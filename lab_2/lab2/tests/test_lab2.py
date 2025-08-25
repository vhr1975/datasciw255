import pytest
import json
from fastapi.testclient import TestClient
from src import __version__
from src.main import app
from pydantic import BaseModel

class PredictionInput(BaseModel):
    MedInc: float
    HouseAge: float
    AveRooms: float
    AveBedrms: float
    Population: float
    AveOccup: float
    Latitude: float
    Longitude: float

client = TestClient(app)

def test_version():
    assert __version__ == "0.1.0"

def test_hello_bad_parameter():
    response = client.get("/hello?bob=name")
    assert response.status_code == 422
    assert response.json() == {
        "detail": [
            {
                "loc": ["query", "name"],
                "msg": "field required",
                "type": "value_error.missing",
            }
        ]
    }

def test_docs():
    response = client.get("/docs")
    assert response.status_code == 200

@pytest.mark.parametrize(
    "test_input, expected",
    [("james", "james"), ("bob", "bob"), ("BoB", "BoB"), (100, "100")],
)

def test_hello(test_input, expected):
    response = client.get(f"/hello?name={test_input}")
    assert response.status_code == 200
    assert response.json() == {"hello": expected}


def test_hello_multiple_parameter_with_good_and_bad():
    response = client.get("/hello?name=james&bob=name")
    assert response.status_code == 200
    assert response.json() == {"hello": "james"}


def test_predict():
    input_data = {
        "MedInc": 8.3252,
        "HouseAge": 41.0,
        "AveRooms": 6.984126984126984,
        "AveBedrms": 1.0238095238095237,
        "Population": 322.0,
        "AveOccup": 2.5555555555555554,
        "Latitude": 37.88,
        "Longitude": -122.23,
    }
    response = client.post("/predict", json=input_data)

    assert response.status_code == 200
    assert "prediction" in response.json()

def test_predict_bad_parameters():
    with TestClient(app) as client:
        response = client.post(
            "/predict",
            json={
                "MedInc": "bad",
                "HouseAge": "bad",
                "AveRooms": "bad",
                "AveBedrms": "bad",
                "Population": "bad",
                "AveOccup": "bad",
                "Latitude": "bad",
                "Longitude": "bad",
            },
        )

        assert response.status_code == 422
        assert response.json() == {
            "detail": [
                {
                    "loc": ["body", "MedInc"],
                    "msg": "value is not a valid float",
                    "type": "type_error.float",
                },
                {
                    "loc": ["body", "HouseAge"],
                    "msg": "value is not a valid float",
                    "type": "type_error.float",
                },
                {
                    "loc": ["body", "AveRooms"],
                    "msg": "value is not a valid float",
                    "type": "type_error.float",
                },
                {
                    "loc": ["body", "AveBedrms"],
                    "msg": "value is not a valid float",
                    "type": "type_error.float",
                },
                {
                    "loc": ["body", "Population"],
                    "msg": "value is not a valid float",
                    "type": "type_error.float",
                },
                {
                    "loc": ["body", "AveOccup"],
                    "msg": "value is not a valid float",
                    "type": "type_error.float",
                },
                {
                    "loc": ["body", "Latitude"],
                    "msg": "value is not a valid float",
                    "type": "type_error.float",
                },
                {
                    "loc": ["body", "Longitude"],
                    "msg": "value is not a valid float",
                    "type": "type_error.float",
                },
            ]
        }
