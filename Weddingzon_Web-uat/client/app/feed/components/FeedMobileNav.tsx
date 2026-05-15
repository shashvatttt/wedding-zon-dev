'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import Link from 'next/link';
import { X, User, Search, MessageSquare, Star, ChevronRight, Home, LayoutGrid, ShoppingBag, Briefcase, Menu } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useAuth } from '@/app/context/AuthContext';
import { calculateProfileCompletion } from '@/lib/profileCompletion';
import Image from 'next/image';

interface FeedMobileNavProps {
    isOpen: boolean;
    onClose: () => void;
    user: any;
}

export default function FeedMobileNav({ isOpen, onClose, user }: FeedMobileNavProps) {
    const { logout } = useAuth();

    // Prevent body scroll when menu is open
    useEffect(() => {
        if (isOpen) {
            document.body.style.overflow = 'hidden';
        } else {
            document.body.style.overflow = 'unset';
        }
        return () => {
            document.body.style.overflow = 'unset';
        };
    }, [isOpen]);

    const profilePhoto = user?.profilePhoto || `https://ui-avatars.com/api/?name=${user?.first_name || "User"}&background=random`;
    const completionPercentage = user ? calculateProfileCompletion(user) : 0;

    const navLinks = [
        { href: '/', label: "Home", icon: Home },
        { href: user ? "/feed" : "/matrimony", label: "Matrimony", icon: LayoutGrid },
        { href: '/services', label: "Services", icon: Briefcase },
        { href: '/shop', label: "Shopping", icon: ShoppingBag },
    ];

    const sidebarLinks = [
        { href: '/onboarding', label: "Complete Profile", icon: User },
        { href: '/feed', label: "Matches", icon: User },
        { href: '/explore', label: "Search", icon: Search },
        { href: '/chats', label: "Chats", icon: MessageSquare },
        { href: '/coming-soon', label: "Upgrade", icon: Star },
    ];

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
                        className="fixed inset-0 bg-black/50 z-[60] backdrop-blur-sm lg:hidden"
                    />

                    {/* Drawer */}
                    <motion.div
                        initial={{ x: '-100%' }}
                        animate={{ x: 0 }}
                        exit={{ x: '-100%' }}
                        transition={{ type: 'spring', damping: 25, stiffness: 200 }}
                        className="fixed top-0 left-0 bottom-0 w-[85%] max-w-[300px] bg-white z-[70] shadow-xl overflow-y-auto lg:hidden"
                    >
                        {/* Header */}
                        <div className="p-4 border-b border-gray-100 flex items-center justify-between">
                            <span className="font-bold text-lg text-[#EF2F55]">Menu</span>
                            <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-full">
                                <X className="w-6 h-6 text-gray-500" />
                            </button>
                        </div>

                        {/* User Profile Summary */}
                        {user && (
                            <div className="p-4 bg-rose-50/50 border-b border-rose-100">
                                <div className="flex items-center gap-3 mb-3">
                                    <div className="relative w-12 h-12 rounded-full overflow-hidden border-2 border-white shadow-sm shrink-0">
                                        <Image src={profilePhoto} alt="Profile Photo" fill className="object-cover" />
                                    </div>
                                    <div className="min-w-0">
                                        <h3 className="font-bold text-gray-900 truncate">
                                            {([user.first_name, user.last_name].filter(Boolean).join(' ') || user.username)}
                                        </h3>
                                        <p className="text-xs text-gray-500 truncate">{user.email}</p>
                                    </div>
                                </div>
                                <div className="flex items-center gap-2">
                                    <div className="flex-1 h-1.5 bg-rose-200 rounded-full overflow-hidden">
                                        <div className="h-full bg-[#EF2F55]" style={{ width: `${completionPercentage}%` }} />
                                    </div>
                                    <span className="text-xs font-bold text-[#EF2F55]">{completionPercentage}%</span>
                                </div>
                            </div>
                        )}

                        {/* Main Navigation */}
                        <div className="p-4 space-y-1">
                            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2 px-2">NAVIGATION</p>
                            {navLinks.map((link) => (
                                <Link
                                    key={link.href}
                                    href={link.href}
                                    onClick={onClose}
                                    className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-gray-700 hover:bg-rose-50 hover:text-[#EF2F55] transition-colors font-medium"
                                >
                                    <link.icon className="w-5 h-5" />
                                    {link.label}
                                </Link>
                            ))}
                        </div>

                        {/* Dashboard Links (Matches, etc.) */}
                        <div className="p-4 space-y-1 border-t border-gray-100">
                            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2 px-2">DASHBOARD</p>
                            {sidebarLinks.map((link) => (
                                <Link
                                    key={link.href}
                                    href={link.href}
                                    onClick={onClose}
                                    className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-gray-700 hover:bg-rose-50 hover:text-[#EF2F55] transition-colors font-medium"
                                >
                                    <link.icon className="w-5 h-5" />
                                    {link.label}
                                </Link>
                            ))}
                        </div>

                        <div className="p-4 border-t border-gray-100">
                            <Button
                                variant="outline"
                                className="w-full justify-start text-red-600 hover:bg-red-50 hover:text-red-700 border-red-100"
                                onClick={() => {
                                    logout();
                                    onClose();
                                }}
                            >
                                Sign Out
                            </Button>
                        </div>

                    </motion.div>
                </>
            )}
        </AnimatePresence>
    );
}

