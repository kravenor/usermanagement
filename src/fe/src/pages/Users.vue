<script setup>
import { ref, onMounted } from "vue";
import { getUsers } from "../api/users";
import { useAuthStore } from "../store/auth";
import axios from "axios";
import { watchEffect } from "vue";

const API_URL = import.meta.env.VITE_API_BASE_URL;

const auth = useAuthStore();

const users = ref([]);
const loading = ref(false);
const error = ref(null);
const currentPage = ref(1);
const itemsPerPage = ref(10);
const totalItems = ref(0);
const sortBy = ref("id");
const sortDesc = ref(false);
const searchQuery = ref("");
const filteredUsers = ref([]);

const selectedUserIds = ref([]);
const allSelected = ref(false);

const fetchUsers = async () => {
  loading.value = true;
  error.value = null;
  try {
    const response = await getUsers(currentPage.value, itemsPerPage.value);
    users.value = response.data;
    totalItems.value = response.total;
    filterUsers();
  } catch (err) {
    error.value = "Errore nel caricamento degli utenti";
    console.error(err);
  } finally {
    loading.value = false;
  }
};

const changePage = (page) => {
  currentPage.value = page;
  fetchUsers();
};

const filterUsers = () => {
  const query = searchQuery.value.toLowerCase();
  filteredUsers.value = users.value.filter((user) => {
    return (
      user.id.toString().includes(query) ||
      user.name.toLowerCase().includes(query) ||
      user.email.toLowerCase().includes(query) ||
      user.roles.some((role) => role.name.toLowerCase().includes(query))
    );
  });
  sortUsers();
};

const sort = (field) => {
  if (sortBy.value === field) {
    sortDesc.value = !sortDesc.value;
  } else {
    sortBy.value = field;
    sortDesc.value = false;
  }
  sortUsers();
};

const sortUsers = () => {
  filteredUsers.value.sort((a, b) => {
    let aVal = a[sortBy.value];
    let bVal = b[sortBy.value];

    if (sortBy.value === "roles") {
      aVal = a.roles[0]?.name || "";
      bVal = b.roles[0]?.name || "";
    }

    if (aVal < bVal) return sortDesc.value ? 1 : -1;
    if (aVal > bVal) return sortDesc.value ? -1 : 1;
    return 0;
  });
};

const debouncedSearch = (e) => {
  searchQuery.value = e.target.value;
  filterUsers();
};

const deleteUser = async (userId) => {
  if (!confirm("Sei sicuro di voler eliminare questo utente?")) return;
  try {
    const token = localStorage.getItem("token");
    await axios.delete(`${API_URL}/users/delete`, {
      headers: { Authorization: `Bearer ${token}` },
      data: { id: userId },
    });
    fetchUsers();
  } catch (err) {
    error.value = "Errore durante l'eliminazione dell'utente";
    console.error(err);
  }
};

const deleteSelectedUsers = async () => {
  if (selectedUserIds.value.length === 0) return;
  if (!confirm(`Sei sicuro di voler eliminare ${selectedUserIds.value.length} utenti selezionati?`)) return;
  try {
    const token = localStorage.getItem("token");
    await axios.delete(`${API_URL}/users/delete-multiple`, {
      headers: { Authorization: `Bearer ${token}` },
      data: { ids: selectedUserIds.value },
    });
    selectedUserIds.value = [];
    allSelected.value = false;
    fetchUsers();
  } catch (err) {
    error.value = "Errore durante l'eliminazione degli utenti selezionati";
    console.error(err);
  }
};

const toggleSelectAll = () => {
  if (allSelected.value) {
    selectedUserIds.value = filteredUsers.value.map((user) => user.id);
  } else {
    selectedUserIds.value = [];
  }
};


watchEffect(() => {
  allSelected.value =
    filteredUsers.value.length > 0 &&
    filteredUsers.value.every((user) => selectedUserIds.value.includes(user.id));
});

onMounted(() => {
  fetchUsers();
});
</script>

<template>
  <div class="h-dvh dark:bg-gray-900 dark:text-white dark:border-gray-700">
    <div class="container mx-auto px-4 py-8">
        <div class="flex flex-col sm:flex-row justify-between items-center mb-6 gap-2">
          <h1 class="text-2xl font-bold">Lista Utenti</h1>
          <div class="flex gap-2 items-center w-full sm:w-auto">
            <router-link
              v-if="auth.hasRole('admin')"
              to="/users/add"
              class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded text-sm font-semibold whitespace-nowrap"
            >
              + Nuovo Utente
            </router-link>
            <button
              v-if="auth.hasRole('admin') && selectedUserIds.length > 0"
              @click="deleteSelectedUsers"
              class="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded text-sm font-semibold whitespace-nowrap"
            >
              Elimina selezionati ({{ selectedUserIds.length }})
            </button>
            <div class="relative flex-1">
              <input
                type="text"
                placeholder="Cerca..."
                @input="debouncedSearch"
                class="pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 w-full"
              />
              <div class="absolute left-3 top-2.5 text-gray-400">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                  />
                </svg>
              </div>
            </div>
          </div>
        </div>

      <!-- Loading state -->
      <div v-if="loading" class="text-center py-4">
        <div
          class="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900 mx-auto"
        ></div>
      </div>

      <!-- Error state -->
      <div
        v-else-if="error"
        class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded"
        role="alert"
      >
        {{ error }}
      </div>

      <!-- Data table -->
      <div v-else>
        <div
          class="shadow overflow-hidden border-b border-gray-200 sm:rounded-lg"
        >
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-4 py-3 text-center">
                  <input type="checkbox" :checked="allSelected" @change="toggleSelectAll" />
                </th>
                <th
                  @click="sort('id')"
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100"
                >
                  ID
                  <span v-if="sortBy === 'id'" class="ml-1">{{
                    sortDesc ? "▼" : "▲"
                  }}</span>
                </th>
                <th
                  @click="sort('name')"
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100"
                >
                  Nome
                  <span v-if="sortBy === 'name'" class="ml-1">{{
                    sortDesc ? "▼" : "▲"
                  }}</span>
                </th>
                <th
                  @click="sort('email')"
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100"
                >
                  Email
                  <span v-if="sortBy === 'email'" class="ml-1">{{
                    sortDesc ? "▼" : "▲"
                  }}</span>
                </th>
                <th
                  @click="sort('roles')"
                  class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100"
                >
                  Ruolo
                  <span v-if="sortBy === 'roles'" class="ml-1">{{
                    sortDesc ? "▼" : "▲"
                  }}</span>
                </th>
                <th class="px-6 py-3"></th>
                <th class="px-6 py-3"></th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="user in filteredUsers" :key="user.id">
                <td class="px-4 py-4 text-center dark:bg-gray-800 dark:text-white dark:border-gray-700">
                  <input type="checkbox" :value="user.id" v-model="selectedUserIds" />
                </td>
                <td class="px-6 py-4 whitespace-nowrap dark:bg-gray-800 dark:text-white dark:border-gray-700">{{ user.id }}</td>
                <td class="px-6 py-4 whitespace-nowrap dark:bg-gray-800 dark:text-white dark:border-gray-700">{{ user.name }}</td>
                <td class="px-6 py-4 whitespace-nowrap dark:bg-gray-800 dark:text-white dark:border-gray-700">{{ user.email }}</td>
                <td class="px-6 py-4 whitespace-nowrap dark:bg-gray-800 dark:text-white dark:border-gray-700">
                  <span
                    v-for="role in user.roles"
                    :key="role"
                    class="inline-block bg-blue-100 text-blue-800 text-xs font-semibold mr-2 px-2.5 py-0.5 rounded"
                  >
                    {{ role.name }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right dark:bg-gray-800 dark:text-white dark:border-gray-700">
                  <router-link
                    v-if="
                      auth.hasRole('admin') ||
                      (auth.hasRole('editor') && user.roles)
                    "
                    :to="`/users/${user.id}/edit`"
                    class="bg-yellow-400 hover:bg-yellow-500 text-white px-3 py-1 rounded text-xs font-semibold"
                    >Modifica</router-link
                  >
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right dark:bg-gray-800 dark:text-white dark:border-gray-700">
                  <!-- <router-link v-if="auth.hasRole('admin')"  :to="`/users/${user.id}/edit`" class="bg-red-400 hover:bg-yellow-500 text-white px-3 py-1 rounded text-xs font-semibold">Elimina</router-link> -->
                  <button
                    v-if="auth.hasRole('admin')"
                    @click="deleteUser(user.id)"
                    class="bg-red-600 hover:bg-red-700 text-white px-3 py-1 rounded text-xs font-semibold"
                  >
                    Elimina
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Pagination -->
        <div class="flex items-center justify-between mt-4">
          <div class="flex items-center">
            <button
              class="px-3 py-1 border rounded mr-2"
              :disabled="currentPage === 1"
              @click="changePage(currentPage - 1)"
              :class="{ 'opacity-50 cursor-not-allowed': currentPage === 1 }"
            >
              Precedente
            </button>
            <span class="mx-2">
              Pagina {{ currentPage }} di
              {{ Math.ceil(totalItems / itemsPerPage) }}
            </span>
            <button
              class="px-3 py-1 border rounded ml-2"
              :disabled="currentPage >= Math.ceil(totalItems / itemsPerPage)"
              @click="changePage(currentPage + 1)"
              :class="{
                'opacity-50 cursor-not-allowed':
                  currentPage >= Math.ceil(totalItems / itemsPerPage),
              }"
            >
              Successiva
            </button>
          </div>
          <div>Totale: {{ totalItems }} utenti</div>
        </div>
      </div>
    </div>
  </div>
</template>
