from flask import request, jsonify, session
from models import db, Reminders, Medicines
from datetime import datetime
from flasgger.utils import swag_from

def routes_reminders(app, db):
    """
    Defines the routes for reminder management.
    """

    @app.route('/api/reminders', methods=['POST'])
    @swag_from("docs/create_reminder.yml")
    def create_reminder():
        """
        Creates a new reminder for the currently logged-in user.
        """
        user_id = session.get('user_id')
        if not user_id:
            return jsonify({'error': 'Not authenticated', 'status': 'fail'}), 401

        data = request.get_json()
        required_fields = ['medicine_name', 'time_of_day', 'frequency']
        if not all(field in data for field in required_fields):
            return jsonify({'error': 'Missing required fields (medicine_name, time_of_day, frequency)', 'status': 'fail'}), 400

        try:
            # Find an existing medicine or create a new one to avoid duplicates
            medicine = Medicines.query.filter_by(name=data['medicine_name']).first()
            if not medicine:
                medicine = Medicines(name=data['medicine_name'], dosage=data.get('dosage'))
                db.session.add(medicine)
                # Commit here to get a medicine_id for the new reminder
                db.session.commit()

            new_reminder = Reminders(
                user_id=user_id,
                medicine_id=medicine.medicine_id,
                time_of_day=data['time_of_day'],
                relation_to_meal=data.get('relation_to_meal'),
                frequency=data['frequency'],
                notification_type=data.get('notification_type', 'sms'),
                is_active=data.get('is_active', True)
            )
            
            db.session.add(new_reminder)
            db.session.commit()
            
            return jsonify({
                'message': 'Reminder created successfully',
                'status': 'success',
                'reminder_id': new_reminder.reminder_id
            }), 201

        except Exception as e:
            db.session.rollback()
            return jsonify({'error': f'Error creating reminder: {str(e)}', 'status': 'fail'}), 500

    @app.route('/api/reminders', methods=['GET'])
    @swag_from("docs/get_reminders.yml")
    def get_reminders():
        """
        Gets all reminders for the currently logged-in user.
        """
        user_id = session.get('user_id')
        if not user_id:
            return jsonify({'error': 'Not authenticated', 'status': 'fail'}), 401

        try:
            reminders = Reminders.query.filter_by(user_id=user_id).order_by(Reminders.time_of_day).all()
            reminders_list = []
            for r in reminders:
                reminders_list.append({
                    'reminder_id': r.reminder_id,
                    'medicine_name': r.medicine.name,
                    'dosage': r.medicine.dosage,
                    'time_of_day': r.time_of_day,
                    'frequency': r.frequency,
                    'relation_to_meal': r.relation_to_meal,
                    'is_active': r.is_active
                })
            return jsonify({'status': 'success', 'reminders': reminders_list}), 200
        
        except Exception as e:
            return jsonify({'error': f'Error fetching reminders: {str(e)}', 'status': 'fail'}), 500
            
    @app.route('/api/reminders/<int:reminder_id>', methods=['GET'])
    @swag_from("docs/get_reminder_by_id.yml")
    def get_reminder_by_id(reminder_id):
        """
        Gets a single reminder by its ID.
        """
        user_id = session.get('user_id')
        if not user_id:
            return jsonify({'error': 'Not authenticated', 'status': 'fail'}), 401
            
        try:
            reminder = Reminders.query.filter_by(reminder_id=reminder_id, user_id=user_id).first()
            
            if not reminder:
                return jsonify({'error': 'Reminder not found or access denied', 'status': 'fail'}), 404
                
            return jsonify({
                'status': 'success',
                'reminder': {
                    'reminder_id': reminder.reminder_id,
                    'medicine_name': reminder.medicine.name,
                    'dosage': reminder.medicine.dosage,
                    'time_of_day': reminder.time_of_day,
                    'frequency': reminder.frequency,
                    'relation_to_meal': reminder.relation_to_meal,
                    'is_active': reminder.is_active
                }
            }), 200
            
        except Exception as e:
            return jsonify({'error': f'Error fetching reminder: {str(e)}', 'status': 'fail'}), 500

    @app.route('/api/reminders/<int:reminder_id>', methods=['PUT'])
    @swag_from("docs/update_reminder.yml")
    def update_reminder(reminder_id):
        """
        Updates a specific reminder for the logged-in user.
        """
        user_id = session.get('user_id')
        if not user_id:
            return jsonify({'error': 'Not authenticated', 'status': 'fail'}), 401

        try:
            # Find the reminder and ensure it belongs to the logged-in user
            reminder = Reminders.query.filter_by(reminder_id=reminder_id, user_id=user_id).first()

            if not reminder:
                return jsonify({'error': 'Reminder not found or access denied', 'status': 'fail'}), 404

            data = request.get_json()

            # Update fields if they exist in the request body
            if 'medicine_name' in data:
                medicine = Medicines.query.filter_by(name=data['medicine_name']).first()
                if not medicine:
                    medicine = Medicines(name=data['medicine_name'], dosage=data.get('dosage'))
                    db.session.add(medicine)
                    db.session.commit()
                reminder.medicine_id = medicine.medicine_id
            
            if 'time_of_day' in data:
                reminder.time_of_day = data['time_of_day']
            if 'frequency' in data:
                reminder.frequency = data['frequency']
            if 'relation_to_meal' in data:
                reminder.relation_to_meal = data['relation_to_meal']
            if 'is_active' in data:
                reminder.is_active = data['is_active']
            if 'notification_type' in data:
                reminder.notification_type = data['notification_type']

            db.session.commit()

            return jsonify({'message': 'Reminder updated successfully', 'status': 'success'}), 200

        except Exception as e:
            db.session.rollback()
            return jsonify({'error': f'Error updating reminder: {str(e)}', 'status': 'fail'}), 500

    @app.route('/api/reminders/<int:reminder_id>', methods=['DELETE'])
    @swag_from("docs/delete_reminder.yml")
    def delete_reminder(reminder_id):
        """
        Deletes a specific reminder for the logged-in user.
        """
        user_id = session.get('user_id')
        if not user_id:
            return jsonify({'error': 'Not authenticated', 'status': 'fail'}), 401

        try:
            # Find the reminder and ensure it belongs to the logged-in user
            reminder = Reminders.query.filter_by(reminder_id=reminder_id, user_id=user_id).first()

            if not reminder:
                return jsonify({'error': 'Reminder not found or access denied', 'status': 'fail'}), 404

            # Before deleting the reminder, consider if you need to delete related logs
            # For example: MedicineLogs.query.filter_by(reminder_id=reminder_id).delete()
            
            db.session.delete(reminder)
            db.session.commit()

            return jsonify({'message': 'Reminder deleted successfully', 'status': 'success'}), 200

        except Exception as e:
            db.session.rollback()
            return jsonify({'error': f'Error deleting reminder: {str(e)}', 'status': 'fail'}), 500