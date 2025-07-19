import requests

BASE_URL = "http://127.0.0.1:5000"

# --- Simulate user login ---
def login_as(user_type="clinic"):
    session_req = requests.Session()
    if user_type == "clinic":
        login_payload = {"user_name": "clinicuser", "password": "clinicpass123"}
    else:
        login_payload = {"user_name": "normaluser", "password": "userpass123"}

    login_resp = session_req.post(BASE_URL + "/api/users/login", json=login_payload)
    assert login_resp.status_code == 200, f"Login failed for {user_type} user"
    return session_req

# --- 1. Clinic user with valid pincode ---
def test_analytics_symptom_trends_valid_clinic_user():
    session = login_as("clinic")
    params = {"pincode": "560001"}  # Replace with a known pincode in your DB
    resp = session.get(BASE_URL + "/api/analytics/symptom-trends", params=params)
    print("✅ Clinic User, Valid Pincode:", resp.text)
    assert resp.status_code == 200
    json_data = resp.json()
    assert json_data["status"] == "success"
    assert json_data["pincode"] == "560001"
    assert isinstance(json_data["trends"], list)

# --- 2. Normal user with valid pincode ---
def test_analytics_symptom_trends_normal_user_forbidden():
    session = login_as("normal")
    params = {"pincode": "560001"}
    resp = session.get(BASE_URL + "/api/analytics/symptom-trends", params=params)
    print("🚫 Normal User, Valid Pincode:", resp.text)
    assert resp.status_code == 403
    assert "permission" in resp.json()["error"].lower()

# --- 3. Clinic user with missing pincode ---
def test_analytics_symptom_trends_missing_pincode():
    session = login_as("clinic")
    resp = session.get(BASE_URL + "/api/analytics/symptom-trends")
    print("❗️Clinic User, Missing Pincode:", resp.text)
    assert resp.status_code == 400
    assert "pincode is required" in resp.json()["error"].lower()

# --- 4. Unauthenticated user ---
def test_analytics_symptom_trends_unauthenticated():
    resp = requests.get(BASE_URL + "/api/analytics/symptom-trends", params={"pincode": "560001"})
    print("🔒 Unauthenticated Access:", resp.text)
    assert resp.status_code == 401
    assert "authentication required" in resp.json()["error"].lower()

# --- 5. Clinic user, pincode with no data ---
def test_analytics_symptom_trends_no_symptom_data():
    session = login_as("clinic")
    params = {"pincode": "999999"}  # Assume this pincode has no records
    resp = session.get(BASE_URL + "/api/analytics/symptom-trends", params=params)
    print("🌀 Clinic User, No Data Pincode:", resp.text)
    assert resp.status_code == 200
    assert resp.json()["trends"] == []

