'use client';

import React, { use } from 'react';
import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { Calendar, User, ArrowLeft, Share2, Clock, ChevronRight } from 'lucide-react';

const blogPostsContent: Record<string, any> = {
    "top-10-indian-wedding-trends-2025": {
        title: "Top 10 Indian Wedding Trends for 2025",
        subtitle: "From sustainable ceremonies to pastel decor, discover what's trending in the world of Indian weddings this season.",
        date: "Feb 1, 2025",
        author: "Ananya Sharma",
        category: "Trends",
        readTime: "5 min read",
        content: `
            <p className="text-xl text-gray-700 leading-relaxed mb-8 font-light italic border-l-4 border-rose-500 pl-6">
                As we move into 2025, Indian weddings are undergoing a beautiful transformation, blending timeless traditions with modern sensibilities.
            </p>
            <h2 className="text-3xl font-serif font-bold text-gray-900 mt-12 mb-6">1. Sustainable Celebrations</h2>
            <p className="text-gray-600 leading-relaxed text-lg mb-6">
                Eco-conscious weddings are no longer a niche choice. Couples are opting for digital invites, locally sourced organic menus, and floral decorations that can be repurposed or composted.
            </p>
            <h2 className="text-3xl font-serif font-bold text-gray-900 mt-12 mb-6">2. Pastel Palettes</h2>
            <p className="text-gray-600 leading-relaxed text-lg mb-6">
                While red remains classic, we're seeing an explosion of sage green, dusty rose, and lavender. These softer tones provide a sophisticated canvas for intricate jewelry and heavy embroidery.
            </p>
            <h2 className="text-3xl font-serif font-bold text-gray-900 mt-12 mb-6">3. Micro-Weddings with Macro-Experiences</h2>
            <p className="text-gray-600 leading-relaxed text-lg mb-12">
                The guest list might be smaller, but the attention to detail is immense. Personalized favors, curated activity corners, and artisanal cocktails are taking center stage.
            </p>
        `
    },
    // Adding fallbacks for other IDs to ensure it looks good even with placeholders
    "default": {
        title: "Wedding Inspiration & Planning",
        subtitle: "Expert advice and beautiful stories to help you plan your perfect day.",
        date: "Recently Updated",
        author: "WeddingZon Editorial",
        category: "Planning",
        readTime: "10 min read",
        content: `
            <p className="text-xl text-gray-700 leading-relaxed mb-8 font-light">
                Welcome to our wedding resource library. We're dedicated to helping you navigate the complex and beautiful journey of planning a celebration that truly reflects your love.
            </p>
            <h2 className="text-3xl font-serif font-bold text-gray-900 mt-12 mb-6">The Journey Begins</h2>
            <p className="text-gray-600 leading-relaxed text-lg mb-6">
                Whether you're just starting out or putting on the final touches, our guides are here to support every step of the way. From venue selection to the final walk down the aisle.
            </p>
        `
    }
};

interface PageProps {
    params: Promise<{ id: string }>;
}

export default function BlogDetailPage({ params }: PageProps) {
    const { id } = use(params);
    const router = useRouter();

    const post = blogPostsContent[id] || blogPostsContent["default"];

    return (
        <div className="min-h-screen bg-white font-sans">
            <Navbar />

            {/* Breadcrumb Section */}
            <div className="pt-32 pb-8 px-4 border-b border-gray-50">
                <div className="max-w-4xl mx-auto flex items-center text-sm text-gray-400 font-bold uppercase tracking-widest">
                    <Link href="/" className="hover:text-rose-500 transition-colors">Home</Link>
                    <ChevronRight className="w-4 h-4 mx-2 text-gray-200" />
                    <Link href="/blogs" className="hover:text-rose-500 transition-colors">Journal</Link>
                    <ChevronRight className="w-4 h-4 mx-2 text-gray-200" />
                    <span className="text-gray-900">{post.category}</span>
                </div>
            </div>

            <article className="py-20 px-4 md:px-8 max-w-4xl mx-auto">
                {/* Article Header */}
                <header className="mb-16 space-y-8">
                    <div className="space-y-4">
                        <span className="bg-rose-50 text-[#EF2F55] px-4 py-1.5 rounded-full text-xs font-black uppercase tracking-widest inline-block mb-4">
                            {post.category}
                        </span>
                        <h1 className="text-4xl md:text-6xl font-serif font-black text-gray-900 leading-tight">
                            {post.title}
                        </h1>
                        <p className="text-xl md:text-2xl text-gray-500 font-light leading-relaxed">
                            {post.subtitle}
                        </p>
                    </div>

                    <div className="flex flex-wrap items-center justify-between py-8 border-y border-gray-100 gap-6">
                        <div className="flex items-center gap-4">
                            <div className="w-12 h-12 rounded-full bg-gray-50 flex items-center justify-center text-gray-400 border border-gray-100">
                                <User className="w-6 h-6" />
                            </div>
                            <div className="flex flex-col">
                                <span className="text-base font-bold text-gray-900 leading-none mb-1">{post.author}</span>
                                <span className="text-sm text-gray-400 font-medium">{post.date}</span>
                            </div>
                        </div>
                        <div className="flex items-center gap-8">
                            <div className="flex items-center gap-2 text-gray-400 font-bold uppercase tracking-tighter text-xs">
                                <Clock className="w-4 h-4" />
                                {post.readTime}
                            </div>
                            <button className="p-2 text-gray-400 hover:text-rose-500 transition-colors">
                                <Share2 className="w-5 h-5" />
                            </button>
                        </div>
                    </div>
                </header>

                {/* Article Body */}
                <div 
                    className="prose prose-rose prose-lg max-w-none prose-headings:font-serif prose-headings:font-black prose-p:font-light prose-p:text-gray-600 prose-p:leading-relaxed"
                    dangerouslySetInnerHTML={{ __html: post.content }}
                />

                {/* Footer Section of Article */}
                <footer className="mt-20 pt-10 border-t border-gray-100 flex items-center justify-between">
                    <button 
                        onClick={() => router.push('/blogs')}
                        className="flex items-center gap-2 text-gray-900 font-black uppercase tracking-widest text-sm hover:text-[#EF2F55] transition-colors group"
                    >
                        <ArrowLeft className="w-5 h-5 transition-transform group-hover:-translate-x-2" />
                        Back to Feed
                    </button>
                    <div className="flex gap-2">
                        <span className="w-2 h-2 rounded-full bg-rose-200" />
                        <span className="w-2 h-2 rounded-full bg-rose-400" />
                        <span className="w-2 h-2 rounded-full bg-rose-600" />
                    </div>
                </footer>
            </article>

            {/* Newsletter Minimal CTA (Reused or similar) */}
            <div className="bg-gray-50 py-24 px-4">
                <div className="max-w-4xl mx-auto text-center space-y-8">
                    <h2 className="text-3xl md:text-5xl font-serif font-bold text-gray-900">Enjoyed this journal?</h2>
                    <p className="text-gray-500 text-lg font-light max-w-xl mx-auto">
                        Join 10,000+ couples receiving our weekly insights on modern Indian weddings.
                    </p>
                    <div className="flex flex-col sm:flex-row gap-4 justify-center max-w-md mx-auto">
                        <input 
                            type="email" 
                            placeholder="Your best email"
                            className="px-6 py-4 bg-white border border-gray-200 rounded-2xl focus:outline-none focus:ring-2 focus:ring-rose-200 transition-all flex-1 font-medium"
                        />
                        <button className="px-8 py-4 bg-[#EF2F55] text-white font-black rounded-2xl hover:bg-rose-600 transition-all shadow-lg shadow-rose-200 active:scale-95 uppercase tracking-widest text-sm">
                            Join Now
                        </button>
                    </div>
                </div>
            </div>

            <Footer />
        </div>
    );
}
