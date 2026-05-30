# ---- Stage 1: builder ----
FROM python:3.12-alpine AS builder

WORKDIR /build

RUN apk add --no-cache gcc musl-dev

COPY pyproject.toml .

RUN pip install --prefix=/install --no-cache-dir \
    "fastapi==0.115.8" \
    "uvicorn==0.34.0" \
    "sqlalchemy==2.0.37" \
    "psycopg-binary==3.2.4" \
    "psycopg==3.2.4" \
    "pytest>=6.2.5" \
    "pytest-asyncio==0.25.3" \
    "httpx==0.28.1"

# ---- Stage 2: runtime ----
FROM python:3.12-alpine

WORKDIR /app

COPY --from=builder /install /usr/local
COPY src/ ./src/
COPY tests/ ./tests/
COPY pyproject.toml .

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

EXPOSE 8065

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8065"]
