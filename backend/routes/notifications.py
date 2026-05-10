from __future__ import annotations

import logging

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from auth.security import get_current_user
from database import get_db
from schemas.notification import NotificationCreate, NotificationResponse, NotificationUpdate
from services.notification_service import get_notification, upsert_notification

logger = logging.getLogger("dentzy.notifications")
router = APIRouter(prefix="/api/notifications", tags=["notifications"])


@router.get("/me", response_model=NotificationResponse | None)
def read_notification(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    logger.info("[API] GET /api/notifications/me user_id=%s", current_user.id)
    notification = get_notification(db, current_user)
    if notification:
        logger.info("[DATABASE] Fetch success - notification found user_id=%s", current_user.id)
    else:
        logger.info("[DATABASE] Fetch - no notification found user_id=%s", current_user.id)
    return notification


@router.post("/me", response_model=NotificationResponse)
def write_notification(payload: NotificationCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    logger.info("[API] POST /api/notifications/me user_id=%s time=%s", current_user.id, payload.reminder_time)
    notification = upsert_notification(db, current_user, payload.reminder_time, payload.enabled)
    logger.info("[DATABASE] Insert success - notification saved user_id=%s", current_user.id)
    return notification


@router.put("/me", response_model=NotificationResponse)
def update_notification(payload: NotificationUpdate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    logger.info("[API] PUT /api/notifications/me user_id=%s", current_user.id)
    existing = get_notification(db, current_user)
    reminder_time = payload.reminder_time or (existing.reminder_time if existing else None)
    enabled = payload.enabled if payload.enabled is not None else (existing.enabled if existing else True)
    if reminder_time is None:
        logger.warning("[API] PUT failed - reminder_time is required user_id=%s", current_user.id)
        raise HTTPException(
            status_code=400,
            detail={"success": False, "error_code": "invalid_payload", "message": "reminder_time is required."},
        )
    notification = upsert_notification(db, current_user, reminder_time, enabled)
    logger.info("[DATABASE] Update success - notification updated user_id=%s", current_user.id)
    return notification
