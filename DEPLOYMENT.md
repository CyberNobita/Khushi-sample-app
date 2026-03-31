# Flodo Backend Deployment

## Local Run (Neon PostgreSQL)

```powershell
cd backend
.\.venv\Scripts\python -m pip install -r requirements.txt
.\.venv\Scripts\python -m uvicorn main:app --host 0.0.0.0 --port 8000
```

## Production Env Vars

- `DATABASE_URL` = your Neon PostgreSQL URL
- `CORS_ORIGINS` = comma-separated domains, e.g. `https://yourapp.web.app,https://localhost:3000`
- `SQL_ECHO` = `false`

## Render Deployment

- Repo root already includes `render.yaml`
- On Render, create a new Blueprint deploy from this repo
- Set `DATABASE_URL` in service env vars
- Deploy
