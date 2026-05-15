'use client';

import React from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { ArrowLeft, Rocket, Bell, Heart, Star, Sparkles, Shield, Zap } from 'lucide-react';
import { Button } from '@/components/ui/button';
import FeedHeader from '../feed/components/FeedHeader';
import Footer from '@/components/Footer';

export default function ComingSoonPage() {
    const router = useRouter();

    return (
        <div className="min-h-screen bg-white flex flex-col font-lato">
            <FeedHeader />

            <main className="flex-1 flex flex-col items-center justify-center p-6 relative overflow-hidden mt-16">
                {/* Decorative background elements */}
                <div className="absolute top-20 left-10 w-64 h-64 bg-pink-100/50 rounded-full blur-3xl animate-pulse" />
                <div className="absolute bottom-20 right-10 w-96 h-96 bg-rose-50/50 rounded-full blur-3xl animate-pulse delay-1000" />

                <div className="max-w-4xl w-full relative z-10 flex flex-col items-center text-center">
                    {/* Floating Icon Group */}
                    <div className="relative mb-12">
                        <div className="w-24 h-24 bg-gradient-to-br from-[#EF2F55] to-[#FF6B8B] rounded-[32px] flex items-center justify-center shadow-2xl shadow-rose-200 animate-bounce">
                            <Rocket className="w-12 h-12 text-white" />
                        </div>
                        <div className="absolute -top-4 -right-4 w-10 h-10 bg-white rounded-full shadow-lg flex items-center justify-center animate-pulse">
                            <Sparkles className="w-5 h-5 text-amber-400" />
                        </div>
                        <div className="absolute -bottom-2 -left-6 w-12 h-12 bg-white rounded-full shadow-lg flex items-center justify-center animate-pulse delay-700">
                            <Heart className="w-6 h-6 text-[#EF2F55]" />
                        </div>
                    </div>

                    <h1 className="text-5xl md:text-7xl font-black text-gray-900 mb-8 tracking-tight">
                        Something <span className="bg-gradient-to-r from-[#EF2F55] to-[#FF6B8B] bg-clip-text text-transparent">Extraordinary</span> <br /> is in the works
                    </h1>

                    <p className="text-xl text-gray-500 mb-12 leading-relaxed max-w-2xl mx-auto">
                        We're crafting a premium experience designed just for you.
                        Exclusive features, advanced matchmaking, and personalized tools
                        are just around the corner.
                    </p>

                    {/* Features Preview */}
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-16 w-full max-w-3xl">
                        {[
                            { icon: <Shield className="w-6 h-6 text-blue-500" />, title: "Secure & Private", desc: "Your safety is our top priority" },
                            { icon: <Zap className="w-6 h-6 text-amber-500" />, title: "Instant Match", desc: "Advanced AI-driven matching" },
                            { icon: <Star className="w-6 h-6 text-[#EF2F55]" />, title: "Premium Tools", desc: "Crafted for excellence" },
                        ].map((item, i) => (
                            <div key={i} className="bg-white/80 backdrop-blur-sm p-6 rounded-3xl border border-gray-100 shadow-sm hover:shadow-md transition-all">
                                <div className="w-12 h-12 bg-gray-50 rounded-2xl flex items-center justify-center mb-4 mx-auto">
                                    {item.icon}
                                </div>
                                <h3 className="font-bold text-gray-900 mb-1">{item.title}</h3>
                                <p className="text-sm text-gray-500">{item.desc}</p>
                            </div>
                        ))}
                    </div>

                    <div className="flex flex-col sm:flex-row gap-4 w-full justify-center">
                        <Button
                            onClick={() => router.push('/')}
                            variant="outline"
                            className="rounded-full px-10 py-7 border-2 border-gray-100 text-gray-600 hover:bg-gray-50 font-bold text-lg"
                        >
                            <ArrowLeft className="w-5 h-5 mr-2" />
                            Back to Home
                        </Button>
                        <Button
                            className="rounded-full px-12 py-7 bg-[#EF2F55] hover:bg-rose-600 text-white font-bold text-lg shadow-xl shadow-rose-200 transition-all hover:-translate-y-1"
                        >
                            <Bell className="w-5 h-5 mr-2" />
                            Notify Me
                        </Button>
                    </div>

                    <p className="mt-12 text-gray-400 text-sm font-medium">
                        Join 5,000+ others waiting for this launch
                    </p>
                </div>
            </main>

            <Footer />
        </div>
    );
}
