from __future__ import annotations

import logging

from sqlalchemy import select
from sqlalchemy.orm import Session

from models.myth_history import MythHistory
from models.user import User

logger = logging.getLogger("dentzy.myths")


def create_history_entry(
    db: Session,
    user: User,
    statement: str,
    result_type: str,
    confidence: float,
    explanation: str,
) -> MythHistory:
    logger.debug("[SERVICE] Creating myth history entry user_id=%s type=%s confidence=%d", 
                 user.id, result_type, int(confidence))
    entry = MythHistory(
        user_id=user.id,
        statement=statement,
        result_type=result_type,
        confidence=confidence,
        explanation=explanation,
    )
    db.add(entry)
    db.commit()
    db.refresh(entry)
    logger.info("[DATABASE] Insert success - myth history inserted entry_id=%s user_id=%s", entry.id, user.id)
    return entry


def list_history(db: Session, user: User) -> list[MythHistory]:
    logger.debug("[SERVICE] Fetching myth history user_id=%s", user.id)
    stmt = select(MythHistory).where(MythHistory.user_id == user.id).order_by(MythHistory.timestamp.desc())
    records = list(db.scalars(stmt).all())
    logger.info("[DATABASE] Fetch success - retrieved %d records user_id=%s", len(records), user.id)
    return records


def delete_history_entry(db: Session, user: User, history_id: int) -> bool:
    logger.debug("[SERVICE] Deleting myth history entry_id=%s user_id=%s", history_id, user.id)
    entry = db.get(MythHistory, history_id)
    if entry is None or entry.user_id != user.id:
        logger.warning("[SERVICE] Delete failed - entry not found or unauthorized entry_id=%s user_id=%s", history_id, user.id)
        return False
    db.delete(entry)
    db.commit()
    logger.info("[DATABASE] Delete success - entry_id=%s user_id=%s", history_id, user.id)
    return True
