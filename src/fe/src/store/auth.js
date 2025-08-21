import { defineStore } from "pinia"
import axios from "axios"
import { login as apiLogin, getUserProfile } from "../api/auth"

export const useAuthStore = defineStore("auth", {
    state: () => ({
        user: null,
        token: localStorage.getItem("token") || null,
        roles: [],
    }),
    getters: {
        isAuthenticated: (state) => !!state.token,
        hasRole: (state) => (role) => {
            return state.roles && state.roles.includes(role)
        },
    },
    actions: {
        async login(email, password) {
            const data = await apiLogin(email, password)
            console.log("Login response:", data)
            this.token = data.token
            this.user = data.user
            this.roles = data.roles || []

            localStorage.setItem("token", this.token)
            axios.defaults.headers.common["Authorization"] = `Bearer ${this.token}`
        },
        async fetchUser() {
            if (this.token) {
                const data = await getUserProfile(this.token)
                this.user = data.user
                this.roles = data.roles || []
            }
        },
        logout() {
            this.user = null
            this.token = null
            localStorage.removeItem("token")
            delete axios.defaults.headers.common["Authorization"]
        },
    },
})