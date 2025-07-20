import requests

BASE_URL = "http://127.0.0.1:5000"

# Set this once authenticated or use session below for persistent login
session = requests.Session()

def login_as_user():
    """Log in as a regular user (assuming user exists in DB)"""
    payload = {"user_name": "johndoe", "password": "securepassword123"}
    resp = session.post(BASE_URL + "/api/users/login", json=payload)
    assert resp.status_code == 200


def test_add_emergency_contact_valid():
    """Test adding emergency contact with valid data"""
    login_as_user()
    payload = {
        "contact_name": "Jane Doe",
        "contact_number": "9876543210",
        "relation": "Sister"
    }
    resp = session.post(BASE_URL + "/api/emergency-contacts", json=payload)
    print("Add valid contact:", resp.text)
    assert resp.status_code == 201
    assert "added" in resp.json()["message"]


def test_add_emergency_contact_missing_number():
    """Test adding contact with missing number"""
    login_as_user()
    payload = {
        "contact_name": "John Doe"
        # Missing contact_number
    }
    resp = session.post(BASE_URL + "/api/emergency-contacts", json=payload)
    print("Missing contact number:", resp.text)
    assert resp.status_code == 400
    assert "required" in resp.json()["error"]


def test_add_emergency_contact_missing_name():
    """Test adding contact with missing name"""
    login_as_user()
    payload = {
        "contact_number": "1234567890"
        # Missing contact_name
    }
    resp = session.post(BASE_URL + "/api/emergency-contacts", json=payload)
    print("Missing contact name:", resp.text)
    assert resp.status_code == 400
    assert "required" in resp.json()["error"]


def test_add_emergency_contact_unauthenticated():
    """Test adding contact without being logged in"""
    payload = {
        "contact_name": "No Login",
        "contact_number": "1112223333"
    }
    # Using fresh session to simulate logout
    resp = requests.post(BASE_URL + "/api/emergency-contacts", json=payload)
    print("Unauthenticated add:", resp.text)
    assert resp.status_code == 401
    assert "Not authenticated" in resp.json()["error"]


def test_get_emergency_contacts_with_data():
    """Test retrieving emergency contacts after adding"""
    login_as_user()
    resp = session.get(BASE_URL + "/api/emergency-contacts")
    print("Get contacts:", resp.text)
    assert resp.status_code == 200
    assert "contacts" in resp.json()
    assert isinstance(resp.json()["contacts"], list)


def test_get_emergency_contacts_unauthenticated():
    """Test retrieving emergency contacts without being logged in"""
    # New session without login
    fresh_session = requests.Session()
    resp = fresh_session.get(BASE_URL + "/api/emergency-contacts")
    print("Get contacts unauthenticated:", resp.text)
    assert resp.status_code == 401
    assert "Not authenticated" in resp.json()["error"]
