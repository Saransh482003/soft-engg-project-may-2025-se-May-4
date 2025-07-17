import requests

BASE_URL = "http://127.0.0.1:5000"

def test_search_doctors_no_params():
    """Test searching doctors with no parameters (should return all doctors)"""
    resp = requests.get(BASE_URL + "/api/doctors/search")
    print("Search doctors with no params:", resp.text)
    assert resp.status_code == 200
    data = resp.json()
    assert "doctors" in data
    assert isinstance(data["doctors"], list)

def test_search_doctors_valid_specialization():
    """Test searching doctors with a valid specialization filter"""
    specialization = "cardiology"  # adjust to match DB data
    resp = requests.get(BASE_URL + f"/api/doctors/search?specialization={specialization}")
    print(f"Search doctors with specialization='{specialization}':", resp.text)
    assert resp.status_code == 200
    data = resp.json()
    assert "doctors" in data
    for doc in data["doctors"]:
        assert specialization.lower() in doc["specialization"].lower()

def test_search_doctors_specialization_case_insensitive():
    """Test that specialization filter is case-insensitive"""
    specialization = "Neurology"
    resp = requests.get(BASE_URL + f"/api/doctors/search?specialization={specialization.lower()}")
    resp2 = requests.get(BASE_URL + f"/api/doctors/search?specialization={specialization.upper()}")
    assert resp.status_code == 200 and resp2.status_code == 200
    data1 = resp.json()
    data2 = resp2.json()
    assert data1 == data2  # results should be the same

def test_search_doctors_specialization_partial_match():
    """Test partial matching of specialization"""
    partial_specialization = "cardio"
    resp = requests.get(BASE_URL + f"/api/doctors/search?specialization={partial_specialization}")
    print(f"Search doctors with partial specialization='{partial_specialization}':", resp.text)
    assert resp.status_code == 200
    data = resp.json()
    for doc in data["doctors"]:
        assert partial_specialization.lower() in doc["specialization"].lower()

def test_search_doctors_specialization_no_match():
    """Test specialization that matches no doctors"""
    specialization = "unicornology"
    resp = requests.get(BASE_URL + f"/api/doctors/search?specialization={specialization}")
    print(f"Search doctors with no matching specialization='{specialization}':", resp.text)
    assert resp.status_code == 200
    data = resp.json()
    assert "doctors" in data
    assert len(data["doctors"]) == 0

def test_search_doctors_with_location_param_ignored():
    """Test that location param does not affect results (based on current code)"""
    resp1 = requests.get(BASE_URL + "/api/doctors/search")
    resp2 = requests.get(BASE_URL + "/api/doctors/search?location=NewYork")
    assert resp1.status_code == 200 and resp2.status_code == 200
    data1 = resp1.json()
    data2 = resp2.json()
    # Should be equal since location filter is unused currently
    assert data1 == data2

def test_search_doctors_special_chars_in_specialization():
    """Test specialization param with special characters (should not error, likely no match)"""
    specialization = "!@#$%^&*"
    resp = requests.get(BASE_URL + f"/api/doctors/search?specialization={specialization}")
    print(f"Search doctors with special chars specialization='{specialization}':", resp.text)
    assert resp.status_code == 200
    data = resp.json()
    assert "doctors" in data

def test_search_doctors_empty_specialization_param():
    """Test empty specialization param should behave like no filter"""
    resp1 = requests.get(BASE_URL + "/api/doctors/search")
    resp2 = requests.get(BASE_URL + "/api/doctors/search?specialization=")
    assert resp1.status_code == 200 and resp2.status_code == 200
    data1 = resp1.json()
    data2 = resp2.json()
    assert data1 == data2
