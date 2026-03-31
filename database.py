import os
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit
from typing import AsyncGenerator

from dotenv import load_dotenv
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import declarative_base

load_dotenv()


def _normalize_database_url(url: str) -> str:
    if url.startswith("postgres://") or url.startswith("postgresql://"):
        parsed = urlsplit(url)
        scheme = "postgresql+asyncpg"
        query_pairs = parse_qsl(parsed.query, keep_blank_values=True)

        normalized_pairs = []
        ssl_required = False
        for key, value in query_pairs:
            lowered = key.lower()
            if lowered == "sslmode":
                ssl_required = value.lower() in {"require", "verify-ca", "verify-full"}
                continue
            if lowered == "channel_binding":
                continue
            normalized_pairs.append((key, value))

        has_ssl = any(key.lower() == "ssl" for key, _ in normalized_pairs)
        if ssl_required and not has_ssl:
            normalized_pairs.append(("ssl", "require"))

        return urlunsplit(
            (
                scheme,
                parsed.netloc,
                parsed.path,
                urlencode(normalized_pairs, doseq=True),
                parsed.fragment,
            )
        )
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
