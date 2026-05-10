from __future__ import annotations

from datetime import date, timedelta

from sqlalchemy import and_, select
from sqlalchemy.orm import Session

from models.brushing_tracker import BrushingTracker
from models.user import User


def upsert_brushing_record(
    db: Session,
    user: User,
    record_date: date,
    morning_brushed: bool,
    night_brushed: bool,
    streak: int | None = None,
) -> BrushingTracker:
    entry = db.scalar(
        select(BrushingTracker).where(and_(BrushingTracker.user_id == user.id, BrushingTracker.date == record_date))
    )
    if entry is None:
        entry = BrushingTracker(
            user_id=user.id,
            date=record_date,
            morning_brushed=morning_brushed,
            night_brushed=night_brushed,
            streak=streak or 0,
        )
    else:
        entry.morning_brushed = morning_brushed
        entry.night_brushed = night_brushed
        if streak is not None:
            entry.streak = streak

    db.add(entry)
    db.commit()
    db.refresh(entry)
    return entry


def list_brushing_records(db: Session, user: User) -> list[BrushingTracker]:
    stmt = select(BrushingTracker).where(BrushingTracker.user_id == user.id).order_by(BrushingTracker.date.desc())
    return list(db.scalars(stmt).all())


def get_latest_streak(db: Session, user: User) -> int:
    records = list_brushing_records(db, user)
    if not records:
        return 0
    latest = records[0]
    return latest.streak
