from __future__ import annotations

import logging

from sqlalchemy import select
from sqlalchemy.orm import Session

from models.user import User
from schemas.user import UserProfileUpdate


logger = logging.getLogger("dentzy.user_service")


def get_user_by_email(db: Session, email: str) -> User | None:
    logger.info("[USER_LOOKUP] searching email=%s", email)
    user = db.scalar(select(User).where(User.email == email))
    logger.info("[USER_LOOKUP] completed email=%s found=%s", email, user is not None)
    return user


def get_user_by_id(db: Session, user_id: int) -> User | None:
    return db.get(User, user_id)


def update_user_profile(db: Session, user: User, payload: UserProfileUpdate) -> User:
    if payload.username is not None:
        user.username = payload.username.strip()
    if payload.selected_language is not None:
        user.selected_language = payload.selected_language.strip() or user.selected_language
    if payload.remember_me is not None:
        user.remember_me = payload.remember_me
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def set_language(db: Session, user: User, language_code: str) -> User:
    user.selected_language = language_code.strip() or user.selected_language
    db.add(user)
    db.commit()
    db.refresh(user)
    return user
