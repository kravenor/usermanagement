<template>
  <div class="h-dvh dark:bg-gray-900 dark:text-white dark:border-gray-700">
    <div class="p-6">
      <h2 class="text-xl font-bold">Profilo Utente</h2>
      <p v-if="user">Ciao {{ user.name }} ({{ user.email }})</p>
      <p v-else>Caricamento...</p>
    </div>

    <div class="p-6" v-if="message">
      <div class="w-full border border-green-500">
        {{ message }}
      </div>
    </div>
    <transition name="fade-modal">
      <div class="p-6">
        <p>Puoi modificare il tuo profilo qui sotto:</p>
        <UserForm
          v-if="user"
          :user="user"
          :roles="roles"
          submit-label="Salva Modifiche"
          cancel-url="/profile"
          @submit="onFormSubmit"
          :personalProfile="true"
        />
      </div>
    </transition>
  </div>
</template>
<style scoped>
.fade-modal-enter-active,
.fade-modal-leave-active {
  transition: opacity 0.6s cubic-bezier(0.4, 0, 0.2, 1);
}
.fade-modal-enter-from,
.fade-modal-leave-to {
  opacity: 0;
}
</style>
<script setup>
import { ref, onMounted } from "vue";
import { useAuthStore } from "@/store/auth";
import UserForm from "@/components/UserForm.vue";
import axios from "axios";
const API_URL = import.meta.env.VITE_API_BASE_URL;

const user = ref(null);
const roles = ref("");
const auth = useAuthStore();
const error = ref(null);
const message = ref("");

onMounted(async () => {
  if (auth.user && auth.roles) {
    user.value = auth.user;
    roles.value = auth.roles.toString();
  } else {
    auth
      .fetchUser()
      .then(() => {
        user.value = auth.user;
        roles.value = auth.roles.toString();
      })
      .catch((err) => {
        console.error("Errore nel caricamento del profilo:", err);
      });
  }
});

const onFormSubmit = async ({ user: formUser, roles }) => {
  try {
    const token = localStorage.getItem("token");
    const updatedUser = {
      ...formUser,
      roles: roles
        .split(",")
        .map((r) => ({ name: r.trim() }))
        .filter((r) => r.name),
    };
    await axios.put(`${API_URL}/users/update`, updatedUser, {
      headers: { Authorization: `Bearer ${token}` },
      id: user.id,
    });
    message.value = "Profilo aggiornato con successo!";
    router.push("/profile");
  } catch (err) {
    error.value = "Errore durante il salvataggio";
  }
};
</script>
