from datetime import datetime,timezone
from config import  db

class Addresses(db.Model):
    __tablename__ = 'addresses'
    address_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    street_address = db.Column(db.Text)
    city = db.Column(db.String)
    state = db.Column(db.String)
    pincode = db.Column(db.String)
    country = db.Column(db.String)

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
    address_id = db.Column(db.Integer, db.ForeignKey('addresses.address_id'), nullable=False)
    place_id = db.Column(db.String, unique=True)
    latitudes = db.Column(db.Numeric(10, 6))
    longitudes = db.Column(db.Numeric(10, 6))
    website = db.Column(db.String, nullable=True)
    phone = db.Column(db.String, nullable=True)
    rating = db.Column(db.Numeric(2,1), nullable=True)
    num_rating = db.Column(db.Integer, nullable=True)
    type = db.Column(db.String, nullable=True)
    address = db.relationship('Addresses', backref='hospitals')

class Pharmacy(db.Model):
    __tablename__ = 'pharmacy'
    pharmacy_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    address_id = db.Column(db.Integer, db.ForeignKey('addresses.address_id'), nullable=False)
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
    address = db.relationship('Addresses', backref='pharmacies')

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
    name = db.Column(db.String, nullable=False)
    password_hash = db.Column(db.String, nullable=False)
    email = db.Column(db.String, unique=True, nullable=False)
    mobile_number = db.Column(db.String, unique=True, nullable=False)
    gender = db.Column(db.String, nullable=True)
    dob = db.Column(db.Date, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.now(timezone.utc))
    address_id = db.Column(db.Integer, db.ForeignKey('addresses.address_id'), nullable=True)
    address = db.relationship('Addresses', backref='users')
    roles = db.relationship('Roles', secondary='user_roles', backref='users')
    favorite_doctors = db.relationship('Doctors', secondary='user_doctor_favorites', backref='favorited_by_users')
    favorite_pharmacies = db.relationship('Pharmacy', secondary='user_pharmacy_favorites', backref='favorited_by_users')

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