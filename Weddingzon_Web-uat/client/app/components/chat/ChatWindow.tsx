'use client';

import { useState, useEffect, useRef } from 'react';
import { useSocket } from '../../context/SocketContext';
import api from '../../services/api';
import { useToast } from '../../contexts/ToastContext';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Send, Image as ImageIcon, Smile, X, CheckCheck, Loader2 } from 'lucide-react';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import EmojiPicker, { EmojiClickData } from 'emoji-picker-react';

interface ChatWindowProps {
    recipientId: string;
    recipientUsername: string;
    recipientName: string;
    recipientPhoto?: string;
    onClose: () => void;
    onRead?: () => void;
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

export default function ChatWindow({ recipientId, recipientUsername, recipientName, recipientPhoto, onClose, onRead }: ChatWindowProps) {
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

    // Initial Fetch & Mark Read
    useEffect(() => {
        fetchHistory();
        // Mark as read when opening window
        api.post('/chat/read', { senderId: recipientId });
        onRead?.();

        return () => {
            // Cleanup listeners
            if (socket) {
                socket.off('receive_message');
                socket.off('message_sent');
                socket.off('user_typing');
                socket.off('user_stop_typing');
            }
        };
    }, [recipientId]);

    // Socket Listeners (Re-attach when socket or recipientId changes)
    useEffect(() => {
        if (!socket) return;


        const handleReceive = (msg: Message) => {
            console.log('Socket: Received Message', msg);
            console.log('Checking Match:', {
                msgSender: msg.sender._id,
                msgReceiver: msg.receiver._id,
                recipientId
            });

            // Only add if it belongs to this conversation
            if (msg.sender._id === recipientId || msg.receiver._id === recipientId) {
                setMessages((prev) => [...prev, msg]);
                scrollToBottom();
                if (msg.sender._id === recipientId) {
                    // Mark as read immediately if window is open
                    api.post('/chat/read', { senderId: recipientId });
                    onRead?.();
                }
            }
        };

        const handleSent = (msg: Message) => {
            console.log('Socket: Message Sent Confirmation', msg);
            // Verify if the message is for the current recipient
            if (msg.receiver._id === recipientId) {
                setMessages((prev) => [...prev, msg]);
                scrollToBottom();
            } else {
                console.warn('Message sent to different recipient?', msg.receiver._id, recipientId);
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
        console.log('sendMessage called', { type, content, hasSocket: !!socket });

        if (!socket) {
            console.error('Socket not initialized! Cannot send message.');
            addToast('Error: Chat Disconnected. Please refresh the page.', 'error');
            return;
        }

        const msgContent = content || newMessage;
        if (!msgContent.trim() && type === 'text') {
            console.log('Empty message, ignoring');
            return;
        }

        const payload = {
            receiverId: recipientId,
            message: type === 'text' ? msgContent : undefined,
            type,
            mediaUrl: type === 'image' ? content : undefined
        };

        console.log('Emitting send_message...', payload);

        // Emit with Acknowledgement
        socket.emit('send_message', payload, (response: any) => {
            console.log('Server Ascribed Delivery:', response);
            if (response.status !== 'ok') {
                addToast('Message failed to send: ' + (response.error || 'Unknown error'), 'error');
            }
        });

        console.log('Emit executed');

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

        // Loop through all selected files
        const uploads = Array.from(files).map(async (file) => {
            const formData = new FormData();
            formData.append('image', file);

            try {
                const res = await api.post('/chat/upload', formData, {
                    headers: { 'Content-Type': 'multipart/form-data' }
                });
                sendMessage('image', res.data.url);
            } catch (err) {
                console.error("Failed to upload file:", file.name, err);
            }
        });

        try {
            await Promise.all(uploads);
        } catch (error) {
            addToast('Some images failed to upload', 'error');
        } finally {
            setUploading(false);
            // Reset input
            if (fileInputRef.current) fileInputRef.current.value = '';
        }
    };

    // ... inside render ...
    <input
        type="file"
        ref={fileInputRef}
        hidden
        multiple // Enable multiple selection
        accept="image/*"
        onChange={handleFileUpload}
    />

    const onEmojiClick = (emojiData: EmojiClickData) => {
        setNewMessage((prev) => prev + emojiData.emoji);
        setShowEmoji(false);
    };

    return (
        <div className="fixed bottom-0 right-4 w-80 sm:w-96 bg-white rounded-t-xl shadow-2xl border border-gray-200 z-50 flex flex-col h-[500px]">
            {/* Header */}
            <div className="bg-pink-600 text-white p-3 rounded-t-xl flex justify-between items-center shadow-md">
                <div className="flex items-center gap-3">
                    <Avatar className="w-8 h-8 border border-white/50">
                        <AvatarImage src={recipientPhoto} />
                        <AvatarFallback>{recipientName[0]}</AvatarFallback>
                    </Avatar>
                    <div>
                        <h3 className="font-bold text-sm">{recipientName}</h3>
                        {recipientTyping && <span className="text-xs text-white/80 italic animate-pulse">Typing...</span>}
                    </div>
                </div>
                <Button variant="ghost" size="icon" className="hover:bg-white/20 text-white h-8 w-8 rounded-full" onClick={onClose}>
                    <X className="w-5 h-5" />
                </Button>
            </div>

            {/* Messages Area */}
            <div className="flex-1 overflow-y-auto p-4 space-y-3 bg-gray-50 scrollbar-thin scrollbar-thumb-gray-200">
                {messages.length === 0 && !loading && (
                    <div className="text-center text-gray-400 text-sm mt-10">
                        Say hi to {recipientName}! 👋
                    </div>
                )}
                {messages.map((msg, idx) => {
                    const isMe = msg.sender._id !== recipientId; // If sender is NOT recipient, it's me
                    return (
                        <div key={idx} className={`flex ${isMe ? 'justify-end' : 'justify-start'}`}>
                            <div className={`max-w-[80%] rounded-2xl px-3 py-2 text-sm shadow-sm ${isMe
                                ? 'bg-[#EF2F55] text-white rounded-br-none'
                                : 'bg-white text-gray-800 border border-gray-100 rounded-bl-none'
                                }`}>
                                {msg.type === 'text' ? (
                                    <p>{msg.message}</p>
                                ) : (
                                    <img src={msg.mediaUrl} alt="Shared" className="rounded-lg max-h-40 object-cover" />
                                )}
                                <div className={`text-[10px] mt-1 flex items-center justify-end gap-1 ${isMe ? 'text-pink-100' : 'text-gray-400'}`}>
                                    {new Date(msg.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                </div>
                            </div>
                        </div>
                    );
                })}
                <div ref={messagesEndRef} />
            </div>

            {/* Input Area */}
            <div className="p-3 bg-white border-t border-gray-100 relative">
                {showEmoji && (
                    <div className="absolute bottom-16 left-0 z-10 shadow-xl">
                        <EmojiPicker onEmojiClick={onEmojiClick} width={300} height={350} />
                    </div>
                )}

                <form
                    onSubmit={(e) => { e.preventDefault(); sendMessage(); }}
                    className="flex gap-2 items-center"
                >
                    <div className="flex gap-1">
                        <Button
                            type="button"
                            variant="ghost"
                            size="icon"
                            className="text-gray-400 hover:text-pink-500 h-9 w-9"
                            onClick={() => setShowEmoji(!showEmoji)}
                        >
                            <Smile className="w-5 h-5" />
                        </Button>
                        <Button
                            type="button"
                            variant="ghost"
                            size="icon"
                            className="text-gray-400 hover:text-blue-500 h-9 w-9"
                            onClick={() => fileInputRef.current?.click()}
                        >
                            <ImageIcon className="w-5 h-5" />
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
                        placeholder="Type a message..."
                        className="rounded-full bg-gray-50 border-gray-200 focus-visible:ring-pink-500"
                        disabled={uploading}
                    />

                    <Button
                        type="submit"
                        size="icon"
                        disabled={(!newMessage.trim() && !uploading) || uploading}
                        className="bg-pink-600 hover:bg-pink-700 text-white rounded-full h-9 w-9 shrink-0"
                    >
                        {uploading ? <Loader2 className="w-4 h-4 animate-spin" /> : <Send className="w-4 h-4" />}
                    </Button>
                </form>
            </div>
        </div>
    );
}
