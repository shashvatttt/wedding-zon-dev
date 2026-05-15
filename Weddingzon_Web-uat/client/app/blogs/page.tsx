'use client';

import React from 'react';
import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';
import Link from 'next/link';
import { Calendar, User, ArrowRight, Bookmark } from 'lucide-react';

const blogPosts = [
    {
        id: "top-10-indian-wedding-trends-2025",
        title: "Top 10 Indian Wedding Trends for 2025",
        excerpt: "From sustainable ceremonies to pastel decor, discover what's trending in the world of Indian weddings this season.",
        date: "Feb 1, 2025",
        author: "Ananya Sharma",
        category: "Trends",
        readTime: "5 min read"
    },
    {
        id: "choosing-perfect-bridal-lehenga",
        title: "How to Choose the Perfect Bridal Lehenga",
        excerpt: "A comprehensive guide to finding a lehenga that complements your body type and personal style.",
        date: "Jan 28, 2025",
        author: "Riya Kapoor",
        category: "Fashion",
        readTime: "8 min read"
    },
    {
        id: "destination-weddings-udaipur-vs-goa",
        title: "Destination Weddings: Udaipur vs. Goa",
        excerpt: "Comparing two of India's most popular wedding destinations to help you decide your dream venue.",
        date: "Jan 20, 2025",
        author: "Vikram Singh",
        category: "Venues",
        readTime: "6 min read"
    },
    {
        id: "essential-tips-wedding-photography",
        title: "5 Essential Tips for Wedding Photography",
        excerpt: "Ensure your special moments are captured perfectly with these tips for working with your photographer.",
        date: "Jan 15, 2025",
        author: "Arjun Das",
        category: "Photography",
        readTime: "4 min read"
    },
    {
        id: "ultimate-wedding-planning-checklist",
        title: "The Ultimate Wedding Planning Checklist",
        excerpt: "Stay organized with our month-by-month guide to planning a stress-free wedding.",
        date: "Jan 10, 2025",
        author: "Meera Patel",
        category: "Planning",
        readTime: "12 min read"
    },
    {
        id: "budgeting-for-your-big-day",
        title: "Budgeting for Your Big Day",
        excerpt: "Smart ways to allocate your funds and save money without compromising on your dream wedding.",
        date: "Jan 05, 2025",
        author: "Sanjay Gupta",
        category: "Finance",
        readTime: "10 min read"
    }
];

export default function BlogsPage() {

    return (
        <div className="min-h-screen bg-rose-50/20 font-sans">
            <Navbar />

            {/* Header */}
            <div className="bg-gradient-to-br from-[#EF2F55] via-rose-600 to-rose-700 text-white pt-40 pb-24 px-4 text-center">
                <div className="max-w-4xl mx-auto space-y-6">
                    <h1 className="text-4xl md:text-7xl font-serif font-bold tracking-tight drop-shadow-md">
                        WeddingZon <span className="italic opacity-90">Insights</span>
                    </h1>
                    <p className="text-xl md:text-2xl font-light opacity-90 max-w-2xl mx-auto border-t border-white/20 pt-6">
                        Inspiration, tips, and trends for your perfect celebration. Crafted for modern couples.
                    </p>
                </div>
            </div>

            {/* Blog Grid */}
            <div className="max-w-7xl mx-auto px-4 md:px-8 py-24">
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-12">
                    {blogPosts.map((post) => (
                        <Link 
                            key={post.id} 
                            href={`/blogs/${post.id}`}
                            className="bg-white rounded-3xl p-8 md:p-10 shadow-[0_4px_20px_rgba(0,0,0,0.03)] hover:shadow-[0_20px_40px_rgba(239,47,85,0.08)] transition-all duration-500 border border-rose-100/50 flex flex-col group relative overflow-hidden"
                        >
                            {/* Decorative Background Element */}
                            <div className="absolute top-0 right-0 w-32 h-32 bg-rose-50 rounded-full -mr-16 -mt-16 group-hover:bg-rose-100 transition-colors duration-500" />
                            
                            <div className="relative z-10 flex flex-col h-full">
                                <div className="flex items-center justify-between mb-8">
                                    <span className="bg-rose-100/50 text-[#EF2F55] px-4 py-1.5 rounded-full text-xs font-black uppercase tracking-widest">
                                        {post.category}
                                    </span>
                                    <span className="text-xs font-bold text-gray-400 uppercase tracking-tighter">
                                        {post.readTime}
                                    </span>
                                </div>

                                <h2 className="text-2xl md:text-3xl font-serif font-black text-gray-900 mb-6 group-hover:text-[#EF2F55] transition-colors leading-snug">
                                    {post.title}
                                </h2>
                                
                                <p className="text-gray-500 text-lg leading-relaxed mb-10 line-clamp-3 font-light">
                                    {post.excerpt}
                                </p>

                                <div className="mt-auto pt-8 border-t border-rose-50 flex items-center justify-between">
                                    <div className="flex items-center gap-4">
                                        <div className="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center text-gray-400 border border-gray-200">
                                            <User className="w-5 h-5" />
                                        </div>
                                        <div className="flex flex-col">
                                            <span className="text-sm font-bold text-gray-900 leading-none mb-1">{post.author}</span>
                                            <span className="text-xs text-gray-400 font-medium">{post.date}</span>
                                        </div>
                                    </div>
                                    <div className="flex items-center text-[#EF2F55] font-black text-sm uppercase tracking-widest group/btn">
                                        Read <ArrowRight className="w-5 h-5 ml-2 transform group-hover/btn:translate-x-2 transition-transform" />
                                    </div>
                                </div>
                            </div>
                        </Link>
                    ))}
                </div>
            </div>

            {/* Newsletter Minimal CTA */}
            <div className="max-w-5xl mx-auto px-4 pb-24">
                <div className="bg-white rounded-[40px] p-12 md:p-20 text-center border border-rose-100 shadow-sm overflow-hidden relative">
                    <div className="absolute top-0 right-0 w-64 h-64 bg-rose-50/50 rounded-full blur-3xl -mr-32 -mt-32" />
                    <div className="absolute bottom-0 left-0 w-64 h-64 bg-rose-50/50 rounded-full blur-3xl -ml-32 -mb-32" />
                    
                    <div className="relative z-10 space-y-8">
                        <Bookmark className="w-12 h-12 text-[#EF2F55] mx-auto mb-4" />
                        <h2 className="text-3xl md:text-5xl font-serif font-bold text-gray-900">Get the best of WeddingZon</h2>
                        <p className="text-gray-500 text-lg max-w-xl mx-auto font-light">
                            Receive curators tips, vendor highlights, and real wedding inspiration directly in your inbox.
                        </p>
                        <div className="flex flex-col sm:flex-row gap-4 justify-center max-w-md mx-auto pt-4">
                            <input 
                                type="email" 
                                placeholder="Email address"
                                className="px-6 py-4 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-rose-200 transition-all flex-1 font-medium"
                            />
                            <button className="px-8 py-4 bg-[#EF2F55] text-white font-black rounded-2xl hover:bg-rose-600 transition-all shadow-lg shadow-rose-200 active:scale-95 uppercase tracking-widest text-sm">
                                Subscribe
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <Footer />
        </div>
    );
}
