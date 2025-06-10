<script setup>
import { useRouter } from 'vue-router';
const router = useRouter();

function goToFeature(path) {
  router.push(path); // Update with correct route path later
}
</script>

<template>
  <div class="dashboard-container">
    <h1 class="text-center">👨‍👩‍👧 Caregiver Dashboard</h1>
    <p class="text-center subtitle">Helping loved ones stay safe and healthy</p>

    <div class="grid-container">
      <div class="card" @click="goToFeature('/missed-alerts')">🚨 Missed Medicine Alerts</div>
      <div class="card" @click="goToFeature('/daily-health')">📊 Daily Health Updates</div>
      <div class="card" @click="goToFeature('/live-location')">📍 Live Location Access</div>
    </div>
  </div>
</template>

<style scoped>
.dashboard-container {
  padding: 2rem;
  background: linear-gradient(to right, #fff0f5, #f3f0ff);
  min-height: 100vh;
  color: #333;
}

h1 {
  font-size: 2rem;
  margin-bottom: 0.5rem;
}

.subtitle {
  margin-bottom: 2rem;
  color: #555;
}

.grid-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 1rem;
}

.card {
  background: #ffffff;
  border-radius: 12px;
  padding: 1rem;
  text-align: center;
  font-size: 1.1rem;
  font-weight: bold;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  transition: transform 0.2s, background 0.3s;
  cursor: pointer;
}

.card:hover {
  background: #e0cfff;
  transform: scale(1.03);
}
</style>
