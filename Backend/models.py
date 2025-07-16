from datetime import datetime, timezone
from config import db
from werkzeug.security import generate_password_hash, check_password_hash

# The Addresses table has been removed.

class Roles(db.Model):
    __tablename__ = 'roles'
    role_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String, unique=True)
    description = db.Column(db.Text)

class Medicines(db.Model):
    __tablename__ = 'medicines'
    medicine_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String)
    dosage = db.Column(db.String)
    description = db.Column(db.Text)

class Services(db.Model):
    __tablename__ = 'services'
    service_id = db.Column(db.Integer, primary_key=True)
    service_name = db.Column(db.String, unique=True)
    description = db.Column(db.Text)

class Hospitals(db.Model):
    __tablename__ = 'hospitals'
    hospital_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    hospital_name = db.Column(db.String, nullable=False)
    address = db.Column(db.Text, nullable=True) 
    place_id = db.Column(db.String, unique=True)
    latitudes = db.Column(db.Numeric(10, 6))
    longitudes = db.Column(db.Numeric(10, 6))
    website = db.Column(db.String, nullable=True)
    phone = db.Column(db.String, nullable=True)
    rating = db.Column(db.Numeric(2,1), nullable=True)
    num_rating = db.Column(db.Integer, nullable=True)
    type = db.Column(db.String, nullable=True)

    def to_dict(self):
            return {
                "hospital_id": self.hospital_id,
                "hospital_name": self.hospital_name,
                "address": self.address,
                "place_id": self.place_id,
                "latitudes": float(self.latitudes) if self.latitudes else None,
                "longitudes": float(self.longitudes) if self.longitudes else None,
                "website": self.website,
                "phone": self.phone,
                "rating": float(self.rating) if self.rating else None,
                "num_rating": self.num_rating,
                "type": self.type
            }


class Pharmacy(db.Model):
    __tablename__ = 'pharmacy'
    pharmacy_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    address = db.Column(db.Text, nullable=True) # Replaced Addresses relationship with a Text column
    place_id = db.Column(db.String(255), unique=True, nullable=False)
    name = db.Column(db.String(255), nullable=False)
    latitude = db.Column(db.Numeric(10, 6), nullable=False)
    longitude = db.Column(db.Numeric(10, 6), nullable=False)
    phone_number = db.Column(db.String(50), nullable=True)
    website = db.Column(db.String(255), nullable=True)
    rating = db.Column(db.Numeric(2,1), nullable=True)
    user_ratings_total = db.Column(db.Integer, nullable=True)
    opening_hours_json = db.Column(db.Text, nullable=True)
    business_status = db.Column(db.String(50), nullable=True)
    delivery_available = db.Column(db.Boolean, default=False)
    
    def to_dict(self):
        return {
            "pharmacy_id": self.pharmacy_id,
            "name": self.name,
            "address": self.address,
            "place_id": self.place_id,
            "latitude": float(self.latitude) if self.latitude else None,
            "longitude": float(self.longitude) if self.longitude else None,
            "phone_number": self.phone_number,
            "website": self.website,
            "rating": float(self.rating) if self.rating else None,
            "user_ratings_total": self.user_ratings_total,
            "opening_hours_json": self.opening_hours_json,
            "business_status": self.business_status,
            "delivery_available": self.delivery_available
        }

class Doctors(db.Model):
    __tablename__ = 'doctors'
    doctor_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String, nullable=False)
    hospital_id = db.Column(db.Integer, db.ForeignKey('hospitals.hospital_id'), nullable=False)
    specialization = db.Column(db.String, nullable=False)
    experience = db.Column(db.Integer, nullable=False)
    rating = db.Column(db.Numeric(2,1), nullable=True)
    num_rating = db.Column(db.Integer, nullable=True)
    hospital = db.relationship('Hospitals', backref='doctors')

class User(db.Model):
    __tablename__ = 'users'
    user_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_name = db.Column(db.String, nullable=False, unique=True)
    password_hash = db.Column(db.String, nullable=False)
    email = db.Column(db.String, unique=True, nullable=False)
    mobile_number = db.Column(db.String, unique=True, nullable=False)
    gender = db.Column(db.String, nullable=True)
    dob = db.Column(db.Date, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.now(timezone.utc))
    address = db.Column(db.Text, nullable=True) 
    pincode = db.Column(db.String(6), nullable=True)
    roles = db.relationship('Roles', secondary='user_roles', backref='users')
    favorite_doctors = db.relationship('Doctors', secondary='user_doctor_favorites', backref='favorited_by_users')
    favorite_pharmacies = db.relationship('Pharmacy', secondary='user_pharmacy_favorites', backref='favorited_by_users')

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

class UserRoles(db.Model):
    __tablename__ = 'user_roles'
    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id'), primary_key=True)
    role_id = db.Column(db.Integer, db.ForeignKey('roles.role_id'), primary_key=True)

class Reminders(db.Model):
    __tablename__ = 'reminders'
    reminder_id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id'))
    medicine_id = db.Column(db.Integer, db.ForeignKey('medicines.medicine_id'))
    time_of_day = db.Column(db.String)
    relation_to_meal = db.Column(db.String)
    frequency = db.Column(db.String)
    notification_type = db.Column(db.String)
    is_active = db.Column(db.Boolean)
    created_at = db.Column(db.DateTime, default=datetime.now(timezone.utc))
    user = db.relationship('User', backref='reminders')
    medicine = db.relationship('Medicines', backref='reminders')

class MedicineLogs(db.Model):
    __tablename__ = 'medicine_logs'
    log_id = db.Column(db.Integer, primary_key=True)
    reminder_id = db.Column(db.Integer, db.ForeignKey('reminders.reminder_id'))
    log_date = db.Column(db.Date)
    status = db.Column(db.String)
    actual_time = db.Column(db.Time)
    reminder = db.relationship('Reminders', backref='logs')

class EmergencyContacts(db.Model):
    __tablename__ = 'emergency_contacts'
    emergency_contact_id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id'))
    contact_name = db.Column(db.String)
    contact_number = db.Column(db.String)
    relation = db.Column(db.String)
    user = db.relationship('User', backref='emergency_contacts')

class UserDoctorFavorites(db.Model):
    __tablename__ = 'user_doctor_favorites'
    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id'), primary_key=True)
    doctor_id = db.Column(db.Integer, db.ForeignKey('doctors.doctor_id'), primary_key=True)
    favorited_at = db.Column(db.DateTime, default=datetime.now(timezone.utc))

class UserPharmacyFavorites(db.Model):
    __tablename__ = 'user_pharmacy_favorites'
    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id'), primary_key=True)
    pharmacy_id = db.Column(db.Integer, db.ForeignKey('pharmacy.pharmacy_id'), primary_key=True)
    favorited_at = db.Column(db.DateTime, default=datetime.now(timezone.utc))


class SymptomLogs(db.Model):
    __tablename__ = 'symptom_logs'
    log_id = db.Column(db.Integer, primary_key=True)
    symptom_term = db.Column(db.String, nullable=False)
    pincode = db.Column(db.String)
    logged_at = db.Column(db.DateTime, default=datetime.now(timezone.utc))


class YogaVideos(db.Model):
    __tablename__ = 'yoga_videos'
    video_id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String, nullable=False)
    description = db.Column(db.Text)
    video_url = db.Column(db.String, nullable=False, unique=True)
    difficulty = db.Column(db.String)
    duration_minutes = db.Column(db.Integer)