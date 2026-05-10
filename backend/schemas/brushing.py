from __future__ import annotations

from datetime import date

from pydantic import BaseModel, ConfigDict


class BrushingTrackerCreate(BaseModel):
    date: date
    morning_brushed: bool = False
    night_brushed: bool = False
    streak: int = 0


class BrushingTrackerUpdate(BaseModel):
    morning_brushed: bool | None = None
    night_brushed: bool | None = None
    streak: int | None = None


class BrushingTrackerResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    date: date
    morning_brushed: bool
    night_brushed: bool
    streak: int
