from flask import Flask, request, jsonify, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import requests
import os
from models import *

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = 'secret'

CORS(app)
db.init_app(app)


@app.route("/")
def index():
    return {"message": "Welcome to the Shravan API!"}


from routes import configure_routes
from routes_user import routes_user

configure_routes(app, db)
routes_user(app, db)

if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    app.run(debug=True)
