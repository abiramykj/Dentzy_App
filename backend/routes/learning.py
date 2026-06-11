from __future__ import annotations

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from database import get_db
from schemas.admin import LearningArticleResponse, LearningVideoResponse
from services.admin_service import list_active_articles_by_language, list_active_videos_by_language

router = APIRouter(tags=["learning"])


@router.get(
    "/videos",
    response_model=list[LearningVideoResponse],
    summary="Get public videos",
    description="Return active learning videos for Flutter. If language is omitted, English is returned by default.",
    response_description="List of active videos filtered by language",
)
def get_videos(
    language: str = Query(default="en", description="Language code: en or ta"),
    db: Session = Depends(get_db),
):
    return list_active_videos_by_language(db, language)


@router.get(
    "/articles",
    response_model=list[LearningArticleResponse],
    summary="Get public articles",
    description="Return active learning articles for Flutter. If language is omitted, English is returned by default.",
    response_description="List of active articles filtered by language",
)
def get_articles(
    language: str = Query(default="en", description="Language code: en or ta"),
    db: Session = Depends(get_db),
):
    return list_active_articles_by_language(db, language)