'use client';

import { useEffect, useState } from 'react';
import api from '../../services/api';
import { useRouter } from 'next/navigation';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Button } from '@/components/ui/button';
import { ArrowLeft, Clock, Eye, User, Sparkles } from 'lucide-react';
import { useSocket } from '../../context/SocketContext';

interface Viewer {
    _id: string;
    viewer: {
        _id: string;
        username: string;
        first_name: string;
        last_name: string;
        profilePhoto: string;
        role: string;
    };
    viewedAt: string;
    isRead: boolean;
}

export default function ViewersPage() {
    const router = useRouter();
    const [viewers, setViewers] = useState<Viewer[]>([]);
    const [loading, setLoading] = useState(true);

    const { socket } = useSocket();

    useEffect(() => {
        const fetchViewers = async () => {
            try {
                const res = await api.get('/users/viewers');
                if (res.data.success) {
                    setViewers(res.data.data);
                } else {
                    setViewers(res.data.data || res.data);
                }
            } catch (error) {
                console.error('Failed to fetch viewers', error);
            } finally {
                setLoading(false);
            }
        };
        fetchViewers();
    }, []);

    // Mark as read when viewers are loaded or page is visited
    useEffect(() => {
        if (!loading && viewers.some(v => !v.isRead)) {
            // Fire and forget
            api.post('/users/viewers/mark-read').catch(console.error);

            // Optimistically update local state after a short delay (so user sees "New" briefly)
            const timer = setTimeout(() => {
                setViewers(prev => prev.map(v => ({ ...v, isRead: true })));
            }, 2000); // Keep badge for 2 seconds
            return () => clearTimeout(timer);
        }
    }, [loading, viewers]);

    // Real-time update
    useEffect(() => {
        if (!socket) return;
        const handleNewView = (data: any) => {
            setViewers((prev) => {
                // Check if already in list to avoid duplicates (though backend limits 1/day)
                if (prev.some(v => v.viewer._id === data.viewer._id)) return prev;

                // Construct new viewer object matching interface
                const newView: Viewer = {
                    _id: Date.now().toString(), // Temp ID
                    viewer: data.viewer,
                    viewedAt: data.viewedAt || new Date().toISOString(),
                    isRead: false
                };
                return [newView, ...prev];
            });
        };

        socket.on('profile_view', handleNewView);
        return () => {
            socket.off('profile_view', handleNewView);
        };
    }, [socket]);

    const formatDate = (dateString: string) => {
        const date = new Date(dateString);
        const now = new Date();
        const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000);

        if (diffInSeconds < 60) return 'Just now';
        if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)}m ago`;
        if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)}h ago`;
        if (diffInSeconds < 604800) return `${Math.floor(diffInSeconds / 86400)}d ago`;

        return new Intl.DateTimeFormat('en-US', {
            month: 'short', day: 'numeric'
        }).format(date);
    };

    return (
        <div className="min-h-screen bg-[#FFF9FA] text-gray-900 font-inter pb-20">
            {/* Header */}
            <header className="fixed top-0 left-0 right-0 z-50 bg-white/80 backdrop-blur-md border-b border-gray-100 shadow-sm h-16 flex items-center px-4">
                <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => router.back()}
                    className="mr-3 rounded-full hover:bg-gray-100 text-gray-600"
                >
                    <ArrowLeft className="w-5 h-5" />
                </Button>
                <div>
                    <h1 className="text-xl font-black flex items-center gap-2 text-gray-900">
                        Profile <span className="text-[#EF2F55]">Viewers</span>
                        <span className="px-3 py-0.5 rounded-full bg-pink-100 text-[#EF2F55] text-xs font-bold">
                            {viewers.length}
                        </span>
                    </h1>
                </div>
            </header>

            {/* Spacer */}
            <div className="h-20" />

            {/* Content */}
            <div className="max-w-xl mx-auto p-4">

                {/* Promo Banner */}
                <div className="mb-8 bg-white border border-pink-50 rounded-[32px] p-8 text-center shadow-[0px_8px_30px_rgba(239,47,85,0.05)] relative overflow-hidden group">
                    <div className="absolute -top-12 -right-12 w-32 h-32 bg-pink-50 rounded-full blur-3xl opacity-50 group-hover:scale-150 transition-transform duration-700" />
                    <div className="relative z-10">
                        <div className="w-16 h-16 bg-pink-50 rounded-full flex items-center justify-center mx-auto mb-4">
                            <Eye className="w-8 h-8 text-[#EF2F55]" />
                        </div>
                        <h2 className="font-black text-2xl mb-2 text-gray-900 tracking-tight">Discover Who's Interested</h2>
                        <p className="text-gray-500 text-sm font-medium">See the profiles that recently visited you to find your next connection.</p>
                    </div>
                </div>

                {loading ? (
                    <div className="space-y-4">
                        {[1, 2, 3, 4].map((i) => (
                            <div key={i} className="h-24 rounded-[24px] bg-white border border-gray-50 animate-pulse shadow-sm" />
                        ))}
                    </div>
                ) : viewers.length === 0 ? (
                    <div className="flex flex-col items-center justify-center py-20 text-center">
                        <div className="w-24 h-24 bg-gray-50 rounded-full flex items-center justify-center mb-6">
                            <User className="w-10 h-10 text-gray-300" />
                        </div>
                        <h3 className="text-2xl font-black text-gray-900 mb-2 tracking-tight">No views yet</h3>
                        <p className="text-gray-500 max-w-xs mx-auto font-medium">
                            Keep your profile updated to attract more visitors and potential matches.
                        </p>
                        <Button
                            className="mt-8 bg-gray-900 text-white hover:bg-black rounded-full px-10 py-6 font-bold shadow-lg"
                            onClick={() => router.push('/feed')}
                        >
                            Back to Feed
                        </Button>
                    </div>
                ) : (
                    <div className="grid grid-cols-1 gap-4">
                        {viewers.filter(v => v.viewer).map((view) => (
                            <div
                                key={view._id}
                                onClick={() => router.push(`/${view.viewer.username}`)}
                                className="group flex items-center gap-5 p-5 bg-white rounded-[28px] border border-transparent shadow-[0px_4px_20px_rgba(0,0,0,0.02)] hover:shadow-[0px_8px_30px_rgba(239,47,85,0.08)] hover:border-pink-50 transition-all duration-300 cursor-pointer active:scale-[0.98]"
                            >
                                <div className="relative shrink-0">
                                    <div className="w-16 h-16 rounded-full border-2 border-pink-50 p-0.5 group-hover:border-[#EF2F55] transition-colors duration-300">
                                        <Avatar className="w-full h-full border-2 border-white shadow-sm ring-1 ring-gray-100">
                                            <AvatarImage src={view.viewer.profilePhoto} className="object-cover" />
                                            <AvatarFallback className="bg-pink-50 text-[#EF2F55] font-black">
                                                {view.viewer.first_name?.[0] || 'U'}
                                            </AvatarFallback>
                                        </Avatar>
                                    </div>
                                    <div className="absolute -bottom-1 -right-1 bg-white rounded-full p-1 shadow-sm">
                                        <div className="w-3 h-3 bg-green-500 rounded-full border border-white"></div>
                                    </div>
                                </div>

                                <div className="flex-1 min-w-0">
                                    <div className="flex justify-between items-start gap-2">
                                        <h3 className="font-black text-gray-900 truncate group-hover:text-[#EF2F55] transition-colors text-lg tracking-tight">
                                            {[view.viewer.first_name, view.viewer.last_name].filter(Boolean).join(' ') || "User"}
                                        </h3>
                                        {view.isRead === false && (
                                            <span className="text-[9px] uppercase font-black tracking-widest text-white bg-[#EF2F55] px-2.5 py-1 rounded-full shadow-md shadow-pink-100">
                                            New
                                            </span>
                                        )}
                                    </div>
                                    <p className="text-xs text-gray-400 mt-1 flex items-center gap-2 font-bold uppercase tracking-wider">
                                        <Clock className="w-3 h-3 text-gray-300" />
                                        Visited {formatDate(view.viewedAt)}
                                    </p>
                                </div>

                                <div className="shrink-0 w-10 h-10 rounded-full bg-gray-50 flex items-center justify-center group-hover:bg-pink-50 transition-colors">
                                    <Eye className="w-5 h-5 text-gray-300 group-hover:text-[#EF2F55]" />
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
}
