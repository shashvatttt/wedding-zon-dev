'use client';

import { GoogleOAuthProvider } from '@react-oauth/google';
import { SocketProvider } from './context/SocketContext';
import { AuthProvider } from './context/AuthContext';

import { CartProvider } from "./context/CartContext";
import CartSidebar from "@/components/CartSidebar";

import { LanguageProvider } from './context/LanguageContext';
import GoogleTranslateScript from '@/components/GoogleTranslateScript';

export function Providers({ children }: { children: React.ReactNode }) {
    const clientId = process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID || '';

    if (!clientId) {
        console.error('Google Client ID is missing');
    }

    return (
        <GoogleOAuthProvider clientId={clientId}>
            <LanguageProvider>
                <AuthProvider>
                    <SocketProvider>
                        <CartProvider>
                            <GoogleTranslateScript />
                            {children}
                            <CartSidebar />
                        </CartProvider>
                    </SocketProvider>
                </AuthProvider>
            </LanguageProvider>
        </GoogleOAuthProvider>
    );
}
