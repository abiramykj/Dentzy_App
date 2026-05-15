from __future__ import annotations

import asyncio
import logging
import os
from pathlib import Path
from typing import Any

from dotenv import load_dotenv
from fastapi import Depends, FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from auth.security import get_current_user
from database import get_db, init_db
from routes.auth import router as auth_router
from routes.brushing import router as brushing_router
from routes.myths import router as myths_router
from routes.notifications import router as notifications_router
from routes.users import router as users_router
from schemas.auth import EmailRequest, VerifyOtpRequest as ResetOtpRequest
from schemas.myth import MythClassificationRequest
from services.auth_service import send_password_reset_otp, verify_password_reset_otp
from services.myth_classifier_service import _classify_with_groq, _detect_language, _has_dental_keywords, classify_statement
from services.myth_history_service import create_history_entry
from utils.config import BACKEND_CORS_ORIGINS

_THIS_DIR = Path(__file__).resolve().parent
for env_path in (_THIS_DIR / ".env", _THIS_DIR.parent / ".env"):
    if env_path.exists():
        load_dotenv(dotenv_path=env_path, override=False)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("dentzy.app")

app = FastAPI(title="Dentzy Backend", version="2.0.0")

cors_origins = ["*"] if "*" in BACKEND_CORS_ORIGINS else BACKEND_CORS_ORIGINS
app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(users_router)
app.include_router(myths_router)
app.include_router(brushing_router)
app.include_router(notifications_router)


@app.on_event("startup")
async def _startup() -> None:
    logger.info("Starting Dentzy backend")
    await asyncio.to_thread(init_db)


@app.get("/health")
async def health() -> dict[str, Any]:
    return {
        "status": "ok",
        "database_configured": bool(os.getenv("DATABASE_URL", "").strip()),
        "groq_configured": bool(os.getenv("GROQ_API_KEY", "").strip()),
        "email_configured": bool(os.getenv("EMAIL_USER", "").strip() and os.getenv("EMAIL_PASSWORD", "").strip()),
    }


@app.post("/send-otp")
def send_otp(payload: EmailRequest, db: Session = Depends(get_db)):
    return send_password_reset_otp(db, str(payload.email))


@app.post("/verify-otp")
def verify_otp(payload: ResetOtpRequest, db: Session = Depends(get_db)):
    return verify_password_reset_otp(db, str(payload.email), payload.otp)


@app.post("/classify")
async def classify(
    request: Request,
    payload: MythClassificationRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    import traceback
    sentence = (payload.text or "").strip()
    if not sentence:
        return {"type": "NOT_DENTAL", "confidence": 0, "explanation": "Please enter a statement to classify."}

    auth_header = request.headers.get("authorization", "")
    print(f"[CLASSIFY] Authorization header received: {auth_header[:24]}{'...' if len(auth_header) > 24 else ''}")
    print(f"[CLASSIFY] Current user = {current_user.id}")

    result = await asyncio.wait_for(_classify_with_groq(sentence), timeout=18.0)
    
    # Debug logs for history saving
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


__all__ = [
    "app",
    "_detect_language",
    "_has_dental_keywords",
    "_classify_with_groq",
    "classify_statement",
]


if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", "8090"))
    logger.info("Starting uvicorn via __main__ on port %s", port)
    uvicorn.run("app_main:app", host="0.0.0.0", port=port, reload=True, log_level="debug")
