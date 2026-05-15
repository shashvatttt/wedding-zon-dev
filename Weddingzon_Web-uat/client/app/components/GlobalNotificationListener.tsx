'use client';

import { useEffect } from 'react';
import { useSocket } from '../context/SocketContext';
import { useToast } from '../contexts/ToastContext';
import { useRouter } from 'next/navigation';

export default function GlobalNotificationListener() {
    const { socket } = useSocket();
    const { addToast } = useToast();

    const router = useRouter(); // Requires import

    useEffect(() => {
        if (!socket) return;

        const handleNewRequest = (newReq: any) => {
            console.log('Global Realtime Request:', newReq);
            const name = newReq.requester?.first_name || newReq.requester?.username || 'Someone';
            addToast(`New Request from ${name}`, 'info', () => router.push('/requests'));
        };

        const handleNotification = (newNotif: any) => {
            console.log('Global Realtime Notification:', newNotif);
            const name = newNotif.otherUser?.first_name || newNotif.otherUser?.username || 'Someone';
            addToast(`Request Accepted by ${name}`, 'success', () => router.push('/requests'));
        };

        const handleNewMessage = (msg: any) => {
            console.log('Global Realtime Message:', msg);
            const senderName = msg.sender?.first_name || msg.sender?.username || 'Someone';
            const senderId = msg.sender?._id;
            addToast(`New Message from ${senderName}`, 'info', () => router.push(`/feed?chatId=${senderId}`));
        };

        const handleProfileView = (data: any) => {
            console.log('Global Realtime View:', data);
            const name = data.viewer?.first_name || data.viewer?.username || 'Someone';
            const username = data.viewer?.username;
            if (username) {
                addToast(`${name} viewed your profile`, 'info', () => router.push(`/${username}`));
            } else {
                addToast(`${name} viewed your profile`, 'info', () => router.push('/profile/viewers'));
            }
        };

        socket.on('new_request', handleNewRequest);
        socket.on('notification', handleNotification);
        socket.on('receive_message', handleNewMessage);
        socket.on('profile_view', handleProfileView);

        return () => {
            socket.off('new_request', handleNewRequest);
            socket.off('notification', handleNotification);
            socket.off('receive_message', handleNewMessage);
            socket.off('profile_view', handleProfileView);
        };
    }, [socket, addToast]);

    return null; // This component renders nothing, just handles side effects
}
