'use client';

import { useEffect, useState } from 'react';
import api from '../../services/api';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { ArrowLeft, Ban, CheckCircle, Search } from 'lucide-react';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import ConfirmationModal from '../../../components/ConfirmationModal';
import { useToast } from '../../contexts/ToastContext';

interface BlockedUser {
    _id: string;
    username: string;
    displayName: string;
    profilePhoto: string;
}

export default function BlockedUsersPage() {
    const router = useRouter();
    const { addToast } = useToast();
    const [blockedUsers, setBlockedUsers] = useState<BlockedUser[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');

    // Modal State
    const [confirmModal, setConfirmModal] = useState({
        isOpen: false,
        title: '',
        message: '',
        onConfirm: async () => { },
        isDangerous: false,
        confirmText: 'Confirm'
    });

    const fetchBlockedUsers = async () => {
        try {
            const res = await api.get('/users/blocked-users');
            if (res.data.success) {
                setBlockedUsers(res.data.data);
            }
        } catch (error) {
            console.error('Failed to fetch blocked users', error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchBlockedUsers();
    }, []);

    const handleUnblock = (username: string) => {
        setConfirmModal({
            isOpen: true,
            title: `Unblock ${username}?`,
            message: `Are you sure you want to unblock ${username}? they will be able to see you again.`,
            confirmText: 'Unblock',
            isDangerous: false,
            onConfirm: async () => {
                try {
                    await api.post('/users/unblock', { targetUsername: username });
                    setBlockedUsers(prev => prev.filter(u => u.username !== username));
                    addToast('User unblocked successfully', 'success');
                } catch (error: any) {
                    addToast(error.response?.data?.message || 'Failed to unblock user', 'error');
                }
            }
        });
    };

    const filteredUsers = blockedUsers.filter(u =>
        u.displayName.toLowerCase().includes(searchQuery.toLowerCase()) ||
        u.username.toLowerCase().includes(searchQuery.toLowerCase())
    );

    return (
        <div className="min-h-screen bg-white text-gray-900 font-sans pb-20">
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
                    <h1 className="text-lg font-bold flex items-center gap-2 text-gray-900">
                        Blocked Users
                        <span className="px-2 py-0.5 rounded-full bg-red-100 text-red-600 text-xs font-bold">
                            {blockedUsers.length}
                        </span>
                    </h1>
                </div>
            </header>

            <div className="h-16" />

            <div className="max-w-xl mx-auto p-4 space-y-6">

                {/* Search */}
                {blockedUsers.length > 0 && (
                    <div className="relative">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                        <input
                            type="text"
                            placeholder="Search blocked users..."
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            className="w-full pl-9 pr-4 py-2 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-red-100"
                        />
                    </div>
                )}

                {loading ? (
                    <div className="space-y-3">
                        {[1, 2, 3].map((i) => (
                            <div key={i} className="flex items-center gap-4 p-4 rounded-xl border border-gray-100 bg-gray-50 animate-pulse">
                                <div className="w-10 h-10 rounded-full bg-gray-200" />
                                <div className="flex-1 space-y-2">
                                    <div className="h-4 bg-gray-200 rounded w-1/3" />
                                </div>
                            </div>
                        ))}
                    </div>
                ) : blockedUsers.length === 0 ? (
                    <div className="flex flex-col items-center justify-center py-20 text-center text-gray-500">
                        <div className="w-20 h-20 bg-gray-50 rounded-full flex items-center justify-center mb-4">
                            <CheckCircle className="w-8 h-8 text-green-500" />
                        </div>
                        <h3 className="text-lg font-bold text-gray-900">No Blocked Users</h3>
                        <p className="text-sm mt-1">You haven't blocked anyone yet.</p>
                    </div>
                ) : (
                    <div className="space-y-2">
                        {filteredUsers.map(user => (
                            <div key={user._id} className="flex items-center justify-between p-4 bg-white border border-gray-100 rounded-xl shadow-sm">
                                <div className="flex items-center gap-3">
                                    <Avatar className="w-10 h-10 border border-gray-100">
                                        <AvatarImage src={user.profilePhoto} className="object-cover" />
                                        <AvatarFallback>{user.displayName[0]}</AvatarFallback>
                                    </Avatar>
                                    <div>
                                        <h3 className="font-bold text-gray-900 text-sm">{user.displayName}</h3>
                                    </div>
                                </div>
                                <Button
                                    variant="outline"
                                    size="sm"
                                    onClick={() => handleUnblock(user.username)}
                                    className="text-red-600 border-red-100 hover:bg-red-50 hover:text-red-700 h-8 text-xs font-medium"
                                >
                                    Unblock
                                </Button>
                            </div>
                        ))}
                        {filteredUsers.length === 0 && searchQuery && (
                            <p className="text-center text-gray-500 py-8">No results found.</p>
                        )}
                    </div>
                )}
            </div>

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
