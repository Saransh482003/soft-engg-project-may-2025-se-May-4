<template>
  <div class="chatbot-page">
    <div class="chatbot-header">
      <RouterLink to="/userdashboard" class="back-button">
        <span class="material-icons">arrow_back</span>
      </RouterLink>
      <h1>SHRAVAN Voice Assistant</h1>
      <div class="theme-toggle">
        <button @click="toggleDarkMode" class="theme-btn">
          <span class="material-icons">{{ darkMode ? 'light_mode' : 'dark_mode' }}</span>
        </button>
      </div>
    </div>

    <div class="chatbot-container">
      <div class="chat-header">
        <div class="chat-info">
           <img src="../assets/Sharvan_logo.jpeg" alt="Avatar" class="chat-avatar" />
          <div>
            <h2>SHRAVAN</h2>
            <p>Your health assistant</p>
          </div>
        </div>
      </div>

      <div class="chat-messages" ref="messagesContainer">
        <div v-if="messages.length === 0" class="empty-chat">
          <span class="material-icons">forum</span>
          <p>Ask me anything about your health, medications, or care!</p>
        </div>
        
        <div v-for="(msg, index) in messages" :key="index" 
             :class="['message-bubble', msg.sender]">
          <div class="message-content">
            <p>{{ msg.text }}</p>
            <span class="message-time">{{ msg.time }}</span>
          </div>
        </div>
      </div>

      <div class="chat-input">
        <form @submit.prevent="sendMessage" class="input-form">
          <input
            v-model="userInput"
            type="text"
            placeholder="Type your message..."
            :disabled="isProcessing"
          />
          <button 
            type="button" 
            @click="startListening" 
            :disabled="!supportsSpeech || isProcessing"
            class="voice-btn"
            :class="{ 'listening': isListening }"
          >
            <span class="material-icons">{{ isListening ? 'mic' : 'mic_none' }}</span>
          </button>
          <button 
            type="submit" 
            class="send-btn"
            :disabled="!userInput.trim() || isProcessing"
          >
            <span class="material-icons">send</span>
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, nextTick, watch } from 'vue';
import axios from 'axios';
import { useRouter } from 'vue-router';

interface Message {
  text: string;
  sender: 'user' | 'bot';
  time: string;
}

const router = useRouter();
const messages = ref<Message[]>([]);
const userInput = ref('');
const supportsSpeech = ref(false);
const isListening = ref(false);
const isProcessing = ref(false);
const messagesContainer = ref<HTMLElement | null>(null);
const darkMode = ref(localStorage.getItem('darkMode') === 'true');

let recognition: any = null;


onMounted(() => {

  messages.value.push({ 
    text: "Hello! I'm SHARVAN, your health assistant. How can I help you today?", 
    sender: 'bot',
    time: getCurrentTime()
  });


  scrollToBottom();
  

  document.body.classList.toggle('dark-mode', darkMode.value);
  

  const SpeechRecognitionClass =
    (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;
    
  if (SpeechRecognitionClass) {
    supportsSpeech.value = true;
    recognition = new SpeechRecognitionClass();
    recognition.lang = 'en-IN';
    recognition.continuous = false;
    recognition.interimResults = false;

    recognition.onstart = () => {
      isListening.value = true;
    };

    recognition.onend = () => {
      isListening.value = false;
    };

    recognition.onresult = (event: any) => {
      const transcript = event.results[0][0].transcript;
      userInput.value = transcript;
      sendMessage();
    };
    
    recognition.onerror = () => {
      isListening.value = false;
    };
  }
});


watch(messages, () => {
  nextTick(() => {
    scrollToBottom();
  });
});


const getCurrentTime = () => {
  const now = new Date();
  return now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
};


const sendMessage = async () => {
  if (!userInput.value.trim() || isProcessing.value) return;
  
  const messageText = userInput.value;
  userInput.value = '';
  isProcessing.value = true;
  

  messages.value.push({ 
    text: messageText, 
    sender: 'user',
    time: getCurrentTime()
  });

  try {

    setTimeout(() => {

      let botResponse = "I'm sorry, I don't understand that yet. My capabilities are still developing.";
      
      if (messageText.toLowerCase().includes('medicine')) {
        botResponse = "I can help you track your medications. Would you like to see your medicine schedule or set a reminder?";
      } else if (messageText.toLowerCase().includes('doctor') || messageText.toLowerCase().includes('appointment')) {
        botResponse = "You can find nearby doctors in the Doctor Finder section. Would you like me to open that for you?";
      } else if (messageText.toLowerCase().includes('emergency')) {
        botResponse = "If you're experiencing an emergency, please use the Emergency SOS feature or call emergency services immediately.";
      } else if (messageText.toLowerCase().includes('hello') || messageText.toLowerCase().includes('hi')) {
        botResponse = "Hello! How can I assist you with your health needs today?";
      }
      
      messages.value.push({ 
        text: botResponse, 
        sender: 'bot',
        time: getCurrentTime()
      });
      
      isProcessing.value = false;
    }, 1000);
  } catch (err) {
    messages.value.push({ 
      text: 'Sorry, I couldn\'t process your request. Please try again.', 
      sender: 'bot',
      time: getCurrentTime()
    });
    isProcessing.value = false;
  }
};


const startListening = () => {
  if (recognition && !isListening.value) {
    recognition.start();
  } else if (recognition && isListening.value) {
    recognition.stop();
  }
};


const scrollToBottom = () => {
  if (messagesContainer.value) {
    messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight;
  }
};


const toggleDarkMode = () => {
  darkMode.value = !darkMode.value;
  localStorage.setItem('darkMode', darkMode.value.toString());
  document.body.classList.toggle('dark-mode', darkMode.value);
};
</script>

<style scoped>
.chatbot-page {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background-color: var(--bg-color, #f5f5f5);
}

.chatbot-header {
  display: flex;
  align-items: center;
  padding: 1rem 1.5rem;
  background-color: var(--primary-color, #4e54c8);
  color: white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.chatbot-header h1 {
  flex: 1;
  font-size: 1.5rem;
  text-align: center;
  margin: 0;
}

.back-button {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background-color: rgba(255, 255, 255, 0.2);
  color: white;
  text-decoration: none;
  transition: background-color 0.3s;
}

.back-button:hover {
  background-color: rgba(255, 255, 255, 0.3);
}

.theme-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background-color: rgba(255, 255, 255, 0.2);
  color: white;
  border: none;
  cursor: pointer;
  transition: background-color 0.3s;
}

.theme-btn:hover {
  background-color: rgba(255, 255, 255, 0.3);
}

.chatbot-container {
  display: flex;
  flex-direction: column;
  max-width: 800px;
  width: 100%;
  margin: 1rem auto;
  flex: 1;
  border-radius: 12px;
  background-color: var(--card-bg, white);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  overflow: hidden;  
}

.chat-header {
  padding: 1rem;
  border-bottom: 1px solid var(--border-color, #eaeaea);
  background-color: var(--card-bg-accent, #f9f9f9);
}

.chat-info {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.chat-info .material-icons {
  font-size: 2rem;
  color: var(--primary-color, #4e54c8);
  background-color: var(--icon-bg, rgba(78, 84, 200, 0.1));
  padding: 8px;
  border-radius: 50%;
}

.chat-info h2 {
  margin: 0;
  font-size: 1.2rem;
  color: var(--text-color, #333);
}

.chat-info p {
  margin: 0;
  font-size: 0.85rem;
  color: var(--text-muted, #666);
}

.chat-messages {
  flex: 1;
  padding: 1rem;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  background-color: var(--chat-bg, #f5f7fb);
}

.empty-chat {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: var(--text-muted, #888);
}

.empty-chat .material-icons {
  font-size: 3rem;
  margin-bottom: 1rem;
  opacity: 0.5;
}

.message-bubble {
  max-width: 75%;
  padding: 0.75rem 1rem;
  border-radius: 18px;
  position: relative;
  animation: fadeIn 0.3s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.message-bubble.user {
  align-self: flex-end;
  background-color: var(--primary-color, #4e54c8);
  color: white;
  border-bottom-right-radius: 4px;
}

.message-bubble.bot {
  align-self: flex-start;
  background-color: var(--message-bot-bg, #e9ecef);
  color: var(--text-color, #333);
  border-bottom-left-radius: 4px;
}

.message-content {
  display: flex;
  flex-direction: column;
}

.message-content p {
  margin: 0;
  line-height: 1.4;
  word-break: break-word;
}

.message-time {
  font-size: 0.7rem;
  margin-top: 4px;
  opacity: 0.7;
  align-self: flex-end;
}

.chat-input {
  padding: 1rem;
  border-top: 1px solid var(--border-color, #eaeaea);
  background-color: var(--card-bg, white);
}

.input-form {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background-color: var(--input-bg, #f0f2f5);
  border-radius: 24px;
  padding: 0.5rem 0.75rem;
}

.input-form input {
  flex: 1;
  border: none;
  outline: none;
  background: transparent;
  padding: 0.5rem;
  font-size: 1rem;
  color: var(--text-color, #333);
}

.input-form input::placeholder {
  color: var(--text-muted, #888);
}

.voice-btn, .send-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border: none;
  background-color: var(--btn-bg, rgba(78, 84, 200, 0.1));
  color: var(--primary-color, #4e54c8);
  cursor: pointer;
  transition: all 0.2s;
}

.voice-btn:hover, .send-btn:hover {
  background-color: var(--btn-hover-bg, rgba(78, 84, 200, 0.2));
}

.voice-btn:disabled, .send-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.voice-btn.listening {
  background-color: #ff5252;
  color: white;
  animation: pulse 1.5s infinite;
}

@keyframes pulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.1); }
  100% { transform: scale(1); }
}

.send-btn {
  background-color: var(--primary-color, #4e54c8);
  color: white;
}


:root {
  --bg-color: #f5f5f5;
  --card-bg: white;
  --card-bg-accent: #f9f9f9;
  --primary-color: #4e54c8;
  --text-color: #333;
  --text-muted: #666;
  --border-color: #eaeaea;
  --chat-bg: #f5f7fb;
  --message-bot-bg: #e9ecef;
  --input-bg: #f0f2f5;
  --btn-bg: rgba(78, 84, 200, 0.1);
  --btn-hover-bg: rgba(78, 84, 200, 0.2);
  --icon-bg: rgba(78, 84, 200, 0.1);
}

:global(.dark-mode) {
  --bg-color: #121212;
  --card-bg: #1e1e1e;
  --card-bg-accent: #252525;
  --primary-color: #6c72dc;
  --text-color: #e0e0e0;
  --text-muted: #a0a0a0;
  --border-color: #333;
  --chat-bg: #151515;
  --message-bot-bg: #2a2a2a;
  --input-bg: #252525;
  --btn-bg: rgba(108, 114, 220, 0.2);
  --btn-hover-bg: rgba(108, 114, 220, 0.3);
  --icon-bg: rgba(108, 114, 220, 0.2);
}

.chat-avatar {
  width: 48px;
  height: 48px;
  object-fit: cover;
  border-radius: 50%;
  background-color: var(--icon-bg, rgba(78, 84, 200, 0.1));
  padding: 4px;
}

html, body {
  margin: 0 !important;
  padding: 0 !important;
  width: 100vw !important;
  overflow-x: hidden;
}

</style>
