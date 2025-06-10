<script setup>
import { RouterLink } from 'vue-router';
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import { auth } from '@/stores/auth';
import { messageStore } from '@/stores/messageStore';

const name = ref('');
const email = ref('');
const password = ref('');
const mobile = ref('');
const address = ref('');
const pin = ref('');
const gender = ref('');
const dob = ref('');
const selectedRole = ref('user');
const linkedSeniorEmail = ref('');

const router = useRouter();
const auth_store = auth();
const message_store = messageStore();

const roleInfo = computed(() => {
  switch (selectedRole.value) {
    case 'caretaker':
      return [
        "🔔 Receive missed medicine alerts.",
        "📈 Get daily health summaries.",
        "📍 View live location (with consent)."
      ];
    case 'ngo':
      return [
        "📢 Send preventive health tips.",
        "📊 View community health trends."
      ];
    default:
      return [
        "👵 As a senior, you can receive care and assistance via the app."
      ];
  }
});

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

async function onSubmit() {
  if (!isValidEmail(email.value)) {
    alert("Please enter a valid email.");
    return;
  }
  if (password.value.length < 6) {
    alert("Password must be at least 6 characters.");
    return;
  }
  if (!mobile.value.match(/^\d{10}$/)) {
    alert("Enter a valid 10-digit mobile number.");
    return;
  }

  const data = {
    name: name.value,
    email: email.value,
    password: password.value,
    mobile: mobile.value,
    address: address.value,
    pin: pin.value,
    gender: gender.value,
    dob: dob.value,
    role: selectedRole.value,
    linkedSeniorEmail: selectedRole.value === 'caretaker' ? linkedSeniorEmail.value : null
  };

  auth_store.register(data).then((resp) => {
    message_store.setmessage(resp.message);
    if (resp.status) {
      router.push('/userlogin');
    }
  });
}
</script>

<template>
  <div class="register-container">
    <div class="register-card">
      <h1 class="text-center">📝 Register for SHARVAN</h1>
      <p class="text-center subtitle">Connecting Care with Compassion</p>

      <form @submit.prevent="onSubmit">
        <div class="mb-3">
          <label for="name" class="form-label">🧑 Name</label>
          <input type="text" class="form-control" id="name" v-model="name" required>
        </div>

        <div class="mb-3">
          <label for="email" class="form-label">📧 Email</label>
          <input type="email" class="form-control" id="email" v-model="email" required>
        </div>

        <div class="mb-3">
          <label for="password" class="form-label">🔐 Password (min 6 chars)</label>
          <input type="password" class="form-control" id="password" v-model="password" required>
        </div>

        <div class="mb-3">
          <label for="mobile" class="form-label">📱 Mobile Number</label>
          <input type="tel" class="form-control" id="mobile" v-model="mobile" required>
        </div>

        <div class="mb-3">
          <label for="gender" class="form-label">🚻 Gender</label>
          <select class="form-select" id="gender" v-model="gender" required>
            <option disabled value="">Select</option>
            <option>Male</option>
            <option>Female</option>
            <option>Other</option>
          </select>
        </div>

        <div class="mb-3">
          <label for="dob" class="form-label">🎂 Date of Birth</label>
          <input type="date" class="form-control" id="dob" v-model="dob" required>
        </div>

        <div class="mb-3">
          <label for="address" class="form-label">🏠 Address</label>
          <textarea class="form-control" id="address" rows="2" v-model="address" required></textarea>
        </div>

        <div class="mb-3">
          <label for="pin" class="form-label">📮 Pincode</label>
          <input type="text" class="form-control" id="pin" v-model="pin" required>
        </div>

        <div class="mb-3">
          <label for="role" class="form-label">👤 Select Your Role</label>
          <select class="form-select" id="role" v-model="selectedRole" required>
            <option value="user">👴 Senior Citizen (Primary)</option>
            <option value="caretaker">🧑‍⚕️ Care Taker (Secondary)</option>
            <option value="ngo">🏥 NGO / Health Center (Tertiary)</option>
          </select>
        </div>

        <!-- Linked Email Field for Caretakers -->
        <div v-if="selectedRole === 'caretaker'" class="mb-3">
          <label for="linkedSenior" class="form-label">🔗 Linked Senior Citizen's Email</label>
          <input type="email" class="form-control" id="linkedSenior" v-model="linkedSeniorEmail" required>
          <small class="form-text text-muted">Used to link with the senior citizen you care for.</small>
        </div>

        <div class="mb-3 bg-light rounded p-3 border role-info-box">
          <h6 class="text-primary">🛠 Role Capabilities:</h6>
          <ul class="list-unstyled">
            <li v-for="info in roleInfo" :key="info">✔️ {{ info }}</li>
          </ul>
        </div>

        <div class="d-flex justify-content-center mb-3">
          <button type="submit" class="btn register-button">✅ Register</button>
        </div>
      </form>

      <div class="d-flex justify-content-center mt-2">
        <span class="me-2">Already have an account?</span>
        <RouterLink class="btn btn-outline-light" to="/userlogin">Login</RouterLink>
      </div>
    </div>
  </div>
</template>

<style scoped>
.register-container {
  background: linear-gradient(to right, #ffe6f0, #f0f9ff);
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}

.register-card {
  background-color: #ffffff;
  border-radius: 12px;
  padding: 2rem;
  max-width: 600px;
  width: 100%;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
}

.subtitle {
  margin-bottom: 2rem;
  color: #6c757d;
}

.role-info-box {
  background-color: #f8f9fa;
  font-size: 0.95rem;
}

.register-container {
  height: 100vh;
  background: linear-gradient(135deg, #f3e5f5, #ffe0e0, #e0f7fa);
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Segoe UI', sans-serif;
  padding: 20px;
}

.register-card {
  background-color: #ffffffee;
  padding: 30px;
  border-radius: 16px;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
  width: 100%;
  max-width: 500px;
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

.form-control,
.form-select {
  border-radius: 8px;
  border: 1px solid #ce93d8;
  padding: 10px;
}

.register-button {
  background-color: #4caf50;
  color: white;
  font-weight: bold;
  padding: 10px 24px;
  border-radius: 10px;
  font-size: 1.1rem;
  transition: background-color 0.3s ease, transform 0.2s;
}

.register-button:hover {
  background-color: #388e3c;
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

.role-info-box {
  background-color: #f3f0ff;
}
</style>
