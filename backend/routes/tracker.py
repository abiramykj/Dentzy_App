from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from auth.security import get_current_user
from database import get_db
from schemas.tracker import TrackerStatsResponse
from services.learning_progress_service import get_tracker_stats, mark_article_completed, mark_video_watched

router = APIRouter(prefix="/api/tracker", tags=["tracker"])


@router.get("/stats", response_model=TrackerStatsResponse)
def read_tracker_stats(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return get_tracker_stats(db, current_user)


@router.post("/articles/{article_id}/complete")
def complete_article(article_id: str, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    mark_article_completed(db, current_user, article_id)
    return {"success": True}


@router.post("/videos/{video_id}/watch")
def watch_video(video_id: str, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    mark_video_watched(db, current_user, video_id)
    return {"success": True}