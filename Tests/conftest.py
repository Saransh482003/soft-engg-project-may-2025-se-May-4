import pytest
import os
from app import app, db
from models import User
from datetime import datetime

@pytest.fixture(scope='module')
def test_client():
    BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'Backend'))
    TEST_DB_PATH = os.path.join(BASE_DIR, 'instance', 'test_database.db')

    app.config['TESTING'] = True
    app.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{TEST_DB_PATH}'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    os.makedirs(os.path.dirname(TEST_DB_PATH), exist_ok=True)

    with app.app_context():
        print("Initializing the test database...")
        print(f"DB Path: {TEST_DB_PATH}")
        print("Initializing the test database at:", TEST_DB_PATH)


        db.create_all()
        User.query.delete()
        db.session.commit()

        test_user = User(
            name="Test User",
            email="test@example.com",
            mobile="1234567890",
            username="testuser",
            password="testpass",
            address="123 Main St",
            pin="123456",
            age=30,
            gender="M",
            # dob="1990-01-01"  
            dob=datetime.strptime("1990-01-01", "%Y-%m-%d").date()
        )
        db.session.add(test_user)
        db.session.commit()

    yield app.test_client()

    with app.app_context():
        db.session.remove()
        db.drop_all()

        if os.path.exists(TEST_DB_PATH):
            os.remove(TEST_DB_PATH)
