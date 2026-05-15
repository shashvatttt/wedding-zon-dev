'use client';

import { useState } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { Heart, MessageCircle, X, Check, Eye, Briefcase, GraduationCap, Circle as Ring } from 'lucide-react';
import { Button } from '@/components/ui/button';
import api from '@/app/services/api';
import { useAuth } from '@/app/context/AuthContext';
import { useToast } from '@/app/contexts/ToastContext';
import { formatLastSeen } from '@/app/utils/formatTime';

interface FeedCardProps {
    user: {
        _id: string;
        first_name?: string;
        last_name?: string;
        username: string;
        profilePhoto: string;
        bio: string;
        photos: { url?: string; _id?: string; restricted?: boolean }[];

        // Demographic fields
        age?: number;
        height?: string;
        city?: string;
        caste?: string;
        religion?: string;
        education?: string;
        occupation?: string;
        income?: string;
        marital_status?: string;
        isOnline?: boolean;
        lastSeen?: string;
    };
    initialConnectionStatus?: 'none' | 'pending' | 'accepted' | 'rejected';
}

// Removed useTransliteration

export default function FeedCard({ user, initialConnectionStatus = 'none' }: FeedCardProps) {
    const { addToast } = useToast();
    const router = useRouter();
    const { user: currentUser } = useAuth();
    const [connectionStatus, setConnectionStatus] = useState(initialConnectionStatus);
    const [isLoading, setIsLoading] = useState(false);

    const isVendorViewer = currentUser?.role === 'vendor';

    // Use real data from user object, with safe fallbacks for display
    const age = user.age || 28;
    const height = user.height || "4ft 11in";
    const location = user.city || "New Delhi";

    // Utility to return value (Google Translate will handle translation)
    const translateData = (category: string, value: string | undefined) => {
        return value || '';
    };

    // Names and City (Google Translate will handle translation)
    const firstName = user.first_name;
    const lastName = user.last_name;
    const city = user.city || "New Delhi";
    const displayName = [firstName, lastName].filter(Boolean).join(' ') || user.username;

    // Construct community string
    let community = translateData('religion', user.religion) || "Bania-Rauniyar";
    if (user.caste && user.caste !== 'No Caste') {
        community = user.caste;
    }

    const education = user.education || "MBA/PGDM, LLB";
    const occupation = user.occupation || "Education Professional";
    const income = user.income || "Rs. 8-10 lakh p.a.";
    const marital = user.marital_status || 'Never Married';

    const handleConnect = async () => {
        if (!currentUser) {
            router.push('/login?redirect=/feed');
            return;
        }
        if (connectionStatus !== 'none') return;
        setIsLoading(true);
        try {
            await api.post('/connections/send', { targetUsername: user.username });
            setConnectionStatus('pending');
            addToast('Request sent successfully', 'success');
        } catch (error: any) {
            addToast(error.response?.data?.message || 'Something went wrong', 'error');
        } finally {
            setIsLoading(false);
        }
    };

    const handleCancel = async () => {
        if (!currentUser) {
            router.push('/login?redirect=/feed');
            return;
        }
        setIsLoading(true);
        try {
            await api.post('/connections/cancel', { targetUsername: user.username, type: 'connection' });
            setConnectionStatus('none');
            addToast('Request cancelled', 'info');
        } catch (error: any) {
            addToast(error.response?.data?.message || 'Something went wrong', 'error');
        } finally {
            setIsLoading(false);
        }
    };

    const handleDisconnect = async () => {
        if (!currentUser) {
            router.push('/login?redirect=/feed');
            return;
        }
        setIsLoading(true);
        try {
            await api.delete('/connections/delete', { data: { targetUsername: user.username } });
            setConnectionStatus('none');
            addToast('Disconnected successfully', 'info');
        } catch (error: any) {
            addToast(error.response?.data?.message || 'Something went wrong', 'error');
        } finally {
            setIsLoading(false);
        }
    };

    const handleIgnore = () => {
        if (!currentUser) {
            router.push('/login?redirect=/feed');
            return;
        }
        addToast('Profile ignored', 'info');
    };

    const actionButtonClass = "flex items-center gap-2 px-5 py-2.5 rounded-full transition-all text-gray-900 font-bold text-[15px]";
    const lightPinkBg = "bg-[#FCE4E9] hover:bg-[#FAD1D9]";

    const renderConnectionButton = () => {
        if (connectionStatus === 'accepted') {
            return (
                <button
                    onClick={handleDisconnect}
                    disabled={isLoading}
                    className={`${actionButtonClass} border border-green-200 bg-green-50 text-green-700 hover:bg-red-50 hover:text-red-600 hover:border-red-200 group`}
                >
                    <Check className="w-4 h-4 group-hover:hidden" />
                    <X className="w-4 h-4 hidden group-hover:block" />
                    <span className="group-hover:hidden">Connected</span>
                    <span className="hidden group-hover:inline">Disconnect</span>
                </button>
            );
        }

        if (connectionStatus === 'pending') {
            return (
                <button
                    onClick={handleCancel}
                    disabled={isLoading}
                    className={`${actionButtonClass} border border-pink-200 bg-pink-50 text-pink-600 hover:bg-red-50 hover:text-red-600 hover:border-red-200 group`}
                >
                    <span className="group-hover:hidden">Request Sent</span>
                    <X className="w-4 h-4 hidden group-hover:block" />
                    <span className="hidden group-hover:inline">Cancel</span>
                </button>
            );
        }

        return (
            <button
                onClick={handleConnect}
                disabled={isLoading}
                className={`${actionButtonClass} ${lightPinkBg}`}
            >
                <Heart className="w-[18px] h-[18px] text-[#EF2F55] stroke-[2.5px]" />
                <span>Like Profile</span>
            </button>
        );
    };

    return (
        <div className="bg-white rounded-[32px] border border-gray-50 shadow-[0_10px_30px_rgba(0,0,0,0.04)] p-5 mb-6 flex flex-col md:flex-row gap-8 transition-all duration-300 hover:shadow-[0_20px_40px_rgba(0,0,0,0.08)] hover:-translate-y-1 overflow-hidden relative group/card">
            {/* Image Section */}
            <div className="w-full md:w-[280px] aspect-[4/3] md:h-[210px] relative shrink-0 rounded-[24px] overflow-hidden bg-gray-50 border border-gray-100/50">
                <Image
                    src={user.profilePhoto || '/default-avatar.png'}
                    alt={firstName || 'User'}
                    fill
                    className="object-cover transition-transform duration-700 group-hover/card:scale-110"
                />
            </div>

            {/* Details Section */}
            <div className="flex-1 flex flex-col justify-between py-1">
                <div className="space-y-3">
                    <div className="flex items-baseline gap-3">
                        <Link href={`/${user.username}`} className="hover:text-[#EF2F55] transition-colors">
                            <h3 className="font-bold text-[34px] text-gray-900 leading-tight tracking-tight">
                                {displayName}{age ? `, ${age}` : ''}
                            </h3>
                        </Link>
                        <span className={`italic text-[15px] font-medium opacity-90 ${user.isOnline ? 'text-green-600' : 'text-[#EF2F55]'}`}>
                            {user.isOnline ? "Online Now" : (
                                user.lastSeen ? `Active ${formatLastSeen(user.lastSeen)}` : ''
                            )}
                        </span>
                    </div>

                    <div className="text-gray-500 font-medium text-[17px] tracking-wide">
                        {[height, city, community].filter(Boolean).join(' • ')}
                    </div>

                    <div className="space-y-1.5 pt-1">
                        <div className="flex items-center gap-3 text-gray-700 font-medium text-[16px]">
                            <Briefcase className="w-[18px] h-[18px] text-gray-600 stroke-[2px]" />
                            <span className="opacity-85">{[occupation, income].filter(Boolean).join(' • ')}</span>
                        </div>
                        <div className="flex items-center gap-6">
                            <div className="flex items-center gap-3 text-gray-700 font-medium text-[16px]">
                                <GraduationCap className="w-[20px] h-[20px] text-gray-600 stroke-[2px]" />
                                <span className="opacity-85">{education}</span>
                            </div>
                            <div className="flex items-center gap-3 text-gray-700 font-medium text-[16px]">
                                <Ring className="w-[18px] h-[18px] text-gray-600 stroke-[2px]" />
                                <span className="opacity-85">{marital}</span>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Actions Row */}
                <div className="flex flex-wrap items-center justify-between gap-4 mt-6">
                    <div className="flex flex-wrap items-center gap-2 md:gap-3 w-full md:w-auto">
                        {!isVendorViewer && (
                            <>
                                {renderConnectionButton()}

                                <button
                                    onClick={handleIgnore}
                                    className={`${actionButtonClass} ${lightPinkBg} px-3 md:px-5`}
                                >
                                    <X className="w-[18px] h-[18px] stroke-[2.5px]" />
                                    <span className="hidden sm:inline">Ignore</span>
                                </button>

                                <Link href={`/chats?start_chat=${user._id}`} className="flex-1 md:flex-none">
                                    <button className={`${actionButtonClass} ${lightPinkBg} w-full justify-center px-3 md:px-5`}>
                                        <MessageCircle className="w-[18px] h-[18px] stroke-[2.5px]" />
                                        <span className="hidden sm:inline">Chat Now</span>
                                        <span className="sm:hidden">Chat Now</span>
                                    </button>
                                </Link>
                            </>
                        )}
                    </div>

                    <Link href={`/${user.username}`} className="w-full md:w-auto">
                        <Button className="w-full md:w-auto bg-[#EF2F55] hover:bg-[#D41F45] text-white rounded-xl px-4 md:px-8 py-4 md:py-6 text-[16px] md:text-[18px] font-bold shadow-lg shadow-pink-100 transition-all active:scale-95">
                            View Profile
                        </Button>
                    </Link>
                </div>
            </div>
        </div>
    );
}
