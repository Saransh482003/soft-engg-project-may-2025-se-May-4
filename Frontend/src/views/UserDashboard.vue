<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import EmergencySOS from './EmergencySOS.vue';

const router = useRouter();
const isDarkMode = ref(false);

function toggleDarkMode() {
  isDarkMode.value = !isDarkMode.value;
  document.body.classList.toggle('dark-mode', isDarkMode.value);
}

function goToFeature(path) {
  router.push(path); // placeholder navigation; use actual paths when implementing features
}
</script>

<template>
  <div class="dashboard-container" :class="{ 'dark': isDarkMode }">
    <h1 class="text-center">👵 Welcome to SHARVAN Dashboard</h1>
    <p class="text-center subtitle">Empowering your golden years with technology</p>
     <EmergencySOS /><br>
    <div class="grid-container">
      <div class="card" @click="goToFeature('/medicinereminders')">💊 Medicine Reminders</div>
      <div class="card" @click="goToFeature('/doctor-finder')">🩺 Doctor Finder</div>
      <div class="card" @click="goToFeature('/chatbot')">🗣️ Voice-Based Chatbot</div>
      <div class="card" @click="goToFeature('/yoga-videos')">🧘‍♀️ Age-Friendly Yoga</div>
      <div class="card" @click="goToFeature('/pharmacy-locator')">🏪 Pharmacy Locator</div>
      <div class="card" @click="goToFeature('/voice-reminders')">🗨️ Set Reminders by Voice</div>
      <div class="card" @click="toggleDarkMode">🌓 Toggle Dark Mode</div>
    </div>
  </div>
</template>

<style scoped>
.dashboard-container {
  padding: 2rem;
  background: linear-gradient(to right, #f0f8ff, #e6f7ff);
  min-height: 100vh;
  color: #333;
}

.dark {
  background: #1f1f1f;
  color: #f1f1f1;
}

h1 {
  font-size: 2rem;
  margin-bottom: 0.5rem;
}

.subtitle {
  margin-bottom: 2rem;
  color: #555;
}

.toggle-mode {
  display: flex;
  justify-content: center;
  margin-bottom: 2rem;
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
  background: #d0ebff;
  transform: scale(1.03);
}

.dark .card {
  background: #2a2a2a;
  color: #eee;
}

.dark .card:hover {
  background: #444;
}
</style>
