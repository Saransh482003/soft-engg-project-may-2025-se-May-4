<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { auth } from '@/stores/auth';

const router = useRouter();
const auth_store = auth();
const isDarkMode = ref(localStorage.getItem('darkModePreference') === 'dark');
const pharmacies = ref([]);
const loading = ref(false);
const error = ref('');
const locationFetched = ref(false);
const locationSearch = ref('');
const searchPerformed = ref(false);

const mockPharmacies = [
  { 
    id: 1,
    name: 'MedPlus Pharmacy',
    phone: '+91 98765 43210',
    website: 'www.medplus.com',
    city: 'Bangalore',
    rating: 4.7,
    openHours: '8:00 AM - 10:00 PM',
    deliveryAvailable: true
  },
  { 
    id: 2,
    name: 'Apollo Pharmacy',
    phone: '+91 87654 32109',
    website: 'www.apollopharmacy.in',
    city: 'Mumbai',
    rating: 4.5,
    openHours: '24 Hours',
    deliveryAvailable: true
  },
  { 
    id: 3,
    name: 'Health & Glow',
    phone: '+91 76543 21098',
    website: 'www.healthandglow.com',
    city: 'Chennai',
    rating: 4.3,
    openHours: '9:00 AM - 9:00 PM',
    deliveryAvailable: true
  },
  { 
    id: 4,
    name: 'Wellness Forever',
    phone: '+91 65432 10987',
    website: 'www.wellnessforever.com',
    city: 'Delhi',
    rating: 4.6,
    openHours: '7:00 AM - 11:00 PM',
    deliveryAvailable: false
  },
  { 
    id: 5,
    name: 'MedLife Pharmacy',
    phone: '+91 54321 09876',
    website: 'www.medlife.com',
    city: 'Hyderabad',
    rating: 4.4,
    openHours: '8:00 AM - 10:00 PM',
    deliveryAvailable: true
  }
];

const displayedPharmacies = computed(() => {
  if (locationSearch.value.trim() === '') {
    return pharmacies.value;
  }
  
  const search = locationSearch.value.toLowerCase();
  return pharmacies.value.filter(pharmacy => 
    pharmacy.name.toLowerCase().includes(search) || 
    pharmacy.city.toLowerCase().includes(search)
  );
});

async function fetchPharmacies(lat, lon) {
  loading.value = true;
  error.value = '';

  try {

    setTimeout(() => {
      pharmacies.value = mockPharmacies;
      loading.value = false;
    }, 800); 
  } catch (err) {
    error.value = 'Failed to fetch pharmacies.';
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
      fetchPharmacies(latitude, longitude);
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
    pharmacies.value = mockPharmacies;
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
  <div class="pharmacy-finder-container" :class="{ 'dark': isDarkMode }">
    <nav class="navbar">
      <div class="logo">
        <span>SHRAVAN</span>
      </div>
      <div class="nav-right">
        <div class="nav-actions">
          <button class="theme-button" @click="toggleDarkMode">
            {{ isDarkMode ? 'Light' : 'Dark' }}
          </button>
          <button class="back-button" @click="goHome">Back to Home</button>
          <button class="logout-button" @click="logout">Logout</button>
        </div>
      </div>
    </nav>

    <div class="content-section">
      <div class="page-header">
        <h1>Find Nearby Pharmacies</h1>
        <p class="subtitle">Discover pharmacies and medical stores in your area</p>
      </div>

      <div class="search-section">
        <div class="location-search">
          <input 
            type="text" 
            v-model="locationSearch" 
            placeholder="Enter location or pharmacy name" 
            class="location-input"
            @keyup.enter="manualSearch"
          >
          <button class="search-button" @click="manualSearch">
            Search
          </button>
        </div>

        <button class="location-button" @click="getLocation">
          Use Current Location
        </button>
      </div>

      <div v-if="loading" class="loading-state">
        <div class="loading-spinner"></div>
        <p>Finding pharmacies...</p>
      </div>

      <div v-if="error" class="error-state">
        <p>{{ error }}</p>
        <button class="retry-button" @click="getLocation">Try Again</button>
      </div>

      <div v-if="!loading && !error && displayedPharmacies.length === 0 && searchPerformed" class="empty-state">
        <p>No pharmacies found in this area. Try a different location.</p>
      </div>

      <div v-if="!loading && displayedPharmacies.length > 0" class="pharmacies-list">
        <div v-for="pharmacy in displayedPharmacies" :key="pharmacy.id" class="pharmacy-card">
          <div class="pharmacy-info">
            <h3 class="pharmacy-name">{{ pharmacy.name }}</h3>
            <div class="pharmacy-details">
              <span class="info-item">Rating: {{ pharmacy.rating }}/5</span>
              <span class="info-item">Hours: {{ pharmacy.openHours }}</span>
              <span class="info-item">🚚 Delivery: {{ pharmacy.deliveryAvailable ? 'Yes' : 'No' }}</span>
              <span class="info-item">📍 Location: {{ pharmacy.city }}</span>
            </div>
            <div class="pharmacy-contact">
              <p class="contact-item">
                <a :href="`tel:${pharmacy.phone.replace(/\s+/g, '')}`" class="contact-link">
                  📞 {{ pharmacy.phone }}
                </a>
              </p>
              <p class="contact-item">
                <a :href="`https://${pharmacy.website}`" target="_blank" class="website-link">
                  🌐 {{ pharmacy.website }}
                </a>
              </p>
            </div>
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

.pharmacy-finder-container {
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

.pharmacies-list {
  display: flex; flex-direction: column; gap: 15px;
}

.pharmacy-card {
  display: flex; background-color: white;
  border-radius: 16px; overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease; padding: 15px;
}

.dark .pharmacy-card {
  background-color: #2a2a2a;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
}

.pharmacy-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 15px rgba(0, 0, 0, 0.1);
}

.dark .pharmacy-card:hover {
  box-shadow: 0 8px 15px rgba(0, 0, 0, 0.3);
}

.pharmacy-info {
  flex: 1;
  display: flex; flex-direction: column;
}

.pharmacy-name {
  font-size: 1.2rem; font-weight: 600;
  color: #1f2937; margin-top: 0; margin-bottom: 8px;
}

.dark .pharmacy-name { color: #f3f4f6; }

.pharmacy-details {
  display: flex; flex-wrap: wrap;
  gap: 8px; margin-bottom: 10px;
}

.info-item {
  background-color: #f3f4f6; color: #4b5563;
  padding: 4px 8px; border-radius: 4px;
  font-size: 0.85rem;
}

.dark .info-item {
  background-color: #374151; color: #d1d5db;
}

.pharmacy-contact {
  display: flex;
  flex-direction: column;
  gap: 3px;
  font-size: 0.9rem;
}

.contact-item {
  margin: 0;
}

.contact-link, .website-link {
  color: #4b5563;
  text-decoration: none;
  transition: all 0.2s ease;
}

.dark .contact-link, .dark .website-link {
  color: #d1d5db;
}

.contact-link:hover, .website-link:hover {
  color: #3b82f6;
  text-decoration: underline;
}

.dark .contact-link:hover, .dark .website-link:hover {
  color: #60a5fa;
}

@media (max-width: 768px) {
  .navbar { padding: 15px; }
  .nav-actions { flex-wrap: wrap; }
  .theme-button, .back-button, .logout-button { 
    font-size: 0.9rem;
    padding: 8px 12px;
  }
  .content-section { padding: 20px; }
  .search-section { flex-direction: column; }
  .location-search { flex-direction: column; }
  .pharmacy-details { flex-direction: column; gap: 5px; }
}
</style>
