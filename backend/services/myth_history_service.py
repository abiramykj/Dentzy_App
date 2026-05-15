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
    import traceback
    try:
        print(f"[MYTH_HISTORY_SERVICE] ========== CREATE HISTORY ENTRY ==========")
        print(f"[MYTH_HISTORY_SERVICE] user_id={user.id}, type={result_type}, confidence={confidence}")
        logger.debug("[SERVICE] Creating myth history entry user_id=%s type=%s confidence=%d", 
                     user.id, result_type, int(confidence))
        
        entry = MythHistory(
            user_id=user.id,
            statement=statement,
            result_type=result_type,
            confidence=confidence,
            explanation=explanation,
        )
        print(f"[MYTH_HISTORY_SERVICE] Created MythHistory object: {entry}")
        
        db.add(entry)
        print(f"[MYTH_HISTORY_SERVICE] Added to session")
        
        db.commit()
        print(f"[MYTH_HISTORY_SERVICE] Commit successful")
        
        db.refresh(entry)
        print(f"[MYTH_HISTORY_SERVICE] Refreshed entry - entry_id={entry.id}, timestamp={entry.timestamp}")
        
        logger.info("[DATABASE] Insert success - myth history inserted entry_id=%s user_id=%s", entry.id, user.id)
        print(f"[MYTH_HISTORY_SERVICE] ========== SAVE COMPLETE ==========")
        return entry
    except Exception as e:
        print(f"[MYTH_HISTORY_SERVICE] ========== ERROR DURING CREATE ==========")
        print(f"[MYTH_HISTORY_SERVICE] Exception: {str(e)}")
        print(f"[MYTH_HISTORY_SERVICE] Type: {type(e).__name__}")
        traceback.print_exc()
        logger.error("[SERVICE] Create history failed: %s", str(e), exc_info=True)
        db.rollback()
        print(f"[MYTH_HISTORY_SERVICE] Rollback executed")
        raise


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
