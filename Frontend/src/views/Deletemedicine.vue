<script setup>
import { ref, onMounted } from 'vue'
import { RouterLink } from 'vue-router'


const reminders = ref([])
const token = localStorage.getItem('token')


async function fetchReminders() {
  try {
    const res = await fetch('/api/reminders', {
      headers: {
        Authorization: `Bearer ${token}`
      }
    })
    reminders.value = await res.json()
  } catch (err) {
    console.error('Error fetching reminders:', err)
  }
}


async function deleteReminder(id) {
  try {
    await fetch(`/api/reminders/${id}`, {
      method: 'DELETE',
      headers: {
        Authorization: `Bearer ${token}`
      }
    })
    reminders.value = reminders.value.filter(r => r.id !== id)
  } catch (err) {
    console.error('Error deleting reminder:', err)
  }
}

onMounted(fetchReminders)
</script>

<template>
  <div class="medicine-reminder-page container py-4">

    <div class="navbar navbar-dark bg-danger px-4 d-flex justify-content-between align-items-center mb-4">
      <RouterLink class="home-btn" to="/userdashboard">🏠 Home</RouterLink>
      <h2 class="heading text-white">🗑️ Delete Medicine Reminders</h2>
    </div>

    <div v-if="reminders.length > 0">
      <div
        class="card shadow-sm mb-3"
        v-for="reminder in reminders"
        :key="reminder.id"
      >
        <div class="card-header bg-light d-flex justify-content-between align-items-center">
          <div>
            <strong>{{ reminder.name }}</strong> — {{ reminder.time }} ({{ reminder.frequency }})
            <br />
            <small>Type: {{ reminder.notificationType }}</small>
          </div>
          <button
            class="btn btn-outline-danger btn-sm"
            @click="deleteReminder(reminder.id)"
          >
            🗑️ Delete
          </button>
        </div>
      </div>
    </div>
    <div v-else class="text-muted text-center">No reminders to delete.</div>
  </div>
</template>

<style scoped>
.card {
  border-radius: 12px;
}

.card-header {
  font-weight: bold;
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
  font-size: larger;
}
</style>
