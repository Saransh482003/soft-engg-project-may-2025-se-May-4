# In a new file: routes_analytics.py
from flask import Flask, request, jsonify
from models import db, SymptomLogs
from sqlalchemy import func
from flasgger.utils import swag_from

def routes_analytics(app, db):
    # NOTE: These endpoints should be protected and only accessible to 'clinic' roles
    
    @app.route('/api/analytics/symptom-trends', methods=['GET'])
    @swag_from("docs/symptom_trends.yml")

    def get_symptom_trends():
        pincode = request.args.get('pincode')
        if not pincode:
            return jsonify({'error': 'Pincode is required for analysis'}), 400

        # Count occurrences of each symptom in the given pincode
        trends = db.session.query(
            SymptomLogs.symptom_term,
            func.count(SymptomLogs.symptom_term).label('count')
        ).filter_by(pincode=pincode).group_by(SymptomLogs.symptom_term).order_by(func.count(SymptomLogs.symptom_term).desc()).all()

        trend_data = [{'symptom': term, 'count': count} for term, count in trends]
        return jsonify({'pincode': pincode, 'trends': trend_data}), 200