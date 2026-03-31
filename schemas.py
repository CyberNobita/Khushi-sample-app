from datetime import date, datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field, field_validator


class TaskStatus(str, Enum):
    todo = "todo"
    in_progress = "in_progress"
    done = "done"


class TaskCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = None
    due_date: date
    status: TaskStatus = TaskStatus.todo
    blocked_by_id: Optional[str] = None
    sort_order: int = 0

    @field_validator("title")
    @classmethod
    def validate_title(cls, value: str) -> str:
        cleaned = value.strip()
        if not cleaned:
            raise ValueError("Title is required")
        return cleaned


class TaskUpdate(BaseModel):
    title: Optional[str] = Field(default=None, min_length=1, max_length=200)
    description: Optional[str] = None
    due_date: Optional[date] = None
    status: Optional[TaskStatus] = None
    blocked_by_id: Optional[str] = None
    sort_order: Optional[int] = None

    @field_validator("title")
    @classmethod
    def validate_title(cls, value: Optional[str]) -> Optional[str]:
        if value is None:
            return value

        cleaned = value.strip()
        if not cleaned:
            raise ValueError("Title is required")
        return cleaned


class TaskResponse(BaseModel):
    id: str
    title: str
    description: Optional[str]
    due_date: date
    status: TaskStatus
    blocked_by_id: Optional[str]
    blocked_by_title: Optional[str]
    is_blocked: bool
    sort_order: int
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class TaskListResponse(BaseModel):
    data: list[TaskResponse]
    total: int
