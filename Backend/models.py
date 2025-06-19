from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

class User(db.Model):
    user_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_name = db.Column(db.String, unique=True, nullable=False)
    password = db.Column(db.String, nullable=False)
    email = db.Column(db.String, unique=True, nullable=False)
    mobile = db.Column(db.String, unique=True, nullable=False)
    gender = db.Column(db.String, nullable=True)
    dob = db.Column(db.Date, nullable=True)

class Hospitals(db.Model):
    hospital_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    hospital_name = db.Column(db.String, unique=False, nullable=False)
    place_id = db.Column(db.String, unique=True, nullable=False)
    global_id = db.Column(db.String, unique=True, nullable=False)
    latitudes = db.Column(db.Numeric(10, 6), nullable=False)
    longitudes = db.Column(db.Numeric(10, 6), nullable=False)
    website = db.Column(db.String, nullable=True)
    rating = db.Column(db.Numeric(2,1), nullable=True)
    num_rating = db.Column(db.Integer, nullable=True)
    type = db.Column(db.String, nullable=False)
    vicinity = db.Column(db.String, nullable=False)

class Doctors(db.Model):
    doctor_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    doctor_name = db.Column(db.String, nullable=False)
    hospital_id = db.Column(db.Integer, db.ForeignKey('hospitals.hospital_id'), nullable=False)
    specialization = db.Column(db.String, nullable=False)
    experience = db.Column(db.Integer, nullable=False)
    rating = db.Column(db.Numeric(2,1), nullable=True)
    num_rating = db.Column(db.Integer, nullable=True)