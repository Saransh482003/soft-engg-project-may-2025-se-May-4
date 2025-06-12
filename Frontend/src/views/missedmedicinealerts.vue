<script setup>
import { onMounted, ref } from 'vue';

const missed = ref([]);

onMounted(async () => {
  const caretakerEmail = localStorage.getItem('email'); // caretaker's email
  const response = await fetch('http://localhost:3000/api/missed-medicines', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ caretakerEmail })
  });

  const data = await response.json();
  missed.value = data.missedMedicines || [];
});
</script>

<template>
  <div class="container mt-4">
    <div class="top-bar">
      <RouterLink to="/userdashboard" class="home-btn">🏠 Home</RouterLink>
      <h2>❗ Missed Medicine Alerts</h2>
    </div>


    <div v-if="missed.length > 0">
      <div class="card mb-2" v-for="(med, index) in missed" :key="index">
        <div class="card-body">
          <h5 class="card-title">{{ med.medicine }}</h5>
          <p class="card-text">⏰ Scheduled At: {{ med.time }}</p>
          <p class="card-text text-danger">⚠️ Missed</p>
        </div>
      </div>
    </div>
    <div v-else class="alert alert-success">
      ✅ No missed medicines reported.
    </div>
  </div>
</template>


<style scoped>
.container {
  padding: 20px;
  font-family: sans-serif;
}
.top-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background-color: #4caf50;
  color: white;
  padding: 10px 20px;
  border-radius: 10px;
  margin-bottom: 20px;
}
.home-btn {
  text-decoration: none;
  color: white;
  background: #388e3c;
  padding: 6px 12px;
  border-radius: 5px;
}
.card {
  border-left: 5px solid #dc3545;
  background-color: #fff4f4;
}
</style>
