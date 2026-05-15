'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../context/AuthContext';
import api from '../services/api';

export default function ProfileRedirect() {
    const router = useRouter();
    const { user, loading } = useAuth(); // Assuming AuthContext provides user

    useEffect(() => {
        if (!loading) {
            if (user && user.username) {
                router.replace(`/${user.username}`);
            } else {
                // If checking auth or not logged in, try fetching me or go to login
                api.get('/auth/me')
                    .then(res => {
                        if (res.data && res.data.username) {
                            router.replace(`/${res.data.username}`);
                        } else {
                            router.replace('/login');
                        }
                    })
                    .catch(() => router.replace('/login'));
            }
        }
    }, [user, loading, router]);

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-pink-500"></div>
        </div>
    );
}
