# ----------------------------
# Stage 1: Builder
# ----------------------------
FROM python:3.10-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y build-essential && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml ./
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -e .[test]

COPY . .


# ----------------------------
# Stage 2: Runtime
# ----------------------------
FROM python:3.10-slim

WORKDIR /app

RUN apt-get update && apt-get install -y libpq-dev && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /app/src /app/src

RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

ENV PATH="/home/appuser/.local/bin:${PATH}"

EXPOSE 8064

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8064"]

