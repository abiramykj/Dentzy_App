from __future__ import annotations

from datetime import time

from pydantic import BaseModel, ConfigDict


class NotificationCreate(BaseModel):
    reminder_time: time
    enabled: bool = True


class NotificationUpdate(BaseModel):
    reminder_time: time | None = None
    enabled: bool | None = None


class NotificationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    reminder_time: time
    enabled: bool
