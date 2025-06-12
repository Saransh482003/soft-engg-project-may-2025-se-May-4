<template>
  <div class="medicine-reminder-page">
    <!-- Top Bar -->
    <nav class="navbar navbar-dark bg-primary px-4">
      <RouterLink class="btn btn-light" to="/userdashboard">🏠 Home</RouterLink>
    </nav>

    <!-- Main Content -->
    <div class="container py-4">
       <h1 class="heading">💊 Medicine Reminders</h1>
      <!-- Add Reminder Card -->
      <div class="card shadow-sm mb-4">
        <div class="card-header bg-info text-white">
          ➕ Add New Reminder
        </div>
        <div class="card-body">
          <form @submit.prevent="addReminder">
            <div class="mb-3">
              <label class="form-label">Medicine Name</label>
              <input v-model="newReminder.name" type="text" class="form-control" required />
            </div>
            <div class="mb-3">
              <label class="form-label">Time</label>
              <input v-model="newReminder.time" type="time" class="form-control" required />
            </div>
            <div class="mb-3">
              <label class="form-label">Frequency</label>
              <select v-model="newReminder.frequency" class="form-select">
                <option>Daily</option>
                <option>Weekly</option>
                <option>Alternate Days</option>
              </select>
            </div>
            <div class="mb-3">
              <label class="form-label">Notification Type</label>
              <div class="form-check" v-for="type in ['SMS', 'Voice', 'Both']" :key="type">
                <input class="form-check-input" type="radio" :id="type" v-model="newReminder.notificationType" :value="type" />
                <label class="form-check-label" :for="type">{{ type }}</label>
              </div>
            </div>
            <button class="btn btn-success">Save Reminder</button>
          </form>
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
            <button class="btn btn-sm btn-outline-danger" @click="deleteReminder(reminder.id)">🗑️</button>
          </li>
        </ul>
        <div class="p-3 text-muted" v-else>No reminders yet.</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { RouterLink } from 'vue-router'

// Reminder data
const reminders = ref([])
const newReminder = ref({
  name: '',
  time: '',
  frequency: 'Daily',
  notificationType: 'SMS'
})

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
    console.error('Error fetching reminders:', err)
  }
}

// Add reminder
async function addReminder() {
  try {
    const res = await fetch('/api/reminders', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`
      },
      body: JSON.stringify(newReminder.value)
    })
    const added = await res.json()
    reminders.value.push(added)
    newReminder.value = { name: '', time: '', frequency: 'Daily', notificationType: 'SMS' }
  } catch (err) {
    console.error('Error adding reminder:', err)
  }
}

// Delete reminder
async function deleteReminder(id) {
  try {
    await fetch(`/api/reminders/${id}`, {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${token}` }
    })
    reminders.value = reminders.value.filter(r => r.id !== id)
  } catch (err) {
    console.error('Error deleting reminder:', err)
  }
}

onMounted(fetchReminders)
</script>

<style scoped>
.medicine-reminder-page {
  background-color: #f5f9fc;
  min-height: 100vh;
  text-align: center;
}

.card {
  border-radius: 12px;
}

.card-header {
  font-weight: bold;
  font-size: 1.1rem;
}

.navbar{
  background-color: lightblue;
  font-size: larger;
  text-align: right;
}
.heading{
text-align: center;
}
</style>
