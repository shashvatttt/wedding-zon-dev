'use client';

import React, { createContext, useContext, useEffect, useState } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import api from '../services/api';

interface User {
    _id: string;
    username: string;
    email: string;
    first_name: string;
    last_name: string;
    avatar?: string;
    profilePhoto?: string;
    is_profile_complete?: boolean;
    role?: string;
    created_for?: string;
    phone?: string;
    vendor_status?: string;
    vendor_details?: {
        business_name: string;
        business_glance?: string;
    };
    city?: string;
    franchise_status?: 'pending_payment' | 'pending_approval' | 'active' | 'rejected';
    franchise_details?: {
        business_name?: string;
    };
    photos?: any[];
    occupation?: string;
}

interface AuthContextType {
    user: User | null;
    loading: boolean;
    isAuthenticated: boolean;
    login: (token: string, refreshToken: string, user: User) => void;
    logout: () => void;
    deleteAccount: () => Promise<void>;
    checkAuth: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType>({
    user: null,
    loading: true,
    isAuthenticated: false,
    login: () => { },
    logout: () => { },
    deleteAccount: async () => { },
    checkAuth: async () => { },
});


export const useAuth = () => useContext(AuthContext);

// Shared logic for public routes
const isPublicRoute = (pathname: string) => {
    const publicPaths = [
        '/', '/login', '/signup', '/verify', '/about', '/contact', 
        '/privacy', '/terms', '/franchise/login', '/franchise/entry', 
        '/explore', '/vendor', '/coming-soon', '/blogs', '/services', '/feed', '/matrimony'
    ];
    
    // Reserved system/app segments
    const reservedSegments = [
        'admin', 'api', 'chats', 'connections', 'feed', 'franchise', 
        'onboarding', 'phonebook', 'profile', 'requests', 
        'settings', 'matrimony', 'contact', 'terms'
    ];

    // Check fixed paths
    if (publicPaths.some(p => p === '/' ? pathname === '/' : pathname.startsWith(p))) {
        return true;
    }

    // Check root-level dynamic routes (usernames)
    // PROFILES ARE NOW PUBLIC BY DEFAULT TO ALLOW GUEST VIEWING
    const segments = pathname.split('/').filter(Boolean);
    if (segments.length === 1 && !reservedSegments.includes(segments[0])) {
        return true;
    }

    return false;
}

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
    const [user, setUser] = useState<User | null>(null);
    const [loading, setLoading] = useState(true);
    const router = useRouter();
    const pathname = usePathname();

    const checkAuth = async () => {
        try {
            // Add timestamp to prevent caching of user role
            const res = await api.get(`/auth/me?t=${Date.now()}`);
            setUser(res.data);

            // Sync token to localStorage if returned (e.g. after refresh/recovery from cookie)
            if (res.data.accessToken) {
                localStorage.setItem('token', res.data.accessToken);
            }
        } catch (error) {
            setUser(null);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        checkAuth();

        const handleAuthChange = () => {
            checkAuth();
        };

        window.addEventListener('auth-change', handleAuthChange);
        return () => window.removeEventListener('auth-change', handleAuthChange);
    }, []);

    // Enforce Profile Completion & Security Redirection
    useEffect(() => {
        if (loading) return;

        const isPublic = isPublicRoute(pathname);

        // 1. Security Check: Unauthenticated users trying to access private routes
        if (!user) {
            if (!isPublic) {
                console.log(`[AuthCheck] Unauthenticated access to private route: ${pathname}. Redirecting to Login.`);
                window.location.href = '/login';
            }
            return;
        }

        // Allow access to public pages if authenticated
        if (isPublic) return;

        // 2. Prerequisite Check: valid email and phone
        if (!user.email || !user.phone) {
            if (pathname !== '/onboarding') {
                console.log('[AuthCheck] Missing Prerequisites. Redirecting to Home. Path:', pathname);
                window.location.href = '/';
            }
            return;
        }

        // 3. Strict Role-Based Path Protection
        const role = user.role;

        // A. Vendor Access Control
        if (role === 'vendor') {
            const isVendorPath = pathname.startsWith('/vendor');
            const isFeedViewAs = pathname === '/feed' && typeof window !== 'undefined' && window.location.search.includes('viewAs=');

            // Enforce Workflow Steps
            const status = user.vendor_status;
            const hasDetails = user.vendor_details?.business_name;

            if (!hasDetails) {
                if (pathname !== '/vendor/onboarding') {
                    router.push('/vendor/onboarding');
                }
                return;
            }

            if (!status || status === 'pending_payment') {
                if (pathname !== '/vendor/payment') {
                    router.push('/vendor/payment');
                }
                return;
            }

            if (status === 'pending' || status === 'pending_approval' || status === 'rejected') {
                if (pathname !== '/vendor/waiting') {
                    router.push('/vendor/waiting');
                }
                return;
            }

            if (status === 'active') {
                if (!isVendorPath && !isFeedViewAs) {
                    router.push('/vendor/dashboard');
                    return;
                }
            }
        }

        // B. Franchise Access Control
        if (role === 'franchise') {
            const isFranchisePath = pathname.startsWith('/franchise');
            const isFeedViewAs = pathname === '/feed' && window.location.search.includes('viewAs=');

            const status = user.franchise_status;
            const hasDetails = user.franchise_details?.business_name;

            if (!hasDetails) {
                if (pathname !== '/franchise/onboarding') {
                    router.push('/franchise/onboarding');
                }
                return;
            }

            if (!status || status === 'pending_payment') {
                if (pathname !== '/franchise/payment') {
                    router.push('/franchise/payment');
                }
                return;
            }

            if (status === 'pending_approval' || status === 'rejected') {
                if (pathname !== '/franchise/waiting') {
                    router.push('/franchise/waiting');
                }
                return;
            }

            if (status === 'active') {
                if (!isFranchisePath && !isFeedViewAs) {
                    router.push('/franchise');
                    return;
                }
            }
        }

        // C. Member Access Control (Member, Bride, Groom)
        const isMember = ['member', 'bride', 'groom'].includes(role || '');
        if (isMember) {
            if (pathname.startsWith('/vendor') || pathname.startsWith('/franchise') || pathname.startsWith('/admin')) {
                router.push('/feed');
                return;
            }
        }

        // 4. Check Profile Completion (Member/Bride/Groom)
        if (isMember && !user.is_profile_complete) {
            if (pathname !== '/onboarding') {
                router.push('/onboarding');
            }
        }
    }, [user, loading, pathname, router]);

    const login = (token: string, refreshToken: string, userData: User) => {
        localStorage.setItem('token', token);
        setUser(userData);
        router.push('/feed');
    };

    const logout = async () => {
        try {
            await api.post('/auth/logout');
            localStorage.removeItem('token');
            setUser(null);
            window.location.href = '/';
        } catch (error) {
            localStorage.removeItem('token');
            setUser(null);
            window.location.href = '/';
        }
    };

    // Calculate if we should block rendering
    const isOnboardingPage = pathname === '/onboarding';
    const isPublic = isPublicRoute(pathname);

    const isUnauthenticatedPrivate = !loading && !user && !isPublic;
    const isMissingPrereqs = !loading && user && (!user.email || !user.phone) && !isPublic && !isOnboardingPage;

    const shouldBlockRender = isUnauthenticatedPrivate || isMissingPrereqs || (user && !loading && !isPublic && !isOnboardingPage && (
        !user.role ||
        ((user.role === 'member' || user.role === 'bride' || user.role === 'groom') && !user.is_profile_complete)
    ));

    let loadingMessage = "Checking Profile Status...";
    if (isUnauthenticatedPrivate) loadingMessage = "Redirecting to Login...";
    else if (isMissingPrereqs) loadingMessage = "Redirecting to Home...";
    else if (shouldBlockRender) loadingMessage = "Redirecting to Setup...";

    const deleteAccount = async () => {
        try {
            await api.delete('/users/profile');
            localStorage.removeItem('token');
            setUser(null);
            window.location.href = '/';
        } catch (error) {
            console.error('Delete account failed', error);
            // Even if it fails, maybe clear local state? 
            // Usually we should only clear if it's 404 or 401.
            throw error;
        }
    };

    return (
        <AuthContext.Provider value={{
            user,
            loading,
            isAuthenticated: !!user,
            login,
            logout,
            deleteAccount,
            checkAuth
        }}>

            {shouldBlockRender ? (
                <div className="h-screen w-full flex flex-col items-center justify-center bg-gray-50 space-y-4">
                    <div className="text-xl font-semibold text-gray-700">{loadingMessage}</div>
                    <div className="w-8 h-8 border-4 border-rose-500 border-t-transparent rounded-full animate-spin"></div>
                </div>
            ) : (
                children
            )}
        </AuthContext.Provider>
    );
};
