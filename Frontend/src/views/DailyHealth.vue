<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { auth } from '@/stores/auth';

const router = useRouter();
const auth_store = auth();
const isDarkMode = ref(localStorage.getItem('darkModePreference') === 'dark');
const loading = ref(true);
const error = ref(null);

// Patient information
const patient = ref({
  name: 'Rajesh Kumar',
  email: 'rajesh.kumar@gmail.com',
  mobile: '+91 98765 43210',
  gender: 'Male',
  dob: '15-05-1965',
  age: 60,
  condition: 'Hypertension, Diabetes Type 2'
});

// Medicine schedule and adherence data
const medicineSchedule = ref([
  {
    id: 1,
    name: 'Metformin',
    dosage: '500mg',
    frequency: 'Twice daily',
    timing: 'Morning, Evening',
    startDate: '10-01-2025'
  },
  {
    id: 2,
    name: 'Lisinopril',
    dosage: '10mg',
    frequency: 'Once daily',
    timing: 'Morning',
    startDate: '15-02-2025'
  },
  {
    id: 3,
    name: 'Atorvastatin',
    dosage: '20mg',
    frequency: 'Once daily',
    timing: 'Evening',
    startDate: '10-01-2025'
  }
]);

// Monthly adherence statistics (last 6 months)
const monthlyStats = ref([
  { month: 'February', adherence: 78, totalDoses: 140, takenDoses: 109 },
  { month: 'March', adherence: 82, totalDoses: 155, takenDoses: 127 },
  { month: 'April', adherence: 91, totalDoses: 150, takenDoses: 137 },
  { month: 'May', adherence: 85, totalDoses: 155, takenDoses: 132 },
  { month: 'June', adherence: 88, totalDoses: 150, takenDoses: 132 },
  { month: 'July', adherence: 93, totalDoses: 70, takenDoses: 65 }
]);

// Overall stats
const overallStats = computed(() => {
  // Calculate from monthly stats
  let totalDoses = 0;
  let takenDoses = 0;
  
  monthlyStats.value.forEach(month => {
    totalDoses += month.totalDoses;
    takenDoses += month.takenDoses;
  });
  
  const adherenceRate = Math.round((takenDoses / totalDoses) * 100);
  const missedDoses = totalDoses - takenDoses;
  
  // Calculate trends
  const last3Months = monthlyStats.value.slice(-3);
  let trend = 'stable';
  
  if (last3Months.length === 3) {
    if (last3Months[2].adherence > last3Months[0].adherence + 5) {
      trend = 'improving';
    } else if (last3Months[2].adherence < last3Months[0].adherence - 5) {
      trend = 'declining';
    }
  }
  
  return {
    adherenceRate,
    missedDoses,
    totalDoses,
    trend
  };
});

function toggleDarkMode() {
  isDarkMode.value = !isDarkMode.value;
  document.body.classList.toggle('dark-mode', isDarkMode.value);
  localStorage.setItem('darkModePreference', isDarkMode.value ? 'dark' : 'light');
}

function goBack() {
  router.push('/caretaker');
}

function logout() {
  auth_store.logout();
  router.push('/');
}

onMounted(() => {
  if (localStorage.getItem('darkModePreference') === 'dark') {
    document.body.classList.add('dark-mode');
  }
  
  // Simulate API call to fetch data
  setTimeout(() => {
    loading.value = false;
  }, 800);
});
</script>

<template>
  <div class="daily-health-container" :class="{ 'dark': isDarkMode }">
    <nav class="navbar">
      <div class="logo">
        <img src="../assets/Sharvan_logo.jpeg" alt="Sharvan Logo" class="logo-image" />
        <span style="margin-left: 10px">SHRAVAN</span>
      </div>
      <div class="nav-right">
        <div class="nav-actions">
          <button class="back-button" @click="goBack">🏠 Home</button>
        </div>
      </div>
    </nav>

    <div class="content-section">
      <div class="page-header">
        <h1>Daily Health Updates</h1>
        <p class="subtitle">Medication adherence information for your patient</p>
      </div>

      <div v-if="loading" class="loading-state">
        <div class="loading-spinner"></div>
        <p>Loading information...</p>
      </div>

      <div v-if="error" class="error-state">
        <p>{{ error }}</p>
        <button class="retry-button" @click="() => loading = true">Try Again</button>
      </div>

      <div v-if="!loading && !error" class="health-data">
        <!-- Patient & Current Medications Row -->
        <div class="data-row">
          <!-- Patient Information Card -->
          <div class="data-card patient-info">
            <h2>Patient Information</h2>
            <div class="patient-details">
              <div class="info-row">
                <span class="info-label">Name:</span>
                <span class="info-value">{{ patient.name }}</span>
              </div>
              <div class="info-row">
                <span class="info-label">Age:</span>
                <span class="info-value">{{ patient.age }} years</span>
              </div>
              <div class="info-row">
                <span class="info-label">Gender:</span>
                <span class="info-value">{{ patient.gender }}</span>
              </div>
              <div class="info-row">
                <span class="info-label">Mobile:</span>
                <span class="info-value">{{ patient.mobile }}</span>
              </div>
              <div class="info-row">
                <span class="info-label">Condition:</span>
                <span class="info-value">{{ patient.condition }}</span>
              </div>
            </div>
          </div>

          <!-- Current Medications Card -->
          <div class="data-card medications">
            <h2>Current Medications</h2>
            <div class="med-list">
              <div v-for="med in medicineSchedule" :key="med.id" class="med-item">
                <div class="med-name">{{ med.name }} ({{ med.dosage }})</div>
                <div class="med-details">
                  <div class="med-detail-item">
                    <span class="detail-label">Frequency:</span>
                    <span class="detail-value">{{ med.frequency }}</span>
                  </div>
                  <div class="med-detail-item">
                    <span class="detail-label">Timing:</span>
                    <span class="detail-value">{{ med.timing }}</span>
                  </div>
                  <div class="med-detail-item">
                    <span class="detail-label">Since:</span>
                    <span class="detail-value">{{ med.startDate }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Overall Adherence Stats -->
        <div class="data-card overall-stats">
          <h2>Overall Medication Adherence</h2>
          <div class="stats-summary">
            <div class="stat-item large">
              <div class="stat-value">{{ overallStats.adherenceRate }}%</div>
              <div class="stat-label">Overall Adherence</div>
              <div class="stat-trend" :class="overallStats.trend">
                <span v-if="overallStats.trend === 'improving'">↗ Improving</span>
                <span v-else-if="overallStats.trend === 'declining'">↘ Declining</span>
                <span v-else>→ Stable</span>
              </div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ overallStats.totalDoses }}</div>
              <div class="stat-label">Total Doses</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ overallStats.missedDoses }}</div>
              <div class="stat-label">Missed Doses</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
:global(html), :global(body) {
  margin: 0; padding: 0; width: 100%; height: 100%;
  overflow-x: hidden; box-sizing: border-box;
}

:global(#app) {
  margin: 0; padding: 0; width: 100%; height: 100%;
}

.daily-health-container {
  min-height: 100vh; width: 100%;
  background: linear-gradient(135deg, #e0f7fa, #ffe6f0, #f0f9ff);
  font-family: 'Poppins', sans-serif;
  display: flex; flex-direction: column; color: #333;
  margin: 0; padding: 0; position: relative;
  height: auto; overflow: auto;
}

.dark {
  background: linear-gradient(135deg, #1a2435, #2d2d3a, #1a1f2c);
  color: #f1f1f1;
}

.navbar {
  background-color: white; display: flex;
  justify-content: space-between; align-items: center;
  padding: 15px 30px; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  position: sticky; top: 0; z-index: 100;
  width: 100%; box-sizing: border-box;
}

.dark .navbar {
  background-color: #2a2a2a;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
}

.logo {
  font-size: 1.5rem; font-weight: 600; color: #3b82f6;
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
}

.nav-actions {
  display: flex;
  gap: 10px;
}

.theme-button, .back-button, .logout-button {
  background-color: #f3f4f6;
  color: #4b5563;
  border: none;
  border-radius: 10px;
  padding: 10px 15px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.dark .theme-button, .dark .back-button, .dark .logout-button {
  background-color: #374151;
  color: #d1d5db;
}

.theme-button:hover, .back-button:hover, .logout-button:hover {
  background-color: #e5e7eb;
}

.dark .theme-button:hover, .dark .back-button:hover, .dark .logout-button:hover {
  background-color: #4b5563;
}

.logout-button {
  background-color: #fee2e2;
  color: #ef4444;
}

.dark .logout-button {
  background-color: #7f1d1d;
  color: #fca5a5;
}

.logout-button:hover {
  background-color: #fecaca;
}

.dark .logout-button:hover {
  background-color: #991b1b;
}

.content-section {
  padding: 30px;
  display: flex;
  flex-direction: column;
  gap: 20px;
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  box-sizing: border-box;
}

.page-header {
  margin-bottom: 20px;
}

.page-header h1 {
  font-size: 2rem;
  margin: 0 0 5px 0;
  color: #1f2937;
}

.dark .page-header h1 {
  color: #f9fafb;
}

.subtitle {
  color: #6b7280;
  margin: 0;
}

.dark .subtitle { color: #d1d5db; }

.loading-state, .error-state {
  text-align: center; padding: 40px;
  background-color: white; border-radius: 16px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  margin-bottom: 20px;
}

.dark .loading-state, .dark .error-state {
  background-color: #2a2a2a;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
}

.loading-spinner {
  display: inline-block; width: 40px; height: 40px;
  border: 4px solid rgba(59, 130, 246, 0.2);
  border-radius: 50%; border-top-color: #3b82f6;
  animation: spin 1s linear infinite;
  margin-bottom: 15px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.error-state p {
  color: #ef4444; margin-bottom: 15px;
}

.retry-button {
  background-color: #3b82f6; color: white;
  border: none; padding: 10px 20px; border-radius: 10px;
  font-weight: 500; cursor: pointer; transition: all 0.3s ease;
}

.dark .retry-button {
  background-color: #2563eb;
}

.retry-button:hover {
  background-color: #2563eb;
}

.health-data {
  display: flex;
  flex-direction: column;
  gap: 20px;
  width: 100%;
}

.data-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 20px;
  width: 100%;
}

.data-card {
  background-color: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  padding: 20px;
}

.dark .data-card {
  background-color: #2a2a2a;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
}

.data-card h2 {
  color: #1f2937;
  font-size: 1.3rem;
  margin-top: 0;
  margin-bottom: 15px;
  font-weight: 600;
  border-bottom: 1px solid #e5e7eb;
  padding-bottom: 10px;
}

.dark .data-card h2 {
  color: #f3f4f6;
  border-bottom-color: #4b5563;
}

/* Patient Info Card Styles */
.patient-info {
  grid-column: span 1;
}

.patient-details {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.info-row {
  display: flex;
  align-items: center;
}

.info-label {
  font-weight: 500;
  color: #6b7280;
  width: 120px;
  flex-shrink: 0;
}

.dark .info-label {
  color: #9ca3af;
}

.info-value {
  color: #1f2937;
}

.dark .info-value {
  color: #f3f4f6;
}

/* Current Medications Styles */
.medications {
  grid-column: span 1;
}

.med-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.med-item {
  background-color: #f9fafb;
  border-radius: 8px;
  padding: 12px;
  border-left: 3px solid #3b82f6;
}

.dark .med-item {
  background-color: #374151;
  border-left-color: #60a5fa;
}

.med-name {
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 8px;
}

.dark .med-name {
  color: #f3f4f6;
}

.med-details {
  display: flex;
  flex-direction: column;
  gap: 5px;
  font-size: 0.9rem;
}

.med-detail-item {
  display: flex;
  align-items: center;
}

.detail-label {
  font-weight: 500;
  color: #6b7280;
  width: 80px;
  flex-shrink: 0;
}

.dark .detail-label {
  color: #9ca3af;
}

.detail-value {
  color: #4b5563;
}

.dark .detail-value {
  color: #d1d5db;
}

/* Overall Stats Styles */
.overall-stats {
  grid-column: 1 / -1;
}

.stats-summary {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-around;
  gap: 20px;
}

.stat-item {
  text-align: center;
  flex: 1;
  min-width: 120px;
  max-width: 200px;
  background-color: #f9fafb;
  padding: 15px;
  border-radius: 10px;
}

.dark .stat-item {
  background-color: #374151;
}

.stat-item.large {
  background-color: #eef2ff;
  flex: 2;
  max-width: 300px;
  border-left: 4px solid #4f46e5;
}

.dark .stat-item.large {
  background-color: #312e81;
  border-left-color: #818cf8;
}

.stat-value {
  font-size: 1.8rem;
  font-weight: 600;
  color: #3b82f6;
  margin-bottom: 5px;
}

.dark .stat-value {
  color: #60a5fa;
}

.stat-item.large .stat-value {
  font-size: 2.5rem;
  color: #4f46e5;
}

.dark .stat-item.large .stat-value {
  color: #818cf8;
}

.stat-label {
  font-size: 0.9rem;
  color: #6b7280;
}

.dark .stat-label {
  color: #9ca3af;
}

.stat-trend {
  margin-top: 8px;
  font-size: 0.9rem;
  font-weight: 500;
}

.stat-trend.improving {
  color: #059669;
}

.dark .stat-trend.improving {
  color: #34d399;
}

.stat-trend.declining {
  color: #dc2626;
}

.dark .stat-trend.declining {
  color: #f87171;
}

.stat-trend.stable {
  color: #9ca3af;
}

.dark .stat-trend.stable {
  color: #d1d5db;
}

@media (max-width: 768px) {
  .navbar { padding: 15px; }
  .nav-actions { flex-wrap: wrap; gap: 5px; }
  .theme-button, .back-button, .logout-button { 
    font-size: 0.9rem;
    padding: 8px 12px;
  }
  .content-section { padding: 20px; }
  .data-row {
    grid-template-columns: 1fr;
  }
  .patient-info, .medications {
    grid-column: 1;
  }
  .stats-summary {
    flex-direction: column;
    align-items: center;
  }
  .stat-item {
    width: 100%;
    max-width: none;
  }
  .stat-item.large {
    max-width: none;
  }
  .info-row {
    flex-direction: column;
    align-items: flex-start;
  }
  .info-label {
    width: 100%;
    margin-bottom: 2px;
  }
}
</style>