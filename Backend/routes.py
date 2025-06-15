import requests
from flask import Flask, request, redirect, send_from_directory,render_template, url_for, session,abort,flash,jsonify
from config import db,app
from models import *
from modules.chatbot import get_chatbot_response


def configure_routes(app):
    @app.route('/')
    def home():
        return jsonify({'message': 'Welcome to the Shravan API!'}), 200

    @app.route('/chatbot', methods=['POST'])
    def chatbot():
        data = request.get_json()
        user_input = data.get('message', '').strip()

        if user_input is None or user_input == '':
            return jsonify({'response': 'Please enter a valid message.'}), 400

        try:
            reply = get_chatbot_response(user_input)
            return jsonify({'response': reply}), 200
        except Exception as e:
            return jsonify({'response': f"Error: {str(e)}"}), 500

    @app.route('/logout', methods=['GET'])
    def logout():
        try:
            session.clear()  # Clear the session
            return jsonify({'msg': 'Logged out successfully', 'status': 'success'}), 200
        except Exception as e:
            return jsonify({'msg': str(e), 'status': 'error'}), 500


    @app.route('/login', methods=['POST'])
    def login():
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')

        # Query the user by username
        user = User.query.filter_by(username=username).first()

        if user is None:
            return jsonify({'msg': 'User not found', 'status': 'fail'}), 401

        if user.password== password:
            session['user_id'] = user.id  # Save user ID in the session
            return jsonify({
                        'msg': f'login successful', 
                        'status': 'success', 
                        'user': {
                            'id': user.id,
                            'name': user.name,
                            'email': user.email
                        }
                    }), 200
        else:
            return jsonify({'msg': 'Invalid credentials or role', 'status': 'fail'}), 401

    @app.route('/register/user', methods=['POST'])
    def register_customer():
        data = request.form  

        # Extract data from the request
        name = data.get('name')
        email = data.get('email')
        mobile = data.get('mobile')
        username = data.get('username')
        password = data.get('password')
        address = data.get('address')
        pin = data.get('pin')   
        age=data.get('age')
        gender=data.get('gender')
        dob=data.get('dob')
        # Basic validation
        if not all([name, email, mobile, username, password, address, pin,age,gender,dob]):
            return jsonify({'msg': 'Missing required fields', 'status': 'fail'}), 400

        # Check if the username or email already exists
        existing_user = User.query.filter((User.username == username) | (User.email == email)).first()
        if existing_user:
            return jsonify({'msg': 'User with this email or username already exists', 'status': 'fail'}), 400


        # Create a new customer
        try:
            new_customer = User(
                name=name,
                email=email,
                mobile=mobile,
                username=username,
                password=password,
                address=address,
                pin=pin,
                age=age,
                gender=gender,
                dob=datetime.strptime(dob, "%Y-%m-%d").date() if dob else None
                )
            
            db.session.add(new_customer)
            db.session.commit()

            return jsonify({'msg': 'Customer registered successfully', 'status': 'success'}), 201

        except Exception as e:
            db.session.rollback()
            return jsonify({'msg': f'Error occurred: {str(e)}', 'status': 'fail'}), 500



    @app.route("/nearby-hospitals", methods=["POST"])
    def nearby_hospitals():
        data = request.json
        lat = data.get("latitude")
        lon = data.get("longitude")
        disease_type = "teeth"  # For now
        results = find_doctors_by_specialty(lat, lon, disease_type)
        return jsonify(results)

    @app.route("/nearby-pharmacies", methods=["POST"])
    def nearby_pharmacies():
        data = request.json
        lat = data.get("latitude")
        lon = data.get("longitude")
        results = find_pharmacies(lat, lon)
        return jsonify(results)

def find_doctors_by_specialty(lat, lon, disease_name, radius=5000):
    overpass_url = "http://overpass-api.de/api/interpreter"

    disease_specialty_map = {
        "heart": ["cardiology", "cardiologist"],
        "eye": ["ophthalmology", "eye"],
        "skin": ["dermatology", "skin"],
        "diabetes": ["endocrinology", "diabetes"],
        "bones": ["orthopedics", "orthopaedic"],
        "lungs": ["pulmonology", "chest"],
        "teeth": ["dentist", "dental"],
    }

    keywords = disease_specialty_map.get(disease_name.lower(), [disease_name.lower()])

    query = f"""
    [out:json];
    (
    node["healthcare:speciality"~"dermatology|skin"](around:{radius},{lat},{lon});
    node["speciality"~"dermatology|skin"](around:{radius},{lat},{lon});
    node["amenity"~"hospital|clinic|doctors"](around:{radius},{lat},{lon});
    );
    out center;
    """


    response = requests.get(overpass_url, params={'data': query})
    data = response.json()
    # print(data["elements"])
    matched_places = []
    for el in data["elements"]:
        tags = el.get("tags", {})
        name = tags.get("name", "Unnamed Facility")

        address_parts = [
            tags.get("addr:housenumber", ""),
            tags.get("addr:street", ""),
            tags.get("addr:city", ""),
            tags.get("addr:postcode", ""),
        ]
        full_address = ", ".join(part for part in address_parts if part)
        specialty = tags.get("healthcare:speciality", "") + tags.get("speciality", "")

        # print(keywords,name)
        if any(kw in specialty.lower() for kw in keywords) or any(kw in name.lower() for kw in keywords):
            matched_places.append({
                "name": name,
                "address": full_address or "Address not available",
                "lat": el.get("lat") or el.get("center", {}).get("lat"),
                "lon": el.get("lon") or el.get("center", {}).get("lon"),
            })
    # print(matched_places)
    return matched_places

def find_pharmacies(lat, lon, radius=10000):
    overpass_url = "http://overpass-api.de/api/interpreter"
    
    query = f"""
    [out:json];
    node["amenity"="pharmacy"](around:{radius},{lat},{lon});
    out center;
    """
    
    response = requests.get(overpass_url, params={'data': query})
    data = response.json()

    pharmacies = []
    for el in data["elements"]:
        tags = el.get("tags", {})
        name = tags.get("name", "Unnamed Pharmacy")

        address_parts = [
            tags.get("addr:housenumber", ""),
            tags.get("addr:street", ""),
            tags.get("addr:city", ""),
            tags.get("addr:postcode", ""),
        ]
        full_address = ", ".join(part for part in address_parts if part)
        
        pharmacies.append({
            "name": name,
            "address": full_address or "Address not available",
            "lat": el.get("lat") or el.get("center", {}).get("lat"),
            "lon": el.get("lon") or el.get("center", {}).get("lon"),
        })
    return pharmacies

# from app import app
