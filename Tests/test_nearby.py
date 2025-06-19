def test_nearby_hospitals(test_client):
    response = test_client.post('/nearby-hospitals', json={
        'latitude': 12.9716,
        'longitude': 77.5946
    })
    assert response.status_code == 200
    assert isinstance(response.get_json(), list)


def test_nearby_pharmacies(test_client):
    response = test_client.post('/nearby-pharmacies', json={
        'latitude': 12.9716,
        'longitude': 77.5946
    })
    assert response.status_code == 200
    assert isinstance(response.get_json(), list)



def test_nearby_invalid_coords(test_client):
    response = test_client.post('/nearby-hospitals', json={
        "latitude": None,
        "longitude": None
    })
    assert response.status_code == 200  # Note: Add validation in route if needed