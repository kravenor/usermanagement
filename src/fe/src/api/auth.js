import axios from "axios"


// Usa la variabile d'ambiente VITE_API_BASE_URL definita in .env
const API_URL = import.meta.env.VITE_API_BASE_URL

export async function login(email, password) {
    console.log(import.meta.env);
    const response = await axios.post(`${API_URL}/auth/login`, {
        email,
        password,
    })
    return response.data
}

export async function getUserProfile(token) {
    const response = await axios.post(`${API_URL}/auth/me`, {
    }, {
        headers: {
            Authorization: `Bearer ${token}`,
        }
    })
    return response.data
}

export async function logout(token) {
    const response = await axios.post(
        `${API_URL}/auth/logout`,
        {},
        {
            headers: {
                Authorization: `Bearer ${token}`,
            },
        }
    )
    return response.data
}