from __future__ import annotations

import logging
from typing import Any

from sqlalchemy import and_, func, or_, select
from sqlalchemy.orm import Session

from models.admin import LearningArticle, LearningVideo
from models.brushing_tracker import BrushingTracker
from models.learning_progress import ArticleProgress, VideoProgress
from models.myth_history import MythHistory
from models.user import User
from services.brushing_service import get_latest_streak

logger = logging.getLogger("dentzy.tracker")


def mark_article_completed(db: Session, user: User, article_id: str) -> ArticleProgress:
    normalized_id = str(article_id).strip()
    entry = db.scalar(
        select(ArticleProgress).where(
            and_(ArticleProgress.user_id == user.id, ArticleProgress.article_id == normalized_id),
        )
    )
    if entry is None:
        entry = ArticleProgress(user_id=user.id, article_id=normalized_id)
        db.add(entry)
        db.commit()
        db.refresh(entry)
    return entry


def mark_video_watched(db: Session, user: User, video_id: str) -> VideoProgress:
    normalized_id = str(video_id).strip()
    entry = db.scalar(
        select(VideoProgress).where(
            and_(VideoProgress.user_id == user.id, VideoProgress.video_id == normalized_id),
        )
    )
    if entry is None:
        entry = VideoProgress(user_id=user.id, video_id=normalized_id)
        db.add(entry)
        db.commit()
        db.refresh(entry)
    return entry


def _count_user_progress(db: Session, model: type[Any], user_id: int) -> int:
    return int(db.scalar(select(func.count()).select_from(model).where(model.user_id == user_id)) or 0)


def get_tracker_stats(db: Session, user: User) -> dict[str, int]:
    total_articles = int(
        db.scalar(
            select(func.count()).select_from(LearningArticle)
        )
        or 0
    )
    total_videos = int(
        db.scalar(
            select(func.count()).select_from(LearningVideo)
        )
        or 0
    )

    completed_articles = _count_user_progress(db, ArticleProgress, user.id)
    watched_videos = _count_user_progress(db, VideoProgress, user.id)
    myths_checked = _count_user_progress(db, MythHistory, user.id)
    brushing_sessions = int(
        db.scalar(
            select(func.count()).select_from(BrushingTracker).where(
                and_(
                    BrushingTracker.user_id == user.id,
                    or_(BrushingTracker.morning_brushed.is_(True), BrushingTracker.night_brushed.is_(True)),
                )
            )
        )
        or 0
    )

    article_percentage = min(100, int((completed_articles / total_articles) * 100)) if total_articles else 0
    video_percentage = min(100, int((watched_videos / total_videos) * 100)) if total_videos else 0

    logger.info(
        "Tracker Stats -> articles=%s/%s, videos=%s/%s",
        completed_articles,
        total_articles,
        watched_videos,
        total_videos,
    )

    return {
        "completed_articles": completed_articles,
        "total_articles": total_articles,
        "article_percentage": article_percentage,
        "watched_videos": watched_videos,
        "total_videos": total_videos,
        "video_percentage": video_percentage,
        "myths_checked": myths_checked,
        "brushing_sessions": brushing_sessions,
        "current_streak": get_latest_streak(db, user),
    }