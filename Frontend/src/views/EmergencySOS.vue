<script setup>
import { ref } from 'vue'
import axios from 'axios'

const statusMessage = ref('')

async function triggerSOS() {
  statusMessage.value = 'Sending alert...';

  try {

    const location = await getLocation();

    const payload = {
      message: '🚨 Emergency Alert from SHARVAN App!',
      location: location ? location : 'Location not available'
    };


    const response = await axios.post('/api/send-sos', payload);

    if (response.data.success) {
      statusMessage.value = '✅ Alert sent successfully!';
    } else {
      statusMessage.value = '⚠️ Failed to send alert.';
    }
  } catch (err) {
    statusMessage.value = '❌ Error: ' + err.message;
  }
}

function getLocation() {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      resolve(null);
      return;
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        const coords = `https://www.google.com/maps?q=${position.coords.latitude},${position.coords.longitude}`;
        resolve(coords);
      },
      () => resolve(null), 
      { timeout: 10000 }
    );
  });
}
</script>

<template>
  <div class="sos-container">
    <button class="btn btn-danger sos-btn" @click="triggerSOS">🚨 Emergency SOS</button>
    <p v-if="statusMessage" class="text-success mt-2">{{ statusMessage }}</p>
  </div>
</template>


<style scoped>
.sos-container {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.sos-btn {
  font-size: 1.2rem;
  padding: 10px 25px;
  background-color: #d9534f;
  border: none;
  border-radius: 10px;
  color: white;
  font-weight: bold;
}

.sos-btn:hover {
  background-color: #c9302c;
}
</style>
