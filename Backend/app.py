from config import app, db
from flask_cors import CORS
from routes import configure_routes
from routes_user import routes_user

CORS(app)

@app.route("/")
def index():
    return {"message": "Welcome to the Shravan API!"}

# Register Routes
configure_routes(app)
routes_user(app)

if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    app.run(debug=True)
