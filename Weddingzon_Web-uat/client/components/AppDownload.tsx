'use client';

import React from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { Apple, Smartphone } from 'lucide-react';
import { APP_LINKS } from '@/constants/links';

const AppDownload = () => {
    return (
        <section className="w-full py-16 bg-[#FFF7F9] overflow-hidden">
            <div className="max-w-7xl mx-auto px-6 lg:px-8">
                <div className="relative rounded-3xl bg-white shadow-xl overflow-hidden p-10 lg:p-16 flex flex-col lg:flex-row items-center justify-between border border-rose-100">

                    {/* Text Content */}
                    <div className="lg:w-1/2 z-10 space-y-8 text-center lg:text-left">
                        <h2 className="text-3xl lg:text-5xl font-bold text-gray-900 font-serif leading-tight">
                            Get the <span className="text-[#EF2F55]">Weddingzon</span> App
                        </h2>
                        <p className="text-lg text-gray-600 max-w-lg mx-auto lg:mx-0 font-sans">
                            Plan your wedding on the go! Find vendors, browse matches, and manage your checklist directly from your phone.
                        </p>

                        <div className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
                            {/* Google Play Button */}
                            <Link
                                href={APP_LINKS.GOOGLE_PLAY}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="flex items-center gap-3 bg-black text-white px-6 py-3 rounded-xl hover:bg-gray-800 transition-all transform hover:-translate-y-1 shadow-lg w-48 justify-center"
                            >
                                <div className="w-8 h-8 relative">
                                    {/* Fallback to icon if image missing */}
                                    <Smartphone className="w-full h-full text-green-400" />
                                </div>
                                <div className="text-left">
                                    <div className="text-[10px] uppercase font-medium">Get it on</div>
                                    <div className="text-sm font-bold">Google Play</div>
                                </div>
                            </Link>

                            {/* App Store Button */}
                            <Link
                                href={APP_LINKS.APP_STORE}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="flex items-center gap-3 bg-black text-white px-6 py-3 rounded-xl hover:bg-gray-800 transition-all transform hover:-translate-y-1 shadow-lg w-48 justify-center"
                            >
                                <div className="w-8 h-8 relative">
                                    <Apple className="w-full h-full text-white" />
                                </div>
                                <div className="text-left">
                                    <div className="text-[10px] uppercase font-medium">Download on the</div>
                                    <div className="text-sm font-bold">App Store</div>
                                </div>
                            </Link>
                        </div>
                    </div>

                    {/* Image/Decoration Side */}
                    <div className="mt-12 lg:mt-0 lg:w-1/2 relative flex justify-center lg:justify-end">
                        <div className="relative w-[300px] h-[600px] border-8 border-black rounded-[3rem] shadow-2xl bg-white overflow-hidden">
                            <div className="absolute top-0 left-1/2 transform -translate-x-1/2 w-32 h-6 bg-black rounded-b-xl z-20"></div>
                            {/* Simulated Screen Content */}
                            <div className="w-full h-full bg-rose-50 flex flex-col items-center justify-center p-6 space-y-4">
                                <div className="w-20 h-20 bg-rose-200 rounded-full animate-pulse"></div>
                                <div className="w-3/4 h-4 bg-gray-200 rounded"></div>
                                <div className="w-1/2 h-4 bg-gray-200 rounded"></div>
                                <div className="mt-8 grid grid-cols-2 gap-2 w-full">
                                    <div className="h-24 bg-white rounded-lg shadow-sm"></div>
                                    <div className="h-24 bg-white rounded-lg shadow-sm"></div>
                                    <div className="h-24 bg-white rounded-lg shadow-sm"></div>
                                    <div className="h-24 bg-white rounded-lg shadow-sm"></div>
                                </div>
                            </div>
                        </div>

                        {/* Decorative Elements */}
                        <div className="absolute -top-10 -right-10 w-40 h-40 bg-pink-200 rounded-full blur-3xl opacity-30"></div>
                        <div className="absolute -bottom-10 -left-10 w-40 h-40 bg-blue-200 rounded-full blur-3xl opacity-30"></div>
                    </div>

                </div>
            </div>
        </section>
    );
};

export default AppDownload;
