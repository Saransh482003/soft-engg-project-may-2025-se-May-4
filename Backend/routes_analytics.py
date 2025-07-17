from flask import Flask, request, jsonify, session
from models import db, User, Roles, SymptomLogs
from sqlalchemy import func
from flasgger.utils import swag_from

def routes_analytics(app, db):

    @app.route('/api/analytics/symptom-trends', methods=['GET'])
    @swag_from("docs/symptom_trends.yml")
    def get_symptom_trends():
        if 'user_id' not in session:
            return jsonify({'error': 'Authentication required. Please log in.', 'status': 'fail'}), 401

        try:
            user = User.query.get(session['user_id'])
            if not user:
                return jsonify({'error': 'User not found.', 'status': 'fail'}), 404
            
            is_clinic_user = any(role.name == 'clinic' for role in user.roles)
            
            if not is_clinic_user:
                return jsonify({'error': 'Forbidden. You do not have permission to access this resource.', 'status': 'fail'}), 403

            pincode = request.args.get('pincode')
            if not pincode:
                return jsonify({'error': 'Pincode is required for analysis', 'status': 'fail'}), 400

            trends = db.session.query(
                SymptomLogs.symptom_term,
                func.count(SymptomLogs.symptom_term).label('count')
            ).filter_by(pincode=pincode).group_by(SymptomLogs.symptom_term).order_by(func.count(SymptomLogs.symptom_term).desc()).all()

            trend_data = [{'symptom': term, 'count': count} for term, count in trends]
            
            return jsonify({
                'pincode': pincode, 
                'trends': trend_data,
                'status': 'success'
            }), 200

        except Exception as e:
            return jsonify({'error': f'An unexpected error occurred: {str(e)}', 'status': 'fail'}), 500