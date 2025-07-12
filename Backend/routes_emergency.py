from flask import Flask, request, jsonify, session
from models import db, EmergencyContacts
from flasgger.utils import swag_from

def routes_emergency(app, db):
    @app.route('/api/emergency-contacts', methods=['POST'])
    @swag_from("docs/add_emergency_contact.yml")
    def add_emergency_contact():
        user_id = session.get('user_id')
        if not user_id:
            return jsonify({'error': 'Not authenticated'}), 401

        data = request.get_json()
        if not data.get('contact_name') or not data.get('contact_number'):
            return jsonify({'error': 'Contact name and number are required'}), 400

        new_contact = EmergencyContacts(
            user_id=user_id,
            contact_name=data['contact_name'],
            contact_number=data['contact_number'],
            relation=data.get('relation')
        )
        db.session.add(new_contact)
        db.session.commit()
        return jsonify({'message': 'Emergency contact added'}), 201

    @app.route('/api/emergency-contacts', methods=['GET'])
    @swag_from("docs/get_emergency_contacts.yml")
    def get_emergency_contacts():
        user_id = session.get('user_id')
        if not user_id:
            return jsonify({'error': 'Not authenticated'}), 401

        contacts = EmergencyContacts.query.filter_by(user_id=user_id).all()
        contact_list = [{
            'contact_id': c.emergency_contact_id,
            'name': c.contact_name,
            'number': c.contact_number,
            'relation': c.relation
        } for c in contacts]
        return jsonify({'contacts': contact_list}), 200