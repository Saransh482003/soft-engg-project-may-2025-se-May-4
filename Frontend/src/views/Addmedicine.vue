<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();
const token = localStorage.getItem('token');
const isDarkMode = ref(localStorage.getItem('darkModePreference') === 'dark');
const newReminder = ref({
  medicineName: '',
  dosage: '',
  timingPeriod: 'Morning',
  timingRelation: 'Before Meal',
  frequency: 'Daily'
});
const reminders = ref([]);
const showSuccessMessage = ref(false);
const errorMessage = ref('');

async function addReminder() {
  try {
    if (!newReminder.value.medicineName || !newReminder.value.dosage) {
      errorMessage.value = 'Please fill in all required fields';
      setTimeout(() => { errorMessage.value = ''; }, 3000);
      return;
    }
    
    const timing = `${newReminder.value.timingPeriod} - ${newReminder.value.timingRelation}`;
    const reminderData = {
      name: newReminder.value.medicineName,
      dosage: newReminder.value.dosage,
      timing: timing,
      frequency: newReminder.value.frequency
    };

    const res = await fetch('/api/reminders', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`
      },
      body: JSON.stringify(reminderData)
    });

    if (!res.ok) throw new Error('Failed to add reminder');
    
    const added = await res.json();
    reminders.value.push(added);
    showSuccessMessage.value = true;
    setTimeout(() => { showSuccessMessage.value = false; }, 3000);
    
    newReminder.value = { 
      medicineName: '', 
      dosage: '',
      timingPeriod: 'Morning',
      timingRelation: 'Before Meal',
      frequency: 'Daily'
    };
  } catch (err) {
    console.error('Error adding reminder:', err);
    errorMessage.value = err.message || 'An error occurred while adding the reminder';
    setTimeout(() => { errorMessage.value = ''; }, 3000);
  }
}

function goBack() {
  router.push('/userdashboard');
}
</script>

<template>
  <div class="add-medicine-container" :class="{ 'dark': isDarkMode }">

    <nav class="navbar">
      <div class="logo">
     <img src="../assets/Sharvan_logo.jpeg" alt="Sharvan Logo" class="logo-image" />
      <span style="margin-left: 10px">SHRAVAN</span>
      </div>
      <div class="nav-right">
        <button class="back-button" @click="goBack">🏠 Home</button>
      </div>
    </nav>


    <div class="content-section">
      <div class="page-header">
        <h1>💊 Add Medicine Reminder</h1>
        <p class="subtitle">Keep track of your medication schedule</p>
      </div>

      <div class="form-card">
        <h2 class="form-title">Medicine Details</h2>

        <div v-if="showSuccessMessage" class="alert success">
          ✅ Medicine reminder added successfully!
        </div>
        
        <div v-if="errorMessage" class="alert error">
          ❌ {{ errorMessage }}
        </div>

        <form @submit.prevent="addReminder">
          <div class="form-group">
            <label for="medicineName">Medicine Name <span class="required">*</span></label>
            <input 
              type="text" 
              id="medicineName" 
              v-model="newReminder.medicineName" 
              placeholder="Enter medicine name"
              class="form-control" 
              required
            >
          </div>

          <div class="form-group">
            <label for="dosage">Dosage <span class="required">*</span></label>
            <input 
              type="text" 
              id="dosage" 
              v-model="newReminder.dosage" 
              placeholder="E.g., 1 tablet, 5ml, etc."
              class="form-control" 
              required
            >
          </div>
          

          <div class="timing-section">
            <h3 class="section-subtitle">Medicine Timing</h3>
            
            <div class="form-row">

              <div class="form-group">
                <label for="timingPeriod">Time of Day</label>
                <div class="timing-options time-of-day">
                  <div class="timing-option" 
                       :class="{ 'selected': newReminder.timingPeriod === 'Morning' }"
                       @click="newReminder.timingPeriod = 'Morning'">
                    <div class="option-icon">🌅</div>
                    <div class="option-label">Morning</div>
                  </div>
                  <div class="timing-option"
                       :class="{ 'selected': newReminder.timingPeriod === 'Afternoon' }"
                       @click="newReminder.timingPeriod = 'Afternoon'">
                    <div class="option-icon">☀️</div>
                    <div class="option-label">Afternoon</div>
                  </div>
                  <div class="timing-option"
                       :class="{ 'selected': newReminder.timingPeriod === 'Evening' }"
                       @click="newReminder.timingPeriod = 'Evening'">
                    <div class="option-icon">🌆</div>
                    <div class="option-label">Evening</div>
                  </div>
                </div>
              </div>
            </div>
            

            <div class="form-group">
              <label for="timingRelation">Relation to Meal</label>
              <div class="timing-options meal-relation">
                <div class="timing-option" 
                     :class="{ 'selected': newReminder.timingRelation === 'Before Meal' }"
                     @click="newReminder.timingRelation = 'Before Meal'">
                  <div class="option-icon">⏱️</div>
                  <div class="option-label">Before Meal</div>
                </div>
                <div class="timing-option"
                     :class="{ 'selected': newReminder.timingRelation === 'After Meal' }"
                     @click="newReminder.timingRelation = 'After Meal'">
                  <div class="option-icon">🍽️</div>
                  <div class="option-label">After Meal</div>
                </div>
              </div>
            </div>
          </div>

          <div class="form-group">
            <label for="frequency">Frequency</label>
            <select id="frequency" v-model="newReminder.frequency" class="form-control">
              <option value="Daily">Daily</option>
              <option value="Twice Daily">Twice Daily</option>
              <option value="Three Times a Day">Three Times a Day</option>
              <option value="Weekly">Weekly</option>
              <option value="Alternate Days">Alternate Days</option>
              <option value="As Needed">As Needed</option>
            </select>
          </div>

          <div class="button-container">
            <button type="submit" class="submit-button">
              Add Medicine Reminder
            </button>
          </div>
        </form>
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

.add-medicine-container {
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


.content-section {
  padding: 30px;
  max-width: 800px;
  margin: 0 auto;
  width: 100%;
  flex: 1; 
  display: flex; 
  flex-direction: column; 
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

.dark .back-button {
  background-color: #4b5563;
  color: #f3f4f6;
}

.back-button:hover {
  background-color: #e5e7eb;
  color: #1f2937;
  transform: translateY(-2px);
}

.dark .back-button:hover {
  background-color: #6b7280;
}


.content-section {
  padding: 30px;
  max-width: 800px;
  margin: 0 auto;
  width: 100%;
  flex: 1; 
  display: flex;
  flex-direction: column; 
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

/* Form Card Styles */
.form-card {
  background-color: white;
  border-radius: 16px;
  padding: 30px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
  margin-bottom: 30px;
}

.dark .form-card {
  background-color: #2a2a2a;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
}

.form-title {
  color: #1f2937;
  font-size: 1.5rem;
  margin-bottom: 25px;
  padding-bottom: 15px;
  border-bottom: 1px solid #e5e7eb;
  font-weight: 500;
}

.dark .form-title {
  color: #f3f4f6;
  border-bottom-color: #4b5563;
}

.section-subtitle {
  color: #4b5563;
  font-size: 1.1rem;
  margin: 20px 0 15px;
  font-weight: 500;
}

.dark .section-subtitle {
  color: #e5e7eb;
}

.timing-section {
  background-color: #f9fafb;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 20px;
  border: 1px solid #e5e7eb;
}

.dark .timing-section {
  background-color: #374151;
  border-color: #4b5563;
}

/* Form Elements */
.form-group {
  margin-bottom: 20px;
}

.form-row {
  display: flex;
  gap: 20px;
}

.form-row .form-group {
  flex: 1;
}

label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #4b5563;
}

.dark label {
  color: #e5e7eb;
}

.required {
  color: #ef4444;
}

.form-control {
  width: 100%;
  padding: 12px 15px;
  border: 1px solid #e5e7eb;
  border-radius: 10px;
  font-size: 1rem;
  transition: all 0.3s ease;
  background-color: #f9fafb;
}

.dark .form-control {
  background-color: #374151;
  border-color: #4b5563;
  color: #f3f4f6;
}

.form-control:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.3);
}

.dark .form-control:focus {
  border-color: #60a5fa;
  box-shadow: 0 0 0 3px rgba(96, 165, 250, 0.3);
}

/* Timing Options */
.timing-options {
  display: flex;
  gap: 10px; 
  margin-bottom: 15px;
}

.timing-option {
  flex: 1;
  border: 1px solid #e5e7eb;
  border-radius: 8px; 
  padding: 10px; 
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
}

.dark .timing-option {
  border-color: #4b5563;
}

.timing-option:hover {
  background-color: #f3f4f6;
}

.dark .timing-option:hover {
  background-color: #374151;
}

.timing-option.selected {
  background-color: #dbeafe;
  border-color: #3b82f6;
}

.dark .timing-option.selected {
  background-color: #1e3a8a;
  border-color: #60a5fa;
}

.option-icon {
  font-size: 1.4rem; 
  margin-bottom: 4px; 
}

.option-label {
  font-weight: 500;
  font-size: 0.9rem; 
}

/* Button Styles */
.button-container {
  margin-top: 30px;
  display: flex;
  justify-content: center;
}

.submit-button {
  background: linear-gradient(90deg, #3b82f6, #2563eb);
  color: white;
  border: none;
  padding: 14px 30px;
  border-radius: 10px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2);
}

.submit-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 10px rgba(37, 99, 235, 0.3);
}

/* Alert Messages */
.alert {
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 20px;
  font-weight: 500;
}

.success {
  background-color: #d1fae5;
  color: #065f46;
  border-left: 4px solid #10b981;
}

.dark .success {
  background-color: #064e3b;
  color: #a7f3d0;
  border-left: 4px solid #10b981;
}

.error {
  background-color: #fee2e2;
  color: #b91c1c;
  border-left: 4px solid #ef4444;
}

.dark .error {
  background-color: #7f1d1d;
  color: #fecaca;
  border-left: 4px solid #ef4444;
}

/* Responsive Adjustments */
@media (max-width: 768px) {
  .form-row {
    flex-direction: column;
    gap: 0;
  }
  
  .timing-options {
    flex-direction: column;
    gap: 10px;
  }
  
  .content-section {
    padding: 20px;
  }
  
  .form-card {
    padding: 20px;
  }
  
  h1 {
    font-size: 1.8rem;
  }
  
  .form-title {
    font-size: 1.3rem;
  }
}
</style>
