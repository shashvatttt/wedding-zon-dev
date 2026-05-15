import Link from 'next/link';
import React from 'react';
import Image from 'next/image';

const MatrimonyHero = () => {

    // Updated categories to match translations and user request
    const categories = [
        "Businessman", "MNC Job", "Farmer", "Government Job",
        "Private Job", "Doctor", "NRI", "Other"
    ];

    return (
        <div className="relative w-full min-h-screen py-20 flex flex-col items-center justify-center">
            {/* Background Image */}
            <div className="absolute inset-0 z-0 overflow-hidden">
                <Image
                    src="/matrimony-hero-bg.png"
                    alt="Matrimony Hero Background"
                    fill
                    className="object-cover"
                />
                <div className="absolute inset-0 bg-black/20" />
            </div>

            {/* Top Right Register Button */}
            <div className="absolute top-24 right-4 z-20 sm:right-8 md:right-10">
                <Link href="/signup?role=member">
                    <button className="bg-[#EF2F55] text-white px-5 sm:px-6 py-2 rounded-md font-semibold hover:bg-rose-600 transition-colors shadow-lg text-sm sm:text-base">
                        Create Profile
                    </button>
                </Link>
            </div>

            {/* Hero Text */}
            <div className="relative z-10 text-center px-4 mb-10">
                <h1 className="text-white text-4xl md:text-6xl font-black mb-4 drop-shadow-xl font-serif">
                    Find Your Lifetime Partner
                </h1>
                <p className="text-white text-lg md:text-xl max-w-3xl mx-auto font-medium drop-shadow-md">
                    The most trusted matrimony platform helping you find the perfect match within your community and values.
                </p>
            </div>

            {/* Content - Buttons Grid */}
            <div className="relative z-10 w-full max-w-7xl mx-auto px-4 sm:px-8 mt-6">
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 lg:gap-8 max-w-6xl mx-auto">
                    {categories.map((cat, idx) => (
                        <Link
                            href={`/feed?occupation=${cat}`}
                            key={idx}
                            className="bg-white/90 backdrop-blur-sm text-[#EF2F55] font-bold py-3 sm:py-4 px-4 sm:px-6 rounded-[15px] sm:rounded-[20px] border-2 border-white shadow-lg hover:bg-[#EF2F55] hover:text-white hover:border-[#EF2F55] transition-all transform hover:-translate-y-1 text-base sm:text-lg block text-center"
                        >
                            {cat}
                        </Link>
                    ))}
                </div>

                <div className="mt-12 flex flex-col sm:flex-row justify-center items-center gap-6">
                    <Link href="/feed">
                        <button className="bg-white text-[#EF2F55] px-10 py-4 rounded-full font-black uppercase tracking-widest text-sm hover:bg-[#EF2F55] hover:text-white transition-all shadow-xl whitespace-nowrap">
                            Search Now
                        </button>
                    </Link>
                    <Link href="/explore">
                        <button className="bg-white text-[#EF2F55] px-10 py-4 rounded-full font-black uppercase tracking-widest text-sm hover:bg-[#EF2F55] hover:text-white transition-all shadow-xl whitespace-nowrap">
                            Advanced Filter
                        </button>
                    </Link>
                </div>
            </div>
        </div>
    );
};

export default MatrimonyHero;
