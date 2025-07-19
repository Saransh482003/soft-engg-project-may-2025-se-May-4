import requests

BASE_URL = "http://127.0.0.1:5000"

# Helper function to simulate a login and return session
def login_and_get_session(user_name="johndoe", password="securepassword123"):
    session = requests.Session()
    resp = session.post(BASE_URL + "/api/users/login", json={"user_name": user_name, "password": password})
    assert resp.status_code == 200
    return session

def test_create_reminder_all_fields():
    session = login_and_get_session()
    payload = {
        "medicine_name": "Paracetamol",
        "dosage": "500mg",
        "time_of_day": "08:00",
        "frequency": "daily",
        "relation_to_meal": "after",
        "notification_type": "sms",
        "is_active": True
    }
    resp = session.post(BASE_URL + "/api/reminders", json=payload)
    print("Create Reminder (all fields):", resp.text)
    assert resp.status_code == 201

def test_create_reminder_required_only():
    session = login_and_get_session()
    payload = {
        "medicine_name": "Ibuprofen",
        "time_of_day": "12:00",
        "frequency": "twice"
    }
    resp = session.post(BASE_URL + "/api/reminders", json=payload)
    print("Create Reminder (required only):", resp.text)
    assert resp.status_code == 201

def test_create_reminder_insufficient_data():
    session = login_and_get_session()
    payload = {"medicine_name": "Vitamin C"}
    resp = session.post(BASE_URL + "/api/reminders", json=payload)
    print("Create Reminder (insufficient data):", resp.text)
    assert resp.status_code == 400

def test_get_reminders():
    session = login_and_get_session()
    resp = session.get(BASE_URL + "/api/reminders")
    print("Get Reminders:", resp.text)
    assert resp.status_code == 200
    assert "reminders" in resp.json()

def test_get_reminder_by_valid_id():
    session = login_and_get_session()
    reminders = session.get(BASE_URL + "/api/reminders").json().get("reminders", [])
    if reminders:
        reminder_id = reminders[0]["reminder_id"]
        resp = session.get(BASE_URL + f"/api/reminders/{reminder_id}")
        print("Get Reminder by Valid ID:", resp.text)
        assert resp.status_code == 200
    else:
        print("No reminders to test valid ID fetch.")

def test_get_reminder_by_invalid_id():
    session = login_and_get_session()
    resp = session.get(BASE_URL + "/api/reminders/999999")
    print("Get Reminder by Invalid ID:", resp.text)
    assert resp.status_code == 404

def test_update_reminder_valid():
    session = login_and_get_session()
    reminders = session.get(BASE_URL + "/api/reminders").json().get("reminders", [])
    if reminders:
        reminder_id = reminders[0]["reminder_id"]
        payload = {"time_of_day": "10:30", "frequency": "weekly"}
        resp = session.put(BASE_URL + f"/api/reminders/{reminder_id}", json=payload)
        print("Update Reminder Valid:", resp.text)
        assert resp.status_code == 200
    else:
        print("No reminders to update.")

def test_update_reminder_invalid_id():
    session = login_and_get_session()
    payload = {"time_of_day": "14:00"}
    resp = session.put(BASE_URL + "/api/reminders/999999", json=payload)
    print("Update Reminder Invalid ID:", resp.text)
    assert resp.status_code == 404

def test_delete_reminder_valid():
    session = login_and_get_session()
    payload = {
        "medicine_name": "ToDelete",
        "time_of_day": "20:00",
        "frequency": "once"
    }
    create_resp = session.post(BASE_URL + "/api/reminders", json=payload)
    reminder_id = create_resp.json().get("reminder_id")
    if reminder_id:
        delete_resp = session.delete(BASE_URL + f"/api/reminders/{reminder_id}")
        print("Delete Reminder Valid ID:", delete_resp.text)
        assert delete_resp.status_code == 200

def test_delete_reminder_invalid_id():
    session = login_and_get_session()
    resp = session.delete(BASE_URL + "/api/reminders/999999")
    print("Delete Reminder Invalid ID:", resp.text)
    assert resp.status_code == 404
