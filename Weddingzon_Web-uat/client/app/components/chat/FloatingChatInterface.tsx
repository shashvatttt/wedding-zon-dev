'use client';

import { useState, useEffect } from 'react';
import ChatList from './ChatList';
import ChatWindow from './ChatWindow';
import { Button } from '@/components/ui/button';
import { MessageCircle, X, Minimize2, Maximize2 } from 'lucide-react';
import { useSocket } from '../../context/SocketContext';
import api from '../../services/api';
import { useSearchParams } from 'next/navigation';

export default function FloatingChatInterface() {
    const [isOpen, setIsOpen] = useState(false);
    const [activeChat, setActiveChat] = useState<any>(null); // Conversation object
    const [isMinimized, setIsMinimized] = useState(false);

    // Toggle main chat box
    const toggleOpen = () => {
        const nextState = !isOpen;
        setIsOpen(nextState);
        if (nextState) {
            setIsMinimized(false);
            setUnreadCount(0); // Clear notifications when opened
        }
    };

    const handleSelectUser = (user: any) => {
        setActiveChat({
            _id: user._id, // User ID
            username: user.username,
            name: `${user.first_name} ${user.last_name}`,
            photo: user.profilePhoto
        });
        // We remain open, but maybe specialized view? 
        // Actually, if we select a user, we normally show the window.
        // My design: FloatingInterface is the LIST. ChatWindow is the CONVERSATION.
    };

    const { socket } = useSocket();
    const [unreadCount, setUnreadCount] = useState(0);

    // Fetch unread count on mount
    useEffect(() => {
        const fetchUnread = async () => {
            try {
                const res = await api.get('/chat/conversations');
                const total = res.data.data.reduce((acc: number, conv: any) => acc + (conv.unreadCount || 0), 0);
                setUnreadCount(total);
            } catch (e) {
                console.error('Failed to fetch unread count');
            }
        };
        fetchUnread();
    }, []); // Only on mount

    // Listen for new messages
    useEffect(() => {
        if (!socket) return;
        const handleReceive = () => {
            if (!isOpen) {
                setUnreadCount(prev => prev + 1);
            }
        };
        socket.on('receive_message', handleReceive);
        return () => {
            socket.off('receive_message', handleReceive);
        };
    }, [socket, isOpen]);

    // Handle URL params for routing
    const searchParams = useSearchParams();
    useEffect(() => {
        const chatId = searchParams.get('chatId');
        if (chatId) {
            // If already active with this user, do nothing unique (maybe just ensure open)
            if (activeChat && activeChat._id === chatId) {
                if (!isOpen) setIsOpen(true);
                return;
            }

            // Find user in existing conversations
            api.get('/chat/conversations')
                .then(res => {
                    const conversations = res.data.data;
                    const conversation = conversations.find((c: any) =>
                        c.participants.some((p: any) => p._id === chatId) ||
                        (c.otherUser && c.otherUser._id === chatId)
                    );

                    if (conversation) {
                        const user = conversation.otherUser || conversation.participants.find((p: any) => p._id === chatId);
                        if (user) {
                            setActiveChat({
                                _id: user._id,
                                username: user.username,
                                name: `${user.first_name} ${user.last_name}`,
                                photo: user.profilePhoto
                            });
                            setIsOpen(true);
                        }
                    }
                })
                .catch(err => console.error('Failed to resolve chat user', err));
        }
    }, [searchParams, activeChat, isOpen]);

    return (
        <>
            {/* FAB Button (Only on Feed usually, or global) */}
            <Button
                onClick={toggleOpen}
                className={`fixed bottom-6 right-6 h-14 w-14 rounded-full shadow-lg bg-pink-600 hover:bg-pink-700 text-white z-40 transition-transform hover:scale-105 ${isOpen ? 'rotate-90 opacity-0 pointer-events-none' : 'opacity-100'}`}
            >
                <div className="relative">
                    <MessageCircle className="w-7 h-7" />
                    {unreadCount > 0 && (
                        <span className="absolute -top-1 -right-1 bg-red-500 text-white text-[10px] font-bold px-1.5 py-0.5 rounded-full min-w-[18px] h-[18px] flex items-center justify-center border-2 border-white">
                            {unreadCount > 9 ? '9+' : unreadCount}
                        </span>
                    )}
                </div>
            </Button>

            {/* Chat List Box */}
            {isOpen && !activeChat && (
                <div className="fixed bottom-6 right-6 w-80 sm:w-96 bg-white rounded-2xl shadow-2xl border border-gray-200 z-50 flex flex-col h-[600px] overflow-hidden animate-in slide-in-from-bottom-10 fade-in duration-200">
                    <div className="bg-gradient-to-r from-pink-600 to-purple-600 p-4 flex justify-between items-center text-white">
                        <h3 className="font-bold flex items-center gap-2">
                            <MessageCircle className="w-5 h-5" /> Messages
                        </h3>
                        <Button variant="ghost" size="icon" className="hover:bg-white/20 text-white rounded-full h-8 w-8" onClick={toggleOpen}>
                            <X className="w-5 h-5" />
                        </Button>
                    </div>
                    <ChatList onSelectUser={handleSelectUser} />
                </div>
            )}

            {/* Active Chat Window */}
            {activeChat && (
                <ChatWindow
                    recipientId={activeChat._id}
                    recipientUsername={activeChat.username}
                    recipientName={activeChat.name}
                    recipientPhoto={activeChat.photo}
                    onClose={() => setActiveChat(null)}
                    onRead={() => {
                        // Optimistically decrement count if > 0
                        // Since we don't know exactly how many messages were unread in that specific chat,
                        // this implementation assumes opening it clears "some".
                        // A better approach would be to re-fetch the count or track per-conversation counts.
                        // For now, re-fetching is safest to get accurate global count.
                        api.get('/chat/conversations')
                            .then(res => {
                                const total = res.data.data.reduce((acc: number, conv: any) => acc + (conv.unreadCount || 0), 0);
                                setUnreadCount(total);
                            })
                            .catch(err => console.error(err));
                    }}
                />
            )}
        </>
    );
}
