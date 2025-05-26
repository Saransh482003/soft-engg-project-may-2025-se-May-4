from flask import Flask, request, jsonify, send_from_directory
import requests
from routes import configure_routes

app = Flask(__name__, static_folder="../Frontend")



@app.route("/")
def serve_index():
    return send_from_directory(app.static_folder, "index.html")

# Register the routes from routes.py
configure_routes(app)
if __name__ == "__main__":
    app.run(debug=True)
