'use client';

import React, { createContext, useContext, useState, useCallback } from 'react';
import { X, CheckCircle, AlertCircle, Info } from 'lucide-react';

type ToastType = 'success' | 'error' | 'info' | 'warning';

interface Toast {
    id: string;
    message: string;
    type: ToastType;
    action?: () => void;
}

interface ToastContextType {
    addToast: (message: string, type?: ToastType, action?: () => void) => void;
}

const ToastContext = createContext<ToastContextType | undefined>(undefined);

export function ToastProvider({ children }: { children: React.ReactNode }) {
    const [toasts, setToasts] = useState<Toast[]>([]);

    const addToast = useCallback((message: string, type: ToastType = 'info', action?: () => void) => {
        const id = Math.random().toString(36).substring(2, 9);
        setToasts((prev) => [...prev, { id, message, type, action }]);
        setTimeout(() => {
            removeToast(id);
        }, 3000);
    }, []);

    const removeToast = useCallback((id: string) => {
        setToasts((prev) => prev.filter((toast) => toast.id !== id));
    }, []);

    return (
        <ToastContext.Provider value={{ addToast }}>
            {children}
            <div className="fixed bottom-4 right-4 z-[9999] flex flex-col gap-2">
                {toasts.map((toast) => (
                    <div
                        key={toast.id}
                        className={`flex items-center gap-2 px-4 py-3 rounded-lg shadow-lg text-white transform transition-all duration-300 animate-in slide-in-from-right-full ${toast.type === 'success' ? 'bg-green-600' :
                            toast.type === 'error' ? 'bg-red-600' :
                                toast.type === 'warning' ? 'bg-yellow-600' :
                                    'bg-blue-600'
                            } ${toast.action ? 'cursor-pointer hover:opacity-90' : ''}`}
                        onClick={() => {
                            if (toast.action) toast.action();
                            removeToast(toast.id);
                        }}
                    >
                        {toast.type === 'success' && <CheckCircle size={18} />}
                        {toast.type === 'error' && <AlertCircle size={18} />}
                        {toast.type === 'warning' && <AlertCircle size={18} />}
                        {toast.type === 'info' && <Info size={18} />}
                        <span className="text-sm font-medium">{toast.message}</span>
                        <button
                            className="ml-2 hover:opacity-80 p-1"
                            onClick={(e) => {
                                e.stopPropagation();
                                removeToast(toast.id);
                            }}
                        >
                            <X size={14} />
                        </button>
                    </div>
                ))}
            </div>
        </ToastContext.Provider>
    );
}

export function useToast() {
    const context = useContext(ToastContext);
    if (context === undefined) {
        throw new Error('useToast must be used within a ToastProvider');
    }
    return context;
}
