'use client';

import Link from 'next/link';
import { ChevronRight } from 'lucide-react';

export default function FeedRightSidebar() {
    const services = [
        { name: "Photographers", href: '/services#photographers' },
        { name: "Makeup Artists", href: '/services#makeup' },
        { name: "Baraat Band", href: '/services' },
        { name: "Ghodi Wale", href: '/services' },
    ];

    return (
        <div className="w-[222px]">
            <div className="bg-white rounded-2xl shadow-sm p-6 h-[834px]"> {/* Fixed height from design, but maybe auto is better? */}
                <h3 className="font-inter font-medium text-xl text-black mb-6">Our Services</h3>

                <div className="space-y-6">
                    {services.map((service, idx) => (
                        <Link
                            key={idx}
                            href={service.href}
                            className="flex items-center justify-between group cursor-pointer"
                        >
                            <span className="text-sm font-medium text-[#111827] group-hover:text-[#EF2F55] transition-colors">
                                {service.name}
                            </span>
                            <ChevronRight className="w-4 h-4 text-[#111827] group-hover:text-[#EF2F55] transition-colors" />
                        </Link>
                    ))}
                </div>
            </div>
        </div>
    );
}
