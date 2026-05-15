'use client';
import React, { createContext, useContext, useEffect, useState } from 'react';
import { io, Socket } from 'socket.io-client';

interface SocketContextType {
    socket: Socket | null;
    isConnected: boolean;
}

const SocketContext = createContext<SocketContextType>({
    socket: null,
    isConnected: false,
});

export const useSocket = () => useContext(SocketContext);

export const SocketProvider = ({ children }: { children: React.ReactNode }) => {
    const [socket, setSocket] = useState<Socket | null>(null);
    const [isConnected, setIsConnected] = useState(false);

    useEffect(() => {
        // Determine correct URL (remove /api if present)
        // Determine correct URL
        let url = process.env.NEXT_PUBLIC_API_URL;

        if (!url) {
            if (typeof window !== 'undefined') {
                // Infer backend from current hostname
                // Assumes backend is on same host but port 5000
                url = `${window.location.protocol}//${window.location.hostname}:5000`;
            } else {
                url = 'http://localhost:5000';
            }
        }

        // Remove /api suffix if present (Socket.io needs base URL)
        if (url.endsWith('/api')) {
            url = url.slice(0, -4);
        }

        console.log('Initializing Socket.io with URL:', url);

        // Initialize socket connection
        const socketInstance = io(url, {
            path: '/socket.io/', // Explicitly set default path to be safe
            withCredentials: true,
            autoConnect: false,
            reconnection: true,
            reconnectionAttempts: 5,
            transports: ['websocket', 'polling'], // Try websocket first
        });

        const connectWithToken = () => {
            if (typeof window === 'undefined') return;
            const token = localStorage.getItem('token');
            if (token) {
                console.log('Connecting socket with token...');
                socketInstance.auth = { token };
                socketInstance.connect();
            } else {
                console.log('No token found for socket connection');
            }
        };

        // Try connecting immediately
        connectWithToken();

        socketInstance.on('connect', () => {
            console.log('Socket Connected:', socketInstance.id);
            setIsConnected(true);
        });

        socketInstance.on('connect_error', (err) => {
            console.error('Socket Connection Error:', err.message);
            setIsConnected(false);

            if (err.message === 'Authentication error' || err.message === 'User not found') {
                console.warn('Socket Auth Failed. Clearing invalid token...');
                localStorage.removeItem('token');
                socketInstance.disconnect();
                // Optionally notify app to logout or refresh
                // window.dispatchEvent(new Event('auth-change'));
            }
        });

        socketInstance.on('disconnect', (reason) => {
            console.log('Socket Disconnected:', reason);
            setIsConnected(false);
        });

        setSocket(socketInstance);

        // Listen for storage events (login/logout in other tabs) to reconnect
        const handleStorageChange = () => {
            connectWithToken();
        };
        window.addEventListener('storage', handleStorageChange);

        // Listen for custom auth-change events (login/refresh in same tab)
        const handleAuthChange = () => {
            console.log('Auth change detected, reconnecting socket...');
            if (socketInstance.connected) {
                socketInstance.disconnect();
            }
            connectWithToken();
        };
        window.addEventListener('auth-change', handleAuthChange);

        return () => {
            socketInstance.disconnect();
            window.removeEventListener('storage', handleStorageChange);
            window.removeEventListener('auth-change', handleAuthChange);
        };
    }, []);

    // Also watch for manual login (e.g. if we set token programmatically)
    // We can't easily watch localStorage directly without custom event, 
    // but we can expose a 'reconnect' function in context if needed.
    // For now, reliance on mount + reload is standard.

    return (
        <SocketContext.Provider value={{ socket, isConnected }}>
            {children}
        </SocketContext.Provider>
    );
};
