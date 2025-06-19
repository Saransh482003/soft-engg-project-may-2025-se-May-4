def test_chatbot_valid_input(test_client):
    response = test_client.post('/chatbot', json={"message": "Hello"})
    assert response.status_code == 200
    assert 'response' in response.json

def test_chatbot_empty_input(test_client):
    response = test_client.post('/chatbot', json={"message": ""})
    assert response.status_code == 400
