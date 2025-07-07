<template>
  <div class="chat-page">
    <!-- Top Navigation -->
    <nav class="navbar fixed-top">
      <div class="navbar-content">
        <RouterLink class="home-btn" to="/userdashboard">🏠 Home</RouterLink>
        <h1 class="title">🎙️ SHARVAN Voice/Text Chatbot</h1>
      </div>
    </nav>

    <!-- Main Chat Area -->
    <div class="chat-container">
      <div class="chat-window">
        <div class="messages" ref="chatRef">
          <div
            v-for="(msg, index) in messages"
            :key="index"
            :class="['message', msg.sender]"
          >
            <div class="bubble">
              <strong>{{ msg.sender === 'user' ? '🧑 You:' : '🤖 Bot:' }}</strong>
              <span>{{ msg.text }}</span>
            </div>
          </div>
        </div>

        <!-- Input Area -->
        <form @submit.prevent="sendMessage" class="input-area">
          <input
            v-model="userInput"
            type="text"
            class="message-input"
            placeholder="Type your message..."
          />
          <button type="submit" class="btn-send">Send</button>
          <button
            type="button"
            class="btn-voice"
            @click="startListening"
            :disabled="!supportsSpeech"
          >
            🎤
          </button>
        </form>

        <p v-if="!supportsSpeech" class="no-voice-support">
          ⚠️ Voice input not supported in this browser.
        </p>
      </div>
    </div>
  </div>
</template>



<script setup lang="ts">
import { ref, onMounted, nextTick } from 'vue';
import axios from 'axios';

interface Message {
  text: string;
  sender: 'user' | 'bot';
}

const messages = ref<Message[]>([]);
const userInput = ref('');
const supportsSpeech = ref(false);
let recognition: SpeechRecognition | null = null;

const chatRef = ref<HTMLElement | null>(null);

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

const scrollToBottom = () => {
  nextTick(() => {
    chatRef.value?.scrollTo({ top: chatRef.value.scrollHeight, behavior: 'smooth' });
  });
};

const sendMessage = async () => {
  if (!userInput.value.trim()) return;

  messages.value.push({ text: userInput.value, sender: 'user' });
  scrollToBottom();

  try {
    const res = await axios.post('https://your-backend-api/chatbot', {
      message: userInput.value,
    });
    messages.value.push({ text: res.data.reply, sender: 'bot' });
  } catch {
    messages.value.push({ text: 'Sorry, I couldn’t get that.', sender: 'bot' });
  }

  userInput.value = '';
  scrollToBottom();
};

const startListening = () => {
  if (recognition) recognition.start();
};
</script>


<style scoped>
.chat-page {
  /* background-image: url('../assets/Sharvan_logo.jpeg'); */
  background-color: green;
  height: 100vh;
  display: flex;
  flex-direction: column;
  .navbar{
    background-color: pink;
  }
}

.navbar {
  padding: 1rem 2rem;
  color: pink;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
  z-index: 1000;
}

.navbar-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.home-btn {
  color: white;
  background-color: #28a745;
  padding: 8px 14px;
  border-radius: 8px;
  text-decoration: none;
  font-size: 1rem;
}

.title {
  margin: 0;
  color: #198754;
  font-size: 1.5rem;
  font-weight: bold;
}

.chat-container {
  flex: 1;
  padding: 100px 20px 40px;
  display: flex;
  justify-content: center;
  align-items: flex-start;
}

.chat-window {
  width: 100%;
  max-width: 700px;
  background-color: #ffffff;
  border-radius: 16px;
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  height: 80vh;
}

.messages {
  flex: 1;
  overflow-y: auto;
  padding-right: 10px;
  margin-bottom: 1rem;
  scroll-behavior: smooth;
}

.message {
  display: flex;
  margin-bottom: 10px;
}

.message.user {
  justify-content: flex-end;
}

.message.bot {
  justify-content: flex-start;
}

.bubble {
  background-color: #d0e8ff;
  padding: 10px 14px;
  border-radius: 16px;
  max-width: 70%;
  word-wrap: break-word;
}

.message.user .bubble {
  background-color: #d0e8ff;
  color: #0d6efd;
  text-align: right;
}

.message.bot .bubble {
  background-color: #d4f5d2;
  color: #198754;
  text-align: left;
}

.input-area {
  display: flex;
  gap: 10px;
  align-items: center;
}

.message-input {
  flex: 1;
  padding: 12px;
  border-radius: 8px;
  border: 1px solid #ccc;
  font-size: 1rem;
}

.btn-send {
  background-color: #007bff;
  color: white;
  border: none;
  padding: 10px 18px;
  border-radius: 8px;
  font-weight: bold;
}

.btn-voice {
  background-color: #ffc107;
  border: none;
  padding: 10px 14px;
  border-radius: 8px;
  font-size: 1.2rem;
}

.no-voice-support {
  text-align: center;
  font-size: 0.9rem;
  color: gray;
  margin-top: 8px;
}

</style>
