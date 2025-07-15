<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { auth } from '@/stores/auth';

const router = useRouter();
const auth_store = auth();
const isDarkMode = ref(localStorage.getItem('darkModePreference') === 'dark');
const doctors = ref([]);
const loading = ref(false);
const error = ref('');
const locationFetched = ref(false);
const locationSearch = ref('');
const searchPerformed = ref(false);

const mockDoctors = [
  { 
    id: 1,
    name: 'Dr. Kavitha R.', 
    specialization: 'Cardiologist', 
    city: 'Bangalore',
    experience: '15 years',
    rating: 4.8
  },
  { 
    id: 2,
    name: 'Dr. Rajesh Kumar', 
    specialization: 'Physician', 
    city: 'Mumbai',
    experience: '12 years',
    rating: 4.5
  },
  { 
    id: 3,
    name: 'Dr. Anitha Menon', 
    specialization: 'Dermatologist', 
    city: 'Chennai',
    experience: '8 years',
    rating: 4.7
  },
  { 
    id: 4,
    name: 'Dr. Suresh Patel', 
    specialization: 'Orthopedic', 
    city: 'Delhi',
    experience: '20 years',
    rating: 4.9
  },
  { 
    id: 5,
    name: 'Dr. Meera Sharma', 
    specialization: 'Neurologist', 
    city: 'Hyderabad',
    experience: '10 years',
    rating: 4.6
  }
];

const displayedDoctors = computed(() => {
  if (locationSearch.value.trim() === '') {
    return doctors.value;
  }
  
  const search = locationSearch.value.toLowerCase();
  return doctors.value.filter(doc => 
    doc.name.toLowerCase().includes(search) || 
    doc.specialization.toLowerCase().includes(search) ||
    doc.city.toLowerCase().includes(search)
  );
});

async function fetchDoctors(lat, lon) {
  loading.value = true;
  error.value = '';

  try {
    setTimeout(() => {
      doctors.value = mockDoctors;
      loading.value = false;
    }, 800); 
  } catch (err) {
    error.value = 'Failed to fetch doctors.';
    loading.value = false;
  }
}

function getLocation() {
  if (!navigator.geolocation) {
    error.value = 'Geolocation is not supported by your browser.';
    return;
  }

  loading.value = true;
  error.value = '';

  navigator.geolocation.getCurrentPosition(
    (position) => {
      const { latitude, longitude } = position.coords;
      locationFetched.value = true;
      fetchDoctors(latitude, longitude);
    },
    (err) => {
      loading.value = false;
      error.value = `Unable to retrieve your location: ${err.message}`;
    }
  );
}

function manualSearch() {
  if (locationSearch.value.trim() === '') {
    error.value = 'Please enter a location to search';
    return;
  }
  
  loading.value = true;
  error.value = '';
  searchPerformed.value = true;
  
  setTimeout(() => {
    doctors.value = mockDoctors;
    loading.value = false;
  }, 800);
}

function toggleDarkMode() {
  isDarkMode.value = !isDarkMode.value;
  document.body.classList.toggle('dark-mode', isDarkMode.value);
  localStorage.setItem('darkModePreference', isDarkMode.value ? 'dark' : 'light');
}

function logout() {
  auth_store.logout();
  router.push('/');
}

function goHome() {
  router.push('/userdashboard');
}

onMounted(() => {
  if (localStorage.getItem('darkModePreference') === 'dark') {
    document.body.classList.add('dark-mode');
  }
  getLocation();
});
</script>

<template>
  <div class="doctor-finder-container" :class="{ 'dark': isDarkMode }">
    <nav class="navbar">
      <div class="logo">
        <span>🌿 SHRAVAN</span>
      </div>
      <div class="nav-right">
        <div class="nav-actions">
          <button class="theme-button" @click="toggleDarkMode">
            {{ isDarkMode ? '☀️ Light' : '🌙 Dark' }}
          </button>
          <button class="back-button" @click="goHome">Back to Home</button>
          <button class="logout-button" @click="logout">Logout</button>
        </div>
      </div>
    </nav>

    <div class="content-section">
      <div class="page-header">
        <h1>🩺 Find Nearby Doctors</h1>
        <p class="subtitle">Discover healthcare professionals in your area</p>
      </div>

      <div class="search-section">
        <div class="location-search">
          <input 
            type="text" 
            v-model="locationSearch" 
            placeholder="Enter location, doctor's name or specialty" 
            class="location-input"
            @keyup.enter="manualSearch"
          >
          <button class="search-button" @click="manualSearch">
            🔍 Search
          </button>
        </div>

        <button class="location-button" @click="getLocation">
          📍 Use Current Location
        </button>
      </div>

      <div v-if="loading" class="loading-state">
        <div class="loading-spinner"></div>
        <p>Finding doctors...</p>
      </div>

      <div v-if="error" class="error-state">
        <p>{{ error }}</p>
        <button class="retry-button" @click="getLocation">Try Again</button>
      </div>

      <div v-if="!loading && !error && displayedDoctors.length === 0 && searchPerformed" class="empty-state">
        <p>No doctors found in this area. Try a different location.</p>
      </div>

      <div v-if="!loading && displayedDoctors.length > 0" class="doctors-list">
        <div v-for="doctor in displayedDoctors" :key="doctor.id" class="doctor-card">
          <div class="doctor-photo">
            <div class="placeholder-photo">👨‍⚕️</div>
          </div>
          <div class="doctor-info">
            <h3 class="doctor-name">{{ doctor.name }}</h3>
            <div class="doctor-details">
              <p class="specialization">{{ doctor.specialization }}</p>
              <p class="experience">{{ doctor.experience }} experience</p>
              <p class="rating">Rating: {{ doctor.rating }}/5</p>
            </div>
            <div class="doctor-location">
              <span class="location-icon">📍</span> 
              <span>{{ doctor.city }}</span>
            </div>
            <button class="contact-button">Contact</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
:global(html), :global(body) {
  margin: 0; padding: 0; width: 100%; height: 100%;
  overflow-x: hidden; box-sizing: border-box;
}

:global(#app) {
  margin: 0; padding: 0; width: 100%; height: 100%;
}

.doctor-finder-container {
  min-height: 100vh; width: 100%;
  background: linear-gradient(135deg, #e0f7fa, #ffe6f0, #f0f9ff);
  font-family: 'Poppins', sans-serif;
  display: flex; flex-direction: column; color: #333;
  margin: 0; padding: 0; position: relative;
  height: auto; overflow: auto;
}

.dark {
  background: linear-gradient(135deg, #1a2435, #2d2d3a, #1a1f2c);
  color: #f1f1f1;
}

.navbar {
  background-color: white; display: flex;
  justify-content: space-between; align-items: center;
  padding: 15px 30px; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  position: sticky; top: 0; z-index: 100;
  width: 100%; box-sizing: border-box;
}

.dark .navbar {
  background-color: #2a2a2a;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
}

.logo {
  font-size: 1.5rem; font-weight: 600; color: #3b82f6;
}

.dark .logo { color: #60a5fa; }

.nav-right {
  display: flex; align-items: center;
  justify-content: flex-end;
}

.nav-actions {
  display: flex; align-items: center; gap: 10px;
}

.theme-button, .back-button, .logout-button {
  background-color: #f3f4f6; color: #4b5563;
  border: none; padding: 10px 15px; border-radius: 10px;
  font-weight: 500; cursor: pointer; transition: all 0.3s ease;
}

.dark .theme-button, .dark .back-button, .dark .logout-button {
  background-color: #4b5563; color: #f3f4f6;
}

.theme-button:hover, .back-button:hover, .logout-button:hover {
  background-color: #e5e7eb; color: #1f2937;
}

.dark .theme-button:hover, .dark .back-button:hover, .dark .logout-button:hover {
  background-color: #6b7280;
}

.content-section {
  padding: 30px; max-width: 900px;
  margin: 0 auto; width: 100%; flex: 1;
}

.page-header {
  margin-bottom: 25px; text-align: center;
}

h1 {
  color: #1f2937; font-size: 2.2rem;
  margin-bottom: 10px; font-weight: 600;
}

.dark h1 { color: #f3f4f6; }

.subtitle {
  color: #6b7280; font-size: 1.1rem; margin-bottom: 0;
}

.dark .subtitle { color: #d1d5db; }

.search-section {
  display: flex; flex-direction: column;
  gap: 15px; margin-bottom: 30px;
  background-color: white; padding: 20px;
  border-radius: 16px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.dark .search-section {
  background-color: #2a2a2a;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
}

.location-search {
  display: flex; gap: 10px; width: 100%;
}

.location-input {
  flex: 1; padding: 12px 15px;
  border: 1px solid #e5e7eb; border-radius: 10px;
  font-size: 1rem; outline: none;
  background-color: #f9fafb; transition: all 0.3s ease;
}

.dark .location-input {
  background-color: #374151; border-color: #4b5563;
  color: #f3f4f6;
}

.location-input:focus {
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.3);
}

.search-button {
  background-color: #3b82f6; color: white;
  border: none; padding: 12px 20px; border-radius: 10px;
  font-weight: 500; cursor: pointer; transition: all 0.3s ease;
  display: flex; align-items: center; justify-content: center;
}

.dark .search-button {
  background-color: #2563eb;
}

.search-button:hover {
  background-color: #2563eb;
}

.dark .search-button:hover {
  background-color: #1d4ed8;
}

.location-button {
  width: 100%; padding: 12px;
  background-color: #f3f4f6; color: #4b5563;
  border: none; border-radius: 10px;
  font-weight: 500; cursor: pointer;
  transition: all 0.3s ease; display: flex;
  align-items: center; justify-content: center;
}

.dark .location-button {
  background-color: #4b5563; color: #f3f4f6;
}

.location-button:hover {
  background-color: #e5e7eb;
}

.dark .location-button:hover {
  background-color: #6b7280;
}

.loading-state, .error-state, .empty-state {
  text-align: center; padding: 40px;
  background-color: white; border-radius: 16px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  margin-bottom: 20px;
}

.dark .loading-state, .dark .error-state, .dark .empty-state {
  background-color: #2a2a2a;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
}

.loading-spinner {
  display: inline-block; width: 40px; height: 40px;
  border: 4px solid rgba(59, 130, 246, 0.2);
  border-radius: 50%; border-top-color: #3b82f6;
  animation: spin 1s linear infinite;
  margin-bottom: 15px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.error-state p {
  color: #ef4444; margin-bottom: 15px;
}

.retry-button {
  background-color: #3b82f6; color: white;
  border: none; padding: 10px 20px; border-radius: 10px;
  font-weight: 500; cursor: pointer; transition: all 0.3s ease;
}

.dark .retry-button {
  background-color: #2563eb;
}

.retry-button:hover {
  background-color: #2563eb;
}

.doctors-list {
  display: flex; flex-direction: column; gap: 20px;
}

.doctor-card {
  display: flex; background-color: white;
  border-radius: 16px; overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
}

.dark .doctor-card {
  background-color: #2a2a2a;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
}

.doctor-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 15px rgba(0, 0, 0, 0.1);
}

.dark .doctor-card:hover {
  box-shadow: 0 8px 15px rgba(0, 0, 0, 0.3);
}

.doctor-photo {
  width: 120px; background-color: #f3f4f6;
  display: flex; align-items: center; justify-content: center;
}

.dark .doctor-photo {
  background-color: #374151;
}

.placeholder-photo {
  font-size: 3rem;
}

.doctor-info {
  flex: 1; padding: 20px;
  display: flex; flex-direction: column;
}

.doctor-name {
  font-size: 1.3rem; font-weight: 600;
  color: #1f2937; margin-bottom: 10px;
}

.dark .doctor-name { color: #f3f4f6; }

.doctor-details {
  display: flex; flex-wrap: wrap;
  gap: 15px; margin-bottom: 15px;
}

.specialization, .experience, .rating {
  background-color: #f3f4f6; color: #4b5563;
  padding: 5px 10px; border-radius: 20px;
  font-size: 0.9rem;
}

.dark .specialization, .dark .experience, .dark .rating {
  background-color: #374151; color: #d1d5db;
}

.doctor-location {
  margin-bottom: 15px; display: flex;
  align-items: center; gap: 5px;
  color: #6b7280; font-size: 0.95rem;
}

.dark .doctor-location { color: #9ca3af; }

.contact-button {
  align-self: flex-start;
  background-color: #3b82f6; color: white;
  border: none; padding: 10px 15px; border-radius: 8px;
  font-weight: 500; cursor: pointer; transition: all 0.3s ease;
}

.dark .contact-button {
  background-color: #2563eb;
}

.contact-button:hover {
  background-color: #2563eb;
}

@media (max-width: 768px) {
  .navbar { padding: 15px; }
  .nav-actions { flex-wrap: wrap; }
  .theme-button, .back-button, .logout-button { 
    font-size: 0.9rem;
    padding: 8px 12px;
  }
  .content-section { padding: 20px; }
  .doctor-card { flex-direction: column; }
  .doctor-photo { 
    width: 100%; height: 100px;
  }
  .search-section { 
    flex-direction: column;
  }
  .location-search {
    flex-direction: column;
  }
  .doctor-details {
    flex-direction: column;
    gap: 8px;
  }
}
</style>
