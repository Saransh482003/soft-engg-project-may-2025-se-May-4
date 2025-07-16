import requests
from flask import Flask, request, session, jsonify
from models import *
import geocoder
from modules.chatbot import Chatbot
from modules.nearby_places import NearbyPlaces
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
        keyword = data.get('keyword', 'pharmacy').lower()
        radius = data.get('radius', 1000)

        if lat is None or lon is None or keyword is None:
            return jsonify({'error': 'Please provide lat, lon, and keyword.'}), 400

        try:
            google_results = nearby_places.find_nearby_places(lat, lon, keyword, radius)
            
            if not google_results:
                return jsonify({'response': [], 'status': 'success'}), 200

            synced_results = []
            
            target_model = None
            if keyword in ['hospital', 'clinic']:
                target_model = Hospitals
            elif keyword == 'pharmacy':
                target_model = Pharmacy
            else:
                 return jsonify({'error': f"Keyword '{keyword}' is not supported."}), 400

            for place in google_results:
                place_id = place.get('place_id')
                if not place_id:
                    continue

                existing_record = db.session.query(target_model).filter_by(place_id=place_id).first()

                if existing_record:
                    synced_results.append(existing_record.to_dict())
                    continue

                details_data = nearby_places.place_details(place_id)
                details = details_data.get('result', {}) if details_data else {}
                if target_model == Hospitals:
                    new_record = Hospitals(
                        place_id=place_id,
                        hospital_name=details.get('name', place.get('name')),
                        address=details.get('formatted_address', place.get('vicinity')),
                        latitudes=place.get('geometry', {}).get('location', {}).get('lat'),
                        longitudes=place.get('geometry', {}).get('location', {}).get('lng'),
                        website=details.get('website'),
                        phone=details.get('formatted_phone_number'),
                        rating=details.get('rating'),
                        num_rating=details.get('user_ratings_total'),
                        type=keyword
                    )
                
                elif target_model == Pharmacy:
                    new_record = Pharmacy(
                        place_id=place_id,
                        name=details.get('name', place.get('name')),
                        address=details.get('formatted_address', place.get('vicinity')),
                        latitude=place.get('geometry', {}).get('location', {}).get('lat'),
                        longitude=place.get('geometry', {}).get('location', {}).get('lng'),
                        phone_number=details.get('formatted_phone_number'),
                        website=details.get('website'),
                        rating=details.get('rating'),
                        user_ratings_total=details.get('user_ratings_total'),
                        opening_hours_json=json.dumps(details.get('opening_hours')) if details.get('opening_hours') else None,
                        business_status=place.get('business_status')
                    )
                
                db.session.add(new_record)
                db.session.flush()
                synced_results.append(new_record.to_dict())

            db.session.commit()
            
            return jsonify({'response': synced_results, 'status': 'success'}), 200

        except Exception as e:
            db.session.rollback()
            return jsonify({'error': f"An unexpected error occurred: {str(e)}", 'status': 'fail'}), 500
               
    # The place_details_route is now mostly for internal use or debugging,
    @app.route('/api/place-details', methods=['POST'])
    @swag_from("docs/place_details.yml")
    def place_details_route():
        data = request.get_json()
        place_id = data.get('place_id')

        if place_id is None:
            return jsonify({'error': 'Please provide a place_id.'}), 400

        try:
            results = nearby_places.place_details(place_id)
            return jsonify({'response': results}), 200
        except Exception as e:
            return jsonify({'error': f"Error: {str(e)}"}), 500