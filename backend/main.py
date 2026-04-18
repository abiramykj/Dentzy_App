from fastapi import FastAPI
from pydantic import BaseModel
from google import genai
from dotenv import load_dotenv
import os
import json
import re

from model import classify as classify_local

load_dotenv()

_api_key = os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY")
client = genai.Client(api_key=_api_key) if _api_key else None

_HIGH_CONFIDENCE_THRESHOLD = 0.5

app = FastAPI()


class InputText(BaseModel):
    text: str


def _fallback_response() -> dict:
    return {
        "type": "not_dental",
        "explanation": "Unable to process the statement.",
        "tip": "",
        "confidence": 0
    }


def is_tamil(text: str) -> bool:
    if not text:
        return False
    return any("\u0B80" <= ch <= "\u0BFF" for ch in text)


def _extract_json(text: str) -> str | None:
    if not text:
        return None
    cleaned = text.strip()
    cleaned = re.sub(r"^```(?:json)?\s*|\s*```$", "", cleaned, flags=re.I | re.S).strip()
    cleaned = re.sub(r"^json\s+and\s+", "", cleaned, flags=re.I).strip()
    cleaned = re.sub(r"^json\s*", "", cleaned, flags=re.I).strip()
    match = re.search(r"\{.*\}", cleaned, flags=re.S)
    return match.group(0) if match else None


def _safe_load_json(text: str) -> dict | None:
    try:
        data = json.loads(text)
    except (TypeError, json.JSONDecodeError):
        return None
    return data if isinstance(data, dict) else None


def _normalize_response(data: dict | None) -> dict:
    if not isinstance(data, dict):
        return _fallback_response()

    t = str(data.get("type", "")).lower().strip().replace(" ", "_")
    if t not in {"fact", "myth", "not_dental"}:
        return _fallback_response()

    explanation = str(data.get("explanation", "")).strip() or "Unable to process the statement."
    tip = str(data.get("tip", "")).strip()

    try:
        confidence = float(data.get("confidence", 0))
    except (TypeError, ValueError):
        confidence = 0

    confidence = max(0, min(1, confidence))

    return {
        "type": t,
        "explanation": explanation,
        "tip": tip,
        "confidence": confidence
    }


def _is_high_confidence(result: dict) -> bool:
    try:
        return float(result.get("confidence", 0)) > _HIGH_CONFIDENCE_THRESHOLD
    except (TypeError, ValueError):
        return False


def call_gemini(sentence: str) -> dict:
    if not client:
        return _fallback_response()

    prompt = f"""
You are a dental health assistant.

The input sentence may be in English or Tamil.

IMPORTANT:

* If input is Tamil -> respond ONLY in Tamil
* If input is English -> respond in English

Classify into:

* fact
* myth
* not_dental

Also provide:

* explanation
* tip
* confidence (0 to 1)

Return ONLY JSON:

{{
"type": "",
"explanation": "",
"tip": "",
"confidence": 0.0
}}

Sentence: "{sentence}"
""".strip()

    try:
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=prompt
        )
        raw = getattr(response, "text", "") or ""
        json_str = _extract_json(raw)
        if not json_str:
            return _fallback_response()
        data = _safe_load_json(json_str)
        return _normalize_response(data)
    except Exception:
        return _fallback_response()


@app.post("/classify")
def classify(payload: InputText):
    sentence = (payload.text or "").strip()
    if not sentence:
        return _fallback_response()

    if is_tamil(sentence):
        return call_gemini(sentence)

    try:
        local_raw = classify_local(sentence)
    except Exception:
        local_raw = None

    local_result = local_raw if isinstance(local_raw, dict) else None
    if local_result:
        local_result = _normalize_response(local_result)

    if local_result and local_result.get("type") != "not_dental" and _is_high_confidence(local_result):
        return local_result

    return call_gemini(sentence)