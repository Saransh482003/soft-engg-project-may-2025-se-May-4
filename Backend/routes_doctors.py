from flask import Flask, request, jsonify
from models import db, Doctors, Hospitals
from flasgger.utils import swag_from
from modules.website_scraper import WebsiteScraper
import requests
import json

def routes_doctors(app, db):
    
    # Initialize website scraper with Groq AI integration
    # Get auth from the same source as other routes
    with open("authorisation.json", "r") as file:
        auth = json.loads(file.read())
    
    scraper = WebsiteScraper(api_key=auth.get("GROQ_API_KEY"))
    
    # Search for doctors, optionally filtering by specialization
    @app.route('/api/doctors/search', methods=['GET'])
    @swag_from("docs/search_doctors.yml")
    def search_doctors():
        specialization = request.args.get('specialization', '').strip()
        location = request.args.get('location', '').strip() # e.g., city or pincode

        query = Doctors.query

        if specialization:
            query = query.filter(Doctors.specialization.ilike(f'%{specialization}%'))

        doctors = query.all()
        doctor_list = [{
            'doctor_id': d.doctor_id,
            'name': d.name,
            'specialization': d.specialization,
            'experience': d.experience,
            'rating': float(d.rating) if d.rating else None,
            'hospital_name': d.hospital.hospital_name,
            'hospital_id': d.hospital_id,
            'hospital_address': d.hospital.address,
            'hospital_phone': d.hospital.phone,
            'hospital_rating': float(d.hospital.rating) if d.hospital.rating else None
        } for d in doctors]

        return jsonify({'doctors': doctor_list}), 200

    # Get detailed information about a specific doctor
    @app.route('/api/doctors/<int:doctor_id>', methods=['GET'])
    def get_doctor_details(doctor_id):
        try:
            doctor = Doctors.query.get(doctor_id)
            if not doctor:
                return jsonify({'error': 'Doctor not found'}), 404
            
            doctor_details = {
                'doctor_id': doctor.doctor_id,
                'name': doctor.name,
                'specialization': doctor.specialization,
                'experience': doctor.experience,
                'rating': float(doctor.rating) if doctor.rating else None,
                'num_ratings': doctor.num_rating,
                'hospital': {
                    'hospital_id': doctor.hospital.hospital_id,
                    'name': doctor.hospital.hospital_name,
                    'address': doctor.hospital.address,
                    'phone': doctor.hospital.phone,
                    'website': doctor.hospital.website,
                    'rating': float(doctor.hospital.rating) if doctor.hospital.rating else None,
                    'type': doctor.hospital.type,
                    'coordinates': {
                        'latitude': float(doctor.hospital.latitudes) if doctor.hospital.latitudes else None,
                        'longitude': float(doctor.hospital.longitudes) if doctor.hospital.longitudes else None
                    }
                }
            }
            
            return jsonify(doctor_details), 200
        except Exception as e:
            return jsonify({'error': f'Failed to fetch doctor details: {str(e)}'}), 500

    # Get detailed hospital information
    @app.route('/api/hospitals/<int:hospital_id>', methods=['GET'])
    def get_hospital_details(hospital_id):
        try:
            hospital = Hospitals.query.get(hospital_id)
            if not hospital:
                return jsonify({'error': 'Hospital not found'}), 404
            
            # Get all doctors in this hospital
            hospital_doctors = Doctors.query.filter_by(hospital_id=hospital_id).all()
            
            hospital_details = {
                'hospital_id': hospital.hospital_id,
                'name': hospital.hospital_name,
                'address': hospital.address,
                'phone': hospital.phone,
                'website': hospital.website,
                'rating': float(hospital.rating) if hospital.rating else None,
                'num_ratings': hospital.num_rating,
                'type': hospital.type,
                'coordinates': {
                    'latitude': float(hospital.latitudes) if hospital.latitudes else None,
                    'longitude': float(hospital.longitudes) if hospital.longitudes else None
                },
                'doctors': [{
                    'doctor_id': d.doctor_id,
                    'name': d.name,
                    'specialization': d.specialization,
                    'experience': d.experience,
                    'rating': float(d.rating) if d.rating else None
                } for d in hospital_doctors],
                'total_doctors': len(hospital_doctors),
                'specializations': list(set([d.specialization for d in hospital_doctors if d.specialization]))
            }
            
            return jsonify(hospital_details), 200
        except Exception as e:
            return jsonify({'error': f'Failed to fetch hospital details: {str(e)}'}), 500

    # Scrape doctor information from hospital website
    @app.route('/api/hospitals/<int:hospital_id>/scrape-doctors', methods=['POST'])
    def scrape_hospital_doctors(hospital_id):
        try:
            hospital = Hospitals.query.get(hospital_id)
            if not hospital:
                return jsonify({'error': 'Hospital not found'}), 404
            
            if not hospital.website:
                return jsonify({'error': 'Hospital website not available'}), 400
            
            # Scrape doctor information from hospital website
            scraped_doctors = scraper.scrape_doctor_info(hospital.website)
            
            if not scraped_doctors:
                # Try to find doctor pages first
                doctor_pages = scraper.find_doctor_page_links(hospital.website)
                all_doctors = []
                for page in doctor_pages[:5]:  # Limit to first 5 pages to avoid timeout
                    page_doctors = scraper.scrape_doctor_info(page)
                    all_doctors.extend(page_doctors)
                scraped_doctors = all_doctors
            
            # Also scrape hospital information
            hospital_info = scraper.scrape_hospital_info(hospital.website)
            
            result = {
                'hospital_id': hospital_id,
                'hospital_name': hospital.hospital_name,
                'scraped_doctors': scraped_doctors,
                'hospital_info': hospital_info,
                'total_scraped': len(scraped_doctors)
            }
            
            return jsonify(result), 200
            
        except Exception as e:
            return jsonify({'error': f'Failed to scrape doctors: {str(e)}'}), 500

    # Find doctors by specialization using web scraping
    @app.route('/api/doctors/find-by-specialization', methods=['POST'])
    @swag_from("docs/find_doctors_by_specialization.yml")
    def find_doctors_by_specialization():
        try:
            data = request.get_json()
            specialization = data.get('specialization', '').strip()
            hospital_website = data.get('hospital_website', '').strip()
            
            if not specialization:
                return jsonify({'error': 'Specialization is required'}), 400
            
            if not hospital_website:
                return jsonify({'error': 'Hospital website URL is required'}), 400
            
            # Find doctors with the specified specialization
            specialized_doctors = scraper.find_doctors_by_specialization(hospital_website, specialization)
            
            # Also get hospital information
            hospital_info = scraper.scrape_hospital_info(hospital_website)
            
            result = {
                'specialization': specialization,
                'hospital_website': hospital_website,
                'hospital_info': hospital_info,
                'doctors': specialized_doctors,
                'total_found': len(specialized_doctors)
            }
            
            return jsonify(result), 200
            
        except Exception as e:
            return jsonify({'error': f'Failed to find doctors: {str(e)}'}), 500

    # Get hospital departments using web scraping
    @app.route('/api/hospitals/departments', methods=['POST'])
    @swag_from("docs/get_hospital_departments.yml")
    def get_hospital_departments():
        try:
            data = request.get_json()
            hospital_website = data.get('hospital_website', '').strip()
            
            if not hospital_website:
                return jsonify({'error': 'Hospital website URL is required'}), 400
            
            # Get hospital departments
            departments = scraper.get_hospital_departments(hospital_website)
            
            # Get hospital basic info
            hospital_info = scraper.scrape_hospital_info(hospital_website)
            
            result = {
                'hospital_website': hospital_website,
                'hospital_info': hospital_info,
                'departments': departments,
                'total_departments': len(departments)
            }
            
            return jsonify(result), 200
            
        except Exception as e:
            return jsonify({'error': f'Failed to get departments: {str(e)}'}), 500

    # Enhanced search with hospital information
    @app.route('/api/doctors/enhanced-search', methods=['GET'])
    @swag_from("docs/enhanced_doctor_search.yml")
    def enhanced_doctor_search():
        try:
            specialization = request.args.get('specialization', '').strip()
            location = request.args.get('location', '').strip()
            hospital_type = request.args.get('hospital_type', '').strip()
            min_rating = request.args.get('min_rating', type=float)
            max_distance = request.args.get('max_distance', type=float)
            
            query = db.session.query(Doctors).join(Hospitals)
            
            if specialization:
                query = query.filter(Doctors.specialization.ilike(f'%{specialization}%'))
            
            if hospital_type:
                query = query.filter(Hospitals.type.ilike(f'%{hospital_type}%'))
            
            if min_rating:
                query = query.filter(Doctors.rating >= min_rating)
            
            doctors = query.all()
            
            enhanced_doctor_list = []
            for doctor in doctors:
                doctor_data = {
                    'doctor_id': doctor.doctor_id,
                    'name': doctor.name,
                    'specialization': doctor.specialization,
                    'experience': doctor.experience,
                    'rating': float(doctor.rating) if doctor.rating else None,
                    'num_ratings': doctor.num_rating,
                    'hospital': {
                        'hospital_id': doctor.hospital.hospital_id,
                        'name': doctor.hospital.hospital_name,
                        'address': doctor.hospital.address,
                        'phone': doctor.hospital.phone,
                        'website': doctor.hospital.website,
                        'rating': float(doctor.hospital.rating) if doctor.hospital.rating else None,
                        'type': doctor.hospital.type,
                        'coordinates': {
                            'latitude': float(doctor.hospital.latitudes) if doctor.hospital.latitudes else None,
                            'longitude': float(doctor.hospital.longitudes) if doctor.hospital.longitudes else None
                        }
                    }
                }
                enhanced_doctor_list.append(doctor_data)
            
            return jsonify({
                'doctors': enhanced_doctor_list,
                'total_results': len(enhanced_doctor_list),
                'search_criteria': {
                    'specialization': specialization,
                    'location': location,
                    'hospital_type': hospital_type,
                    'min_rating': min_rating
                }
            }), 200
            
        except Exception as e:
            return jsonify({'error': f'Search failed: {str(e)}'}), 500
            
    # AI-powered doctor and hospital extraction
    @app.route('/api/hospitals/ai-extract', methods=['POST'])
    @swag_from("docs/ai_extract_hospital.yml")
    def ai_extract_hospital_info():
        """Use Groq AI to extract comprehensive hospital and doctor information from HTML"""
        try:
            data = request.get_json()
            hospital_website = data.get('hospital_website', '').strip()
            extract_doctors = data.get('extract_doctors', True)
            specialization_filter = data.get('specialization', '')
            
            if not hospital_website:
                return jsonify({'error': 'Hospital website URL is required'}), 400
            
            # Fetch the HTML content
            try:
                response = requests.get(hospital_website, headers=scraper.headers, timeout=15)
                response.raise_for_status()
                html_content = response.text
            except Exception as e:
                return jsonify({'error': f'Failed to fetch website: {str(e)}'}), 400
            
            result = {
                'hospital_website': hospital_website,
                'extraction_method': 'groq_ai' if scraper.groq_client else 'traditional',
                'hospital_info': None,
                'doctors': [],
                'total_doctors': 0
            }
            
            # Extract hospital information using Groq AI
            if scraper.groq_client:
                hospital_info = scraper.extract_hospital_info_with_groq(html_content)
                result['hospital_info'] = hospital_info
                
                # Extract doctors if requested
                if extract_doctors:
                    doctors = scraper.extract_doctors_with_groq(html_content, specialization_filter)
                    result['doctors'] = doctors
                    result['total_doctors'] = len(doctors)
            else:
                # Fallback to traditional methods
                hospital_info = scraper._fallback_extract_hospital_info(html_content)
                result['hospital_info'] = hospital_info
                
                if extract_doctors:
                    doctors = scraper._fallback_extract_doctors(html_content, specialization_filter)
                    result['doctors'] = doctors
                    result['total_doctors'] = len(doctors)
            
            return jsonify(result), 200
            
        except Exception as e:
            return jsonify({'error': f'AI extraction failed: {str(e)}'}), 500