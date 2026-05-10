from __future__ import annotations

import logging

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from auth.security import get_current_user
from database import get_db
from schemas.myth import MythHistoryCreate, MythHistoryResponse
from services.myth_history_service import create_history_entry, delete_history_entry, list_history

logger = logging.getLogger("dentzy.myths")
router = APIRouter(prefix="/api/myths", tags=["myths"])


@router.get("/history", response_model=list[MythHistoryResponse])
def get_history(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    logger.info("[API] GET /api/myths/history user_id=%s", current_user.id)
    records = list_history(db, current_user)
    logger.info("[DATABASE] Fetch success - retrieved %d myth history records", len(records))
    return records


@router.post("/history", response_model=MythHistoryResponse)
def add_history(payload: MythHistoryCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    logger.info("[API] POST /api/myths/history user_id=%s statement_len=%d type=%s", 
                current_user.id, len(payload.statement), payload.result_type)
    entry = create_history_entry(
        db,
        current_user,
        statement=payload.statement,
        result_type=payload.result_type,
        confidence=payload.confidence,
        explanation=payload.explanation,
    )
    logger.info("[DATABASE] Insert success - myth history saved user_id=%s entry_id=%s", current_user.id, entry.id)
    return entry


@router.post("/save-history", response_model=MythHistoryResponse)
def save_history(payload: MythHistoryCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    """Save myth checking result to history (alias for /history)"""
    logger.info("[API] POST /api/myths/save-history user_id=%s statement_len=%d type=%s", 
                current_user.id, len(payload.statement), payload.result_type)
    entry = create_history_entry(
        db,
        current_user,
        statement=payload.statement,
        result_type=payload.result_type,
        confidence=payload.confidence,
        explanation=payload.explanation,
    )
    logger.info("[DATABASE] Insert success - myth history saved user_id=%s entry_id=%s", current_user.id, entry.id)
    return entry


@router.delete("/history/{history_id}")
def remove_history(history_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    logger.info("[API] DELETE /api/myths/history/%d user_id=%s", history_id, current_user.id)
    if not delete_history_entry(db, current_user, history_id):
        logger.warning("[API] DELETE failed - history not found history_id=%d user_id=%s", history_id, current_user.id)
        raise HTTPException(status_code=404, detail={"success": False, "error_code": "not_found", "message": "History item not found."})
    logger.info("[DATABASE] Delete success - history_id=%d", history_id)
    return {"success": True, "message": "History item deleted successfully."}
