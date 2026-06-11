from __future__ import annotations

from pydantic import BaseModel, ConfigDict


class TrackerStatsResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    completed_articles: int
    total_articles: int
    article_percentage: int
    watched_videos: int
    total_videos: int
    video_percentage: int
    myths_checked: int
    brushing_sessions: int
    current_streak: int