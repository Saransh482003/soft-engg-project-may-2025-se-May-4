<script setup>
import { ref, onMounted } from 'vue';
import { RouterLink } from 'vue-router';
import { useRouter } from 'vue-router';
import { auth } from '@/stores/auth';

const router = useRouter();
const auth_store = auth();
const patientName = ref('Your Patient');
const locationData = ref(null);
const sosAlerts = ref([]);
const loading = ref(false);
const error = ref(null);
const mapUrl = ref('');
const lastLocationUpdate = ref(null);

// Get linked patient info
onMounted(async () => {
  try {
    if (auth_store.userDetails) {
      const userDetails = JSON.parse(auth_store.userDetails);
      // Normally would fetch this from backend API
      // In a real app, the backend would return the patient's info linked to this caretaker
      await fetchLinkedPatientInfo();
      await fetchSOSHistory();
    }
  } catch (error) {
    console.error('Error loading patient data:', error);
  }
});

// Simulated API call to get linked patient info
async function fetchLinkedPatientInfo() {
  // This would be a real API call in production
  await new Promise(resolve => setTimeout(resolve, 800));
  patientName.value = 'Rajesh Sharma';
  
  // Get last known location if available
  lastLocationUpdate.value = new Date(new Date().getTime() - 45 * 60000).toLocaleString(); // 45 min ago
  locationData.value = {
    latitude: 28.6139,
    longitude: 77.2090,
    timestamp: lastLocationUpdate.value,
    address: 'Connaught Place, New Delhi'
  };
}

// Fetch SOS history
async function fetchSOSHistory() {
  // This would be a real API call in production
  await new Promise(resolve => setTimeout(resolve, 600));
  
  // Mock data for demonstration
  sosAlerts.value = [
    {
      id: 'sos-1',
      timestamp: new Date(new Date().getTime() - 2 * 24 * 60 * 60 * 1000).toLocaleString(),
      location: {
        latitude: 28.6129,
        longitude: 77.2295,
        address: 'Lodhi Gardens, New Delhi'
      },
      status: 'resolved',
      resolvedBy: 'You'
    },
    {
      id: 'sos-2',
      timestamp: new Date(new Date().getTime() - 7 * 24 * 60 * 60 * 1000).toLocaleString(),
      location: {
        latitude: 28.5535,
        longitude: 77.2588,
        address: 'Lotus Temple, New Delhi'
      },
      status: 'resolved',
      resolvedBy: 'Emergency Services'
    }
  ];
}

// Track current location
async function trackCurrentLocation() {
  loading.value = true;
  error.value = null;
  
  try {
    // In a real application, this would be an API call to your backend
    // The backend would then query the patient's device for location
    await new Promise(resolve => setTimeout(resolve, 1500));
    
    // Simulate location data (would come from backend in real app)
    const currentTime = new Date().toLocaleString();
    locationData.value = {
      latitude: 28.6304,
      longitude: 77.2177,
      timestamp: currentTime,
      address: 'Karol Bagh, New Delhi'
    };
    
    lastLocationUpdate.value = currentTime;
    
    // Generate Google Maps URL
    mapUrl.value = `https://www.google.com/maps?q=${locationData.value.latitude},${locationData.value.longitude}`;
  } catch (err) {
    error.value = "Failed to retrieve location. Please try again.";
    console.error(err);
  } finally {
    loading.value = false;
  }
}

function viewOnMap(location) {
  window.open(`https://www.google.com/maps?q=${location.latitude},${location.longitude}`, '_blank');
}

function goBack() {
  router.push('/caretaker');
}
</script>

<template>
  <div class="location-tracking-container">

    <nav class="navbar">
      <div class="logo">
        <img src="../assets/Sharvan_logo.jpeg" alt="Sharvan Logo" class="logo-image" />
        <span style="margin-left: 10px">SHRAVAN</span>
      </div>
      <div class="nav-right">
        <button class="back-button" @click="goBack">
          🏠 Home
        </button>
      </div>
    </nav>


    <section class="header-section">
      <h1>Location Tracking</h1>
      <p class="subtitle">Monitor location for {{ patientName }}</p>
    </section>


    <div class="content-container">

      <section class="current-location-section">
        <div class="card location-card">
          <div class="card-header">
            <h2>📍 Current Location</h2>
            <span v-if="lastLocationUpdate" class="last-update">
              Last updated: {{ lastLocationUpdate }}
            </span>
          </div>
          
          <div class="card-body">
            <div v-if="locationData" class="location-details">
              <p><strong>Address:</strong> {{ locationData.address }}</p>
              <p><strong>Coordinates:</strong> {{ locationData.latitude }}, {{ locationData.longitude }}</p>
              
              <div class="map-actions">
                <a v-if="locationData" 
                   :href="`https://www.google.com/maps?q=${locationData.latitude},${locationData.longitude}`" 
                   target="_blank" 
                   class="map-link">
                  🗺️ View on Google Maps
                </a>
              </div>
            </div>
            
            <div v-else class="no-location">
              <p>No location data available yet.</p>
            </div>
            
            <div class="tracking-actions">
              <button 
                @click="trackCurrentLocation" 
                class="track-button"
                :disabled="loading">
                <span v-if="!loading">🔍 Track Current Location</span>
                <span v-else>⏳ Tracking...</span>
              </button>
              <p v-if="error" class="error-message">{{ error }}</p>
            </div>
          </div>
        </div>
      </section>

      <section class="sos-history-section">
        <div class="card sos-card">
          <div class="card-header">
            <h2>🚨 SOS Alerts History</h2>
          </div>
          
          <div class="card-body">
            <div v-if="sosAlerts.length > 0" class="sos-list">
              <div v-for="alert in sosAlerts" :key="alert.id" class="sos-alert">
                <div class="alert-header">
                  <span class="alert-time">{{ alert.timestamp }}</span>
                  <span class="alert-status" :class="alert.status">
                    {{ alert.status === 'resolved' ? '✓ Resolved' : '⚠️ Active' }}
                  </span>
                </div>
                
                <div class="alert-details">
                  <p><strong>Location:</strong> {{ alert.location.address }}</p>
                  <p v-if="alert.status === 'resolved'"><strong>Resolved by:</strong> {{ alert.resolvedBy }}</p>
                  
                  <button @click="viewOnMap(alert.location)" class="view-map-button">
                    🗺️ View Location
                  </button>
                </div>
              </div>
            </div>
            
            <div v-else class="no-alerts">
              <p>No SOS alerts have been triggered.</p>
            </div>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped>
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

.location-tracking-container {
  min-height: 100vh;
  width: 100%;
  background: linear-gradient(135deg, #e0f7fa, #ffe0e0, #f3e5f5);
  font-family: 'Poppins', sans-serif;
  display: flex;
  flex-direction: column;
  color: #333;
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
}

.logo {
  font-size: 1.5rem;
  font-weight: 600;
  color: #3b82f6;
}

.logo-image {
  height: 36px;
  width: auto;
  object-fit: contain;
  display: inline-block;
  vertical-align: middle; /* Ensures inline alignment with text */
}
.nav-right {
  display: flex;
  align-items: center;
}

.back-button {
  background-color: #f3f4f6;
  color: #4b5563;
  border: none;
  padding: 10px 20px;
  border-radius: 10px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.back-button:hover {
  background-color: #e5e7eb;
  color: #1f2937;
}


.header-section {
  padding: 30px;
  text-align: center;
}

h1 {
  color: #1f2937;
  font-size: 2.2rem;
  margin-bottom: 10px;
  font-weight: 600;
}

.subtitle {
  color: #6b7280;
  font-size: 1.1rem;
}


.content-container {
  padding: 0 30px 30px;
  display: flex;
  flex-direction: column;
  gap: 30px;
}


.card {
  background-color: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.card-header {
  padding: 15px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: #f3f4f6;
}

.card-header h2 {
  font-size: 1.3rem;
  color: #1f2937;
  font-weight: 600;
  margin: 0;
}

.last-update {
  font-size: 0.9rem;
  color: #6b7280;
}

.card-body {
  padding: 20px;
}


.location-details {
  margin-bottom: 20px;
}

.location-details p {
  margin-bottom: 10px;
  color: #4b5563;
}

.no-location {
  text-align: center;
  color: #6b7280;
  margin: 20px 0;
}

.tracking-actions {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-top: 20px;
}

.track-button {
  background: linear-gradient(90deg, #60a5fa, #3b82f6);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  width: 100%;
  max-width: 300px;
}

.track-button:hover:not(:disabled) {
  background: linear-gradient(90deg, #3b82f6, #2563eb);
  transform: translateY(-2px);
}

.track-button:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.error-message {
  color: #ef4444;
  margin-top: 10px;
  text-align: center;
}

.map-actions {
  display: flex;
  justify-content: center;
  margin-top: 15px;
}

.map-link {
  display: inline-block;
  background-color: #f3f4f6;
  color: #4b5563;
  text-decoration: none;
  padding: 8px 16px;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.map-link:hover {
  background-color: #e5e7eb;
  color: #1f2937;
}


.sos-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.sos-alert {
  background-color: #f9fafb;
  border-radius: 10px;
  padding: 15px;
  border-left: 4px solid #ef4444;
}

.alert-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
}

.alert-time {
  font-size: 0.9rem;
  color: #6b7280;
}

.alert-status {
  font-size: 0.9rem;
  font-weight: 500;
}

.alert-status.resolved {
  color: #10b981;
}

.alert-status.active {
  color: #ef4444;
}

.alert-details {
  color: #4b5563;
}

.alert-details p {
  margin-bottom: 8px;
}

.view-map-button {
  background-color: #f3f4f6;
  border: none;
  color: #4b5563;
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.2s ease;
  margin-top: 8px;
}

.view-map-button:hover {
  background-color: #e5e7eb;
  color: #1f2937;
}

.no-alerts {
  text-align: center;
  color: #6b7280;
  padding: 20px 0;
}


@media (max-width: 768px) {
  .navbar, .header-section {
    padding: 15px;
  }
  
  h1 {
    font-size: 1.8rem;
  }
  
  .content-container {
    padding: 0 15px 20px;
  }
  
  .track-button {
    width: 100%;
  }
  
  .alert-header {
    flex-direction: column;
    gap: 5px;
  }
}
</style>