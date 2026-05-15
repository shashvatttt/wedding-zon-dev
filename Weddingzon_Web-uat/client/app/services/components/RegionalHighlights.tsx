'use client';

import React from 'react';
import Image from 'next/image';
import { MapPin, ChevronRight, Sparkles, Star, User } from 'lucide-react';

interface Vendor {
    _id: string;
    displayName: string;
    username: string;
    occupation: string;
    city: string;
    state: string;
    profilePhoto: string | null;
}

interface Destination {
    id: string;
    name: string;
    state: string;
    attraction: string;
    description: string;
    image: string;
    vendorsCount: string;
}

const destinations: Destination[] = [
    {
        id: 'rajasthan',
        name: 'Jaipur & Udaipur',
        state: 'Rajasthan',
        attraction: 'Palatial Grandeur',
        description: 'Experience royal weddings in majestic palaces and desert forts under golden sunsets.',
        image: '/regional-rajasthan.png',
        vendorsCount: '500+'
    },
    {
        id: 'up',
        name: 'Agra & Lucknow',
        state: 'Uttar Pradesh',
        attraction: 'Timeless Heritage',
        description: 'Exchange vows near the Taj Mahal or in the cultured elegance of Awadhi architecture.',
        image: '/regional-up.png',
        vendorsCount: '350+'
    },
    {
        id: 'delhi',
        name: 'New Delhi',
        state: 'Delhi',
        attraction: 'Cosmopolitan Charm',
        description: 'Lush farmhouse weddings and luxury city hotels blending modern flair with historic charm.',
        image: '/regional-delhi.png',
        vendorsCount: '600+'
    }
];

export default function RegionalHighlights({ 
    vendors,
    onSearchState 
}: { 
    vendors: {
        rajasthan: Vendor[];
        up: Vendor[];
        delhi: Vendor[];
    };
    onSearchState: (state: string) => void 
}) {
    return (
        <section className="py-24 bg-[#FFF9FA]">
            <div className="max-w-[1440px] mx-auto px-4 sm:px-8">
                <div className="flex flex-col md:flex-row justify-between items-center md:items-end mb-16 gap-4">
                    <div className="text-center md:text-left">
                        <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-pink-100 text-[#EF2F55] text-sm font-bold uppercase tracking-wider mb-4">
                            <Sparkles className="w-4 h-4" /> 
                            <span>Wedding Destinations</span>
                        </div>
                        <h2 className="text-4xl md:text-5xl font-serif font-black text-gray-900 leading-tight">
                            Regional <span className="text-[#EF2F55]">Highlights</span>
                        </h2>
                        <p className="text-lg text-gray-600 mt-4 max-w-2xl font-medium">
                            Explore iconic wedding locations and connect with verified local professionals.
                        </p>
                    </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                    {destinations.map((dest) => {
                        const regionalVendors = dest.id === 'rajasthan' ? vendors.rajasthan : dest.id === 'up' ? vendors.up : vendors.delhi;
                        
                        return (
                            <div 
                                key={dest.id}
                                className="group relative flex flex-col h-auto rounded-[32px] overflow-hidden shadow-2xl hover:shadow-pink-100/50 transition-all duration-500"
                            >
                                {/* card image part */}
                                <div className="relative h-[350px] overflow-hidden shrink-0">
                                    <Image
                                        src={dest.image}
                                        alt={dest.name}
                                        fill
                                        className="object-cover group-hover:scale-110 transition-transform duration-700"
                                    />
                                    <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent" />
                                    
                                    <div className="absolute top-6 left-6 px-4 py-2 bg-white/20 backdrop-blur-md border border-white/30 rounded-2xl text-white text-[10px] font-bold uppercase tracking-widest">
                                        {dest.attraction}
                                    </div>

                                    <div className="absolute bottom-6 left-6 right-6">
                                        <div className="flex items-center gap-2 text-pink-300 font-bold text-xs uppercase tracking-widest mb-1">
                                            <MapPin className="w-3 h-3" />
                                            <span>{dest.state}</span>
                                        </div>
                                        <h3 className="text-2xl font-serif font-bold text-white mb-2">{dest.name}</h3>
                                    </div>
                                </div>

                                {/* vendors list part */}
                                <div className="bg-white p-6 flex-1 flex flex-col">
                                    <h4 className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4 flex items-center gap-2">
                                        <Star className="w-3 h-3 text-pink-500 fill-pink-500" />
                                        Featured Vendors in {dest.state}
                                    </h4>

                                    <div className="space-y-4 mb-6">
                                        {regionalVendors && regionalVendors.length > 0 ? (
                                            regionalVendors.map((v) => (
                                                <div 
                                                    key={v._id} 
                                                    className="flex items-center gap-3 p-3 rounded-2xl bg-gray-50 border border-gray-100 hover:border-pink-200 hover:bg-pink-50 transition-all cursor-pointer"
                                                    onClick={() => window.open(`/${v.username}`, '_blank')}
                                                >
                                                    <div className="w-10 h-10 rounded-full bg-gray-200 overflow-hidden relative border-2 border-white shadow-sm shrink-0">
                                                        {v.profilePhoto ? (
                                                            <Image src={v.profilePhoto} alt={v.displayName} fill className="object-cover" />
                                                        ) : (
                                                            <div className="w-full h-full flex items-center justify-center bg-pink-50">
                                                                <User className="w-5 h-5 text-pink-300" />
                                                            </div>
                                                        )}
                                                    </div>
                                                    <div className="min-w-0">
                                                        <p className="text-sm font-bold text-gray-900 truncate">{v.displayName || v.username}</p>
                                                        <p className="text-[10px] font-medium text-gray-500 uppercase tracking-tighter">{v.occupation}</p>
                                                    </div>
                                                    <ChevronRight className="w-4 h-4 text-gray-300 ml-auto" />
                                                </div>
                                            ))
                                        ) : (
                                            <div className="py-8 text-center text-gray-400 italic text-sm bg-gray-50 rounded-2xl border border-dashed border-gray-200">
                                                New Vendors Joining Soon!
                                            </div>
                                        )}
                                    </div>

                                    <div className="mt-auto pt-4 border-t border-gray-100 flex items-center justify-between">
                                        <div className="text-[10px] font-black text-[#EF2F55] uppercase tracking-widest">
                                            {dest.vendorsCount} LISTINGS
                                        </div>
                                        <button
                                            onClick={() => onSearchState(dest.state)}
                                            className="inline-flex items-center gap-2 bg-[#EF2F55] hover:bg-rose-700 text-white px-5 py-2.5 rounded-xl font-bold text-xs transition-all shadow-md active:scale-95 group/btn"
                                        >
                                            View All 
                                            <ChevronRight className="w-3 h-3 transform group-hover/btn:translate-x-1 transition-transform" />
                                        </button>
                                    </div>
                                </div>
                            </div>
                        );
                    })}
                </div>
            </div>
        </section>
    );
}
