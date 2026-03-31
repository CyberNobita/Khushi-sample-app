# Khushi Sample App (Flutter + FastAPI)

Production-ready task management app with:
- Flutter frontend (`flodo_app`)
- FastAPI backend (`/` root)
- PostgreSQL (Neon) database support

## Live Deployments

- Frontend (Vercel): https://flodo-web.vercel.app
- Backend (Vercel): https://khushi.sbpgm.com
- Backend Docs: https://khushi.sbpgm.com/docs

## Track & Stretch Goal

- **Track Chosen:** **A** (Full-Stack: Flutter + FastAPI + PostgreSQL)
- **Stretch Goal Chosen:** **Debounced Autocomplete Search** (implemented in task search flow)

## Step-by-Step Setup Instructions

### 1. Backend Setup (FastAPI)

```powershell
py -m venv .venv
.\.venv\Scripts\python -m pip install -r requirements.txt
Copy-Item .env.example .env
# Set DATABASE_URL in .env
.\.venv\Scripts\python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Open: `http://localhost:8000/docs`

### 2. Flutter App Setup

```powershell
cd flodo_app
flutter pub get
flutter run -d chrome
```

Default production API in app config: `https://khushi.sbpgm.com/api/v1`

For Android:

```powershell
flutter run -d <device-id>
```

### 3. Testing

Backend:

```powershell
.\.venv\Scripts\python -m pytest -q
```

Flutter:

```powershell
cd flodo_app
flutter analyze
flutter test
```

## AI Usage Report

AI was used mainly for:
- Flutter UI implementation and responsive UX refinements (grid, mobile FAB placement, overflow fixes).
- UX polish decisions for task cards, search/filter layout, and mobile behavior.
- Minor automation help for deployment commands and environment wiring.

No external proprietary code was copied; all app logic and integration were implemented and validated in this repository.
