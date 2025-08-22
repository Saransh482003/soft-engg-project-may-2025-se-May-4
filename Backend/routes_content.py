from flask import Flask, request, jsonify
from models import db, YogaVideos
from flasgger.utils import swag_from

def routes_content(app, db):
    @app.route('/api/yoga-videos', methods=['GET'])
    @swag_from("docs/get_yoga_videos.yml")
    def get_yoga_videos():
        difficulty = request.args.get('difficulty')
        query = YogaVideos.query
        if difficulty:
            query = query.filter_by(difficulty=difficulty)
        
        videos = query.all()
        video_list = [{
            'title': v.title,
            'description': v.description,
            'video_url': v.video_url,
            'difficulty': v.difficulty,
            'duration': v.duration_minutes
        } for v in videos]

        return jsonify({'videos': video_list}), 200
    
    @app.route('/api/yoga-videos', methods=['POST'])
    @swag_from("docs/create_yoga_video.yml")
    def create_yoga_video():
        data = request.get_json()
        video = YogaVideos(
            title=data.get('title'),
            description=data.get('description'),
            video_url=data.get('video_url'),
            difficulty=data.get('difficulty'),
            duration_minutes=data.get('duration')
        )
        db.session.add(video)
        db.session.commit()
        return jsonify({'message': 'Yoga video created', 'id': video.id}), 201

    @app.route('/api/yoga-videos/<int:video_id>', methods=['PUT'])
    @swag_from("docs/update_yoga_video.yml")
    def update_yoga_video(video_id):
        data = request.get_json()
        video = YogaVideos.query.get_or_404(video_id)
        video.title = data.get('title', video.title)
        video.description = data.get('description', video.description)
        video.video_url = data.get('video_url', video.video_url)
        video.difficulty = data.get('difficulty', video.difficulty)
        video.duration_minutes = data.get('duration', video.duration_minutes)
        db.session.commit()
        return jsonify({'message': 'Yoga video updated'}), 200

    @app.route('/api/yoga-videos/<int:video_id>', methods=['DELETE'])
    @swag_from("docs/delete_yoga_video.yml")
    def delete_yoga_video(video_id):
        video = YogaVideos.query.get_or_404(video_id)
        db.session.delete(video)
        db.session.commit()
        return jsonify({'message': 'Yoga video deleted'}), 200