'use client';

import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';
import { FadeIn } from '@/components/animations/FadeIn';
import { HelpCircle, MessageSquare, Mail, Phone, ExternalLink, ChevronRight } from 'lucide-react';

export default function SupportPage() {
    const faqs = [
        { q: "How do I verify my profile?", a: "Go to your profile settings and upload a valid Government ID." },
        { q: "Can I hide my photos?", a: "Yes, you can manage photo visibility in Settings > Privacy." },
        { q: "How to upgrade to Premium?", a: "Click on the 'Upgrade Membership' banner in the feed sidebar." },
        { q: "What is Franchise mode?", a: "Franchise mode allows you to manage profiles on behalf of others." }
    ];

    return (
        <div className="min-h-screen flex flex-col bg-[#FFF9FA]">
            <Navbar />
            <main className="flex-grow pt-24 pb-12">
                <FadeIn className="max-w-6xl mx-auto px-4">
                    <div className="flex flex-col lg:flex-row gap-12">
                        {/* Right Content First for Mobile Flow */}
                        <div className="flex-1 space-y-10 order-2 lg:order-1">
                            <div>
                                <h1 className="text-4xl font-extrabold text-gray-900 mb-2">How can we <span className="text-[#EF2F55]">help?</span></h1>
                                <p className="text-gray-500 font-medium tracking-wide">Search through our help articles or visit FAQs below.</p>
                            </div>

                            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                {faqs.map((faq, i) => (
                                    <div key={i} className="p-6 bg-white rounded-[24px] border border-gray-50 shadow-sm hover:shadow-md transition-shadow group cursor-pointer">
                                        <div className="flex justify-between items-start mb-2">
                                            <h4 className="font-bold text-gray-900 group-hover:text-[#EF2F55] transition-colors pr-4">{faq.q}</h4>
                                            <ChevronRight className="w-5 h-5 text-gray-300 group-hover:text-[#EF2F55]" />
                                        </div>
                                        <p className="text-sm text-gray-500 leading-relaxed">{faq.a}</p>
                                    </div>
                                ))}
                            </div>

                            <div className="bg-white rounded-[32px] p-10 border border-gray-50 shadow-sm">
                                <h3 className="text-2xl font-bold mb-6">Didn't find what you need?</h3>
                                <div className="flex flex-wrap gap-4">
                                    <div className="flex items-center gap-3 px-6 py-4 bg-gray-50 rounded-2xl hover:bg-pink-50 transition-colors cursor-pointer border border-transparent hover:border-pink-100 flex-1 min-w-[200px]">
                                        <Mail className="w-6 h-6 text-[#EF2F55]" />
                                        <div>
                                            <p className="text-xs font-bold text-gray-400 uppercase">Email Us</p>
                                            <p className="text-sm font-bold text-gray-800">support@weddingzon.com</p>
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-3 px-6 py-4 bg-gray-50 rounded-2xl hover:bg-pink-50 transition-colors cursor-pointer border border-transparent hover:border-pink-100 flex-1 min-w-[200px]">
                                        <Phone className="w-6 h-6 text-[#EF2F55]" />
                                        <div>
                                            <p className="text-xs font-bold text-gray-400 uppercase">Call Support</p>
                                            <p className="text-sm font-bold text-gray-800">+91 1800-WED-ZON</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Left Sidebar Contact Card */}
                        <div className="w-full lg:w-80 order-1 lg:order-2">
                            <div className="bg-white rounded-[40px] p-8 shadow-[0_20px_50px_rgba(239,47,85,0.1)] border border-pink-50 sticky top-28 text-center ring-4 ring-pink-50/50">
                                <div className="w-20 h-20 bg-[#EF2F55] rounded-full flex items-center justify-center mx-auto mb-6 shadow-xl shadow-pink-200">
                                    <MessageSquare className="w-10 h-10 text-white" />
                                </div>
                                <h3 className="text-2xl font-black text-gray-900 mb-2">Live Chat</h3>
                                <p className="text-sm text-gray-500 mb-8 leading-relaxed">
                                    Our support heroes are available 24/7 to assist you.
                                </p>
                                <button className="w-full bg-[#EF2F55] hover:bg-rose-700 text-white font-bold py-4 rounded-2xl transition-all active:scale-95 shadow-lg shadow-pink-100 mb-4">
                                    Start Chat Now
                                </button>
                                <p className="text-[10px] text-gray-400 font-bold uppercase tracking-widest">Average Wait Time: 2 Mins</p>
                            </div>
                        </div>
                    </div>
                </FadeIn>
            </main>
            <Footer />
        </div>
    );
}
