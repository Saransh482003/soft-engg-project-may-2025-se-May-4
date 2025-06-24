# from config import app, db
from flask import Flask
from flask_cors import CORS
import requests
import os
from models import *
import json
from config import app,db


CORS(app)

with open("authorisation.json", "r") as file:
    auth = json.loads(file.read())

@app.route("/")
def index():
    return {"message": "Welcome to the Shravan API!"}


from routes_functions import function_routes
from routes_user import routes_user

function_routes(app, db, auth)
routes_user(app, db, auth)

if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    app.run(debug=True)
