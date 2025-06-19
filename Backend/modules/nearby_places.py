import os
from dotenv import load_dotenv
import requests
import json

load_dotenv()

class NearbyPlaces:
    def __init__(self, api_key):
        self.api_key = api_key

    def find_nearby_places(self, lat, lon, keyword, radius=5000):
        google_maps_url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        params = {
            'location': f'{lat},{lon}',
            'radius': radius,
            'keyword': keyword,
            'key': self.api_key
        }
        response = requests.get(google_maps_url, params=params)
        return response.json()["results"]

    