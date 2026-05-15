import React from 'react';
import Image from 'next/image';
import { Star } from 'lucide-react';

const MatrimonyTestimonials = () => {
    const reviews = [
        {
            name: "Mr. & Mrs. Kapoor",
            image: "https://images.unsplash.com/photo-1583939003579-730e3918a45a?auto=format&fit=crop&q=80&w=200&h=200",
            text: "WeddingZon helped me find my perfect life partner. The platform's security and detailed profiles made the process so much easier. We highly recommend it!"
        },
        {
            name: "Mr. & Mrs. Sharma",
            image: "https://images.unsplash.com/photo-1621112904887-419379ce6824?auto=format&fit=crop&q=80&w=200&h=200",
            text: "Finding a compatible match was effortless with WeddingZon. The filters helped us narrow down exactly what we were looking for. Thank you for this amazing service!"
        },
        {
            name: "Mr. & Mrs. Verma",
            image: "https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&q=80&w=200&h=200",
            text: "We are so grateful to WeddingZon for bringing us together. The platform is user-friendly and very trustworthy. A must-use for anyone looking for serious matches."
        }
    ];

    return (
        <div className="bg-[#FFF5F5] py-20 pb-32">
            <div className="container mx-auto px-4">
                <h2 className="font-serif text-5xl font-bold text-black mb-16 text-center">Success Stories</h2>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                    {reviews.map((review, idx) => (
                        <div key={idx} className="bg-white p-8 rounded-xl shadow-xl relative flex flex-col items-center text-center mt-10">
                            {/* Profile Image - Absolute positioned to overlap top */}
                            <div className="absolute -top-12 w-24 h-24 rounded-full border-4 border-white overflow-hidden shadow-xl transition-all duration-300 hover:scale-110 hover:shadow-pink-200/50">
                                <Image
                                    src={review.image}
                                    alt={review.name}
                                    width={96}
                                    height={96}
                                    className="object-cover"
                                    unoptimized
                                />
                            </div>

                            <div className="mt-12">
                                <h3 className="font-bold text-lg text-black">{review.name}</h3>
                                <p className="text-xs text-gray-400 uppercase tracking-wider mb-3">Found their match on WeddingZon</p>

                                <div className="flex justify-center gap-1 mb-4">
                                    {[1, 2, 3, 4, 5].map(s => <Star key={s} size={16} className="text-yellow-400 fill-yellow-400" />)}
                                </div>

                                <p className="text-gray-600 text-sm leading-relaxed italic">
                                    "{review.text}"
                                </p>
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
};

export default MatrimonyTestimonials;
