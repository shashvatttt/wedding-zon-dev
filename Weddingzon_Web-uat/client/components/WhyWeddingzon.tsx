'use client';

import React from 'react';
import Image from 'next/image';
import { motion } from 'framer-motion';
import FadeIn from '@/components/animations/FadeIn';

const FeatureCard = ({
    imageSrc,
    title,
}: {
    imageSrc: string,
    title: string,
}) => (
    <motion.div
        className="w-full h-full min-h-[300px] relative cursor-pointer"
        whileHover={{ scale: 1.05 }}
        transition={{ type: "spring", stiffness: 300, damping: 20 }}
    >
        <Image
            src={imageSrc}
            alt={title}
            fill
            className="object-contain"
        />
    </motion.div>
);



export default function WhyWeddingzon() {
    return (
        <section className="w-full relative py-16 md:py-24 overflow-hidden bg-[#FFF7F9]">
            {/* Background Image Container */}
            <div className="absolute inset-0 z-0">
                {/* Using the image provided by the user */}
                <Image
                    src="/images/home/Gemini_Generated_Image_d72rw2d72rw2d72r (1).png"
                    alt="Why Weddingzon Background"
                    fill
                    className="object-cover object-center"
                />
            </div>


            <div className="relative z-10 max-w-[1440px] mx-auto px-4 sm:px-8">
                {/* Header */}
                <div className="text-left mb-12 md:mb-20">
                    <h2 className="font-serif font-bold text-4xl sm:text-5xl md:text-7xl text-black leading-tight mb-4">
                        Why <span className="text-[#EF2F55]">Weddingzon</span>
                    </h2>
                    <p className="text-gray-600 text-base sm:text-lg md:text-xl">
                        Trusted by couples & vendors across India
                    </p>
                </div>

                {/* Features Grid - Desktop (Existing) */}
                <div className="hidden md:grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 lg:gap-8">
                    <FadeIn delay={0.1} className="h-full">
                        <FeatureCard
                            imageSrc="/images/home/WhyWZ/image1.png"
                            title="10+ Years Experience"
                        />
                    </FadeIn>
                    <FadeIn delay={0.2} className="h-full">
                        <FeatureCard
                            imageSrc="/images/home/WhyWZ/image2.png"
                            title="500+ Vendors"
                        />
                    </FadeIn>
                    <FadeIn delay={0.3} className="h-full">
                        <FeatureCard
                            imageSrc="/images/home/WhyWZ/image3.png"
                            title="Reliable Service"
                        />
                    </FadeIn>
                    <FadeIn delay={0.4} className="h-full">
                        <FeatureCard
                            imageSrc="/images/home/WhyWZ/image4.png"
                            title="20,000+ Clients"
                        />
                    </FadeIn>
                </div>

                {/* Features Grid - Mobile (Images Only) */}
                <div className="md:hidden grid grid-cols-2 gap-4">
                    {/* 10+ Years */}
                    <div className="bg-white rounded-[9.4px] shadow-[0px_0px_2.95px_rgba(0,0,0,0.25)] p-4 flex items-center justify-center">
                        <div className="w-full aspect-[115/98] relative">
                            <Image src="/images/home/WhyWZ/image1.png" alt="10+ Years Experience" fill className="object-contain" />
                        </div>
                    </div>

                    {/* 500+ Vendors */}
                    <div className="bg-white rounded-[9.4px] shadow-[0px_0px_2.95px_rgba(0,0,0,0.25)] p-4 flex items-center justify-center">
                        <div className="w-full aspect-[115/98] relative">
                            <Image src="/images/home/WhyWZ/image2.png" alt="500+ Vendors" fill className="object-contain" />
                        </div>
                    </div>

                    {/* Reliable Service */}
                    <div className="bg-white rounded-[9.4px] shadow-[0px_0px_2.95px_rgba(0,0,0,0.25)] p-4 flex items-center justify-center">
                        <div className="w-full aspect-[115/98] relative">
                            <Image src="/images/home/WhyWZ/image3.png" alt="Reliable Service" fill className="object-contain" />
                        </div>
                    </div>

                    {/* 20,000+ Clients */}
                    <div className="bg-white rounded-[9.4px] shadow-[0px_0px_2.95px_rgba(0,0,0,0.25)] p-4 flex items-center justify-center">
                        <div className="w-full aspect-[115/98] relative">
                            <Image src="/images/home/WhyWZ/image4.png" alt="20,000+ Clients" fill className="object-contain" />
                        </div>
                    </div>
                </div>
            </div>
        </section >
    );
}
