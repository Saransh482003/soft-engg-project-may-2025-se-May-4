<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();
const showModal = ref(false);
const isLoading = ref(false);
const errorMessage = ref('');
const successMessage = ref('');

// Blog post form data
const newPost = ref({
  title: '',
  summary: '',
  content: '',
  category: 'general',
  image: null
});

// Sample existing blog posts (would come from API in real app)
const healthTips = ref([
  {
    id: 1,
    title: 'Staying Hydrated in Summer',
    summary: 'Tips for maintaining hydration during hot weather',
    content: 'Water is essential for maintaining good health, especially during hot summer months...',
    category: 'general',
    author: 'Dr. Sharma',
    publishedDate: '2025-05-20',
    imageUrl: 'https://placehold.co/300x200/e0f7fa/1f2937?text=Hydration'
  },
  {
    id: 2,
    title: 'Managing Diabetes Through Diet',
    summary: 'Dietary recommendations for diabetes management',
    content: 'A balanced diet is key to managing diabetes effectively...',
    category: 'chronic-care',
    author: 'Dr. Patel',
    publishedDate: '2025-06-01',
    imageUrl: 'https://placehold.co/300x200/e0f7fa/1f2937?text=Diabetes'
  },
  {
    id: 3,
    title: 'Simple Exercises for Seniors',
    summary: 'Low-impact exercises suitable for elderly people',
    content: 'Regular physical activity is important for seniors to maintain mobility and health...',
    category: 'elderly-care',
    author: 'Dr. Kumar',
    publishedDate: '2025-06-10',
    imageUrl: 'https://placehold.co/300x200/e0f7fa/1f2937?text=Exercise'
  }
]);

// Categories for the dropdown
const categories = [
  { value: 'general', label: 'General Health' },
  { value: 'elderly-care', label: 'Elderly Care' },
  { value: 'chronic-care', label: 'Chronic Disease Management' },
  { value: 'mental-health', label: 'Mental Health' },
  { value: 'nutrition', label: 'Nutrition & Diet' }
];

onMounted(() => {
  // In a real application, you would fetch blog posts from the backend
  // fetchHealthTips();
});

function openModal() {
  // Reset form fields
  newPost.value = {
    title: '',
    summary: '',
    content: '',
    category: 'general',
    image: null
  };
  errorMessage.value = '';
  successMessage.value = '';
  showModal.value = true;
}

function closeModal() {
  showModal.value = false;
}

function handleImageUpload(event) {
  const file = event.target.files[0];
  if (file) {
    newPost.value.image = file;
  }
}

async function submitPost() {
  // Basic validation
  if (!newPost.value.title || !newPost.value.content) {
    errorMessage.value = 'Please fill in all required fields';
    return;
  }

  isLoading.value = true;
  try {
    // In a real app, this would be an API call to submit the post
    // const formData = new FormData();
    // formData.append('title', newPost.value.title);
    // formData.append('summary', newPost.value.summary);
    // formData.append('content', newPost.value.content);
    // formData.append('category', newPost.value.category);
    // if (newPost.value.image) {
    //   formData.append('image', newPost.value.image);
    // }
    
    // const response = await fetch('/api/health-tips', {
    //   method: 'POST',
    //   body: formData
    // });
    
    // if (!response.ok) {
    //   throw new Error('Failed to create post');
    // }

    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // Add the new post to the list (in a real app, we'd use the data from the API response)
    const newId = healthTips.value.length > 0 ? Math.max(...healthTips.value.map(tip => tip.id)) + 1 : 1;
    
    healthTips.value.unshift({
      id: newId,
      title: newPost.value.title,
      summary: newPost.value.summary,
      content: newPost.value.content,
      category: newPost.value.category,
      author: 'You', // Would come from user profile
      publishedDate: new Date().toISOString().split('T')[0],
      imageUrl: newPost.value.image ? URL.createObjectURL(newPost.value.image) : 'https://placehold.co/300x200/e0f7fa/1f2937?text=New+Post'
    });
    
    successMessage.value = 'Health tip published successfully!';
    
    // Close modal after success (with slight delay to show success message)
    setTimeout(() => {
      closeModal();
      successMessage.value = '';
    }, 2000);
    
  } catch (error) {
    console.error('Error publishing health tip:', error);
    errorMessage.value = 'Failed to publish health tip. Please try again.';
  } finally {
    isLoading.value = false;
  }
}

function goBack() {
  router.push('/tertiary-dashboard');
}

function getCategoryLabel(categoryValue) {
  const category = categories.find(cat => cat.value === categoryValue);
  return category ? category.label : categoryValue;
}

function truncateText(text, length = 120) {
  return text.length > length ? text.substring(0, length) + '...' : text;
}
</script>

<template>
  <div class="health-tips-container">
    <!-- Navigation Bar -->
    <nav class="navbar">
      <div class="logo">
        <span>🌿 SHARVAN</span>
      </div>
      <div class="nav-right">
        <button class="back-button" @click="goBack">
          ← Back to Dashboard
        </button>
      </div>
    </nav>

    <!-- Header Section -->
    <section class="header-section">
      <h1>Health Tips & Resources</h1>
      <p class="subtitle">Share health information with the community</p>
    </section>

    <!-- Content Section -->
    <div class="content-container">
      <!-- Action Bar -->
      <div class="action-bar">
        <button class="new-post-button" @click="openModal">
          ✏️ Create New Health Tip
        </button>
      </div>

      <!-- Blog Posts Grid -->
      <div class="blog-grid">
        <div v-for="post in healthTips" :key="post.id" class="blog-card">
          <div class="blog-image">
            <img :src="post.imageUrl" :alt="post.title">
            <div class="category-badge">{{ getCategoryLabel(post.category) }}</div>
          </div>
          <div class="blog-content">
            <h2>{{ post.title }}</h2>
            <p class="blog-meta">
              <span>{{ post.author }}</span> • 
              <span>{{ new Date(post.publishedDate).toLocaleDateString() }}</span>
            </p>
            <p class="blog-summary">{{ post.summary }}</p>
            <button class="read-more-button">Read More</button>
          </div>
        </div>
      </div>
    </div>

    <!-- New Post Modal -->
    <div class="modal-overlay" v-if="showModal" @click.self="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h2>Create New Health Tip</h2>
          <button class="close-button" @click="closeModal">×</button>
        </div>
        
        <div class="modal-body">
          <div v-if="successMessage" class="success-message">
            {{ successMessage }}
          </div>
          
          <div v-if="errorMessage" class="error-message">
            {{ errorMessage }}
          </div>
          
          <form @submit.prevent="submitPost">
            <div class="form-group">
              <label for="title">Title *</label>
              <input 
                type="text" 
                id="title" 
                v-model="newPost.title" 
                placeholder="Enter a title for your health tip"
                required
              >
            </div>
            
            <div class="form-group">
              <label for="summary">Summary</label>
              <input 
                type="text" 
                id="summary" 
                v-model="newPost.summary" 
                placeholder="A brief summary of your health tip"
              >
            </div>
            
            <div class="form-group">
              <label for="category">Category</label>
              <select id="category" v-model="newPost.category">
                <option v-for="category in categories" :key="category.value" :value="category.value">
                  {{ category.label }}
                </option>
              </select>
            </div>
            
            <div class="form-group">
              <label for="content">Content *</label>
              <textarea 
                id="content" 
                v-model="newPost.content" 
                placeholder="Write your health tip content here..." 
                rows="8"
                required
              ></textarea>
            </div>
            
            <div class="form-group">
              <label for="image">Featured Image</label>
              <input 
                type="file" 
                id="image" 
                @change="handleImageUpload" 
                accept="image/*"
              >
              <small>Recommended size: 800x600 pixels</small>
            </div>
            
            <div class="form-actions">
              <button type="button" class="cancel-button" @click="closeModal">Cancel</button>
              <button type="submit" class="submit-button" :disabled="isLoading">
                <span v-if="isLoading">Publishing...</span>
                <span v-else>Publish Health Tip</span>
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

/* Base Styles */
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

.health-tips-container {
  min-height: 100vh;
  width: 100%;
  background: linear-gradient(135deg, #e0ffe0, #e6fff9);
  font-family: 'Poppins', sans-serif;
  display: flex;
  flex-direction: column;
  color: #333;
}

/* Navbar Styles */
.navbar {
  background-color: white;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 30px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 100;
  width: 100%;
}

.logo {
  font-size: 1.5rem;
  font-weight: 600;
  color: #059669;
}

.nav-right {
  display: flex;
  align-items: center;
}

.back-button {
  background-color: #f3f4f6;
  color: #4b5563;
  border: none;
  padding: 10px 20px;
  border-radius: 10px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.back-button:hover {
  background-color: #e5e7eb;
  color: #1f2937;
}

/* Header Section */
.header-section {
  padding: 30px;
  text-align: center;
}

h1 {
  color: #1f2937;
  font-size: 2.2rem;
  margin-bottom: 10px;
  font-weight: 600;
}

.subtitle {
  color: #6b7280;
  font-size: 1.1rem;
}

/* Content Container */
.content-container {
  flex: 1;
  padding: 0 30px 30px;
}

/* Action Bar */
.action-bar {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 20px;
}

.new-post-button {
  background-color: #059669;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 10px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.new-post-button:hover {
  background-color: #047857;
  transform: translateY(-2px);
}

/* Blog Grid */
.blog-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 25px;
}

.blog-card {
  background-color: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.blog-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
}

.blog-image {
  height: 180px;
  position: relative;
}

.blog-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.category-badge {
  position: absolute;
  top: 10px;
  right: 10px;
  background-color: rgba(5, 150, 105, 0.8);
  color: white;
  padding: 5px 10px;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 500;
}

.blog-content {
  padding: 20px;
}

.blog-content h2 {
  font-size: 1.2rem;
  margin-bottom: 10px;
  color: #1f2937;
}

.blog-meta {
  font-size: 0.8rem;
  color: #6b7280;
  margin-bottom: 10px;
}

.blog-summary {
  font-size: 0.95rem;
  color: #4b5563;
  margin-bottom: 15px;
  line-height: 1.5;
}

.read-more-button {
  background-color: transparent;
  color: #059669;
  border: 1px solid #059669;
  padding: 8px 16px;
  border-radius: 8px;
  font-size: 0.9rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.read-more-button:hover {
  background-color: #059669;
  color: white;
}

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background-color: white;
  border-radius: 12px;
  width: 90%;
  max-width: 700px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  border-bottom: 1px solid #e5e7eb;
}

.modal-header h2 {
  font-size: 1.5rem;
  color: #1f2937;
}

.close-button {
  background: none;
  border: none;
  font-size: 1.5rem;
  color: #6b7280;
  cursor: pointer;
}

.modal-body {
  padding: 20px;
}

.success-message {
  background-color: #d1fae5;
  color: #059669;
  padding: 10px;
  border-radius: 8px;
  margin-bottom: 15px;
}

.error-message {
  background-color: #fee2e2;
  color: #ef4444;
  padding: 10px;
  border-radius: 8px;
  margin-bottom: 15px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #4b5563;
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  font-family: 'Poppins', sans-serif;
  font-size: 0.95rem;
}

.form-group textarea {
  resize: vertical;
}

.form-group small {
  font-size: 0.8rem;
  color: #6b7280;
  margin-top: 5px;
  display: block;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 15px;
  margin-top: 20px;
}

.cancel-button {
  background-color: #f3f4f6;
  color: #4b5563;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
}

.submit-button {
  background-color: #059669;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
}

.submit-button:disabled {
  background-color: #9ca3af;
  cursor: not-allowed;
}

/* Responsive Adjustments */
@media (max-width: 768px) {
  .header-section {
    padding: 20px 15px;
  }
  
  .content-container {
    padding: 0 15px 20px;
  }
  
  .blog-grid {
    grid-template-columns: 1fr;
  }
  
  .action-bar {
    justify-content: center;
  }
  
  .form-actions {
    flex-direction: column;
  }
  
  .cancel-button, .submit-button {
    width: 100%;
  }
}
</style>