from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class UserProfileResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    username: str
    email: str
    selected_language: str
    remember_me: bool
    created_at: datetime


class UserProfileUpdate(BaseModel):
    username: str | None = Field(default=None, min_length=1, max_length=120)
    selected_language: str | None = Field(default=None, max_length=20)
    remember_me: bool | None = None


class LanguageUpdate(BaseModel):
    selected_language: str = Field(max_length=20)
