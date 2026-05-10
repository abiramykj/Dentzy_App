from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from auth.security import get_current_user
from database import get_db
from schemas.myth import MythHistoryCreate, MythHistoryResponse
from services.myth_history_service import create_history_entry, delete_history_entry, list_history

router = APIRouter(prefix="/api/myths", tags=["myths"])


@router.get("/history", response_model=list[MythHistoryResponse])
def get_history(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return list_history(db, current_user)


@router.post("/history", response_model=MythHistoryResponse)
def add_history(payload: MythHistoryCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return create_history_entry(
        db,
        current_user,
        statement=payload.statement,
        result_type=payload.result_type,
        confidence=payload.confidence,
        explanation=payload.explanation,
    )


@router.delete("/history/{history_id}")
def remove_history(history_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    if not delete_history_entry(db, current_user, history_id):
        raise HTTPException(status_code=404, detail={"success": False, "error_code": "not_found", "message": "History item not found."})
    return {"success": True, "message": "History item deleted successfully."}
