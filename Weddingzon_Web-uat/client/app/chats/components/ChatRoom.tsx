'use client';

import { useState, useEffect, useRef } from 'react';
import { useSocket } from '../../context/SocketContext';
import api from '../../services/api';
import { useToast } from '../../contexts/ToastContext';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Send, Image as ImageIcon, Smile, Paperclip, Loader2, ArrowLeft } from 'lucide-react'; // Added Paperclip
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import EmojiPicker, { EmojiClickData } from 'emoji-picker-react';
import Image from 'next/image';
import { formatLastSeen } from '@/app/utils/formatTime';

interface ChatRoomProps {
    recipientId: string;
    recipientUsername: string;
    recipientName: string;
    recipientPhoto?: string;
    isOnline?: boolean;
    lastSeen?: string;
    // onClose: () => void; // Not needed in full page view usually
    onRead?: () => void;
    onBack?: () => void;
}

interface Message {
    _id: string;
    sender: { _id: string; username: string };
    receiver: { _id: string; username: string };
    message?: string;
    type: 'text' | 'image';
    mediaUrl?: string;
    read: boolean;
    createdAt: string;
}

export default function ChatRoom({ recipientId, recipientUsername, recipientName, recipientPhoto, isOnline, lastSeen, onRead, onBack }: ChatRoomProps) {
    const { socket } = useSocket();
    const { addToast } = useToast();
    const [messages, setMessages] = useState<Message[]>([]);
    const [newMessage, setNewMessage] = useState('');
    const [isTyping, setIsTyping] = useState(false);
    const [recipientTyping, setRecipientTyping] = useState(false);
    const [page, setPage] = useState(1);
    const [loading, setLoading] = useState(false);
    const [showEmoji, setShowEmoji] = useState(false);
    const [uploading, setUploading] = useState(false);

    const messagesEndRef = useRef<HTMLDivElement>(null);
    const fileInputRef = useRef<HTMLInputElement>(null);
    const typingTimeoutRef = useRef<NodeJS.Timeout | null>(null);

    // Initial Fetch & Mark Read (Copied logic)
    useEffect(() => {
        fetchHistory();
        api.post('/chat/read', { senderId: recipientId });
        onRead?.();

        return () => {
            // Cleanup listeners if needed, but the main effect below handles re-binds
        };
    }, [recipientId]);

    // Socket Listeners
    useEffect(() => {
        if (!socket) return;

        const handleReceive = (msg: Message) => {
            if (msg.sender._id === recipientId || msg.receiver._id === recipientId) {
                setMessages((prev) => [...prev, msg]);
                scrollToBottom();
                if (msg.sender._id === recipientId) {
                    api.post('/chat/read', { senderId: recipientId });
                    onRead?.();
                }
            }
        };

        const handleSent = (msg: Message) => {
            if (msg.receiver._id === recipientId) {
                setMessages((prev) => [...prev, msg]);
                scrollToBottom();
            }
        };

        const handleTyping = (data: { userId: string }) => {
            if (data.userId === recipientId) setRecipientTyping(true);
        };

        const handleStopTyping = (data: { userId: string }) => {
            if (data.userId === recipientId) setRecipientTyping(false);
        };

        socket.on('receive_message', handleReceive);
        socket.on('message_sent', handleSent);
        socket.on('user_typing', handleTyping);
        socket.on('user_stop_typing', handleStopTyping);

        return () => {
            socket.off('receive_message', handleReceive);
            socket.off('message_sent', handleSent);
            socket.off('user_typing', handleTyping);
            socket.off('user_stop_typing', handleStopTyping);
        };
    }, [socket, recipientId]);

    const fetchHistory = async () => {
        setLoading(true);
        try {
            const res = await api.get(`/chat/history/${recipientId}?page=${page}`);
            if (page === 1) {
                setMessages(res.data.data);
                scrollToBottom();
            } else {
                setMessages((prev) => [...res.data.data, ...prev]);
            }
        } catch (err) {
            console.error('Failed to fetch chat history', err);
        } finally {
            setLoading(false);
        }
    };

    const scrollToBottom = () => {
        setTimeout(() => {
            messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
        }, 100);
    };

    const sendMessage = (type: 'text' | 'image' = 'text', content?: string) => {
        if (!socket) {
            addToast('Error: Chat Disconnected', 'error');
            return;
        }

        const msgContent = content || newMessage;
        if (!msgContent.trim() && type === 'text') return;

        const payload = {
            receiverId: recipientId,
            message: type === 'text' ? msgContent : undefined,
            type,
            mediaUrl: type === 'image' ? content : undefined
        };

        socket.emit('send_message', payload, (response: any) => {
            if (response.status !== 'ok') {
                addToast(response.error || 'Message failed to send', 'error');
            }
        });

        if (type === 'text') {
            setNewMessage('');
            stopTyping();
        }
    };

    const handleThinking = (e: React.ChangeEvent<HTMLInputElement>) => {
        setNewMessage(e.target.value);
        if (!socket) return;

        if (!isTyping) {
            setIsTyping(true);
            socket.emit('typing', { receiverId: recipientId });
        }

        if (typingTimeoutRef.current) clearTimeout(typingTimeoutRef.current);

        typingTimeoutRef.current = setTimeout(() => {
            stopTyping();
        }, 2000);
    };

    const stopTyping = () => {
        if (isTyping && socket) {
            setIsTyping(false);
            socket.emit('stop_typing', { receiverId: recipientId });
        }
    };

    const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const files = e.target.files;
        if (!files || files.length === 0) return;

        setUploading(true);
        const uploads = Array.from(files).map(async (file) => {
            const formData = new FormData();
            formData.append('image', file);
            try {
                const res = await api.post('/chat/upload', formData, {
                    headers: { 'Content-Type': 'multipart/form-data' }
                });
                sendMessage('image', res.data.url);
            } catch (err) {
                console.error("Failed to upload", err);
            }
        });

        try {
            await Promise.all(uploads);
        } finally {
            setUploading(false);
            if (fileInputRef.current) fileInputRef.current.value = '';
        }
    };

    const onEmojiClick = (emojiData: EmojiClickData) => {
        setNewMessage((prev) => prev + emojiData.emoji);
        setShowEmoji(false);
    };

    return (
        <div className="flex flex-col h-full bg-white rounded-r-3xl shadow-sm relative">
            {/* Header */}
            <div className="flex items-center gap-4 p-4 border-b border-gray-50 bg-[#FFE8ED]/30 h-[80px]">
                {onBack && (
                    <Button variant="ghost" size="icon" className="lg:hidden -ml-2 text-gray-600 rounded-full" onClick={onBack}>
                        <ArrowLeft className="w-5 h-5" />
                    </Button>
                )}
                <div className="relative">
                    <Avatar className="w-12 h-12 border-2 border-white shadow-sm">
                        <AvatarImage src={recipientPhoto} />
                        <AvatarFallback>{recipientName[0]}</AvatarFallback>
                    </Avatar>
                    {/* Status dot */}
                    <span className="absolute bottom-1 right-0 w-3 h-3 bg-green-500 border-2 border-white rounded-full"></span>
                </div>
                <div className="flex-1">
                    <h3 className="font-bold text-lg text-black leading-tight">{recipientName}</h3>
                    <p className="text-xs text-gray-500">
                        {recipientTyping ? 'Typing...' : (
                            isOnline ? 'Online' : (lastSeen ? `Active ${formatLastSeen(lastSeen)}` : '')
                        )}
                    </p>
                </div>

                {/* Action Buttons (Mock based on design, simplified) */}
                <div className="flex gap-2">
                    {/* Add call/video buttons later if needed */}
                </div>
            </div>

            {/* Messages */}
            <div className="flex-1 overflow-y-auto p-6 space-y-4 bg-white">
                {messages.length === 0 && !loading && (
                    <div className="text-center text-gray-400 mt-20">
                        <div className="w-20 h-20 bg-gray-100 rounded-full mx-auto mb-4 flex items-center justify-center">
                            <Smile className="w-10 h-10 text-gray-300" />
                        </div>
                        <p>No messages yet.</p>
                        <p className="text-sm">Start the conversation with {recipientName.split(' ')[0]}!</p>
                    </div>
                )}

                {messages.map((msg, idx) => {
                    const senderId = typeof msg.sender === 'string' ? msg.sender : msg.sender._id;
                    const isMe = senderId !== recipientId;
                    return (
                        <div key={idx} className={`flex gap-3 ${isMe ? 'flex-row-reverse' : 'flex-row'}`}>
                            {!isMe && (
                                <Avatar className="w-8 h-8 self-end mb-1">
                                    <AvatarImage src={recipientPhoto} />
                                    <AvatarFallback>{recipientName[0]}</AvatarFallback>
                                </Avatar>
                            )}

                            <div className={`max-w-[70%] group relative`}>
                                <div className={`px-5 py-3 rounded-2xl text-[15px] shadow-sm ${isMe
                                    ? 'bg-[#EF2F55] text-white rounded-br-sm'
                                    : 'bg-[#F9FAFB] text-gray-800 border border-gray-100 rounded-bl-sm'
                                    }`}>
                                    {msg.type === 'text' ? (
                                        <p>{msg.message}</p>
                                    ) : (
                                        <div className="relative w-64 h-64 rounded-xl overflow-hidden cursor-pointer bg-black/10">
                                            <Image src={msg.mediaUrl || ''} alt="Shared" fill className="object-cover" />
                                        </div>
                                    )}
                                </div>
                                <div className={`text-[10px] mt-1 text-gray-400 opacity-0 group-hover:opacity-100 transition-opacity absolute -bottom-5 ${isMe ? 'right-0' : 'left-0'}`}>
                                    {new Date(msg.createdAt).toLocaleTimeString([], { hour: 'numeric', minute: '2-digit', hour12: true }).toLowerCase()}
                                </div>
                            </div>

                            {/* My Avatar (Right side) - Design typically doesn't show own avatar in chat, but existing ChatWindow didn't either. Leaving out for clean look. */}
                        </div>
                    );
                })}
                <div ref={messagesEndRef} />
            </div>

            {/* Input Area */}
            <div className="p-4 border-t border-gray-50">
                <div className="relative flex items-center gap-2 bg-white border border-gray-200 rounded-full px-2 py-2 shadow-sm focus-within:ring-2 focus-within:ring-pink-100 transition-shadow">

                    <div className="flex items-center gap-1 pl-1">
                        <Button
                            variant="ghost" size="icon" className="text-gray-400 hover:text-gray-600 rounded-full w-9 h-9"
                            onClick={() => setShowEmoji(!showEmoji)}
                        >
                            <Smile className="w-5 h-5" />
                        </Button>
                        <Button
                            variant="ghost" size="icon" className="text-gray-400 hover:text-gray-600 rounded-full w-9 h-9"
                            onClick={() => fileInputRef.current?.click()}
                        >
                            <Paperclip className="w-5 h-5" />
                        </Button>
                        <input
                            type="file"
                            ref={fileInputRef}
                            hidden
                            multiple
                            accept="image/*"
                            onChange={handleFileUpload}
                        />
                    </div>

                    <Input
                        value={newMessage}
                        onChange={handleThinking}
                        onKeyDown={(e) => { if (e.key === 'Enter') { e.preventDefault(); sendMessage(); } }}
                        placeholder="Type a message..."
                        className="flex-1 border-none focus-visible:ring-0 shadow-none bg-transparent placeholder:text-gray-400 px-2"
                        disabled={uploading}
                    />

                    <Button
                        onClick={() => sendMessage()}
                        disabled={(!newMessage.trim() && !uploading) || uploading}
                        size="icon"
                        className="w-10 h-10 rounded-full bg-white hover:bg-gray-50 text-[var(--primary)] shrink-0 shadow-none"
                    >
                        {uploading ? <Loader2 className="w-5 h-5 animate-spin" /> : <Send className="w-5 h-5" />}
                    </Button>

                    {/* Emoji Picker Popup */}
                    {showEmoji && (
                        <div className="absolute bottom-16 left-0 z-50">
                            <EmojiPicker onEmojiClick={onEmojiClick} searchDisabled width={300} height={350} />
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}
