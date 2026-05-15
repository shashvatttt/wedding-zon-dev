'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import api from '../services/api';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { ArrowLeft, Search, MapPin, Briefcase, MessageCircle, User, Trash2 } from 'lucide-react';
import { motion } from 'framer-motion';
import ChatWindow from '../components/chat/ChatWindow';
import ConfirmationModal from '../../components/ConfirmationModal';
import { useToast } from '../contexts/ToastContext';

interface Connection {
    _id: string;
    username: string;
    first_name: string;
    last_name: string;
    profilePhoto: string;
    occupation?: string;
    city?: string;
    state?: string;
    country?: string;
    age?: number;
}

export default function ConnectionsPage() {
    const router = useRouter();
    const { addToast } = useToast();
    const [connections, setConnections] = useState<Connection[]>([]);
    const [filteredConnections, setFilteredConnections] = useState<Connection[]>([]);
    const [searchQuery, setSearchQuery] = useState('');
    const [loading, setLoading] = useState(true);
    const [selectedChatUser, setSelectedChatUser] = useState<Connection | null>(null);

    // Modal State
    const [confirmModal, setConfirmModal] = useState({
        isOpen: false,
        title: '',
        message: '',
        onConfirm: async () => { },
        isDangerous: false,
        confirmText: 'Confirm'
    });

    useEffect(() => {
        const fetchConnections = async () => {
            try {
                const res = await api.get('/connections/my-connections');
                if (res.data.success) {
                    console.log('Connections API Response:', res.data.data); // Debug log
                    // Filter duplicates based on _id right here to be safe
                    const uniqueConnections = res.data.data.filter((v: Connection, i: number, a: Connection[]) => a.findIndex((t: Connection) => t._id === v._id) === i);
                    if (uniqueConnections.length !== res.data.data.length) {
                        console.warn('Duplicate connections detected and filtered client-side');
                    }
                    setConnections(uniqueConnections);
                    setFilteredConnections(uniqueConnections);
                }
            } catch (error) {
                console.error("Failed to fetch connections", error);
            } finally {
                setLoading(false);
            }
        };

        fetchConnections();
    }, []);

    useEffect(() => {
        const lowerQuery = searchQuery.toLowerCase();
        const filtered = connections.filter(conn =>
            conn.first_name.toLowerCase().includes(lowerQuery) ||
            conn.last_name.toLowerCase().includes(lowerQuery) ||
            conn.username.toLowerCase().includes(lowerQuery) ||
            (conn.occupation && conn.occupation.toLowerCase().includes(lowerQuery)) ||
            (conn.city && conn.city.toLowerCase().includes(lowerQuery))
        );
        setFilteredConnections(filtered);
    }, [searchQuery, connections]);

    const handleRemoveConnection = (conn: Connection) => {
        setConfirmModal({
            isOpen: true,
            title: `Remove Connection?`,
            message: `Are you sure you want to remove ${conn.first_name} from your connections?`,
            confirmText: 'Remove',
            isDangerous: true,
            onConfirm: async () => {
                try {
                    await api.delete('/connections/delete', { data: { targetUsername: conn.username } });
                    setConnections(prev => prev.filter(c => c._id !== conn._id));
                    addToast('Connection removed', 'success');
                } catch (err: any) {
                    addToast('Failed to remove connection', 'error');
                }
            }
        });
    };

    const container = {
        hidden: { opacity: 0 },
        show: {
            opacity: 1,
            transition: {
                staggerChildren: 0.05
            }
        }
    };

    const item = {
        hidden: { opacity: 0, y: 20 },
        show: { opacity: 1, y: 0 }
    };

    return (
        <div className="min-h-screen bg-[#FFF9FA] pb-20 font-inter">
            {/* Header */}
            <div className="sticky top-0 z-20 bg-white/80 backdrop-blur-md border-b border-gray-100 px-4 py-4 md:px-8">
                <div className="max-w-5xl mx-auto flex flex-col md:flex-row md:items-center justify-between gap-4">
                    <div className="flex items-center gap-4">
                        <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => router.back()}
                            className="bg-gray-50 hover:bg-gray-100 rounded-full"
                        >
                            <ArrowLeft className="w-5 h-5 text-gray-700" />
                        </Button>
                        <div>
                            <h1 className="text-2xl font-black text-gray-900">
                                My <span className="text-[#EF2F55]">Connections</span>
                            </h1>
                            <p className="text-xs text-gray-500 font-bold uppercase tracking-wider">
                                {connections.length} {connections.length === 1 ? 'Friend' : 'Friends'} Connected
                            </p>
                        </div>
                    </div>

                    {/* Search Bar */}
                    <div className="relative w-full md:w-80">
                        <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                        <input
                            type="text"
                            placeholder="Search matches..."
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            className="w-full pl-12 pr-4 py-3 bg-white border border-gray-100 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-pink-100 focus:border-pink-200 shadow-sm transition-all"
                        />
                    </div>
                </div>
            </div>

            {/* Content using motion.div directly would require 'use client' which we have. */}
            <div className="max-w-5xl mx-auto px-4 py-8">
                {loading ? (
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-8">
                        {[1, 2, 3, 4].map((i) => (
                            <div key={i} className="h-48 bg-white rounded-[32px] shadow-sm animate-pulse" />
                        ))}
                    </div>
                ) : filteredConnections.length === 0 ? (
                    <div className="flex flex-col items-center justify-center py-20 text-center">
                        <div className="w-24 h-24 bg-pink-50 rounded-full flex items-center justify-center mb-6">
                            <User className="w-10 h-10 text-[#EF2F55]" />
                        </div>
                        <h3 className="text-2xl font-black text-gray-900 mb-2">Finding your perfect match</h3>
                        <p className="text-gray-500 max-w-sm font-medium">
                            {connections.length === 0
                                ? "You haven't connected with anyone yet. Your special someone is just a click away!"
                                : `No results found for "${searchQuery}".`}
                        </p>
                        {connections.length === 0 && (
                            <Button
                                className="mt-8 bg-[#EF2F55] hover:bg-rose-600 text-white rounded-full px-10 py-6 font-bold shadow-lg shadow-pink-100"
                                onClick={() => router.push('/feed')}
                            >
                                Start Exploring
                            </Button>
                        )}
                    </div>
                ) : (
                    <motion.div
                        variants={container}
                        initial="hidden"
                        animate="show"
                        className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-8"
                    >
                        {filteredConnections.map((conn) => (
                            <motion.div key={conn._id} variants={item}>
                                <Card className="overflow-hidden border-none shadow-[0px_8px_30px_rgba(0,0,0,0.04)] hover:shadow-[0px_8px_40px_rgba(239,47,85,0.08)] transition-all duration-500 bg-white rounded-[32px] group">
                                    <CardContent className="p-0">
                                        <div className="p-8 flex items-center gap-6">
                                            <div
                                                className="relative cursor-pointer shrink-0"
                                                onClick={() => router.push(`/${conn.username}`)}
                                            >
                                                <div className="w-24 h-24 rounded-full border-[3px] border-pink-50 p-1 group-hover:border-[#EF2F55] transition-colors duration-500">
                                                    <Avatar className="w-full h-full border-2 border-white shadow-sm ring-1 ring-gray-100">
                                                        <AvatarImage src={conn.profilePhoto} className="object-cover" />
                                                        <AvatarFallback className="bg-pink-50 text-[#EF2F55] text-2xl font-black">
                                                            {conn.first_name?.[0]}
                                                        </AvatarFallback>
                                                    </Avatar>
                                                </div>
                                                <div className="absolute top-1 right-1 w-6 h-6 bg-white rounded-full p-1 shadow-md">
                                                    <div className="w-full h-full bg-green-500 rounded-full" />
                                                </div>
                                            </div>

                                            <div className="flex-1 min-w-0">
                                                <div className="flex flex-col">
                                                    <h3
                                                        className="text-xl font-black text-gray-900 truncate cursor-pointer hover:text-[#EF2F55] transition-colors leading-tight"
                                                        onClick={() => router.push(`/${conn.username}`)}
                                                    >
                                                        {conn.first_name} {conn.last_name}
                                                    </h3>
                                                </div>

                                                <div className="mt-4 flex flex-wrap gap-2">
                                                    {(conn.occupation) && (
                                                        <div className="flex items-center gap-1.5 px-3 py-1 bg-gray-50 rounded-full text-[10px] font-bold text-gray-500 uppercase">
                                                            <Briefcase className="w-3 h-3" />
                                                            <span className="truncate max-w-[100px]">{conn.occupation}</span>
                                                        </div>
                                                    )}
                                                    {(conn.city) && (
                                                        <div className="flex items-center gap-1.5 px-3 py-1 bg-gray-50 rounded-full text-[10px] font-bold text-gray-500 uppercase">
                                                            <MapPin className="w-3 h-3" />
                                                            <span className="truncate max-w-[100px]">{conn.city}</span>
                                                        </div>
                                                    )}
                                                </div>
                                            </div>
                                        </div>

                                        <div className="px-8 pb-8 pt-0 flex gap-4">
                                            <Button
                                                variant="outline"
                                                className="flex-none w-14 h-14 border-gray-100 text-gray-400 hover:bg-red-50 hover:text-red-500 hover:border-red-100 rounded-2xl transition-all duration-300"
                                                onClick={() => handleRemoveConnection(conn)}
                                                title="Remove Connection"
                                            >
                                                <Trash2 className="w-6 h-6" />
                                            </Button>
                                            <Button
                                                className="flex-1 h-14 bg-gray-900 hover:bg-black text-white rounded-2xl font-bold transition-all shadow-md active:scale-95"
                                                onClick={() => router.push(`/${conn.username}`)}
                                            >
                                                <User className="w-5 h-5 mr-3" />
                                                View Profile
                                            </Button>
                                            <Button
                                                className="flex-1 h-14 bg-[#EF2F55] hover:bg-rose-600 text-white rounded-2xl font-bold transition-all shadow-lg shadow-pink-100 active:scale-95"
                                                onClick={() => setSelectedChatUser(conn)}
                                            >
                                                <MessageCircle className="w-5 h-5 mr-3 fill-current" />
                                                Chat
                                            </Button>
                                        </div>
                                    </CardContent>
                                </Card>
                            </motion.div>
                        ))}
                    </motion.div>
                )}
            </div>

            {selectedChatUser && (
                <ChatWindow
                    recipientId={selectedChatUser._id}
                    recipientUsername={selectedChatUser.username}
                    recipientName={`${selectedChatUser.first_name} ${selectedChatUser.last_name}`}
                    recipientPhoto={selectedChatUser.profilePhoto}
                    onClose={() => setSelectedChatUser(null)}
                />
            )}

            <ConfirmationModal
                isOpen={confirmModal.isOpen}
                onClose={() => setConfirmModal(prev => ({ ...prev, isOpen: false }))}
                onConfirm={confirmModal.onConfirm}
                title={confirmModal.title}
                message={confirmModal.message}
                confirmText={confirmModal.confirmText}
                isDangerous={confirmModal.isDangerous}
            />
        </div>
    );
}
