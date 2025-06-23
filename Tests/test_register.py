def test_register_success(test_client):
    response = test_client.post('/register/user', data={
        "name": "New User",
        "email": "new@example.com",
        "mobile": "1231231234",
        "username": "newuser",
        "password": "newpass",
        "address": "Somewhere",
        "pin": "654321",
        "age": "25",
        "gender": "F",
        "dob": "1998-05-12"
    })
    assert response.status_code == 201
    assert response.json['status'] == 'success'


def test_register_existing_username_email(test_client):
    response = test_client.post('/register/user', data={
        "name": "Test User",
        "email": "test@example.com",
        "mobile": "1234567890",
        "username": "testuser",
        "password": "testpass",
        "address": "Somewhere",
        "pin": "123456",
        "age": "30",
        "gender": "M",
        "dob": "1990-01-01"
    })
    assert response.status_code == 400




def test_register_missing_fields(test_client):
    response = test_client.post('/register/user', data={
        "name": "No Email"
        # other fields missing
    })
    assert response.status_code == 400
