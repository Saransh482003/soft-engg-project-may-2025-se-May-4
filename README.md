# Shravan - Your Companion for a Graceful Age

*AI-powered Digital Health Solution for Senior Citizens*

## 🌟 Overview

**Shravan** is a comprehensive digital health companion designed specifically for senior citizens, providing an intuitive and accessible platform to manage their health, medications, and wellness journey. Named after the symbol of devotion and care in Indian culture, Shravan embodies the spirit of compassionate healthcare for our elderly community.

## 🎯 Mission Statement

To empower senior citizens with technology that simplifies healthcare management, promotes wellness, and provides peace of mind through intelligent health monitoring and medication management.

## ✨ Key Features

### 🤖 **Medical Assistance Chatbot**

This is a chatbot empowered by the **Groq AI API**, which has been fine-tuned to deliver informative medical assistance to the users.

The chatbot is not capable of providing diagnostics or other sensitive information to the user, that may require professional supervision.

- **Groq AI Integration** for intelligent medical guidance
- **Safe Medical Information** delivery without diagnostics
- **Interactive Q&A** for health-related queries
- **Professional Supervision Awareness** for sensitive topics

### 🏥 **Hospital and Pharmacy Finder**

Elders often find it difficult to locate hospitals and pharmacies in their vicinity.

To counter this, backed by the power of **Google Maps API**, we are fetching information about the hospitals and pharmacies in a user's vicinity, for a given distance radius.

We utilized the free $300 GCP credits to access the Google Maps API.

- **Location-based Search** using GPS coordinates or locality names
- **Google Maps API Integration** with $300 GCP credits utilization
- **Customizable Distance Radius** for search results
- **Real-time Healthcare Facility Information**

### 👨‍⚕️ **Doctor & Medical Professional Finder**

Building upon the hospital and pharmacy finder, we implemented the doctor finder as well, which is capable of fetching all the doctors of a certain specialty present in the user's vicinity.

This enables the users to choose which doctors they should consult with.

On the backend we are using the data we get from the hospital finder where, we extract the websites of all these hospitals, run a crawler that goes in **5 layers of depth** to extract the best possible urls present on the pages using **fuzzy matching**.

After shortlisting the urls, their HTML bodies are scraped using **headless Selenium**, and then sent to **Groq AI** which fetches out all information from those pages and returns a list of dictionaries as a response.

- **Specialty-based Doctor Search** in user's vicinity
- **Advanced Web Crawling** with 5-layer depth analysis
- **Fuzzy Matching Algorithm** for URL optimization
- **Headless Selenium Scraping** for data extraction
- **Groq AI-powered Information Processing**

### 💬 **Personalised Chatbot Companion**

Unlike the Medical Chatbot which is tuned just for Medical concerns, this chatbot is to counter loneliness among the elderly.

Users can tailor the persona of the chatbot according to their wishes and chat with them as they wish.

In the future we are going to fine-tune AI chatbots on these parameters to receive much more diverse responses from the AI.

- **Customizable Chatbot Personas** for personalized interaction
- **Loneliness Mitigation** through companionship
- **Tailored Conversation Styles** based on user preferences
- **Future AI Fine-tuning** for diverse responses

### 🧘 **Yoga Asana Animations**

Sequential images of asanas are generated manually by **ChatGPT Generative AI**.

After fetching these images from the backend, they are displayed on a loop giving an impression of an animation.

We are planning to add automated generative AI generation part, where user inputs the asana and it generates the images.

- **ChatGPT-generated Sequential Images** for yoga poses
- **Looped Animation Effect** for better visualization
- **Backend Image Management** with efficient delivery
- **Future Automation** for user-input based image generation

### 💊 **Medical Adherence Assistant**

A mobile application to ensure medical adherence by setting medicine reminders.

To provide an ease of use to the elderly, we have enabled **speech narration** for adding new medication to the application.

We are currently working on creating **analytical dashboards** to allow our secondary users to monitor the patient's adherence of medications.

- **Medicine Reminder System** with customizable scheduling
- **Speech Narration Support** for elderly accessibility
- **Voice-enabled Medication Entry** for ease of use
- **Analytical Dashboards** for adherence monitoring (in development)
- **Secondary User Access** for family/caregiver monitoring

## 🏗️ Technical Architecture

### **Frontend (Mobile Application)**
- **Framework**: Flutter with Dart
- **UI Design**: Material Design with custom theming
- **State Management**: StatefulWidget with efficient state handling
- **Navigation**: Flutter's built-in navigation system
- **Local Storage**: SharedPreferences for user data persistence

### **Backend (Flask API)**
- **Framework**: Python Flask with modular architecture
- **Database**: JSON-based data storage with file system integration
- **API Design**: RESTful endpoints with comprehensive documentation
- **Authentication**: Session-based user management
- **AI Integration**: Google Gemini API for intelligent features

### **Key Backend Modules**
- `routes_user.py` - User management and authentication
- `routes_health.py` - Health data and analytics
- `routes_reminders.py` - Medication reminders system
- `routes_asanas.py` - Yoga and wellness content
- `routes_doctors.py` - Healthcare provider services
- `routes_emergency.py` - Emergency contact management
- `routes_analytics.py` - Data analytics and insights

### **Mobile App Structure**
```
lib/
├── screens/
│   ├── dashboard_screen.dart      # Main health dashboard
│   ├── medication_logs_screen.dart # Medication tracking
│   ├── login_screen.dart          # User authentication
│   └── add_prescription_screen.dart # Prescription management
├── services/
│   ├── data_storage_service.dart  # Local data management
│   ├── auth_service.dart          # Authentication handling
│   └── notification_service.dart   # Push notifications
└── constants/
    └── theme_constants.dart       # UI theming and colors
```

## 🚀 Getting Started

### **Prerequisites**
- Flutter SDK (latest stable version)
- Python 3.8+
- Android Studio / VS Code
- Git

### **App Setup**
```bash
# Clone the repository
git clone https://github.com/Umang7198/soft-engg-project-may-2025-se-May-4.git
cd soft-engg-project-may-2025-se-May-4
```

### **Backend Setup**
```bash
# Set up Python environment
cd Backend
python -m venv env
source env/bin/activate  # On Windows: env\Scripts\activate
pip install -r requirements.txt

# Run the Flask backend
python app.py
```

### **Web App Setup**
```bash
# Navigate to web app directory
cd frontend

# Run the VueJS application
npm run dev
# or
yarn run dev # if your prefer yarn
```

### **Mobile App Setup**
```bash
# Navigate to mobile app directory
cd mobile-application/frontend

# Install Flutter dependencies
flutter pub get

# Run the application
flutter run
```

### **Quick Start Scripts**
- **🚀 Complete App**: `run_app.ps1` (Windows) / `run_app.sh` (Unix/Linux) - One-click setup and launch
- **Backend Only**: `run_backend.ps1` (Windows) / `run_backend.sh` (Unix/Linux) - Flask backend only
- **Testing**: `run_test.ps1` - Automated testing script

#### **Quick Launch (Recommended)**
```powershell
# Windows - Run complete application
.\run_app.ps1
```

```bash
# Unix/Linux/Mac - Run complete application
./run_app.sh
```

These scripts will automatically:
1. ✅ Check system prerequisites (Python, Node.js)
2. ✅ Set up Python virtual environment
3. ✅ Install all dependencies
4. ✅ Start Flask backend server
5. ✅ Start VueJS frontend development server
6. ✅ Provide helpful status messages and URLs

## 📱 User Experience

### **Dashboard Overview**
- **Modern Card-based Layout** with intuitive navigation
- **Quick Health Stats** showing medication adherence
- **Upcoming Reminders** prominently displayed
- **One-tap Access** to frequently used features
- **Swipe Gestures** for quick navigation between screens

### **Medication Management Flow**
1. **Add Prescription** with photo capture or manual entry
2. **Set Reminder Times** using intuitive time picker
3. **Receive Notifications** at scheduled times
4. **Log Medication Intake** with simple tap interaction
5. **View Analytics** showing adherence patterns

### **AI Chatbot Interaction**
- **Natural Language Processing** for health queries
- **Contextual Responses** based on user's medical history
- **Medication Information** lookup and explanation
- **Health Tips** and preventive care recommendations

## 🔒 Privacy & Security

- **Local Data Storage** with encrypted user information
- **Secure API Communication** with HTTPS protocols
- **Privacy-first Design** with minimal data collection
- **User Consent Management** for data usage
- **HIPAA-compliant** data handling practices

## 🧪 Testing & Quality Assurance

### **Comprehensive Test Suite**
- `test_auth.py` - Authentication system testing
- `test_chatbot.py` - AI chatbot functionality
- `test_routes_*.py` - API endpoint validation
- `test_nearby.py` - Location-based services
- **Mobile Unit Tests** for critical app components

### **Quality Metrics**
- **Code Coverage**: 85%+ across critical modules
- **Performance Testing** for mobile responsiveness
- **Accessibility Testing** for senior-friendly design
- **Cross-platform Compatibility** validation

## 📈 Analytics & Insights

### **User Health Metrics**
- **Medication Adherence Rates** with trend analysis
- **Health Pattern Recognition** using AI algorithms
- **Wellness Activity Tracking** with progress indicators
- **Predictive Health Insights** for preventive care

### **Data Visualization**
- **Interactive Charts** showing health trends
- **Color-coded Indicators** for quick status understanding
- **Time-series Analysis** of medication patterns
- **Comparative Analytics** for health improvement tracking

## 🌐 API Documentation

Comprehensive API documentation is available in the `Backend/docs/` directory with YAML specifications for:
- User management endpoints
- Medication tracking APIs
- Health analytics services
- AI chatbot integration
- Location-based services

## 🤝 Contributing

We welcome contributions from developers passionate about senior healthcare technology. Please see our contribution guidelines and code of conduct.

## 📄 License

This project is developed as part of a Software Engineering course and is intended for educational and healthcare improvement purposes.

## 📞 Support & Contact

For technical support or healthcare-related queries, please contact our development team or refer to the in-app help section.

---

**Shravan** - Bridging technology and healthcare for a better tomorrow for our senior citizens. 👴👵💙
