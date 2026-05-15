from __future__ import annotations

import asyncio
import json
import logging
import os
import re
import time
import unicodedata
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any

import httpx
from dotenv import load_dotenv
import traceback

from fastapi import Depends, FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from auth.security import get_current_user
try:
    from backend.email_service import generate_otp, send_otp_email
except Exception:
    from email_service import generate_otp, send_otp_email

from database import get_db, init_db
from routes.auth import router as auth_router
from routes.brushing import router as brushing_router
from routes.myths import router as myths_router
from routes.notifications import router as notifications_router
from routes.users import router as users_router
from schemas.auth import EmailRequest, LoginRequest, SignupRequest, TokenResponse, VerifyOtpRequest
from services.auth_service import authenticate_user, create_user, send_password_reset_otp, verify_password_reset_otp
from services.myth_history_service import create_history_entry

_THIS_DIR = Path(__file__).resolve().parent
_ENV_CANDIDATES = [
    _THIS_DIR / '.env',
    _THIS_DIR.parent / '.env',
]
for env_path in _ENV_CANDIDATES:
    if env_path.exists():
        load_dotenv(dotenv_path=env_path, override=False)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("dentzy.groq")

GROQ_API_KEY = os.getenv("GROQ_API_KEY", "").strip()
GROQ_MODEL = os.getenv("GROQ_MODEL", "llama-3.3-70b-versatile").strip() or "llama-3.3-70b-versatile"
GROQ_FALLBACK_MODEL = "llama-3.1-8b-instant"
GROQ_BASE_URL = os.getenv("GROQ_BASE_URL", "https://api.groq.com/openai/v1").strip().rstrip("/")
GROQ_TIMEOUT_SECONDS = float(os.getenv("GROQ_TIMEOUT_SECONDS", "15"))
CLASSIFY_REQUEST_TIMEOUT = 18.0

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(auth_router)
app.include_router(users_router)
app.include_router(myths_router)
app.include_router(brushing_router)
app.include_router(notifications_router)


class InputText(BaseModel):
    text: str = Field(default="")


_EMAIL_PATTERN = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


def _normalize_email(email: str) -> str:
    return (email or "").strip().lower()


def _is_valid_email(email: str) -> bool:
    return bool(_EMAIL_PATTERN.fullmatch(_normalize_email(email)))


def _detect_language(text: str) -> str:
    """Detect language: English, Tamil, or Mixed (Tanglish)."""
    # Tamil Unicode range: U+0B80 to U+0BFF
    tamil_chars = any('\u0B80' <= c <= '\u0BFF' for c in text)
    # English ASCII letters
    english_chars = any(c.isascii() and c.isalpha() for c in text)

    if tamil_chars and english_chars:
        return "mixed"
    elif tamil_chars:
        return "tamil"
    
    return "english"


SYSTEM_PROMPT = """
You are an advanced multilingual dental myth classifier.

Supported languages:
- English
- Tamil
- Tanglish (mixed English-Tamil)

FIRST TASK:
Determine whether the statement is related to:
- teeth
- gums
- mouth
- oral hygiene
- dental care
- cavities
- brushing
- flossing
- dentist
- oral health

If the statement is unrelated to dentistry or oral health,
ALWAYS return:
NOT_DENTAL

Examples of NOT_DENTAL:
- fish flying
- weather
- cars
- sports
- programming
- movies
- animals
- space
- politics

SECOND TASK:
If the statement IS dental-related:
- classify as FACT or MYTH

Definitions:
FACT = scientifically correct dental information
MYTH = false or misleading dental information
NOT_DENTAL = unrelated to oral/dental health

IMPORTANT:
- Tamil input → Tamil explanation
- English input → English explanation
- Keep explanations short (under 20 words)

Return ONLY valid JSON:
{
  "type":"FACT",
  "confidence":95,
  "explanation":"short explanation"
}
"""


def _normalize_type(value: Any) -> str:
    normalized = str(value or "").strip().upper().replace("-", "_").replace(" ", "_")
    if normalized in {"FACT", "MYTH", "NOT_DENTAL"}:
        return normalized
    return "NOT_DENTAL"


def _normalize_confidence(value: Any) -> int:
    try:
        confidence = float(value)
    except (TypeError, ValueError):
        return 0

    if 0.0 <= confidence <= 1.0:
        confidence *= 100.0

    return int(max(0, min(100, round(confidence))))


def _safe_text(value: Any, fallback: str) -> str:
    text = str(value or "").strip()
    return text if text else fallback


def _has_dental_keywords(text: str, detected_language: str) -> tuple[bool, str | None]:
    """
    Check if text contains dental keywords.
    Returns (has_dental_keywords, matched_keyword_or_none)
    
    For Tamil: be MORE permissive (skip early exit, send to GROQ)
    For English/Mixed: use early exit if keywords found
    """
    user_text = text or ""
    text_lower = user_text.lower()
    
    # Normalize Tamil text for better matching
    text_normalized = unicodedata.normalize("NFC", user_text)

    # English dental keywords (expanded)
    ENGLISH_KEYWORDS = [
        "tooth",
        "teeth",
        "gum",
        "gums",
        "oral",
        "mouth",
        "dentist",
        "dental",
        "brush",
        "brushing",
        "toothpaste",
        "floss",
        "flossing",
        "cavity",
        "cavities",
        "plaque",
        "enamel",
        "mouthwash",
        "oral hygiene",
        "tooth decay",
        "bad breath",
        "bleeding gums",
        "tongue",
        "whitening",
        "denture",
        "implant",
        "braces",
    ]

    # Tamil dental keywords (expanded with variations)
    TAMIL_KEYWORDS = [
        "பல்",           # tooth
        "பற்",           # tooth (variant)
        "பற்கள்",         # teeth
        "பற்களை",        # teeth (with suffix)
        "பல்லு",         # tooth (colloquial)
        "வாய்",          # mouth
        "வாய்நலம்",      # oral health
        "ஈறு",          # gum
        "ஈறுகள்",        # gums
        "பற்பசை",        # toothpaste
        "டூத்ப்பேஸ்ட",   # toothpaste (English-Tamil)
        "துலக்கு",       # brush
        "துலக்க",        # brush (variant)
        "துலக்குதல்",     # brushing
        "பல் துலக்கு",    # tooth brushing
        "பல் மருத்துவர்",  # dentist
        "மருத்துவர்",     # doctor/dentist
        "பாக்டீரியா",     # bacteria
        "பாக்டீரியாக்கள்", # bacteria (plural)
        "வாய்துர்நாற்றம்", # bad breath
        "கேவிட்டி",       # cavity
        "கேவிட்டிகள்",    # cavities
        "பல் வலி",       # tooth pain
        "வலி",           # pain
        "சுத்தம்",        # clean
        "சுத்தமாக",      # cleanliness
    ]

    # Tanglish keywords
    TANGLISH_KEYWORDS = [
        "pal",
        "pallu",
        "brush panna",
        "tooth paste",
        "dentist paakanum",
        "pal vali",
        "vay nalam",
        "floss panna",
    ]

    # Check English keywords
    for keyword in ENGLISH_KEYWORDS:
        if keyword.lower() in text_lower:
            logger.info("[KEYWORD MATCH] English=%s language=%s", keyword, detected_language)
            return (True, keyword)

    # Check Tamil keywords (with normalized text)
    for keyword in TAMIL_KEYWORDS:
        if keyword in text or keyword in text_normalized:
            logger.info("[KEYWORD MATCH] Tamil=%s language=%s", keyword, detected_language)
            return (True, keyword)

    # Check Tanglish keywords
    for keyword in TANGLISH_KEYWORDS:
        if keyword.lower() in text_lower:
            logger.info("[KEYWORD MATCH] Tanglish=%s language=%s", keyword, detected_language)
            return (True, keyword)

    logger.info("[NO KEYWORD MATCH] language=%s", detected_language)
    return (False, None)


def _not_dental_response(detected_language: str) -> dict[str, Any]:
    """Return NOT_DENTAL response in the detected language."""
    if detected_language == "tamil":
        explanation = "இந்த வாக்கியம் பல் அல்லது வாய்நலத்துடன் தொடர்புடையதல்ல."
    elif detected_language == "mixed":
        explanation = "This statement is not related to dental or oral health."
    else:
        explanation = "This statement is not related to dental or oral health."
    
    return {
        "type": "NOT_DENTAL",
        "confidence": 100,
        "explanation": explanation,
    }


def extract_json(content: str) -> dict[str, Any] | None:
    try:
        cleaned = (
            content.replace("```json", "")
            .replace("```", "")
            .strip()
        )

        match = re.search(r'\{.*', cleaned, re.DOTALL)
        if not match:
            raise Exception("No JSON object found")

        json_text = match.group(0).strip()

        # repair missing quote
        if json_text.count('"') % 2 != 0:
            json_text += '"'

        # repair missing brace
        if not json_text.endswith("}"):
            json_text += "}"

        parsed = json.loads(json_text)
        return parsed if isinstance(parsed, dict) else None

    except Exception as e:
        logger.error("JSON parse error: %s", e)
        return None


def _fallback_response(message: str) -> dict[str, Any]:
    return {
        "type": "NOT_DENTAL",
        "confidence": 0,
        "explanation": message,
    }


@app.on_event("startup")
async def _startup_log() -> None:
    logger.info("=" * 60)
    logger.info("Backend starting - Multilingual Myth Checker")
    logger.info("=" * 60)
    logger.info("Groq model=%s", GROQ_MODEL)
    logger.info("GROQ base URL=%s", GROQ_BASE_URL)
    logger.info("GROQ API key loaded=%s", bool(GROQ_API_KEY))
    logger.info("GROQ timeout=%s seconds", GROQ_TIMEOUT_SECONDS)
    logger.info("Classify request timeout=%s seconds", CLASSIFY_REQUEST_TIMEOUT)
    logger.info("Supported languages: English, Tamil, Mixed (Tanglish)")
    logger.info("=" * 60)
    await asyncio.to_thread(init_db)


@app.post("/signup", response_model=TokenResponse)
def signup(payload: SignupRequest, db: Session = Depends(get_db)):
    logger.info("[AUTH] POST /signup email=%s", payload.email)
    try:
        result = create_user(db, payload)
        logger.info("[AUTH] Signup success email=%s", payload.email)
        return result
    except HTTPException as exc:
        logger.warning("[AUTH] Signup failed - HTTPException email=%s status=%d", payload.email, exc.status_code)
        detail = exc.detail if isinstance(exc.detail, dict) else {"success": False, "error": str(exc.detail)}
        message = detail.get("message") or detail.get("error") or "Unable to create account right now. Please try again."
        return JSONResponse(
            status_code=exc.status_code,
            content={
                "success": False,
                "error": message,
                "message": message,
                "error_code": detail.get("error_code"),
            },
        )
    except Exception as e:
        logger.exception("[AUTH] Signup failed - Exception email=%s error=%s", payload.email, str(e))
        traceback.print_exc()
        return JSONResponse(
            status_code=500,
            content={"success": False, "error": "Unable to create account right now. Please try again."},
        )


@app.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    return authenticate_user(db, payload)


@app.get("/health")
async def health() -> dict[str, Any]:
    return {
        "status": "ok",
        "groq_model": GROQ_MODEL,
        "groq_configured": bool(GROQ_API_KEY),
        "email_configured": bool(os.getenv("EMAIL_USER", "").strip() and os.getenv("EMAIL_PASSWORD", "").strip()),
    }


@app.post("/send-otp")
def send_otp(payload: EmailRequest, db: Session = Depends(get_db)) -> dict[str, Any]:
    return send_password_reset_otp(db, str(payload.email))


@app.post("/verify-otp")
def verify_otp(payload: VerifyOtpRequest, db: Session = Depends(get_db)) -> dict[str, Any]:
    return verify_password_reset_otp(db, str(payload.email), payload.otp)


@app.get('/test-email')
async def test_email(email: str) -> dict[str, Any]:
    """Test SMTP connectivity."""
    target = _normalize_email(email)
    logger.info('[OTP] /test-email target=%s', target)
    if not _is_valid_email(target):
        raise HTTPException(
            status_code=400,
            detail={
                'success': False,
                'error_code': 'invalid_email',
                'message': 'Please provide a valid email address.',
            },
        )

    test_otp = generate_otp()
    try:
        await asyncio.to_thread(
            send_otp_email,
            recipient_email=target,
            otp=test_otp,
            ttl_minutes=_OTP_TTL_MINUTES,
        )
        logger.info('[OTP] /test-email send success target=%s', target)
    except RuntimeError as exc:
        logger.exception('[OTP] /test-email send failed target=%s error=%s', target, exc)
        raise HTTPException(
            status_code=500,
            detail={
                'success': False,
                'error_code': 'email_send_failed',
                'message': 'Unable to send OTP email right now.',
            },
        ) from exc

    return {
        'success': True,
        'message': 'Test OTP email sent successfully.',
    }


async def _classify_with_groq(sentence: str, detected_language: str) -> dict[str, Any]:
    start_time = time.time()
    
    if not GROQ_API_KEY:
        logger.error("GROQ_API_KEY is not configured")
        return _fallback_response("Unable to classify statement right now.")

    logger.info("=" * 80)
    logger.info("GROQ CLASSIFICATION START")
    logger.info("=" * 80)
    logger.info("Detected language=%s", detected_language)
    logger.info("Input text=%r", sentence)
    logger.info("Input length=%d chars", len(sentence))

    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json; charset=utf-8",
        "Accept": "application/json",
    }

    url = f"{GROQ_BASE_URL}/chat/completions"
    models_to_try = [GROQ_MODEL, GROQ_FALLBACK_MODEL]
    
    for attempt, model in enumerate(models_to_try, 1):
        logger.info("Model attempt %d/%d: %s", attempt, len(models_to_try), model)
        
        payload = {
            "model": model,
            "messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": sentence},
            ],
            "temperature": 0.1,
            "max_tokens": 250,
            "top_p": 0.9,
        }

        logger.info("GROQ URL=%s", url)
        logger.info("GROQ model=%s", model)

        try:
            async with httpx.AsyncClient(timeout=GROQ_TIMEOUT_SECONDS) as client:
                response = await client.post(url, headers=headers, json=payload)
            logger.info("GROQ HTTP request completed with status=%s", response.status_code)
        except httpx.TimeoutException as exc:
            logger.error("GROQ request timed out after %s seconds", GROQ_TIMEOUT_SECONDS)
            return _fallback_response("GROQ request timed out.")
        except httpx.HTTPError as exc:
            logger.error("GROQ HTTP error occurred: %s", exc)
            return _fallback_response("GROQ HTTP request failed.")

        raw_body = response.text
        logger.info("GROQ response status code=%s", response.status_code)
        logger.info("GROQ response body length=%d chars", len(raw_body))

        if response.status_code == 400 and attempt < len(models_to_try):
            logger.warning("Model %s returned HTTP 400, trying fallback model...", model)
            continue

        if response.status_code < 200 or response.status_code >= 300:
            logger.error("GROQ API returned error status=%s", response.status_code)
            return _fallback_response(f"GROQ API error: HTTP {response.status_code}")

        try:
            data = response.json()
        except json.JSONDecodeError as e:
            logger.error("Failed to parse GROQ response as JSON: %s", e)
            return _fallback_response("GROQ response was not valid JSON.")

        try:
            if "choices" not in data or len(data["choices"]) == 0:
                logger.error("GROQ response missing or empty choices")
                return _fallback_response("GROQ returned empty choices.")
            
            content = data["choices"][0]["message"]["content"]
            logger.info("Successfully extracted message content from GROQ")
        except (KeyError, IndexError, TypeError) as e:
            logger.error("Error extracting content from GROQ response: %s", e)
            return _fallback_response("Failed to extract content from GROQ response.")

        logger.info("GROQ message content length=%d chars", len(content))

        parsed = extract_json(content)
        if not parsed:
            logger.error("Failed to extract JSON object from GROQ content")
            return _fallback_response("Failed to parse GROQ classification JSON.")

        logger.info("Successfully extracted JSON from GROQ content")

        if not isinstance(parsed, dict):
            logger.error("Parsed JSON is not a dict: %s", type(parsed))
            return _fallback_response("GROQ returned invalid JSON format.")

        normalized = {
            "type": _normalize_type(parsed.get("type")),
            "confidence": _normalize_confidence(parsed.get("confidence")),
            "explanation": _safe_text(
                parsed.get("explanation"),
                "Unable to generate detailed explanation at this time.",
            ),
        }
        logger.info("Normalized type=%s, confidence=%d", normalized["type"], normalized["confidence"])

        elapsed = time.time() - start_time
        logger.info("=" * 80)
        logger.info("GROQ CLASSIFICATION RESULT: type=%s confidence=%d language=%s model=%s elapsed=%.3fs", 
                    normalized["type"], normalized["confidence"], detected_language, model, elapsed)
        logger.info("=" * 80)
        
        return normalized
    
    logger.error("All model attempts failed")
    return _fallback_response("Unable to classify statement right now.")


@app.post("/classify")
async def classify(
    request: Request,
    payload: InputText, 
    db: Session = Depends(get_db), 
    current_user=Depends(get_current_user)
):
    request_start = time.time()
    sentence = (payload.text or "").strip()
    
    logger.info("\n" + "▶" * 40)
    logger.info("NEW CLASSIFICATION REQUEST")
    logger.info("▶" * 40)
    logger.info("Input text=%r", sentence)
    logger.info("Input length=%d characters", len(sentence))
    
    if not sentence:
        logger.warning("Empty text received - returning fallback")
        return _fallback_response("Please enter a statement to classify.")

    # Detect language
    detected_language = _detect_language(sentence)
    logger.info("[LANGUAGE DETECTED] language=%s", detected_language)

    # Check for dental keywords
    has_keywords, matched_keyword = _has_dental_keywords(sentence, detected_language)
    
    # For Tamil/Mixed: ALWAYS send to GROQ (be permissive)
    # For English: use early exit only if no keywords found
    if not has_keywords and detected_language == "english":
        logger.info("[ROUTE] Returning NOT_DENTAL early (no keywords found). language=%s", detected_language)
        return _not_dental_response(detected_language)
    
    if has_keywords:
        logger.info("[ROUTE] Sending to GROQ. language=%s keyword=%s", detected_language, matched_keyword)
    else:
        logger.info("[ROUTE] Sending to GROQ (Tamil/Mixed - more permissive). language=%s", detected_language)

    try:
        result = await asyncio.wait_for(
            _classify_with_groq(sentence, detected_language),
            timeout=CLASSIFY_REQUEST_TIMEOUT
        )
    except asyncio.TimeoutError:
        elapsed = time.time() - request_start
        logger.error("CLASSIFY REQUEST TIMEOUT after %.3f seconds", elapsed)
        return _fallback_response("Classification request timed out. Please try again.")
    except Exception as e:
        elapsed = time.time() - request_start
        logger.exception("CLASSIFY REQUEST ERROR after %.3f seconds: %s", elapsed, e)
        return _fallback_response("An error occurred during classification.")
    
    elapsed = time.time() - request_start
    logger.info("▶ FINAL RESPONSE TO CLIENT")
    logger.info("Type=%s, Confidence=%d, Explanation=%r, Total elapsed=%.3fs", 
                result.get("type"), result.get("confidence"), 
                result.get("explanation", "")[:100], elapsed)
    logger.info("▶" * 40 + "\n")
    
    # SAVE TO MYTH HISTORY TABLE
    auth_header = request.headers.get("authorization", "")
    print(f"[CLASSIFY] Authorization header received: {auth_header[:24]}{'...' if len(auth_header) > 24 else ''}")
    print(f"[CLASSIFY] Current user = {current_user.id}")
    print(f"[CLASSIFY] Result received: type={result.get('type')}, confidence={result.get('confidence')}")
    
    if current_user is not None and result.get("type") in {"FACT", "MYTH", "NOT_DENTAL"}:
        print(f"[CLASSIFY] Attempting to save history for user_id={current_user.id}")
        try:
            print(f"[SAVING] TO MYTH_HISTORY table")
            print(f"[SAVING] user_id={current_user.id}, statement={sentence}, type={result.get('type')}, confidence={result.get('confidence')}")
            
            create_history_entry(
                db,
                current_user,
                statement=sentence,
                result_type=str(result.get("type", "NOT_DENTAL")),
                confidence=float(result.get("confidence", 0)),
                explanation=str(result.get("explanation", "")),
            )
            print(f"[CLASSIFY] MYTH_HISTORY SAVED SUCCESSFULLY for user_id={current_user.id}")
        except Exception as e:
            print(f"[CLASSIFY] SAVE ERROR: {str(e)}")
            print(f"[CLASSIFY] Exception type: {type(e).__name__}")
            traceback.print_exc()
            db.rollback()
    else:
        print(f"[CLASSIFY] History NOT saved - result type '{result.get('type')}' not in FACT/MYTH/NOT_DENTAL")
    
    return result
