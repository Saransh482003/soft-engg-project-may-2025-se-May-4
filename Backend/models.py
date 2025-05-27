from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from config import db

class User(db.Model):

    id = db.Column(db.Integer, autoincrement=True, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    mobile = db.Column(db.String(15), unique=True, nullable=False) # Changed to unique based on common practice
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)

    address = db.Column(db.String(255), nullable=True) # Made nullable as professionals might not need a public address here
    pin = db.Column(db.String(10), nullable=True) # Made nullable for consistency with address

    # Fields specific to 'customer' (senior citizen)
    age = db.Column(db.Integer, nullable=True) # Nullable because professionals might not have this relevant
    gender = db.Column(db.String(20), nullable=True) # e.g., 'Male', 'Female', 'Other'
    dob = db.Column(db.Date, nullable=True) # Date of Birth for senior citizens

    