'use client';

import { Suspense, useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import FeedHeader from '../feed/components/FeedHeader';
import FeedSidebar from '../feed/components/FeedSidebar';
import FeedFilters from '../feed/components/FeedFilters';
import Link from 'next/link';
import ThreadList from './components/ThreadList';
import SettingsSidebar from './components/SettingsSidebar';
import ChatRoom from './components/ChatRoom'; // Added missing import
import { Button } from '@/components/ui/button';
import { Search, SlidersHorizontal, Settings, Bell, User as UserIcon } from 'lucide-react';
import api from '../services/api';
import Image from 'next/image';
import { useSocket } from '../context/SocketContext';

// Placeholder for online users
const OnlineUsers = () => {
    const [onlineUsers, setOnlineUsers] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const { socket } = useSocket();

    useEffect(() => {
        const fetchOnlineUsers = async () => {
            try {
                // Fetch connections
                const res = await api.get('/connections/my-connections');
                if (res.data.success) {
                    const allConnections = res.data.data;
                    // Filter for online OR active in last 24h
                    const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
                    const active = allConnections.filter((u: any) =>
                        u.isOnline || (u.lastSeen && new Date(u.lastSeen) > oneDayAgo)
                    );
                    setOnlineUsers(active);
                }
            } catch (error) {
                console.error('Failed to fetch online users', error);
            } finally {
                setLoading(false);
            }
        };

        fetchOnlineUsers();
    }, []);

    // Socket Listeners for Real-time Status
    useEffect(() => {
        if (!socket) return;

        const handleStatus = ({ userId, status }: { userId: string, status: string }) => {
            if (status === 'online') {
                // Re-fetch to get details
                fetchConnectionsAndFilter();
            } else {
                setOnlineUsers(prev => prev.filter(u => u._id !== userId));
            }
        };

        const fetchConnectionsAndFilter = async () => {
            try {
                const res = await api.get('/connections/my-connections');
                if (res.data.success) {
                    setOnlineUsers(res.data.data.filter((u: any) => {
                        const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
                        return u.isOnline || (u.lastSeen && new Date(u.lastSeen) > oneDayAgo);
                    }));
                }
            } catch (e) { console.error(e); }
        };

        socket.on('user_status', handleStatus);
        return () => {
            socket.off('user_status', handleStatus);
        };
    }, [socket]);

    if (loading) return null;
    if (onlineUsers.length === 0) return null;

    return (
        <div className="mb-8">
            <h3 className="text-2xl font-bold mb-1 pt-6 text-[var(--foreground)]">Active <span className="text-[#EF2F55]">People</span></h3>
            <p className="text-gray-500 mb-4 text-sm">Chat with active users to get faster replies</p>
            <div className="flex gap-4 overflow-x-auto pb-2 scrollbar-hide">
                {onlineUsers.map((u) => (
                    <div key={u._id} className="flex flex-col items-center gap-1 cursor-pointer min-w-[60px]" onClick={() => window.location.href = `/chats?start_chat=${u._id}`}>
                        <div className="relative w-14 h-14 rounded-full border-2 border-[#EF2F55] p-0.5">
                            <div className="w-full h-full rounded-full overflow-hidden relative">
                                <Image src={u.profilePhoto || '/placeholder-user.jpg'} alt={u.username} fill className="object-cover" />
                            </div>
                            <span className={`absolute bottom-0 right-0 w-3 h-3 border-2 border-white rounded-full ${u.isOnline ? 'bg-green-500' : 'bg-gray-300'}`}></span>
                        </div>
                        <span className="text-xs font-medium truncate w-16 text-center">{u.first_name}</span>
                    </div>
                ))}
            </div>
        </div>
    );
};


function ChatsContent() {
    const router = useRouter();
    const searchParams = useSearchParams();
    const [me, setMe] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const [isSettingsOpen, setIsSettingsOpen] = useState(false);

    // Active chat state
    const [activeChat, setActiveChat] = useState<any>(null);

    useEffect(() => {
        const checkAuth = async () => {
            try {
                const res = await api.get('/auth/me');
                if (res.data) {
                    const user = res.data;
                    // If role is missing, we allow them to stay on the page (though AuthContext might catch them)
                    /* 
                    if (!user.role || user.role === 'user') {
                        router.push('/');
                        return;
                    }
                    */

                    if ((user.role === 'member' || user.role === 'bride' || user.role === 'groom') && !user.is_profile_complete) {
                        router.push('/onboarding');
                        return;
                    }
                    setMe(user);
                }
            } catch (e: any) {
                if (e.response && e.response.status === 401) {
                    router.push('/login');
                }
            } finally {
                setLoading(false);
            }
        };
        checkAuth();
    }, [router]);

    // Handle start_chat query
    useEffect(() => {
        const startChatId = searchParams.get('start_chat');
        if (startChatId && me) {
            // Fetch user details to set active chat
            api.get('/chat/conversations')
                .then(res => {
                    const conv = res.data.data.find((c: any) => c._id === startChatId);
                    if (conv) {
                        setActiveChat(conv);
                    } else {
                        // Fetch specific user if not in list yet
                        api.get(`/users/${startChatId}`)
                            .then(uRes => {
                                // Extract from .data.data due to standardized wrapper
                                const user = uRes.data.data;
                                if (user) {
                                    setActiveChat({
                                        _id: user._id,
                                        username: user.username,
                                        first_name: user.first_name,
                                        last_name: user.last_name,
                                        profilePhoto: user.profilePhoto
                                    });
                                }
                            })
                            .catch(uErr => console.error('Failed to fetch specific user for chat', uErr));
                    }
                })
                .catch(err => console.error('Failed to fetch conversations for start_chat', err));
        }
    }, [searchParams, me]);

    if (loading) {
        return (
            <div className="h-screen flex items-center justify-center bg-[#FFF9FA]">
                <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-rose-600"></div>
            </div>
        );
    }

    if (!me) return null;

    return (
        <div className="min-h-screen bg-[#FFF9FA] font-sans">
            <FeedHeader />

            <div className={`pt-[100px] pb-10 px-4 max-w-[1440px] mx-auto grid grid-cols-1 lg:grid-cols-[250px_1fr] gap-8 justify-center`}>

                {/* Left Sidebar */}
                <div className="hidden lg:block relative">
                    <div className="sticky top-[100px]">
                        <FeedSidebar user={me} activePage="chats" />
                    </div>
                </div>

                {/* Main Content */}
                <div className="flex flex-col w-full max-w-[1000px]">
                    {/* Top Filters Toolbar - Replaced with Shared FeedFilters */}
                    <FeedFilters
                        user={me}
                        onSettingsClick={() => setIsSettingsOpen(true)}
                    />

                    <OnlineUsers />

                    {/* Chat Interface Container - 2 Columns */}
                    <div className="bg-white rounded-3xl shadow-sm min-h-[600px] flex overflow-hidden border border-gray-100">
                        {/* Left: Thread List - 35% on desktop, full width on mobile if no chat active */}
                        <div className={`${activeChat ? 'hidden lg:block' : 'w-full'} lg:w-[35%] lg:min-w-[300px] border-r border-gray-100`}>
                            <ThreadList
                                onSelectUser={(user) => setActiveChat(user)}
                                activeUserId={activeChat?._id || null}
                            />
                        </div>

                        {/* Right: Chat Room - 65% on desktop, full width on mobile if chat active */}
                        <div className={`${!activeChat ? 'hidden lg:block' : 'w-full'} flex-1 bg-white`}>
                            {activeChat ? (
                                <ChatRoom
                                    recipientId={activeChat._id}
                                    recipientUsername={activeChat.username}
                                    recipientName={[activeChat.first_name, activeChat.last_name].filter(Boolean).join(' ') || activeChat.username}
                                    recipientPhoto={activeChat.profilePhoto}
                                    isOnline={activeChat.isOnline}
                                    lastSeen={activeChat.lastSeen}
                                    onBack={() => setActiveChat(null)}
                                />
                            ) : (
                                <div className="flex flex-col items-center justify-center h-full text-gray-400">
                                    <div className="w-24 h-24 bg-pink-50 rounded-full flex items-center justify-center mb-4">
                                        <Bell className="w-10 h-10 text-pink-300" />
                                    </div>
                                    <h3 className="text-xl font-semibold text-gray-700">Select a conversation</h3>
                                    <p className="text-sm">Choose a chat from the left to start messaging</p>
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            </div>

            {/* Settings Sidebar Overlay */}
            <SettingsSidebar
                isOpen={isSettingsOpen}
                onClose={() => setIsSettingsOpen(false)}
                user={me}
            />
        </div>
    );
}

export default function ChatsPage() {
    return (
        <Suspense fallback={
            <div className="h-screen flex items-center justify-center bg-[#FFF9FA]">
                <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-rose-600"></div>
            </div>
        }>
            <ChatsContent />
        </Suspense>
    );
}
