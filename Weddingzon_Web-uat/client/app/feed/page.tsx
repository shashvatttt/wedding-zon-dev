'use client';

import Feed from '../components/Feed';
import { Suspense, useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Eye } from 'lucide-react';
import api from '../services/api';
import { useAuth } from '../context/AuthContext';
import { useSocket } from '../context/SocketContext';

// New Components
import FeedHeader from './components/FeedHeader';
import FeedSidebar from './components/FeedSidebar';
import FeedRightSidebar from './components/FeedRightSidebar';
import FeedFilters from './components/FeedFilters';
import FloatingChatInterface from '../components/chat/FloatingChatInterface';
import SettingsSidebar from '../chats/components/SettingsSidebar'; // Reuse from chats
import { FadeIn } from '@/components/animations/FadeIn';
import { SlideIn } from '@/components/animations/SlideIn';
import { motion, AnimatePresence } from 'framer-motion';
import { StaggerContainer, StaggerItem } from '@/components/animations/StaggerContainer';

function FeedContent() {
    const { user, loading, logout } = useAuth();
    const { socket } = useSocket();
    const [me, setMe] = useState<any>(null);
    const router = useRouter();
    const searchParams = useSearchParams();
    const viewAs = searchParams.get('viewAs');
    const [viewAsName, setViewAsName] = useState<string | null>(null);
    const [isSettingsOpen, setIsSettingsOpen] = useState(false);
    const [onlineCount, setOnlineCount] = useState<number>(0);

    useEffect(() => {
        // Wait for auth to load
        if (loading) return;

        if (user) {
            setMe(user);

            // Access Control Logic

            // 1. Franchise Logic
            if (user.role === 'franchise') {
                // If viewAs is present, ALLOW access.
                if (viewAs) {
                    return;
                }

                // Otherwise redirect to dashboard
                router.push('/franchise');
                return;
            }

            // If role is missing, we allow them to stay on feed (which is public)
            // but we don't return early so they can still be caught by onboarding checks if needed
            // However, for feed, we'll allow it.

            if (user.role && ['user', 'member', 'bride', 'groom'].includes(user.role) && !user.is_profile_complete) {
                router.push('/onboarding');
                return;
            }
        }
    }, [user, loading, router, viewAs]);

    useEffect(() => {
        // Fetch View As User Details
        if (viewAs) {
            const fetchViewAsUser = async () => {
                try {
                    const res = await api.get(`/franchise/profiles/${viewAs}`);
                    if (res.data) {
                        setViewAsName(res.data.first_name || res.data.username);
                    }
                } catch (error) {
                    console.error('Failed to fetch viewAs user', error);
                }
            };
            fetchViewAsUser();
        }
    }, [viewAs]);

    return (
        <div className="min-h-screen font-sans bg-[#FFF9FA] pb-20">
            {/* View As Banner */}
            {viewAs && (
                <div className="fixed top-[72px] left-0 right-0 z-40 bg-indigo-600 text-white px-4 py-2 text-center shadow-md flex items-center justify-center gap-2 animate-in slide-in-from-top-2">
                    <Eye className="w-4 h-4" />
                    <span className="text-sm font-medium">
                        Viewing as <strong>{viewAsName || "Member"}</strong>.
                        Filtered by
                    </span>
                    <button
                        onClick={() => router.push('/franchise')}
                        className="ml-4 text-xs bg-white/20 hover:bg-white/30 px-2 py-1 rounded transition-colors"
                    >
                        Exit
                    </button>
                </div>
            )}

            <FadeIn duration={0.3}>
                <FeedHeader onSettingsClick={() => setIsSettingsOpen(true)} />
            </FadeIn>

            <StaggerContainer
                staggerDelay={0.1}
                className={`pt-[100px] pb-10 px-4 max-w-[1440px] mx-auto grid grid-cols-1 lg:grid-cols-[250px_1fr_222px] gap-8 justify-center`}
            >
                {/* Left Sidebar */}
                <StaggerItem className="hidden lg:block relative">
                    <div className="sticky top-[100px]">
                        <FeedSidebar user={me} onlineCount={onlineCount} />
                    </div>
                </StaggerItem>

                {/* Main Content */}
                <StaggerItem className="flex flex-col">
                    <FeedFilters user={me} onSettingsClick={() => setIsSettingsOpen(true)} />
                    <Feed viewAs={viewAs} readOnly={!!viewAs} onOnlineCountUpdate={setOnlineCount} />
                </StaggerItem>

                {/* Right Sidebar */}
                <StaggerItem className="hidden lg:block relative">
                    <div className="sticky top-[100px]">
                        <FeedRightSidebar />
                    </div>
                </StaggerItem>
            </StaggerContainer>

            {/* Add Floating Chat - Hide if viewing as another user (Franchise Mode) */}
            {!viewAs && (
                <Suspense fallback={null}>
                    <FloatingChatInterface />
                </Suspense>
            )}
            {/* Settings Sidebar */}
            <SettingsSidebar
                isOpen={isSettingsOpen}
                onClose={() => setIsSettingsOpen(false)}
                user={me}
            />
            {/* Full-screen click-to-login overlay for unauthenticated users */}
            {!loading && !user && (
                <div 
                    className="fixed inset-0 z-[9999] cursor-pointer bg-transparent" 
                    onClick={() => router.push('/login?redirect=/feed')}
                />
            )}
        </div>
    );
}

export default function FeedPage() {
    return (
        <Suspense fallback={
            <div className="h-screen flex items-center justify-center bg-[#FFF9FA]">
                <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-rose-600"></div>
            </div>
        }>
            <FeedContent />
        </Suspense>
    );
}
