from flask import Flask
from flask_sqlalchemy import SQLAlchemy
import os
from flask_session import Session # For server-side session management


app = Flask(__name__, static_folder="../Frontend")
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

app.config['SECRET_KEY'] = 'secret'
app.config["SESSION_TYPE"] = "filesystem" # Stores sessions in a local directory
app.config["SESSION_PERMANENT"] = False # Sessions expire when browser closes (change for persistent logins)
Session(app)


db = SQLAlchemy(app)
