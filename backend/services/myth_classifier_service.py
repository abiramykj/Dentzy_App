from __future__ import annotations

import json
import logging
import re
import time
import unicodedata
from typing import Any

import httpx

from data import all_facts, all_myths
from services.local_myth_classifier import classify as local_classify
from utils.config import GROQ_API_KEY, GROQ_BASE_URL, GROQ_FALLBACK_MODEL, GROQ_MODEL, GROQ_TIMEOUT_SECONDS

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

    english_keywords = [
        "tooth", "teeth", "brush", "brushing", "toothpaste", "floss", "gum", "gums", "mouth", "oral",
        "dental", "dentist", "cavity", "plaque", "enamel", "mouthwash", "oral hygiene", "tooth decay",
        "bad breath", "bleeding gums", "root canal", "orthodontics", "whitening", "cleaning", "periodontist",
        "gingivitis", "periodontitis", "canker sore", "mouth ulcer", "tartar", "calculus", "sensitivity",
        "fluoride", "smile", "bite", "malocclusion", "braces", "implant", "crown", "bridge", "dentures",
        "extraction", "prophylaxis", "scaling", "root planing", "deep clean", "professional clean",
    ]

    tamil_keywords = [
        "பல்", "பற்கள்", "பற்களை", "பல்லு", "வாய்", "ஈறு", "ஈறுகள்", "பற்பசை", "துலக்கு", "துலக்க", "துலக்குதல்",
        "பல் துலக்கு", "பல் மருத்துவர்", "மருத்துவர்", "வாய்நலம்", "பல் வலி", "கேவிட்டி", "பாக்டீரியா", "வாய்துர்நாற்றம்",
        "ஈறு வீக்கம்", "வாய் சுகாதாரம்", "பற்கள் சுகாதாரம்", "பல் சொத்த", "பல் வெள்ளை", "பல் நோய்", "வாய் நோய்",
        "வாய் மணம்", "பற்கள் வலி",
    ]

    tanglish_keywords = [
        "pal", "pallu", "brush panna", "tooth paste", "dentist paakanum", "pal vali", "vay nalam", "pal brushing",
        "brush panikal", "tooth cleaning",
    ]

    for keyword in english_keywords:
        if keyword.lower() in normalized_lower:
            return True, keyword

    for keyword in tamil_keywords:
        if unicodedata.normalize("NFC", keyword) in normalized_text:
            return True, keyword

    if language in ("mixed", "english"):
        for keyword in tanglish_keywords:
            if keyword.lower() in normalized_lower:
                return True, keyword

    return False, None


def _normalize_type(value: Any) -> str:
    normalized = str(value or "").strip().upper().replace("-", "_").replace(" ", "_")
    return normalized if normalized in {"FACT", "MYTH", "NOT_DENTAL"} else "NOT_DENTAL"


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


def _not_dental_response(detected_language: str) -> dict[str, Any]:
    if detected_language == "tamil":
        explanation = "இந்த வாக்கியம் பல் அல்லது வாய்நலத்துடன் தொடர்புடையதல்ல."
    else:
        explanation = "This statement is not related to dental or oral health."
    return {"type": "NOT_DENTAL", "confidence": 100, "explanation": explanation}


def extract_json(content: str) -> dict[str, Any] | None:
    try:
        cleaned = content.replace("```json", "").replace("```", "").strip()
        match = re.search(r"\{.*", cleaned, re.DOTALL)
        if not match:
            return None
        json_text = match.group(0).strip()
        if json_text.count('"') % 2 != 0:
            json_text += '"'
        if not json_text.endswith("}"):
            json_text += "}"
        parsed = json.loads(json_text)
        return parsed if isinstance(parsed, dict) else None
    except Exception:
        return None


def _fallback_response(message: str) -> dict[str, Any]:
    return {"type": "NOT_DENTAL", "confidence": 0, "explanation": message}


async def _classify_with_groq(sentence: str) -> dict[str, Any]:
    start_time = time.time()

    if not GROQ_API_KEY:
        return _normalize_local_result(local_classify(sentence))

    detected_language = _detect_language(sentence)
    has_keywords, matched_keyword = _has_dental_keywords(sentence)

    if not has_keywords and detected_language == "english":
        return _not_dental_response(detected_language)

    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json; charset=utf-8",
        "Accept": "application/json",
    }
    url = f"{GROQ_BASE_URL}/chat/completions"

    for model in [GROQ_MODEL, GROQ_FALLBACK_MODEL]:
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
            async with httpx.AsyncClient(timeout=GROQ_TIMEOUT_SECONDS) as client:
                response = await client.post(url, headers=headers, json=payload)
        except httpx.TimeoutException:
            return _normalize_local_result(local_classify(sentence))
        except httpx.HTTPError:
            return _normalize_local_result(local_classify(sentence))

        if response.status_code == 400 and model != GROQ_FALLBACK_MODEL:
            continue
        if response.status_code < 200 or response.status_code >= 300:
            return _normalize_local_result(local_classify(sentence))

        try:
            data = response.json()
        except json.JSONDecodeError:
            return _normalize_local_result(local_classify(sentence))

        try:
            content = data["choices"][0]["message"]["content"]
        except (KeyError, IndexError, TypeError):
            return _normalize_local_result(local_classify(sentence))

        parsed = extract_json(content)
        if not parsed:
            return _normalize_local_result(local_classify(sentence))

        normalized = {
            "type": _normalize_type(parsed.get("type")),
            "confidence": _normalize_confidence(parsed.get("confidence")),
            "explanation": _safe_text(parsed.get("explanation"), "Unable to generate detailed explanation at this time."),
        }
        return normalized

    elapsed = time.time() - start_time
    logger.info("classify fallback elapsed=%.3fs keywords=%s", elapsed, matched_keyword)
    return _normalize_local_result(local_classify(sentence))


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
