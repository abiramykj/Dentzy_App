from __future__ import annotations

from datetime import datetime, timedelta, timezone

from fastapi import HTTPException, status
from sqlalchemy import and_, delete, select
from sqlalchemy.orm import Session

from auth.otp import generate_otp, send_otp_email
from auth.security import create_access_token, hash_password, revoke_token, verify_password
from models.otp_verification import OTPVerification
from models.user import User
from schemas.auth import LoginRequest, ResetPasswordRequest, SignupRequest
from services.user_service import get_user_by_email


def _normalize_email(email: str) -> str:
    return (email or "").strip().lower()


def _clean_otp_value(otp: str) -> str:
    return (otp or "").strip()


def create_user(db: Session, payload: SignupRequest) -> dict[str, object]:
    email = _normalize_email(str(payload.email))
    if get_user_by_email(db, email) is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail={"success": False, "error_code": "duplicate_email", "message": "An account with this email already exists."},
        )

    user = User(
        username=payload.username.strip(),
        email=email,
        hashed_password=hash_password(payload.password),
        selected_language=payload.selected_language.strip() or "en",
        remember_me=payload.remember_me,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    token = create_access_token(subject=user.email, user_id=user.id)
    return {
        "success": True,
        "message": "Account created successfully.",
        "access_token": token,
        "token_type": "bearer",
        "requires_language_selection": not bool(user.selected_language),
        "user": user,
    }


def authenticate_user(db: Session, payload: LoginRequest) -> dict[str, object]:
    email = _normalize_email(str(payload.email))
    user = get_user_by_email(db, email)
    if user is None or not verify_password(payload.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"success": False, "error_code": "invalid_login", "message": "Invalid email or password."},
        )

    user.remember_me = payload.remember_me
    db.add(user)
    db.commit()
    db.refresh(user)

    token = create_access_token(subject=user.email, user_id=user.id)
    return {
        "success": True,
        "message": "Signed in successfully.",
        "access_token": token,
        "token_type": "bearer",
        "requires_language_selection": not bool(user.selected_language),
        "user": user,
    }


def send_password_reset_otp(db: Session, email: str) -> dict[str, object]:
    normalized_email = _normalize_email(email)
    user = get_user_by_email(db, normalized_email)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"success": False, "error_code": "no_account", "message": "No account found for this email."},
        )

    otp_value = generate_otp()
    expiry_time = datetime.now(timezone.utc) + timedelta(minutes=5)

    db.execute(delete(OTPVerification).where(OTPVerification.email == normalized_email))
    db.add(OTPVerification(email=normalized_email, otp=otp_value, expiry_time=expiry_time))
    db.commit()

    send_otp_email(normalized_email, otp_value, ttl_minutes=5)
    return {"success": True, "message": "Verification code sent.", "expires_in_seconds": 300}


def verify_password_reset_otp(db: Session, email: str, otp: str) -> dict[str, object]:
    normalized_email = _normalize_email(email)
    otp_value = _clean_otp_value(otp)

    entry = db.scalar(
        select(OTPVerification)
        .where(and_(OTPVerification.email == normalized_email, OTPVerification.otp == otp_value))
        .order_by(OTPVerification.expiry_time.desc())
    )

    if entry is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"success": False, "error_code": "invalid_otp", "message": "Invalid verification code."},
        )

    if entry.expiry_time <= datetime.now(timezone.utc):
        db.delete(entry)
        db.commit()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"success": False, "error_code": "otp_expired", "message": "Verification code expired. Please resend."},
        )

    return {"success": True, "message": "OTP verified successfully."}


def reset_password(db: Session, payload: ResetPasswordRequest) -> dict[str, object]:
    normalized_email = _normalize_email(str(payload.email))
    otp_value = _clean_otp_value(payload.otp)
    entry = db.scalar(
        select(OTPVerification)
        .where(and_(OTPVerification.email == normalized_email, OTPVerification.otp == otp_value))
        .order_by(OTPVerification.expiry_time.desc())
    )

    if entry is None or entry.expiry_time <= datetime.now(timezone.utc):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"success": False, "error_code": "otp_invalid", "message": "Verification code is invalid or expired."},
        )

    user = get_user_by_email(db, normalized_email)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"success": False, "error_code": "no_account", "message": "No account found for this email."},
        )

    user.hashed_password = hash_password(payload.new_password)
    db.delete(entry)
    db.add(user)
    db.commit()
    return {"success": True, "message": "Password reset successfully."}


def logout_user(db: Session, token: str) -> dict[str, object]:
    revoke_token(db, token)
    return {"success": True, "message": "Logged out successfully."}
