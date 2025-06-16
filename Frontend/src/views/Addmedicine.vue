<script setup>
import { ref } from 'vue'
import { RouterLink } from 'vue-router'

const token = localStorage.getItem('token')

const newReminder = ref({
  name: '',
  time: '',
  frequency: 'Daily',
  notificationType: 'SMS'
})

const reminders = ref([]) // Dummy for this page if you need it

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
</script>
<template>
    <div class="navbar navbar-dark bg-primary px-4 d-flex justify-content-between align-items-center">
      <RouterLink class="home-btn" to="/userdashboard">🏠 Home</RouterLink>
      <h2 class="heading text-white">💊Add Medicine Reminders</h2>
    </div>

    <div class="card shadow-sm mb-4 mt-3">
      <div class="card-header bg-info text-white">
        ➕ Add New Reminder
      </div><br>
      <div class="card-body">
        <form @submit.prevent="addReminder">
          <div class="mb-3">
            <label class="form-label">Medicine Name</label>
            <input v-model="newReminder.name" type="text" class="form-control" required />
          </div><br>
          <div class="mb-3">
            <label class="form-label">Time</label>
            <input v-model="newReminder.time" type="time" class="form-control" required />
          </div><br>
          <div class="mb-3">
            <label class="form-label">Frequency</label>
            <select v-model="newReminder.frequency" class="form-select">
              <option>Daily</option>
              <option>Weekly</option>
              <option>Alternate Days</option>
            </select>
          </div><br>
          <div class="mb-3">
            <label class="form-label">Notification Type</label>
            <div class="form-check" v-for="type in ['SMS', 'Voice', 'Both']" :key="type">
              <input class="form-check-input" type="radio" :id="type" v-model="newReminder.notificationType" :value="type" />
              <label class="form-check-label" :for="type">{{ type }}</label>
            </div><br>
          </div>
          <button class="btn btn-success">Add Reminder</button>
        </form>
      </div>
    </div>
</template>

<style scoped>
.card {
  border-radius: 12px;
}

.card-header {
  font-weight: bold;
  font-size: 1.1rem;
}

.heading {
  text-align: center;
}


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
}
</style>
