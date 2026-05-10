from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class SignupRequest(BaseModel):
    username: str = Field(min_length=1, max_length=120)
    email: str
    password: str = Field(min_length=8, max_length=128)
    selected_language: str = Field(default="en", max_length=20)
    remember_me: bool = False


class LoginRequest(BaseModel):
    email: str
    password: str = Field(min_length=1, max_length=128)
    remember_me: bool = False


class EmailRequest(BaseModel):
    email: str


class VerifyOtpRequest(BaseModel):
    email: str
    otp: str = Field(min_length=4, max_length=12)


class ResetPasswordRequest(BaseModel):
    email: str
    otp: str = Field(min_length=4, max_length=12)
    new_password: str = Field(min_length=8, max_length=128)


class TokenResponse(BaseModel):
    success: bool = True
    message: str
    access_token: str | None = None
    token_type: str | None = None
    requires_language_selection: bool = False
    error_code: str | None = None


class MessageResponse(BaseModel):
    success: bool = True
    message: str
    error_code: str | None = None


class OTPResponse(BaseModel):
    success: bool = True
    message: str
    expires_in_seconds: int | None = None
    error_code: str | None = None
