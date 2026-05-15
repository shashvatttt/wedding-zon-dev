import React, { useState, useEffect, useCallback } from 'react';
import Image from 'next/image';
import { Star, Quote, ChevronLeft, ChevronRight } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

const testimonials = [
    {
        id: 1,
        name: "Mr. & Mrs. Kapoor",
        role: "Match found on WeddingZon",
        image: "https://images.unsplash.com/photo-1583939003579-730e3918a45a?auto=format&fit=crop&q=80&w=600&h=600",
        rating: 5,
        text: "Weddingzon made planning our wedding so much easier. We found trusted vendors, compared prices and reviews, and booked everything in one place. The support team was quick to respond and helped us at every step. Truly a great experience—highly recommended for any couple planning their big day!",
        category: "Couple"
    },
    {
        id: 2,
        name: "Varuna",
        role: "Makeup Artist, Chandigarh",
        image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=400&h=400",
        rating: 5,
        text: "After registering as a verified vendor, my business grew quickly. Thanks to Weddingzon for the leads and support. The platform is incredibly intuitive and connects you with direct clients looking for quality services.",
        category: "Vendor"
    },
    {
        id: 3,
        name: "Mr. & Mrs. Gupta",
        role: "Match found on WeddingZon",
        image: "https://images.unsplash.com/photo-1621112904887-419379ce6824?auto=format&fit=crop&q=80&w=600&h=450",
        rating: 5,
        text: "Weddingzon made our wedding planning stress-free. We found amazing vendors, compared options easily, and everything turned out perfect. Highly recommended for couples who want a seamless planning experience!",
        category: "Couple"
    },
    {
        id: 4,
        name: "Dhanush",
        role: "Mehndi Artist, Delhi",
        image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=400&h=400",
        rating: 5,
        text: "The exposure I've received through Weddingzon has been phenomenal. I've been able to connect with clients I never would have reached otherwise. The leads are high quality and the support is top-notch.",
        category: "Vendor"
    },
    {
        id: 5,
        name: "Singh Home Decor",
        role: "Home Decors, Ludhiana",
        image: "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&q=80&w=600&h=400",
        rating: 5,
        text: "Partnering with Weddingzon has been a great boost for our home décor business. We started receiving quality leads, connected with genuine customers, and closed more projects in less time.",
        category: "Vendor"
    },
    {
        id: 6,
        name: "Karan Caters",
        role: "Catering Service, Ghaziabad",
        image: "https://images.unsplash.com/photo-1595152772835-219674b2a8a6?auto=format&fit=crop&q=80&w=400&h=400",
        rating: 5,
        text: "Partnering with Weddingzon has been a great boost for our catering service. We started receiving quality leads, connected with genuine customers, and confirmed more bookings in less time.",
        category: "Vendor"
    },
    {
        id: 7,
        name: "Shubh Decorators",
        role: "Event Planner, Sirsa",
        image: "https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&q=80&w=400&h=400",
        rating: 5,
        text: "WeddingZon has given us the platform to showcase our work to the right audience. The quality of leads is excellent, and it has helped us secure several high-profile wedding contracts.",
        category: "Vendor"
    }
];

const Rating = ({ rating }: { rating: number }) => (
    <div className="flex gap-1">
        {[...Array(5)].map((_, i) => (
            <Star key={i} size={16} className={`${i < rating ? 'fill-yellow-400 text-yellow-400' : 'text-gray-300'}`} />
        ))}
    </div>
);

export default function ClientTestimonials() {
    const [currentIndex, setCurrentIndex] = useState(0);
    const [direction, setDirection] = useState(0); // -1 for left, 1 for right

    const nextSlide = useCallback(() => {
        setDirection(1);
        setCurrentIndex((prev) => (prev + 1) % testimonials.length);
    }, []);

    const prevSlide = useCallback(() => {
        setDirection(-1);
        setCurrentIndex((prev) => (prev - 1 + testimonials.length) % testimonials.length);
    }, []);

    useEffect(() => {
        const timer = setInterval(() => {
            nextSlide();
        }, 5000);
        return () => clearInterval(timer);
    }, [nextSlide]);

    const variants = {
        enter: (direction: number) => ({
            x: direction > 0 ? 1000 : -1000,
            opacity: 0
        }),
        center: {
            zIndex: 1,
            x: 0,
            opacity: 1
        },
        exit: (direction: number) => ({
            zIndex: 0,
            x: direction < 0 ? 1000 : -1000,
            opacity: 0
        })
    };

    const current = testimonials[currentIndex];

    return (
        <section className="w-full bg-[#FFF5F7] py-16 md:py-24 overflow-hidden relative">
            {/* Background Decorative Element */}
            <div className="absolute top-0 right-0 w-64 h-64 bg-pink-100 rounded-full blur-3xl opacity-30 -mr-32 -mt-32"></div>
            <div className="absolute bottom-0 left-0 w-96 h-96 bg-white rounded-full blur-3xl opacity-50 -ml-48 -mb-48"></div>

            <div className="max-w-[1440px] mx-auto px-4 sm:px-8 relative z-10">
                <h2 className="font-serif text-5xl md:text-7xl text-black mb-16 md:mb-20 text-center md:text-left">
                    Client Testimonials
                </h2>

                {/* Desktop Grid View (md and above) */}
                <div className="hidden md:grid md:grid-cols-3 gap-8 items-start mb-12">
                    {/* Column 1 */}
                    <div className="flex flex-col gap-12">
                        {/* Varuna */}
                        <div className="relative ml-8">
                            <div className="absolute -left-10 top-1/2 -translate-y-1/2 w-20 h-20 rounded-full border-4 border-white overflow-hidden shadow-xl z-10 transition-transform duration-300 hover:scale-110 hover:shadow-pink-200/50">
                                <Image
                                    src={testimonials[1].image}
                                    alt={testimonials[1].name}
                                    width={80}
                                    height={80}
                                    className="w-full h-full object-cover"
                                />
                            </div>
                            <div className="bg-white rounded-xl shadow-lg p-6 relative pl-14 pr-6 py-6">
                                <div className="flex justify-between items-start mb-2">
                                    <div>
                                        <h3 className="font-bold text-lg text-gray-900">{testimonials[1].name}</h3>
                                        <p className="text-xs text-gray-500">{testimonials[1].role}</p>
                                    </div>
                                    <Quote className="text-pink-200 fill-pink-200 rotate-180" size={32} />
                                </div>
                                <div className="mb-3"><Rating rating={testimonials[1].rating} /></div>
                                <p className="text-sm text-gray-600 leading-relaxed">
                                    {testimonials[1].text}
                                </p>
                            </div>
                        </div>

                        {/* Gupta */}
                        <div className="bg-white rounded-xl shadow-lg overflow-hidden flex flex-col group border border-pink-50">
                            <div className="w-full relative aspect-[4/3]">
                                <Image
                                    src={testimonials[2].image}
                                    alt={testimonials[2].name}
                                    fill
                                    className="object-cover object-top"
                                />
                            </div>
                            <div className="p-6">
                                <h3 className="font-bold text-xl text-gray-900 mb-0.5">{testimonials[2].name}</h3>
                                <p className="text-sm text-gray-500 mb-3">{testimonials[2].role}</p>
                                <div className="mb-3"><Rating rating={testimonials[2].rating} /></div>
                                <p className="text-sm text-gray-600 leading-relaxed">
                                    {testimonials[2].text}
                                </p>
                            </div>
                        </div>
                    </div>

                    {/* Column 2 */}
                    <div className="flex flex-col gap-12 mt-8 lg:mt-0">
                        {/* Kapoor */}
                        <div className="relative pt-12">
                            <div className="absolute top-0 left-1/2 -translate-x-1/2 w-28 h-28 rounded-full border-4 border-white overflow-hidden shadow-xl z-10 transition-transform duration-300 hover:scale-110 hover:shadow-pink-200/50">
                                <Image
                                    src={testimonials[0].image}
                                    alt={testimonials[0].name}
                                    width={112}
                                    height={112}
                                    className="w-full h-full object-cover"
                                />
                            </div>
                            <div className="bg-white rounded-xl shadow-lg p-6 relative pt-20 pb-10 px-8 text-center">
                                <h3 className="font-bold text-xl text-gray-900 mb-1">{testimonials[0].name}</h3>
                                <p className="text-xs text-gray-500 mb-4">{testimonials[0].role}</p>
                                <div className="flex justify-center mb-6"><Rating rating={testimonials[0].rating} /></div>
                                <p className="text-gray-600 text-sm leading-relaxed">
                                    {testimonials[0].text}
                                </p>
                            </div>
                        </div>

                        {/* Singh Home Decor */}
                        <div className="bg-white rounded-xl shadow-lg overflow-hidden flex flex-row items-center border border-pink-50">
                            <div className="w-1/3 min-h-[160px] relative">
                                <Image
                                    src={testimonials[4].image}
                                    alt={testimonials[4].name}
                                    fill
                                    className="object-cover"
                                />
                            </div>
                            <div className="w-2/3 p-5">
                                <div className="mb-2"><Rating rating={testimonials[4].rating} /></div>
                                <h3 className="font-bold text-lg text-gray-900">{testimonials[4].name}</h3>
                                <p className="text-xs text-gray-500 mb-2">{testimonials[4].role}</p>
                                <p className="text-[10px] sm:text-xs text-gray-600 leading-relaxed">
                                    {testimonials[4].text}
                                </p>
                            </div>
                        </div>

                        {/* Karan Caters - Moved to Column 2 */}
                        <div className="bg-white rounded-xl shadow-lg p-6 relative">
                            <div className="flex justify-between items-start mb-2">
                                <div>
                                    <h3 className="font-bold text-lg text-gray-900">{testimonials[5].name}</h3>
                                    <p className="text-xs text-gray-500">{testimonials[5].role}</p>
                                </div>
                                <Rating rating={testimonials[5].rating} />
                            </div>
                            <p className="text-sm text-gray-600 leading-relaxed">
                                {testimonials[5].text}
                            </p>
                        </div>
                    </div>

                    {/* Column 3 */}
                    <div className="flex flex-col gap-12">
                        {/* Dhanush - Moved to Column 3 */}
                        <div className="relative mr-8">
                            <div className="absolute -right-10 top-1/2 -translate-y-1/2 w-20 h-20 rounded-full border-4 border-white overflow-hidden shadow-xl z-10 transition-transform duration-300 hover:scale-110 hover:shadow-pink-200/50">
                                <Image
                                    src={testimonials[3].image}
                                    alt={testimonials[3].name}
                                    width={80}
                                    height={80}
                                    className="w-full h-full object-cover"
                                />
                            </div>
                            <div className="bg-white rounded-xl shadow-lg p-6 relative pr-14 pl-6 py-6 text-right">
                                <div className="mb-2">
                                    <h3 className="font-bold text-lg text-gray-900">{testimonials[3].name}</h3>
                                    <p className="text-xs text-gray-500">{testimonials[3].role}</p>
                                </div>
                                <p className="text-sm text-gray-600 leading-relaxed mb-3">
                                    {testimonials[3].text}
                                </p>
                                <div className="flex justify-end"><Rating rating={testimonials[3].rating} /></div>
                            </div>
                        </div>

                        {/* Pankaj Studio */}
                        <div className="rounded-full bg-white shadow-lg p-3 pr-8 flex items-center gap-4">
                            <div className="w-16 h-16 rounded-full overflow-hidden flex-shrink-0 border-2 border-pink-100 relative shadow-md transition-transform duration-300 hover:scale-110">
                                <Image
                                    src="https://images.unsplash.com/photo-1598550880863-4e8aa3d0edb4?auto=format&fit=crop&q=80&w=400&h=400"
                                    alt="Pankaj Studio"
                                    fill
                                    className="object-cover"
                                />
                            </div>
                            <div>
                                <h3 className="font-bold text-lg text-gray-900">Pankaj Studio</h3>
                                <p className="text-xs text-gray-500 mb-1">Photographer, Kanpur</p>
                                <Rating rating={5} />
                                <p className="text-xs text-gray-600 mt-1">Best Services Top class!!!</p>
                            </div>
                        </div>

                        {/* Hemant */}
                        <div className="relative">
                            <div className="bg-white rounded-xl shadow-lg p-6 relative rounded-bl-none">
                                <h3 className="font-bold text-lg text-gray-900">Hemant</h3>
                                <p className="text-xs text-gray-500 mb-3">Wedding Planner, Sirsa</p>
                                <div className="mb-3"><Rating rating={5} /></div>
                                <p className="text-sm text-gray-600 leading-relaxed">
                                    I took the most popular package on Weddingzon and it is totally useful. For beginners like me, it would be very helpful to have a support like Weddingzon to get more clients. I would recommend this platform to everyone looking to grow their business quickly.
                                </p>
                            </div>
                            <div className="absolute -bottom-8 left-0">
                                <Quote className="text-[#BFA8AB] fill-[#BFA8AB] rotate-180" size={48} />
                            </div>
                            <div className="absolute -bottom-16 -right-4 w-16 h-16 rounded-full border-4 border-white overflow-hidden shadow-xl transition-transform duration-300 hover:scale-110 hover:shadow-pink-200/50">
                                <div className="w-full h-full relative">
                                    <Image
                                        src="https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=400&h=400"
                                        alt="Hemant"
                                        fill
                                        className="object-cover"
                                    />
                                </div>
                            </div>
                        </div>

                        {/* Shubh Decorators */}
                        <div className="bg-white rounded-xl shadow-lg p-6 relative flex flex-col border border-pink-50">
                            <div className="flex items-center gap-4 mb-4">
                                <div className="w-16 h-16 rounded-full overflow-hidden border-2 border-pink-100 relative">
                                    <Image
                                        src={testimonials[6].image}
                                        alt={testimonials[6].name}
                                        fill
                                        className="object-cover"
                                    />
                                </div>
                                <div className="flex flex-col">
                                    <h3 className="font-bold text-lg text-gray-900">{testimonials[6].name}</h3>
                                    <p className="text-xs text-gray-500">{testimonials[6].role}</p>
                                </div>
                            </div>
                            <div className="mb-3"><Rating rating={testimonials[6].rating} /></div>
                            <p className="text-sm text-gray-600 leading-relaxed">
                                {testimonials[6].text}
                            </p>
                        </div>
                    </div>
                </div>

                {/* Mobile View Toggle Section */}
                <div className="md:hidden">
                    <div className="flex justify-between items-center mb-8">
                        <div className="flex gap-4 ml-auto">
                            <button
                                onClick={prevSlide}
                                className="w-10 h-10 rounded-full border border-pink-200 flex items-center justify-center text-pink-600 hover:bg-pink-600 hover:text-white transition-all shadow-sm"
                            >
                                <ChevronLeft size={20} />
                            </button>
                            <button
                                onClick={nextSlide}
                                className="w-10 h-10 rounded-full border border-pink-200 flex items-center justify-center text-pink-600 hover:bg-pink-600 hover:text-white transition-all shadow-sm"
                            >
                                <ChevronRight size={20} />
                            </button>
                        </div>
                    </div>

                    <div className="relative h-[600px] flex items-center justify-center">
                        <AnimatePresence initial={false} custom={direction}>
                            <motion.div
                                key={currentIndex}
                                custom={direction}
                                variants={variants}
                                initial="enter"
                                animate="center"
                                exit="exit"
                                transition={{
                                    x: { type: "spring", stiffness: 300, damping: 30 },
                                    opacity: { duration: 0.2 }
                                }}
                                className="absolute w-full"
                            >
                                <div className="bg-white rounded-3xl shadow-xl overflow-hidden flex flex-col items-stretch border border-pink-50">
                                    {/* Image Section */}
                                    <div className="h-[250px] relative overflow-hidden bg-pink-50">
                                        <Image
                                            src={current.image}
                                            alt={current.name}
                                            fill
                                            className="object-cover"
                                            unoptimized={current.image.startsWith('http')}
                                        />
                                        <div className="absolute top-4 left-4">
                                            <div className="bg-[#EF2F55] text-white text-[10px] font-bold uppercase tracking-wider px-3 py-1.5 rounded-full shadow-lg">
                                                {current.category}
                                            </div>
                                        </div>
                                    </div>

                                    {/* Content Section */}
                                    <div className="p-8 flex flex-col justify-center relative bg-white">
                                        <Quote className="absolute top-4 right-4 text-pink-50 w-16 h-16 opacity-50" />

                                        <div className="mb-4">
                                            <Rating rating={current.rating} />
                                        </div>

                                        <p className="text-base text-gray-700 italic leading-relaxed mb-6 font-light">
                                            "{current.text}"
                                        </p>

                                        <div>
                                            <h3 className="text-xl font-bold text-gray-900 mb-0.5">{current.name}</h3>
                                            <p className="text-sm text-gray-500">{current.role}</p>
                                        </div>
                                    </div>
                                </div>
                            </motion.div>
                        </AnimatePresence>
                    </div>

                    {/* Progress Indicators */}
                    <div className="flex justify-center gap-2 mt-8">
                        {testimonials.map((_, index) => (
                            <button
                                key={index}
                                onClick={() => {
                                    setDirection(index > currentIndex ? 1 : -1);
                                    setCurrentIndex(index);
                                }}
                                className={`h-1.5 transition-all duration-300 rounded-full ${index === currentIndex ? 'w-8 bg-[#EF2F55]' : 'w-1.5 bg-pink-200 hover:bg-pink-300'
                                    }`}
                                aria-label={`Go to testimonial ${index + 1}`}
                            />
                        ))}
                    </div>
                </div>
            </div>
        </section>
    );
}
