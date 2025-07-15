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
      <div class="card-left">
        <img src="../assets/caretaker.png" alt="Expert Caretaker" class="caretaker-image">
      </div>
      <div class="card-right">
      <h1 class="text-center">🔐 Login to SHARVAN</h1>
      <p class="text-center subtitle">Your wellness, our priority</p>
      <form @submit.prevent="onSubmit" class="form-wrapper">
        <div class="form-group">
          <label for="email">📧 Email Address</label>
          <input type="email" id="email"  placeholder="Enter your email" v-model="email" required />
        </div>

        <div class="form-group">
          <label for="password">🔒 Password</label>
          <input type="password" id="password" placeholder="Enter your password" v-model="password" required />
        </div>

        <button type="submit" class="login-button">Login</button>
      </form>

        <br>
        <div class="d-flex justify-content-center mt-2">
          <span class="me-2">Don't have an account?</span>
          <RouterLink class="btn btn-outline-light" to="/register">Register</RouterLink>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>

.login-container {
  height: 100vh;
  width: 100vw;
  background: linear-gradient(135deg, #e0f7fa, #ffe0e0, #f3e5f5);
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Poppins', sans-serif;
  position: fixed; 
  inset: 0;
}
.form-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px; /* spacing between fields */
}

.form-group {
  display: flex;
  flex-direction: column;
  width: 100%;
  max-width: 400px;
}

.form-group label {
  font-size: 1.2rem;         /* larger label text */
  font-weight: 600;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.form-group input {
  padding: 14px;
  font-size: 1.1rem;         /* larger input text */
  border: 2px solid #ccc;
  border-radius: 8px;
  width: 100%;
}

.form-group input::placeholder {
  color: #9ca3af; /* light grey placeholder */
  font-weight: 400;
}

.login-card {
  width: 80%;
  max-width: 1000px;
  display: flex;
  border-radius: 20px;
  box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  background: #ffffff;
}

.card-left {
  flex: 0.45;
  background-color: #f6f8fb;
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 20px;
  overflow: hidden;
}

.card-left::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, rgba(96, 165, 250, 0.1), rgba(147, 197, 253, 0.1));
  z-index: 0;
}

.card-left::after {
  content: '';
  position: absolute;
  top: 10%;
  right: 0;
  height: 80%;
  width: 1px;
  background: linear-gradient(to bottom, transparent, rgba(0, 0, 0, 0.1), transparent);
  z-index: 2;
}

.caretaker-image {
  width: 90%;
  height: 90%;
  object-fit: cover;
  object-position: center;
  border-radius: 16px;
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
  z-index: 1;
  transition: transform 0.5s ease;
}

.caretaker-image:hover {
  transform: scale(1.02);
}

.card-right {
  flex: 0.55;
  background-color: #ffffff; 
  padding: 40px;
  color: #333;
  position: relative;
}

.text-center {
  text-align: center;
}

h1 {
  color: #2e3b4e;
  margin-bottom: 10px;
  font-family: 'Poppins', sans-serif;
  font-weight: 700;
  font-size: 2.2rem;
  letter-spacing: -0.5px;
}

.subtitle {
  font-size: 1rem;
  color: #6b7280;
  margin-bottom: 35px;
  font-family: 'Poppins', sans-serif;
  font-weight: 400;
  letter-spacing: 0.2px;
  position: relative;
  display: inline-block;
}

.subtitle::after {
  content: '';
  position: absolute;
  left: 50%;
  bottom: -10px;
  transform: translateX(-50%);
  width: 50px;
  height: 2px;
  background: linear-gradient(90deg, #60a5fa, #93c5fd);
}

.form-label {
  font-weight: 500;
  color: #4b5563;
  margin-bottom: 8px;
  display: block;
  font-size: 0.95rem;
  letter-spacing: 0.3px;
  font-weight: bold;
  text-align: left;
  color: #4a148c;
  font-size: large;
}

.form-control, .form-select {
  border-radius: 12px;
  border: 1.5px solid #e5e7eb;
  padding: 12px 16px;
  margin-bottom: 20px;
  background-color: #f9fafb;
  color: #1f2937;
  width: 100%;
  font-family: 'Poppins', sans-serif;
  font-size: 0.95rem;
  transition: all 0.3s ease;
}

.form-control:focus {
  outline: none;
  border-color: #60a5fa;
  box-shadow: 0 0 0 4px rgba(96, 165, 250, 0.2);
  background-color: #ffffff;
}

.login-button {
  background: linear-gradient(90deg, #60a5fa, #3b82f6);
  border: none;
  color: #fff;
  padding: 14px 32px;
  border-radius: 12px;
  font-size: 1.05rem;
  font-weight: 600;
  letter-spacing: 0.5px;
  transition: all 0.3s ease;
  width: 100%;
  margin-top: 10px;
  box-shadow: 0 4px 6px rgba(59, 130, 246, 0.2);
  position: relative;
  overflow: hidden;
}

.login-button::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: all 0.5s ease;
}

.login-button:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 15px rgba(59, 130, 246, 0.3);
  background: linear-gradient(90deg, #3b82f6, #2563eb);
}

.login-button:hover::before {
  left: 100%;
}

.btn-outline-light {
  color: #3b82f6;
  border: 2px solid #3b82f6;
  background-color: transparent;
  border-radius: 12px;
  padding: 8px 20px;
  font-weight: 500;
  transition: all 0.3s ease;
}

.btn-outline-light:hover {
  background-color: #bfdbfe;
  color: #1e40af;
  transform: translateY(-2px);
}

.me-2 {
  color: #6b7280;
  font-weight: 400;
}


@media (max-width: 768px) {
  .login-card {
    width: 90%;
    flex-direction: column;
  }
  
  .card-left {
    height: 200px;
    padding: 10px;
  }
  
  .card-left::after {
    top: auto;
    right: 10%;
    bottom: 0;
    height: 1px;
    width: 80%;
    background: linear-gradient(to right, transparent, rgba(0, 0, 0, 0.1), transparent);
  }
  
  .card-right {
    padding: 25px;
  }
  
  h1 {
    font-size: 1.8rem;
  }
}
</style>
