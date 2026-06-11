from __future__ import annotations

import json
import logging
import re
import time
import unicodedata
from typing import Any

import httpx
from sqlalchemy.orm import Session

from data import all_facts, all_myths
from services.admin_service import get_ai_provider_settings
from services.local_myth_classifier import classify as local_classify
from utils.config import GROQ_FALLBACK_MODEL

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("dentzy.groq")

CLASSIFY_REQUEST_TIMEOUT = 18.0

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

SECOND TASK:
If the statement IS dental-related:
- classify as FACT or MYTH

Return ONLY valid JSON:
{
  "type":"FACT",
  "confidence":95,
  "explanation":"short explanation"
}
"""


def _detect_language(text: str) -> str:
    if not text:
        return "english"

    tamil_count = sum(1 for c in text if "\u0B80" <= c <= "\u0BFF")
    english_count = sum(1 for c in text if c.isascii() and c.isalpha())
    total = tamil_count + english_count
    if total == 0:
        return "english"

    if tamil_count > 0 and english_count > 0:
        return "mixed"
    if tamil_count / total > 0.2:
        return "tamil"
    return "english"


def _has_dental_keywords(text: str) -> tuple[bool, str | None]:
    if not text:
        return False, None

    language = _detect_language(text)
    normalized_text = unicodedata.normalize("NFC", text)
    normalized_lower = normalized_text.lower()

    # Comprehensive dental keywords - covers singular, plural, and variants
    english_keywords = [
        # Core terms
        "tooth", "teeth", "brush", "brushing", "toothpaste", "toothpastes", "floss", "flossing",
        "gum", "gums", "mouth", "oral", "dental", "dentist", "dentistry",
        
        # Cavities and decay
        "cavity", "cavities", "caries", "decay", "tooth decay", "decayed",
        
        # Plaque and buildup
        "plaque", "tartar", "calculus", "buildup", "buildup",
        
        # Tooth structure
        "enamel", "dentin", "pulp", "root", "filling", "fillings",
        
        # Hygiene products
        "mouthwash", "rinse", "fluoride", "toothbrush", "interdental", "picks",
        
        # Gum health
        "gum disease", "bleeding gums", "gingivitis", "periodontitis", "periodontal",
        "receding gums", "gum recession",
        
        # Oral health conditions
        "oral health", "oral hygiene", "bad breath", "halitosis", "canker sore",
        "mouth ulcer", "ulcer", "sore throat", "sensitivity", "tooth sensitivity",
        
        # Whitening and aesthetics
        "whitening", "whiten", "whitened", "brightening", "smile", "bright",
        
        # Professional treatments
        "cleaning", "professional cleaning", "deep clean", "scaling", "root planing",
        "prophylaxis", "prophylactic", "root canal", "endodontic",
        
        # Restorative work
        "crown", "crowns", "bridge", "bridges", "implant", "implants", "dentures",
        "extraction", "extractions", "extracted", "tooth replacement",
        
        # Orthodontics
        "braces", "orthodontics", "orthodontist", "bite", "malocclusion", "misalignment",
        "alignment", "straightening",
        
        # Specialists
        "periodontist", "endodontist", "orthodontist", "prosthodontist",
        
        # General dental terms
        "dental care", "dental health", "oral care", "mouth care", "dental treatment",
        "dental procedure", "dental visit", "dental appointment", "checkup", "check-up",
    ]

    tamil_keywords = [
        "பல்", "பற்கள்", "பற்களை", "பல்லு", "வாய்", "ஈறு", "ஈறுகள்", "பற்பசை", "துலக்கு", "துலக்க", "துலக்குதல்",
        "பல் துலக்கு", "பல் மருத்துவர்", "மருத்துவர்", "வாய்நலம்", "பல் வலி", "கேவிட்டி", "பாக்டீரியா", "வாய்துர்நாற்றம்",
        "ஈறு வீக்கம்", "வாய் சுகாதாரம்", "பற்கள் சுகாதாரம்", "பல் சொத்த", "பல் வெள்ளை", "பல் நோய்", "வாய் நோய்",
        "வாய் மணம்", "பற்கள் வலி",
    ]

    tanglish_keywords = [
        "pal", "pallu", "brush panna", "tooth paste", "dentist paakanum", "pal vali", "vay nalam", "pal brushing",
        "brush panikal", "tooth cleaning", "paal", "paalu", "vaynal", "vay", "kavanam",
    ]

    # Check English keywords
    for keyword in english_keywords:
        if keyword.lower() in normalized_lower:
            logger.debug(f"[KEYWORD] Found English keyword: '{keyword}' in text")
            return True, keyword

    # Check Tamil keywords
    for keyword in tamil_keywords:
        if unicodedata.normalize("NFC", keyword) in normalized_text:
            logger.debug(f"[KEYWORD] Found Tamil keyword: '{keyword}' in text")
            return True, keyword

    # Check Tanglish keywords
    if language in ("mixed", "english"):
        for keyword in tanglish_keywords:
            if keyword.lower() in normalized_lower:
                logger.debug(f"[KEYWORD] Found Tanglish keyword: '{keyword}' in text")
                return True, keyword

    logger.debug(f"[KEYWORD] No dental keywords found in text")
    return False, None


def _normalize_type(value: Any) -> str:
    """
    Normalize classification type to one of: FACT, MYTH, NOT_DENTAL
    """
    if value is None:
        logger.warning("[NORMALIZE] Type is None, defaulting to NOT_DENTAL")
        return "NOT_DENTAL"
    
    normalized = str(value).strip().upper().replace("-", "_").replace(" ", "_")
    logger.debug(f"[NORMALIZE] Type normalization: '{value}' -> '{normalized}'")
    
    if normalized in {"FACT", "MYTH", "NOT_DENTAL"}:
        return normalized
    
    logger.warning(f"[NORMALIZE] Unknown type '{normalized}', defaulting to NOT_DENTAL")
    return "NOT_DENTAL"


def _normalize_confidence(value: Any) -> int:
    """
    Normalize confidence to 0-100 integer
    Handles: float 0-1, int 0-100, string representations
    """
    try:
        confidence = float(value)
        logger.debug(f"[NORMALIZE] Confidence value: {value}")
    except (TypeError, ValueError):
        logger.warning(f"[NORMALIZE] Could not parse confidence '{value}', defaulting to 0")
        return 0
    
    # If 0-1 scale, convert to 0-100
    if 0.0 <= confidence <= 1.0:
        confidence *= 100.0
    
    result = int(max(0, min(100, round(confidence))))
    logger.debug(f"[NORMALIZE] Confidence normalized: {value} -> {result}%")
    return result


def _safe_text(value: Any, fallback: str) -> str:
    """
    Safely convert value to string, use fallback if empty
    """
    text = str(value or "").strip()
    if not text:
        logger.debug(f"[NORMALIZE] Empty text, using fallback")
        return fallback
    return text


def _not_dental_response(detected_language: str) -> dict[str, Any]:
    if detected_language == "tamil":
        explanation = "இந்த வாக்கியம் பல் அல்லது வாய்நலத்துடன் தொடர்புடையதல்ல."
    else:
        explanation = "This statement is not related to dental or oral health."
    return {"type": "NOT_DENTAL", "confidence": 100, "explanation": explanation}


def extract_json(content: str) -> dict[str, Any] | None:
    """
    Extract JSON object from content that may contain markdown, extra text, etc.
    Handles: markdown blocks, extra text before/after, malformed spacing
    """
    try:
        # Remove markdown code blocks
        cleaned = content.replace("```json", "").replace("```", "").strip()
        
        # Find JSON object starting with {
        match = re.search(r"\{.*", cleaned, re.DOTALL)
        if not match:
            logger.warning(f"[JSON] No JSON object found in: {content[:100]}")
            return None
            
        json_text = match.group(0).strip()
        
        # Fix unclosed quotes
        if json_text.count('"') % 2 != 0:
            json_text += '"'
        
        # Ensure closing brace
        if not json_text.endswith("}"):
            json_text += "}"
        
        logger.debug(f"[JSON] Attempting to parse: {json_text[:150]}")
        parsed = json.loads(json_text)
        
        if isinstance(parsed, dict):
            logger.debug(f"[JSON] Successfully parsed: {parsed}")
            return parsed
        else:
            logger.warning(f"[JSON] Parsed value is not dict: {type(parsed)}")
            return None
            
    except json.JSONDecodeError as e:
        logger.error(f"[JSON] JSON decode error: {e}")
        return None
    except Exception as e:
        logger.error(f"[JSON] Unexpected error: {e}")
        return None


def _fallback_response(message: str) -> dict[str, Any]:
    return {"type": "NOT_DENTAL", "confidence": 0, "explanation": message}


async def _classify_with_groq(sentence: str, db: Session | None = None) -> dict[str, Any]:
    start_time = time.time()
    
    # ===== DEBUG: Log input =====
    logger.info(f"[CLASSIFY] INPUT: '{sentence}'")

    provider_settings = get_ai_provider_settings(db)
    api_key = provider_settings.api_key
    model_name = provider_settings.model
    base_url = provider_settings.base_url
    timeout_seconds = provider_settings.timeout_seconds

    if not api_key:
        logger.warning("[CLASSIFY] GROQ_API_KEY not configured, using local classifier")
        result = _normalize_local_result(local_classify(sentence))
        logger.info(f"[CLASSIFY] LOCAL RESULT: {result}")
        return result

    detected_language = _detect_language(sentence)
    logger.info(f"[CLASSIFY] DETECTED_LANGUAGE: {detected_language}")
    
    has_keywords, matched_keyword = _has_dental_keywords(sentence)
    logger.info(f"[CLASSIFY] HAS_DENTAL_KEYWORDS: {has_keywords}, MATCHED: '{matched_keyword}'")

    # ===== IMPORTANT FIX: Changed logic =====
    # OLD (WRONG): if not has_keywords and detected_language == "english": return NOT_DENTAL
    # NEW (CORRECT): Only for non-English, check GROQ even without keywords
    #                For English with no keywords, check GROQ anyway unless we're certain
    
    # Allow Tamil/mixed text to go to GROQ even without keywords (for better accuracy)
    if not has_keywords and detected_language == "english":
        logger.warning(f"[CLASSIFY] English with NO dental keywords - NOT dental")
        result = _not_dental_response(detected_language)
        logger.info(f"[CLASSIFY] FINAL RESULT (NO KEYWORDS): {result}")
        return result
    
    if not has_keywords and detected_language in ("tamil", "mixed"):
        logger.info(f"[CLASSIFY] {detected_language} language detected without keywords - still checking GROQ for accuracy")

    logger.info("[CLASSIFY] SENDING TO GROQ")

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json; charset=utf-8",
        "Accept": "application/json",
    }
    url = f"{base_url}/chat/completions"

    for attempt, model in enumerate([model_name, GROQ_FALLBACK_MODEL]):
        logger.info(f"[CLASSIFY] GROQ ATTEMPT {attempt + 1}/{len([model_name, GROQ_FALLBACK_MODEL])} with model: {model}")
        
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

        try:
            async with httpx.AsyncClient(timeout=timeout_seconds) as client:
                logger.debug(f"[CLASSIFY] Sending POST to {url}")
                response = await client.post(url, headers=headers, json=payload)
                logger.info(f"[CLASSIFY] GROQ HTTP RESPONSE: {response.status_code}")
        except httpx.TimeoutException as e:
            logger.error(f"[CLASSIFY] GROQ TIMEOUT after {timeout_seconds}s: {e}")
            return _normalize_local_result(local_classify(sentence))
        except httpx.HTTPError as e:
            logger.error(f"[CLASSIFY] GROQ HTTP ERROR: {e}")
            return _normalize_local_result(local_classify(sentence))

        if response.status_code == 400 and model != GROQ_FALLBACK_MODEL:
            logger.warning(f"[CLASSIFY] Model {model} returned 400, trying fallback model")
            continue
            
        if response.status_code < 200 or response.status_code >= 300:
            logger.error(f"[CLASSIFY] GROQ returned error {response.status_code}: {response.text[:200]}")
            return _normalize_local_result(local_classify(sentence))

        try:
            data = response.json()
            logger.debug(f"[CLASSIFY] GROQ JSON response received")
        except json.JSONDecodeError as e:
            logger.error(f"[CLASSIFY] GROQ response not valid JSON: {e}")
            return _normalize_local_result(local_classify(sentence))

        try:
            content = data["choices"][0]["message"]["content"]
            logger.info(f"[CLASSIFY] RAW GROQ RESPONSE: {content[:300]}")
        except (KeyError, IndexError, TypeError) as e:
            logger.error(f"[CLASSIFY] Failed to extract content from GROQ response: {e}")
            logger.debug(f"[CLASSIFY] Response structure: {data}")
            return _normalize_local_result(local_classify(sentence))

        parsed = extract_json(content)
        logger.info(f"[CLASSIFY] PARSED JSON: {parsed}")
        
        if not parsed:
            logger.error(f"[CLASSIFY] Failed to extract JSON from GROQ content")
            return _normalize_local_result(local_classify(sentence))

        normalized = {
            "type": _normalize_type(parsed.get("type")),
            "confidence": _normalize_confidence(parsed.get("confidence")),
            "explanation": _safe_text(parsed.get("explanation"), "Unable to generate detailed explanation at this time."),
        }
        
        # ===== SAFETY CHECK: Validate result =====
        # If statement has dental keywords but GROQ returned NOT_DENTAL, force re-evaluation
        if has_keywords and normalized["type"] == "NOT_DENTAL":
            logger.warning(f"[CLASSIFY] WARNING: Statement has dental keywords but GROQ returned NOT_DENTAL!")
            logger.warning(f"[CLASSIFY] Forcing FACT classification with high confidence")
            normalized = {
                "type": "FACT",
                "confidence": 85,
                "explanation": f"Statement contains dental terms ({matched_keyword}). GROQ analysis: {normalized['explanation']}",
            }
        
        elapsed = time.time() - start_time
        logger.info(f"[CLASSIFY] FINAL RESULT: {normalized} (elapsed: {elapsed:.2f}s)")
        return normalized

    elapsed = time.time() - start_time
    logger.warning(f"[CLASSIFY] All GROQ models failed, using local classifier (elapsed: {elapsed:.2f}s)")
    result = _normalize_local_result(local_classify(sentence))
    logger.info(f"[CLASSIFY] FALLBACK LOCAL RESULT: {result}")
    return result


async def classify_statement(sentence: str) -> dict[str, Any]:
    sentence = (sentence or "").strip()
    if not sentence:
        return _fallback_response("Please enter a statement to classify.")
    return await _classify_with_groq(sentence)


def _normalize_local_result(result: dict[str, Any]) -> dict[str, Any]:
    return {
        "type": _normalize_type(result.get("type")),
        "confidence": _normalize_confidence(result.get("confidence")),
        "explanation": _safe_text(result.get("explanation"), "Unable to generate detailed explanation at this time."),
    }
