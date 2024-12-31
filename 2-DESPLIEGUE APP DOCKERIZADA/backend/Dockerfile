FROM python:3.9-alpine AS builder

RUN apk add --no-cache \
    build-base \
    libpq-dev \
    gcc

WORKDIR /app

COPY requirements.txt .

RUN pip install --upgrade pip

RUN pip install --no-cache-dir -r requirements.txt --target /app/dependencies

COPY . .

FROM python:3.9-alpine

RUN apk add --no-cache \
    libpq \
    netcat-openbsd

WORKDIR /app

COPY --from=builder /app/dependencies /usr/local/lib/python3.9/site-packages

COPY --from=builder /app .

RUN chmod +x /app/entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/app/entrypoint.sh"]

