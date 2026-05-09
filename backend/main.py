from __future__ import annotations

import json
import logging
import os
import re
import unicodedata
from typing import Any

import httpx
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("dentzy.groq")

GROQ_API_KEY = os.getenv("GROQ_API_KEY", "").strip()
# Primary model: llama-3.3-70b-versatile (superior Tamil reasoning)
# Fallback model: llama-3.1-8b-instant (widely available)
GROQ_MODEL = os.getenv("GROQ_MODEL", "llama-3.3-70b-versatile").strip() or "llama-3.3-70b-versatile"
GROQ_FALLBACK_MODEL = "llama-3.1-8b-instant"
GROQ_BASE_URL = os.getenv("GROQ_BASE_URL", "https://api.groq.com/openai/v1").strip().rstrip("/")
GROQ_TIMEOUT_SECONDS = float(os.getenv("GROQ_TIMEOUT_SECONDS", "30"))

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class InputText(BaseModel):
    text: str = Field(default="")


def _detect_language(text: str) -> str:
    """
    Detect whether text is English, Tamil, or mixed (Tanglish).
    
    Returns:
        "english" | "tamil" | "mixed"
    """
    if not text or not text.strip():
        return "english"
    
    # Tamil Unicode ranges: U+0B80 to U+0BFF
    tamil_pattern = re.compile(r'[\u0B80-\u0BFF]')
    english_pattern = re.compile(r'[a-zA-Z]')
    
    has_tamil = bool(tamil_pattern.search(text))
    has_english = bool(english_pattern.search(text))
    
    if has_tamil and has_english:
        return "mixed"
    elif has_tamil:
        return "tamil"
    else:
        return "english"



SYSTEM_PROMPT = """
You are an advanced multilingual dental myth classifier.

Supported languages:
- English
- Tamil
- Tanglish

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


def _has_dental_keywords(text: str) -> bool:
    """
    Quick pre-check: does the text contain ANY dental-related keywords?
    If not, return NOT_DENTAL immediately without calling GROQ.
    """
    text_lower = text.lower()
    
    # English and Tanglish keywords
    dental_keywords = {
        "tooth", "teeth", "dental", "dentist", "brush", "brushing",
        "floss", "flossing", "gum", "gums", "cavity", "cavities",
        "plaque", "tartar", "enamel", "mouth", "oral", "fluoride",
        "toothpaste", "toothbrush", "whitening", "cleaning", "decay",
        "canine", "molar", "incisor", "root", "sensitivity",
        "bleeding", "infection", "crown", "bridge", "implant",
        "gingivitis", "caries", "gingiva",
    }
    
    # Tanglish keywords
    tanglish_keywords = {
        "pal", "pale", "paal", "paale", "iragu", "irukal", "irugalai",
        "sulagu", "tulagu", "soothae", "vaay", "aarokkiam", "arogyam",
        "noi", "theai", "kedu", "pul", "kodi", "pulvaithiyam", "pulvaithiyan",
        "tulakkum", "soothukku",
    }
    
    # Tamil keywords (check in original text, not lowercased)
    tamil_keywords = {
        "பல்", "ஈறு", "வாய்", "பல்வைத்", "பல்வைத்யம்", "பல்வைத்யன்",
        "ஆரோக்கியம்", "சொத்த", "கெட்ட", "நோய்", "துலக்க", "துலக்கு",
        "சீற", "சீறல்", "சீற", "சுளுவ", "சுளுவு", "புண்", "தேய்", "கொப்பளிப்பு",
    }
    
    # Check English/Tanglish (case-insensitive)
    for keyword in dental_keywords:
        if keyword in text_lower:
            return True
    
    for keyword in tanglish_keywords:
        if keyword in text_lower:
            return True
    
    # Check Tamil (case-sensitive)
    for keyword in tamil_keywords:
        if keyword in text:
            return True
    
    return False


def _not_dental_response(detected_language: str) -> dict[str, Any]:
    """
    Return NOT_DENTAL response in the detected language.
    """
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


    """Check if sentence is related to dental health (English, Tamil, and Tanglish)."""
    text = (sentence or "").lower()
    
    # English keywords
    english_keywords = (
        "tooth",
        "teeth",
        "dental",
        "dentist",
        "brush",
        "brushing",
        "floss",
        "gum",
        "gums",
        "cavity",
        "cavities",
        "plaque",
        "tartar",
        "enamel",
        "mouth",
        "oral",
        "fluoride",
        "toothpaste",
        "toothbrush",
        "whitening",
        "cleaning",
        "decay",
        "canine",
        "molar",
        "incisor",
        "root",
        "sensitivity",
        "gums",
        "bleeding",
        "infection",
        "crown",
        "bridge",
        "implant",
        "gingiva",
        "caries",
        "gingivitis",
        "flossing",
    )
    
    # Tanglish keywords (Tamil words written in English letters)
    tanglish_keywords = (
        "pal",  # tooth
        "pale",  # teeth
        "paal",  # tooth
        "paale",  # teeth
        "iragu",  # gum
        "irukal",  # gums
        "irugalai",  # gums (accusative)
        "sulagu",  # cavity/decay
        "tulagu",  # to brush
        "soothae",  # to clean
        "vaay",  # mouth
        "aarokkiam",  # health
        "arogyam",  # health
        "noi",  # disease
        "theai",  # to wear/decay
        "kedu",  # bad
        "pul",  # tooth
        "kodi",  # cavity
        "pulvaithiyam",  # dentistry
        "pulvaithiyan",  # dentist
        "tulakkum",  # brushing
        "soothukku",  # cleaning
    )
    
    # Tamil keywords (in Tamil script)
    tamil_keywords = (
        "பல்",  # tooth/paal
        "பாலி",  # teeth-like
        "பற்",  # dental
        "பலி",  # palli
        "ஈறு",  # gums/iru
        "ஈறுகளை",  # gums (accusative)
        "சீறல்",  # brushing
        "சீற",  # brush
        "துலக்க",  # brush (brush/sweep)
        "வாய்",  # mouth/mouth
        "வாய்",  # mouth
        "பல்வைத்",  # tooth care
        "பல்வைத்யம்",  # dentistry
        "பல்வைத்யன்",  # dentist
        "ஆரோக்கியம்",  # health
        "பொலிவு",  # brightness/whitening
        "சுளுவ",  # cavity
        "சுளுவு",  # cavity
        "புண்",  # ulcer/decay
        "சொத்த",  # cleansing
        "கெட்ட",  # bad/decay
        "தேய்",  # to wear away/decay
        "தேய்தல்",  # rubbing/brushing
        "நோய்",  # disease
        "கொப்பளிப்பு",  # flossing
    )
    
    # Check English keywords
    has_english_keyword = any(keyword in text for keyword in english_keywords)
    
    # Check Tanglish keywords (case-insensitive)
    has_tanglish_keyword = any(keyword in text for keyword in tanglish_keywords)
    
    # Check Tamil keywords (case-sensitive for Unicode)
    has_tamil_keyword = any(keyword in sentence for keyword in tamil_keywords)
    
    return has_english_keyword or has_tanglish_keyword or has_tamil_keyword


def extract_json(content: str) -> dict[str, Any] | None:
    try:
        cleaned = (
            content.replace("```json", "")
            .replace("```", "")
            .strip()
        )

        print("\n================ CLEANED RESPONSE ================\n")
        print(cleaned)
        print("\n==================================================\n")

        match = re.search(r'\{.*', cleaned, re.DOTALL)

        if not match:
            raise Exception("No JSON object found")

        json_text = match.group(0)

        json_text = json_text.strip()

        # repair missing quote
        if json_text.count('"') % 2 != 0:
            json_text += '"'

        # repair missing brace
        if not json_text.endswith("}"):
            json_text += "}"

        print("\n================ EXTRACTED JSON ==================\n")
        print(json_text)
        print("\n==================================================\n")

        parsed = json.loads(json_text)

        return parsed if isinstance(parsed, dict) else None

    except Exception as e:
        print("\n================ JSON PARSE ERROR ================\n")
        print(str(e))
        print("\n==================================================\n")
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
    logger.info("Supported languages: English, Tamil, Mixed (Tanglish)")
    logger.info("=" * 60)


@app.get("/health")
async def health() -> dict[str, Any]:
    return {
        "status": "ok",
        "groq_model": GROQ_MODEL,
        "groq_configured": bool(GROQ_API_KEY),
    }


async def _classify_with_groq(sentence: str) -> dict[str, Any]:
    if not GROQ_API_KEY:
        logger.error("GROQ_API_KEY is not configured")
        return _fallback_response("Unable to classify statement right now.")

    # Detect language
    detected_language = _detect_language(sentence)
    logger.info("=" * 80)
    logger.info("GROQ CLASSIFICATION START")
    logger.info("=" * 80)
    logger.info("Detected language=%s", detected_language)
    logger.info("Input text=%r", sentence)
    logger.info("Input length=%d chars", len(sentence))

    # PRE-CHECK: Does the statement have dental-related keywords?
    # If not, return NOT_DENTAL immediately without calling GROQ
    if not _has_dental_keywords(sentence):
        logger.info("PRE-CHECK: No dental keywords found, returning NOT_DENTAL immediately")
        result = _not_dental_response(detected_language)
        logger.info("=" * 80)
        logger.info("GROQ CLASSIFICATION RESULT (PRE-CHECK): type=%s confidence=%d",
                    result["type"], result["confidence"])
        logger.info("=" * 80)
        return result

    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json; charset=utf-8",
        "Accept": "application/json",
    }

    url = f"{GROQ_BASE_URL}/chat/completions"

    # Try primary model first (llama-3.3-70b-versatile)
    # If that fails with HTTP 400, fallback to llama-3.1-8b-instant
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
        logger.debug("GROQ request payload=%s", json.dumps(payload, ensure_ascii=False, indent=2))

        # Make GROQ API request
        try:
            async with httpx.AsyncClient(timeout=GROQ_TIMEOUT_SECONDS) as client:
                response = await client.post(url, headers=headers, json=payload)
            logger.info("GROQ HTTP request completed with status=%s", response.status_code)
        except httpx.TimeoutException as exc:
            logger.error("GROQ request timed out after %s seconds", GROQ_TIMEOUT_SECONDS)
            logger.exception("Timeout exception: %s", exc)
            return _fallback_response("GROQ request timed out.")
        except httpx.HTTPError as exc:
            logger.error("GROQ HTTP error occurred")
            logger.exception("HTTP error: %s", exc)
            return _fallback_response("GROQ HTTP request failed.")

        # Check response status
        raw_body = response.text
        logger.info("GROQ response status code=%s", response.status_code)
        logger.info("GROQ response body length=%d chars", len(raw_body))
        logger.debug("GROQ raw response body=%s", raw_body)

        # If this model failed with 400, try fallback
        if response.status_code == 400 and attempt < len(models_to_try):
            logger.warning("Model %s returned HTTP 400, trying fallback model...", model)
            continue

        if response.status_code < 200 or response.status_code >= 300:
            logger.error("GROQ API returned error status=%s", response.status_code)
            logger.error("Error response body=%s", raw_body)
            return _fallback_response(f"GROQ API error: HTTP {response.status_code}")

        # Parse GROQ response structure
        logger.info("Parsing GROQ JSON response structure...")
        try:
            data = response.json()
            logger.debug("GROQ JSON structure parsed successfully")
        except json.JSONDecodeError as e:
            logger.error("Failed to parse GROQ response as JSON: %s", e)
            logger.error("Response body was: %s", raw_body)
            return _fallback_response("GROQ response was not valid JSON.")

        # Extract message content from GROQ response
        logger.info("Extracting message content from GROQ response...")
        try:
            if "choices" not in data:
                logger.error("GROQ response missing 'choices' key. Keys: %s", list(data.keys()))
                return _fallback_response("GROQ response format invalid.")
            
            if len(data["choices"]) == 0:
                logger.error("GROQ response choices array is empty")
                return _fallback_response("GROQ returned empty choices.")
            
            choice = data["choices"][0]
            if "message" not in choice:
                logger.error("GROQ choice missing 'message' key. Keys: %s", list(choice.keys()))
                return _fallback_response("GROQ choice format invalid.")
            
            message = choice["message"]
            if "content" not in message:
                logger.error("GROQ message missing 'content' key. Keys: %s", list(message.keys()))
                return _fallback_response("GROQ message format invalid.")
            
            content = message["content"]
            print("\n================ RAW GROQ RESPONSE ================\n")
            print(content)
            print("\n===================================================\n")

            if not content.strip().endswith("}"):
                print("INCOMPLETE JSON RESPONSE DETECTED")

                # attempt repair
                if not content.strip().endswith('"'):
                    content += '"'

                content += "}"

            logger.info("Successfully extracted message content from GROQ")
        except (KeyError, IndexError, TypeError) as e:
            logger.error("Error extracting content from GROQ response: %s", e)
            logger.error("GROQ response data structure: %s", json.dumps(data, ensure_ascii=False)[:500])
            return _fallback_response("Failed to extract content from GROQ response.")

        logger.info("GROQ message content length=%d chars", len(content))
        logger.debug("GROQ message content=%s", content)

        # Extract JSON from message content
        logger.info("Extracting JSON from GROQ message content...")
        parsed = extract_json(content)
        
        if not parsed:
            logger.error("Failed to extract JSON object from GROQ content")
            logger.error("GROQ content was: %s", content)
            return _fallback_response("Failed to parse GROQ classification JSON.")

        logger.info("Successfully extracted JSON from GROQ content")
        logger.debug("Parsed JSON=%s", json.dumps(parsed, ensure_ascii=False))

        # Validate extracted JSON has required fields
        logger.info("Validating parsed JSON fields...")
        if not isinstance(parsed, dict):
            logger.error("Parsed JSON is not a dict: %s", type(parsed))
            return _fallback_response("GROQ returned invalid JSON format.")

        required_fields = ["type", "confidence", "explanation"]
        missing_fields = [f for f in required_fields if f not in parsed]
        if missing_fields:
            logger.warning("Parsed JSON missing fields: %s. Parsed: %s", missing_fields, parsed)
            # Still try to use it if we have at least 'type'
            if "type" not in parsed:
                return _fallback_response("GROQ JSON missing required 'type' field.")

        logger.info("Parsed JSON has all required fields")

        # Normalize the classification
        logger.info("Normalizing classification values...")
        normalized = {
            "type": _normalize_type(parsed.get("type")),
            "confidence": _normalize_confidence(parsed.get("confidence")),
            "explanation": _safe_text(
                parsed.get("explanation"),
                "Unable to generate detailed explanation at this time.",
            ),
        }
        logger.info("Normalized type=%s, confidence=%d", normalized["type"], normalized["confidence"])

        # Only apply fallback override for English non-dental text (not for Tamil/mixed)
        if normalized["type"] in {"FACT", "MYTH"} and detected_language == "english" and not _is_dental_related(sentence):
            logger.info("Applying English non-dental override")
            normalized = {
                "type": "NOT_DENTAL",
                "confidence": min(normalized["confidence"], 70),
                "explanation": "This statement does not appear to be about dental health.",
            }

        logger.info("=" * 80)
        logger.info("GROQ CLASSIFICATION RESULT: type=%s confidence=%d language=%s model=%s", 
                    normalized["type"], normalized["confidence"], detected_language, model)
        logger.info("=" * 80)
        
        return normalized
    
    # If all models failed
    logger.error("All model attempts failed")
    return _fallback_response("Unable to classify statement right now.")


@app.post("/classify")
async def classify(payload: InputText):
    sentence = (payload.text or "").strip()
    
    logger.info("\n" + "▶" * 40)
    logger.info("NEW CLASSIFICATION REQUEST")
    logger.info("▶" * 40)
    logger.info("Input text=%r", sentence)
    logger.info("Input length=%d characters", len(sentence))
    
    if not sentence:
        logger.warning("Empty text received - returning fallback")
        logger.info("▶" * 40 + "\n")
        return _fallback_response("Please enter a statement to classify.")

    result = await _classify_with_groq(sentence)
    
    logger.info("▶ FINAL RESPONSE TO CLIENT")
    logger.info("Type=%s, Confidence=%d, Explanation=%r", 
                result.get("type"), result.get("confidence"), 
                result.get("explanation", "")[:100])
    logger.info("▶" * 40 + "\n")
    
    return result
