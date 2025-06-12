<script setup>
import { RouterLink } from 'vue-router';
import { auth } from '@/stores/auth';
import { messageStore } from '@/stores/messageStore';
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const email = ref('');
const password = ref('');

const router = useRouter();
const auth_store = auth();
const message_store = messageStore();

async function onSubmit() {
  const data = {
    email: email.value,
    password: password.value
  };

  auth_store.login(data).then((resp) => {
    message_store.setmessage(resp.message);
    const role = auth_store.role;

    if (resp.status && role === 'user') {
      router.push({ path: '/userdashboard' });
    } else if (resp.status && role === 'caretaker') {
      router.push({ path: '/caretaker' });
    } else if (resp.status && role === 'ngo') {
      router.push({ path: '/tertiaryuser' });
    } else {
      router.push({ path: '/' });
    }
  });
}
</script>

<template>
  <div class="login-container">
    <div class="login-card">
      <h1 class="text-center">🔐 Login to SHARVAN</h1>
      <p class="text-center subtitle">Your wellness, our priority</p>
      <form @submit.prevent="onSubmit">
        <div class="mb-3">
          <label for="email" class="form-label">📧 Email Address</label>
          <input type="email" class="form-control" id="email" v-model="email" required>
        </div>

        <div class="mb-3">
          <label for="password" class="form-label">🔒 Password</label>
          <input type="password" class="form-control" id="password" v-model="password" required>
        </div>

        <div class="d-flex justify-content-center mb-3">
          <button type="submit" class="btn login-button">Login</button>
        </div>
      </form>

      <div class="d-flex justify-content-center mt-2">
        <span class="me-2">Don't have an account?</span>
        <RouterLink class="btn btn-outline-light" to="/register">Register</RouterLink>
      </div>
    </div>
  </div>
</template>


<style scoped>
.login-container {
  height: 100vh;
  background: linear-gradient(135deg, #e0f7fa, #ffe0e0, #f3e5f5);
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Segoe UI', sans-serif;
  padding: 20px;
}

.login-card {
  background-color: #ffffffdd;
  padding: 30px;
  border-radius: 16px;
  box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
  width: 100%;
  max-width: 500px;
}

.text-center {
  text-align: center;
}

.subtitle {
  font-size: 1rem;
  color: #6a1b9a;
  margin-bottom: 20px;
}

.form-label {
  font-weight: bold;
  color: #4a148c;
}

.form-control, .form-select {
  border-radius: 8px;
  border: 1px solid #ce93d8;
  padding: 10px;
}

.login-button {
  background-color: #ff7043;
  border: none;
  color: white;
  padding: 10px 24px;
  border-radius: 10px;
  font-size: 1.1rem;
  font-weight: bold;
  transition: background-color 0.3s ease, transform 0.2s;
}

.login-button:hover {
  background-color: #f4511e;
  transform: scale(1.05);
}

.btn-outline-light {
  color: #4a148c;
  border-color: #4a148c;
  border-radius: 8px;
}

.btn-outline-light:hover {
  background-color: #f8bbd0;
  color: #4a148c;
}
</style>
