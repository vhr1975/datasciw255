from fastapi.testclient import TestClient

from src import __version__
from src.main import app

client = TestClient(app)

def test_version():
    assert __version__ == '0.1.0'

def test_root():
    response = client.get("/")
    assert response.status_code == 501
    assert response.json() == {"message": "not implemented"}

def test_hello1():
    response = client.get("/hello/?name=")
    assert response.status_code == 400
    assert response.json() == {        
        'detail': 'string {name} required'
    }

def test_hello2():
    response = client.get("/hello/")
    assert response.status_code == 422
    assert response.json() == {
        "detail": [{'loc': ['query', 'name'],
                    'msg': 'field required',
                    'type': 'value_error.missing'}]
    }

def test_hello3():
    response = client.get("/hello/?name=Wendy")
    assert response.status_code == 200
    assert response.json() == {
        "hello": "Wendy"        
    }

def test_docs():
    response = client.get("/docs")
    assert response.status_code == 200

def test_docs():
    response = client.get("/docs")
    assert response.status_code == 200

def test_openapi():
    response = client.get("/openapi.json")
    assert response.status_code == 200
