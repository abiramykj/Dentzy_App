from fastapi import FastAPI
from pydantic import BaseModel
from google import genai
from dotenv import load_dotenv
import os
import json
import re

load_dotenv()

_api_key = os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY")
client = genai.Client(api_key=_api_key) if _api_key else None

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


def _extract_json(text: str) -> str | None:
    if not text:
        return None
    cleaned = text.strip()
    cleaned = re.sub(r"^```(?:json)?\s*|\s*```$", "", cleaned, flags=re.I | re.S).strip()
    match = re.search(r"\{.*\}", cleaned, flags=re.S)
    return match.group(0) if match else None


def call_gemini(sentence: str) -> dict:
    if not client:
        return _fallback_response()

    prompt = f"""
You are a dental health assistant.

Classify the sentence into:

* fact
* myth
* not_dental

Also provide:

* explanation
* tip
* confidence (0 to 1)

Return ONLY JSON in this format:

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

        data = json.loads(json_str)

        t = str(data.get("type", "")).lower().strip().replace(" ", "_")
        if t not in {"fact", "myth", "not_dental"}:
            t = "not_dental"

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
    except Exception:
        return _fallback_response()


@app.post("/classify")
def classify(payload: InputText):
    sentence = (payload.text or "").strip()
    if not sentence:
        return _fallback_response()
    return call_gemini(sentence)