'use client';

import React from 'react';
import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';
import { Heart, Users, ShieldCheck, Zap } from 'lucide-react';


export default function AboutPage() {

    return (
        <div className="min-h-screen bg-white font-sans">
            <Navbar />

            {/* Hero Section */}
            <div className="relative w-full h-[50vh] flex items-center justify-center mt-20 bg-gradient-to-br from-rose-500 via-[#EF2F55] to-rose-700">
                <div className="relative z-10 text-center text-white px-4">
                    <h1 className="text-4xl md:text-6xl font-serif font-bold mb-4 drop-shadow-md">Our Love for Modern Traditions</h1>
                    <p className="text-lg md:text-xl max-w-2xl mx-auto font-light drop-shadow-sm">
                        Redefining how India finds its perfect match with trust, technology, and elegance.
                    </p>
                </div>
            </div>

            {/* Our Story */}
            <section className="py-24 px-4 md:px-8 max-w-4xl mx-auto text-center">
                <div className="space-y-8">
                    <div className="flex flex-col items-center gap-4 text-center">
                        <h2 className="text-3xl md:text-5xl font-serif font-bold text-gray-900">Our Story</h2>
                        <div className="w-20 h-1.5 bg-[#EF2F55] rounded-full" />
                    </div>
                    <div className="space-y-6">
                        <p className="text-gray-600 leading-relaxed text-xl font-light">
                            WeddingZon was born from a simple observation: finding a partner should be a journey of joy, not a process of compromise.
                        </p>
                        <p className="text-gray-700 leading-relaxed text-xl font-medium">
                            We combined deep-rooted cultural values with cutting-edge matchmaking technology to create a platform that respects your choices.
                        </p>
                    </div>
                </div>
            </section>

            {/* Mission & Vision */}
            <section className="bg-rose-50 py-20 px-4 md:px-8">
                <div className="max-w-7xl mx-auto text-center mb-16">
                    <h2 className="text-3xl md:text-4xl font-serif font-bold text-gray-900 mb-4">Why Choose WeddingZon?</h2>
                    <p className="text-gray-600 max-w-2xl mx-auto">
                        Everything you need to plan your big day, all in one place.
                    </p>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 max-w-7xl mx-auto">
                    {[
                        {
                            icon: Heart,
                            title: "Passion for Matching",
                            desc: "We are deeply committed to helping you find a partner who truly complements your soul."
                        },
                        {
                            icon: Users,
                            title: "Vibrant Community",
                            desc: "Access a diverse network of verified profiles across various backgrounds and professions."
                        },
                        {
                            icon: ShieldCheck,
                            title: "Unmatched Trust",
                            desc: "Your privacy and security are our top priorities, with advanced verification systems."
                        },
                        {
                            icon: Zap,
                            title: "Smart Innovation",
                            desc: "Leveraging modern tech for map-based searches, smart filters, and seamless chat."
                        }
                    ].map((item, idx) => (
                        <div key={idx} className="bg-white p-8 rounded-2xl shadow-sm hover:shadow-md transition-shadow text-center">
                            <div className="w-14 h-14 bg-rose-100 text-[#EF2F55] rounded-full flex items-center justify-center mx-auto mb-6">
                                <item.icon className="w-7 h-7" />
                            </div>
                            <h3 className="text-xl font-bold text-gray-900 mb-3">{item.title}</h3>
                            <p className="text-gray-600 leading-relaxed">
                                {item.desc}
                            </p>
                        </div>
                    ))}
                </div>
            </section>

            {/* CTA */}
            <section className="py-24 px-4 text-center bg-gradient-to-r from-[#EF2F55] to-rose-600 text-white">
                <h2 className="text-3xl md:text-5xl font-serif font-bold mb-6">Ready to find your forever?</h2>
                <p className="text-lg mb-10 max-w-2xl mx-auto opacity-90">
                    Browse thousands of profiles and start your story today.
                </p>
                <div className="flex flex-col sm:flex-row gap-4 justify-center">
                    <a href="/matrimony" className="px-8 py-3 bg-white text-[#EF2F55] font-bold rounded-full hover:bg-gray-100 transition-colors shadow-lg">
                        Find Your Match
                    </a>
                    <a href="/services" className="px-8 py-3 bg-transparent border-2 border-white text-white font-bold rounded-full hover:bg-white/10 transition-colors">
                        Explore Vendors
                    </a>
                </div>
            </section>

            <Footer />
        </div>
    );
}
