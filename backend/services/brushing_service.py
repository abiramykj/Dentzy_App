from __future__ import annotations

import logging
from datetime import date, timedelta

from sqlalchemy import and_, select
from sqlalchemy.orm import Session

from models.brushing_tracker import BrushingTracker
from models.user import User

logger = logging.getLogger("dentzy.brushing")


def upsert_brushing_record(
    db: Session,
    user: User,
    record_date: date,
    morning_brushed: bool,
    night_brushed: bool,
    streak: int | None = None,
) -> BrushingTracker:
    logger.debug("[SERVICE] Upserting brushing record user_id=%s date=%s morning=%s night=%s streak=%s",
                 user.id, record_date, morning_brushed, night_brushed, streak)
    entry = db.scalar(
        select(BrushingTracker).where(and_(BrushingTracker.user_id == user.id, BrushingTracker.date == record_date))
    )
    if entry is None:
        logger.debug("[SERVICE] Creating new brushing record user_id=%s date=%s", user.id, record_date)
        entry = BrushingTracker(
            user_id=user.id,
            date=record_date,
            morning_brushed=morning_brushed,
            night_brushed=night_brushed,
            streak=streak or 0,
        )
    else:
        logger.debug("[SERVICE] Updating existing brushing record entry_id=%s user_id=%s date=%s", 
                     entry.id, user.id, record_date)
        entry.morning_brushed = morning_brushed
        entry.night_brushed = night_brushed
        if streak is not None:
            entry.streak = streak

    db.add(entry)
    db.commit()
    db.refresh(entry)
    logger.info("[DATABASE] Insert success - brushing record upserted entry_id=%s user_id=%s date=%s", 
                entry.id, user.id, record_date)
    return entry


def list_brushing_records(db: Session, user: User) -> list[BrushingTracker]:
    logger.debug("[SERVICE] Listing brushing records user_id=%s", user.id)
    stmt = select(BrushingTracker).where(BrushingTracker.user_id == user.id).order_by(BrushingTracker.date.desc())
    records = list(db.scalars(stmt).all())
    logger.info("[DATABASE] Fetch success - retrieved %d brushing records user_id=%s", len(records), user.id)
    return records


def get_latest_streak(db: Session, user: User) -> int:
    logger.debug("[SERVICE] Getting latest streak user_id=%s", user.id)
    records = list_brushing_records(db, user)
    if not records:
        return 0
    latest = records[0]
    logger.debug("[SERVICE] Latest streak=%d user_id=%s", latest.streak, user.id)
    return latest.streak
