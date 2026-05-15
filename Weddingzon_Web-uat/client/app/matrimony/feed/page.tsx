'use client';

import React from 'react';
import { useAuth } from '@/app/context/AuthContext';
import BlurredMatrimonyFeed from '@/components/BlurredMatrimonyFeed';
import { MatrimonyFeed } from '@/components/MatrimonyFeed';

export default function MatrimonyFeedPage() {
    const { user, loading } = useAuth();
    // We are NOT using router.push here because we want to SHOW content based on auth state, 
    // not strictly redirect (user explicitly asked for a blurred feed if not logged in).

    if (loading) {
        return (
            <div className="h-screen w-full flex items-center justify-center bg-white">
                <div className="w-8 h-8 border-4 border-rose-500 border-t-transparent rounded-full animate-spin"></div>
            </div>
        );
    }

    // Design Requirement: "In / matrimony when i click... and I am not logged in It must take me to a blurred feed section"
    if (!user) {
        return <BlurredMatrimonyFeed />;
    }

    return <MatrimonyFeed />;
}
