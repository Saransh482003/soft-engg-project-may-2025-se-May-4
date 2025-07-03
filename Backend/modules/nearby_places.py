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

    def place_details(self, place_id):
        google_maps_url = f"https://maps.googleapis.com/maps/api/place/details/json?placeid={place_id}&key={self.api_key}"
        params = {
            'place_id': place_id,
            'fields': 'name,rating,formatted_phone_number,website,opening_hours,geometry',
            'key': self.api_key
        }
        response = requests.get(google_maps_url, params=params)
        return response.json()

    