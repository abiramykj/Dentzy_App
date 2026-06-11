from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from typing import Any

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from auth.admin_security import create_admin_access_token, hash_password, verify_password
from models.admin import AdminUser, AppSetting, LearningArticle, LearningVideo, QuizQuestion
from schemas.admin import (
    AIProviderSettingsUpdate,
    AdminLoginRequest,
    AdminUserCreate,
    AdminUserUpdate,
    AppSettingCreate,
    AppSettingUpdate,
    LearningArticleCreate,
    LearningArticleUpdate,
    LearningVideoCreate,
    LearningVideoUpdate,
    QuizQuestionCreate,
    QuizQuestionUpdate,
)
from utils.config import (
    GROQ_API_KEY as ENV_GROQ_API_KEY,
    GROQ_BASE_URL as ENV_GROQ_BASE_URL,
    GROQ_MODEL as ENV_GROQ_MODEL,
    GROQ_TIMEOUT_SECONDS as ENV_GROQ_TIMEOUT_SECONDS,
)


@dataclass(frozen=True)
class AIProviderSettings:
    ai_provider: str
    api_key: str
    model: str
    base_url: str
    timeout_seconds: float


def _clean_text(value: Any, fallback: str = "") -> str:
    text = str(value or "").strip()
    return text if text else fallback


def _normalize_language(language: Any) -> str:
    normalized = _clean_text(language).lower()
    if normalized not in {"en", "ta"}:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"success": False, "error_code": "invalid_language", "message": "Language must be 'en' or 'ta'."},
        )
    return normalized


def get_admin_by_email(db: Session, email: str) -> AdminUser | None:
    normalized_email = _clean_text(email).lower()
    return db.scalar(select(AdminUser).where(AdminUser.email == normalized_email))


def list_admin_users(db: Session) -> list[AdminUser]:
    return list(db.scalars(select(AdminUser).order_by(AdminUser.created_at.desc())).all())


def create_admin_user(db: Session, payload: AdminUserCreate) -> AdminUser:
    if get_admin_by_email(db, payload.email) is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"success": False, "error_code": "duplicate_email", "message": "An admin account with this email already exists."},
        )

    admin = AdminUser(
        username=payload.username.strip(),
        email=_clean_text(payload.email).lower(),
        password_hash=hash_password(payload.password),
        is_active=payload.is_active,
        role=_clean_text(payload.role, "admin"),
    )
    db.add(admin)
    db.commit()
    db.refresh(admin)
    return admin


def update_admin_user(db: Session, admin: AdminUser, payload: AdminUserUpdate) -> AdminUser:
    if payload.email is not None:
        normalized_email = _clean_text(payload.email).lower()
        existing = get_admin_by_email(db, normalized_email)
        if existing is not None and existing.id != admin.id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={"success": False, "error_code": "duplicate_email", "message": "An admin account with this email already exists."},
            )
        admin.email = normalized_email
    if payload.username is not None:
        admin.username = payload.username.strip()
    if payload.password is not None:
        admin.password_hash = hash_password(payload.password)
    if payload.is_active is not None:
        admin.is_active = payload.is_active
    if payload.role is not None:
        admin.role = _clean_text(payload.role, admin.role)

    db.add(admin)
    db.commit()
    db.refresh(admin)
    return admin


def delete_admin_user(db: Session, admin: AdminUser) -> None:
    db.delete(admin)
    db.commit()


def authenticate_admin(db: Session, payload: AdminLoginRequest) -> dict[str, object]:
    admin = get_admin_by_email(db, payload.email)
    if admin is None or not verify_password(payload.password, admin.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"success": False, "error_code": "invalid_login", "message": "Invalid admin email or password."},
        )
    if not admin.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={"success": False, "error_code": "admin_disabled", "message": "Admin account is disabled."},
        )

    admin.last_login_at = datetime.utcnow()
    db.add(admin)
    db.commit()
    db.refresh(admin)

    return {
        "success": True,
        "message": "Admin signed in successfully.",
        "access_token": create_admin_access_token(subject=admin.email, admin_id=admin.id),
        "token_type": "bearer",
        "admin": admin,
    }


def get_setting(db: Session, setting_key: str) -> AppSetting | None:
    return db.scalar(select(AppSetting).where(AppSetting.setting_key == setting_key))


def list_settings(db: Session) -> list[AppSetting]:
    return list(db.scalars(select(AppSetting).order_by(AppSetting.setting_key.asc())).all())


def upsert_setting(db: Session, payload: AppSettingCreate | AppSettingUpdate, setting_key: str | None = None) -> AppSetting:
    key = _clean_text(setting_key or (payload.setting_key if isinstance(payload, AppSettingCreate) else ""))
    if not key:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"success": False, "error_code": "invalid_setting_key", "message": "Setting key is required."},
        )

    setting = get_setting(db, key)
    if setting is None:
        if isinstance(payload, AppSettingUpdate):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"success": False, "error_code": "setting_not_found", "message": "Setting not found."},
            )
        setting = AppSetting(
            setting_key=key,
            setting_value=_clean_text(payload.setting_value),
            value_type=_clean_text(payload.value_type, "string"),
            description=payload.description.strip() if payload.description else None,
            is_secret=bool(payload.is_secret),
        )
        db.add(setting)
    else:
        if getattr(payload, "setting_value", None) is not None:
            setting.setting_value = _clean_text(payload.setting_value)
        if getattr(payload, "value_type", None) is not None:
            setting.value_type = _clean_text(payload.value_type, setting.value_type)
        if hasattr(payload, "description"):
            setting.description = payload.description.strip() if getattr(payload, "description", None) else None
        if getattr(payload, "is_secret", None) is not None:
            setting.is_secret = bool(payload.is_secret)

    db.commit()
    db.refresh(setting)
    return setting


def delete_setting(db: Session, setting_key: str) -> bool:
    setting = get_setting(db, setting_key)
    if setting is None:
        return False
    db.delete(setting)
    db.commit()
    return True


def get_ai_provider_settings(db: Session | None = None) -> AIProviderSettings:
    defaults = AIProviderSettings(
        ai_provider="groq",
        api_key=ENV_GROQ_API_KEY,
        model=ENV_GROQ_MODEL,
        base_url=ENV_GROQ_BASE_URL,
        timeout_seconds=ENV_GROQ_TIMEOUT_SECONDS,
    )
    if db is None:
        return defaults

    settings_map = {setting.setting_key: setting.setting_value for setting in list_settings(db)}
    timeout_seconds = defaults.timeout_seconds
    raw_timeout = settings_map.get("timeout_seconds") or settings_map.get("timeout")
    if raw_timeout is not None:
        try:
            timeout_seconds = float(raw_timeout)
        except (TypeError, ValueError):
            timeout_seconds = defaults.timeout_seconds

    return AIProviderSettings(
        ai_provider=_clean_text(settings_map.get("ai_provider"), defaults.ai_provider),
        api_key=_clean_text(settings_map.get("api_key"), defaults.api_key),
        model=_clean_text(settings_map.get("model"), defaults.model),
        base_url=_clean_text(settings_map.get("base_url"), defaults.base_url).rstrip("/"),
        timeout_seconds=timeout_seconds,
    )


def update_ai_provider_settings(db: Session, payload: AIProviderSettingsUpdate) -> dict[str, AppSetting]:
    updated: dict[str, AppSetting] = {}
    updated["ai_provider"] = upsert_setting(db, AppSettingCreate(setting_key="ai_provider", setting_value=payload.ai_provider, value_type="string"))
    updated["api_key"] = upsert_setting(db, AppSettingCreate(setting_key="api_key", setting_value=payload.api_key, value_type="secret", is_secret=True))
    updated["model"] = upsert_setting(db, AppSettingCreate(setting_key="model", setting_value=payload.model, value_type="string"))
    if payload.base_url is not None:
        updated["base_url"] = upsert_setting(db, AppSettingCreate(setting_key="base_url", setting_value=payload.base_url, value_type="string"))
    if payload.timeout_seconds is not None:
        updated["timeout_seconds"] = upsert_setting(
            db,
            AppSettingCreate(setting_key="timeout_seconds", setting_value=str(payload.timeout_seconds), value_type="number"),
        )
    return updated


def create_quiz_question(db: Session, payload: QuizQuestionCreate) -> QuizQuestion:
    question = QuizQuestion(**payload.model_dump())
    db.add(question)
    db.commit()
    db.refresh(question)
    return question


def update_quiz_question(db: Session, question: QuizQuestion, payload: QuizQuestionUpdate) -> QuizQuestion:
    for key, value in payload.model_dump(exclude_unset=True).items():
        setattr(question, key, value)
    db.add(question)
    db.commit()
    db.refresh(question)
    return question


def create_learning_video(db: Session, payload: LearningVideoCreate) -> LearningVideo:
    data = payload.model_dump()
    data["language"] = _normalize_language(data["language"])
    video = LearningVideo(**data)
    db.add(video)
    db.commit()
    db.refresh(video)
    return video


def update_learning_video(db: Session, video: LearningVideo, payload: LearningVideoUpdate) -> LearningVideo:
    for key, value in payload.model_dump(exclude_unset=True).items():
        if key == "language" and value is not None:
            value = _normalize_language(value)
        setattr(video, key, value)
    db.add(video)
    db.commit()
    db.refresh(video)
    return video


def create_learning_article(db: Session, payload: LearningArticleCreate) -> LearningArticle:
    data = payload.model_dump()
    data["language"] = _normalize_language(data["language"])
    article = LearningArticle(**data)
    db.add(article)
    db.commit()
    db.refresh(article)
    return article


def update_learning_article(db: Session, article: LearningArticle, payload: LearningArticleUpdate) -> LearningArticle:
    for key, value in payload.model_dump(exclude_unset=True).items():
        if key == "language" and value is not None:
            value = _normalize_language(value)
        setattr(article, key, value)
    db.add(article)
    db.commit()
    db.refresh(article)
    return article


def list_active_videos_by_language(db: Session, language: str) -> list[LearningVideo]:
    normalized_language = _normalize_language(language)
    statement = (
        select(LearningVideo)
        .where(LearningVideo.is_active.is_(True), LearningVideo.language == normalized_language)
        .order_by(LearningVideo.created_at.desc())
    )
    return list(db.scalars(statement).all())


def list_active_articles_by_language(db: Session, language: str) -> list[LearningArticle]:
    normalized_language = _normalize_language(language)
    statement = (
        select(LearningArticle)
        .where(LearningArticle.is_active.is_(True), LearningArticle.language == normalized_language)
        .order_by(LearningArticle.created_at.desc())
    )
    return list(db.scalars(statement).all())