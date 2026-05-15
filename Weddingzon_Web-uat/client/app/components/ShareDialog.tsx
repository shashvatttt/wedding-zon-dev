'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
    X,
    Copy,
    Check,
    Share2,
    MessageCircle, // WhatsApp generic replacement if needed
    Facebook,
    Twitter,
    Mail,
    Linkedin,
    Link as LinkIcon,
    ArrowLeft,
    Search,
    Send,
    User,
    Users,
    Loader2
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { useSocket } from '../context/SocketContext';
import api from '../services/api';
import { useToast } from '../contexts/ToastContext';

interface ShareDialogProps {
    isOpen: boolean;
    onClose: () => void;
    profile: {
        username: string;
        first_name?: string;
        last_name?: string;
        profilePhoto?: string;
        occupation?: string;
    };
}

interface Connection {
    _id: string;
    username: string;
    first_name: string;
    last_name: string;
    profilePhoto: string;
    occupation?: string;
}

export default function ShareDialog({ isOpen, onClose, profile }: ShareDialogProps) {
    const { socket } = useSocket();
    const { addToast } = useToast();
    const [copied, setCopied] = useState(false);
    const [shareUrl, setShareUrl] = useState('');
    const [hasNativeShare, setHasNativeShare] = useState(false);

    // Chat Share State
    const [view, setView] = useState<'initial' | 'select-contact'>('initial');
    const [connections, setConnections] = useState<Connection[]>([]);
    const [filteredConnections, setFilteredConnections] = useState<Connection[]>([]);
    const [searchQuery, setSearchQuery] = useState('');
    const [loadingConnections, setLoadingConnections] = useState(false);
    const [sendingTo, setSendingTo] = useState<string | null>(null);
    const [sentTo, setSentTo] = useState<string[]>([]);

    useEffect(() => {
        if (typeof window !== 'undefined') {
            // Construct URL dynamically based on username
            const url = `${window.location.origin}/${profile.username}`;
            setShareUrl(url);
            setHasNativeShare(!!navigator.share);
        }
    }, [profile]); // Ensure URL updates if profile changes

    const fullName = [profile.first_name, profile.last_name].filter(Boolean).join(' ') || profile.username;
    const shareText = `Check out ${fullName}'s profile on WeddingZon!`;

    const handleCopy = async () => {
        try {
            await navigator.clipboard.writeText(shareUrl);
            setCopied(true);
            setTimeout(() => setCopied(false), 2000);
            addToast('Link copied to clipboard', 'success');
        } catch (err) {
            console.error('Failed to copy', err);
            addToast('Failed to copy link', 'error');
        }
    };

    const handleNativeShare = async () => {
        if (navigator.share) {
            try {
                await navigator.share({
                    title: `${fullName} on WeddingZon`,
                    text: shareText,
                    url: shareUrl,
                });
                onClose();
            } catch (err) {
                console.log('Error sharing', err);
            }
        }
    };

    const handleOpenChatSelection = async () => {
        setView('select-contact');
        if (connections.length === 0) {
            setLoadingConnections(true);
            try {
                const res = await api.get('/connections/my-connections');
                if (res.data.success) {
                    // Filter duplicates client-side just in case
                    const unique = res.data.data.filter((v: Connection, i: number, a: Connection[]) => a.findIndex((t) => t._id === v._id) === i);
                    setConnections(unique);
                    setFilteredConnections(unique);
                }
            } catch (error) {
                console.error("Failed to fetch connections", error);
            } finally {
                setLoadingConnections(false);
            }
        }
    };

    // Filter connections
    useEffect(() => {
        if (view === 'select-contact') {
            const lower = searchQuery.toLowerCase();
            setFilteredConnections(
                connections.filter(c =>
                    c.first_name.toLowerCase().includes(lower) ||
                    c.last_name.toLowerCase().includes(lower) ||
                    c.username.toLowerCase().includes(lower)
                )
            );
        }
    }, [searchQuery, connections, view]);


    const handleSendToChat = (recipientId: string) => {
        if (!socket) {
            addToast('Chat service unavailable. Please try again later.', 'error');
            return;
        }

        setSendingTo(recipientId);

        const payload = {
            receiverId: recipientId,
            message: `${shareText}\n${shareUrl}`, // Send as text message usually, or handle as rich link if you want
            type: 'text',
        };

        socket.emit('send_message', payload, (response: any) => {
            setSendingTo(null);
            if (response.status === 'ok') {
                setSentTo(prev => [...prev, recipientId]);
                addToast('Message sent', 'success');
            } else {
                addToast('Failed to send message', 'error');
            }
        });
    };

    const socialLinks = [
        {
            name: 'WhatsApp',
            icon: <MessageCircle className="w-6 h-6 text-green-500" />,
            url: `https://wa.me/?text=${encodeURIComponent(shareText + ' ' + shareUrl)}`,
            color: 'bg-green-50 hover:bg-green-100',
        },
        {
            name: 'Twitter', // X
            icon: <Twitter className="w-6 h-6 text-blue-400" />,
            url: `https://twitter.com/intent/tweet?text=${encodeURIComponent(shareText)}&url=${encodeURIComponent(shareUrl)}`,
            color: 'bg-blue-50 hover:bg-blue-100',
        },
        {
            name: 'Facebook',
            icon: <Facebook className="w-6 h-6 text-blue-600" />,
            url: `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(shareUrl)}`,
            color: 'bg-indigo-50 hover:bg-indigo-100',
        },
        {
            name: 'LinkedIn',
            icon: <Linkedin className="w-6 h-6 text-blue-700" />,
            url: `https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(shareUrl)}`,
            color: 'bg-blue-50 hover:bg-blue-100',
        },
        {
            name: 'Email',
            icon: <Mail className="w-6 h-6 text-gray-600" />,
            url: `mailto:?subject=${encodeURIComponent(`Check out ${fullName}`)}&body=${encodeURIComponent(shareText + '\n\n' + shareUrl)}`,
            color: 'bg-gray-50 hover:bg-gray-100',
        },
    ];

    if (!isOpen) return null;

    return (
        <AnimatePresence>
            {isOpen && (
                <>
                    {/* Backdrop */}
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        onClick={onClose}
                        className="fixed inset-0 z-[60] bg-black/40 backdrop-blur-sm flex items-end sm:items-center justify-center p-0 sm:p-4"
                    >
                        {/* Modal */}
                        <motion.div
                            initial={{ y: "100%", opacity: 0 }}
                            animate={{ y: 0, opacity: 1 }}
                            exit={{ y: "100%", opacity: 0 }}
                            transition={{ type: "spring", damping: 25, stiffness: 300 }}
                            onClick={(e) => e.stopPropagation()}
                            className="bg-white w-full max-w-md rounded-t-2xl sm:rounded-2xl shadow-2xl overflow-hidden flex flex-col max-h-[85vh]"
                        >
                            {/* Header */}
                            <div className="p-4 border-b border-gray-100 flex items-center justify-between bg-white sticky top-0 z-10">
                                {view === 'initial' ? (
                                    <h3 className="text-lg font-bold text-gray-900">Share Profile</h3>
                                ) : (
                                    <div className="flex items-center gap-2">
                                        <Button variant="ghost" size="icon" onClick={() => setView('initial')} className="-ml-2 rounded-full">
                                            <ArrowLeft className="w-5 h-5" />
                                        </Button>
                                        <h3 className="text-lg font-bold text-gray-900">Send in Chat</h3>
                                    </div>
                                )}
                                <Button variant="ghost" size="icon" onClick={onClose} className="rounded-full hover:bg-gray-100">
                                    <X className="w-5 h-5 text-gray-500" />
                                </Button>
                            </div>

                            {/* Content */}
                            <div className="overflow-y-auto">
                                {view === 'initial' ? (
                                    <div className="p-6 space-y-6">
                                        {/* Profile Preview */}
                                        <div className="flex flex-col items-center text-center space-y-3 p-4 bg-gray-50 rounded-xl border border-gray-100">
                                            <div className="w-20 h-20 rounded-full border-4 border-white shadow-sm overflow-hidden bg-gray-200">
                                                <img
                                                    src={profile.profilePhoto || '/default-avatar.png'}
                                                    alt={profile.username}
                                                    className="w-full h-full object-cover"
                                                />
                                            </div>
                                            <div className="space-y-1">
                                                <div className="font-bold text-lg text-gray-900">{fullName}</div>
                                                <div className="text-sm text-gray-500">{profile.occupation || 'Member'}</div>
                                            </div>
                                        </div>

                                        {/* Link Copy Section */}
                                        <div className="flex gap-2">
                                            <div className="flex-1 bg-gray-50 border border-gray-200 rounded-lg px-3 py-2 text-sm text-gray-600 truncate flex items-center">
                                                <LinkIcon className="w-4 h-4 mr-2 text-gray-400 flex-shrink-0" />
                                                <span className="truncate">{shareUrl}</span>
                                            </div>
                                            <Button
                                                onClick={handleCopy}
                                                className={`${copied ? 'bg-green-600 hover:bg-green-700' : 'bg-gray-900 hover:bg-gray-800'} text-white transition-all shadow-md`}
                                            >
                                                {copied ? <Check className="w-4 h-4" /> : <Copy className="w-4 h-4" />}
                                            </Button>
                                        </div>

                                        {/* Share Options Grid */}
                                        <div className="grid grid-cols-4 gap-4">
                                            {/* Chat Option (FIRST) */}
                                            <button
                                                onClick={handleOpenChatSelection}
                                                className="flex flex-col items-center gap-2 group"
                                            >
                                                <div className="w-14 h-14 rounded-full bg-pink-50 text-pink-600 flex items-center justify-center group-hover:bg-pink-100 transition-colors border border-pink-100 shadow-sm">
                                                    <Send className="w-6 h-6 ml-0.5" />
                                                </div>
                                                <span className="text-xs font-medium text-gray-600">Chat</span>
                                            </button>

                                            {/* Native Share Button (if supported) */}
                                            {hasNativeShare && (
                                                <button
                                                    onClick={handleNativeShare}
                                                    className="flex flex-col items-center gap-2 group"
                                                >
                                                    <div className="w-14 h-14 rounded-full bg-gray-50 text-gray-600 flex items-center justify-center group-hover:bg-gray-100 transition-colors border border-gray-100">
                                                        <Share2 className="w-6 h-6" />
                                                    </div>
                                                    <span className="text-xs font-medium text-gray-600">More</span>
                                                </button>
                                            )}

                                            {socialLinks.map((link) => (
                                                <a
                                                    key={link.name}
                                                    href={link.url}
                                                    target="_blank"
                                                    rel="noopener noreferrer"
                                                    className="flex flex-col items-center gap-2 group"
                                                >
                                                    <div className={`w-14 h-14 rounded-full flex items-center justify-center transition-colors border border-transparent group-hover:border-gray-200 ${link.color}`}>
                                                        {link.icon}
                                                    </div>
                                                    <span className="text-xs font-medium text-gray-600">{link.name}</span>
                                                </a>
                                            ))}
                                        </div>
                                    </div>
                                ) : (
                                    /* Connections Selection View */
                                    <div className="flex flex-col h-[400px]">
                                        {/* Search */}
                                        <div className="p-4 border-b border-gray-50">
                                            <div className="relative">
                                                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                                                <input
                                                    type="text"
                                                    placeholder="Search connections..."
                                                    value={searchQuery}
                                                    onChange={(e) => setSearchQuery(e.target.value)}
                                                    className="w-full pl-9 pr-4 py-2 bg-gray-50 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-pink-100 transition-all"
                                                />
                                            </div>
                                        </div>

                                        {/* List */}
                                        <div className="flex-1 overflow-y-auto p-2">
                                            {loadingConnections ? (
                                                <div className="flex flex-col items-center justify-center h-full text-gray-400 gap-2">
                                                    <Loader2 className="w-6 h-6 animate-spin" />
                                                    <span className="text-sm">Loading friends...</span>
                                                </div>
                                            ) : filteredConnections.length === 0 ? (
                                                <div className="flex flex-col items-center justify-center h-full text-gray-400 gap-2 p-8 text-center">
                                                    <User className="w-10 h-10 opacity-20" />
                                                    <p className="text-sm">No connections found.</p>
                                                </div>
                                            ) : (
                                                <div className="space-y-1">
                                                    {filteredConnections.map((conn) => {
                                                        const isSent = sentTo.includes(conn._id);
                                                        const isSending = sendingTo === conn._id;

                                                        return (
                                                            <div key={conn._id} className="flex items-center justify-between p-3 hover:bg-gray-50 rounded-xl transition-colors">
                                                                <div className="flex items-center gap-3 overflow-hidden">
                                                                    <Avatar className="w-10 h-10 border border-gray-100">
                                                                        <AvatarImage src={conn.profilePhoto} />
                                                                        <AvatarFallback>{conn.first_name[0]}</AvatarFallback>
                                                                    </Avatar>
                                                                    <div className="min-w-0">
                                                                        <h4 className="font-semibold text-sm text-gray-900 truncate">
                                                                            {conn.first_name} {conn.last_name}
                                                                        </h4>
                                                                    </div>
                                                                </div>

                                                                <Button
                                                                    size="sm"
                                                                    variant={isSent ? "outline" : "default"}
                                                                    disabled={isSent || isSending}
                                                                    onClick={() => handleSendToChat(conn._id)}
                                                                    className={`rounded-full px-4 h-8 ${isSent
                                                                        ? 'bg-green-50 text-green-600 border-green-200 hover:bg-green-100'
                                                                        : 'bg-pink-600 hover:bg-pink-700 text-white'
                                                                        }`}
                                                                >
                                                                    {isSending ? (
                                                                        <Loader2 className="w-3.5 h-3.5 animate-spin" />
                                                                    ) : isSent ? (
                                                                        <span className="flex items-center gap-1 text-xs font-bold">
                                                                            <Check className="w-3.5 h-3.5" /> Sent
                                                                        </span>
                                                                    ) : (
                                                                        <span className="text-xs">Send</span>
                                                                    )}
                                                                </Button>
                                                            </div>
                                                        );
                                                    })}
                                                </div>
                                            )}
                                        </div>
                                    </div>
                                )}
                            </div>

                        </motion.div>
                    </motion.div>
                </>
            )}
        </AnimatePresence>
    );
}
