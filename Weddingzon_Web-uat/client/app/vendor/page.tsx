'use client';

import React, { useEffect } from 'react';
import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer'; // Assuming Footer is needed as well, typical for landing pages
import Image from 'next/image';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/app/context/AuthContext';

export default function VendorPage() {
    const router = useRouter();
    const { user, loading } = useAuth();

    // Redirect authenticated users away from landing page
    useEffect(() => {
        if (!loading && user) {
            if (user.role === 'vendor') {
                router.push('/vendor/dashboard');
            } else if (user.role === 'franchise') {
                router.push('/franchise/dashboard');
            } else {
                router.push('/feed');
            }
        }
    }, [user, loading, router]);

    return (
        <div className="min-h-screen bg-white font-sans">
            <Navbar />

            {/* Hero Section */}
            <div className="relative w-full h-screen min-h-[600px] flex items-center justify-center">

                {/* Background Image */}
                <div className="absolute inset-0 z-0">
                    <Image
                        src="/vendor-hero-bg.png"
                        alt="Vendor Hero Background"
                        fill
                        className="object-cover"
                        priority
                        quality={100}
                        unoptimized
                    />
                </div>

                {/* 
                   Buttons Container 
                   User requested specific absolute positioning:
                   - Group width: 1059px
                   - Centered: left: calc(50% - 1059px/2) => Centered
                   - Top: 215px
                */}
                <div className="absolute top-[20%] lg:top-[25%] left-1/2 transform -translate-x-1/2 w-full max-w-6xl px-4 z-10 hidden md:block">
                    <div className="grid grid-cols-2 gap-6 lg:gap-12 w-full max-w-5xl mx-auto">
                        <Link href="/login?redirect=/services" className="group relative block w-full h-[120px] lg:h-[152px] bg-white border border-[#EF2F55] rounded-2xl hover:shadow-lg transition-all cursor-pointer">
                            <div className="absolute inset-0 flex flex-col items-center justify-center px-12">
                                <span className="font-sans font-semibold text-[24px] lg:text-[32px] leading-tight text-[#EF2F55] text-center">
                                    Login as User
                                </span>
                            </div>
                        </Link>
                        <Link href="/login?type=vendor" className="group relative block w-full h-[120px] lg:h-[152px] bg-white border border-[#EF2F55] rounded-2xl hover:shadow-lg transition-all cursor-pointer">
                            <div className="absolute inset-0 flex flex-col items-center justify-center px-12">
                                <span className="font-sans font-semibold text-[24px] lg:text-[32px] leading-tight text-[#EF2F55] text-center">
                                    Login as Vendor (Admin)
                                </span>
                            </div>
                        </Link>
                    </div>
                </div>

                {/* Mobile View - Stacked */}
                <div className="absolute top-[20%] w-full px-4 flex flex-col gap-6 md:hidden z-10">
                    <Link href="/login?redirect=/services" className="block w-full bg-white border border-[#EF2F55] rounded-xl p-6 shadow-md text-center">
                        <span className="block font-bold text-xl text-[#EF2F55] mb-2">Login as User</span>
                    </Link>
                    <Link href="/login?type=vendor" className="block w-full bg-white border border-[#EF2F55] rounded-xl p-6 shadow-md text-center">
                        <span className="block font-bold text-xl text-[#EF2F55] mb-2">Login as Vendor (Admin)</span>
                    </Link>
                </div>

            </div>


            <Footer />
        </div>
    );
}
