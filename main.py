import os
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from database import init_db
from routers.tasks import router as tasks_router

@asynccontextmanager
async def lifespan(_: FastAPI):
    await init_db()
    yield

app = FastAPI(title="Flodo Task API", version="1.0.0", lifespan=lifespan)

origins = os.getenv("CORS_ORIGINS", "*")
allow_origins = ["*"] if origins.strip() == "*" else [o.strip() for o in origins.split(",") if o.strip()]
app.add_middleware(
    CORSMiddleware,
    allow_origins=allow_origins,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def healthcheck() -> dict[str, str]:
    return {"status": "ok", "service": "flodo-task-api"}


app.include_router(tasks_router)
