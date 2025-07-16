<script setup>
import { ref } from 'vue'
import { RouterLink } from 'vue-router'

// Mock list of yoga video data (we will replace with real backend data later)
const yogaVideos = ref([
  {
    title: 'Gentle Yoga for Seniors – 20 Minutes',
    url: 'https://www.youtube.com/watch?v=kFhG-ZzLNN4',
    videoId: 'kFhG-ZzLNN4'
  },
  {
    title: 'Chair Yoga for Seniors – Easy Routine',
    url: 'https://www.youtube.com/watch?v=-Ts01MC2mIo',
    videoId: '-Ts01MC2mIo'
  },
  {
    title: 'Morning Yoga for Seniors – Stretch & Energize',
    url: 'https://www.youtube.com/watch?v=NDLad2vOHkU',
    videoId: 'NDLad2vOHkU'
  }
])
</script>

<template>
  <div class="yoga-container">
    <div class="top-bar">
      <RouterLink to="/userdashboard" class="home-btn">🏠 Home</RouterLink>
      <div>
      <img src="../assets/Sharvan_logo.jpeg" alt="Sharvan Logo" class="logo-image" />
      <span style="margin-left: 10px">SHRAVAN</span>
      </div>
    </div>

    <div class="video-grid">
      <div v-for="video in yogaVideos" :key="video.videoId" class="video-card">
        <img
          :src="`https://img.youtube.com/vi/${video.videoId}/0.jpg`"
          :alt="video.title"
          class="thumbnail"
        />
        <h4>{{ video.title }}</h4>
        <a :href="video.url" target="_blank" class="play-btn">▶️ Play</a>
      </div>
    </div>
  </div>
</template>

<style scoped>
.yoga-container {
  padding: 20px;
  font-family: sans-serif;
}
.logo-image {
  height: 36px;
  width: auto;
  object-fit: contain;
  display: inline-block;
  vertical-align: middle; /* Ensures inline alignment with text */
}
.top-bar {
  display: flex;
  align-items: left;
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
.video-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
}
.video-card {
  background: #f0f0f0;
  border-left: 5px solid #ffe6f0;
  padding: 15px;
  border-radius: 10px;
  box-shadow: 0 2px 5px rgba(0,0,0,0.1);
  text-align: center;
}
.thumbnail {
  width: 100%;
  border-radius: 10px;
  margin-bottom: 10px;
}
.play-btn {
  display: inline-block;
  margin-top: 8px;
  background: #ffe6f0;
  color: black;
  padding: 8px 12px;
  border-radius: 5px;
  text-decoration: none;
}
.play-btn:hover {
  background: #ffe6f0;
}
</style>
