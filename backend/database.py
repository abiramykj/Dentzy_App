from __future__ import annotations

from contextlib import contextmanager
import logging

from sqlalchemy import create_engine
from sqlalchemy.engine import make_url
from sqlalchemy.exc import OperationalError
from sqlalchemy.orm import declarative_base, sessionmaker

from utils.config import DATABASE_URL

logger = logging.getLogger("dentzy.database")

_SQLITE_FALLBACK_URL = "sqlite:///./dentzy.db"

_url = make_url(DATABASE_URL)
_engine_kwargs = {
    "future": True,
    "pool_pre_ping": True,
}

if _url.drivername.startswith("sqlite"):
    _engine_kwargs["connect_args"] = {"check_same_thread": False}
    _engine_kwargs.pop("pool_pre_ping", None)

engine = create_engine(DATABASE_URL, **_engine_kwargs)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)
Base = declarative_base()


def _switch_to_sqlite_fallback(reason: Exception) -> None:
    global engine, SessionLocal
    logger.warning("Falling back to SQLite because the primary database is unavailable: %s", reason)
    engine = create_engine(_SQLITE_FALLBACK_URL, future=True, connect_args={"check_same_thread": False})
    SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@contextmanager
def session_scope():
    db = SessionLocal()
    try:
        yield db
        db.commit()
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


def init_db() -> None:
    from models.admin import AdminUser, AppSetting, LearningArticle, LearningVideo, QuizQuestion  # noqa: F401
    from models.brushing_tracker import BrushingTracker  # noqa: F401
    from models.learning_progress import ArticleProgress, VideoProgress  # noqa: F401
    from models.myth_history import MythHistory  # noqa: F401
    from models.notification import Notification  # noqa: F401
    from models.otp_verification import OTPVerification  # noqa: F401
    from models.user import User  # noqa: F401

    try:
        Base.metadata.create_all(bind=engine)
        _run_password_hash_migration(engine)
    except OperationalError as exc:
        if not _url.drivername.startswith("sqlite"):
            _switch_to_sqlite_fallback(exc)
            Base.metadata.create_all(bind=engine)
            _run_password_hash_migration(engine)
        else:
            raise


def _run_password_hash_migration(engine) -> None:
    """Run a safe startup migration for users.password_hash compatibility."""
    from sqlalchemy import text

    logger.info("[DB MIGRATION] Starting users.password_hash compatibility migration")
    with engine.begin() as conn:
        dialect = engine.dialect.name.lower()

        # Ensure users table exists before attempting migration.
        table_exists = False
        if dialect == "sqlite":
            result = conn.execute(text("SELECT name FROM sqlite_master WHERE type='table' AND name='users'"))
            table_exists = bool(result.all())
        else:
            try:
                result = conn.execute(
                    text(
                        "SELECT column_name FROM information_schema.columns WHERE table_name='users'"
                    )
                )
                table_exists = bool(result.all())
            except Exception:
                try:
                    result = conn.execute(text("SELECT 1 FROM users LIMIT 1"))
                    table_exists = True
                except Exception:
                    table_exists = False

        if not table_exists:
            logger.info("[DB MIGRATION] users table not present yet; skipping password_hash migration")
            return

        has_password_hash = False
        has_hashed_password = False

        if dialect == "sqlite":
            res = conn.execute(text("PRAGMA table_info('users')")).mappings().all()
            cols = [r["name"] for r in res]
            has_password_hash = "password_hash" in cols
            has_hashed_password = "hashed_password" in cols
        else:
            try:
                res = conn.execute(
                    text(
                        "SELECT column_name FROM information_schema.columns WHERE table_name='users'"
                    )
                ).all()
                cols = [r[0] for r in res]
                has_password_hash = "password_hash" in cols
                has_hashed_password = "hashed_password" in cols
            except Exception:
                try:
                    r = conn.execute(text("SELECT * FROM users LIMIT 1"))
                    cols = [c[0] for c in r.cursor.description]
                    has_password_hash = "password_hash" in cols
                    has_hashed_password = "hashed_password" in cols
                except Exception:
                    logger.warning("[DB MIGRATION] Unable to inspect users table schema; aborting migration")
                    return

        if has_password_hash:
            logger.info("[DB MIGRATION] password_hash column already exists; no migration required")
            return

        logger.info("[DB MIGRATION] password_hash missing; adding new column")
        if dialect == "sqlite":
            conn.execute(text("ALTER TABLE users ADD COLUMN password_hash VARCHAR(255) DEFAULT ''"))
        else:
            try:
                conn.execute(text("ALTER TABLE users ADD COLUMN password_hash VARCHAR(255)"))
            except Exception:
                conn.execute(text("ALTER TABLE users ADD COLUMN password_hash VARCHAR(255) DEFAULT ''"))

        logger.info("[DB MIGRATION] Added password_hash column to users table")

        if has_hashed_password:
            logger.info("[DB MIGRATION] Copying legacy hashed_password values into password_hash")
            conn.execute(
                text(
                    "UPDATE users SET password_hash = hashed_password WHERE password_hash IS NULL OR password_hash = ''"
                )
            )
            logger.info("[DB MIGRATION] Data copy from hashed_password completed")

        logger.info("[DB MIGRATION] users.password_hash migration completed")
