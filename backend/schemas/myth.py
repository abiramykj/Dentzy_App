from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class MythClassificationRequest(BaseModel):
    text: str = Field(min_length=1)


class MythHistoryCreate(BaseModel):
    statement: str = Field(min_length=1)
    result_type: str = Field(min_length=1, max_length=30)
    confidence: float = Field(ge=0, le=100)
    explanation: str = Field(min_length=1)


class MythHistoryResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    statement: str
    result_type: str
    confidence: float
    explanation: str
    timestamp: datetime
