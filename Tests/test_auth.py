import requests

url = "http://127.0.0.1:5000"

def test_register_success():
    input = {
        "dob": "1990-01-15",
        "email": "john.doe@example.com",
        "gender": "Male",
        "mobile_number": "1234567890",
        "password": "securepassword123",
        "user_name": "johndoe"
    }
    response = requests.post(url + "/api/create_user", json=input)
    op = response.json()
    print("Input:", input)
    print("Output:", op)
    assert response.status_code == 201
    assert op["status"] == "success"

def test_register_duplicate_user():
    input = {
        "dob": "1990-01-15",
        "email": "john.doe@example.com",
        "gender": "Male",
        "mobile_number": "1234567890",
        "password": "securepassword123",
        "user_name": "johndoe"
    }
    response = requests.post(url + "/api/create_user", json=input)
    op = response.json()
    print("Output:", op)
    assert response.status_code == 409
    assert "already exists" in op["error"]

def test_create_user_with_minimum_fields():
    input = {
        "dob": "1995-01-01",
        "email": "minuser@example.com",
        "gender": "Other",
        "mobile_number": "9876543210",
        "password": "minimalpass",
        "user_name": "minuser"
    }
    response = requests.post(url + "/api/create_user", json=input)
    op = response.json()
    print("Input:", input)
    print("Output:", op)
    assert response.status_code == 201
    assert op["status"] == "success"

def test_create_user_invalid_email_format():
    input = {
        "user_name": "bademail",
        "email": "not-an-email",
        "mobile_number": "1231231234",
        "gender": "Male",
        "dob": "1990-01-01",
        "password": "pass123"
    }
    response = requests.post(url + "/api/create_user", json=input)
    print("Invalid Email Output:", response.text)
    assert response.status_code in [400, 500]

def test_login_success():
    input = {'user_name': 'johndoe', 'password': 'securepassword123'}
    response = requests.post(url + '/api/users/login', json=input)
    op = response.json()
    print("Login Output:", op)
    assert response.status_code == 200
    assert op["status"] == "success"
    assert op["user"]["user_name"] == "johndoe"

def test_login_failure():
    input = {'user_name': 'wronguser', 'password': 'wrongpass'}
    response = requests.post(url + '/api/users/login', json=input)
    op = response.json()
    print("Output:", op)
    assert response.status_code == 401
    assert op["status"] == "fail"

def test_get_all_users_valid():
    response = requests.get(url + "/api/users?page=1&per_page=5")
    op = response.json()
    print("Output:", op)
    assert response.status_code == 200
    assert "users" in op

def test_get_all_users_invalid_params():
    response = requests.get(url + "/api/users?page=abc&per_page=xyz")
    print("Output:", response.text)
    assert response.status_code == 500

def test_get_all_users_default():
    response = requests.get(url + "/api/users")
    op = response.json()
    print("Output:", op)
    assert response.status_code == 200
    assert "users" in op

def test_get_user_by_valid_id():
    response = requests.get(url + "/api/users/5")
    op = response.json()
    print("Output:", op)
    assert response.status_code == 200
    assert op["user"]["user_id"] == 5

def test_get_user_by_invalid_id():
    response = requests.get(url + "/api/users/99999")
    op = response.json()
    print("Output:", op)
    assert response.status_code == 404
    assert op["status"] == "fail"

def test_search_users_valid_query():
    response = requests.get(url + "/api/users/search?q=john")
    op = response.json()
    print("Output:", op)
    assert response.status_code == 200
    assert "users" in op

def test_search_users_empty_query():
    response = requests.get(url + "/api/users/search?q=")
    op = response.json()
    print("Output:", op)
    assert response.status_code == 400
    assert op["status"] == "fail"

def test_search_users_inappropriate_input():
    response = requests.get(url + "/api/users/search?q=!!!")
    op = response.json()
    print("Output:", op)
    assert response.status_code in [200, 500]

def test_update_user_email():
    updated_data = {"email": "new.email@example.com"}
    response = requests.put(url + "/api/users/5", json=updated_data)
    op = response.json()
    print("Output:", op)
    assert response.status_code == 200
    assert op["user"]["email"] == "new.email@example.com"

def test_update_user_password():
    updated_data = {"password": "newpass123"}
    response = requests.put(url + "/api/users/5", json=updated_data)
    op = response.json()
    print("Output:", op)
    assert response.status_code == 200
    assert op["status"] == "success"

def test_update_user_no_change():
    response = requests.put(url + "/api/users/5", json={})
    op = response.json()
    print("Update No Change Output:", op)
    assert response.status_code == 200
    assert op["status"] == "success"

def test_partial_update_conflict_email():
    input1 = {
        "user_name": "patchuser1",
        "email": "patch1@example.com",
        "mobile_number": "1001001001",
        "gender": "Other",
        "dob": "1990-01-01",
        "password": "patchpass1"
    }
    input2 = {
        "user_name": "patchuser2",
        "email": "patch2@example.com",
        "mobile_number": "1001001002",
        "gender": "Other",
        "dob": "1990-01-01",
        "password": "patchpass2"
    }
    res1 = requests.post(url + "/api/create_user", json=input1)
    res2 = requests.post(url + "/api/create_user", json=input2)
    id2 = res2.json()["user"]["user_id"]
    patch_resp = requests.patch(url + f"/api/users/{id2}", json={"email": "patch1@example.com"})
    print("Conflict Email Patch Output:", patch_resp.json())
    assert patch_resp.status_code == 409

def test_delete_user():
    input = {
        "dob": "1991-02-15",
        "email": "temp.user@example.com",
        "gender": "Female",
        "mobile_number": "1112223333",
        "password": "temporary123",
        "user_name": "tempuser"
    }
    create_resp = requests.post(url + "/api/create_user", json=input)
    user_id = create_resp.json()["user"]["user_id"]
    print("Created user_id:", user_id)
    delete_resp = requests.delete(f"{url}/api/users/{user_id}")
    print("Delete Response:", delete_resp.json())
    assert delete_resp.status_code == 200

def test_delete_nonexistent_user():
    response = requests.delete(url + "/api/users/999999")
    op = response.json()
    print("Delete Nonexistent User Output:", op)
    assert response.status_code == 404
    assert op["status"] == "fail"

def test_logout_after_login():
    session_req = requests.Session()
    login_data = {'user_name': 'johndoe', 'password': 'securepassword123'}
    login_resp = session_req.post(url + "/api/users/login", json=login_data)
    assert login_resp.status_code == 200
    logout_resp = session_req.post(url + "/api/users/logout")
    print("Logout Output:", logout_resp.json())
    assert logout_resp.status_code == 200

def test_logout_without_login():
    session_req = requests.Session()
    logout_resp = session_req.post(url + "/api/users/logout")
    print("Logout Output:", logout_resp.json())
    assert logout_resp.status_code == 200

def test_get_current_user_after_login():
    session_req = requests.Session()
    login_data = {'user_name': 'johndoe', 'password': 'securepassword123'}
    login_resp = session_req.post(url + "/api/users/login", json=login_data)
    assert login_resp.status_code == 200
    me_resp = session_req.get(url + "/api/users/me")
    print("Me Output:", me_resp.json())
    assert me_resp.status_code == 200
    assert me_resp.json()["user"]["user_name"] == "johndoe"

def test_get_current_user_after_logout():
    session_req = requests.Session()
    login_data = {'user_name': 'johndoe', 'password': 'securepassword123'}
    session_req.post(url + "/api/users/login", json=login_data)
    session_req.post(url + "/api/users/logout")
    me_resp = session_req.get(url + "/api/users/me")
    print("Me Output After Logout:", me_resp.json())
    assert me_resp.status_code == 401
