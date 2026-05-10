from __future__ import annotations

from datetime import date

from sqlalchemy import Boolean, Date, ForeignKey, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database import Base


class BrushingTracker(Base):
    __tablename__ = "brushing_tracker"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)
    date: Mapped[date] = mapped_column(Date, index=True, nullable=False)
    morning_brushed: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    night_brushed: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    streak: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    user = relationship("User", back_populates="brushing_records")
