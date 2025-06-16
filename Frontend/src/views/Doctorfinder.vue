<script setup>
import { ref, onMounted } from 'vue'

const doctors = ref([])
const loading = ref(false)
const error = ref('')
const locationFetched = ref(false)

async function fetchDoctors(lat, lon) {
  loading.value = true
  error.value = ''

  try {
    // Simulated backend call - replace with actual fetch call to your backend
    // Example: const res = await fetch(`https://yourapi.com/doctors?lat=${lat}&lon=${lon}`)
    // doctors.value = await res.json()

    // Mock data for demo
    doctors.value = [
      { name: 'Dr. Kavitha R.', specialization: 'Cardiologist', distance: '1.2 km' },
      { name: 'Dr. Rajesh Kumar', specialization: 'Physician', distance: '2.0 km' },
      { name: 'Dr. Anitha Menon', specialization: 'Dermatologist', distance: '2.5 km' }
    ]
  } catch (err) {
    error.value = 'Failed to fetch doctors.'
  } finally {
    loading.value = false
  }
}

function getLocation() {
  if (!navigator.geolocation) {
    error.value = 'Geolocation is not supported by your browser.'
    return
  }

  navigator.geolocation.getCurrentPosition(
    (position) => {
      const { latitude, longitude } = position.coords
      locationFetched.value = true
      fetchDoctors(latitude, longitude)
    },
    () => {
      error.value = 'Unable to retrieve your location.'
    }
  )
}

onMounted(() => {
  getLocation()
})
</script>

<template>
  <div class="doctor-container">
    <div class="top-bar">
      <RouterLink to="/userdashboard" class="home-btn">🏠 Home</RouterLink>
      <h2>🩺 Find Nearby Doctors</h2>
    </div>

    <div v-if="loading" class="status">⏳ Finding nearby doctors...</div>
    <div v-if="error" class="error">{{ error }}</div>

    <div v-if="!loading && locationFetched && doctors.length > 0" class="doctor-list">
      <div v-for="doc in doctors" :key="doc.name" class="doctor-card">
        <h4>{{ doc.name }}</h4>
        <p>👨‍⚕️ {{ doc.specialization }}</p>
        <p>📍 {{ doc.distance }}</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.doctor-container {
  padding: 20px;
  font-family: sans-serif;
}
.top-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background-color: #ffe6f0;
  color: black;
  padding: 10px 20px;
  border-radius: 10px;
  margin-bottom: 20px;
}
.home-btn {
  text-decoration: none;
  color: black;
  background: #ffe6f0;
  padding: 5px 10px;
  border-radius: 5px;
  font-size: larger;
}
.doctor-list {
  display: grid;
  gap: 15px;
}
.doctor-card {
  background-color: #f8f9fa;
  padding: 15px;
  border-left: 5px solid #007bff;
  border-radius: 10px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}
.status {
  color: #555;
  font-weight: bold;
}
.error {
  color: red;
  font-weight: bold;
}
</style>
