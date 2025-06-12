import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import TertiaryUserDashboard from '@/views/TertiaryUserDashboard.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView,
    },
    {
      path: '/userlogin',
      name: 'userlogin',
      component: () => import('../views/Login.vue'),
    },
    {
      path: '/register',
      name: 'register',
      component: () => import('../views/Register.vue'),
    },
    {
      path: '/userdashboard',
      name: 'userdashboard',
      component: () => import('../views/UserDashboard.vue'),
    },
    {
      path: '/caretaker',
      name: 'caretaker',
     component: () => import('../views/CareTakerDashboard.vue'),
    },
    {
      path: '/tertiaryuser',
      name: 'tertiaryuser',
      component: () => import('../views/TertiaryUserDashboard.vue'),
    },
    {
      path: '/chatbot',
      name: 'chatbot',
      component: () => import('../views/Chatbot.vue'),
    },
    {
      path: '/emergencysos',
      name: 'emergencysos',
      component: () => import('../views/EmergencySOS.vue'),
    },
    {
      path: '/medicinereminders',
      name: 'medicinereminders',
      component: () => import('../views/MedicineReminders.vue'),
    },
    {
      path: '/doctorfinder',
      name: 'doctorfinder',
      component: () => import('../views/Doctorfinder.vue'),
    },
    {
      path: '/videos',
      name: 'videos',
      component: () => import('../views/Yogavideos.vue'),
    },
    {
      path: '/pharmacyfinder',
      name: 'pharmacyfinder',
      component: () => import('../views/pharmacyfinder.vue'),
    },
    {
      path: '/missedmedicinealert',
      name: 'missedmedicinealert',
      component: () => import('../views/missedmedicinealerts.vue'),
    },
    {
      path: '/about',
      name: 'about',
      // route level code-splitting
      // this generates a separate chunk (About.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () => import('../views/AboutView.vue'),
    },
  ],
})

export default router
