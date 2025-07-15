<script setup>
import { RouterLink } from 'vue-router';
</script>

<template>
  <main class="home-container">
    <h1 class="welcome-text">👋 WELCOME TO SHRAVAN</h1>
    <p class="subtitle">A Helping Hand for Senior Citizens</p>
    <div class="button-container">
      <RouterLink class="login-button" to="/userlogin">🔐 LOGIN / REGISTER</RouterLink>
    </div>
  </main>
</template>

<style scoped>
.home-container {
  height: 100vh;
  background: linear-gradient(135deg, #f9e5ff, #ffe0e0, #e0f7fa);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  font-family: 'Segoe UI', sans-serif;
  padding: 20px;
  text-align: center;
}

.welcome-text {
  font-size: 3rem;
  color: #4a148c;
  margin-bottom: 10px;
  text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.1);
}

.subtitle {
  font-size: 1.2rem;
  color: #5d4037;
  margin-bottom: 30px;
}

.button-container {
  display: flex;
  justify-content: center;
}

.login-button {
  background-color: #ff7043;
  color: white;
  padding: 12px 24px;
  border-radius: 10px;
  font-size: 1.1rem;
  font-weight: bold;
  text-decoration: none;
  transition: background-color 0.3s, transform 0.2s;
}

.login-button:hover {
  background-color: #f4511e;
  transform: scale(1.05);
}
</style>
