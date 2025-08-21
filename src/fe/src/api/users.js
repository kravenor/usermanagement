import axios from 'axios';

//const API_URL = "http://be.usermanagement.localhost/api"
const API_URL = import.meta.env.VITE_API_BASE_URL
export const getUsers = async (page = 1, limit = 10) => {
    try {
        const token = localStorage.getItem("token");
        const response = await axios.get(`${API_URL}/users`, {
            params: {
                page,
                limit
            },
            headers: {
                Authorization: `Bearer ${token}`,
            },
        });
        return response.data;
    } catch (error) {
        throw error;
    }
};


export const getAllUsers = async (page = 1, limit = 10) => {
    try {
        const token = localStorage.getItem("token");
        const response = await axios.get(`${API_URL}/users/all`, {
            headers: {
                Authorization: `Bearer ${token}`,
            },
        });
        return response.data;
    } catch (error) {
        throw error;
    }
};
