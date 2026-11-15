from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_root():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["message"] == "FastAPI on k3d is running"


def test_healthz():
    response = client.get("/healthz")
    assert response.status_code == 200
    assert response.json() == {"status": "alive"}


@patch("app.main.get_conn")
def test_readyz_healthy(mock_get_conn):
    mock_conn = MagicMock()
    mock_get_conn.return_value.__enter__.return_value = mock_conn
    response = client.get("/readyz")
    assert response.status_code == 200
    assert response.json()["status"] == "ready"