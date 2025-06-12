<script setup>
import { ref } from 'vue'
import { RouterLink } from 'vue-router'

// Mock list of yoga video data (replace with real backend data later)
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
      <h2>🧘 Yoga Videos for Seniors</h2>
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
.top-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background-color: #4caf50;
  color: white;
  padding: 10px 20px;
  border-radius: 10px;
  margin-bottom: 20px;
}
.home-btn {
  text-decoration: none;
  color: white;
  background: #388e3c;
  padding: 6px 12px;
  border-radius: 5px;
}
.video-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
}
.video-card {
  background: #f0f0f0;
  border-left: 5px solid #4caf50;
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
  background: #4caf50;
  color: white;
  padding: 8px 12px;
  border-radius: 5px;
  text-decoration: none;
}
.play-btn:hover {
  background: #388e3c;
}
</style>
