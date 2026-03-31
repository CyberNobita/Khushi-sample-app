# Flodo App - Company Submission Documentation

## 1. Project Summary

This is a full-stack task management application built with:
- Flutter (web + Android app)
- FastAPI backend
- PostgreSQL database (Neon)

The app supports creating, updating, deleting, searching, filtering, and dependency-aware task tracking.

## 2. Live Deployment Links

- Frontend (Web): https://flodo.sbpgm.com
- Backend (API): https://khushi.sbpgm.com
- Backend API Docs (Swagger): https://khushi.sbpgm.com/docs

## 3. Track and Stretch Goal

- Track selected: **Track A (Flutter + FastAPI + PostgreSQL)**
- Stretch goal selected: **Debounced search/autocomplete behavior in task search flow**

## 4. Tech Stack

### Frontend
- Flutter 3.38.x
- Riverpod (state management)
- Go Router (routing/navigation)

### Backend
- FastAPI
- SQLAlchemy (async)
- Pydantic
- Uvicorn

### Database
- Neon PostgreSQL
- Async driver: `asyncpg`

### Deployment
- Vercel (frontend + backend)
- Custom backend domain mapping through Vercel

## 5. What Was Implemented

### UI/UX Implementation
- Professional task board style layout for web and mobile.
- Responsive grid behavior for desktop and mobile.
- Mobile bottom area simplified so only center floating plus button remains.
- Task cards styled to match modern productivity UI patterns.
- Search and status filtering controls implemented.

### Functional Behavior
- Full CRUD task flow integrated with backend APIs.
- Status-based task behavior and blocked task metadata.
- Draft persistence support in task form flow.
- Better state restore behavior when screen switches/back navigation.

### Bug Fixes
- Resolved repeated right overflow issues seen on small widths.
- Reworked mobile filter/action row to avoid horizontal overflow.
- Stabilized backend startup in serverless deployment.

## 6. Database and Backend Design

### Database
- PostgreSQL used in production (Neon).
- App reads `DATABASE_URL` from environment variables.

### API Endpoints
- `GET /` health check
- `GET /api/v1/tasks` list tasks
- `POST /api/v1/tasks` create task
- `GET /api/v1/tasks/{task_id}` get task detail
- `PUT /api/v1/tasks/{task_id}` update task
- `DELETE /api/v1/tasks/{task_id}` delete task

### Important Backend Deployment Fix
- Neon connection string with `sslmode`/`channel_binding` needed normalization for `asyncpg`.
- URL normalization was added in backend code to make production connection work on Vercel.

## 7. Deployment Process Followed

## Backend (Vercel)
1. Added serverless entry point:
   - `api/index.py`
   - `vercel.json` route config
2. Linked backend project to Vercel.
3. Configured production environment variables:
   - `DATABASE_URL`
   - `CORS_ORIGINS`
4. Deployed production backend and mapped custom domain.
5. Verified with live endpoint checks:
   - `GET /` returns status JSON
   - `GET /api/v1/tasks` returns valid response

## Frontend (Vercel)
1. Set production API base in Flutter app:
   - `https://khushi.sbpgm.com/api/v1`
2. Built Flutter web:
   - `flutter build web --release`
3. Deployed `flodo_app/build/web` to Vercel project `flodo-web`.
4. Verified frontend and backend connectivity.

## 8. Local Setup Instructions

## Backend
```powershell
py -m venv .venv
.\.venv\Scripts\python -m pip install -r requirements.txt
Copy-Item .env.example .env
# set DATABASE_URL in .env
.\.venv\Scripts\python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

## Frontend
```powershell
cd flodo_app
flutter pub get
flutter run -d chrome
```

## Android
```powershell
cd flodo_app
flutter run -d <device-id>
```

## 9. Testing and Validation

- Flutter static checks:
  - `flutter analyze` (pass)
- Flutter unit/widget tests:
  - `flutter test` (executed during development iterations)
- API smoke checks:
  - `curl https://khushi.sbpgm.com/`
  - `curl https://khushi.sbpgm.com/api/v1/tasks`
- Manual UI checks:
  - web rendering, responsive layout, mobile behavior, task interactions

## 10. AI Usage Report

AI support was used mainly for:
- Flutter UI implementation and UX polish.
- Responsive layout improvements and overflow debugging.
- Deployment command automation and verification flow.
- Minor documentation structuring.

AI was not used to copy external proprietary code.

## 11. Repository Structure

- `main.py`, `database.py`, `models.py`, `routers/` -> FastAPI backend
- `api/index.py`, `vercel.json` -> Vercel backend entry/routing
- `flodo_app/` -> Flutter application (web + Android)
- `README.md` -> setup summary
- `COMPANY_SUBMISSION_DOC.md` -> this full submission document

## 12. Important Notes

- Keep production secrets in Vercel environment variables only.
- Do not commit private `DATABASE_URL` credentials in public repos.
- If local Android release build fails due low `C:` space, move Gradle cache via:
  - `GRADLE_USER_HOME` to another drive before build.
