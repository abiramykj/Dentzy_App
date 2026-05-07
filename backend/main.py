from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
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
# Add CORS middleware for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Check API key at startup
if not _api_key:
    print("⚠️  WARNING: No Gemini API key found!")
else:
    print(f"✅ Gemini API key loaded")
    if LOCAL_MODEL_AVAILABLE:
        print("✅ Mode: Hybrid (Gemini + Local KB fallback)")
    else:
        print("✅ Using ONLY Gemini API")


class InputText(BaseModel):
    text: str


def build_prompt(sentence: str) -> str:
        return f"""
You are a STRICT dental health classifier.

Your job:
Classify the statement into ONE of:
- FACT
- MYTH
- NOT_DENTAL

IMPORTANT RULES:
- Output ONLY a single valid JSON object (no markdown, no extra text, no explanations, no preamble, no code block)
- NEVER return UNKNOWN
- ALWAYS return all fields
- If unsure, choose the closest category
- Confidence must be between 0.5 and 1.0
- Treat common dental knowledge as HIGH confidence

Output format:
{{
    "type": "FACT or MYTH or NOT_DENTAL",
    "explanation": "Clear simple explanation (1-2 lines)",
    "tip": "Short actionable advice",
    "confidence": 0.50 to 1.00
}}

Examples:

Input: "Brushing teeth twice a day is good"
Output:
{{
    "type": "FACT",
    "explanation": "Brushing twice daily removes plaque and prevents cavities and gum disease.",
    "tip": "Brush morning and before bed using fluoride toothpaste.",
    "confidence": 0.95
}}

Input: "Sugar does not affect teeth"
Output:
{{
    "type": "MYTH",
    "explanation": "Sugar feeds bacteria that produce acids which damage enamel.",
    "tip": "Limit sugary foods and rinse after eating sweets.",
    "confidence": 0.95
}}

Now classify:

Input: "{sentence}"

REMEMBER: Respond ONLY with a single JSON object as shown above. Do NOT include any extra text, markdown, or explanations.
"""


def _fallback_response() -> dict:
    return {
        "type": "Myth",
        "explanation": "Unable to process the statement right now, so please try again.",
        "tip": "Retry the check after a moment.",
        "confidence": 70
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
        print(f"  🔄 Calling Gemini 2.0 Flash (worker)...")
        response = client.models.generate_content(
            model="gemini-2.0-flash",
            contents=prompt,
            timeout=30
        )
        raw_response = getattr(response, "text", "") or ""
        print(f"  ✅ Got raw response ({len(raw_response)} chars)")
        print(f"  📝 Raw start: {raw_response[:200]}...")

        json_str = _extract_json(raw_response)
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