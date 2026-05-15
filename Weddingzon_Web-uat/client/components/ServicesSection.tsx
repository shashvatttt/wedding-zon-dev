'use client';

import Image from 'next/image';
import Link from 'next/link';
import { StaggerContainer, StaggerItem } from './animations/StaggerContainer';

const services = [
    {
        id: 1,
        title: 'Matrimonial',
        frontImage: '/images/service-matrimony-front.png',
        backImage: '/images/service-matrimony-back.png',
        link: '/matrimony',
    },
    {
        id: 2,
        title: 'Vendors',
        frontImage: '/images/service-vendors-front.png',
        backImage: '/images/service-vendors-back.png',
        link: '/vendor',
    },
    {
        id: 3,
        title: 'Franchise',
        frontImage: '/images/service-franchise-front.png',
        backImage: '/images/service-franchise-back.png',
        link: '/franchise/entry',
    },
    {
        id: 4,
        title: 'Shopping',
        frontImage: '/images/service-shopping-front.png',
        backImage: '/images/service-shopping-back.png',
        link: '/shop',
    },
];

export default function ServicesSection() {
    return (
        <section className="w-full bg-white py-16 md:py-24 relative overflow-hidden flex flex-col items-center">

            {/* Pink Background Rectangle */}
            <div className="w-[90%] max-w-[1240px] bg-[#FFF0F5] py-16 md:py-24 px-8 md:px-16 rounded-[40px] relative flex flex-col items-center">

                {/* Decorative Heading */}
                <div className="w-full text-left mb-12">
                    <h2 className="font-serif font-bold text-4xl sm:text-5xl md:text-7xl text-gray-900 leading-tight">
                        Our Services
                    </h2>
                </div>

                {/* Desktop Cards Grid Container - Using negative margins on large screens to overflow the pink box */}
                <StaggerContainer className="hidden sm:grid w-full lg:w-[115%] lg:-mx-[7.5%] relative z-10 grid-cols-2 lg:grid-cols-4 gap-6 md:gap-8">
                    {services.map((service) => (
                        <StaggerItem key={service.id}>
                            <Link href={service.link} className="group h-[350px] md:h-[400px] w-full perspective-1000 cursor-pointer block">
                                {/* Inner Flip Container */}
                                <div className="relative w-full h-full duration-700 transition-all transform-style-3d group-hover:rotate-y-180 rounded-3xl shadow-xl">
                                    {/* Front Side */}
                                    <div className="absolute inset-0 w-full h-full backface-hidden rounded-3xl overflow-hidden bg-white">
                                        <Image
                                            src={service.frontImage}
                                            alt={service.title}
                                            fill
                                            className="object-cover"
                                            quality={100}
                                            unoptimized
                                        />
                                    </div>

                                    {/* Back Side */}
                                    <div className="absolute inset-0 w-full h-full backface-hidden rotate-y-180 rounded-3xl overflow-hidden bg-white hover:border-2 hover:border-[#EF2F55] transition-all">
                                        <Image
                                            src={service.backImage}
                                            alt={`${service.title} details`}
                                            fill
                                            className="object-cover"
                                            quality={100}
                                            unoptimized
                                        />
                                    </div>
                                </div>
                            </Link>
                        </StaggerItem>
                    ))}
                </StaggerContainer>

                {/* Mobile Cards Grid Container */}
                <div className="sm:hidden grid grid-cols-2 gap-4 w-[calc(100%+2rem)] -mx-4 px-4 pb-4">
                    {services.map((service) => (
                        <Link key={service.id} href={service.link} className="relative w-full aspect-[157/189] rounded-[8.8px] overflow-hidden group shadow-md">
                            {/* Background Image */}
                            <Image
                                src={service.frontImage}
                                alt={service.title}
                                fill
                                className="object-cover"
                            />
                        </Link>
                    ))}
                </div>
            </div>

        </section>
    );
}
