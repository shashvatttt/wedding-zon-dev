'use client';

import React from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { useRouter } from 'next/navigation';
import { User, ShieldCheck, ArrowRight, LayoutDashboard, Heart, Sparkles, Building2 } from 'lucide-react';
import Navbar from '@/components/Navbar';
import { motion } from 'framer-motion';

export default function FranchiseEntryPage() {
    const router = useRouter();

    return (
        <div className="min-h-screen bg-[#FFF5F7] font-sans selection:bg-rose-100 selection:text-rose-600">
            <Navbar />

            <main className="pt-[72px] min-h-screen flex flex-col relative overflow-hidden">
                {/* Decorative Background Elements */}
                <div className="absolute top-0 left-0 w-full h-full overflow-hidden opacity-40 pointer-events-none">
                    <div className="absolute -top-24 -left-24 w-96 h-96 bg-rose-200 rounded-full mix-blend-multiply filter blur-3xl animate-blob"></div>
                    <div className="absolute top-1/3 -right-24 w-72 h-72 bg-pink-100 rounded-full mix-blend-multiply filter blur-3xl animate-blob animation-delay-2000"></div>
                    <div className="absolute -bottom-8 left-1/2 w-80 h-80 bg-pink-200 rounded-full mix-blend-multiply filter blur-3xl animate-blob animation-delay-4000"></div>
                </div>

                <div className="flex-grow flex flex-col justify-center items-center px-4 sm:px-6 relative z-10 py-12 lg:py-20">

                    {/* Header Section */}
                    <div className="text-center max-w-3xl mx-auto mb-16">
                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ duration: 0.6 }}
                            className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/50 backdrop-blur-sm border border-rose-100 mb-6 shadow-sm"
                        >
                            <Sparkles className="w-4 h-4 text-rose-500" />
                            <span className="text-sm font-medium text-rose-900">Welcome to WeddingZon Franchise</span>
                        </motion.div>

                        <motion.h1
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ duration: 0.6, delay: 0.1 }}
                            className="text-4xl md:text-5xl lg:text-6xl font-bold text-gray-900 mb-6 tracking-tight leading-tight"
                        >
                            Manage Your <span className="text-transparent bg-clip-text bg-gradient-to-r from-rose-600 to-pink-600">Business</span><br />
                            Expand Your <span className="text-transparent bg-clip-text bg-gradient-to-r from-pink-600 to-rose-600">Network</span>
                        </motion.h1>

                        <motion.p
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ duration: 0.6, delay: 0.2 }}
                            className="text-lg md:text-xl text-gray-600 leading-relaxed"
                        >
                            Select your portal to continue. Access your member profile or manage your franchise dashboard.
                        </motion.p>
                    </div>

                    {/* Cards Container */}
                    <div className="grid md:grid-cols-2 gap-6 w-full max-w-4xl mx-auto">
                        {/* Member/User Portal Card */}
                        <motion.div
                            initial={{ opacity: 0, x: -20 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ duration: 0.5, delay: 0.3 }}
                            className="group relative"
                            onClick={() => router.push('/franchise/login')}
                        >
                            <div className="absolute inset-0 bg-gradient-to-r from-rose-500 to-pink-500 rounded-3xl opacity-0 group-hover:opacity-100 blur transition-opacity duration-500"></div>
                            <div className="relative h-full bg-white border border-gray-100 rounded-3xl p-8 lg:p-10 shadow-xl shadow-rose-900/5 hover:shadow-2xl hover:-translate-y-1 transition-all duration-300 cursor-pointer flex flex-col items-center text-center">
                                <div className="w-20 h-20 bg-rose-50 rounded-2xl flex items-center justify-center mb-6 group-hover:bg-rose-100 transition-colors">
                                    <User className="w-10 h-10 text-rose-600" />
                                </div>
                                <h2 className="text-2xl font-bold text-gray-900 mb-3 group-hover:text-rose-600 transition-colors">Login as Member</h2>
                                <p className="text-gray-500 mb-8 flex-grow">
                                    Access your personal profile, view matches, and manage your account.
                                </p>
                                <div className="flex items-center gap-2 text-rose-600 font-semibold group-hover:gap-3 transition-all">
                                    <span>Member Login</span>
                                    <ArrowRight className="w-5 h-5" />
                                </div>
                            </div>
                        </motion.div>

                        {/* Admin/Franchise Portal Card */}
                        <motion.div
                            initial={{ opacity: 0, x: 20 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ duration: 0.5, delay: 0.4 }}
                            className="group relative"
                            onClick={() => router.push('/franchise')}
                        >
                            <div className="absolute inset-0 bg-gradient-to-r from-pink-500 to-rose-500 rounded-3xl opacity-0 group-hover:opacity-100 blur transition-opacity duration-500"></div>
                            <div className="relative h-full bg-white border border-gray-100 rounded-3xl p-8 lg:p-10 shadow-xl shadow-pink-900/5 hover:shadow-2xl hover:-translate-y-1 transition-all duration-300 cursor-pointer flex flex-col items-center text-center">
                                <div className="w-20 h-20 bg-pink-50 rounded-2xl flex items-center justify-center mb-6 group-hover:bg-pink-100 transition-colors">
                                    <LayoutDashboard className="w-10 h-10 text-pink-600" />
                                </div>
                                <h2 className="text-2xl font-bold text-gray-900 mb-3 group-hover:text-pink-600 transition-colors">Franchise Admin</h2>
                                <p className="text-gray-500 mb-8 flex-grow">
                                    Manage your franchise, add members, view analytics, and control settings.
                                </p>
                                <div className="flex items-center gap-2 text-pink-600 font-semibold group-hover:gap-3 transition-all">
                                    <span>Admin Panel</span>
                                    <ArrowRight className="w-5 h-5" />
                                </div>
                            </div>
                        </motion.div>
                    </div>

                </div>

                {/* Footer Strip */}
                <motion.div
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ duration: 1, delay: 0.8 }}
                    className="w-full bg-white/80 backdrop-blur-md border-t border-gray-100 py-6"
                >
                    <div className="max-w-7xl mx-auto px-6 flex flex-col md:flex-row items-center justify-between gap-4 text-sm text-gray-500">
                        <div className="flex items-center gap-2">
                            <Building2 className="w-4 h-4 text-rose-400" />
                            <span>© 2024 WeddingZon Franchise. All rights reserved.</span>
                        </div>
                        <div className="flex items-center gap-6">
                            <Link href="/privacy" className="hover:text-gray-900 transition-colors">Privacy Policy</Link>
                            <Link href="/terms" className="hover:text-gray-900 transition-colors">Terms of Service</Link>
                            <Link href="/support" className="hover:text-gray-900 transition-colors">Support</Link>
                        </div>
                    </div>
                </motion.div>

                {/* CSS Animation for Blobs */}
                <style jsx>{`
                    @keyframes blob {
                        0% { transform: translate(0px, 0px) scale(1); }
                        33% { transform: translate(30px, -50px) scale(1.1); }
                        66% { transform: translate(-20px, 20px) scale(0.9); }
                        100% { transform: translate(0px, 0px) scale(1); }
                    }
                    .animate-blob {
                        animation: blob 7s infinite;
                    }
                    .animation-delay-2000 {
                        animation-delay: 2s;
                    }
                    .animation-delay-4000 {
                        animation-delay: 4s;
                    }
                `}</style>

            </main>
        </div>
    );
}
