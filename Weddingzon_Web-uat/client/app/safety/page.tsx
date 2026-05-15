'use client';

import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';
import { FadeIn } from '@/components/animations/FadeIn';
import { ShieldCheck, EyeOff, Lock, UserCheck, AlertTriangle, HelpCircle } from 'lucide-react';

export default function SafetyPage() {
    return (
        <div className="min-h-screen flex flex-col bg-white">
            <Navbar />
            <main className="flex-grow pt-24 pb-12">
                <FadeIn className="max-w-4xl mx-auto px-4">
                    <div className="text-center mb-16">
                        <div className="inline-block p-4 bg-pink-50 rounded-[24px] mb-6">
                            <ShieldCheck className="w-12 h-12 text-[#EF2F55]" />
                        </div>
                        <h1 className="text-4xl md:text-5xl font-black text-gray-900 mb-6">
                            Trust & <span className="text-[#EF2F55]">Safety</span> Center
                        </h1>
                        <p className="text-xl text-gray-500 max-w-2xl mx-auto leading-relaxed">
                            Your safety is the foundation of every heartbeat on WeddingZon. We employ advanced technology and human moderation to keep you secure.
                        </p>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-16">
                        <div className="p-8 bg-gray-50 rounded-[32px] border border-gray-100 hover:shadow-xl hover:-translate-y-2 transition-all duration-300">
                            <div className="w-12 h-12 bg-white rounded-2xl flex items-center justify-center shadow-sm mb-6">
                                <Lock className="w-6 h-6 text-[#EF2F55]" />
                            </div>
                            <h3 className="text-xl font-bold text-gray-900 mb-3">Privacy First</h3>
                            <p className="text-gray-500 text-sm leading-relaxed">
                                Control who sees your photos and details. Our "Strict Privacy" mode ensures only verified matches can view your sensitive information.
                            </p>
                        </div>

                        <div className="p-8 bg-gray-50 rounded-[32px] border border-gray-100 hover:shadow-xl hover:-translate-y-2 transition-all duration-300">
                            <div className="w-12 h-12 bg-white rounded-2xl flex items-center justify-center shadow-sm mb-6">
                                <UserCheck className="w-6 h-6 text-green-500" />
                            </div>
                            <h3 className="text-xl font-bold text-gray-900 mb-3">Verified Profiles</h3>
                            <p className="text-gray-500 text-sm leading-relaxed">
                                Look for the blue tick! Every verified profile undergoes a multi-step verification process including ID and social validation.
                            </p>
                        </div>

                        <div className="p-8 bg-gray-50 rounded-[32px] border border-gray-100 hover:shadow-xl hover:-translate-y-2 transition-all duration-300">
                            <div className="w-12 h-12 bg-white rounded-2xl flex items-center justify-center shadow-sm mb-6">
                                <AlertTriangle className="w-6 h-6 text-amber-500" />
                            </div>
                            <h3 className="text-xl font-bold text-gray-900 mb-3">Instant Reporting</h3>
                            <p className="text-gray-500 text-sm leading-relaxed">
                                Encountered someone suspicious? Report or block instantly. Our moderation team reviews reports within 24 hours.
                            </p>
                        </div>

                        <div className="p-8 bg-gray-50 rounded-[32px] border border-gray-100 hover:shadow-xl hover:-translate-y-2 transition-all duration-300">
                            <div className="w-12 h-12 bg-white rounded-2xl flex items-center justify-center shadow-sm mb-6">
                                <EyeOff className="w-6 h-6 text-blue-500" />
                            </div>
                            <h3 className="text-xl font-bold text-gray-900 mb-3">Invisible Mode</h3>
                            <p className="text-gray-500 text-sm leading-relaxed">
                                Want to browse quietly? Toggle invisible mode to visit profiles without letting them know. (Premium Feature)
                            </p>
                        </div>
                    </div>

                    <div className="bg-[#EF2F55] rounded-[40px] p-10 md:p-16 text-white text-center shadow-2xl shadow-pink-200">
                        <h2 className="text-3xl font-bold mb-4">Golden Rules of Online Safety</h2>
                        <ul className="text-left max-w-lg mx-auto space-y-4 opacity-90">
                            <li className="flex gap-3"><span>1.</span> Always meet in public places for the first few dates.</li>
                            <li className="flex gap-3"><span>2.</span> Keep your financial details strictly private.</li>
                            <li className="flex gap-3"><span>3.</span> Inform a friend or family member about your location.</li>
                            <li className="flex gap-3"><span>4.</span> Trust your instincts—if it feels wrong, it probably is.</li>
                        </ul>
                    </div>
                </FadeIn>
            </main>
            <Footer />
        </div>
    );
}
