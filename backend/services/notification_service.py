from __future__ import annotations

import logging
from datetime import time

from sqlalchemy import select
from sqlalchemy.orm import Session

from models.notification import Notification
from models.user import User

logger = logging.getLogger("dentzy.notifications")


def upsert_notification(db: Session, user: User, reminder_time: time, enabled: bool) -> Notification:
    logger.debug("[SERVICE] Upserting notification user_id=%s time=%s enabled=%s", 
                 user.id, reminder_time, enabled)
    entry = db.scalar(select(Notification).where(Notification.user_id == user.id))
    if entry is None:
        logger.debug("[SERVICE] Creating new notification entry user_id=%s", user.id)
        entry = Notification(user_id=user.id, reminder_time=reminder_time, enabled=enabled)
    else:
        logger.debug("[SERVICE] Updating existing notification entry_id=%s user_id=%s", entry.id, user.id)
        entry.reminder_time = reminder_time
        entry.enabled = enabled
    db.add(entry)
    db.commit()
    db.refresh(entry)
    logger.info("[DATABASE] Insert success - notification upserted entry_id=%s user_id=%s", entry.id, user.id)
    return entry


def get_notification(db: Session, user: User) -> Notification | None:
    logger.debug("[SERVICE] Getting notification user_id=%s", user.id)
    entry = db.scalar(select(Notification).where(Notification.user_id == user.id))
    if entry:
        logger.info("[DATABASE] Fetch success - notification found user_id=%s", user.id)
    else:
        logger.info("[DATABASE] Fetch - no notification found user_id=%s", user.id)
    return entry
