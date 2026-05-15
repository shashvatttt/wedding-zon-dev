'use client';

import { useEffect, useState } from 'react';
import api from '../../services/api';
import { useSocket } from '../../context/SocketContext';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Loader2, Check, Store } from 'lucide-react';
import { formatLastSeen } from '@/app/utils/formatTime';
import { useToast } from '../../contexts/ToastContext';

interface Conversation {
    _id: string; // User ID
    username: string;
    first_name: string;
    last_name: string;
    profilePhoto: string;
    lastMessage: string;
    lastMessageAt: string;
    unreadCount: number;
    isOnline?: boolean;
    lastSeen?: string;
}

interface ThreadListProps {
    onSelectUser: (user: Conversation) => void;
    activeUserId: string | null;
    hideVendorFeatures?: boolean;
}

export default function ThreadList({ onSelectUser, activeUserId, hideVendorFeatures = false }: ThreadListProps) {
    const [userConversations, setUserConversations] = useState<any[]>([]);
    const [vendorConversations, setVendorConversations] = useState<any[]>([]);
    const [matches, setMatches] = useState<any[]>([]);
    const [requests, setRequests] = useState<any[]>([]);
    const [notifications, setNotifications] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [activeTab, setActiveTab] = useState<'chats' | 'vendor_chats' | 'requests' | 'interests'>('chats');
    const { addToast } = useToast();
    const { socket } = useSocket();

    useEffect(() => {
        const fetchData = async () => {
            setLoading(true);

            // 1. Fetch User Conversations
            try {
                const userConvRes = await api.get('/chat/conversations?role=user');
                setUserConversations(userConvRes.data.data);
            } catch (error) {
                console.error('Failed to fetch user conversations', error);
            }

            // 2. Fetch Vendor Conversations
            try {
                const vendorConvRes = await api.get('/chat/conversations?role=vendor');
                setVendorConversations(vendorConvRes.data.data);
            } catch (error) {
                console.error('Failed to fetch vendor conversations', error);
            }

            // 3. Fetch Matches (Accepted Connections)
            try {
                const matchRes = await api.get('/connections/my-connections');
                if (matchRes.data.success) {
                    setMatches(matchRes.data.data);
                }
            } catch (error) {
                console.error('Failed to fetch matches', error);
            }

            // 4. Fetch All Requests
            try {
                const reqRes = await api.get('/connections/requests');
                if (reqRes.data.success) {
                    setRequests(reqRes.data.data);
                }
            } catch (error) {
                console.error('Failed to fetch requests', error);
            }

            // 5. Fetch Notifications
            try {
                const notifRes = await api.get('/connections/notifications');
                if (notifRes.data.success) {
                    setNotifications(notifRes.data.data);
                }
            } catch (error) {
                console.error('Failed to fetch notifications', error);
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    // Socket Listener for Status (Update both lists)
    useEffect(() => {
        if (!socket) return;

        const handleStatus = ({ userId, status, lastSeen }: { userId: string, status: string, lastSeen?: string }) => {
            const updateList = (list: any[]) => list.map(conv => {
                // Check against _id (for conversations) or otherUser._id (for matches/notifications sometimes)
                // However, our lists in state are slightly different structures.
                // Conversations: item is User object directly (populated)
                // Matches: item is Connection object with 'otherUser' populated

                // Case 1: Direct User Object (Conversations)
                if (conv._id === userId) {
                    return { ...conv, isOnline: status === 'online', lastSeen: lastSeen || conv.lastSeen };
                }

                // Case 2: Connection Object (Matches)
                if (conv.otherUser && conv.otherUser._id === userId) {
                    return {
                        ...conv,
                        otherUser: {
                            ...conv.otherUser,
                            isOnline: status === 'online',
                            lastSeen: lastSeen || conv.otherUser.lastSeen
                        }
                    };
                }

                return conv;
            });

            setUserConversations(prev => updateList(prev));
            setVendorConversations(prev => updateList(prev));
            setMatches(prev => updateList(prev));
        };

        socket.on('user_status', handleStatus);
        return () => {
            socket.off('user_status', handleStatus);
        };
    }, [socket]);

    const handleAction = async (e: React.MouseEvent, item: any, action: 'accept' | 'reject') => {
        e.stopPropagation();
        try {
            if (item.type === 'connection') {
                const endpoint = action === 'accept' ? '/connections/accept' : '/connections/reject';
                await api.post(endpoint, { requestId: item._id });
            } else if (item.type === 'photo') {
                await api.post('/connections/respond-photo', {
                    requestId: item._id,
                    action: action === 'accept' ? 'grant' : 'reject'
                });
            } else if (item.type === 'details') {
                await api.post('/connections/respond-details', {
                    requestId: item._id,
                    action: action === 'accept' ? 'grant' : 'reject'
                });
            }

            // Remove from requests list
            setRequests(prev => prev.filter(req => req._id !== item._id));
            addToast(`Request ${action === 'accept' ? 'accepted' : 'rejected'}`, 'success');

            // If accepted, add to matches (if it was a connection request)
            if (action === 'accept' && item.type === 'connection') {
                const matchRes = await api.get('/connections/my-connections');
                if (matchRes.data.success) {
                    setMatches(matchRes.data.data);
                }
            }
        } catch (error: any) {
            console.error(`Failed to ${action} request`, error);
            addToast(error.response?.data?.message || `Failed to ${action} request`, 'error');
        }
    };

    // ... loading check stays same ...

    const getData = () => {
        if (activeTab === 'chats') {
            // User Chats + Matches that are NOT vendors and not in conversation yet
            // Matches returns everyone. We should filter matches by role too if possible, but connection API doesn't return role strictly? 
            // Actually `my-connections` returns otherUser which has fields. If 'role' is not in populate, we might miss it.
            // Let's assume matches are mostly users for now.

            // To be safe, we merge Matches into 'chats' only if they aren't already in userConversations
            const chatIds = new Set(userConversations.map(c => c._id));
            const distinctMatches = matches.filter(m => !chatIds.has(m._id));
            return [...userConversations, ...distinctMatches];
        }

        if (activeTab === 'vendor_chats') {
            return vendorConversations;
        }

        if (activeTab === 'requests') {
            return requests;
        }

        if (activeTab === 'interests') {
            return notifications;
        }

        return [];
    };

    // ... sort logic stays same ...

    return (
        <div className="flex flex-col h-full bg-white rounded-l-3xl shadow-sm border-r border-gray-100 overflow-hidden">
            <div className="p-6 pb-2">
                <div className="flex items-center justify-between mb-4">
                    <h2 className="text-2xl font-bold text-black">My Conversations</h2>
                    {!hideVendorFeatures && (
                        <button
                            onClick={() => setActiveTab('vendor_chats')}
                            className={`flex items-center gap-2 px-3 py-1.5 rounded-full text-xs font-bold transition-all ${activeTab === 'vendor_chats'
                                ? 'bg-[#EF2F55] text-white shadow-md'
                                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                                }`}
                            title="Vendor Chats"
                        >
                            <Store className="w-3.5 h-3.5" />
                            <span>Vendor Chats</span>
                        </button>
                    )}
                </div>

                {/* Tabs - Scrollable if needed */}
                <div className="flex items-center gap-6 border-b border-gray-100 pb-2 mb-4 overflow-x-auto scrollbar-hide">
                    {[
                        { id: 'chats', label: 'Messages' },
                        // { id: 'vendor_chats', label: 'Vendor Chats' }, // REMOVED
                        ...(!hideVendorFeatures ? [
                            { id: 'requests', label: 'Requests' },
                            { id: 'interests', label: 'Interests' }
                        ] : [])
                    ].map((tab) => {
                        const count = tab.id === 'requests'
                            ? requests.length
                            : tab.id === 'interests'
                                ? notifications.length
                                : 0;
                        return (
                            <button
                                key={tab.id}
                                onClick={() => setActiveTab(tab.id as any)}
                                className={`text-sm font-medium capitalize pb-2 -mb-2.5 transition-colors flex items-center gap-1.5 whitespace-nowrap ${activeTab === tab.id
                                    ? 'text-[var(--primary)] border-b-2 border-[var(--primary)]'
                                    : 'text-gray-500 hover:text-gray-800'
                                    }`}
                            >
                                {tab.label}
                                {count > 0 && <span className="bg-gray-100 text-gray-600 text-[10px] px-1.5 py-0.5 rounded-full">{count}</span>}
                            </button>
                        );
                    })}
                </div>
            </div>

            <div className="flex-1 overflow-y-auto px-4 pb-4 space-y-2">
                {getData().length === 0 ? (
                    <div className="flex flex-col items-center justify-center h-40 text-gray-400">
                        <p>No {activeTab} yet</p>
                    </div>
                ) : (
                    getData().map((item: any) => {
                        // Check if it's a Request or a Chat/Match based on current tab
                        const isRequest = activeTab === 'requests';
                        const isInterest = activeTab === 'interests';

                        // - Requests have 'requester' populated.
                        // - Interests (from notifications) have 'otherUser' populated.
                        // - Conversations/Matches are user-like objects.
                        const user = isRequest ? item.requester : (isInterest ? item.otherUser : item);

                        if (!user) return null;

                        // Determine key and selection logic
                        const isActive = activeUserId === user._id;

                        let title = `${user.first_name || ''} ${user.last_name || ''}`.trim() || user.username;
                        let subtitle = '';
                        let timeString = '';

                        if (isInterest) {
                            const date = new Date(item.updatedAt || item.grantedAt || item.createdAt);
                            timeString = date.toLocaleDateString([], { month: 'short', day: 'numeric' });
                            subtitle = item.type === 'connection' ? 'Accepted your interest' : `Accepted ${item.type} access`;
                        } else if (isRequest) {
                            const date = new Date(item.createdAt);
                            timeString = date.toLocaleDateString([], { month: 'short', day: 'numeric' });
                            subtitle = item.type === 'connection' ? 'Sent you an interest' : `Requested ${item.type || 'profile'} access`;
                        } else {
                            // Chat
                            timeString = (item.lastMessageAt || item.createdAt)
                                ? formatLastSeen(item.lastMessageAt || item.createdAt)
                                : '';
                            subtitle = item.lastMessage || 'Connected! Start a conversation 👋';
                        }

                        return (
                            <div
                                key={item._id}
                                onClick={() => (!isRequest && !isInterest) ? onSelectUser(item) : null}
                                className={`flex items-start gap-3 p-3 rounded-xl transition-all ${isActive ? 'bg-pink-50' : 'hover:bg-gray-50'
                                    } ${(!isRequest && !isInterest) ? 'cursor-pointer' : ''}`}
                            >
                                <div className="relative shrink-0">
                                    <Avatar className="w-14 h-14 border border-gray-100">
                                        <AvatarImage src={user.profilePhoto} className="object-cover" />
                                        <AvatarFallback>{user.first_name?.[0]}</AvatarFallback>
                                    </Avatar>
                                    {!isRequest && !isInterest && user.isOnline && (
                                        <span className="absolute bottom-1 right-1 w-3 h-3 bg-green-500 border-2 border-white rounded-full"></span>
                                    )}
                                </div>

                                <div className="flex-1 min-w-0 pt-1">
                                    <div className="flex justify-between items-start mb-0.5">
                                        <h4 className="font-semibold text-gray-900 text-lg leading-tight truncate">
                                            {title}
                                        </h4>
                                        <span className={`text-xs ${(!isRequest && !isInterest) && item.unreadCount > 0 ? 'text-[#EF2F55] font-bold' : 'text-gray-400 font-light'}`}>
                                            {timeString}
                                        </span>
                                    </div>
                                    <div className="flex justify-between items-center">
                                        <p className={`text-sm truncate pr-2 ${(!isRequest && !isInterest) && item.unreadCount > 0 ? 'font-medium text-gray-800' : 'text-gray-500 font-light'}`}>
                                            {subtitle}
                                        </p>

                                        {/* Unread Count for Chats */}
                                        {!isRequest && !isInterest && item.unreadCount > 0 && (
                                            <span className="bg-[#EF2F55] text-white text-[10px] w-5 h-5 flex items-center justify-center rounded-full font-bold shrink-0">
                                                {item.unreadCount}
                                            </span>
                                        )}

                                        {/* Action Buttons for Requests */}
                                        {isRequest && (
                                            <div className="flex gap-2">
                                                <button
                                                    onClick={(e) => handleAction(e, item, 'accept')}
                                                    className="w-8 h-8 rounded-full bg-pink-100 hover:bg-pink-200 flex items-center justify-center text-pink-600 transition-colors"
                                                    title="Accept"
                                                >
                                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12" /></svg>
                                                </button>
                                                <button
                                                    onClick={(e) => handleAction(e, item, 'reject')}
                                                    className="w-8 h-8 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center text-gray-500 transition-colors"
                                                    title="Reject"
                                                >
                                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" /></svg>
                                                </button>
                                            </div>
                                        )}

                                        {/* Action Icon for Interests */}
                                        {isInterest && (
                                            <div className="w-8 h-8 rounded-full bg-blue-50 flex items-center justify-center text-blue-600">
                                                <Check className="w-4 h-4" />
                                            </div>
                                        )}
                                    </div>
                                </div>
                            </div>
                        );
                    })
                )}
            </div>
        </div>
    );
}
