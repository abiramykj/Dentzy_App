from __future__ import annotations

from datetime import date

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from auth.security import get_current_user
from database import get_db
from schemas.brushing import BrushingTrackerCreate, BrushingTrackerResponse, BrushingTrackerUpdate
from services.brushing_service import list_brushing_records, upsert_brushing_record

router = APIRouter(prefix="/api/brushing", tags=["brushing"])


@router.get("/records", response_model=list[BrushingTrackerResponse])
def get_records(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return list_brushing_records(db, current_user)


@router.post("/records", response_model=BrushingTrackerResponse)
def create_record(payload: BrushingTrackerCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return upsert_brushing_record(
        db,
        current_user,
        record_date=payload.date,
        morning_brushed=payload.morning_brushed,
        night_brushed=payload.night_brushed,
        streak=payload.streak,
    )


@router.put("/records/{record_date}", response_model=BrushingTrackerResponse)
def update_record(record_date: date, payload: BrushingTrackerUpdate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    existing = next((item for item in list_brushing_records(db, current_user) if item.date == record_date), None)
    morning = payload.morning_brushed if payload.morning_brushed is not None else (existing.morning_brushed if existing else False)
    night = payload.night_brushed if payload.night_brushed is not None else (existing.night_brushed if existing else False)
    streak = payload.streak if payload.streak is not None else (existing.streak if existing else 0)
    return upsert_brushing_record(db, current_user, record_date, morning, night, streak)
