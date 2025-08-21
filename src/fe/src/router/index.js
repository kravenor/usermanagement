import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../store/auth'

import Login from '../pages/Login.vue'
import Dashboard from '../pages/Dashboard.vue'
import Profile from '../pages/Profile.vue'

const routes = [
    { path: '/login', name: 'login', component: Login },
    { path: '/dashboard', name: 'dashboard', component: Dashboard, meta: { requiresAuth: true } },
    { path: '/profile', name: 'profile', component: Profile, meta: { requiresAuth: true } },
    { path: '/users', name: 'users', component: () => import('../pages/Users.vue'), meta: { requiresAuth: true } },
    { path: '/users/add', name: 'user-add', component: () => import('../pages/UserAdd.vue'), meta: { requiresAuth: true } },
    { path: '/users/:id/edit', name: 'user-edit', component: () => import('../pages/UserEdit.vue'), meta: { requiresAuth: true } },
    { path: '/', redirect: '/dashboard' },
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

router.beforeEach((to, from, next) => {
    const auth = useAuthStore()

    // Blocca pagine protette se non loggato
    if (to.meta.requiresAuth && !auth.isAuthenticated) {
        next({ name: 'login' })
        return
    }

    // Se è loggato e va su /login → redirect a dashboard
    if (to.name === 'login' && auth.isAuthenticated) {
        next({ name: 'dashboard' })
        return
    }

    next()
})

export default router
