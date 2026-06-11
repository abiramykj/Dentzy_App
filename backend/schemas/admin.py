from __future__ import annotations

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


class AdminLoginRequest(BaseModel):
    email: str
    password: str = Field(min_length=1, max_length=128)


class AdminUserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    username: str
    email: str
    is_active: bool
    role: str
    created_at: datetime
    updated_at: datetime
    last_login_at: datetime | None = None


class AdminTokenResponse(BaseModel):
    success: bool = True
    message: str
    access_token: str | None = None
    token_type: str | None = None
    admin: AdminUserResponse | None = None
    error_code: str | None = None


class AdminUserCreate(BaseModel):
    username: str = Field(min_length=1, max_length=120)
    email: str
    password: str = Field(min_length=8, max_length=128)
    is_active: bool = True
    role: str = Field(default="admin", max_length=50)


class AdminUserUpdate(BaseModel):
    username: str | None = Field(default=None, max_length=120)
    email: str | None = None
    password: str | None = Field(default=None, min_length=8, max_length=128)
    is_active: bool | None = None
    role: str | None = Field(default=None, max_length=50)


class AdminMessageResponse(BaseModel):
    success: bool = True
    message: str
    error_code: str | None = None


class QuizQuestionBase(BaseModel):
    question_en: str = Field(min_length=1)
    question_ta: str = Field(min_length=1)
    option_a_en: str = Field(min_length=1)
    option_a_ta: str = Field(min_length=1)
    option_b_en: str = Field(min_length=1)
    option_b_ta: str = Field(min_length=1)
    option_c_en: str = Field(min_length=1)
    option_c_ta: str = Field(min_length=1)
    option_d_en: str = Field(min_length=1)
    option_d_ta: str = Field(min_length=1)
    correct_option: str = Field(pattern="^[ABCD]$")
    explanation_en: str | None = None
    explanation_ta: str | None = None
    is_active: bool = True


class QuizQuestionCreate(QuizQuestionBase):
    pass


class QuizQuestionUpdate(BaseModel):
    question_en: str | None = None
    question_ta: str | None = None
    option_a_en: str | None = None
    option_a_ta: str | None = None
    option_b_en: str | None = None
    option_b_ta: str | None = None
    option_c_en: str | None = None
    option_c_ta: str | None = None
    option_d_en: str | None = None
    option_d_ta: str | None = None
    correct_option: str | None = Field(default=None, pattern="^[ABCD]$")
    explanation_en: str | None = None
    explanation_ta: str | None = None
    is_active: bool | None = None


class QuizQuestionResponse(QuizQuestionBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime
    updated_at: datetime


class LearningVideoBase(BaseModel):
    title: str = Field(min_length=1)
    description: str | None = None
    video_url: str = Field(min_length=1)
    thumbnail_url: str | None = None
    language: Literal["en", "ta"]
    is_active: bool = True


class LearningVideoCreate(LearningVideoBase):
    pass


class LearningVideoUpdate(BaseModel):
    title: str | None = None
    description: str | None = None
    video_url: str | None = None
    thumbnail_url: str | None = None
    language: Literal["en", "ta"] | None = None
    is_active: bool | None = None


class LearningVideoResponse(LearningVideoBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime
    updated_at: datetime


class LearningArticleBase(BaseModel):
    title: str = Field(min_length=1)
    content: str = Field(min_length=1)
    summary: str | None = None
    language: Literal["en", "ta"]
    is_active: bool = True


class LearningArticleCreate(LearningArticleBase):
    pass


class LearningArticleUpdate(BaseModel):
    title: str | None = None
    content: str | None = None
    summary: str | None = None
    language: Literal["en", "ta"] | None = None
    is_active: bool | None = None


class LearningArticleResponse(LearningArticleBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime
    updated_at: datetime


class LearningVideoPublicResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    description: str | None = None
    video_url: str
    thumbnail_url: str | None = None
    language: Literal["en", "ta"]
    created_at: datetime


class LearningArticlePublicResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    content: str
    summary: str | None = None
    language: Literal["en", "ta"]
    created_at: datetime


class AppSettingBase(BaseModel):
    setting_key: str = Field(min_length=1, max_length=150)
    setting_value: str
    value_type: str = Field(default="string", max_length=30)
    description: str | None = None
    is_secret: bool = False


class AppSettingCreate(AppSettingBase):
    pass


class AppSettingUpdate(BaseModel):
    setting_value: str | None = None
    value_type: str | None = Field(default=None, max_length=30)
    description: str | None = None
    is_secret: bool | None = None


class AppSettingResponse(AppSettingBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime
    updated_at: datetime


class AIProviderSettingsUpdate(BaseModel):
    ai_provider: str = Field(default="groq", max_length=50)
    api_key: str = Field(default="", max_length=4000)
    model: str = Field(default="llama3", max_length=150)
    base_url: str | None = None
    timeout_seconds: float | None = None