<script setup>
import { onMounted, ref } from 'vue';
import { useRouter } from 'vue-router';
import { RouterLink } from 'vue-router';

const router = useRouter();
const medicationUpdates = ref([]);
const loading = ref(true);
const error = ref(null);
const linkedSeniorName = ref('');


const caretakerEmail = 'john.caretaker@example.com';

onMounted(async () => {
  try {

    await new Promise(resolve => setTimeout(resolve, 1000));

    linkedSeniorName.value = 'Rajesh Sharma';
    medicationUpdates.value = getMockData();
    loading.value = false;
  } catch (err) {
    console.error('Error fetching medication data:', err);
    error.value = 'Unable to load medication data. Please try again.';
    loading.value = false;
  }
});


function getMockData() {
  return [
    {
      date: '2025-06-16', 
      medications: [
        {
          name: 'Lisinopril',
          dosage: '10mg',
          schedule: 'Morning, before breakfast',
          status: 'taken',
          time_taken: '07:45 AM'
        },
        {
          name: 'Metformin',
          dosage: '500mg',
          schedule: 'After lunch',
          status: 'taken',
          time_taken: '01:30 PM'
        },
        {
          name: 'Atorvastatin',
          dosage: '20mg',
          schedule: 'Evening, after dinner',
          status: 'pending',
          time_taken: null
        }
      ]
    },
    {
      date: '2025-06-15',
      medications: [
        {
          name: 'Lisinopril',
          dosage: '10mg',
          schedule: 'Morning, before breakfast',
          status: 'taken',
          time_taken: '08:15 AM'
        },
        {
          name: 'Metformin',
          dosage: '500mg',
          schedule: 'After lunch',
          status: 'missed',
          time_taken: null
        },
        {
          name: 'Atorvastatin',
          dosage: '20mg',
          schedule: 'Evening, after dinner',
          status: 'taken',
          time_taken: '09:00 PM'
        }
      ]
    },
    {
      date: '2025-06-14',
      medications: [
        {
          name: 'Lisinopril',
          dosage: '10mg',
          schedule: 'Morning, before breakfast',
          status: 'taken',
          time_taken: '07:30 AM'
        },
        {
          name: 'Metformin',
          dosage: '500mg',
          schedule: 'After lunch',
          status: 'taken',
          time_taken: '01:15 PM'
        },
        {
          name: 'Atorvastatin',
          dosage: '20mg',
          schedule: 'Evening, after dinner',
          status: 'taken',
          time_taken: '08:45 PM'
        }
      ]
    }
  ];
}

function formatDate(dateString) {
  const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
  return new Date(dateString).toLocaleDateString('en-US', options);
}

function isToday(dateString) {
  const today = new Date();
  const dateToCheck = new Date(dateString);
  return today.toDateString() === dateToCheck.toDateString();
}
</script>

<template>
  <div class="medication-dashboard">

    <nav class="navbar">
      <div class="logo">
        <img src="../assets/Sharvan_logo.jpeg" alt="Sharvan Logo" class="logo-image" />
        <span style="margin-left: 10px">SHRAVAN</span>
      </div>
      <div class="nav-right">
        <button class="back-button" @click="router.push('/caretaker')">
          🏠 Home
        </button>
      </div>
    </nav>


    <section class="header-section">
      <h1>Medication Tracking</h1>
      <p class="subtitle">Daily medication status for {{ linkedSeniorName }}</p>
    </section>


    <section class="content-section">

      <div v-if="loading" class="loading-state">
        <div class="spinner"></div>
        <p>Loading medication updates...</p>
      </div>


      <div v-else-if="error" class="error-state">
        <p>{{ error }}</p>
        <button @click="fetchMedicationData" class="retry-button">Retry</button>
      </div>


      <div v-else class="medication-timeline">
        <div v-for="dayData in medicationUpdates" :key="dayData.date" class="day-card">
          <div class="date-header" :class="{ 'today': isToday(dayData.date) }">
            <h2>{{ formatDate(dayData.date) }}</h2>
            <span v-if="isToday(dayData.date)" class="today-badge">Today</span>
          </div>

          <div class="medications-list">
            <div 
              v-for="med in dayData.medications" 
              :key="`${dayData.date}-${med.name}`"
              class="medication-card"
              :class="{
                'status-taken': med.status === 'taken',
                'status-missed': med.status === 'missed',
                'status-pending': med.status === 'pending'
              }"
            >
              <div class="medication-info">
                <h3>{{ med.name }} <span class="dosage">{{ med.dosage }}</span></h3>
                <p class="schedule">{{ med.schedule }}</p>
              </div>
              
              <div class="medication-status">
                <div v-if="med.status === 'taken'" class="status-indicator taken">
                  <span class="status-icon">✓</span>
                  <span class="status-text">Taken at {{ med.time_taken }}</span>
                </div>
                <div v-else-if="med.status === 'missed'" class="status-indicator missed">
                  <span class="status-icon">✗</span>
                  <span class="status-text">Missed</span>
                </div>
                <div v-else class="status-indicator pending">
                  <span class="status-icon">⏱</span>
                  <span class="status-text">Pending</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body, html {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
  overflow-x: hidden;
}

.medication-dashboard {
  min-height: 100vh;
  width: 100%;
  background: linear-gradient(135deg, #e0f7fa, #ffe0e0, #f3e5f5);
  font-family: 'Poppins', sans-serif;
  display: flex;
  flex-direction: column;
  color: #333;
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

.logo {
  font-size: 1.5rem;
  font-weight: 600;
  color: #3b82f6;
}
.logo-image {
  height: 36px;
  width: auto;
  object-fit: contain;
  display: inline-block;
  vertical-align: middle; /* Ensures inline alignment with text */
}
.nav-right {
  display: flex;
  align-items: center;
}

.back-button {
  background-color: #f3f4f6;
  color: #4b5563;
  border: none;
  padding: 10px 20px;
  border-radius: 10px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.back-button:hover {
  background-color: #e5e7eb;
  color: #1f2937;
}


.header-section {
  padding: 30px;
  text-align: center;
}

h1 {
  color: #1f2937;
  font-size: 2.2rem;
  margin-bottom: 10px;
  font-weight: 600;
}

.subtitle {
  color: #6b7280;
  font-size: 1.1rem;
}


.content-section {
  flex: 1;
  padding: 0 30px 30px;
}

.loading-state, .error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 50px 0;
  text-align: center;
}

.spinner {
  border: 4px solid rgba(0, 0, 0, 0.1);
  border-radius: 50%;
  border-top: 4px solid #3b82f6;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin-bottom: 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.retry-button {
  margin-top: 20px;
  padding: 10px 20px;
  background-color: #3b82f6;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
}


.medication-timeline {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.day-card {
  background-color: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.date-header {
  background-color: #f3f4f6;
  padding: 15px 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.date-header h2 {
  font-size: 1.2rem;
  color: #4b5563;
  font-weight: 600;
}

.today-badge {
  background-color: #3b82f6;
  color: white;
  padding: 5px 10px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
}

.date-header.today {
  background-color: #dbeafe;
}

.medications-list {
  padding: 15px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.medication-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px;
  border-radius: 10px;
  background-color: #f9fafb;
  transition: transform 0.2s;
}

.medication-card:hover {
  transform: translateY(-2px);
}

.status-taken {
  border-left: 4px solid #10b981;
}

.status-missed {
  border-left: 4px solid #ef4444;
}

.status-pending {
  border-left: 4px solid #f59e0b;
}

.medication-info h3 {
  font-size: 1.1rem;
  color: #1f2937;
  margin-bottom: 5px;
}

.dosage {
  font-size: 0.9rem;
  color: #6b7280;
  font-weight: 400;
}

.schedule {
  font-size: 0.9rem;
  color: #6b7280;
}

.medication-status {
  display: flex;
  align-items: center;
}

.status-indicator {
  display: flex;
  align-items: center;
  padding: 5px 10px;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 500;
}

.status-indicator.taken {
  background-color: #d1fae5;
  color: #10b981;
}

.status-indicator.missed {
  background-color: #fee2e2;
  color: #ef4444;
}

.status-indicator.pending {
  background-color: #fef3c7;
  color: #f59e0b;
}

.status-icon {
  margin-right: 5px;
  font-weight: bold;
}


@media (max-width: 768px) {
  .navbar {
    padding: 10px 15px;
  }
  
  .header-section {
    padding: 20px 15px;
  }
  
  h1 {
    font-size: 1.8rem;
  }
  
  .content-section {
    padding: 0 15px 20px;
  }
  
  .medication-card {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .medication-status {
    margin-top: 10px;
    align-self: flex-end;
  }
}
</style>
