'use client';

import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';
import { FadeIn } from '@/components/animations/FadeIn';
import Image from 'next/image';
import { Smartphone, Bell, Heart, ShieldCheck, Zap, Download } from 'lucide-react';
import { APP_LINKS } from '@/constants/links';

export default function DownloadAppPage() {
    return (
        <div className="min-h-screen flex flex-col bg-white">
            <Navbar />
            <main className="flex-grow pt-24 pb-12">
                <FadeIn className="max-w-6xl mx-auto px-4">
                    <div className="flex flex-col lg:flex-row items-center gap-16 py-12">
                        {/* Left Content */}
                        <div className="flex-1 text-center lg:text-left space-y-8">
                            <div>
                                <h1 className="text-5xl md:text-7xl font-black text-gray-900 leading-tight mb-6 mt-16 font-playfair">
                                    Love <span className="text-[#EF2F55]">On The Go</span> with WeddingZon
                                </h1>
                                <p className="text-xl text-gray-500 max-w-xl mx-auto lg:mx-0 leading-relaxed">
                                    Finding your life partner is now at your fingertips. Download the WeddingZon app for a seamless, fast, and secure matchmaking experience.
                                </p>
                            </div>

                            <div className="flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-4">
                                <a
                                    href={APP_LINKS.APP_STORE}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="bg-black text-white px-8 py-4 rounded-2xl flex items-center gap-4 hover:scale-105 transition-transform active:scale-95 group w-full sm:w-auto justify-center"
                                >
                                    <div className="text-left">
                                        <p className="text-[10px] font-bold uppercase opacity-60">Download on the</p>
                                        <p className="text-xl font-black">App Store</p>
                                    </div>
                                </a>
                                <a
                                    href={APP_LINKS.GOOGLE_PLAY}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="bg-black text-white px-8 py-4 rounded-2xl flex items-center gap-4 hover:scale-105 transition-transform active:scale-95 group w-full sm:w-auto justify-center"
                                >
                                    <div className="text-left">
                                        <p className="text-[10px] font-bold uppercase opacity-60">Get it on</p>
                                        <p className="text-xl font-black">Google Play</p>
                                    </div>
                                </a>
                            </div>

                            <div className="grid grid-cols-2 gap-6 max-w-md mx-auto lg:mx-0">
                                <div className="flex items-center gap-3 text-gray-700 font-bold">
                                    <div className="w-8 h-8 bg-pink-50 rounded-lg flex items-center justify-center">
                                        <Bell className="w-4 h-4 text-[#EF2F55]" />
                                    </div>
                                    <span className="text-sm">Instant Notifications</span>
                                </div>
                                <div className="flex items-center gap-3 text-gray-700 font-bold">
                                    <div className="w-8 h-8 bg-pink-50 rounded-lg flex items-center justify-center">
                                        <ShieldCheck className="w-4 h-4 text-[#EF2F55]" />
                                    </div>
                                    <span className="text-sm">Secure Chat</span>
                                </div>
                                <div className="flex items-center gap-3 text-gray-700 font-bold">
                                    <div className="w-8 h-8 bg-pink-50 rounded-lg flex items-center justify-center">
                                        <Heart className="w-4 h-4 text-[#EF2F55]" />
                                    </div>
                                    <span className="text-sm">Bio-Matching</span>
                                </div>
                                <div className="flex items-center gap-3 text-gray-700 font-bold">
                                    <div className="w-8 h-8 bg-pink-50 rounded-lg flex items-center justify-center">
                                        <Zap className="w-4 h-4 text-[#EF2F55]" />
                                    </div>
                                    <span className="text-sm">Realtime Connect</span>
                                </div>
                            </div>
                        </div>

                        {/* Right Content - Mockup */}
                        <div className="w-full lg:w-[500px] flex justify-center">
                            <div className="relative w-[300px] md:w-[350px] h-[600px] md:h-[700px] rounded-[50px] border-[12px] border-gray-900 bg-black overflow-hidden shadow-[0_50px_100px_rgba(0,0,0,0.2)] animate-float">
                                {/* Notch */}
                                <div className="absolute top-0 left-1/2 -translate-x-1/2 w-32 h-8 bg-gray-900 rounded-b-3xl z-20" />

                                {/* Screen Content */}
                                <div className="absolute inset-0 bg-white flex flex-col items-center justify-center p-8 text-center space-y-6">
                                    <div className="w-20 h-20 bg-[#EF2F55] rounded-3xl flex items-center justify-center shadow-2xl shadow-pink-200 mb-4 animate-pulse">
                                        <Heart className="w-10 h-10 text-white fill-current" />
                                    </div>
                                    <h4 className="text-2xl font-black text-gray-900">Matches Waiting</h4>
                                    <p className="text-sm text-gray-400">Discover your perfect partner with our mobile app.</p>
                                    <div className="w-full h-1 bg-gray-100 rounded-full relative overflow-hidden">
                                        <div className="absolute top-0 left-0 h-full bg-[#EF2F55] w-2/3 animate-shimmer" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </FadeIn>
            </main>
            <Footer />

            <style jsx>{`
                @keyframes float {
                    0%, 100% { transform: translateY(0); }
                    50% { transform: translateY(-20px); }
                }
                .animate-float {
                    animation: float 6s ease-in-out infinite;
                }
                @keyframes shimmer {
                    0% { transform: translateX(-100%); }
                    100% { transform: translateX(200%); }
                }
                .animate-shimmer {
                    animation: shimmer 1.5s infinite;
                }
            `}</style>
        </div>
    );
}
