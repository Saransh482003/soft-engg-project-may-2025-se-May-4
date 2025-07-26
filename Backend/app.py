# from config import app, db
from flask import Flask
from flask_cors import CORS
import requests
import os
from models import *
import json
from config import app,db
from routes_functions import function_routes
from routes_user import routes_user
from routes_analytics import routes_analytics
from routes_content import routes_content
from routes_doctors import routes_doctors
from routes_emergency import routes_emergency
from routes_reminders import routes_reminders
from routes_health import routes_health

CORS(app)

with open("authorisation.json", "r") as file:
    auth = json.loads(file.read())

@app.route("/")
def index():
    return {"message": "Welcome to the Shravan API!"}



function_routes(app, db, auth)
routes_user(app, db)
routes_analytics(app, db)
routes_content(app, db)
routes_doctors(app, db)
routes_emergency(app, db)
routes_reminders(app, db)
routes_health(app, db)

if __name__ == "__main__":
    with app.app_context():
        db.create_all()
        
        if Roles.query.count() == 0:
            default_roles = [
                Roles(name='ngo', description='Non-Governmental Organization'),
                Roles(name='caretaker', description='Doctor,Nurse etc'),
                Roles(name='user', description='General User')
            ]
            db.session.bulk_save_objects(default_roles)
            db.session.commit()
    app.run(debug=True)
