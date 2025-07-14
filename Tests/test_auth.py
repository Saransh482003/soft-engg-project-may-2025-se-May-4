import requests
url="http://127.0.0.1:5000"

def test_register_success():
    """Test if a user can be regisered succesfully"""
    input={"dob": "1990-01-15","email": "john.doe@example.com","gender": "Male","mobile": "1234567890","password": "securepassword123","user_name": "johndoe"}
    expected_output={'message': 'User created successfully', 'status': 'success', 'user': {'dob': '1990-01-15', 'email': 'john.doe@example.com', 'gender': 'Male', 'mobile': '1234567890', 'user_id': 5, 'user_name': 'johndoe'}}
    response=requests.post(url+"/api/users",json=input)
    op=response.json()
    print("Input:",input)
    print("Expected Output:",expected_output)
    print("Output:",op)
    assert response.status_code==201
    assert expected_output==op

def test_login_success():
    """Test if a user can be logged in succesfully"""
    input={'user_name': 'johndoe','password': 'securepassword123'}
    response = requests.post(url+'/api/users/login', json=input)
    expected_output={'message': 'Login successful', 'status': 'success', 'user': {'dob': '1990-01-15', 'email': 'john.doe@example.com', 'gender': 'Male', 'mobile': '1234567890', 'user_id': 5, 'user_name': 'johndoe'}}
    op=response.json()
    print("Input:",input)
    print("Expected Output:",expected_output)
    print("Output:",op)
    assert response.status_code == 200
    assert expected_output==op


def test_login_failure():
    """Test if giving a wrong username will not log them in"""
    input={'user_name': 'wronguser','password': 'wrongpass'}
    response = requests.post(url+'/api/users/login', json=input)
    expected_output={"error": "Invalid credentials","status": "fail"}
    op=response.json()
    print("Input:",input)
    print("Expected Output:",expected_output)
    print("Output:",op)
    assert response.status_code == 401
    assert expected_output==op

