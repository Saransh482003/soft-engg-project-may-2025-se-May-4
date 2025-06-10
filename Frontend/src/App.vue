<script setup>
import { RouterLink, RouterView } from 'vue-router'
import { messageStore } from './stores/messageStore';

const message_store = messageStore()
</script>

<template>
  <div class="container-fluid text-bg-warning" >
    <p>{{ message_store.flash_message }}</p>
  </div>
  <RouterView />
</template>