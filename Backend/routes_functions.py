import requests
from flask import Flask, request, session, jsonify
from models import *
import geocoder
from modules.chatbot import Chatbot
from modules.nearby_places import NearbyPlaces
from modules.website_scraper import WebsiteScraper
from flasgger.utils import swag_from
import json




def function_routes(app, db, auth):
    SYSTEM_PROMPT = """"
        You are a kind, patient, and helpful assistant for senior citizens.You are a compassionate, patient, and knowledgeable virtual medical consultant specializing in assisting elderly and disabled individuals. Your primary goal is to offer clear, respectful, and reassuring medical advice in simple terms that are easy to understand.

        Key guidelines:
        - Always be **kind, non-judgmental, and encouraging** in tone.
        - Automatically detect the **user's language** and **respond in the same language**.
        - Provide **basic, responsible medical information** such as lifestyle tips, medication reminders, understanding symptoms, and when to seek help.
        - **Never diagnose** medical conditions, **prescribe treatments**, or offer guidance that should come from a licensed medical professional.
        - If a query is beyond your capabilities, gently **recommend the user consult a doctor or healthcare provider**.
        - Always **prioritize safety, privacy, and empathy** in every interaction.

        Example disclaimers you may use when needed:
        - “I'm here to support you with general information, but it's important to speak with a qualified doctor for this.”
        - “This might require a medical professional's opinion. Would you like help in understanding what kind of specialist to consult?”

        Your responses should make the user feel **heard, supported, and informed**—never overwhelmed.
        Also the response should be in the same language as the user input.
        Also the response should be in markdown. I will direct put it in a markdown renderer. So format it pretty good. So use all bullets, emojis and all to make it look good.
    """
    chatbot = Chatbot(api_key=auth.get("GROQ_API_KEY"), system_prompt=SYSTEM_PROMPT)
    nearby_places = NearbyPlaces(api_key=auth.get("GOOGLE_MAPS_API_KEY"))
    web_scraper = WebsiteScraper(api_key=auth.get("GROQ_API_KEY"))

    def safe_float(val):
        try:
            return float(val)
        except (TypeError, ValueError):
            return 0.0

    def safe_int(val):
        try:
            return int(val)
        except (TypeError, ValueError):
            return 0
        
    @app.route('/api/chatbot', methods=['POST'])
    @swag_from("docs/chatbot.yml")
    def chatbot_route():
        """
        Handles chatbot interaction requests.
        This route function receives a JSON payload containing a user's question and conversation history,
        validates the input, and generates a response using the chatbot model. If the input is invalid,
        it returns an error message. On successful processing, it returns the chatbot's reply. Handles
        unexpected errors gracefully.
        Returns:
            JSON response with the chatbot's reply and appropriate HTTP status code.
            - 200: Success, with chatbot response.
            - 400: Invalid input.
            - 500: Internal server error.
        """
        
        data = request.get_json()
        user_input = data.get('question', '').strip()
        history = data.get('history', {"user": "", "assistant": ""})

        if user_input is None or user_input == '':
            return jsonify({'response': 'Please enter a valid question.'}), 400

        try:
            reply = chatbot.get_response(user_input, history)
            return jsonify({'response': reply}), 200
        except Exception as e:
            return jsonify({'response': f"Error: {str(e)}"}), 500


    @app.route('/api/doctor-finder', methods=['POST'])
    @swag_from("docs/doctor_finder.yml")
    def doctor_finder():
        """
        Endpoint to find nearby hospitals or clinics and scrape doctor information based on location and specialty.
        Receives a JSON payload with the following fields:
            - latitude (float): Latitude of the user's location. (required)
            - longitude (float): Longitude of the user's location. (required)
            - type (str): Type of place to search for (e.g., 'hospital', 'clinic'). Defaults to 'hospital'. (optional)
            - radius (int): Search radius in meters. Defaults to 1000. (optional)
            - specialist (str): Medical specialty to search for (e.g., 'obstetrician'). Defaults to 'obstetrician'. (optional)
        Process:
            1. Finds nearby places of the specified type within the given radius.
            2. Retrieves detailed information for each place.
            3. Attempts to scrape doctor information from each place's website for the specified specialty.
        Returns:
            JSON response with:
                - response: Dictionary of place details keyed by place_id.
                - scraped_data: Dictionary of scraped doctor information keyed by place_id.
                - status: 'success' if the operation was successful.
        Response Codes:
            200: Success. Returns the place details and scraped doctor data.
            400/500: Error in processing or scraping data.
        """

        # try:
        data = request.get_json()
        latitude = data.get('latitude')
        longitude = data.get('longitude')
        type = data.get('type', 'hospital').lower()
        radius = data.get('radius', 1000)
        specialist = data.get('specialist', 'obstetrician')
        limit = data.get('limit', 5)

        if latitude is None or longitude is None:
            return jsonify({'error': 'Latitude and longitude are required fields.', 'status': 'fail'}), 400

        nearby_hospitals = nearby_places.find_nearby_places(latitude, longitude, type, radius)
        if not nearby_hospitals:
            return jsonify({'response': {}, 'scraped_data': {}, 'status': 'no_places_found'}), 200

        place_ids = [place.get('place_id') for place in nearby_hospitals if place.get('place_id')]
        nearby_hospitals = sorted(
            nearby_hospitals,
            key=lambda x: safe_float(x.get("distance"))
        )

        top_10_closest = nearby_hospitals[:10]

        top_10_sorted = sorted(
            top_10_closest,
            key=lambda x: (
                -safe_int(x.get("user_ratings_total"))
                -safe_float(x.get("rating")),
            )
        )
        hospital_info = top_10_sorted[:5]

        place_ids = [place.get('place_id') for place in hospital_info if place.get('place_id')]
        place_details = {}
        for place_id in place_ids:
            details = nearby_places.place_details(place_id)
            if details:
                place_details[place_id] = details

        scrape = {}
        for place_id, details in list(place_details.items()):
            website = details.get('website')
            name = details.get('name', '')
            if not website:
                scrape[place_id] = {"name": name, "doctor_info": [], "error": "No website found for this place."}
                continue
            doctor_pages = web_scraper.find_doctor_page_links(website, specialist)[:3]
            if doctor_pages != []:
                page_scrape = []
                for page in doctor_pages:
                    doctor_scrape = web_scraper.fetch_doctor_information(page, specialist)
                    page_scrape.append(doctor_scrape)
                scrape[place_id] = {"name": name, "website": website, "doctor_scrape": page_scrape, "pages": doctor_pages}
        return scrape
        


    @app.route('/api/pharmacy-finder', methods=['POST'])
    @swag_from("docs/pharmacy-finder.yml")
    def pharmacy_finder():
        """
        Handles requests to find nearby pharmacies (or other specified place types) based on provided latitude and longitude.
        Returns a JSON response containing detailed information about each found place, or an error/status message.
        Request JSON Body:
            latitude (float): Latitude of the location (required).
            longitude (float): Longitude of the location (required).
            type (str, optional): Type of place to search for (default: 'pharmacy').
            radius (int, optional): Search radius in meters (default: 1000).
        Responses:
            200: Success. Returns a dictionary of place details keyed by place_id, or an empty response if no places found.
            400: Bad request. Missing latitude or longitude.
            500: Internal server error. Unexpected error occurred.
        Returns:
            flask.Response: JSON response with 'response' (dict), 'status' (str), and optionally 'error' (str).
        """

        try:
            data = request.get_json()
            latitude = data.get('latitude')
            longitude = data.get('longitude')
            type = data.get('type', 'pharmacy').lower()
            radius = data.get('radius', 1000)

            if latitude is None or longitude is None:
                return jsonify({'error': 'Latitude and longitude are required fields.', 'status': 'fail'}), 400

            pharmacy_info = nearby_places.find_nearby_places(latitude, longitude, type, radius)
            if not pharmacy_info:
                return jsonify({'response': {}, 'status': 'no_places_found'}), 200

            place_ids = [place.get('place_id') for place in pharmacy_info if place.get('place_id')]

            place_details = {}  
            for place_id in place_ids:
                details = nearby_places.place_details(place_id)
                if details:
                    place_details[place_id] = details

            return jsonify({'response': place_details, 'status': 'success'}), 200

        except Exception as e:
            return jsonify({'error': f"An unexpected error occurred: {str(e)}", 'status': 'fail'}), 500
        

    @app.route('/api/hospital-finder', methods=['POST'])
    @swag_from("docs/hospital-finder.yml")
    def hospital_finder():
        """
        Handles requests to find nearby hospitals based on provided latitude and longitude.
        Returns a JSON response containing detailed information about each found place, or an error/status message.
        Request JSON Body:
            latitude (float): Latitude of the location (required).
            longitude (float): Longitude of the location (required).
            type (str, optional): Type of place to search for (default: 'hospital').
            radius (int, optional): Search radius in meters (default: 1000).
        Responses:
            200: Success. Returns a dictionary of place details keyed by place_id, or an empty response if no places found.
            400: Bad request. Missing latitude or longitude.
            500: Internal server error. Unexpected error occurred.
        Returns:
            flask.Response: JSON response with 'response' (dict), 'status' (str), and optionally 'error' (str).
        """

        try:
            data = request.get_json()
            latitude = data.get('latitude')
            longitude = data.get('longitude')
            type = data.get('type', 'hospital').lower()
            radius = data.get('radius', 1000)

            if latitude is None or longitude is None:
                return jsonify({'error': 'Latitude and longitude are required fields.', 'status': 'fail'}), 400

            hospital_info = nearby_places.find_nearby_places(latitude, longitude, type, radius)
            if not hospital_info:
                return jsonify({'response': {}, 'status': 'no_places_found'}), 200

            place_ids = [place.get('place_id') for place in hospital_info if place.get('place_id')]

            place_details = {}  
            for place_id in place_ids:
                details = nearby_places.place_details(place_id)
                if details:
                    place_details[place_id] = details

            return jsonify({'response': place_details, 'status': 'success'}), 200

        except Exception as e:
            return jsonify({'error': f"An unexpected error occurred: {str(e)}", 'status': 'fail'}), 500
