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