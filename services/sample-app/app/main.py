import os
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import psycopg

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "appdb")
DB_USER = os.getenv("DB_USER", "appuser")
DB_PASS = os.getenv("DB_PASS", "apppass")
APP_ENV = os.getenv("APP_ENV", "local")

DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"


def get_conn():
    return psycopg.connect(DATABASE_URL, connect_timeout=3)


@asynccontextmanager
async def lifespan(app: FastAPI):
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS items (
                    id SERIAL PRIMARY KEY,
                    name TEXT NOT NULL
                );
            """)
        conn.commit()
    yield


app = FastAPI(title="k3d Sample App", lifespan=lifespan)


class ItemIn(BaseModel):
    name: str


@app.get("/")
def root():
    return {"message": "FastAPI on k3d is running", "environment": APP_ENV}


@app.get("/healthz")
def liveness():
    return {"status": "alive"}


@app.get("/readyz")
def readiness():
    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1;")
        return {"status": "ready", "database": "connected"}
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {e}")


@app.get("/items")
def list_items():
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT id, name FROM items ORDER BY id;")
            rows = cur.fetchall()
    return [{"id": r[0], "name": r[1]} for r in rows]


@app.post("/items", status_code=201)
def create_item(item: ItemIn):
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute("INSERT INTO items (name) VALUES (%s) RETURNING id;", (item.name,))
            new_id = cur.fetchone()[0]
        conn.commit()
    return {"id": new_id, "name": item.name}