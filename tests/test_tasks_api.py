import asyncio
import os
from pathlib import Path

from fastapi.testclient import TestClient

os.environ["DATABASE_URL"] = "sqlite+aiosqlite:///./test_flodo.db"

from database import Base, engine
from main import app

TEST_DB_FILE = Path("test_flodo.db")


async def _reset_db() -> None:
    async with engine.begin() as connection:
        await connection.run_sync(Base.metadata.drop_all)
        await connection.run_sync(Base.metadata.create_all)


def setup_function() -> None:
    asyncio.run(_reset_db())


def teardown_module() -> None:
    asyncio.run(engine.dispose())
    if TEST_DB_FILE.exists():
        TEST_DB_FILE.unlink()


def test_create_and_list_task() -> None:
    with TestClient(app) as client:
        create_response = client.post(
            "/api/v1/tasks",
            json={
                "title": "Design dashboard",
                "description": "Wireframe top metrics",
                "due_date": "2026-04-05",
                "status": "in_progress",
            },
        )

        assert create_response.status_code == 201
        created = create_response.json()
        assert created["title"] == "Design dashboard"
        assert created["status"] == "in_progress"

        list_response = client.get("/api/v1/tasks")
        assert list_response.status_code == 200
        payload = list_response.json()
        assert payload["total"] == 1
        assert payload["data"][0]["id"] == created["id"]


def test_blocked_task_computed_state() -> None:
    with TestClient(app) as client:
        blocker = client.post(
            "/api/v1/tasks",
            json={
                "title": "Backend API",
                "description": "",
                "due_date": "2026-04-08",
                "status": "in_progress",
            },
        )
        assert blocker.status_code == 201
        blocker_data = blocker.json()

        dependent = client.post(
            "/api/v1/tasks",
            json={
                "title": "Android integration",
                "description": "",
                "due_date": "2026-04-10",
                "status": "todo",
                "blocked_by_id": blocker_data["id"],
            },
        )
        assert dependent.status_code == 201
        dependent_data = dependent.json()

        assert dependent_data["is_blocked"] is True
        assert dependent_data["blocked_by_title"] == "Backend API"


def test_delete_clears_blocked_by_dependencies() -> None:
    with TestClient(app) as client:
        blocker = client.post(
            "/api/v1/tasks",
            json={
                "title": "Finalize schema",
                "description": "",
                "due_date": "2026-04-11",
                "status": "done",
            },
        ).json()

        dependent = client.post(
            "/api/v1/tasks",
            json={
                "title": "Ship app",
                "description": "",
                "due_date": "2026-04-12",
                "status": "todo",
                "blocked_by_id": blocker["id"],
            },
        ).json()

        delete_response = client.delete(f"/api/v1/tasks/{blocker['id']}")
        assert delete_response.status_code == 204

        dependent_after_delete = client.get(f"/api/v1/tasks/{dependent['id']}")
        assert dependent_after_delete.status_code == 200
        payload = dependent_after_delete.json()
        assert payload["blocked_by_id"] is None
        assert payload["is_blocked"] is False


def test_search_and_filter_at_database_level() -> None:
    with TestClient(app) as client:
        client.post(
            "/api/v1/tasks",
            json={
                "title": "Design login",
                "description": "UI",
                "due_date": "2026-04-01",
                "status": "todo",
            },
        )
        client.post(
            "/api/v1/tasks",
            json={
                "title": "Implement auth",
                "description": "API",
                "due_date": "2026-04-02",
                "status": "done",
            },
        )

        filtered = client.get("/api/v1/tasks", params={"status": "done", "search": "auth"})
        assert filtered.status_code == 200

        payload = filtered.json()
        assert payload["total"] == 1
        assert payload["data"][0]["title"] == "Implement auth"
