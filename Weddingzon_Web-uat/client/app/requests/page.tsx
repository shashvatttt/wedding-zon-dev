'use client';

import { useEffect, useState } from 'react';
import api from '../services/api';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Avatar, AvatarImage, AvatarFallback } from '@/components/ui/avatar';
import { Card, CardContent } from '@/components/ui/card';
import { ArrowLeft, Check, X, User } from 'lucide-react';
import { useToast } from '../contexts/ToastContext';
import ConfirmationModal from '../../components/ConfirmationModal';

interface Request {
    _id: string;
    requester: {
        _id: string;
        username: string;
        first_name: string;
        last_name: string;
        profilePhoto: string;
        occupation?: string;
        city?: string;
        age?: number;
    };
    type: 'connection' | 'photo' | 'details'; // Added type
    status?: string; // Added status for UI updates
}

import { useSocket } from '../context/SocketContext';

export default function RequestsPage() {
    const router = useRouter();
    const { socket } = useSocket();
    const { addToast } = useToast();
    const [activeTab, setActiveTab] = useState<'requests' | 'interests'>('requests');
    const [notifications, setNotifications] = useState<any[]>([]);

    const [requests, setRequests] = useState<Request[]>([]);
    // const [connections, setConnections] = useState<any[]>([]); // Removed connections
    const [loading, setLoading] = useState(true);

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
        fetchData();
    }, []);

    // Realtime Listeners
    useEffect(() => {
        if (!socket) return;

        const handleNewRequest = (newReq: Request) => {
            console.log('Realtime Request:', newReq);
            setRequests((prev) => [newReq, ...prev]);
        };

        const handleNotification = (newNotif: any) => {
            console.log('Realtime Notification:', newNotif);
            setNotifications((prev) => [newNotif, ...prev]);
        };

        socket.on('new_request', handleNewRequest);
        socket.on('notification', handleNotification);

        return () => {
            socket.off('new_request', handleNewRequest);
            socket.off('notification', handleNotification);
        };
    }, [socket]);

    const fetchData = async () => {
        setLoading(true);
        try {
            const [reqRes, notifRes] = await Promise.all([
                api.get('/connections/requests'),
                api.get('/connections/notifications'),
                // api.get('/connections/my-connections')
            ]);
            setRequests(reqRes.data.data);
            setNotifications(notifRes.data.data);
            // setConnections(connRes.data.data);
        } catch (error) {
            console.error("Failed to fetch data", error);
        } finally {
            setLoading(false);
        }
    };

    const processAction = async (requestId: string, type: string, action: 'accept' | 'reject') => {
        try {
            if (type === 'connection') {
                const endpoint = action === 'accept' ? '/connections/accept' : '/connections/reject';
                await api.post(endpoint, { requestId });
            } else if (type === 'photo') {
                await api.post('/connections/respond-photo', { requestId, action: action === 'accept' ? 'grant' : 'reject' });
            } else if (type === 'details') {
                await api.post('/connections/respond-details', { requestId, action: action === 'accept' ? 'grant' : 'reject' });
            }

            // Update UI
            if (action === 'accept') {
                setRequests(prev => prev.map(req => req._id === requestId ? { ...req, status: 'accepted' } : req));
                addToast('Request accepted', 'success');
            } else {
                setRequests(prev => prev.filter(req => req._id !== requestId));
                addToast('Request rejected', 'info');
            }
        } catch (error) {
            addToast('Failed to process request', 'error');
        }
    };

    const handleAction = (requestId: string, type: string, action: 'accept' | 'reject') => {
        if (action === 'reject') {
            setConfirmModal({
                isOpen: true,
                title: 'Reject Request',
                message: 'Are you sure you want to reject this request?',
                confirmText: 'Reject',
                isDangerous: true,
                onConfirm: async () => {
                    await processAction(requestId, type, action);
                }
            });
        } else {
            processAction(requestId, type, action);
        }
    };

    const getRequestBadge = (type: string) => {
        if (type === 'photo') return <span className="text-xs bg-purple-100 text-purple-700 px-2 py-0.5 rounded-full">Photo Access</span>;
        if (type === 'details') return <span className="text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full">Details Access</span>;
        return <span className="text-xs bg-pink-100 text-pink-700 px-2 py-0.5 rounded-full">Connection</span>;
    };

    return (
        <div className="min-h-screen bg-gray-50 pb-20">
            {/* Header */}
            <div className="bg-white border-b border-gray-200 px-4 py-3 sticky top-0 z-10 flex items-center gap-3">
                <Button variant="ghost" size="icon" onClick={() => router.back()}>
                    <ArrowLeft className="w-5 h-5" />
                </Button>
                <h1 className="text-xl font-bold text-gray-900">Activity</h1>
            </div>

            {/* Tabs */}
            <div className="flex border-b border-gray-200 bg-white">
                <button
                    onClick={() => setActiveTab('requests')}
                    className={`flex-1 py-3 text-sm font-medium border-b-2 transition-colors ${activeTab === 'requests' ? 'border-pink-600 text-pink-600' : 'border-transparent text-gray-500 hover:text-gray-700'}`}
                >
                    Requests ({requests.length})
                </button>
                <button
                    onClick={() => setActiveTab('interests')}
                    className={`flex-1 py-3 text-sm font-medium border-b-2 transition-colors ${activeTab === 'interests' ? 'border-pink-600 text-pink-600' : 'border-transparent text-gray-500 hover:text-gray-700'}`}
                >
                    Interests ({notifications.length})
                </button>
            </div>

            <div className="max-w-md mx-auto p-4 space-y-4">
                {loading ? (
                    <div className="flex justify-center p-8 text-gray-500">Loading...</div>
                ) : activeTab === 'requests' ? (
                    // --- REQUESTS LIST ---
                    requests.length === 0 ? (
                        <div className="text-center p-10 bg-white rounded-xl shadow-sm">
                            <User className="w-12 h-12 mx-auto text-gray-300 mb-3" />
                            <h3 className="text-lg font-medium text-gray-900">No Pending Requests</h3>
                            <p className="text-gray-500 text-sm mt-1">When people want to connect with you, they'll appear here.</p>
                        </div>
                    ) : (
                        requests.map((req) => {
                            if (!req.requester) return null;
                            return (
                                <Card key={req._id} className="overflow-hidden">
                                    <CardContent className="p-4 flex items-center gap-4">
                                        <div
                                            className="cursor-pointer"
                                            onClick={() => router.push(`/${req.requester.username}`)}
                                        >
                                            <Avatar className="w-16 h-16 border-2 border-white shadow-sm">
                                                <AvatarImage src={req.requester.profilePhoto} className="object-cover" />
                                                <AvatarFallback>{req.requester.first_name?.[0]}</AvatarFallback>
                                            </Avatar>
                                        </div>

                                        <div className="flex-1 min-w-0">
                                            <div className="mb-1">{getRequestBadge(req.type)}</div>
                                            <h4
                                                className="font-bold text-gray-900 truncate cursor-pointer hover:underline"
                                                onClick={() => router.push(`/${req.requester.username}`)}
                                            >
                                                {req.requester.first_name} {req.requester.last_name}
                                            </h4>
                                            <p className="text-sm text-gray-500 truncate">
                                                {req.requester.age ? `${req.requester.age} • ` : ''}
                                                {req.requester.occupation || 'Member'}
                                            </p>
                                        </div>

                                        <div className="flex flex-col gap-2">
                                            {req.status === 'accepted' || req.status === 'granted' ? (
                                                <div className="flex items-center gap-1 text-green-600 bg-green-50 px-3 py-1 rounded-full text-sm font-medium">
                                                    <Check className="w-4 h-4" />
                                                    <span>Accepted</span>
                                                </div>
                                            ) : (
                                                <>
                                                    <Button
                                                        size="sm"
                                                        className="bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white shadow-md hover:shadow-lg transition-all duration-300 rounded-full h-8 w-8 p-0 sm:w-auto sm:px-6 sm:h-9 font-semibold"
                                                        onClick={() => handleAction(req._id, req.type, 'accept')}
                                                        title="Accept"
                                                    >
                                                        <Check className="w-4 h-4 sm:mr-1" />
                                                        <span className="hidden sm:inline">Accept</span>
                                                    </Button>
                                                    <Button
                                                        size="sm"
                                                        variant="outline"
                                                        className="text-gray-500 hover:text-red-500 hover:bg-red-50 rounded-full h-8 w-8 p-0 sm:w-auto sm:px-4 sm:h-9"
                                                        onClick={() => handleAction(req._id, req.type, 'reject')}
                                                        title="Reject"
                                                    >
                                                        <X className="w-4 h-4 sm:mr-1" />
                                                        <span className="hidden sm:inline">Reject</span>
                                                    </Button>
                                                </>
                                            )}
                                        </div>
                                    </CardContent>
                                </Card>
                            );
                        })
                    )
                ) : (
                    // --- INTERESTS LIST ---
                    notifications.length === 0 ? (
                        <div className="text-center p-10 bg-white rounded-xl shadow-sm">
                            <Check className="w-12 h-12 mx-auto text-gray-300 mb-3" />
                            <h3 className="text-lg font-medium text-gray-900">No Interests Yet</h3>
                            <p className="text-gray-500 text-sm mt-1">Accepted requests will appear here.</p>
                        </div>
                    ) : (
                        notifications.map((notif) => {
                            if (!notif.otherUser) return null;
                            const isNew = false; // Could check 'read' status if implemented
                            return (
                                <Card key={notif._id} className={`overflow-hidden ${isNew ? 'bg-blue-50/50' : 'bg-white'}`}>
                                    <CardContent className="p-4 flex items-center gap-4">
                                        <div
                                            className="cursor-pointer"
                                            onClick={() => router.push(`/${notif.otherUser.username}`)}
                                        >
                                            <Avatar className="w-14 h-14 border border-gray-100 shadow-sm">
                                                <AvatarImage src={notif.otherUser.profilePhoto} className="object-cover" />
                                                <AvatarFallback>{notif.otherUser.first_name?.[0]}</AvatarFallback>
                                            </Avatar>
                                        </div>
                                        <div className="flex-1">
                                            <p className="text-sm text-gray-800">
                                                <span className="font-bold cursor-pointer hover:underline" onClick={() => router.push(`/${notif.otherUser.username}`)}>
                                                    {notif.otherUser.first_name} {notif.otherUser.last_name}
                                                </span>
                                                <span className="text-gray-600"> accepted your </span>
                                                <span className="font-medium text-gray-900">
                                                    {notif.type === 'connection' ? 'Connection Request' :
                                                        notif.type === 'photo' ? 'Photo Access Request' : 'Details Request'}
                                                </span>
                                            </p>
                                            <p className="text-xs text-gray-400 mt-1">
                                                {new Date(notif.updatedAt || notif.grantedAt || notif.createdAt).toLocaleDateString()}
                                            </p>
                                        </div>
                                        <div>
                                            {/* Action based on type? e.g. View Profile or Chat */}
                                            <Button variant="ghost" size="icon" onClick={() => router.push(`/${notif.otherUser.username}`)}>
                                                <ArrowLeft className="w-4 h-4 rotate-180 text-gray-400" />
                                            </Button>
                                        </div>
                                    </CardContent>
                                </Card>
                            )
                        })
                    )
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
