FROM python:3.12-slim

WORKDIR /app

# Apply latest Debian security patches and create non-root user
RUN apt-get update && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -m appuser

COPY app/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip "setuptools>=78.1.1" wheel && \
    pip install --no-cache-dir -r requirements.txt

COPY app/ ./app/
USER appuser

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]