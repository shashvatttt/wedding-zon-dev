'use client';

import React from 'react';
import Image from 'next/image';
import { MapPin, Star } from 'lucide-react';
import { useRouter } from 'next/navigation';

export interface Vendor {
    _id: string;
    displayName: string;
    username: string;
    occupation: string;
    city: string;
    state: string;
    profilePhoto: string | null;
    vendor_details?: {
        business_name?: string;
        business_address?: string;
        service_type?: string;
        price_range?: string;
        experience_years?: number;
        working_hours?: string;
        description?: string;
        averageRating?: number;
        reviewCount?: number;
    };
    rating?: number;
    price?: number;
    is_franchise_created?: boolean;
}

interface VendorCardProps {
    vendor: Vendor;
    onClick?: () => void;
    className?: string; // Allow custom styling
    priority?: boolean;
}

export default function VendorCard({ vendor, onClick, className = '', priority }: VendorCardProps) {
    const router = useRouter();

    const handleClick = () => {
        if (onClick) {
            onClick();
        } else {
            router.push(`/${vendor.username}`);
        }
    };

    const displayName = vendor.vendor_details?.business_name || vendor.displayName || 'Vendor';
    const initials = displayName.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
    
    // Aesthetic fallback colors
    const getAvatarColor = (name: string) => {
        const colors = [
            'bg-rose-400', 'bg-fuchsia-400', 'bg-purple-400', 'bg-violet-400', 
            'bg-indigo-400', 'bg-blue-400', 'bg-sky-400', 'bg-cyan-400', 
            'bg-teal-400', 'bg-emerald-400'
        ];
        let hash = 0;
        for (let i = 0; i < name.length; i++) {
            hash = name.charCodeAt(i) + ((hash << 5) - hash);
        }
        return colors[Math.abs(hash) % colors.length];
    };

    return (
        <div
            onClick={handleClick}
            className={`w-full max-w-[350px] bg-white rounded-2xl shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all duration-300 cursor-pointer border border-gray-100 flex flex-col overflow-hidden ${className}`}
        >
            {/* Image Part */}
            <div className="relative h-[230px] bg-gray-100">
                {vendor.profilePhoto ? (
                    <Image
                        src={vendor.profilePhoto}
                        alt={displayName}
                        fill
                        className="object-cover"
                        priority={priority}
                    />
                ) : (
                    <div className={`w-full h-full flex items-center justify-center text-white text-6xl font-black tracking-tighter ${getAvatarColor(displayName)} opacity-90`}>
                        {initials}
                    </div>
                )}
                {/* Overlay Gradient */}
                <div className="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent opacity-60" />
                
                {/* Franchise Badge Overlay */}
                {vendor.is_franchise_created && (
                    <div className="absolute top-3 left-3 bg-white/90 backdrop-blur-sm border border-gray-100 text-gray-900 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider shadow-xl z-10 flex items-center gap-1">
                        <span className="w-1.5 h-1.5 bg-purple-600 rounded-full animate-pulse" />
                        Franchise Managed
                    </div>
                )}
            </div>

            {/* Info Part */}
            <div className="p-5 flex flex-col gap-2 relative">
                <div className="flex justify-between items-start gap-2">
                    <h3 className="font-medium text-xl text-gray-900 truncate flex-1">
                        {vendor.vendor_details?.business_name || vendor.displayName || 'Vendor'}
                    </h3>
                    <div className="flex items-center gap-1 bg-blue-50 px-2.5 py-1 rounded-full text-blue-600 text-[10px] font-bold border border-blue-100 uppercase tracking-wider shrink-0 shadow-sm">
                        Verified
                    </div>
                </div>

                <p className="text-sm text-[#EF2F55] font-semibold uppercase tracking-wide">
                    {vendor.vendor_details?.service_type || vendor.occupation || 'Vendor'}
                </p>

                <div className="flex flex-col gap-1 text-gray-500 text-sm mb-1">
                    <div className="flex items-center gap-1.5">
                        <MapPin className="w-4 h-4 text-gray-400" />
                        <span className="truncate">
                            {[vendor.city, vendor.state].filter(Boolean).join(', ') || 'Location N/A'}
                        </span>
                    </div>
                    {vendor.vendor_details?.business_address && (
                        <p className="text-xs text-gray-400 pl-5 truncate">{vendor.vendor_details.business_address}</p>
                    )}
                </div>

                {/* Rating Stars */}
                <div className="flex items-center gap-2">
                    {vendor.vendor_details?.averageRating && vendor.vendor_details.averageRating > 0 ? (
                        <>
                            <div className="flex gap-0.5 text-yellow-500">
                                {[1, 2, 3, 4, 5].map(s => (
                                    <Star
                                        key={s}
                                        className={`w-3.5 h-3.5 ${s <= (vendor.vendor_details?.averageRating || 0) ? 'fill-current' : 'fill-gray-200 text-gray-200 border-none'}`}
                                    />
                                ))}
                            </div>
                            <span className="text-gray-400 text-xs font-medium">
                                {vendor.vendor_details.averageRating} ({vendor.vendor_details.reviewCount})
                            </span>
                        </>
                    ) : (
                        <span className="text-gray-400 text-[10px] font-bold bg-gray-50 px-2 py-0.5 rounded-full uppercase tracking-widest border border-gray-100">
                            New Vendor
                        </span>
                    )}
                </div>

                <div className="flex items-center justify-between mt-3 pt-3 border-t border-gray-100">
                    <div className="flex flex-col">
                        <span className="text-[10px] text-gray-400 uppercase font-bold tracking-tight">Starting from</span>
                        <p className="text-[#EF2F55] font-bold text-lg leading-tight">
                            {vendor.vendor_details?.price_range ? (
                                <span>{vendor.vendor_details.price_range}</span>
                            ) : (
                                <span>₹ {vendor.price ? vendor.price.toLocaleString() : 'On Request'}</span>
                            )}
                        </p>
                    </div>
                    {vendor.vendor_details?.experience_years ? (
                        <span className="text-[11px] bg-rose-50 text-rose-600 px-3 py-1 rounded-full font-bold border border-rose-100/50 shadow-sm">
                            {vendor.vendor_details.experience_years} Yrs Exp
                        </span>
                    ) : null}
                </div>
            </div>
        </div>
    );
}
