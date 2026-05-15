'use client';

import { useEffect, useState } from 'react';
import api from '../../services/api';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Loader2 } from 'lucide-react';

interface Conversation {
    _id: string; // User ID
    username: string;
    first_name: string;
    last_name: string;
    profilePhoto: string;
    lastMessage: string;
    lastMessageAt: string;
    unreadCount: number;
}

interface ChatListProps {
    onSelectUser: (user: Conversation) => void;
}

export default function ChatList({ onSelectUser }: ChatListProps) {
    const [conversations, setConversations] = useState<Conversation[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchConversations();
    }, []);

    const fetchConversations = async () => {
        try {
            const res = await api.get('/chat/conversations');
            setConversations(res.data.data);
        } catch (error) {
            console.error('Failed to fetch conversations', error);
        } finally {
            setLoading(false);
        }
    };

    if (loading) return <div className="flex justify-center p-8"><Loader2 className="animate-spin text-pink-500" /></div>;

    if (conversations.length === 0) {
        return (
            <div className="p-8 text-center text-gray-500">
                <p>No conversations yet.</p>
                <p className="text-xs mt-2">Connect with people to start chatting!</p>
            </div>
        );
    }

    return (
        <div className="flex-1 overflow-y-auto">
            {conversations.map((conv) => (
                <div
                    key={conv._id}
                    onClick={() => onSelectUser(conv)}
                    className="flex items-center gap-3 p-3 hover:bg-gray-50 cursor-pointer border-b border-gray-100 transition-colors"
                >
                    <div className="relative">
                        <Avatar className="w-12 h-12 border border-gray-200">
                            <AvatarImage src={conv.profilePhoto} />
                            <AvatarFallback>{conv.first_name?.[0]}</AvatarFallback>
                        </Avatar>
                        {conv.unreadCount > 0 && (
                            <span className="absolute -top-1 -right-1 bg-pink-600 text-white text-[10px] w-5 h-5 flex items-center justify-center rounded-full border-2 border-white font-bold">
                                {conv.unreadCount}
                            </span>
                        )}
                    </div>
                    <div className="flex-1 min-w-0">
                        <div className="flex justify-between items-baseline mb-1">
                            <h4 className="font-semibold text-gray-900 truncate">
                                {conv.first_name} {conv.last_name}
                            </h4>
                            <span className="text-xs text-gray-400">
                                {new Date(conv.lastMessageAt).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}
                            </span>
                        </div>
                        <p className={`text-sm truncate ${conv.unreadCount > 0 ? 'font-medium text-gray-800' : 'text-gray-500'}`}>
                            {conv.lastMessage || 'Sent an image'}
                        </p>
                    </div>
                </div>
            ))}
        </div>
    );
}
