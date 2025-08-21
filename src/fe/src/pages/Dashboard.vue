<template>
  <div class="p-6">
    <h1 class="text-2xl font-bold">Benvenuto nella Dashboard</h1>

    <div class="flex flex-row">
        <!-- Pie Chart Ruoli -->
      <div class="mt-6 w-full max-w-xl">
        <h2 class="text-xl font-semibold mb-4">Distribuzione Ruoli Utenti</h2>
        <div class="bg-white p-4 rounded-lg shadow">
          <Pie v-if="chartData" :data="chartData" :options="chartOptions" />
        </div>
      </div>

      <!-- Bar Chart Registrazioni -->
      <div class="ml-12 mt-10 w-full max-w-xl">
        <h2 class="text-xl font-semibold mb-4">Trend Registrazioni Utenti</h2>
        <div class="bg-white p-4 rounded-lg shadow">
          <Bar
            v-if="registrationChartData"
            :data="registrationChartData"
            :options="barOptions"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useAuthStore } from "../store/auth";
import { useRouter } from "vue-router";
import { Pie, Bar } from "vue-chartjs";
import {
  Chart as ChartJS,
  ArcElement,
  Tooltip,
  Legend,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
} from "chart.js";
import { getUsers } from "../api/users";

ChartJS.register(
  ArcElement,
  Tooltip,
  Legend,
  CategoryScale,
  LinearScale,
  BarElement,
  Title
);

const auth = useAuthStore();
const router = useRouter();
const chartData = ref(null);
const registrationChartData = ref(null);

const chartOptions = {
  responsive: true,
  maintainAspectRatio: true,
};

const barOptions = {
  responsive: true,
  maintainAspectRatio: true,
  plugins: {
    legend: { display: false },
    title: { display: true, text: "Registrazioni mensili" },
  },
  scales: {
    y: { beginAtZero: true, ticks: { stepSize: 1 } },
  },
};

const logout = () => {
  auth.logout();
  router.push({ name: "login" });
};

onMounted(async () => {
  try {
    const response = await getUsers(1, 1000);
    const users = response.data || [];
    // Pie chart: conta utenti per ruolo principale
    const roleCount = users.reduce((acc, user) => {
      const role =
        user.roles && user.roles.length > 0 ? user.roles[0].name : "N/A";
      acc[role] = (acc[role] || 0) + 1;
      return acc;
    }, {});
    chartData.value = {
      labels: Object.keys(roleCount),
      datasets: [
        {
          data: Object.values(roleCount),
          backgroundColor: [
            "#FF6384",
            "#36A2EB",
            "#FFCE56",
            "#4BC0C0",
            "#9966FF",
          ],
        },
      ],
    };
   
    // Bar chart: trend registrazioni per mese
    const monthly = {};
    users.forEach((user) => {
      if (user.created_at) {
        const d = new Date(user.created_at);
        const key =
          d.getFullYear() + "-" + String(d.getMonth() + 1).padStart(2, "0");
        monthly[key] = (monthly[key] || 0) + 1;
      }
    });
    // Prendi solo gli ultimi 6 mesi
    const sortedKeys = Object.keys(monthly).sort();
    const lastMonths = sortedKeys.slice(-6);
    registrationChartData.value = {
      labels: lastMonths.map((k) => {
        const [y, m] = k.split("-");
        return `${m}/${y.slice(-2)}`;
      }),
      datasets: [
        {
          label: "Registrazioni",
          data: lastMonths.map((k) => monthly[k]),
          backgroundColor: "#36A2EB",
          borderColor: "#2693e6",
          borderWidth: 1,
        },
      ],
    };
  } catch (error) {
    console.error("Errore nel caricamento dei dati:", error);
  }
});
</script>
