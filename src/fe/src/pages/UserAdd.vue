<template>
    <nav class="ml-4 pt-6 mb-6 text-sm" aria-label="Breadcrumb">
    <ol class="list-reset flex text-gray-600">
      <li>
        <router-link to="/users" class="hover:underline text-blue-600">Utenti</router-link>
      </li>
      <li><span class="mx-2">/</span></li>
      <li class="text-gray-900 font-semibold dark:text-white">Aggiungi</li>
    </ol>
  </nav>
    <transition name="fade-modal">
      <div class="max-w-xl mx-auto mt-10 p-6 bg-white rounded shadow dark:bg-gray-800 dark:text-white dark:border-gray-700">
        <h2 class="text-2xl font-bold mb-4">Aggiungi Nuovo Utente</h2>
        <form @submit.prevent="addUser">
          <div class="mb-4 ">
            <label class="block mb-1 font-semibold">Nome</label>
            <input v-model="user.name" class="w-full border rounded px-3 py-2 dark:bg-gray-900 dark:text-white dark:border-gray-700" required />
          </div>
          <div class="mb-4">
            <label class="block mb-1 font-semibold">Email</label>
            <input
              v-model="user.email"
              class="w-full border rounded px-3 py-2 dark:bg-gray-900 dark:text-white dark:border-gray-700"
              type="email"
              required
              @blur="validateEmail"
            />
            <div v-if="emailError" class="text-red-500 text-sm mt-1">{{ emailError }}</div>
          </div>
          <div class="mb-4">
            <label class="block mb-1 font-semibold">Password</label>
            <input v-model="user.password" class="w-full border rounded px-3 py-2 dark:bg-gray-900 dark:text-white dark:border-gray-700" type="password" required />
          </div>
          <div class="mb-4">
            <label class="block mb-1 font-semibold">Ruoli</label>
            <input v-model="rolesInput" class="w-full border rounded px-3 py-2 dark:bg-gray-900 dark:text-white dark:border-gray-700" placeholder="Ruoli separati da virgola" />
          </div>
          <div v-if="error" class="text-red-500 mb-2">{{ error }}</div>
          <div class="flex gap-2">
            <button type="submit" class="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700">Aggiungi</button>
            <router-link :to="'/users'" class="bg-gray-300 px-4 py-2 rounded hover:bg-gray-400">Annulla</router-link>
          </div>
        </form>
      </div>
    </transition>
</template>
<style>
.fade-modal-enter-active, .fade-modal-leave-active {
  transition: opacity 0.3s cubic-bezier(0.4,0,0.2,1);
}
.fade-modal-enter-from, .fade-modal-leave-to {
  opacity: 0;
}
</style>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';

const router = useRouter();
const user = ref({ name: '', email: '', password: '', roles: [] });
const rolesInput = ref('');
const error = ref(null);
const emailError = ref('');
const validateEmail = () => {
  // Semplice regex per validazione email
  const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailPattern.test(user.value.email)) {
    emailError.value = 'Inserisci un indirizzo email valido';
    return false;
  } else {
    emailError.value = '';
    return true;
  }
};

const API_URL = import.meta.env.VITE_API_BASE_URL;

const addUser = async () => {
  if (!validateEmail()) {
    return;
  }
  try {
    const token = localStorage.getItem('token');
    const newUser = {
      ...user.value,
      roles: rolesInput.value.split(',').map(r => ({ name: r.trim() })).filter(r => r.name)
    };
    await axios.post(`${API_URL}/users/save`, newUser, {
      headers: { Authorization: `Bearer ${token}` },
    });
    router.push('/users');
  } catch (err) {
    error.value = 'Errore durante la creazione dell\'utente';
  }
};
</script>
