<template>
  <div class="flex items-center justify-center min-h-screen bg-gray-100">
    <form @submit.prevent="submitLogin" class="bg-white p-6 rounded shadow-md w-80">
      <h2 class="text-xl font-bold mb-4">Login</h2>
      <input 
        v-model="email" 
        type="email" 
        placeholder="Email" 
        class="w-full mb-3 p-2 border rounded"
      />
      <input 
        v-model="password" 
        type="password" 
        placeholder="Password" 
        class="w-full mb-3 p-2 border rounded"
      />
      <button 
        type="submit" 
        class="w-full bg-blue-500 text-white py-2 rounded"
      >
        Accedi
      </button>
      <p v-if="error" class="text-red-500 mt-2">{{ error }}</p>
    </form>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../store/auth'

const email = ref('')
const password = ref('')
const error = ref(null)

const router = useRouter()
const auth = useAuthStore()

const submitLogin = async () => {
  error.value = null
  try {
    await auth.login(email.value, password.value)
    router.push({ name: 'dashboard' })
  } catch (err) {
    error.value = "Credenziali non valide"
  }
}
</script>
