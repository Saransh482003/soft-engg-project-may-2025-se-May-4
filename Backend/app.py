from flask import Flask, request, jsonify, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import requests
import os
from routes import configure_routes
from routes_user import routes_user
from models import *
from config import db, app

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = 'secret'

CORS(app)
db.init_app(app)

@app.route("/")
def index():
    return {"message": "Welcome to the Shravan API!"}

# Register the routes from routes.py
configure_routes(app)

# Register the user routes from routes_user.py
routes_user(app)




if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    app.run(debug=True)
