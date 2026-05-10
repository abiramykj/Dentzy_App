from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from auth.security import get_current_user
from database import get_db
from schemas.user import LanguageUpdate, UserProfileResponse, UserProfileUpdate
from services.user_service import set_language, update_user_profile

router = APIRouter(prefix="/api/users", tags=["users"])


@router.get("/me", response_model=UserProfileResponse)
def get_profile(current_user=Depends(get_current_user)):
    return current_user


@router.put("/me", response_model=UserProfileResponse)
def update_profile(payload: UserProfileUpdate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return update_user_profile(db, current_user, payload)


@router.put("/language", response_model=UserProfileResponse)
def update_language(payload: LanguageUpdate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return set_language(db, current_user, payload.selected_language)


@router.get("/language", response_model=UserProfileResponse)
def get_language(current_user=Depends(get_current_user)):
    return current_user
