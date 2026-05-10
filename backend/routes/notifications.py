from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from auth.security import get_current_user
from database import get_db
from schemas.notification import NotificationCreate, NotificationResponse, NotificationUpdate
from services.notification_service import get_notification, upsert_notification

router = APIRouter(prefix="/api/notifications", tags=["notifications"])


@router.get("/me", response_model=NotificationResponse | None)
def read_notification(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return get_notification(db, current_user)


@router.post("/me", response_model=NotificationResponse)
def write_notification(payload: NotificationCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return upsert_notification(db, current_user, payload.reminder_time, payload.enabled)


@router.put("/me", response_model=NotificationResponse)
def update_notification(payload: NotificationUpdate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    existing = get_notification(db, current_user)
    reminder_time = payload.reminder_time or (existing.reminder_time if existing else None)
    enabled = payload.enabled if payload.enabled is not None else (existing.enabled if existing else True)
    if reminder_time is None:
        raise HTTPException(
            status_code=400,
            detail={"success": False, "error_code": "invalid_payload", "message": "reminder_time is required."},
        )
    return upsert_notification(db, current_user, reminder_time, enabled)
