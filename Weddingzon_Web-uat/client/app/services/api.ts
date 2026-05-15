import axios from 'axios';

const API_URL = process.env.NEXT_PUBLIC_API_URL || '/api';

if (typeof window !== 'undefined' && process.env.NODE_ENV !== 'production') {
    console.log('[API Debug] Base URL:', API_URL);
}

const api = axios.create({
    baseURL: API_URL, 
    withCredentials: true,
    headers: {
        'Content-Type': 'application/json',
    },
});

// Helper to get cookie
function getCookie(name: string) {
    if (typeof document === 'undefined') return null;
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) return parts.pop()?.split(';').shift();
    return null;
}

// Request Interceptor: Add CSRF Token
api.interceptors.request.use(
    (config) => {
        // CSRF Token (Cookie based)
        const csrfToken = getCookie('csrf_token');
        if (csrfToken) {
            config.headers['x-csrf-token'] = csrfToken;
        }

        // Bearer Token (LocalStorage based)
        // Many parts of the app use localStorage 'token'
        if (typeof window !== 'undefined') {
            const token = localStorage.getItem('token');
            if (token) {
                config.headers['Authorization'] = `Bearer ${token}`;
            }
        }

        return config;
    },
    (error) => Promise.reject(error)
);

// Queue to hold failed requests while token is refreshing
let isRefreshing = false;
let failedQueue: Array<{ resolve: (value?: unknown) => void; reject: (reason?: any) => void }> = [];

const processQueue = (error: any, token: string | null = null) => {
    failedQueue.forEach((prom) => {
        if (error) {
            prom.reject(error);
        } else {
            prom.resolve(token);
        }
    });

    failedQueue = [];
};

// Interceptor to handle token refresh automatically
api.interceptors.response.use(
    (response) => response,
    async (error) => {
        const originalRequest = error.config;

        const isAuthRequest = originalRequest.url?.includes('auth/login') ||
            originalRequest.url?.includes('auth/google') ||
            originalRequest.url?.includes('auth/verify-otp') ||
            originalRequest.url?.includes('auth/refresh') ||
            originalRequest.url?.includes('auth/me');

        if (error.response?.status === 401 && !originalRequest._retry && !isAuthRequest) {

            if (isRefreshing) {
                return new Promise(function (resolve, reject) {
                    failedQueue.push({ resolve, reject });
                })
                    .then(() => {
                        return api(originalRequest);
                    })
                    .catch((err) => {
                        return Promise.reject(err);
                    });
            }

            originalRequest._retry = true;
            isRefreshing = true;

            try {
                // Attempt to refresh token
                const res = await api.post('/auth/refresh');

                if (res.data.accessToken) {
                    localStorage.setItem('token', res.data.accessToken);
                }

                processQueue(null, 'refreshed');

                // Retry original request
                return api(originalRequest);

            } catch (err) {
                processQueue(err, null);

                // If refresh fails, redirect to login
                console.error('Session expired', err);

                // Don't redirect if we were just checking auth status
                if (originalRequest.url?.includes('/auth/me')) {
                    return Promise.reject(err);
                }

                if (typeof window !== 'undefined') {
                    const pathname = window.location.pathname;
                    const segments = pathname.split('/').filter(Boolean);
                    
                    // Reserved system/app segments
                    const reservedSegments = [
                        'admin', 'api', 'chats', 'connections', 'feed', 'franchise', 
                        'onboarding', 'phonebook', 'profile', 'requests', 
                        'settings', 'matrimony'
                    ];

                    const isPublicFixed = [
                        '/', '/login', '/signup', '/verify', '/about', '/contact', 
                        '/privacy', '/terms', '/franchise/login', '/franchise/entry', 
                        '/explore', '/vendor', '/coming-soon', '/blogs', '/services', '/feed', '/matrimony'
                    ].some(p => p === '/' ? pathname === '/' : pathname.startsWith(p));
                    const isPublicProfile = segments.length === 1 && !reservedSegments.includes(segments[0]);

                    if (!isPublicFixed && 
                        !isPublicProfile &&
                        !originalRequest.url?.includes('auth/me') &&
                        !originalRequest.url?.includes('auth/refresh')) {

                        localStorage.removeItem('token');
                        window.location.href = '/';
                    }
                }
                return Promise.reject(err);
            } finally {
                isRefreshing = false;
            }
        }
        return Promise.reject(error);
    }
);

export default api;
