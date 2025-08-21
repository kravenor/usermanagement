<template>
    
  <nav class="ml-4 pt-6 mb-6 text-sm" aria-label="Breadcrumb">
    <ol class="list-reset flex text-gray-600">
      <li>
        <router-link to="/users" class="hover:underline text-blue-600"
          >Utenti</router-link
        >
      </li>
      <li><span class="mx-2">/</span></li>
      <li class="text-gray-900 font-semibold dark:text-white">Modifica</li>
    </ol>
  </nav>
    <transition name="fade-modal">
      <div class="max-w-xl mx-auto mt-10 p-6 bg-white rounded shadow dark:bg-gray-800 dark:text-white dark:border-gray-700">
        <h2 class="text-2xl font-bold mb-4">Modifica Utente</h2>

        <UserForm
          :user="user"
          :roles="rolesInput"
          :error="error"
          submit-label="Salva"
          cancel-url="/users"
          @submit="onFormSubmit"
        />
      </div>
    </transition>

</template>
<script setup>
import UserForm from "../components/UserForm.vue";
import { ref, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import axios from "axios";

const route = useRoute();
const router = useRouter();
const user = ref({ name: "", email: "", roles: [] });
const rolesInput = ref("");
const error = ref(null);

const API_URL = import.meta.env.VITE_API_BASE_URL;

const fetchUser = async () => {
  try {
    const token = localStorage.getItem("token");
    const { data } = await axios.post(`${API_URL}/users/show`, {
      headers: { Authorization: `Bearer ${token}` },
      id: route.params.id,
    });
    user.value = data;
    console.log(data.roles);
    rolesInput.value = data.roles.map((r) => r.name).join(", ");
  } catch (err) {
    error.value = "Errore nel caricamento dei dati utente";
  }
};

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
      id: route.params.id,
    });
    router.push("/users");
  } catch (err) {
    error.value = "Errore durante il salvataggio";
  }
};

onMounted(fetchUser);
</script>
