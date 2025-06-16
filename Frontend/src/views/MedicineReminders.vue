<script setup>
import { ref, onMounted } from 'vue'
import { RouterLink } from 'vue-router'

// Reminder data
const reminders = ref([]);


// Simulated token
const token = localStorage.getItem('token')

// Fetch reminders from backend
async function fetchReminders() {
  try {
    const res = await fetch('/api/reminders', {
      headers: { Authorization: `Bearer ${token}` }
    })
    reminders.value = await res.json()
  } catch (err) {
    console.error('Error fetching reminders:', err);
  }
}

// Delete reminder
async function markReminder(id) {
  try {
    await fetch(`/api/reminders/${id}`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`
      }
    })
    reminders.value = reminders.value.filter(r => r.id !== id)
  } catch (err) {
    console.error('Error marking reminder:', err)
  }
}

onMounted(fetchReminders)
</script>

<template>
  <div class="medicine-reminder-page">
    <div class="navbar navbar-dark bg-primary px-4">
      <RouterLink class="home-btn" to="/userdashboard">🏠 Home</RouterLink>
      <RouterLink class="add-btn" to="/addmedicinealert">➕ Add Medicine</RouterLink>
      <RouterLink class="delete-btn" to="/deletemedicinealert">🗑️ Delete Medicine</RouterLink>
      <h2 class="heading">💊 Medicine Reminders</h2>
    </div>
  </div>

      <!-- Reminder List -->
      <div class="card shadow-sm">
        <div class="card-header bg-secondary text-white">
          📝 Your Reminders
        </div>
        <ul class="list-group list-group-flush" v-if="reminders.length > 0">
          <li v-for="reminder in reminders" :key="reminder.id" class="list-group-item d-flex justify-content-between align-items-start">
            <div>
              <strong>{{ reminder.name }}</strong> — {{ reminder.time }} ({{ reminder.frequency }})
              <br />
              <small>Type: {{ reminder.notificationType }}</small>
            </div>
            <button class="btn btn-sm btn-outline-danger" @click="markReminder(reminder.id)">🗑️</button>
          </li>
        </ul>
        <div class="p-3 text-muted" v-else>No reminders yet.</div>
      </div>
</template>

<style scoped>

.navbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background-color: #f8bbd0;
  color: black;
  padding: 10px 20px;
  border-radius: 10px;
  margin-bottom: 20px;
}
.home-btn {
  text-decoration: none;
  color: black;
  background: #f8bbd0;
  padding: 6px 12px;
  border-radius: 5px;
  font-size: larger;
}
.add-btn{
  text-decoration: none;
  color: black;
  background: #f8bbd0;
  padding: 6px 12px;
  border-radius: 5px;
  font-size: larger;
}
.delete-btn{
  text-decoration: none;
  color: black;
  background: #f8bbd0;
  padding: 6px 12px;
  border-radius: 5px;
  font-size: larger;
}


.card {
  border-radius: 12px;
}

.card-header {
  font-weight: bold;
  font-size: 1.1rem;
}

.heading{
text-align: center;
}
</style>
