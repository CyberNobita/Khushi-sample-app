from datetime import date, datetime
from typing import Optional

from sqlalchemy import CheckConstraint, Date, DateTime, ForeignKey, Index, Integer, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database import Base


class Task(Base):
    __tablename__ = "tasks"
    __table_args__ = (
        CheckConstraint(
            "status IN ('todo', 'in_progress', 'done')",
            name="ck_tasks_status",
        ),
        Index("idx_tasks_status", "status"),
        Index("idx_tasks_blocked_by", "blocked_by_id"),
    )

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    due_date: Mapped[date] = mapped_column(Date, nullable=False)
    status: Mapped[str] = mapped_column(String(20), nullable=False, default="todo")
    blocked_by_id: Mapped[Optional[str]] = mapped_column(
        String(64),
        ForeignKey("tasks.id", ondelete="SET NULL"),
        nullable=True,
    )
    sort_order: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )

    blocker: Mapped[Optional["Task"]] = relationship(
        "Task",
        remote_side="Task.id",
        foreign_keys=[blocked_by_id],
        lazy="selectin",
    )
