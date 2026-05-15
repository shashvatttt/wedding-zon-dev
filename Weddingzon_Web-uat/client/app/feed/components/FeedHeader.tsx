'use client';

import { useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { useRouter, usePathname } from 'next/navigation';
import { Bell, Settings, User, Menu } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useAuth } from '../../context/AuthContext';
import LanguageSwitcher from '@/components/LanguageSwitcher';
import FeedMobileNav from './FeedMobileNav';

interface FeedHeaderProps {
    onSettingsClick?: () => void;
}

export default function FeedHeader({ onSettingsClick }: FeedHeaderProps) {
    const router = useRouter();
    const pathname = usePathname();
    const { user, isAuthenticated } = useAuth();
    const [isMobileNavOpen, setIsMobileNavOpen] = useState(false);

    const isActive = (path: string) => pathname === path;

    return (
        <>
            <header className="fixed top-0 left-0 right-0 z-50 h-[72px] bg-white border-b border-gray-100 flex items-center justify-between px-4 md:px-8 shadow-sm">
                {/* Left Side: Menu (Mobile) + Logo */}
                <div className="flex items-center gap-2 md:gap-4 md:w-[260px]">
                    {/* Mobile Menu Button */}
                    <button
                        onClick={() => setIsMobileNavOpen(true)}
                        className="lg:hidden p-2 -ml-2 text-gray-700 hover:bg-gray-100 rounded-full transition-colors"
                    >
                        <Menu className="w-6 h-6" />
                    </button>

                    <Link href="/" className="block h-8 md:h-12">
                        <img
                            src="/weddingzon-logo.png"
                            alt="WeddingZon"
                            className="h-full w-auto object-contain"
                        />
                    </Link>
                </div>

                {/* Centered Navigation (Desktop Only) */}
                <nav className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 hidden lg:flex items-center gap-8">
                    <Link
                        href="/"
                        className={`font-inter font-semibold text-base px-2 py-1 relative ${isActive('/') ? 'text-[#EF2F55]' : 'text-black hover:text-[#EF2F55]'}`}
                    >
                        Home
                        {isActive('/') && <span className="absolute bottom-0 left-0 w-full h-0.5 bg-[#EF2F55] rounded-full"></span>}
                    </Link>
                    <Link
                        href="/feed"
                        className={`font-inter font-semibold text-base px-2 py-1 relative ${isActive('/matrimony') || isActive('/feed') || isActive('/chats') || isActive('/matches') || isActive('/explore') ? 'text-[#EF2F55]' : 'text-black hover:text-[#EF2F55]'}`}
                    >
                        Matrimony
                        {(isActive('/matrimony') || isActive('/feed') || isActive('/chats') || isActive('/matches') || isActive('/explore')) && <span className="absolute bottom-0 left-0 w-full h-0.5 bg-[#EF2F55] rounded-full"></span>}
                    </Link>
                    <Link
                        href="/services"
                        className={`font-inter font-semibold text-base px-2 py-1 relative ${isActive('/services') ? 'text-[#EF2F55]' : 'text-black hover:text-[#EF2F55]'}`}
                    >
                        Services
                        {isActive('/services') && <span className="absolute bottom-0 left-0 w-full h-0.5 bg-[#EF2F55] rounded-full"></span>}
                    </Link>
                    <Link
                        href="/shop"
                        className={`font-inter font-semibold text-base px-2 py-1 relative ${isActive('/shop') ? 'text-[#EF2F55]' : 'text-black hover:text-[#EF2F55]'}`}
                    >
                        Shopping
                        {isActive('/shop') && <span className="absolute bottom-0 left-0 w-full h-0.5 bg-[#EF2F55] rounded-full"></span>}
                    </Link>
                </nav>

                {/* Right Side Actions */}
                <div className="flex items-center gap-2 md:gap-4 md:min-w-[200px] justify-end">

                    <LanguageSwitcher />

                    {/* Vendor Button */}
                    <div className="hidden lg:flex items-center">
                        {isAuthenticated && user?.role === 'vendor' ? (
                            <Link
                                href="/vendor/dashboard"
                                className="px-4 lg:px-6 py-2.5 border border-[#EF2F55] bg-[#EF2F55] text-white hover:bg-rose-700 text-base font-semibold rounded-md transition-all shadow-sm whitespace-nowrap"
                            >
                                Vendor Dashboard
                            </Link>
                        ) : (
                            <Link
                                href="/login?type=vendor&role=vendor"
                                className="px-4 lg:px-6 py-2.5 border border-[#EF2F55] text-[#EF2F55] hover:bg-rose-50 text-base font-semibold rounded-md transition-all whitespace-nowrap"
                            >
                                Login as Vendor
                            </Link>
                        )}
                    </div>

                    {/* Get The App Button (Desktop Only) */}
                    <div className="hidden xl:flex items-center gap-2 px-4 py-1.5 border border-[#FBC3CF] rounded-full bg-white">
                        <span className="text-[10px] font-medium text-black">GET THE APP</span>
                        <div className="flex items-center gap-2 border-l border-gray-200 pl-2">
                            {/* Apple Icon */}
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" className="text-black">
                                <path d="M17.3,12.8c-0.1,2.8,2.4,3.8,2.5,3.8c-0.1,0.4-0.4,1.4-1.3,2.8c-0.8,1.2-1.7,2.3-3,2.3 c-1.3,0-1.7-0.8-3.2-0.8c-1.5,0-2,0.8-3.2,0.8s-2.1-1.2-3-2.3C4.2,16.8,2,11.3,5.1,9.4c1.5-0.9,2.9-1.4,4-1.4 c1.2,0,2.3,0.8,3,0.8c0.7,0,2-1,3.4-0.9c0.6,0,2.2,0.2,3.3,1.6C18.6,9.6,17.3,10.4,17.3,12.8M12.9,5.7 c0.7-0.8,1.1-1.9,0.9-3c-1,0-2.2,0.6-2.9,1.5c-0.6,0.7-1.2,1.8-1,2.9C11,7.2,12.2,6.5,12.9,5.7" />
                            </svg>
                            {/* Playstore Icon (Android) */}
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" className="text-black">
                                <path d="M3,20.5V3.5C3,2.91,3.34,2.39,3.84,2.15L13.69,12L3.84,21.85C3.34,21.6,3,21.09,3,20.5M16.81,15.12L6.05,21.34L14.54,12.85L16.81,15.12M20.16,10.81C20.5,11.14,20.5,11.69,20.16,12.02L18.25,13.93L15.68,11.36L18.25,8.79L20.16,10.81M16.81,8.88L14.54,11.15L6.05,2.66L16.81,8.88M14.54,12L6.05,3.51L12,9.46L6.05,15.41" />
                            </svg>
                        </div>
                    </div>
                </div>
            </header>

            {/* Mobile Navigation Drawer */}
            <FeedMobileNav
                isOpen={isMobileNavOpen}
                onClose={() => setIsMobileNavOpen(false)}
                user={user}
            />
        </>
    );
}
