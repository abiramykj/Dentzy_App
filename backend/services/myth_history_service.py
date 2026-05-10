from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import Session

from models.myth_history import MythHistory
from models.user import User


def create_history_entry(
    db: Session,
    user: User,
    statement: str,
    result_type: str,
    confidence: float,
    explanation: str,
) -> MythHistory:
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
    return entry


def list_history(db: Session, user: User) -> list[MythHistory]:
    stmt = select(MythHistory).where(MythHistory.user_id == user.id).order_by(MythHistory.timestamp.desc())
    return list(db.scalars(stmt).all())


def delete_history_entry(db: Session, user: User, history_id: int) -> bool:
    entry = db.get(MythHistory, history_id)
    if entry is None or entry.user_id != user.id:
        return False
    db.delete(entry)
    db.commit()
    return True
