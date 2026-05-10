from __future__ import annotations

from datetime import time

from sqlalchemy import select
from sqlalchemy.orm import Session

from models.notification import Notification
from models.user import User


def upsert_notification(db: Session, user: User, reminder_time: time, enabled: bool) -> Notification:
    entry = db.scalar(select(Notification).where(Notification.user_id == user.id))
    if entry is None:
        entry = Notification(user_id=user.id, reminder_time=reminder_time, enabled=enabled)
    else:
        entry.reminder_time = reminder_time
        entry.enabled = enabled
    db.add(entry)
    db.commit()
    db.refresh(entry)
    return entry


def get_notification(db: Session, user: User) -> Notification | None:
    return db.scalar(select(Notification).where(Notification.user_id == user.id))
