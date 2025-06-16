<script setup>
import { onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'

const pharmacies = ref([])
const isLoading = ref(true)
const error = ref(null)

onMounted(async () => {
  try {
    const response = await fetch('http://localhost:5000/api/pharmacies') // replace with your backend URL
    const data = await response.json()
    pharmacies.value = data.pharmacies // assume backend returns { pharmacies: [...] }
  } catch (err) {
    error.value = 'Failed to fetch pharmacies. Please try again later.'
  } finally {
    isLoading.value = false
  }
})
</script>

<template>
  <div class="pharmacy-container">
    <div class="top-bar">
      <RouterLink to="/userdashboard" class="home-btn">🏠 Home</RouterLink>
      <h2>🏥 Nearby Pharmacies</h2>
    </div>

    <div v-if="isLoading" class="loading">Loading pharmacies...</div>
    <div v-if="error" class="error">{{ error }}</div>

    <div class="pharmacy-grid" v-if="!isLoading && !error">
      <div v-for="pharmacy in pharmacies" :key="pharmacy.id" class="pharmacy-card">
        <h3>{{ pharmacy.name }}</h3>
        <p>📍 {{ pharmacy.address }}</p>
        <p>📞 {{ pharmacy.contact }}</p>
        <a v-if="pharmacy.mapLink" :href="pharmacy.mapLink" target="_blank" class="map-link">🗺️ View on Map</a>
      </div>
    </div>
  </div>
</template>

<style scoped>
.pharmacy-container {
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
  padding: 6px 12px;
  border-radius: 5px;
  font-size: larger;
}
.loading,
.error {
  text-align: center;
  margin-top: 20px;
  color: #d32f2f;
  font-weight: bold;
}
.pharmacy-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
}
.pharmacy-card {
  background: #e0f2f1;
  border-left: 6px solid #00796b;
  padding: 15px;
  border-radius: 10px;
  box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}
.map-link {
  display: inline-block;
  margin-top: 8px;
  background: #00796b;
  color: white;
  padding: 6px 10px;
  border-radius: 4px;
  text-decoration: none;
}
.map-link:hover {
  background: #004d40;
}
</style>
