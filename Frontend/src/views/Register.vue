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
      <div class="card-left">
        <img src="../assets/login img.jpg" alt="Elderly care" class="caretaker-image">
      </div>
      <div class="card-right">
        <h1 class="text-center">📝 Register for SHRAVAN</h1>
        <p class="text-center subtitle">Connecting Care with Compassion</p>

        <form @submit.prevent="onSubmit">
          <div class="mb-3">
            <label for="name" class="form-label">🧑 Name</label>
            <input type="text" class="form-control" id="name" v-model="name" required>
          </div>

          <div class="form-row">
            <div class="mb-3 form-col">
              <label for="email" class="form-label">📧 Email</label>
              <input type="email" class="form-control" id="email" v-model="email" required>
            </div>

            <div class="mb-3 form-col">
              <label for="password" class="form-label">🔐 Password (min 6 chars)</label>
              <input type="password" class="form-control" id="password" v-model="password" required>
            </div>
          </div>

          <div class="form-row">
            <div class="mb-3 form-col">
              <label for="mobile" class="form-label">📱 Mobile Number</label>
              <input type="tel" class="form-control" id="mobile" v-model="mobile" required>
            </div>

            <div class="mb-3 form-col">
              <label for="gender" class="form-label">🚻 Gender</label>
              <select class="form-select" id="gender" v-model="gender" required>
                <option disabled value="">Select</option>
                <option>Male</option>
                <option>Female</option>
                <option>Other</option>
              </select>
            </div>
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


          <div v-if="selectedRole === 'caretaker'" class="mb-3">
            <label for="linkedSenior" class="form-label">🔗 Linked Senior Citizen's Email</label>
            <input type="email" class="form-control" id="linkedSenior" v-model="linkedSeniorEmail" required>
            <small class="form-text text-muted">Used to link with the senior citizen you care for.</small>
          </div>

          <div class="mb-3 role-info-box">
            <h6 class="role-info-title">🛠 Role Capabilities:</h6>
            <ul class="role-info-list">
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
  </div>
</template>

<style scoped>

@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

.register-container {
  height: 100vh;
  width: 100vw;
  background: linear-gradient(135deg, #e0f7fa, #ffe0e0, #f3e5f5);
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Poppins', sans-serif;
  position: fixed;
  inset: 0;
  overflow-y: auto;
  padding: 20px 0;
}

.register-card {
  width: 90%;
  max-width: 1100px;
  display: flex;
  border-radius: 20px;
  box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  background: #ffffff;
  margin: auto;
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
  overflow-y: auto;
  max-height: 90vh;
}

.card-right::-webkit-scrollbar {
  width: 8px;
}

.card-right::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 10px;
}

.card-right::-webkit-scrollbar-thumb {
  background: #bfdbfe;
  border-radius: 10px;
}

.card-right::-webkit-scrollbar-thumb:hover {
  background: #93c5fd;
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

.form-control:focus, .form-select:focus {
  outline: none;
  border-color: #60a5fa;
  box-shadow: 0 0 0 4px rgba(96, 165, 250, 0.2);
  background-color: #ffffff;
}

.form-row {
  display: flex;
  gap: 15px;
}

.form-col {
  flex: 1;
}

.register-button {
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

.register-button::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: all 0.5s ease;
}

.register-button:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 15px rgba(59, 130, 246, 0.3);
  background: linear-gradient(90deg, #3b82f6, #2563eb);
}

.register-button:hover::before {
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

.role-info-box {
  background-color: #f0f7ff;
  border-radius: 12px;
  padding: 15px;
  margin-bottom: 20px;
  border-left: 4px solid #60a5fa;
}

.role-info-title {
  color: #3b82f6;
  font-weight: 600;
  margin-bottom: 10px;
  font-size: 1rem;
}

.role-info-list {
  list-style: none;
  padding-left: 5px;
  margin: 0;
}

.role-info-list li {
  margin-bottom: 5px;
  color: #4b5563;
  font-size: 0.95rem;
}

.form-text {
  font-size: 0.8rem;
  color: #6b7280;
  margin-top: -15px;
  display: block;
  margin-bottom: 15px;
}

.mb-3 {
  margin-bottom: 15px;
}

.d-flex {
  display: flex;
}

.justify-content-center {
  justify-content: center;
}

.mt-2 {
  margin-top: 15px;
}


@media (max-width: 992px) {
  .register-card {
    width: 95%;
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
    max-height: unset;
  }
  
  h1 {
    font-size: 1.8rem;
  }

  .form-row {
    flex-direction: column;
    gap: 0;
  }
}

@media (max-width: 480px) {
  .register-container {
    padding: 10px;
  }

  .register-card {
    width: 100%;
    border-radius: 15px;
  }

  .card-right {
    padding: 20px 15px;
  }
  
  h1 {
    font-size: 1.5rem;
  }
  
  .subtitle {
    font-size: 0.9rem;
  }
}
</style>
