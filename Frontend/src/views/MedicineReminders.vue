<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();
const token = localStorage.getItem('token');
const isDarkMode = ref(localStorage.getItem('darkModePreference') === 'dark');

const reminders = ref([
  {
    id: 1,
    name: 'Aspirin',
    dosage: '1 tablet',
    timing: 'Morning - After Meal',
    frequency: 'Daily',
    status: 'pending'
  },
  {
    id: 2,
    name: 'Vitamin D',
    dosage: '2 tablets',
    timing: 'Afternoon - With Meal',
    frequency: 'Daily',
    status: 'taken'
  },
  {
    id: 3,
    name: 'Blood Pressure Medicine',
    dosage: '1 tablet',
    timing: 'Morning - Before Meal',
    frequency: 'Daily',
    status: 'missed'
  },
  {
    id: 4,
    name: 'Insulin',
    dosage: '10 units',
    timing: 'Evening - Before Meal',
    frequency: 'Daily',
    status: 'pending'
  },
  {
    id: 5,
    name: 'Calcium',
    dosage: '1 tablet',
    timing: 'Morning - With Meal',
    frequency: 'Daily',
    status: 'taken'
  }
]);

const todayReminders = computed(() => 
  reminders.value.filter(r => r.status === 'pending')
);

const takenReminders = computed(() => 
  reminders.value.filter(r => r.status === 'taken')
);

async function fetchReminders() {
  try {
    console.log('Using dummy data - will fetch from API in production');
  } catch (err) {
    console.error('Error fetching reminders:', err);
  }
}

async function updateReminderStatus(id, status) {
  try {
    const reminder = reminders.value.find(r => r.id === id);
    if (reminder) {
      reminder.status = status;
    }
  } catch (err) {
    console.error('Error updating reminder status:', err);
  }
}

function goBack() {
  router.push('/userdashboard');
}

function goToAddMedicine() {
  router.push('/addmedicinealert');
}

onMounted(fetchReminders);
</script>

<template>
  <div class="reminders-container" :class="{ 'dark': isDarkMode }">

    <nav class="navbar">
      <div class="logo">
      <img src="../assets/Sharvan_logo.jpeg" alt="Sharvan Logo" class="logo-image" />
      <span style="margin-left: 10px">SHRAVAN</span>
      </div>
      <div class="nav-right">
        <button class="action-button add-button" @click="goToAddMedicine">+ Add Medicine</button>
        <button class="back-button" @click="goBack">🏠 Home</button>
      </div>
    </nav>


    <div class="content-section">
      <div class="page-header">
        <h1>💊 Medicine Reminders</h1>
        <p class="subtitle">Keep track of your medication schedule</p>
      </div>


      <div class="reminder-section">
        <h2 class="section-title">Today's Reminders</h2>
        <div class="reminder-list" v-if="todayReminders.length > 0">
          <div v-for="reminder in todayReminders" :key="reminder.id" class="reminder-card">
            <div class="reminder-info">
              <div class="reminder-name">{{ reminder.name }}</div>
              <div class="reminder-dosage">{{ reminder.dosage }}</div>
              <div class="reminder-timing">{{ reminder.timing }}</div>
              <div class="reminder-frequency">{{ reminder.frequency }}</div>
            </div>
            <div class="reminder-actions">
              <button 
                class="status-button taken" 
                @click="updateReminderStatus(reminder.id, 'taken')"
                title="Mark as Taken"
              >
                ✅ Taken
              </button>
            </div>
          </div>
        </div>
        <div class="empty-state" v-else>
          <p>No pending reminders for today. 🎉</p>
        </div>
      </div>


      <div class="reminder-section">
        <h2 class="section-title">Taken Medicines</h2>
        <div class="reminder-list taken-list" v-if="takenReminders.length > 0">
          <div v-for="reminder in takenReminders" :key="reminder.id" class="reminder-card taken">
            <div class="reminder-info">
              <div class="reminder-name">{{ reminder.name }}</div>
              <div class="reminder-dosage">{{ reminder.dosage }}</div>
              <div class="reminder-timing">{{ reminder.timing }}</div>
              <div class="reminder-frequency">{{ reminder.frequency }}</div>
            </div>
            <div class="status-indicator">
              <span class="status-icon">✅</span>
            </div>
          </div>
        </div>
        <div class="empty-state" v-else>
          <p>No taken medicines yet.</p>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
:global(html), :global(body) {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
  overflow-x: hidden;
  box-sizing: border-box;
}

:global(#app) {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
}

.reminders-container {
  min-height: 100vh;
  width: 100%;
  background: linear-gradient(135deg, #e0f7fa, #ffe6f0, #f0f9ff);
  font-family: 'Poppins', sans-serif;
  display: flex;
  flex-direction: column;
  color: #333;
  margin: 0;
  padding: 0;
  position: relative;
  height: auto;
  overflow: auto;
}

.dark {
  background: linear-gradient(135deg, #1a2435, #2d2d3a, #1a1f2c);
  color: #f1f1f1;
}


.navbar {
  background-color: white;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 30px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 100;
  width: 100%;
  box-sizing: border-box;
}

.dark .navbar {
  background-color: #2a2a2a;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
}

.logo-image {
  height: 36px;
  width: auto;
  object-fit: contain;
  display: inline-block;
  vertical-align: middle; /* Ensures inline alignment with text */
}
.dark .logo {
  color: #60a5fa;
}

.nav-right {
  display: flex;
  align-items: center;
  gap: 15px;
}

.back-button, .action-button {
  background-color: #f3f4f6;
  color: #4b5563;
  border: none;
  padding: 10px 15px;
  border-radius: 10px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.dark .back-button, .dark .action-button {
  background-color: #4b5563;
  color: #f3f4f6;
}

.action-button.add-button {
  background-color: #3b82f6;
  color: white;
}

.dark .action-button.add-button {
  background-color: #2563eb;
}

.back-button:hover, .action-button:hover {
  transform: translateY(-2px);
}

.back-button:hover {
  background-color: #e5e7eb;
}

.action-button.add-button:hover {
  background-color: #2563eb;
}

.dark .back-button:hover {
  background-color: #6b7280;
}

.dark .action-button.add-button:hover {
  background-color: #1d4ed8;
}


.content-section {
  padding: 30px;
  max-width: 1000px;
  margin: 0 auto;
  width: 100%;
  flex: 1;
}

.page-header {
  margin-bottom: 30px;
  text-align: center;
}

h1 {
  color: #1f2937;
  font-size: 2.2rem;
  margin-bottom: 10px;
  font-weight: 600;
}

.dark h1 {
  color: #f3f4f6;
}

.subtitle {
  color: #6b7280;
  font-size: 1.1rem;
  margin-bottom: 0;
}

.dark .subtitle {
  color: #d1d5db;
}


.reminder-section {
  margin-bottom: 40px;
}

.section-title {
  color: #1f2937;
  font-size: 1.5rem;
  margin-bottom: 20px;
  font-weight: 500;
  display: flex;
  align-items: center;
}

.section-title::before {
  content: '';
  display: inline-block;
  width: 4px;
  height: 24px;
  background-color: #3b82f6;
  margin-right: 10px;
  border-radius: 2px;
}

.dark .section-title {
  color: #f3f4f6;
}

.dark .section-title::before {
  background-color: #60a5fa;
}

.reminder-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.reminder-card {
  background-color: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  display: flex;
  justify-content: space-between;
  transition: all 0.3s ease;
  border-left: 4px solid #3b82f6;
}

.dark .reminder-card {
  background-color: #2a2a2a;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
}

.reminder-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 15px rgba(0, 0, 0, 0.1);
}

.dark .reminder-card:hover {
  box-shadow: 0 8px 15px rgba(0, 0, 0, 0.3);
}

.reminder-card.taken {
  border-left-color: #10b981;
  opacity: 0.85;
}

.reminder-card.missed {
  border-left-color: #ef4444;
  opacity: 0.85;
}

.reminder-info {
  flex: 1;
}

.reminder-name {
  font-weight: 600;
  font-size: 1.1rem;
  color: #1f2937;
  margin-bottom: 5px;
}

.dark .reminder-name {
  color: #f3f4f6;
}

.reminder-dosage {
  color: #4b5563;
  font-size: 0.95rem;
  margin-bottom: 10px;
}

.dark .reminder-dosage {
  color: #d1d5db;
}

.reminder-timing, .reminder-frequency {
  color: #6b7280;
  font-size: 0.9rem;
  margin-bottom: 3px;
}

.dark .reminder-timing, .dark .reminder-frequency {
  color: #9ca3af;
}

.reminder-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-left: 15px;
}

.status-button {
  background: none;
  border: 1px solid;
  border-radius: 8px;
  padding: 8px 12px;
  font-size: 0.85rem;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  white-space: nowrap;
}

.status-button.taken {
  border-color: #10b981;
  color: #10b981;
}

.status-button.taken:hover {
  background-color: #10b981;
  color: white;
}

.status-indicator {
  display: flex;
  align-items: center;
}

.status-icon {
  font-size: 1.4rem;
}

.empty-state {
  background-color: #f9fafb;
  border-radius: 12px;
  padding: 30px;
  text-align: center;
  color: #6b7280;
}

.dark .empty-state {
  background-color: #374151;
  color: #9ca3af;
}


@media (max-width: 768px) {
  .navbar {
    flex-direction: column;
    padding: 15px;
  }
  
  .logo {
    margin-bottom: 15px;
  }
  
  .nav-right {
    width: 100%;
    flex-direction: column;
    gap: 10px;
  }
  
  .back-button, .action-button {
    width: 100%;
  }
  
  .reminder-list {
    grid-template-columns: 1fr;
  }
  
  .content-section {
    padding: 20px;
  }
  
  h1 {
    font-size: 1.8rem;
  }
  
  .reminder-card {
    flex-direction: column;
  }
  
  .reminder-actions {
    flex-direction: row;
    margin-left: 0;
    margin-top: 15px;
  }
  
  .status-button {
    flex: 1;
  }
}
</style>
