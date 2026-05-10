from __future__ import annotations

import logging
from datetime import date

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from auth.security import get_current_user
from database import get_db
from schemas.brushing import BrushingTrackerCreate, BrushingTrackerResponse, BrushingTrackerUpdate
from services.brushing_service import list_brushing_records, upsert_brushing_record

logger = logging.getLogger("dentzy.brushing")
router = APIRouter(prefix="/api/brushing", tags=["brushing"])


@router.get("/records", response_model=list[BrushingTrackerResponse])
def get_records(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    logger.info("[API] GET /api/brushing/records user_id=%s", current_user.id)
    records = list_brushing_records(db, current_user)
    logger.info("[DATABASE] Fetch success - retrieved %d brushing records user_id=%s", len(records), current_user.id)
    return records


@router.post("/records", response_model=BrushingTrackerResponse)
def create_record(payload: BrushingTrackerCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    logger.info("[API] POST /api/brushing/records user_id=%s date=%s morning=%s night=%s streak=%s", 
                current_user.id, payload.date, payload.morning_brushed, payload.night_brushed, payload.streak)
    record = upsert_brushing_record(
        db,
        current_user,
        record_date=payload.date,
        morning_brushed=payload.morning_brushed,
        night_brushed=payload.night_brushed,
        streak=payload.streak,
    )
    logger.info("[DATABASE] Insert success - brushing tracker saved user_id=%s date=%s", current_user.id, payload.date)
    logger.info("[API] Brushing tracker saved")
    return record


@router.put("/records/{record_date}", response_model=BrushingTrackerResponse)
def update_record(record_date: date, payload: BrushingTrackerUpdate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    logger.info("[API] PUT /api/brushing/records/%s user_id=%s morning=%s night=%s streak=%s",
                record_date, current_user.id, payload.morning_brushed, payload.night_brushed, payload.streak)
    existing = next((item for item in list_brushing_records(db, current_user) if item.date == record_date), None)
    morning = payload.morning_brushed if payload.morning_brushed is not None else (existing.morning_brushed if existing else False)
    night = payload.night_brushed if payload.night_brushed is not None else (existing.night_brushed if existing else False)
    streak = payload.streak if payload.streak is not None else (existing.streak if existing else 0)
    record = upsert_brushing_record(db, current_user, record_date, morning, night, streak)
    logger.info("[DATABASE] Update success - brushing tracker updated user_id=%s date=%s", current_user.id, record_date)
    logger.info("[API] Brushing tracker saved")
    return record
