from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from auth.admin_security import get_current_admin
from database import get_db
from models.admin import AdminUser, AppSetting, LearningArticle, LearningVideo, QuizQuestion
from schemas.admin import (
    AIProviderSettingsUpdate,
    AdminLoginRequest,
    AdminUserCreate,
    AdminUserResponse,
    AdminUserUpdate,
    AdminMessageResponse,
    AdminTokenResponse,
    AppSettingCreate,
    AppSettingResponse,
    AppSettingUpdate,
    LearningArticleCreate,
    LearningArticleResponse,
    LearningArticleUpdate,
    LearningVideoCreate,
    LearningVideoResponse,
    LearningVideoUpdate,
    QuizQuestionCreate,
    QuizQuestionResponse,
    QuizQuestionUpdate,
)
from services.admin_service import (
    create_admin_user,
    authenticate_admin,
    delete_admin_user,
    create_learning_article,
    create_learning_video,
    create_quiz_question,
    delete_setting,
    get_ai_provider_settings,
    list_admin_users,
    get_setting,
    list_settings,
    list_active_articles_by_language,
    list_active_videos_by_language,
    update_ai_provider_settings,
    update_admin_user,
    update_learning_article,
    update_learning_video,
    update_quiz_question,
    upsert_setting,
)

router = APIRouter(prefix="/admin", tags=["admin"])


def _get_row_or_404(db: Session, model: type[Any], item_id: int, message: str):
    item = db.get(model, item_id)
    if item is None:
        raise HTTPException(status_code=404, detail={"success": False, "error_code": "not_found", "message": message})
    return item


@router.post("/login", response_model=AdminTokenResponse)
def login(payload: AdminLoginRequest, db: Session = Depends(get_db)):
    return authenticate_admin(db, payload)


@router.get("/users", response_model=list[AdminUserResponse])
def list_users(db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    return list_admin_users(db)


@router.post("/users", response_model=AdminUserResponse)
def create_user(payload: AdminUserCreate, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    return create_admin_user(db, payload)


@router.get("/users/{admin_user_id}", response_model=AdminUserResponse)
def get_user(admin_user_id: int, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    return _get_row_or_404(db, AdminUser, admin_user_id, "Admin user not found.")


@router.put("/users/{admin_user_id}", response_model=AdminUserResponse)
def edit_user(admin_user_id: int, payload: AdminUserUpdate, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    admin_user = _get_row_or_404(db, AdminUser, admin_user_id, "Admin user not found.")
    return update_admin_user(db, admin_user, payload)


@router.delete("/users/{admin_user_id}", response_model=AdminMessageResponse)
def delete_user(admin_user_id: int, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    admin_user = _get_row_or_404(db, AdminUser, admin_user_id, "Admin user not found.")
    delete_admin_user(db, admin_user)
    return {"success": True, "message": "Admin user deleted successfully."}


@router.get("/questions", response_model=list[QuizQuestionResponse])
def list_questions(db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    return list(db.query(QuizQuestion).order_by(QuizQuestion.created_at.desc()).all())


@router.post("/questions", response_model=QuizQuestionResponse)
def create_question(payload: QuizQuestionCreate, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    return create_quiz_question(db, payload)


@router.get("/questions/{question_id}", response_model=QuizQuestionResponse)
def get_question(question_id: int, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    return _get_row_or_404(db, QuizQuestion, question_id, "Quiz question not found.")


@router.put("/questions/{question_id}", response_model=QuizQuestionResponse)
def edit_question(question_id: int, payload: QuizQuestionUpdate, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    question = _get_row_or_404(db, QuizQuestion, question_id, "Quiz question not found.")
    return update_quiz_question(db, question, payload)


@router.delete("/questions/{question_id}", response_model=AdminMessageResponse)
def delete_question(question_id: int, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    question = _get_row_or_404(db, QuizQuestion, question_id, "Quiz question not found.")
    db.delete(question)
    db.commit()
    return {"success": True, "message": "Quiz question deleted successfully."}


@router.get("/videos", response_model=list[LearningVideoResponse])
def list_videos(db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    return list(db.query(LearningVideo).order_by(LearningVideo.created_at.desc()).all())


@router.post("/videos", response_model=LearningVideoResponse)
def create_video(payload: LearningVideoCreate, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    return create_learning_video(db, payload)


@router.get("/videos/{video_id}", response_model=LearningVideoResponse)
def get_video(video_id: int, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    return _get_row_or_404(db, LearningVideo, video_id, "Learning video not found.")


@router.put("/videos/{video_id}", response_model=LearningVideoResponse)
def edit_video(video_id: int, payload: LearningVideoUpdate, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    video = _get_row_or_404(db, LearningVideo, video_id, "Learning video not found.")
    return update_learning_video(db, video, payload)


@router.delete("/videos/{video_id}", response_model=AdminMessageResponse)
def delete_video(video_id: int, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    video = _get_row_or_404(db, LearningVideo, video_id, "Learning video not found.")
    db.delete(video)
    db.commit()
    return {"success": True, "message": "Learning video deleted successfully."}


@router.get("/articles", response_model=list[LearningArticleResponse])
def list_articles(db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    return list(db.query(LearningArticle).order_by(LearningArticle.created_at.desc()).all())


@router.post("/articles", response_model=LearningArticleResponse)
def create_article(payload: LearningArticleCreate, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    return create_learning_article(db, payload)


@router.get("/articles/{article_id}", response_model=LearningArticleResponse)
def get_article(article_id: int, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    return _get_row_or_404(db, LearningArticle, article_id, "Learning article not found.")


@router.put("/articles/{article_id}", response_model=LearningArticleResponse)
def edit_article(article_id: int, payload: LearningArticleUpdate, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    article = _get_row_or_404(db, LearningArticle, article_id, "Learning article not found.")
    return update_learning_article(db, article, payload)


@router.delete("/articles/{article_id}", response_model=AdminMessageResponse)
def delete_article(article_id: int, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    article = _get_row_or_404(db, LearningArticle, article_id, "Learning article not found.")
    db.delete(article)
    db.commit()
    return {"success": True, "message": "Learning article deleted successfully."}


@router.get("/settings", response_model=list[AppSettingResponse])
def list_app_settings(db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    return list_settings(db)


@router.post("/settings", response_model=AppSettingResponse)
def create_app_setting(payload: AppSettingCreate, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    return upsert_setting(db, payload)


@router.get("/settings/ai-provider")
def read_ai_provider_settings(db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    settings = get_ai_provider_settings(db)
    return {
        "success": True,
        "ai_provider": settings.ai_provider,
        "api_key": settings.api_key,
        "model": settings.model,
        "base_url": settings.base_url,
        "timeout_seconds": settings.timeout_seconds,
    }


@router.put("/settings/ai-provider")
def write_ai_provider_settings(payload: AIProviderSettingsUpdate, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    update_ai_provider_settings(db, payload)
    return {"success": True, "message": "AI provider settings updated successfully."}


@router.put("/settings/{setting_key}", response_model=AppSettingResponse)
def edit_app_setting(setting_key: str, payload: AppSettingUpdate, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    return upsert_setting(db, payload, setting_key=setting_key)


@router.delete("/settings/{setting_key}", response_model=AdminMessageResponse)
def remove_app_setting(setting_key: str, db: Session = Depends(get_db), current_admin=Depends(get_current_admin)):
    if not delete_setting(db, setting_key):
        raise HTTPException(status_code=404, detail={"success": False, "error_code": "not_found", "message": "Setting not found."})
    return {"success": True, "message": "Setting deleted successfully."}

