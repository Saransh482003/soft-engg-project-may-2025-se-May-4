import requests
from datetime import datetime

BASE_URL = "http://127.0.0.1:5000"

def test_log_medicine_intake_valid():
    """Test logging medicine intake with valid data"""
    # This reminder_id should already exist in the system
    data = {
        "reminder_id": 1,  # Replace with a valid reminder_id from your DB
        "status": "taken"
    }
    response = requests.post(BASE_URL + "/api/medicine-logs", json=data)
    print("Log Medicine Intake:", response.text)
    assert response.status_code == 201
    assert "message" in response.json()

def test_log_medicine_intake_missing_id():
    """Test logging medicine intake with missing reminder_id"""
    data = {
        "status": "taken"
    }
    response = requests.post(BASE_URL + "/api/medicine-logs", json=data)
    print("Log Medicine Intake Missing ID:", response.text)
    assert response.status_code == 400
    assert "Reminder ID is required" in response.text

def test_get_health_summary_valid_user():
    """Test getting health summary for a valid user ID"""
    user_id = 1  # Replace with an actual user_id from your DB who has logs today
    response = requests.get(BASE_URL + f"/api/users/{user_id}/health-summary")
    print("Health Summary:", response.text)
    assert response.status_code == 200
    summary = response.json()
    assert "medicine_taken" in summary
    assert "medicine_skipped" in summary
    assert "log_details" in summary
    assert isinstance(summary["log_details"], list)

def test_get_health_summary_invalid_user():
    """Test getting health summary for a non-existent user"""
    response = requests.get(BASE_URL + "/api/users/99999/health-summary")
    print("Health Summary Invalid User:", response.text)
    # Status should be 200 but possibly empty log details
    assert response.status_code == 200
    summary = response.json()
    assert "log_details" in summary
