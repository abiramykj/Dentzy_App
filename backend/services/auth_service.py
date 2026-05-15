from __future__ import annotations

import logging
from datetime import datetime, timedelta, timezone
import traceback

from fastapi import HTTPException, status
from sqlalchemy import and_, delete, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session
import os

from auth.otp import generate_otp, send_otp_email
from auth.security import create_access_token, hash_password, verify_password
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
    """
    Authenticate user with comprehensive logging and error handling.
    """
    try:
        # Step 1: Normalize email
        email = _normalize_email(str(payload.email))
        logger.info("[AUTH] ========== LOGIN REQUEST RECEIVED ==========")
        logger.info("[AUTH] Email: %s", email)
        print(f"[AUTH] ========== LOGIN REQUEST RECEIVED ==========")
        print(f"[AUTH] Email: {email}")
        print(f"[AUTH] Request timestamp: {datetime.utcnow()}")
        
        # Step 2: Query database for user
        logger.info("[AUTH] [STEP 1] Starting MySQL query to find user by email")
        print(f"[AUTH] [STEP 1] Starting MySQL query to find user by email: {email}")
        try:
            user = get_user_by_email(db, email)
            logger.info("[AUTH] [STEP 1] MySQL query completed - user found: %s", user is not None)
            print(f"[AUTH] [STEP 1] MySQL query completed - user found: {user is not None}")
        except Exception as query_err:
            logger.error("[AUTH] [STEP 1] MySQL query FAILED: %s", str(query_err), exc_info=True)
            print(f"[AUTH] [STEP 1] MySQL query FAILED: {str(query_err)}")
            traceback.print_exc()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail={"success": False, "error_code": "database_error", "message": "Database connection failed. Please try again."},
            )
        
        # Step 3: Check if user exists
        if user is None:
            logger.warning("[AUTH] [STEP 2] Login failed - user not found email=%s", email)
            print(f"[AUTH] [STEP 2] Login failed - user not found for email: {email}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={"success": False, "error_code": "invalid_login", "message": "Invalid email or password."},
            )
        
        logger.info("[AUTH] [STEP 2] User found - user_id=%s, email=%s", user.id, user.email)
        print(f"[AUTH] [STEP 2] User found - user_id={user.id}, email={user.email}")
        
        # Step 4: Verify password with detailed logging
        logger.info("[AUTH] [STEP 3] Starting password verification")
        print(f"[AUTH] [STEP 3] Starting bcrypt password verification for user_id={user.id}")
        try:
            # Debug bypass: direct comparison when DEBUG_AUTH_BYPASS=1
            if os.getenv("DEBUG_AUTH_BYPASS") == "1":
                print("[AUTH] [DEBUG] DEBUG_AUTH_BYPASS enabled - using direct comparison for password check")
                password_valid = (payload.password == user.password_hash)
            else:
                password_valid = verify_password(payload.password, user.password_hash)
            logger.info("[AUTH] [STEP 3] Password verification completed - valid=%s", password_valid)
            print(f"[AUTH] [STEP 3] Password verification completed - valid={password_valid}")
        except Exception as pwd_err:
            logger.error("[AUTH] [STEP 3] Password verification FAILED: %s", str(pwd_err), exc_info=True)
            print(f"[AUTH] [STEP 3] Password verification FAILED: {str(pwd_err)}")
            traceback.print_exc()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail={"success": False, "error_code": "auth_error", "message": "Authentication failed. Please try again."},
            )
        
        if not password_valid:
            logger.warning("[AUTH] [STEP 4] Login failed - invalid password email=%s", email)
            print(f"[AUTH] [STEP 4] Login failed - invalid password for email: {email}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={"success": False, "error_code": "invalid_login", "message": "Invalid email or password."},
            )
        
        logger.info("[AUTH] [STEP 4] Password verified successfully")
        print(f"[AUTH] [STEP 4] Password verified successfully")
        
        # Step 5: Update user remember_me flag
        logger.info("[AUTH] [STEP 5] Updating remember_me flag - remember_me=%s", payload.remember_me)
        print(f"[AUTH] [STEP 5] Updating remember_me flag - remember_me={payload.remember_me}")
        user.remember_me = payload.remember_me
        
        # Step 6: Commit database changes
        logger.info("[AUTH] [STEP 6] Committing database changes")
        print(f"[AUTH] [STEP 6] Committing database changes")
        try:
            db.add(user)
            db.commit()
            db.refresh(user)
            logger.info("[AUTH] [STEP 6] Database commit successful - user_id=%s", user.id)
            print(f"[AUTH] [STEP 6] Database commit successful - user_id={user.id}")
        except Exception as commit_err:
            logger.error("[AUTH] [STEP 6] Database commit FAILED: %s", str(commit_err), exc_info=True)
            print(f"[AUTH] [STEP 6] Database commit FAILED: {str(commit_err)}")
            db.rollback()
            traceback.print_exc()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail={"success": False, "error_code": "database_error", "message": "Failed to update user session."},
            )
        
        # Step 7: Generate JWT token (can be disabled with DEBUG_NO_JWT=1)
        logger.info("[AUTH] [STEP 7] Generating JWT access token")
        print(f"[AUTH] [STEP 7] Generating JWT access token for user_id={user.id}")
        try:
            if os.getenv("DEBUG_NO_JWT") == "1":
                print("[AUTH] [DEBUG] DEBUG_NO_JWT enabled - skipping JWT generation")
                token = "debug-token"
            else:
                token = create_access_token(subject=user.email, user_id=user.id)
            logger.info("[AUTH] [STEP 7] JWT token generated successfully")
            print(f"[AUTH] [STEP 7] JWT token generated successfully")
        except Exception as token_err:
            logger.error("[AUTH] [STEP 7] JWT token generation FAILED: %s", str(token_err), exc_info=True)
            print(f"[AUTH] [STEP 7] JWT token generation FAILED: {str(token_err)}")
            traceback.print_exc()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail={"success": False, "error_code": "token_error", "message": "Failed to generate authentication token."},
            )
        
        # Step 8: Return success response
        logger.info("[AUTH] ========== LOGIN SUCCESSFUL ==========")
        logger.info("[AUTH] user_id=%s, email=%s", user.id, user.email)
        print(f"[AUTH] ========== LOGIN SUCCESSFUL ==========")
        print(f"[AUTH] user_id={user.id}, email={user.email}")
        
        response = {
            "success": True,
            "message": "Signed in successfully.",
            "access_token": token,
            "token_type": "bearer",
            "requires_language_selection": not bool(user.selected_language),
            "user": user,
        }
        logger.info("[AUTH] Returning success response to client")
        print(f"[AUTH] Returning success response to client")
        return response
        
    except HTTPException:
        # Re-raise HTTP exceptions as-is
        raise
    except Exception as exc:
        logger.error("[AUTH] ========== LOGIN FAILED WITH UNEXPECTED ERROR ==========", exc_info=True)
        logger.error("[AUTH] Error: %s", str(exc))
        print(f"[AUTH] ========== LOGIN FAILED WITH UNEXPECTED ERROR ==========")
        print(f"[AUTH] Error: {str(exc)}")
        traceback.print_exc()
        
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"success": False, "error_code": "internal_error", "message": "Login failed. Please try again."},
        )


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


def logout_user() -> dict[str, object]:
    return {"success": True, "message": "Logged out successfully."}
