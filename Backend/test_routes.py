#!/usr/bin/env python3
"""
Test script to verify that Flask routes can be loaded without conflicts.
This will help identify any duplicate endpoint issues.
"""

import sys
import os

# Add the Backend directory to the Python path
backend_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, backend_dir)

try:
    from flask import Flask
    from routes_asanas import asana_routes
    from routes_user import routes_user
    from routes_analytics import routes_analytics
    from routes_doctors import routes_doctors
    from routes_emergency import routes_emergency
    from routes_reminders import routes_reminders
    from routes_health import routes_health
    from routes_functions import function_routes
    from models import db
    import json
    
    print("✅ All imports successful")
    
    # Create a test Flask app
    app = Flask(__name__)
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['SECRET_KEY'] = 'test-secret-key'
    
    # Initialize database
    db.init_app(app)
    
    # Load auth config
    try:
        with open("authorisation.json", "r") as file:
            auth = json.loads(file.read())
        print("✅ Auth configuration loaded")
    except FileNotFoundError:
        print("⚠️  Authorization file not found, using empty auth")
        auth = {}
    
    # Test loading each route module
    with app.app_context():
        print("\n🔄 Testing route registrations...")
        
        try:
            asana_routes(app)
            print("✅ Asana routes registered successfully")
        except Exception as e:
            print(f"❌ Error registering asana routes: {e}")
            
        try:
            routes_user(app, db)
            print("✅ User routes registered successfully")
        except Exception as e:
            print(f"❌ Error registering user routes: {e}")
            
        try:
            routes_analytics(app, db)
            print("✅ Analytics routes registered successfully")
        except Exception as e:
            print(f"❌ Error registering analytics routes: {e}")
            
        try:
            routes_doctors(app, db)
            print("✅ Doctor routes registered successfully")
        except Exception as e:
            print(f"❌ Error registering doctor routes: {e}")
            
        try:
            routes_emergency(app, db)
            print("✅ Emergency routes registered successfully")
        except Exception as e:
            print(f"❌ Error registering emergency routes: {e}")
            
        try:
            routes_reminders(app, db)
            print("✅ Reminder routes registered successfully")
        except Exception as e:
            print(f"❌ Error registering reminder routes: {e}")
            
        try:
            routes_health(app, db)
            print("✅ Health routes registered successfully")
        except Exception as e:
            print(f"❌ Error registering health routes: {e}")
            
        try:
            function_routes(app, db, auth)
            print("✅ Function routes registered successfully")
        except Exception as e:
            print(f"❌ Error registering function routes: {e}")
    
    # List all registered routes to check for duplicates
    print("\n📋 Registered routes:")
    route_endpoints = {}
    for rule in app.url_map.iter_rules():
        endpoint = rule.endpoint
        if endpoint in route_endpoints:
            print(f"⚠️  DUPLICATE ENDPOINT: {endpoint}")
            print(f"   First: {route_endpoints[endpoint]}")
            print(f"   Second: {rule.rule}")
        else:
            route_endpoints[endpoint] = rule.rule
            print(f"   {endpoint}: {rule.rule} {list(rule.methods)}")
    
    print(f"\n✅ Total routes registered: {len(route_endpoints)}")
    print("✅ Route loading test completed successfully!")
    
except ImportError as e:
    print(f"❌ Import error: {e}")
    sys.exit(1)
except Exception as e:
    print(f"❌ Unexpected error: {e}")
    sys.exit(1)