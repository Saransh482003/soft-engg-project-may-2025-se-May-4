from flask import Flask, request, jsonify
from models import db, Doctors
from flasgger.utils import swag_from

def routes_doctors(app, db):
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
            'hospital_name': d.hospital.hospital_name
        } for d in doctors]

        return jsonify({'doctors': doctor_list}), 200