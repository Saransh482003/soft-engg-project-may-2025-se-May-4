from flask import request, jsonify
from models import YogaAsana, YogaAsanaImages, db
from flasgger.utils import swag_from
import json


def asana_routes(app):
    
    @app.route('/api/asanas', methods=['POST'])
    @swag_from("docs/create_asana.yml")
    def create_asana():
        """
        Create a new yoga asana.
        Accepts JSON data with asana details and optionally initial images.
        
        Returns:
            JSON response with created asana details or error message.
        """
        try:
            data = request.get_json()
            
            # Validate required fields
            if not data.get('name'):
                return jsonify({'error': 'Asana name is required', 'status': 'fail'}), 400
            
            # Create new asana
            new_asana = YogaAsana(
                name=data.get('name'),
                sanskrit_name=data.get('sanskrit_name'),
                description=data.get('description'),
                difficulty=data.get('difficulty', 'Beginner'),
                duration_minutes=data.get('duration_minutes'),
                benefits=data.get('benefits'),
                instructions=data.get('instructions')
            )
            
            # Add to database
            db.session.add(new_asana)
            db.session.flush()  # Get the asana_id
            
            # Add initial images if provided
            images = data.get('images', [])
            if images:
                for idx, image_data in enumerate(images):
                    if isinstance(image_data, str):
                        # Simple URL string
                        new_image = YogaAsanaImages(
                            asana_id=new_asana.asana_id,
                            image_url=image_data,
                            display_order=idx + 1
                        )
                    elif isinstance(image_data, dict):
                        # Detailed image object
                        new_image = YogaAsanaImages(
                            asana_id=new_asana.asana_id,
                            image_url=image_data.get('image_url'),
                            display_order=image_data.get('display_order', idx + 1)
                        )
                    else:
                        continue
                    
                    db.session.add(new_image)
            
            db.session.commit()
            
            return jsonify({
                'message': 'Asana created successfully',
                'asana': new_asana.to_dict(),
                'status': 'success'
            }), 201
            
        except Exception as e:
            db.session.rollback()
            return jsonify({'error': f'Error creating asana: {str(e)}', 'status': 'fail'}), 500
    
    
    @app.route('/api/asanas/<int:asana_id>/images', methods=['POST'])
    @swag_from("docs/add_asana_images.yml")
    def add_asana_images(asana_id):
        """
        Add images to an existing yoga asana.
        
        Args:
            asana_id (int): ID of the asana to add images to
            
        Returns:
            JSON response with updated asana details or error message.
        """
        try:
            # Check if asana exists
            asana = YogaAsana.query.get(asana_id)
            if not asana:
                return jsonify({'error': 'Asana not found', 'status': 'fail'}), 404
            
            data = request.get_json()
            images = data.get('images', [])
            
            if not images:
                return jsonify({'error': 'No images provided', 'status': 'fail'}), 400
            
            # Get the current max display order
            current_max_order = db.session.query(db.func.max(YogaAsanaImages.display_order))\
                .filter_by(asana_id=asana_id).scalar() or 0
            
            added_images = []
            for idx, image_data in enumerate(images):
                if isinstance(image_data, str):
                    # Simple URL string
                    new_image = YogaAsanaImages(
                        asana_id=asana_id,
                        image_url=image_data,
                        display_order=current_max_order + idx + 1
                    )
                elif isinstance(image_data, dict):
                    # Detailed image object
                    new_image = YogaAsanaImages(
                        asana_id=asana_id,
                        image_url=image_data.get('image_url'),
                        display_order=image_data.get('display_order', current_max_order + idx + 1)
                    )
                else:
                    continue
                
                if new_image.image_url:  # Only add if URL is provided
                    db.session.add(new_image)
                    added_images.append(new_image)
            
            db.session.commit()
            
            return jsonify({
                'message': f'{len(added_images)} images added successfully',
                'asana': asana.to_dict(),
                'status': 'success'
            }), 200
            
        except Exception as e:
            db.session.rollback()
            return jsonify({'error': f'Error adding images: {str(e)}', 'status': 'fail'}), 500
    
    
    @app.route('/api/asanas', methods=['GET'])
    @swag_from("docs/get_asanas.yml")
    def get_asanas():
        """
        Get all yoga asanas with optional filtering and search.
        
        Query Parameters:
            name (str): Filter by asana name (partial match)
            sanskrit_name (str): Filter by sanskrit name (partial match)
            difficulty (str): Filter by difficulty level (partial match)
            duration_min (int): Minimum duration in minutes
            duration_max (int): Maximum duration in minutes
            search (str): General search across name, sanskrit_name, description, and benefits
            limit (int): Maximum number of results to return
            offset (int): Number of results to skip (for pagination)
            
        Returns:
            JSON response with list of asanas.
        """
        try:
            # Get query parameters
            name = request.args.get('name')
            sanskrit_name = request.args.get('sanskrit_name')
            difficulty = request.args.get('difficulty')
            duration_min = request.args.get('duration_min', type=int)
            duration_max = request.args.get('duration_max', type=int)
            search = request.args.get('search')
            limit = request.args.get('limit', type=int)
            offset = request.args.get('offset', type=int, default=0)
            
            # Build query
            query = YogaAsana.query
            
            # Apply filters
            if name:
                query = query.filter(YogaAsana.name.ilike(f'%{name}%'))
            
            if sanskrit_name:
                query = query.filter(YogaAsana.sanskrit_name.ilike(f'%{sanskrit_name}%'))
            
            if difficulty:
                query = query.filter(YogaAsana.difficulty.ilike(f'%{difficulty}%'))
            
            if duration_min:
                query = query.filter(YogaAsana.duration_minutes >= duration_min)
            
            if duration_max:
                query = query.filter(YogaAsana.duration_minutes <= duration_max)
            
            # General search across multiple fields
            if search:
                search_term = f'%{search}%'
                query = query.filter(
                    db.or_(
                        YogaAsana.name.ilike(search_term),
                        YogaAsana.sanskrit_name.ilike(search_term),
                        YogaAsana.description.ilike(search_term),
                        YogaAsana.benefits.ilike(search_term),
                        YogaAsana.difficulty.ilike(search_term)
                    )
                )
            
            # Get total count for pagination info
            total_count = query.count()
            
            # Apply pagination
            if limit:
                query = query.limit(limit)
            if offset:
                query = query.offset(offset)
            
            # Execute query
            asanas = query.all()
            
            return jsonify({
                'asanas': [asana.to_dict() for asana in asanas],
                'count': len(asanas),
                'total_count': total_count,
                'offset': offset,
                'limit': limit,
                'status': 'success'
            }), 200
            
        except Exception as e:
            return jsonify({'error': f'Error retrieving asanas: {str(e)}', 'status': 'fail'}), 500
    
    
    @app.route('/api/asanas/<int:asana_id>', methods=['GET'])
    @swag_from("docs/get_asana_by_id.yml")
    def get_asana_by_id(asana_id):
        """
        Get a specific yoga asana by ID.
        
        Args:
            asana_id (int): ID of the asana to retrieve
            
        Returns:
            JSON response with asana details or error message.
        """
        try:
            asana = YogaAsana.query.get(asana_id)
            if not asana:
                return jsonify({'error': 'Asana not found', 'status': 'fail'}), 404
            
            return jsonify({
                'asana': asana.to_dict(),
                'status': 'success'
            }), 200
            
        except Exception as e:
            return jsonify({'error': f'Error retrieving asana: {str(e)}', 'status': 'fail'}), 500
    
    
    @app.route('/api/asanas/<int:asana_id>', methods=['PUT'])
    @swag_from("docs/update_asana.yml")
    def update_asana(asana_id):
        """
        Update an existing yoga asana.
        
        Args:
            asana_id (int): ID of the asana to update
            
        Returns:
            JSON response with updated asana details or error message.
        """
        try:
            asana = YogaAsana.query.get(asana_id)
            if not asana:
                return jsonify({'error': 'Asana not found', 'status': 'fail'}), 404
            
            data = request.get_json()
            
            # Update fields if provided
            if 'name' in data:
                asana.name = data['name']
            if 'sanskrit_name' in data:
                asana.sanskrit_name = data['sanskrit_name']
            if 'description' in data:
                asana.description = data['description']
            if 'difficulty' in data:
                asana.difficulty = data['difficulty']
            if 'duration_minutes' in data:
                asana.duration_minutes = data['duration_minutes']
            if 'benefits' in data:
                asana.benefits = data['benefits']
            if 'instructions' in data:
                asana.instructions = data['instructions']
            
            db.session.commit()
            
            return jsonify({
                'message': 'Asana updated successfully',
                'asana': asana.to_dict(),
                'status': 'success'
            }), 200
            
        except Exception as e:
            db.session.rollback()
            return jsonify({'error': f'Error updating asana: {str(e)}', 'status': 'fail'}), 500
    
    
    @app.route('/api/asanas/<int:asana_id>', methods=['DELETE'])
    @swag_from("docs/delete_asana.yml")
    def delete_asana(asana_id):
        """
        Delete a yoga asana and all its associated images.
        
        Args:
            asana_id (int): ID of the asana to delete
            
        Returns:
            JSON response confirming deletion or error message.
        """
        try:
            asana = YogaAsana.query.get(asana_id)
            if not asana:
                return jsonify({'error': 'Asana not found', 'status': 'fail'}), 404
            
            asana_name = asana.name
            db.session.delete(asana)  # Cascade will delete associated images
            db.session.commit()
            
            return jsonify({
                'message': f'Asana "{asana_name}" deleted successfully',
                'status': 'success'
            }), 200
            
        except Exception as e:
            db.session.rollback()
            return jsonify({'error': f'Error deleting asana: {str(e)}', 'status': 'fail'}), 500
    
    
    @app.route('/api/asanas/<int:asana_id>/images/<int:image_id>', methods=['DELETE'])
    @swag_from("docs/delete_asana_image.yml")
    def delete_asana_image(asana_id, image_id):
        """
        Delete a specific image from an asana.
        
        Args:
            asana_id (int): ID of the asana
            image_id (int): ID of the image to delete
            
        Returns:
            JSON response confirming deletion or error message.
        """
        try:
            # Check if asana exists
            asana = YogaAsana.query.get(asana_id)
            if not asana:
                return jsonify({'error': 'Asana not found', 'status': 'fail'}), 404
            
            # Check if image exists and belongs to this asana
            image = YogaAsanaImages.query.filter_by(
                image_id=image_id, 
                asana_id=asana_id
            ).first()
            
            if not image:
                return jsonify({'error': 'Image not found', 'status': 'fail'}), 404
            
            db.session.delete(image)
            db.session.commit()
            
            return jsonify({
                'message': 'Image deleted successfully',
                'status': 'success'
            }), 200
            
        except Exception as e:
            db.session.rollback()
            return jsonify({'error': f'Error deleting image: {str(e)}', 'status': 'fail'}), 500
    
    
    @app.route('/api/asanas/search', methods=['GET'])
    @swag_from("docs/search_asanas.yml")
    def search_asanas():
        """
        Search yoga asanas by name, Sanskrit name, or description.
        
        Query Parameters:
            q (str): Search query
            difficulty (str): Filter by difficulty level
            limit (int): Maximum number of results to return
            
        Returns:
            JSON response with matching asanas.
        """
        try:
            search_query = request.args.get('q', '').strip()
            difficulty = request.args.get('difficulty')
            limit = request.args.get('limit', type=int, default=20)
            
            if not search_query:
                return jsonify({'error': 'Search query is required', 'status': 'fail'}), 400
            
            # Build search query
            query = YogaAsana.query.filter(
                db.or_(
                    YogaAsana.name.ilike(f'%{search_query}%'),
                    YogaAsana.sanskrit_name.ilike(f'%{search_query}%'),
                    YogaAsana.description.ilike(f'%{search_query}%'),
                    YogaAsana.benefits.ilike(f'%{search_query}%')
                )
            )
            
            # Apply difficulty filter
            if difficulty:
                query = query.filter(YogaAsana.difficulty.ilike(f'%{difficulty}%'))
            
            # Apply limit
            query = query.limit(limit)
            
            asanas = query.all()
            
            return jsonify({
                'asanas': [asana.to_dict() for asana in asanas],
                'count': len(asanas),
                'search_query': search_query,
                'status': 'success'
            }), 200
            
        except Exception as e:
            return jsonify({'error': f'Error searching asanas: {str(e)}', 'status': 'fail'}), 500
