<template>
  <div :class="{ dark: isDark }">
    <!-- Navbar visibile solo se utente loggato -->
    <nav
      v-if="auth.isAuthenticated"
      class="p-4 bg-gray-200 dark:bg-gray-800 dark:text-gray-100 flex gap-4"
    >
      <router-link to="/dashboard" class="px-2 py-1">Dashboard</router-link>
      <router-link to="/profile" class="px-2 py-1">Profilo</router-link>
      <router-link
        to="/users"
        v-if="auth.hasRole('admin') || auth.hasRole('editor')"
        class="px-2 py-1"
        >Utenti</router-link
      >
      <button @click="logout" class="px-2 py-1">Logout</button>
      <button
        @click="toggleTheme"
        class="ml-auto px-2 py-1 rounded border dark:border-gray-600"
      >
        <span v-if="isDark">🌙</span>
        <span v-else>☀️</span>
      </button>
    </nav>
    <div class="h-dvh dark:bg-gray-900 dark:text-white dark:border-gray-700">
      <transition name="fade-page" mode="out-in">
        <router-view />
      </transition>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useAuthStore } from "./store/auth";
import { useRouter } from "vue-router";

const auth = useAuthStore();
const router = useRouter();

const isDark = ref(false);

const loadTheme = () => {
  const saved = localStorage.getItem("theme");
  if (saved === "dark") {
    isDark.value = true;
    document.documentElement.classList.add("dark");
  } else {
    isDark.value = false;
    document.documentElement.classList.remove("dark");
  }
};

const toggleTheme = () => {
  isDark.value = !isDark.value;
  localStorage.setItem("theme", isDark.value ? "dark" : "light");
  if (isDark.value) {
    document.documentElement.classList.add("dark");
  } else {
    document.documentElement.classList.remove("dark");
  }
};

onMounted(loadTheme);

const logout = () => {
  auth.logout();
  router.push({ name: "login" });
};
</script>
