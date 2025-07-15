import { ref, computed } from 'vue'
import { defineStore } from 'pinia'


export const auth = defineStore('auth',()=>{
    const backend_url = 'http://127.0.0.1:8000'
    const token = ref(localStorage.getItem('token'))
    const user_details = ref(localStorage.getItem('user_details'))
    const username = computed(()=>JSON.parse(user_details.value).username)
    const email = computed(()=> JSON.parse(user_details.value).email)
    const role = computed(()=>JSON.parse(user_details.value).role)

    const isAuthenticated = computed(()=>token.value !== null)

    function updateToken(){
        token.value = localStorage.getItem('token')
    }

    function updateUser(){
        user_details.value = localStorage.getItem('user_details')
    }

    function setToken(token){
        localStorage.setItem('token',token)
    }

    function removeToken(){
        localStorage.removeItem('token')
        token.value = null
    }

    function removeUserDetails(){
        localStorage.removeItem('user_details')
        user_details.value = null
    }

    function setUserDetails(user_dets){
        localStorage.setItem('user_details',user_dets)
    }
    
    async function logout(){
        try{
            const response = await fetch(`${backend_url}/api/v2/logout`,{
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                    'Authentication-Token': token.value
                }
            })
            if (!response.ok){
                const data = await response.json()
                const rsp = {
                    'status': false,
                    'message': data.message
                }
                return rsp
            }
            else{
                const data = await response.json()
                const rsp = {
                    'status': true,
                    'message': data.message
                }
                removeToken()
                removeUserDetails()
                updateToken()
                updateUser()
                return rsp
            }
        }
        catch(error){
            console.error(error)
            const rsp = {
                'status': false,
                'message': 'Oops! Something Went Wrong'
            }
            return rsp
        }
    }

    async function login(user_details){
        try{
            const response = await fetch(`${backend_url}/api/v2/login`,{
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify(user_details)
            })
            if (!response.ok){
                const data = await response.json()
                const rsp = {
                    'status': false,
                    'message': data.message
                }
                return rsp
            }
            else{
                const data = await response.json()
                if (data.user.auth_token){
                    setToken(data.user.auth_token)
                    const user_dets = {
                        'username':data.user.username,
                        'role':data.user.roles[0],
                        'email':data.user.email,
                    }
                    setUserDetails(JSON.stringify(user_dets))
                    const rsp = {
                        'status': true,
                        'message': data.message
                    }
                    updateToken()
                    updateUser()
                    return rsp
                }
            }
        }
        catch(error){
            console.error(error)
            const rsp = {
                'status': true,
                'message': 'Oops! Something Went Wrong'
            }
            return rsp
        }
    }

    async function register(user_details){
        try{
            const response = await fetch(`${backend_url}/api/v2/register`,{
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify(user_details)
            })
            if (!response.ok){
                const data = await response.json()
                const rsp = {
                    'status': false,
                    'message': data.message
                }
                return rsp
            }
            else{
                const data = await response.json()
                const rsp = {
                    'status': true,
                    'message': data.message
                }
                return rsp
            }
        }
        catch(error){
            console.error(error)
            const rsp = {
                'status': false,
                'message': 'Oops! Something Went Wrong'
            }
            return rsp
        }
    }


    return {login, logout, register ,token, username, isAuthenticated, backend_url, role,email}
});