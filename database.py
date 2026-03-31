import os
from typing import AsyncGenerator

from dotenv import load_dotenv
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import declarative_base

load_dotenv()


def _normalize_database_url(url: str) -> str:
    if url.startswith("postgres://"):
        return url.replace("postgres://", "postgresql+asyncpg://", 1)
    if url.startswith("postgresql://"):
        return url.replace("postgresql://", "postgresql+asyncpg://", 1)
    return url


DATABASE_URL = _normalize_database_url(
    os.getenv("DATABASE_URL", "sqlite+aiosqlite:///./flodo.db")
)

engine = create_async_engine(
    DATABASE_URL,
    echo=os.getenv("SQL_ECHO", "false").lower() == "true",
    future=True,
    pool_pre_ping=True,
)
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)

Base = declarative_base()


async def get_session() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        yield session


async def init_db() -> None:
    # Ensure models are imported before metadata create.
    import models  # noqa: F401

    async with engine.begin() as connection:
        await connection.run_sync(Base.metadata.create_all)
