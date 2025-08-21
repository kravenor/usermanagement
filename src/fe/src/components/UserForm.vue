<template>
  <transition name="fade-modal">
    <form @submit.prevent="onSubmit">
        <div class="mb-4">
          <label class="block mb-1 font-semibold">Nome</label>
          <input
            v-model="localUser.name"
            class="w-full border rounded px-3 py-2 bg-white dark:bg-gray-900 dark:text-white dark:border-gray-700"
            required
          />
        </div>
        <div class="mb-4">
          <label class="block mb-1 font-semibold">Email</label>
          <input
            v-model="localUser.email"
            class="w-full border rounded px-3 py-2 bg-white dark:bg-gray-900 dark:text-white dark:border-gray-700"
            type="email"
            required
          />
        </div>
         <div class="mb-4">
          <label class="block mb-1 font-semibold">Password</label>
          <input
            v-model="localUser.password"
            class="w-full border rounded px-3 py-2 bg-white dark:bg-gray-900 dark:text-white dark:border-gray-700"
            type="password"
          />
        </div>
        <div class="mb-4">
          <label class="block mb-1 font-semibold">Ruoli</label>
          <input
            v-model="rolesInput"
            class="w-full border rounded px-3 py-2 bg-white dark:bg-gray-900 dark:text-white dark:border-gray-700"
            placeholder="Ruoli separati da virgola"
            :disabled="personalProfile"
          />
        </div>
        <div v-if="error" class="text-red-500 mb-2">{{ error }}</div>
        <div class="flex gap-2">
          <button
            type="submit"
            class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 dark:bg-blue-800 dark:hover:bg-blue-900"
          >
           
        {{ submitLabel }}
      </button>
      <router-link
        :to="cancelUrl"
        class="bg-gray-300 px-4 py-2 rounded hover:bg-gray-400"
        >Annulla</router-link
      >
    </div>
    </form>
  </transition>

</template>

<script setup>
import { ref, watch, toRefs } from 'vue';

const props = defineProps({
  user: {
    type: Object,
    required: true
  },
  roles: {
    type: String,
    default: ''
  },
  error: {
    type: String,
    default: ''
  },
  submitLabel: {
    type: String,
    default: 'Salva'
  },
  cancelUrl: {
    type: String,
    default: '/users'
  },
  personalProfile: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['submit']);

const localUser = ref({ ...props.user });
const rolesInput = ref(props.roles);

watch(() => props.user, (val) => {
  localUser.value = { ...val };
});
watch(() => props.roles, (val) => {
  rolesInput.value = val;
});

const onSubmit = () => {
  emit('submit', {
    user: localUser.value,
    roles: rolesInput.value
  });
};
</script>
