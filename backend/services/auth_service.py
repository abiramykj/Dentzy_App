from __future__ import annotations

import logging
from datetime import datetime, timedelta, timezone
import traceback

from fastapi import HTTPException, status
from sqlalchemy import and_, delete, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from auth.otp import generate_otp, send_otp_email
from auth.security import create_access_token, hash_password, revoke_token, verify_password
from models.otp_verification import OTPVerification
from models.user import User
from schemas.auth import LoginRequest, ResetPasswordRequest, SignupRequest
from services.user_service import get_user_by_email

logger = logging.getLogger("dentzy.auth")


def _normalize_email(email: str) -> str:
    return (email or "").strip().lower()


def _clean_otp_value(otp: str) -> str:
    return (otp or "").strip()


def _utcnow() -> datetime:
    return datetime.utcnow()


def create_user(db: Session, payload: SignupRequest) -> dict[str, object]:
    email = _normalize_email(str(payload.email))
    logger.info("[AUTH] Signup request received email=%s", email)
    print("[AUTH] Signup request received")
    try:
        if get_user_by_email(db, email) is not None:
            logger.warning("[AUTH] Signup failed - duplicate email email=%s", email)
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={"success": False, "error_code": "duplicate_email", "message": "An account with this email already exists."},
            )

        hashed_password = hash_password(payload.password)
        logger.debug("[AUTH] Generated password hash for email=%s", email)
        print(f"[AUTH] Generated password hash: {hashed_password}")

        user = User(
            username=payload.username.strip(),
            email=email,
            password_hash=hashed_password,
            selected_language=payload.selected_language.strip() or "en",
            remember_me=payload.remember_me,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        logger.info("[DATABASE] User inserted into MySQL user_id=%s email=%s", user.id, email)
        print("[DATABASE] User inserted into MySQL")
        print("[AUTH] Signup commit success")

        token = create_access_token(subject=user.email, user_id=user.id)
        return {
            "success": True,
            "message": "Account created successfully.",
            "access_token": token,
            "token_type": "bearer",
            "requires_language_selection": not bool(user.selected_language),
            "user": user,
        }
    except HTTPException:
        db.rollback()
        raise
    except IntegrityError as exc:
        db.rollback()
        print("[AUTH] Signup commit failed: integrity error")
        traceback.print_exc()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"success": False, "error_code": "duplicate_email", "message": "An account with this email already exists."},
        ) from exc
    except Exception as exc:
        db.rollback()
        print("[AUTH] Signup failed with unexpected error")
        traceback.print_exc()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"success": False, "error": "Unable to create account right now. Please try again."},
        ) from exc


def authenticate_user(db: Session, payload: LoginRequest) -> dict[str, object]:
    email = _normalize_email(str(payload.email))
    logger.info("[AUTH] Login request received email=%s", email)
    print("[AUTH] Login request received")
    user = get_user_by_email(db, email)
    if user is None or not verify_password(payload.password, user.password_hash):
        logger.warning("[AUTH] Login failed - invalid credentials email=%s", email)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"success": False, "error_code": "invalid_login", "message": "Invalid email or password."},
        )

    user.remember_me = payload.remember_me
    db.add(user)
    db.commit()
    db.refresh(user)
    logger.info("[DATABASE] User login updated user_id=%s email=%s", user.id, email)
    print("[AUTH] User created successfully")

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
    logger.info("[AUTH] Password reset requested email=%s", normalized_email)
    user = get_user_by_email(db, normalized_email)
    if user is None:
        logger.warning("[AUTH] Password reset failed - no account email=%s", normalized_email)
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"success": False, "error_code": "no_account", "message": "No account found for this email."},
        )

    otp_value = generate_otp()
    expiry_time = _utcnow() + timedelta(minutes=5)

    db.execute(delete(OTPVerification).where(OTPVerification.email == normalized_email))
    db.add(OTPVerification(email=normalized_email, otp=otp_value, expiry_time=expiry_time))
    db.commit()
    logger.info("[DATABASE] OTP record inserted email=%s", normalized_email)

    send_otp_email(normalized_email, otp_value, ttl_minutes=5)
    logger.info("[AUTH] OTP email sent email=%s", normalized_email)
    return {"success": True, "message": "Verification code sent.", "expires_in_seconds": 300}


def verify_password_reset_otp(db: Session, email: str, otp: str) -> dict[str, object]:
    normalized_email = _normalize_email(email)
    otp_value = _clean_otp_value(otp)
    logger.info("[AUTH] OTP verification requested email=%s", normalized_email)

    entry = db.scalar(
        select(OTPVerification)
        .where(and_(OTPVerification.email == normalized_email, OTPVerification.otp == otp_value))
        .order_by(OTPVerification.expiry_time.desc())
    )

    if entry is None:
        logger.warning("[AUTH] OTP verification failed - invalid OTP email=%s", normalized_email)
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"success": False, "error_code": "invalid_otp", "message": "Invalid verification code."},
        )

    if entry.expiry_time <= _utcnow():
        db.delete(entry)
        db.commit()
        logger.warning("[AUTH] OTP verification failed - expired OTP email=%s", normalized_email)
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"success": False, "error_code": "otp_expired", "message": "Verification code expired. Please resend."},
        )

    logger.info("[DATABASE] OTP verified email=%s", normalized_email)
    return {"success": True, "message": "OTP verified successfully."}


def reset_password(db: Session, payload: ResetPasswordRequest) -> dict[str, object]:
    normalized_email = _normalize_email(str(payload.email))
    otp_value = _clean_otp_value(payload.otp)
    entry = db.scalar(
        select(OTPVerification)
        .where(and_(OTPVerification.email == normalized_email, OTPVerification.otp == otp_value))
        .order_by(OTPVerification.expiry_time.desc())
    )

    if entry is None or entry.expiry_time <= _utcnow():
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
