from __future__ import annotations

import logging
import traceback

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from database import get_db
from schemas.auth import EmailRequest, LoginRequest, MessageResponse, ResetPasswordRequest, SignupRequest, TokenResponse, VerifyOtpRequest
from services.auth_service import (
    authenticate_user,
    create_user,
    logout_user,
    reset_password,
    send_password_reset_otp,
    verify_password_reset_otp,
)

router = APIRouter(prefix="/api/auth", tags=["auth"])
logger = logging.getLogger("dentzy.auth.route")


@router.post("/signup", response_model=TokenResponse)
def signup(payload: SignupRequest, db: Session = Depends(get_db)):
    try:
        return create_user(db, payload)
    except HTTPException as exc:
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
    except Exception:
        traceback.print_exc()
        return JSONResponse(
            status_code=500,
            content={"success": False, "error": "Unable to create account right now. Please try again."},
        )


@router.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    """
    Login endpoint with comprehensive error handling.
    """
    try:
        logger.info("[LOGIN][ROUTE] request received email=%s remember_me=%s", payload.email, payload.remember_me)
        result = authenticate_user(db, payload)
        logger.info("[LOGIN][ROUTE] authenticate_user completed email=%s", payload.email)
        logger.info("[LOGIN][ROUTE] returning success response email=%s", payload.email)
        return result
        
    except HTTPException as exc:
        logger.warning("[LOGIN][ROUTE] HTTPException status=%s detail=%s", exc.status_code, exc.detail)
        raise
    except Exception as exc:
        tb = traceback.format_exc()
        logger.exception("[LOGIN][ROUTE] unexpected error: %s", exc)
        logger.error(tb)
        return JSONResponse(
            status_code=500,
            content={
                "success": False,
                "message": "Backend error",
                "error": str(exc),
                "traceback": tb,
            },
        )


@router.post("/logout", response_model=MessageResponse)
def logout():
    return logout_user()


@router.post("/forgot-password", response_model=MessageResponse)
def forgot_password(payload: EmailRequest, db: Session = Depends(get_db)):
    return send_password_reset_otp(db, str(payload.email))


@router.post("/send-otp")
def send_otp(payload: EmailRequest, db: Session = Depends(get_db)):
    return send_password_reset_otp(db, str(payload.email))


@router.post("/verify-otp", response_model=MessageResponse)
def verify_otp(payload: VerifyOtpRequest, db: Session = Depends(get_db)):
    return verify_password_reset_otp(db, str(payload.email), payload.otp)


@router.post("/reset-password", response_model=MessageResponse)
def reset_password_route(payload: ResetPasswordRequest, db: Session = Depends(get_db)):
    return reset_password(db, payload)
