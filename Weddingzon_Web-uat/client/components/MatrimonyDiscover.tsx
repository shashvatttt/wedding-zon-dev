import React from 'react';
import { ShieldCheck, CheckCircle, Clock } from 'lucide-react';

const MatrimonyDiscover = () => {
    const stats = [
        {
            icon: <ShieldCheck className="w-12 h-12 text-[#EF2F55]" />,
            title: "Verified Profiles",
            desc: "100% verified members for a secure search experience"
        },
        {
            icon: <CheckCircle className="w-12 h-12 text-[#EF2F55]" />,
            title: "Advanced Search",
            desc: "Smart filters to find exactly who you're looking for"
        },
        {
            icon: <Clock className="w-12 h-12 text-[#EF2F55]" />,
            title: "Secure Platform",
            desc: "Your privacy is our top priority with industry-standard security"
        },
        {
            icon: <div className="text-4xl font-bold text-[#EF2F55]">200+</div>,
            title: "Happily married",
            desc: "Loved by Thousands"
        }
    ];

    return (
        <div className="bg-[#FFF5F5] py-20 relative overflow-hidden">
            {/* Decorative background pattern */}
            <div className="absolute inset-0 z-0 pointer-events-none">
                <img src="/matrimony-discover-bg.png" alt="Background" className="w-full h-full object-cover opacity-20" />
            </div>

            <div className="container mx-auto px-4 text-center relative z-10">
                <h2 className="font-serif text-5xl font-bold text-black mb-6">Discover Your Perfect Match</h2>

                <p className="max-w-3xl mx-auto text-gray-700 text-lg mb-16 leading-relaxed">
                    Join thousands of happy couples who found their life partners on WeddingZon. Our platform is designed to make your journey to marriage smooth and joyful.
                </p>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
                    {stats.map((item, idx) => (
                        <div key={idx} className="bg-white p-8 rounded-2xl shadow-sm hover:shadow-md transition-shadow flex flex-col items-center">
                            <div className="mb-4">
                                {item.icon}
                            </div>
                            <h3 className="font-bold text-xl text-black">{item.title}</h3>
                            <p className="text-gray-500 text-sm mt-2">{item.desc}</p>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
};

export default MatrimonyDiscover;
