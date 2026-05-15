'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { useRouter, usePathname } from 'next/navigation';
import { useAuth } from '@/app/context/AuthContext';
import { useLanguage } from '@/app/context/LanguageContext';
import { Menu, X, User, LogOut, ChevronDown, Globe } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

export default function Navbar() {
    const router = useRouter();
    const pathname = usePathname();
    const { user, logout, isAuthenticated } = useAuth();
    const { language, setLanguage } = useLanguage();
    const [isMenuOpen, setIsMenuOpen] = useState(false);
    const [isProfileOpen, setIsProfileOpen] = useState(false);
    const [isLangOpen, setIsLangOpen] = useState(false);

    const checkActive = (path: string) => pathname === path;

    const navLinks = [
        { name: "Home", path: '/' },
        { name: "About Us", path: '/about' },
        { name: "Blogs", path: '/blogs' },
    ];

    const languages = [
        { code: 'en', name: 'English' },
        { code: 'hi', name: 'हिन्दी' },
        { code: 'pa', name: 'ਪੰਜਾਬੀ' },
    ];

    return (
        <nav className="fixed top-0 left-0 w-full bg-white/95 backdrop-blur-md shadow-sm z-50 transition-all duration-300">
            <div className="max-w-[1440px] mx-auto px-4 sm:px-8 h-20 flex items-center justify-between">

                {/* Logo */}
                <Link href="/" className="flex items-center gap-2 group shrink-0">
                    <Image
                        src="/weddingzon-logo.png"
                        alt="WeddingZon Logo"
                        width={240}
                        height={65}
                        className="object-contain w-[150px] sm:w-[210px] md:w-[240px]"
                        priority
                        quality={100}
                        unoptimized
                    />
                </Link>

                {/* Desktop Links */}
                <div className="hidden lg:flex items-center gap-6 xl:gap-12">
                    {navLinks.map((link) => (
                        <Link
                            key={link.path}
                            href={link.path}
                            className={`text-base font-semibold transition-colors hover:text-[#EF2F55] ${checkActive(link.path) ? 'text-[#EF2F55]' : 'text-gray-900'
                                }`}
                        >
                            {link.name}
                        </Link>
                    ))}
                </div>

                {/* Auth / Profile / Language */}
                <div className="hidden md:flex items-center gap-3 lg:gap-4">
                    {/* Premium Language Selector */}
                    <div className="relative">
                        <button
                            onClick={() => setIsLangOpen(!isLangOpen)}
                            className="flex items-center gap-1 text-gray-700 hover:text-[#EF2F55] transition-colors font-medium text-sm"
                        >
                            <Globe className="w-4 h-4" />
                            <span className="uppercase">{language}</span>
                            <ChevronDown className="w-4 h-4" />
                        </button>

                        <AnimatePresence>
                            {isLangOpen && (
                                <motion.div
                                    initial={{ opacity: 0, y: 10 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    exit={{ opacity: 0, y: 10 }}
                                    className="absolute top-full right-0 mt-2 w-32 bg-white rounded-xl shadow-xl border border-gray-100 py-2 z-50"
                                >
                                    {languages.map((lang) => (
                                        <button
                                            key={lang.code}
                                            onClick={() => {
                                                setLanguage(lang.code as any);
                                                if (window.triggerGoogleTranslate) {
                                                    window.triggerGoogleTranslate(lang.code);
                                                }
                                                setIsLangOpen(false);
                                            }}
                                            className={`w-full text-left px-4 py-2 text-sm hover:bg-rose-50 hover:text-rose-600 transition-colors ${language === lang.code ? 'text-rose-600 font-semibold' : 'text-gray-700'
                                                }`}
                                        >
                                            {lang.name}
                                        </button>
                                    ))}
                                </motion.div>
                            )}
                        </AnimatePresence>
                    </div>

                    {isAuthenticated && user ? (
                        <div className="relative">
                            <button
                                onClick={() => setIsProfileOpen(!isProfileOpen)}
                                className="flex items-center gap-2 text-gray-700 hover:text-[#EF2F55] transition-colors"
                            >
                                <div className="w-8 h-8 rounded-full bg-rose-100 flex items-center justify-center text-rose-600 border border-rose-200">
                                    <User className="w-4 h-4" />
                                </div>
                                <span className="font-medium text-sm max-w-[80px] lg:max-w-[100px] truncate">
                                    {user.first_name || 'User'}
                                </span>
                                <ChevronDown className="w-4 h-4" />
                            </button>

                            {/* Dropdown */}
                            <AnimatePresence>
                                {isProfileOpen && (
                                    <motion.div
                                        initial={{ opacity: 0, y: 10 }}
                                        animate={{ opacity: 1, y: 0 }}
                                        exit={{ opacity: 0, y: 10 }}
                                        transition={{ duration: 0.2 }}
                                        className="absolute top-full right-0 mt-2 w-48 bg-white rounded-xl shadow-xl border border-gray-100 py-2 z-50"
                                    >
                                        <div className="px-4 py-2 border-b border-gray-50">
                                            <p className="text-xs text-gray-500">Signed in as</p>
                                            <p className="text-sm font-semibold text-gray-900 truncate">{user.email}</p>
                                        </div>
                                        <Link
                                            href="/profile"
                                            className="block px-4 py-2 text-sm text-gray-700 hover:bg-rose-50 hover:text-rose-600 transition-colors"
                                            onClick={() => setIsProfileOpen(false)}
                                        >
                                            My Profile
                                        </Link>
                                        {user.role === 'vendor' && (
                                            <Link
                                                href="/vendor/dashboard"
                                                className="block px-4 py-2 text-sm text-gray-700 hover:bg-rose-50 hover:text-rose-600 transition-colors"
                                                onClick={() => setIsProfileOpen(false)}
                                            >
                                                Vendor Dashboard
                                            </Link>
                                        )}
                                        {user.role === 'franchise' && (
                                            <Link
                                                href="/franchise"
                                                className="block px-4 py-2 text-sm text-gray-700 hover:bg-rose-50 hover:text-rose-600 transition-colors"
                                                onClick={() => setIsProfileOpen(false)}
                                            >
                                                Franchise Dashboard
                                            </Link>
                                        )}
                                        <button
                                            onClick={() => {
                                                logout();
                                                setIsProfileOpen(false);
                                            }}
                                            className="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors flex items-center gap-2"
                                        >
                                            <LogOut className="w-4 h-4" />
                                            Log Out
                                        </button>
                                    </motion.div>
                                )}
                            </AnimatePresence>
                        </div>
                    ) : (
                        <div className="flex items-center gap-3 lg:gap-4">
                            <Link
                                href="/login?type=vendor&role=vendor"
                                className="hidden xl:block px-4 lg:px-6 py-2.5 border border-[#EF2F55] text-[#EF2F55] hover:bg-rose-50 text-base font-semibold rounded-md transition-all whitespace-nowrap"
                            >
                                Login as Vendor
                            </Link>
                            <Link
                                href="/login"
                                className="px-4 lg:px-8 py-2.5 bg-[#EF2F55] hover:bg-rose-700 text-white text-base font-semibold rounded-md transition-all shadow-sm hover:shadow-md whitespace-nowrap"
                            >
                                Log In
                            </Link>
                        </div>
                    )}
                </div>

                {/* Mobile Menu Button */}
                <div className="flex items-center gap-2 lg:hidden">
                    <button
                        onClick={() => setIsLangOpen(!isLangOpen)}
                        className="p-2 text-gray-600 hover:text-[#EF2F55]"
                    >
                        <Globe className="w-5 h-5" />
                    </button>
                    <button
                        onClick={() => setIsMenuOpen(!isMenuOpen)}
                        className="p-2 text-gray-600 hover:text-[#EF2F55] transition-colors"
                    >
                        {isMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
                    </button>
                </div>
            </div>

            {/* Mobile Menu */}
            <AnimatePresence>
                {isMenuOpen && (
                    <motion.div
                        initial={{ opacity: 0, height: 0 }}
                        animate={{ opacity: 1, height: 'auto' }}
                        exit={{ opacity: 0, height: 0 }}
                        transition={{ duration: 0.3, ease: 'easeInOut' }}
                        className="lg:hidden bg-white border-t border-gray-100 px-4 py-4 shadow-lg overflow-hidden"
                    >
                        <div className="flex flex-col space-y-4">
                            {/* Mobile Language Selector (Headless Google Translate) */}
                            <div className="flex gap-2 py-2 overflow-x-auto no-scrollbar">
                                {languages.map((lang) => (
                                    <button
                                        key={lang.code}
                                        onClick={() => {
                                            setLanguage(lang.code as any);
                                            if (window.triggerGoogleTranslate) {
                                                window.triggerGoogleTranslate(lang.code);
                                            }
                                        }}
                                        className={`px-4 py-1.5 rounded-full text-sm whitespace-nowrap transition-colors ${language === lang.code
                                            ? 'bg-rose-100 text-rose-600 font-semibold'
                                            : 'bg-gray-100 text-gray-600'
                                            }`}
                                    >
                                        {lang.name}
                                    </button>
                                ))}
                            </div>

                            {navLinks.map((link, idx) => (
                                <motion.div
                                    key={link.path}
                                    initial={{ opacity: 0, x: -20 }}
                                    animate={{ opacity: 1, x: 0 }}
                                    transition={{ delay: idx * 0.05 }}
                                >
                                    <Link
                                        href={link.path}
                                        onClick={() => setIsMenuOpen(false)}
                                        className={`text-lg font-medium py-3 border-b border-gray-50 block ${checkActive(link.path) ? 'text-[#EF2F55]' : 'text-gray-800'
                                            }`}
                                    >
                                        {link.name}
                                    </Link>
                                </motion.div>
                            ))}

                            <div className="pt-6 flex flex-col gap-4">
                                {isAuthenticated ? (
                                    <>
                                        <Link
                                            href="/profile"
                                            onClick={() => setIsMenuOpen(false)}
                                            className="w-full text-center py-3 border border-gray-200 rounded-lg text-gray-700 font-medium hover:bg-gray-50"
                                        >
                                            My Profile
                                        </Link>
                                        <button
                                            onClick={() => {
                                                logout();
                                                setIsMenuOpen(false);
                                            }}
                                            className="w-full text-center py-3 bg-gray-100 text-red-600 font-medium rounded-lg hover:bg-gray-200"
                                        >
                                            Log Out
                                        </button>
                                    </>
                                ) : (
                                    <div className="flex flex-col gap-3">
                                        <Link
                                            href="/login"
                                            onClick={() => setIsMenuOpen(false)}
                                            className="w-full text-center py-3 bg-[#EF2F55] text-white font-semibold rounded-md hover:bg-rose-700 shadow-md"
                                        >
                                            Log In
                                        </Link>
                                        <Link
                                            href="/login?type=vendor&role=vendor"
                                            onClick={() => setIsMenuOpen(false)}
                                            className="w-full text-center py-3 border border-[#EF2F55] text-[#EF2F55] font-semibold rounded-md hover:bg-rose-50"
                                        >
                                            Login as Vendor
                                        </Link>
                                    </div>
                                )}
                            </div>
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </nav>
    );
}

