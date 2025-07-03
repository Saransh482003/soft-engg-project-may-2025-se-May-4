import requests
url='http://127.0.0.1:5000'
def test_location():
    """Test if the correct location is returned"""
    response=requests.get(url+'/api/location')
    input={}
    expected_output= {'response': {'lat': 8.7274, 'lng': 77.6838}}
    op=response.json()
    print("Input:",input)
    print("Expected output:",expected_output)
    print("Output:",op)
    assert response.status_code==200
    assert op==expected_output

def test_nearby_places_with_input():
    """Testing by providing an input"""
    input={"keyword": "pharmacy","lat": 8.7274,"lon": 77.6838,"radius": 2000}
    response=requests.post(url+'/api/nearby_places',json=input)
    op=response.json()
    print("Input:",input)
    expected_output_structure={
  "response": [
    {
      "address": "123 Main St, Anytown, USA",
      "geometry": {
        "location": {
          "lat": 34.051,
          "lng": -118.245
        }
      },
      "name": "Good Health Hospital",
      "place_id": "ChIJUQ_M-R3GwoAR4q3W4C3k0j0",
      "rating": 4.5
    }
  ]
}
    print("Expected output:","Must be of the structure",expected_output_structure)
    print("Output:",op['response'][0])
    cond=(response.status_code==200) and ('response' in op) and (len(op['response'])>1) and (type(op['response'])==list)
    assert cond

def test_nearby_places_with_negative_input():
    """Testing by giving negative coordinates"""
    input={"keyword": "pharmacy","lat": -8.7274,"lon": -77.6838,"radius": 2000}
    response=requests.post(url+'/api/nearby_places',json=input)
    op=response.json()
    expected_output={"response":[]}
    print("Input:",input)
    print("Expected output:",expected_output)
    print("Output:",op)
    assert expected_output==op

def test_nearby_places_with_missing_inputs():
    """Testing with not giving a latitude"""
    input={"lon": -77.6838,"radius": 2000}
    response=requests.post(url+'/api/nearby_places',json=input)
    op=response.json()
    expected_output={"response": "Please provide lat, lon, and keyword."}
    print("Input:",input)
    print("Expected output:",expected_output)
    print("Output:",op)
    assert expected_output==op
    assert response.status_code==400

def test_place_details():
    """Testing with giving a valid place id"""
    input={"place_id":"ChIJIc6a4WIRBDsRUcz2ylKS4nU"}
    response=requests.post(url+'/api/place-details',json=input)
    op=response.json()
    print("Input:",input)
    print("Output:",op)
    print("Inference:","`result` is called instead of the json directly")
    assert response.status_code==200

def tet_plcace_details_without_place_id():
    """Testing without giving a valid place id"""
    input={"place_id":""}
    response=requests.post(url+'/api/place-details',json=input)
    op=response.json()
    expected_output={'response': 'Please provide a place_id.'}
    print("Input:",input)
    print("Output:",op)
    assert response.status_code==400
    assert op==expected_output