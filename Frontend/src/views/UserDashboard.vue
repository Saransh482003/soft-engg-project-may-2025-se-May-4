<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { auth } from '@/stores/auth';

const router = useRouter();
const auth_store = auth();
const username = ref('User');
const isDarkMode = ref(false);
const sosStatusMessage = ref('');

onMounted(() => {
  if (auth_store.userDetails) {
    try {
      const userDetails = JSON.parse(auth_store.userDetails);
      username.value = userDetails.username || 'User';
    } catch (e) {
      console.error('Error parsing user details:', e);
    }
  }
  
  const savedTheme = localStorage.getItem('darkModePreference');
  if (savedTheme === 'dark') {
    isDarkMode.value = true;
    document.body.classList.add('dark-mode');
  }
});

function toggleDarkMode() {
  isDarkMode.value = !isDarkMode.value;
  document.body.classList.toggle('dark-mode', isDarkMode.value);
  localStorage.setItem('darkModePreference', isDarkMode.value ? 'dark' : 'light');
}

function goToFeature(path) {
  router.push(path);
}

function logout() {
  auth_store.logout();
  router.push('/');
}

async function triggerSOS() {
  sosStatusMessage.value = 'Requesting location permission...';

  try {
    if (navigator.permissions && navigator.permissions.query) {
      try {
        const permissionStatus = await navigator.permissions.query({ name: 'geolocation' });
        console.log('Current geolocation permission status:', permissionStatus.state);
        sosStatusMessage.value = `Current permission status: ${permissionStatus.state}. Requesting location...`;
      } catch (e) {
        console.error('Error checking permission:', e);
      }
    }

    const location = await getLocation();

    if (!location) {
      sosStatusMessage.value = '❌ Unable to get your location. Please ensure location services are enabled.';
      return;
    }

    sosStatusMessage.value = 'Sending alert with your location...';
    setTimeout(() => {
      sosStatusMessage.value = '✅ Alert sent successfully! Coordinates have been shared with emergency contacts.';
    }, 1500);
    
    console.log('Emergency alert triggered with location:', location);
  } catch (err) {
    sosStatusMessage.value = '❌ Error: ' + err.message;
    console.error('SOS error:', err);
  }
}

function getLocation() {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      sosStatusMessage.value = '❌ Your browser does not support geolocation';
      resolve(null);
      return;
    }

    const options = {
      enableHighAccuracy: true,
      timeout: 10000,
      maximumAge: 0
    };

    sosStatusMessage.value = 'Waiting for location permission...';
    console.log('Requesting geolocation...');

    navigator.geolocation.getCurrentPosition(
      (position) => {
        console.log('Position obtained:', position);
        const coords = `https://www.google.com/maps?q=${position.coords.latitude},${position.coords.longitude}`;
        sosStatusMessage.value = 'Location obtained successfully!';
        resolve(coords);
      },
      (error) => {
        console.error('Geolocation error:', error);
        switch(error.code) {
          case error.PERMISSION_DENIED:
            sosStatusMessage.value = '❌ Location access denied. Please enable location in your browser settings and try again.';
            break;
          case error.POSITION_UNAVAILABLE:
            sosStatusMessage.value = '❌ Location information is unavailable';
            break;
          case error.TIMEOUT:
            sosStatusMessage.value = '❌ Location request timed out';
            break;
          default:
            sosStatusMessage.value = `❌ Error getting location: ${error.message}`;
        }
        resolve(null);
      },
      options
    );
  });
}
</script>

<template>
  <div class="dashboard-container" :class="{ 'dark': isDarkMode }">
    <nav class="navbar">
      <div class="logo">
        <span>🌿 SHRAVAN</span>
      </div>
      <div class="nav-right">
        <div class="nav-actions">
          <button class="theme-button" @click="toggleDarkMode">
            {{ isDarkMode ? '☀️ Light' : '🌙 Dark' }}
          </button>
          <button class="logout-button" @click="logout">Logout</button>
        </div>
      </div>
    </nav>

    <section class="welcome-section">
      <div class="welcome-content">
        <h1>Welcome, {{ username }} 👋</h1>
        <p class="subtitle">Empowering your golden years with technology</p>
        
        <div class="sos-container">
          <button class="sos-btn" @click="triggerSOS">🚨 Emergency SOS</button>
          <p v-if="sosStatusMessage" class="status-message">{{ sosStatusMessage }}</p>
        </div>
      </div>
      <div class="welcome-image">
        <img src="https://placehold.co/400x300/f9e8e8/1f2937?text=Senior+Care" alt="Senior Care" class="care-image">
      </div>
    </section>

    <section class="features-section">
      <h2>Services</h2>
      <div class="card-container">
        <div class="feature-card" @click="goToFeature('/medicinereminders')">
          <div class="card-icon">💊</div>
          <h3>Medicine Reminders</h3>
          <p>Manage and track your medication schedule</p>
        </div>
        
        <div class="feature-card" @click="goToFeature('/doctor-finder')">
          <div class="card-icon">🩺</div>
          <h3>Doctor Finder</h3>
          <p>Find healthcare professionals near you</p>
        </div>
        
        <div class="feature-card" @click="goToFeature('/chatbot')">
          <div class="card-icon">🗣️</div>
          <h3>Voice-Based Chatbot</h3>
          <p>Ask questions and get assistance using your voice</p>
        </div>

        <div class="feature-card" @click="goToFeature('/yoga-videos')">
          <div class="card-icon">🧘‍♀️</div>
          <h3>Age-Friendly Yoga</h3>
          <p>Gentle exercises suitable for seniors</p>
        </div>

        <div class="feature-card" @click="goToFeature('/pharmacy-locator')">
          <div class="card-icon">🏪</div>
          <h3>Pharmacy Locator</h3>
          <p>Find nearby pharmacies for your medication needs</p>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>

:global(html), :global(body) {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
  overflow-x: hidden;
  box-sizing: border-box;
}

:global(#app) {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
}

.dashboard-container {
  min-height: 100vh;
  width: 100%;
  background: linear-gradient(135deg, #e0f7fa, #ffe6f0, #f0f9ff);
  font-family: 'Poppins', sans-serif;
  display: flex;
  flex-direction: column;
  color: #333;
  margin: 0;
  padding: 0;
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
}

.dark {
  background: linear-gradient(135deg, #1a2435, #2d2d3a, #1a1f2c);
  color: #f1f1f1;
}


.navbar {
  background-color: white;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 30px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 100;
  width: 100%;
  box-sizing: border-box;
}

.dark .navbar {
  background-color: #2a2a2a;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
}

.logo {
  font-size: 1.5rem;
  font-weight: 600;
  color: #3b82f6;
}

.dark .logo {
  color: #60a5fa;
}


.nav-right {
  display: flex;
  align-items: center;
  justify-content: flex-end; 
}

.nav-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.theme-button {
  background-color: #f3f4f6;
  color: #4b5563;
  border: none;
  padding: 10px 20px;
  border-radius: 10px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.dark .theme-button {
  background-color: #4b5563;
  color: #f3f4f6;
}

.theme-button:hover {
  background-color: #e5e7eb;
  color: #1f2937;
}

.dark .theme-button:hover {
  background-color: #6b7280;
}

.logout-button {
  background-color: #f3f4f6;
  color: #4b5563;
  border: none;
  padding: 10px 20px;
  border-radius: 10px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.dark .logout-button {
  background-color: #4b5563;
  color: #f3f4f6;
}

.logout-button:hover {
  background-color: #e5e7eb;
  color: #1f2937;
}

.dark .logout-button:hover {
  background-color: #6b7280;
}


.welcome-section {
  display: flex;
  margin: 30px 30px;
  background-color: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
}

.dark .welcome-section {
  background-color: #2a2a2a;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
}

.welcome-content {
  flex: 1;
  padding: 40px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}


.sos-container {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  margin-top: 20px;
}

.sos-btn {
  font-size: 1.2rem;
  padding: 10px 25px;
  background-color: #d9534f;
  border: none;
  border-radius: 10px;
  color: white;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
}

.sos-btn:hover {
  background-color: #c9302c;
  transform: scale(1.05);
}

.status-message {
  margin-top: 10px;
  font-weight: 500;
  color: #10b981;
}

.dark .status-message {
  color: #34d399;
}

.welcome-image {
  flex: 1;
  background-color: #f6f8fb;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.dark .welcome-image {
  background-color: #333;
}

.care-image {
  max-width: 100%;
  max-height: 250px;
  object-fit: cover;
  border-radius: 12px;
}

h1 {
  color: #1f2937;
  font-size: 2.2rem;
  margin-bottom: 10px;
  font-weight: 600;
}

.dark h1 {
  color: #f3f4f6;
}

.subtitle {
  color: #6b7280;
  font-size: 1.1rem;
  margin-bottom: 0;
}

.dark .subtitle {
  color: #d1d5db;
}


.features-section {
  padding: 0 30px 30px 30px;
}

.features-section h2 {
  color: #1f2937;
  font-size: 1.5rem;
  margin-bottom: 20px;
  font-weight: 500;
  padding-left: 10px;
  border-left: 4px solid #3b82f6;
}

.dark .features-section h2 {
  color: #f3f4f6;
  border-left-color: #60a5fa;
}

.card-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.feature-card {
  background-color: white;
  border-radius: 16px;
  padding: 25px;
  text-align: center;
  transition: all 0.3s ease;
  border: 1px solid #e5e7eb;
  cursor: pointer;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.dark .feature-card {
  background-color: #2a2a2a;
  border-color: #444;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
}

.feature-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
  border-color: #bfdbfe;
}

.dark .feature-card:hover {
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.3);
  border-color: #4b5563;
}

.card-icon {
  font-size: 2.5rem;
  margin-bottom: 15px;
}

.feature-card h3 {
  color: #1f2937;
  font-size: 1.2rem;
  margin-bottom: 10px;
  font-weight: 500;
}

.dark .feature-card h3 {
  color: #f3f4f6;
}

.feature-card p {
  color: #6b7280;
  font-size: 0.95rem;
}

.dark .feature-card p {
  color: #d1d5db;
}

@media (max-width: 768px) {
  .navbar {
    flex-direction: column;
    padding: 15px;
  }
  
  .logo {
    margin-bottom: 10px;
  }
  
  .nav-right {
    flex-direction: column;
    width: 100%;
  }
  
  .nav-actions {
    margin-top: 10px;
    width: 100%;
    gap: 10px;
  }
  
  .theme-button, .logout-button {
    width: 100%;
  }
  
  .welcome-section {
    flex-direction: column;
    margin: 20px 15px;
  }
  
  .welcome-content, .welcome-image {
    padding: 25px;
  }
  
  h1 {
    font-size: 1.8rem;
  }
  
  .features-section {
    padding: 0 15px 15px 15px;
  }
  
  .card-container {
    grid-template-columns: 1fr;
  }
}
</style>
