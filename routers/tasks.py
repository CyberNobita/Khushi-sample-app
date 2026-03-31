import asyncio
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException, Query, Response, status
from sqlalchemy import and_, or_, select, update
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from database import get_session
from models import Task
from schemas import TaskCreate, TaskListResponse, TaskResponse, TaskStatus, TaskUpdate

router = APIRouter(prefix="/api/v1/tasks", tags=["tasks"])


def _to_response(task: Task) -> TaskResponse:
    blocker = task.blocker
    is_blocked = blocker is not None and blocker.status != TaskStatus.done.value

    return TaskResponse(
        id=task.id,
        title=task.title,
        description=task.description,
        due_date=task.due_date,
        status=TaskStatus(task.status),
        blocked_by_id=task.blocked_by_id,
        blocked_by_title=blocker.title if blocker else None,
        is_blocked=is_blocked,
        sort_order=task.sort_order,
        created_at=task.created_at,
        updated_at=task.updated_at,
    )


async def _get_task_or_404(session: AsyncSession, task_id: str) -> Task:
    query = select(Task).options(selectinload(Task.blocker)).where(Task.id == task_id)
    result = await session.execute(query)
    task = result.scalar_one_or_none()
    if task is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    return task


async def _validate_blocker(
    session: AsyncSession,
    blocked_by_id: str | None,
    current_task_id: str | None = None,
) -> None:
    if blocked_by_id is None:
        return

    if current_task_id and blocked_by_id == current_task_id:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="A task cannot block itself",
        )

    blocker = await session.get(Task, blocked_by_id)
    if blocker is None:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="blocked_by_id must reference an existing task",
        )


@router.get("", response_model=TaskListResponse)
async def list_tasks(
    search: str | None = Query(default=None),
    status_filter: TaskStatus | None = Query(default=None, alias="status"),
    session: AsyncSession = Depends(get_session),
) -> TaskListResponse:
    query = select(Task).options(selectinload(Task.blocker))

    filters = []
    if status_filter is not None:
        filters.append(Task.status == status_filter.value)

    if search and search.strip():
        like_pattern = f"%{search.strip()}%"
        filters.append(
            or_(
                Task.title.ilike(like_pattern),
                Task.description.ilike(like_pattern),
            )
        )

    if filters:
        query = query.where(and_(*filters))

    query = query.order_by(Task.sort_order.asc(), Task.created_at.desc())

    result = await session.execute(query)
    tasks = result.scalars().all()

    data = [_to_response(task) for task in tasks]
    return TaskListResponse(data=data, total=len(data))


@router.post("", response_model=TaskResponse, status_code=status.HTTP_201_CREATED)
async def create_task(
    payload: TaskCreate,
    session: AsyncSession = Depends(get_session),
) -> TaskResponse:
    await _validate_blocker(session, payload.blocked_by_id)

    task = Task(
        id=str(uuid4()),
        title=payload.title,
        description=payload.description,
        due_date=payload.due_date,
        status=payload.status.value,
        blocked_by_id=payload.blocked_by_id,
        sort_order=payload.sort_order,
    )

    await asyncio.sleep(2)

    session.add(task)
    await session.commit()

    created = await _get_task_or_404(session, task.id)
    return _to_response(created)


@router.get("/{task_id}", response_model=TaskResponse)
async def get_task(
    task_id: str,
    session: AsyncSession = Depends(get_session),
) -> TaskResponse:
    task = await _get_task_or_404(session, task_id)
    return _to_response(task)


@router.put("/{task_id}", response_model=TaskResponse)
async def update_task(
    task_id: str,
    payload: TaskUpdate,
    session: AsyncSession = Depends(get_session),
) -> TaskResponse:
    task = await _get_task_or_404(session, task_id)

    updates = payload.model_dump(exclude_unset=True)
    if not updates:
        return _to_response(task)

    if "blocked_by_id" in updates:
        await _validate_blocker(session, updates["blocked_by_id"], current_task_id=task_id)

    if "status" in updates and updates["status"] is not None:
        updates["status"] = updates["status"].value

    for field_name, value in updates.items():
        setattr(task, field_name, value)

    await asyncio.sleep(2)

    await session.commit()

    updated = await _get_task_or_404(session, task_id)
    return _to_response(updated)


@router.delete("/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_task(
    task_id: str,
    session: AsyncSession = Depends(get_session),
) -> Response:
    task = await _get_task_or_404(session, task_id)

    await session.execute(
        update(Task).where(Task.blocked_by_id == task_id).values(blocked_by_id=None)
    )
    await session.delete(task)
    await session.commit()

    return Response(status_code=status.HTTP_204_NO_CONTENT)
