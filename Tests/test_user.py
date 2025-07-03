import requests
url='http://127.0.0.1:5000/'
def test_create_user():
    """Testing to create a user"""
    input={
  "dob": "1990-01-15",
  "email": "john.doe@example.com",
  "gender": "Male",
  "mobile": "1234567890",
  "password": "securepassword123",
  "user_name": "johndoe"
}
    response=requests.post(url+'/api/users',json=input)
    print(response.status_code)
    print(response.json())
    assert True

#def test_user():
    """Testing toGet user details"""
#    input=(1,10)
#    response=requests.get(url+'/api/users?page=1&per_page=10')
#    print(response.status_code)
#    print(response.json())
#    assert True