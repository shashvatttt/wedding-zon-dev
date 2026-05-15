'use client';

import Image from 'next/image';
import { ExternalLink, Info } from 'lucide-react';
import { motion } from 'framer-motion';

interface AdCardProps {
    ad: {
        _id: string;
        title: string;
        imageUrl: string;
        link?: string;
    };
}

export default function AdCard({ ad }: AdCardProps) {
    const handleClick = () => {
        if (ad.link) {
            window.open(ad.link, '_blank');
        }
    };

    return (
        <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.4 }}
            className="bg-white rounded-[32px] border border-rose-100 shadow-[0_10px_30px_rgba(239,47,85,0.05)] overflow-hidden mb-6 relative group cursor-pointer"
            onClick={handleClick}
        >
            {/* Ad Label */}
            <div className="absolute top-4 right-4 z-10 bg-white/80 backdrop-blur-sm border border-rose-100 px-3 py-1 rounded-full flex items-center gap-1.5 shadow-sm">
                <Info className="w-3 h-3 text-rose-500" />
                <span className="text-[11px] font-bold text-rose-600 tracking-wider uppercase">Sponsored</span>
            </div>

            <div className="flex flex-col md:flex-row h-full">
                {/* Image Section */}
                <div className="w-full md:w-[280px] aspect-[4/3] md:h-[210px] relative overflow-hidden bg-gray-50 border-r border-rose-50">
                    <Image
                        src={ad.imageUrl}
                        alt={ad.title}
                        fill
                        className="object-cover transition-transform duration-700 group-hover:scale-105"
                    />
                </div>

                {/* Details Section */}
                <div className="flex-1 flex flex-col justify-center p-6 md:p-8 space-y-4">
                    <div className="space-y-2">
                        <h3 className="font-bold text-[24px] md:text-[28px] text-gray-900 leading-tight">
                            {ad.title}
                        </h3>
                        {ad.link && (
                            <p className="text-rose-500 font-medium text-sm flex items-center gap-1">
                                {new URL(ad.link).hostname} <ExternalLink className="w-3 h-3" />
                            </p>
                        )}
                    </div>

                    <div className="pt-2">
                        <button className="bg-[#EF2F55] hover:bg-[#D41F45] text-white rounded-full px-8 py-3 text-[16px] font-bold shadow-lg shadow-pink-100 transition-all active:scale-95 flex items-center gap-2">
                            Learn More
                            <ExternalLink className="w-4 h-4" />
                        </button>
                    </div>
                </div>
            </div>

            {/* Decorative element */}
            <div className="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-[#EF2F55] to-rose-400 opacity-20" />
        </motion.div>
    );
}
