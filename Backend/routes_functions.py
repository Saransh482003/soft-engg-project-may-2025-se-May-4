import requests
from flask import Flask, request, session, jsonify
from models import *
import geocoder
from modules.chatbot import Chatbot
from modules.nearby_places import NearbyPlaces
from flasgger.utils import swag_from




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

    @app.route('/api/chatbot', methods=['POST'])
    @swag_from("docs/chatbot.yml")
    def chatbot_route():
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

    @app.route('/api/location', methods=['GET'])
    @swag_from("docs/location.yml")
    def location_route():
        g = geocoder.ip('me')
        if not g.ok:
            return jsonify({'response': 'Unable to retrieve location.'}), 400
        try:
            location = g.latlng
            return jsonify({'response': {"lat": location[0], "lng": location[1]}}), 200
        except Exception as e:
            return jsonify({'response': f"Error: {str(e)}"}), 500

    @app.route('/api/nearby_places', methods=['POST'])
    @swag_from("docs/nearby_places.yml")
    def nearby_places_route():
        data = request.get_json()
        lat = data.get('lat')
        lon = data.get('lon')
        keyword = data.get('keyword','hospital')
        radius = data.get('radius', 5000)

        if lat is None or lon is None or keyword is None:
            return jsonify({'response': 'Please provide lat, lon, and keyword.'}), 400

        try:
            results = nearby_places.find_nearby_places(lat, lon, keyword, radius)
            return jsonify({'response': results}), 200
        except Exception as e:
            return jsonify({'response': f"Error: {str(e)}"}), 500

    @app.route('/api/place-details', methods=['POST'])
    @swag_from("docs/place_details.yml")
    def place_details_route():
        data = request.get_json()
        place_id = data.get('place_id')

        if place_id is None:
            return jsonify({'response': 'Please provide a place_id.'}), 400

        try:
            results = nearby_places.place_details(place_id)
            return jsonify({'response': results}), 200
        except Exception as e:
            return jsonify({'response': f"Error: {str(e)}"}), 500

