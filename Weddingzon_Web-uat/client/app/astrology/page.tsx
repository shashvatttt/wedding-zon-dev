'use client';

import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';
import { FadeIn } from '@/components/animations/FadeIn';
import { Moon, Sun, Star, Compass, Sparkles, Wand2, Calendar } from 'lucide-react';

export default function AstrologyPage() {
    return (
        <div className="min-h-screen flex flex-col bg-[#FFF9FA]">
            {/* Celestial Background Effect */}
            <div className="fixed inset-0 pointer-events-none overflow-hidden z-0">
                <div className="absolute top-1/4 right-0 w-[500px] h-[500px] bg-pink-100/30 rounded-full blur-[120px] -translate-y-1/2 translate-x-1/2" />
                <div className="absolute bottom-1/4 left-0 w-[400px] h-[400px] bg-rose-100/20 rounded-full blur-[100px] translate-y-1/2 -translate-x-1/2" />
            </div>

            <Navbar />
            <main className="flex-grow pt-24 pb-12 relative z-10">
                <FadeIn className="max-w-6xl mx-auto px-4">
                    <div className="text-center mb-16">
                        <h1 className="text-5xl md:text-6xl font-black text-gray-900 mb-6 font-playfair tracking-tight">
                            Written in the <span className="text-[#EF2F55]">Stars</span>
                        </h1>
                        <p className="text-xl text-gray-500 max-w-2xl mx-auto leading-relaxed">
                            Combine ancient wisdom with modern matchmaking. Find your celestial counterpart through our comprehensive Vedic astrology engine.
                        </p>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-20">
                        {/* Guna Milan */}
                        <div className="bg-white rounded-[40px] p-10 border border-gray-50 shadow-sm hover:shadow-2xl hover:-translate-y-2 transition-all group overflow-hidden relative">
                            <div className="absolute top-0 right-0 p-4 opacity-5 group-hover:opacity-10 transition-opacity">
                                <Compass className="w-32 h-32 text-gray-900" />
                            </div>
                            <div className="w-16 h-16 bg-pink-50 rounded-2xl flex items-center justify-center mb-8">
                                <Sparkles className="w-8 h-8 text-[#EF2F55]" />
                            </div>
                            <h3 className="text-2xl font-bold text-gray-900 mb-4">Guna Milan</h3>
                            <p className="text-gray-500 text-sm leading-relaxed mb-8">
                                Detailed 36-point matching based on your Ashtakoota. Analyze mental, physical, and financial compatibility.
                            </p>
                            <button className="text-[#EF2F55] font-black text-sm uppercase tracking-widest flex items-center gap-2 hover:gap-4 transition-all">
                                Check Matching <Wand2 className="w-4 h-4" />
                            </button>
                        </div>

                        {/* Manglik Check */}
                        <div className="bg-white rounded-[40px] p-10 border border-gray-50 shadow-sm hover:shadow-2xl hover:-translate-y-2 transition-all group overflow-hidden relative">
                            <div className="absolute top-0 right-0 p-4 opacity-5 group-hover:opacity-10 transition-opacity">
                                <Sun className="w-32 h-32 text-gray-900" />
                            </div>
                            <div className="w-16 h-16 bg-pink-50 rounded-2xl flex items-center justify-center mb-8">
                                <Star className="w-8 h-8 text-[#EF2F55]" />
                            </div>
                            <h3 className="text-2xl font-bold text-gray-900 mb-4">Dosha Analysis</h3>
                            <p className="text-gray-500 text-sm leading-relaxed mb-8">
                                Identify Manglik Dosha, Kuja Dosha, and their potential remedies. Ensure a harmonious married life.
                            </p>
                            <button className="text-[#EF2F55] font-black text-sm uppercase tracking-widest flex items-center gap-2 hover:gap-4 transition-all">
                                Analyze Dosha <Wand2 className="w-4 h-4" />
                            </button>
                        </div>

                        {/* Daily Horoscope */}
                        <div className="bg-white rounded-[40px] p-10 border border-gray-50 shadow-sm hover:shadow-2xl hover:-translate-y-2 transition-all group overflow-hidden relative">
                            <div className="absolute top-0 right-0 p-4 opacity-5 group-hover:opacity-10 transition-opacity">
                                <Moon className="w-32 h-32 text-gray-900" />
                            </div>
                            <div className="w-16 h-16 bg-pink-50 rounded-2xl flex items-center justify-center mb-8">
                                <Calendar className="w-8 h-8 text-[#EF2F55]" />
                            </div>
                            <h3 className="text-2xl font-bold text-gray-900 mb-4">Daily Insights</h3>
                            <p className="text-gray-500 text-sm leading-relaxed mb-8">
                                Get daily updates on how planetary movements affect your love life and matchmaking chances today.
                            </p>
                            <button className="text-[#EF2F55] font-black text-sm uppercase tracking-widest flex items-center gap-2 hover:gap-4 transition-all">
                                View Prediction <Wand2 className="w-4 h-4" />
                            </button>
                        </div>
                    </div>

                    {/* Premium Call to Action */}
                    <div className="max-w-4xl mx-auto rounded-[50px] p-12 bg-gradient-to-tr from-[#EF2F55] to-rose-400 text-white flex flex-col md:flex-row items-center justify-between gap-10 shadow-2xl shadow-pink-200">
                        <div className="text-left">
                            <h2 className="text-3xl font-black mb-2">Speak to our Astrologers</h2>
                            <p className="opacity-90 max-w-sm">Get personalized relationship guidance from our panel of expert Vedic astrologers.</p>
                        </div>
                        <button className="bg-white text-[#EF2F55] px-10 py-5 rounded-2xl font-bold text-lg hover:scale-105 transition-transform active:scale-95 whitespace-nowrap">
                            Book Consultant
                        </button>
                    </div>
                </FadeIn>
            </main>
            <Footer />
        </div>
    );
}
