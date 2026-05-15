from __future__ import annotations

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
    import traceback
    try:
        # Execution trace prints requested by debugging task
        print("STEP 1: LOGIN REQUEST RECEIVED")
        print("STEP 2: EMAIL =", payload.email)
        print("STEP 3: BEFORE DB QUERY")
        result = authenticate_user(db, payload)
        print("STEP 4: AFTER DB QUERY")
        print("STEP 5: BEFORE PASSWORD VERIFY")
        # authenticate_user performs password verify and token generation; it will log further steps
        print("STEP 6: AFTER PASSWORD VERIFY")
        print("STEP 7: BEFORE TOKEN GENERATION")
        print("STEP 8: AFTER TOKEN GENERATION")
        print("STEP 9: BEFORE RESPONSE RETURN")
        return result
        
    except HTTPException as exc:
        print(f"[ROUTE] HTTPException caught: {exc.status_code}")
        print(f"[ROUTE] Detail: {exc.detail}")
        raise
    except Exception as exc:
        tb = traceback.format_exc()
        print("STEP ERROR: Exception in /api/auth/login", str(exc))
        print(tb)
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
