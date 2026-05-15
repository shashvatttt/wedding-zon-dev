'use client';

import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';
import { FadeIn } from '@/components/animations/FadeIn';

export default function EditProfilePlaceholder() {
    return (
        <div className="min-h-screen flex flex-col bg-white">
            <Navbar />
            <main className="flex-grow pt-24 pb-12">
                <FadeIn className="max-w-4xl mx-auto px-4">
                    <div className="bg-white rounded-[32px] border border-gray-100 shadow-[0_10px_30px_rgba(0,0,0,0.04)] p-8 md:p-12 text-center">
                        <h1 className="text-4xl md:text-5xl font-bold text-gray-900 mb-6">
                            Edit <span className="text-[#EF2F55]">Profile</span>
                        </h1>
                        <p className="text-xl text-gray-500 mb-10 max-w-2xl mx-auto">
                            We're currently enhancing the profile editing experience to give you more control over your information. This feature will be available soon!
                        </p>
                        <div className="w-full max-w-md mx-auto aspect-video relative rounded-[24px] overflow-hidden bg-pink-50 flex items-center justify-center border-2 border-dashed border-pink-200">
                            <span className="text-pink-400 font-bold text-lg">New Editor Coming Soon</span>
                        </div>
                    </div>
                </FadeIn>
            </main>
            <Footer />
        </div>
    );
}
