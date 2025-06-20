import requests
from flask import Flask, request, redirect, send_from_directory,render_template, url_for, session,abort,flash,jsonify
from models import *
from modules.chatbot import get_chatbot_response
from datetime import datetime
import uuid

def routes_user(app, db, auth):
    @app.route('/api/users', methods=['POST'])
    def create_user():
        try:
            data = request.get_json()
            required_fields = ['user_name', 'password', 'email', 'mobile','gender', 'dob']
            for field in required_fields:
                if not data.get(field):
                    return jsonify({'error': f'{field} is required', 'status': 'fail'}), 400
            
            # Check if user already exists
            existing_user = User.query.filter(
                (User.user_name == data['user_name']) &
                (User.email == data['email']) &
                (User.mobile == data['mobile'])
            ).first()
            
            if existing_user:
                return jsonify({'error': 'User with this username, email or mobile already exists', 'status': 'fail'}), 409
            
            # Create new user
            new_user = User(
                user_id=str(uuid.uuid4()),
                user_name=data['user_name'],
                password=data['password'],  # In production, hash this password
                email=data['email'],
                mobile=data['mobile'],
                gender=data.get('gender'),
                dob=datetime.strptime(data['dob'], "%Y-%m-%d").date() if data.get('dob') else None
            )
            
            db.session.add(new_user)
            db.session.commit()
            
            return jsonify({
                'message': 'User created successfully',
                'status': 'success',
                'user': {
                    'user_id': new_user.user_id,
                    'user_name': new_user.user_name,
                    'email': new_user.email,
                    'mobile': new_user.mobile,
                    'gender': new_user.gender,
                    'dob': new_user.dob.isoformat() if new_user.dob else None
                }
            }), 201
            
        except ValueError as e:
            return jsonify({'error': 'Invalid date format. Use YYYY-MM-DD', 'status': 'fail'}), 400
        except Exception as e:
            db.session.rollback()
            return jsonify({'error': f'Error creating user: {str(e)}', 'status': 'fail'}), 500
    
    # READ - Get all users
    @app.route('/api/users', methods=['GET'])
    def get_all_users():
        try:
            page = request.args.get('page', 1, type=int)
            per_page = request.args.get('per_page', 10, type=int)
            
            users = User.query.paginate(
                page=page, 
                per_page=per_page, 
                error_out=False
            )
            
            users_list = []
            for user in users.items:
                users_list.append({
                    'user_id': user.user_id,
                    'user_name': user.user_name,
                    'email': user.email,
                    'mobile': user.mobile,
                    'gender': user.gender,
                    'dob': user.dob.isoformat() if user.dob else None
                })
            
            return jsonify({
                'users': users_list,
                'pagination': {
                    'page': users.page,
                    'pages': users.pages,
                    'per_page': users.per_page,
                    'total': users.total
                },
                'status': 'success'
            }), 200
            
        except Exception as e:
            return jsonify({'error': f'Error fetching users: {str(e)}', 'status': 'fail'}), 500
    
    # READ - Get user by ID
    @app.route('/api/users/<string:user_id>', methods=['GET'])
    def get_user_by_id(user_id):
        try:
            user = User.query.filter_by(user_id=user_id).first()
            
            if not user:
                return jsonify({'error': 'User not found', 'status': 'fail'}), 404
            
            return jsonify({
                'user': {
                    'user_id': user.user_id,
                    'user_name': user.user_name,
                    'email': user.email,
                    'mobile': user.mobile,
                    'gender': user.gender,
                    'dob': user.dob.isoformat() if user.dob else None
                },
                'status': 'success'
            }), 200
            
        except Exception as e:
            return jsonify({'error': f'Error fetching user: {str(e)}', 'status': 'fail'}), 500
    
    # READ - Search users by username or email
    @app.route('/api/users/search', methods=['GET'])
    def search_users():
        try:
            query = request.args.get('q', '').strip()
            if not query:
                return jsonify({'error': 'Search query is required', 'status': 'fail'}), 400
            
            users = User.query.filter(
                (User.user_name.contains(query)) | 
                (User.email.contains(query))
            ).all()
            
            users_list = []
            for user in users:
                users_list.append({
                    'user_id': user.user_id,
                    'user_name': user.user_name,
                    'email': user.email,
                    'mobile': user.mobile,
                    'gender': user.gender,
                    'dob': user.dob.isoformat() if user.dob else None
                })
            
            return jsonify({
                'users': users_list,
                'count': len(users_list),
                'status': 'success'
            }), 200
            
        except Exception as e:
            return jsonify({'error': f'Error searching users: {str(e)}', 'status': 'fail'}), 500
    
    # UPDATE - Update user by ID
    @app.route('/api/users/<string:user_id>', methods=['PUT'])
    def update_user(user_id):
        try:
            user = User.query.filter_by(user_id=user_id).first()
            
            if not user:
                return jsonify({'error': 'User not found', 'status': 'fail'}), 404
            
            data = request.get_json()
            
            # Check if email or mobile is being changed and already exists
            if 'email' in data and data['email'] != user.email:
                existing_email = User.query.filter_by(email=data['email']).first()
                if existing_email:
                    return jsonify({'error': 'Email already exists', 'status': 'fail'}), 409
            
            if 'mobile' in data and data['mobile'] != user.mobile:
                existing_mobile = User.query.filter_by(mobile=data['mobile']).first()
                if existing_mobile:
                    return jsonify({'error': 'Mobile number already exists', 'status': 'fail'}), 409
            
            if 'user_name' in data and data['user_name'] != user.user_name:
                existing_username = User.query.filter_by(user_name=data['user_name']).first()
                if existing_username:
                    return jsonify({'error': 'Username already exists', 'status': 'fail'}), 409
            
            # Update fields
            if 'user_name' in data:
                user.user_name = data['user_name']
            if 'password' in data:
                user.password = data['password']  # In production, hash this password
            if 'email' in data:
                user.email = data['email']
            if 'mobile' in data:
                user.mobile = data['mobile']
            if 'gender' in data:
                user.gender = data['gender']
            if 'dob' in data:
                if data['dob']:
                    user.dob = datetime.strptime(data['dob'], "%Y-%m-%d").date()
                else:
                    user.dob = None
            
            db.session.commit()
            
            return jsonify({
                'message': 'User updated successfully',
                'status': 'success',
                'user': {
                    'user_id': user.user_id,
                    'user_name': user.user_name,
                    'email': user.email,
                    'mobile': user.mobile,
                    'gender': user.gender,
                    'dob': user.dob.isoformat() if user.dob else None
                }
            }), 200
            
        except ValueError as e:
            return jsonify({'error': 'Invalid date format. Use YYYY-MM-DD', 'status': 'fail'}), 400
        except Exception as e:
            db.session.rollback()
            return jsonify({'error': f'Error updating user: {str(e)}', 'status': 'fail'}), 500
    
    # UPDATE - Partial update user by ID
    @app.route('/api/users/<string:user_id>', methods=['PATCH'])
    def partial_update_user(user_id):
        try:
            user = User.query.filter_by(user_id=user_id).first()
            
            if not user:
                return jsonify({'error': 'User not found', 'status': 'fail'}), 404
            
            data = request.get_json()
            
            # Only update provided fields
            for key, value in data.items():
                if key == 'user_id':
                    continue  # Don't allow updating user_id
                elif key == 'dob' and value:
                    user.dob = datetime.strptime(value, "%Y-%m-%d").date()
                elif key == 'dob' and not value:
                    user.dob = None
                elif hasattr(user, key):
                    # Check for uniqueness for email, mobile, user_name
                    if key in ['email', 'mobile', 'user_name'] and value != getattr(user, key):
                        existing = User.query.filter(getattr(User, key) == value).first()
                        if existing:
                            return jsonify({'error': f'{key} already exists', 'status': 'fail'}), 409
                    setattr(user, key, value)
            
            db.session.commit()
            
            return jsonify({
                'message': 'User updated successfully',
                'status': 'success',
                'user': {
                    'user_id': user.user_id,
                    'user_name': user.user_name,
                    'email': user.email,
                    'mobile': user.mobile,
                    'gender': user.gender,
                    'dob': user.dob.isoformat() if user.dob else None
                }
            }), 200
            
        except ValueError as e:
            return jsonify({'error': 'Invalid date format. Use YYYY-MM-DD', 'status': 'fail'}), 400
        except Exception as e:
            db.session.rollback()
            return jsonify({'error': f'Error updating user: {str(e)}', 'status': 'fail'}), 500
    
    # DELETE - Delete user by ID
    @app.route('/api/users/<string:user_id>', methods=['DELETE'])
    def delete_user(user_id):
        try:
            user = User.query.filter_by(user_id=user_id).first()
            
            if not user:
                return jsonify({'error': 'User not found', 'status': 'fail'}), 404
            
            db.session.delete(user)
            db.session.commit()
            
            return jsonify({
                'message': 'User deleted successfully',
                'status': 'success'
            }), 200
            
        except Exception as e:
            db.session.rollback()
            return jsonify({'error': f'Error deleting user: {str(e)}', 'status': 'fail'}), 500
    
    # User authentication endpoints
    @app.route('/api/users/login', methods=['POST'])
    def user_login():
        try:
            data = request.get_json()
            
            if not data.get('user_name') or not data.get('password'):
                return jsonify({'error': 'Username and password are required', 'status': 'fail'}), 400
            
            user = User.query.filter_by(user_name=data['user_name']).first()
            
            if not user or user.password != data['password']:  # In production, use proper password hashing
                return jsonify({'error': 'Invalid credentials', 'status': 'fail'}), 401
            
            # Store user session
            session['user_id'] = user.user_id
            session['user_name'] = user.user_name
            
            return jsonify({
                'message': 'Login successful',
                'status': 'success',
                'user': {
                    'user_id': user.user_id,
                    'user_name': user.user_name,
                    'email': user.email,
                    'mobile': user.mobile,
                    'gender': user.gender,
                    'dob': user.dob.isoformat() if user.dob else None
                }
            }), 200
            
        except Exception as e:
            return jsonify({'error': f'Login error: {str(e)}', 'status': 'fail'}), 500
    
    @app.route('/api/users/logout', methods=['POST'])
    def user_logout():
        try:
            session.clear()
            return jsonify({
                'message': 'Logout successful',
                'status': 'success'
            }), 200
            
        except Exception as e:
            return jsonify({'error': f'Logout error: {str(e)}', 'status': 'fail'}), 500
    
    # Get current user info (requires session)
    @app.route('/api/users/me', methods=['GET'])
    def get_current_user():
        try:
            if 'user_id' not in session:
                return jsonify({'error': 'Not authenticated', 'status': 'fail'}), 401
            
            user = User.query.filter_by(user_id=session['user_id']).first()
            
            if not user:
                session.clear()  # Clear invalid session
                return jsonify({'error': 'User not found', 'status': 'fail'}), 404
            
            return jsonify({
                'user': {
                    'user_id': user.user_id,
                    'user_name': user.user_name,
                    'email': user.email,
                    'mobile': user.mobile,
                    'gender': user.gender,
                    'dob': user.dob.isoformat() if user.dob else None
                },
                'status': 'success'
            }), 200
            
        except Exception as e:
            return jsonify({'error': f'Error fetching current user: {str(e)}', 'status': 'fail'}), 500
