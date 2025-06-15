from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

class User(db.Model):
    user_id = db.Column(db.String, primary_key=True)
    user_name = db.Column(db.String, unique=True, nullable=False)
    password = db.Column(db.String, nullable=False)
    email = db.Column(db.String, unique=True, nullable=False)
    mobile = db.Column(db.String, unique=True, nullable=False)
    gender = db.Column(db.String, nullable=True)
    dob = db.Column(db.Date, nullable=True)
