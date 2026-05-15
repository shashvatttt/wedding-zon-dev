import { X, ChevronRight, UserCog, BookUser, Users, ShieldCheck, HelpCircle, Smartphone, LogOut, Trash2 } from 'lucide-react';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import Link from 'next/link';
import api from '@/app/services/api';
import { useRouter } from 'next/navigation';
import { useState } from 'react';

import { useAuth } from '@/app/context/AuthContext';

import { motion, AnimatePresence } from 'framer-motion';

interface SettingsSidebarProps {
    isOpen: boolean;
    onClose: () => void;
    user: any;
}

export default function SettingsSidebar({ isOpen, onClose, user }: SettingsSidebarProps) {
    const router = useRouter();
    const { logout, deleteAccount } = useAuth();
    const [isDeleting, setIsDeleting] = useState(false);

    if (!user) return null;

    const handleLogout = async () => {
        await logout();
    };

    const handleDeleteAccount = async () => {
        if (window.confirm('Are you sure you want to delete your account? This action cannot be undone.')) {
            setIsDeleting(true);
            try {
                await deleteAccount();
            } catch (error) {
                alert('Failed to delete account. Please try again.');
                setIsDeleting(false);
            }
        }
    };

    const menuItems = [
        { icon: UserCog, label: 'Edit Profile', href: `/${user.username}` },
        { icon: BookUser, label: 'Phonebook', href: '/coming-soon' },
        { icon: Users, label: 'Partner Preferences', href: `/${user.username}?tab=preferences` },
        { icon: ShieldCheck, label: 'Safety & Security', href: '/safety' },
        { icon: HelpCircle, label: 'Help & Support', href: '/support' },
        { icon: Smartphone, label: 'Get The App', href: '/app' },
    ];

    const fullMenu = [
        ...menuItems.slice(0, 4),
        { icon: Users, label: 'Astrology', href: '/astrology' },
        ...menuItems.slice(4)
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
                        className="fixed inset-0 bg-black/20 z-40"
                        onClick={onClose}
                    />

                    {/* Sidebar */}
                    <motion.div
                        initial={{ x: '100%' }}
                        animate={{ x: 0 }}
                        exit={{ x: '100%' }}
                        transition={{ type: 'spring', damping: 25, stiffness: 200 }}
                        className="fixed top-0 right-0 h-full w-[300px] bg-white shadow-2xl z-50 flex flex-col"
                    >
                        {/* Header Section */}
                        <div className="p-6 pb-4 flex-1 overflow-y-auto">
                            <div className="flex justify-between items-center mb-6">
                                <h2 className="text-2xl font-bold font-sans">Settings</h2>
                                <button onClick={onClose} className="p-1 hover:bg-gray-100 rounded-full">
                                    <X className="w-6 h-6 text-gray-500" />
                                </button>
                            </div>

                            <div className="flex items-center gap-4 mb-6">
                                <Avatar className="w-16 h-16 border-2 border-white shadow-sm">
                                    <AvatarImage src={user.profilePhoto} className="object-cover" />
                                    <AvatarFallback>{user.first_name?.[0]}</AvatarFallback>
                                </Avatar>
                                <div>
                                    <h3 className="text-xl font-semibold text-gray-900">{user.first_name} {user.last_name}</h3>
                                    <p className="text-sm text-gray-500">{user.city}, {user.country}</p>
                                </div>
                            </div>

                            {/* Upgrade Banner */}
                            <div className="mb-8">
                                <Link href="/coming-soon">
                                    <button className="w-full bg-[#EF2F55] text-white font-semibold py-3 rounded-xl shadow-md hover:bg-pink-700 transition-colors">
                                        Upgrade Membership
                                    </button>
                                </Link>
                                <p className="text-center text-[10px] text-gray-500 mt-2 font-light">
                                    Flat 50% off until 14 feb 2026
                                </p>
                            </div>

                            {/* Menu Items */}
                            <div className="space-y-1">
                                {fullMenu.map((item, index) => (
                                    <Link
                                        key={index}
                                        href={item.href}
                                        className="flex items-center justify-between p-3 rounded-lg hover:bg-gray-50 group transition-colors"
                                    >
                                        <div className="flex items-center gap-4">
                                            <item.icon className="w-5 h-5 text-gray-700 group-hover:text-black" />
                                            <span className="text-base font-medium text-gray-700 group-hover:text-black">
                                                {item.label}
                                            </span>
                                        </div>
                                        <ChevronRight className="w-5 h-5 text-gray-400 group-hover:text-gray-600" />
                                    </Link>
                                ))}
                            </div>
                        </div>

                        {/* Footer Actions */}
                        <div className="p-6 pt-4 border-t border-gray-100 space-y-2">
                            <button
                                onClick={handleLogout}
                                className="w-full flex items-center justify-center gap-2 p-3 text-gray-600 hover:bg-gray-50 rounded-xl transition-colors font-medium border border-gray-100"
                            >
                                <LogOut className="w-5 h-5" />
                                <span>Logout</span>
                            </button>
                            
                            <button
                                onClick={handleDeleteAccount}
                                disabled={isDeleting}
                                className="w-full flex items-center justify-center gap-2 p-3 text-red-600 hover:bg-red-50 rounded-xl transition-colors font-medium text-sm"
                            >
                                <Trash2 className="w-4 h-4" />
                                <span>{isDeleting ? 'Deleting...' : 'Delete Account'}</span>
                            </button>
                        </div>
                    </motion.div>
                </>
            )}
        </AnimatePresence>
    );
}

