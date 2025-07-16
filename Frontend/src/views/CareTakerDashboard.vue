<script setup>
import { useRouter } from 'vue-router';
import { ref, onMounted } from 'vue';
import { auth } from '@/stores/auth';

const router = useRouter();
const auth_store = auth();
const username = ref('Caretaker');
const searchQuery = ref('');

onMounted(() => {

  if (auth_store.userDetails) {
    try {
      const userDetails = JSON.parse(auth_store.userDetails);
      username.value = userDetails.username || 'Caretaker';
    } catch (e) {
      console.error('Error parsing user details:', e);
    }
  }
});

function goToFeature(path) {
  router.push(path);
}

function logout() {
  auth_store.logout();
  router.push('/');
}

// function handleSearch() {

//   console.log('Searching for:', searchQuery.value);
// }
</script>

<template>
  <div class="dashboard-container">

    <nav class="navbar">
      <div class="logo">
        <img src="../assets/Sharvan_logo.jpeg" alt="Sharvan Logo" class="logo-image" />
        <span style="margin-left: 10px">SHRAVAN</span>
      </div>
      <div class="nav-right">
        <!-- <div class="search-container">
          <input 
            type="text" 
            v-model="searchQuery" 
            placeholder="Search..." 
            class="search-input"
            @keyup.enter="handleSearch"
          >
          <button class="search-button" @click="handleSearch">🔍</button>
        </div> -->
        <div class="nav-actions">
          <button class="logout-button" @click="logout">Logout</button>
        </div>
      </div>
    </nav>


    <section class="welcome-section">
      <div class="welcome-content">
        <h1>Welcome, {{ username }} 👋</h1>
        <p class="subtitle">Your dedication to care makes a difference every day</p>
      </div>
      <div class="welcome-image">

        <img src="https://placehold.co/400x300/e0f7fa/1f2937?text=Caretaker" alt="Caretaker" class="care-image">
      </div>
    </section>


    <section class="features-section">
      <h2>Care Services</h2>
      <div class="card-container">
        <div class="feature-card" @click="goToFeature('/missedmedicinealert')">
          <div class="card-icon">🚨</div>
          <h3>Missed Medicine Alerts</h3>
          <p>Monitor if your loved one has missed any medications</p>
        </div>
        
        <div class="feature-card" @click="goToFeature('/daily-health')">
          <div class="card-icon">📊</div>
          <h3>Daily Health Updates</h3>
          <p>Check vital signs and daily health status</p>
        </div>
        
        <div class="feature-card" @click="goToFeature('/locationfinder')">
          <div class="card-icon">📍</div>
          <h3>Location Tracking</h3>
          <p>Find your loved one's location in case of emergency</p>
        </div>
      </div>
    </section>
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

.dashboard-container {
  min-height: 100vh;
  width: 100%;
  background: linear-gradient(135deg, #e0f7fa, #ffe0e0, #f3e5f5);
  font-family: 'Poppins', sans-serif;
  display: flex;
  flex-direction: column;
  color: #333;
  margin: 0;
  padding: 0;
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
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
  justify-content: flex-end; 
}

.search-container {
  display: flex;
  width: 300px;
  margin-right: 15px;
}

.search-input {
  flex: 1;
  padding: 10px 15px;
  border: 1px solid #e5e7eb;
  border-radius: 10px 0 0 10px;
  font-size: 0.95rem;
  outline: none;
}

.search-button {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 10px 15px;
  border-radius: 0 10px 10px 0;
  cursor: pointer;
}

.nav-actions {
  display: flex;
  align-items: center;
}

.logout-button {
  background-color: #f3f4f6;
  color: #4b5563;
  border: none;
  padding: 10px 20px;
  border-radius: 10px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.logout-button:hover {
  background-color: #e5e7eb;
  color: #1f2937;
}


.welcome-section {
  display: flex;
  margin: 30px 30px;
  background-color: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
}

.welcome-content {
  flex: 1;
  padding: 40px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.welcome-image {
  flex: 1;
  background-color: #f6f8fb;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.care-image {
  max-width: 100%;
  max-height: 250px;
  object-fit: cover;
  border-radius: 12px;
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
  margin-bottom: 0;
}


.features-section {
  padding: 0 30px 30px 30px;
}

.features-section h2 {
  color: #1f2937;
  font-size: 1.5rem;
  margin-bottom: 20px;
  font-weight: 500;
  padding-left: 10px;
  border-left: 4px solid #3b82f6;
}

.card-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.feature-card {
  background-color: white;
  border-radius: 16px;
  padding: 25px;
  text-align: center;
  transition: all 0.3s ease;
  border: 1px solid #e5e7eb;
  cursor: pointer;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.feature-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
  border-color: #bfdbfe;
}

.card-icon {
  font-size: 2.5rem;
  margin-bottom: 15px;
}

.feature-card h3 {
  color: #1f2937;
  font-size: 1.2rem;
  margin-bottom: 10px;
  font-weight: 500;
}

.feature-card p {
  color: #6b7280;
  font-size: 0.95rem;
}


@media (max-width: 768px) {
  .navbar {
    flex-direction: column;
    padding: 15px;
  }
  
  .logo {
    margin-bottom: 10px;
  }
  
  .nav-right {
    flex-direction: column;
    width: 100%;
  }
  
  .search-container {
    width: 100%;
    margin: 10px 0;
  }
  
  .nav-actions {
    margin-top: 10px;
    width: 100%;
  }
  
  .logout-button {
    width: 100%;
  }
  
  .welcome-section {
    flex-direction: column;
    margin: 20px 15px;
  }
  
  .welcome-content, .welcome-image {
    padding: 25px;
  }
  
  h1 {
    font-size: 1.8rem;
  }
  
  .features-section {
    padding: 0 15px 15px 15px;
  }
  
  .card-container {
    grid-template-columns: 1fr;
  }
}
</style>
