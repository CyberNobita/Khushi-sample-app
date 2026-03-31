# Khushi Sample App Backend (Production Ready)

FastAPI backend for Flodo task management app.

## Features

- Async FastAPI API (`/api/v1/tasks`)
- PostgreSQL ready (Neon/Supabase style URL)
- SQLite fallback for local development
- Task dependency (`blocked_by_id`) with computed `is_blocked`
- Auto schema create at startup
- Pytest coverage for core CRUD/blocked flows

## Local Setup

```powershell
py -m venv .venv
.\.venv\Scripts\python -m pip install -r requirements.txt
Copy-Item .env.example .env
.\.venv\Scripts\python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Open docs at: `http://localhost:8000/docs`

## Production Environment Variables

- `DATABASE_URL`
- `CORS_ORIGINS` (e.g. `https://your-web-app.vercel.app,https://your-web-app.web.app`)
- `SQL_ECHO=false`

## Deploy on Render

1. Push this repo to GitHub.
2. In Render, create a new Blueprint deploy from this repo.
3. Render will pick `render.yaml` automatically.
4. Add `DATABASE_URL` in Render env vars.
5. Deploy.

## Test

```powershell
.\.venv\Scripts\python -m pytest -q
```
