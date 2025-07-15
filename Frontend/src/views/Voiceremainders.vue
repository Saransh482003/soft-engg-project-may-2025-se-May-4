<script setup>
import { ref, onMounted } from 'vue'
import { RouterLink } from 'vue-router'

const token = localStorage.getItem('token')
const title = ref('')
const selectedFile = ref(null)
const voiceReminders = ref([])


function handleFileUpload(event) {
  selectedFile.value = event.target.files[0]
}


async function uploadReminder() {
  if (!selectedFile.value) return

  const formData = new FormData()
  formData.append('title', title.value)
  formData.append('audio', selectedFile.value)

  try {
    const res = await fetch('/api/voice-reminders', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`
      },
      body: formData
    })
    const saved = await res.json()
    voiceReminders.value.push(saved)
    title.value = ''
    selectedFile.value = null
  } catch (err) {
    console.error('Upload failed:', err)
  }
}


async function fetchVoiceReminders() {
  try {
    const res = await fetch('/api/voice-reminders', {
      headers: { Authorization: `Bearer ${token}` }
    })
    voiceReminders.value = await res.json()
  } catch (err) {
    console.error('Error fetching voice reminders:', err)
  }
}

onMounted(fetchVoiceReminders)
</script>

<template>
  <div class="voice-reminder-page">

    <nav class="navbar navbar-dark bg-primary px-4">
      <RouterLink class="home-btn" to="/userdashboard">🏠 Home</RouterLink>
      <h2 class="heading">🔊 Voice Reminders</h2>
    </nav>

    <div class="container py-4">

      <div class="card shadow-sm mb-4">
        <div class="card-header bg-info text-white">🎙️ Add New Voice Reminder</div>
        <div class="card-body">
          <form @submit.prevent="uploadReminder">
            <div class="mb-3">
              <label class="form-label">Reminder Title</label>
              <input v-model="title" type="text" class="form-control" required />
            </div>
            <div class="mb-3">
              <label class="form-label">Choose Audio File</label>
              <input type="file" accept="audio/*" class="form-control" @change="handleFileUpload" required />
            </div>
            <button class="btn btn-success">Upload Reminder</button>
          </form>
        </div>
      </div>


      <div class="card shadow-sm">
        <div class="card-header bg-secondary text-white">📁 Saved Voice Reminders</div>
        <ul class="list-group list-group-flush" v-if="voiceReminders.length > 0">
          <li v-for="reminder in voiceReminders" :key="reminder.id" class="list-group-item d-flex justify-content-between align-items-start">
            <div>
              <strong>{{ reminder.title }}</strong>
              <br />
              <audio :src="reminder.audioUrl" controls />
            </div>
          </li>
        </ul>
        <div class="p-3 text-muted" v-else>No voice reminders yet.</div>
      </div>
    </div>
  </div>
</template>

<style scoped>

.heading {
  text-align: right;
  flex-grow: 1;
  color: black;
}

.card {
  border-radius: 12px;
}

.card-header {
  font-weight: bold;
  font-size: 1.1rem;
}

.navbar {
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
</style>
