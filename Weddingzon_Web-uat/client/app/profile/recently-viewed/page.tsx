'use client';

import { useEffect, useState } from 'react';
import api from '../../services/api';
import { useRouter } from 'next/navigation';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Button } from '@/components/ui/button';
import { ArrowLeft, Clock, Eye, User } from 'lucide-react';

interface Recents {
    _id: string;
    user: {
        _id: string;
        username: string;
        displayName: string;
        profilePhoto: string;
        bio?: string;
        occupation?: string;
        location?: string;
    };
    viewedAt: string;
}

export default function RecentlyViewedPage() {
    const router = useRouter();
    const [recents, setRecents] = useState<Recents[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchRecents = async () => {
            try {
                const res = await api.get('/users/recently-viewed');
                if (res.data.success) {
                    setRecents(res.data.data);
                }
            } catch (error) {
                console.error('Failed to fetch recently viewed', error);
            } finally {
                setLoading(false);
            }
        };
        fetchRecents();
    }, []);

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
                        Recently <span className="text-[#EF2F55]">Viewed</span>
                    </h1>
                </div>
            </header>

            <div className="h-20" />

            <div className="max-w-xl mx-auto p-4">
                {loading ? (
                    <div className="space-y-4">
                        {[1, 2, 3, 4].map((i) => (
                            <div key={i} className="h-24 rounded-[24px] bg-white border border-gray-50 animate-pulse shadow-sm" />
                        ))}
                    </div>
                ) : recents.length === 0 ? (
                    <div className="flex flex-col items-center justify-center py-20 text-center">
                        <div className="w-24 h-24 bg-gray-50 rounded-full flex items-center justify-center mb-6">
                            <User className="w-10 h-10 text-gray-300" />
                        </div>
                        <h3 className="text-2xl font-black text-gray-900 mb-2 tracking-tight">No history yet</h3>
                        <p className="text-gray-500 max-w-xs mx-auto font-medium">
                            You haven't visited any profiles recently.
                        </p>
                        <Button
                            className="mt-8 bg-gray-900 text-white hover:bg-black rounded-full px-10 py-6 font-bold shadow-lg"
                            onClick={() => router.push('/feed')}
                        >
                            Explore Feed
                        </Button>
                    </div>
                ) : (
                    <div className="grid grid-cols-1 gap-4">
                        {recents.map((item) => (
                            <div
                                key={item._id}
                                onClick={() => router.push(`/${item.user.username}`)}
                                className="group flex items-center gap-5 p-5 bg-white rounded-[28px] border border-transparent shadow-[0px_4px_20px_rgba(0,0,0,0.02)] hover:shadow-[0px_8px_30px_rgba(239,47,85,0.08)] hover:border-pink-50 transition-all duration-300 cursor-pointer active:scale-[0.98]"
                            >
                                <div className="relative shrink-0">
                                    <div className="w-16 h-16 rounded-full border-2 border-pink-50 p-0.5 group-hover:border-[#EF2F55] transition-colors duration-300">
                                        <Avatar className="w-full h-full border-2 border-white shadow-sm ring-1 ring-gray-100">
                                            <AvatarImage src={item.user.profilePhoto} className="object-cover" />
                                            <AvatarFallback className="bg-pink-50 text-[#EF2F55] font-black">
                                                {item.user.displayName?.[0] || 'U'}
                                            </AvatarFallback>
                                        </Avatar>
                                    </div>
                                </div>

                                <div className="flex-1 min-w-0">
                                    <div className="flex justify-between items-start gap-2">
                                        <h3 className="font-black text-gray-900 truncate group-hover:text-[#EF2F55] transition-colors text-lg tracking-tight">
                                            {item.user.displayName}
                                        </h3>
                                    </div>
                                    <p className="text-xs text-gray-400 mt-1 flex items-center gap-2 font-bold uppercase tracking-wider">
                                        <Clock className="w-3 h-3 text-gray-300" />
                                        Viewed {formatDate(item.viewedAt)}
                                    </p>
                                    {item.user.occupation && (
                                        <p className="text-xs text-gray-500 mt-1 truncate">
                                            {item.user.occupation} • {item.user.location}
                                        </p>
                                    )}
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
