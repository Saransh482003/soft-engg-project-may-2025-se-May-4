<template>
  <nav class="navbar navbar-dark bg-primary fixed-top">
    <RouterLink class="home-btn" to="/userdashboard">🏠 Home</RouterLink>
     <h2>🎙️ SHARVAN Voice/Text Chatbot</h2>
  </nav>
  <div class="chatbot-container">
    <div class="chat-box mb-3 p-3">
      <div v-for="(msg, index) in messages" :key="index" :class="msg.sender">
        <strong>{{ msg.sender === 'user' ? '🧑 You:' : '🤖 Bot:' }}</strong> {{ msg.text }}
      </div>
    </div>

    <form @submit.prevent="sendMessage" class="d-flex gap-2">
      <input
        v-model="userInput"
        class="form-control"
        type="text"
        placeholder="Type your question..."
      />
      <button class="btn btn-primary" type="submit">Send</button>
      <button
        class="btn btn-secondary"
        type="button"
        @click="startListening"
        :disabled="!supportsSpeech"
      >
        🎤 Speak
      </button>
    </form>

    <p v-if="!supportsSpeech" class="text-muted mt-2">
      ⚠️ Voice input not supported in this browser.
    </p>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import axios from 'axios';

interface Message {
  text: string;
  sender: 'user' | 'bot';
}

const messages = ref<Message[]>([]);
const userInput = ref('');
const supportsSpeech = ref(false);
let recognition: SpeechRecognition | null = null;

// Check for voice support
onMounted(() => {
  const SpeechRecognitionClass =
    (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;
  if (SpeechRecognitionClass) {
    supportsSpeech.value = true;
    recognition = new SpeechRecognitionClass();
    recognition.lang = 'en-IN';
    recognition.continuous = false;
    recognition.interimResults = false;

    recognition.onresult = (event: SpeechRecognitionEvent) => {
      const transcript = event.results[0][0].transcript;
      userInput.value = transcript;
      sendMessage();
    };
  }
});

// Send message to backend
const sendMessage = async () => {
  if (!userInput.value.trim()) return;

  messages.value.push({ text: userInput.value, sender: 'user' });

  try {
    const res = await axios.post('https://your-backend-api/chatbot', {
      message: userInput.value,
    });
    messages.value.push({ text: res.data.reply, sender: 'bot' });
  } catch (err) {
    messages.value.push({ text: 'Sorry, I couldn’t get that.', sender: 'bot' });
  }

  userInput.value = '';
};

// Trigger voice
const startListening = () => {
  if (recognition) recognition.start();
};
</script>

<style scoped>

.navbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background-color: #ffe6f0;
  color: black;
  padding: 10px 20px;
  border-radius: 10px;
  margin-bottom: 20px;
}
.home-btn {
  text-decoration: none;
  color: black;
  background: #ffe6f0;
  padding: 6px 12px;
  border-radius: 5px;
  font-size: larger;
}
.chatbot-container {
  max-width: 600px;
  margin: auto;
  padding: 1.5rem;
  background-color: #ffe6f0;
  border-radius: 12px;
  box-shadow: 0 0 12px rgba(0, 0, 0, 0.1);
}
.chat-box {
  height: 300px;
  overflow-y: auto;
  background: white;
  border: 1px solid #ccc;
  border-radius: 8px;
}
.user {
  text-align: right;
  margin-bottom: 8px;
  color: #0d6efd;
}
.bot {
  text-align: left;
  margin-bottom: 8px;
  color: #198754;
}
.container-fluid{
  text-align: right;
}
.form-control{
  font-size: large;
}
</style>
