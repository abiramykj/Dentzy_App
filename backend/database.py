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
    from models.brushing_tracker import BrushingTracker  # noqa: F401
    from models.myth_history import MythHistory  # noqa: F401
    from models.notification import Notification  # noqa: F401
    from models.otp_verification import OTPVerification  # noqa: F401
    from models.token_blacklist import TokenBlacklist  # noqa: F401
    from models.user import User  # noqa: F401

    try:
        Base.metadata.create_all(bind=engine)
    except OperationalError as exc:
        if not _url.drivername.startswith("sqlite"):
            _switch_to_sqlite_fallback(exc)
            Base.metadata.create_all(bind=engine)
        else:
            raise
