import requests
import json

BASE_URL = "http://127.0.0.1:5000"

# --- Helper to simulate login/session if needed later
from requests import Session

# --- 1. chatbot_route tests ---
def test_chatbot_valid_question():
    payload = {"question": "How can I stay healthy as a senior?", "history": {}}
    res = requests.post(BASE_URL + "/api/chatbot", json=payload)
    print("Chatbot Valid:", res.text)
    assert res.status_code == 200
    data = res.json()
    assert "response" in data and isinstance(data["response"], str)

def test_chatbot_empty_question():
    payload = {"question": "", "history": {}}
    res = requests.post(BASE_URL + "/api/chatbot", json=payload)
    print("Chatbot Empty:", res.text)
    assert res.status_code == 400
    assert "Please enter a valid question" in res.json()["response"]

# --- 2. location_route tests ---
def test_location_success():
    res = requests.get(BASE_URL + "/api/location")
    print("Location success:", res.text)
    # It might fail if external service is down
    assert res.status_code in [200, 400]
    data = res.json()
    assert "response" in data

# --- 3. nearby_places_route tests ---
def test_nearby_places_missing_fields():
    payload = {"lat": 12.0}
    res = requests.post(BASE_URL + "/api/nearby_places", json=payload)
    print("Nearby Missing:", res.text)
    assert res.status_code == 400
    assert "Please provide lat, lon, and keyword" in res.json()["error"]

def test_nearby_places_unsupported_keyword():
    payload = {"lat": 12.0, "lon": 77.0, "keyword": "bakery"}
    res = requests.post(BASE_URL + "/api/nearby_places", json=payload)
    print("Nearby Unsupported:", res.text)
    assert res.status_code == 400
    assert "not supported" in res.json()["error"]

def test_nearby_places_no_results(monkeypatch):
    # monkeypatch search function to return empty list
    class DummyNP:
        def find_nearby_places(*args, **kw): return []
    # substitute in monkeypatch, then call endpoint
    import modules.nearby_places
    monkeypatch.setattr(modules.nearby_places, "NearbyPlaces", lambda api_key: DummyNP())
    payload = {"lat": 12.0, "lon": 77.0, "keyword": "pharmacy", "radius": 500}
    res = requests.post(BASE_URL + "/api/nearby_places", json=payload)
    print("Nearby No Results:", res.text)
    assert res.status_code == 200
    assert res.json()["response"] == []
    assert res.json()["status"] == "success"

# --- 4. place_details_route tests ---
def test_place_details_missing_id():
    res = requests.post(BASE_URL + "/api/place-details", json={})
    print("Place Details Missing:", res.text)
    assert res.status_code == 400
    assert "provide a place_id" in res.json()["error"]

def test_place_details_invalid_id(monkeypatch):
    # monkeypatch to raise error
    class DummyNP:
        def place_details(self, pid): raise Exception("API failure")
    import modules.nearby_places
    monkeypatch.setattr(modules.nearby_places, "NearbyPlaces", lambda api_key: DummyNP())
    payload = {"place_id": "invalid123"}
    res = requests.post(BASE_URL + "/api/place-details", json=payload)
    print("Place Details Fail:", res.text)
    assert res.status_code == 500
    assert "Error:" in res.json()["error"]
