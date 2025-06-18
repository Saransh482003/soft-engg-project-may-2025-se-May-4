def test_login_success(test_client):
    response = test_client.post('/login', json={
        'username': 'testuser',
        'password': 'testpass'
    })
    assert response.status_code == 200
    assert b'login successful' in response.data


def test_login_failure(test_client):
    response = test_client.post('/login', json={
        'username': 'wronguser',
        'password': 'wrongpass'
    })
    assert response.status_code == 401
    assert b'User not found' in response.data


def test_logout(test_client):
    with test_client.session_transaction() as sess:
        sess['user_id'] = 1
    response = test_client.get('/logout')
    assert response.status_code == 200
    assert b'Logged out successfully' in response.data


def test_login_valid_credentials(test_client):
    response = test_client.post('/login', json={
        "username": "testuser",
        "password": "testpass"
    })
    assert response.status_code == 200
    assert response.json['status'] == 'success'

def test_login_invalid_password(test_client):
    response = test_client.post('/login', json={
        "username": "testuser",
        "password": "wrongpass"
    })
    assert response.status_code == 401
    assert response.json['status'] == 'fail'

def test_login_missing_fields(test_client):
    response = test_client.post('/login', json={"username": "testuser"})
    assert response.status_code == 401

def test_login_nonexistent_user(test_client):
    response = test_client.post('/login', json={
        "username": "nonexistent",
        "password": "123"
    })
    assert response.status_code == 401
