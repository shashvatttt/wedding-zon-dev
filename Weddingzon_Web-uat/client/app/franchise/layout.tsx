'use client';

import { useEffect } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import { useAuth } from '../context/AuthContext';

export default function FranchiseLayout({ children }: { children: React.ReactNode }) {
    const { user, isAuthenticated, loading } = useAuth();
    const router = useRouter();
    const pathname = usePathname();

    const isPublicPage = pathname?.includes('/login') || pathname?.includes('/entry');
    // Also likely onboarding if we want. But entry is key.

    useEffect(() => {
        if (!loading && !isPublicPage) {
            if (!isAuthenticated) {
                router.push('/franchise/login');
            } else if (user?.role !== 'franchise') {
                // If logged in but not franchise (e.g. member), kick them out
                router.push('/feed');
            }
        }
    }, [user, isAuthenticated, loading, router, isPublicPage]);

    if (loading) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-rose-600"></div>
            </div>
        );
    }

    if (!isPublicPage && (!isAuthenticated || user?.role !== 'franchise')) {
        return null; // Don't render content while redirecting
    }

    return <>{children}</>;
}
