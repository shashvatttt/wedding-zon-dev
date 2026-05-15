'use client';

import Link from 'next/link';
import Image from 'next/image';
import { User, Search, MessageSquare, Star, ChevronRight, PenSquare } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { calculateProfileCompletion } from '@/lib/profileCompletion';

interface FeedSidebarProps {
    user: any;
    activePage?: 'matches' | 'search' | 'chats' | 'upgrade';
    onlineCount?: number;
}

export default function FeedSidebar({ user, activePage = 'matches', onlineCount = 0 }: FeedSidebarProps) {
    if (!user || user.role === 'vendor') return null;

    const profilePhoto = user.profilePhoto || `https://ui-avatars.com/api/?name=${user.first_name || "User"}&background=random`;
    const completionPercentage = calculateProfileCompletion(user);


    // Helper to get helper classes
    const getLinkClasses = (page: string) => {
        const isActive = activePage === page;
        return `flex items-center justify-between group hover:text-[#EF2F55] transition-colors ${isActive ? 'text-[#EF2F55] font-bold' : 'text-gray-800 font-medium'}`;
    };

    return (
        <div className="flex flex-col gap-6 w-[250px]">
            {/* Profile Card */}
            <div className="bg-white rounded-3xl shadow-[0px_0px_10px_rgba(0,0,0,0.1)] p-5 relative overflow-hidden">
                {/* Header Section */}
                <div className="flex items-center gap-4 mb-5">
                    <div className="relative w-16 h-16 shrink-0">
                        {/* Dynamic SVG Progress Ring */}
                        <svg className="absolute inset-0 w-full h-full -rotate-90 scale-[1.15]">
                            <circle
                                cx="32"
                                cy="32"
                                r="30"
                                fill="transparent"
                                stroke="#f3f4f6"
                                strokeWidth="2"
                            />
                            <circle
                                cx="32"
                                cy="32"
                                r="30"
                                fill="transparent"
                                stroke="#EF2F55"
                                strokeWidth="2"
                                strokeDasharray={2 * Math.PI * 30}
                                strokeDashoffset={2 * Math.PI * 30 - (completionPercentage / 100) * (2 * Math.PI * 30)}
                                style={{ transition: 'stroke-dashoffset 1s ease-in-out' }}
                                strokeLinecap="round"
                            />
                        </svg>
                        <div className="relative w-full h-full rounded-full overflow-hidden border-2 border-white shadow-sm">
                            <Image src={profilePhoto} alt="Profile Photo" fill className="object-cover" />
                        </div>
                    </div>
                    <div className="flex flex-col min-w-0 flex-1">
                        <h3 className="font-bold text-xl text-black leading-tight">
                            <span>{([user.first_name, user.last_name].filter(Boolean).join(' ') || user.username) === 'Arsh Prabhat' ? "Demo User" : ([user.first_name, user.last_name].filter(Boolean).join(' ') || user.username)}</span>
                            <Link href={`/${user.username}`} className="inline-flex items-center ml-2 align-middle">
                                <PenSquare className="w-4 h-4 text-[#EF2F55] hover:opacity-80 transition-opacity" />
                            </Link>
                        </h3>
                        <p className="text-sm text-gray-900 font-medium">
                            {user.city || "Delhi"}, {user.country || "India"}
                        </p>
                    </div>
                </div>

                {/* Progress Bar Section */}
                <div className="mb-6">
                    <div className="flex items-center gap-3">
                        <div className="h-1.5 flex-1 bg-pink-100 rounded-full overflow-hidden">
                            <div className="h-full bg-[#EF2F55] rounded-full" style={{ width: `${completionPercentage}%` }}></div>
                        </div>
                        <span className="text-sm font-bold text-black min-w-[32px]">{completionPercentage}%</span>
                    </div>
                </div>
 
                {/* Online Status Section */}
                <div className="mb-6 bg-rose-50/50 rounded-2xl p-3 border border-rose-100/50 flex items-center justify-between">
                    <div className="flex items-center gap-2">
                        <div className="relative flex h-2 w-2">
                            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                            <span className="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
                        </div>
                        <span className="text-sm font-semibold text-gray-700">Online Now</span>
                    </div>
                    <span className="text-sm font-bold text-[#EF2F55]">{onlineCount}</span>
                </div>
 
                <div className="w-full h-[1px] bg-gray-100 mb-5"></div>

                {/* Navigation Links */}
                <div className="space-y-5">
                    <Link href="/onboarding" className="flex items-center justify-between group hover:text-[#EF2F55] transition-colors text-[#111827] font-semibold">
                        <span className="text-base">Complete Profile</span>
                        <ChevronRight className="w-5 h-5 text-black group-hover:text-[#EF2F55]" />
                    </Link>
                    <Link href="/feed" className={`${getLinkClasses('matches')} text-[#111827] font-semibold`}>
                        <span className="text-base">Matches</span>
                        <ChevronRight className={`w-5 h-5 ${activePage === 'matches' ? 'text-[#EF2F55]' : 'text-black'} group-hover:text-[#EF2F55]`} />
                    </Link>
                    <Link href="/explore" className={`${getLinkClasses('search')} text-[#111827] font-semibold`}>
                        <span className="text-base">Search</span>
                        <ChevronRight className={`w-5 h-5 ${activePage === 'search' ? 'text-[#EF2F55]' : 'text-black'} group-hover:text-[#EF2F55]`} />
                    </Link>
                    {user.role === 'vendor' ? (
                        <Link href="/vendor/inquiries" className={`${getLinkClasses('chats')} text-[#111827] font-semibold`}>
                            <span className="text-base">Inquiries</span>
                            <ChevronRight className={`w-5 h-5 ${activePage === 'chats' ? 'text-[#EF2F55]' : 'text-black'} group-hover:text-[#EF2F55]`} />
                        </Link>
                    ) : (
                        <Link href="/chats" className={`${getLinkClasses('chats')} text-[#111827] font-semibold`}>
                            <span className="text-base">Chats</span>
                            <ChevronRight className={`w-5 h-5 ${activePage === 'chats' ? 'text-[#EF2F55]' : 'text-black'} group-hover:text-[#EF2F55]`} />
                        </Link>
                    )}
                    <Link href="/coming-soon" className={`${getLinkClasses('upgrade')} text-[#111827] font-semibold`}>
                        <span className="text-base">Upgrade</span>
                        <ChevronRight className={`w-5 h-5 ${activePage === 'upgrade' ? 'text-[#EF2F55]' : 'text-black'} group-hover:text-[#EF2F55]`} />
                    </Link>
                </div>
            </div>

            {/* Upgrade Banner */}
            <div className="bg-white rounded-2xl shadow-sm p-6 h-[350px] flex flex-col items-center justify-center text-center relative">
                <h3 className="absolute top-4 left-6 text-xl font-medium text-black">
                    Upgrade to<br />
                    <span className="text-[#EF2F55]">Premium</span>
                </h3>

                <div className="w-32 h-32 bg-gray-100 rounded-full mb-6 mt-8 flex items-center justify-center">
                    <Star className="w-12 h-12 text-[#EF2F55] fill-current" />
                </div>

                <Link href="/coming-soon" className="w-full">
                    <Button className="w-full bg-[#EF2F55] hover:bg-rose-600 text-white rounded-md font-semibold">
                        Upgrade Now
                    </Button>
                </Link>
            </div>
        </div>
    );
}
