'use client';

import React from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { FaInstagram, FaFacebookF, FaYoutube, FaWhatsapp, FaPinterestP, FaLinkedin } from 'react-icons/fa6';
import { APP_LINKS } from '@/constants/links';

const Footer = () => {
    return (
        <footer className="bg-white pt-16 pb-8 border-t border-gray-100 font-sans">
            <div className="container mx-auto px-4 lg:px-8">
                <div className="flex flex-col lg:flex-row justify-between gap-12">

                    {/* LEFT: Logo & Tagline */}
                    <div className="lg:w-1/4 group">
                        <Link href="/" className="inline-block mb-6 transition-all duration-300 hover:scale-105 active:scale-95">
                            <Image
                                src="/weddingzon-logo.png"
                                alt="WeddingZon Logo"
                                width={300}
                                height={100}
                                className="object-contain drop-shadow-sm filter brightness-110"
                                quality={100}
                                unoptimized
                            />
                        </Link>
                        <div className="relative pl-4 border-l-2 border-[#EF2F55]/20 hover:border-[#EF2F55]/50 transition-colors duration-300">
                            <p className="text-gray-600 text-[15px] sm:text-base leading-relaxed font-medium">
                                Your <span className="text-[#EF2F55] font-semibold">one-stop destination</span> for your <span className="text-black">perfect celebration</span>.
                            </p>
                        </div>
                    </div>

                    {/* CENTER: Navigation Links */}
                    <div className="lg:w-2/4 grid grid-cols-2 sm:grid-cols-3 gap-8">
                        {/* Explore */}
                        <div>
                            <h3 className="font-bold text-black text-lg mb-4 sm:mb-6">Explore</h3>
                            <ul className="space-y-3 sm:space-y-4 text-gray-600 font-medium text-sm sm:text-base">
                                <li><Link href="/" className="hover:text-[#EF2F55] transition-colors">Home</Link></li>
                                <li><Link href="/matrimony" className="hover:text-[#EF2F55] transition-colors">Matrimony</Link></li>
                                <li><Link href="/services" className="hover:text-[#EF2F55] transition-colors">Vendor</Link></li>
                                <li><Link href="/franchise/entry" className="hover:text-[#EF2F55] transition-colors">Franchise</Link></li>
                            </ul>
                        </div>

                        {/* Links */}
                        <div>
                            <h3 className="font-bold text-black text-lg mb-4 sm:mb-6">Links</h3>
                            <ul className="space-y-3 sm:space-y-4 text-gray-600 font-medium text-sm sm:text-base">
                                <li><Link href="/about" className="hover:text-[#EF2F55] transition-colors">About Us</Link></li>
                                <li><Link href="/support" className="hover:text-[#EF2F55] transition-colors">Contact Us</Link></li>
                                <li><Link href="/shop" className="hover:text-[#EF2F55] transition-colors">Shop</Link></li>
                                <li><Link href="/terms" className="hover:text-[#EF2F55] transition-colors">Terms & Conditions</Link></li>
                                <li><Link href="/privacy-policy" className="hover:text-[#EF2F55] transition-colors">Privacy Policy</Link></li>
                            </ul>
                        </div>

                        {/* Locations - Responsive grid for mobile */}
                        <div className="col-span-2 sm:col-span-1">
                            <h3 className="font-bold text-black text-lg mb-4 sm:mb-6">Locations</h3>
                            <ul className="grid grid-cols-2 sm:grid-cols-1 gap-3 sm:gap-4 text-gray-600 font-medium text-sm sm:text-base">
                                <li>Delhi</li>
                                <li>Chandigarh</li>
                                <li>Ludhiana</li>
                                <li>Jaipur</li>
                            </ul>
                        </div>
                    </div>

                    {/* RIGHT: Action Boxes */}
                    <div className="lg:w-1/4 flex flex-col gap-6">

                        {/* Download Box */}
                        <div className="bg-[#F8D7DA] bg-opacity-60 rounded-2xl p-5 sm:p-6">
                            <h3 className="font-bold text-black text-lg mb-4">Download Now</h3>
                            <div className="flex gap-2">
                                <a href={APP_LINKS.GOOGLE_PLAY} target="_blank" rel="noopener noreferrer" className="flex-1 transform hover:-translate-y-1 transition-transform max-w-[140px]">
                                    <Image
                                        src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg"
                                        alt="Get it on Google Play"
                                        width={135}
                                        height={40}
                                        className="w-full h-auto"
                                        quality={100}
                                        unoptimized
                                    />
                                </a>
                                <a href={APP_LINKS.APP_STORE} target="_blank" rel="noopener noreferrer" className="flex-1 transform hover:-translate-y-1 transition-transform max-w-[140px]">
                                    <Image
                                        src="https://upload.wikimedia.org/wikipedia/commons/3/3c/Download_on_the_App_Store_Badge.svg"
                                        alt="Download on the App Store"
                                        width={135}
                                        height={40}
                                        className="w-full h-auto"
                                        quality={100}
                                        unoptimized
                                    />
                                </a>
                            </div>
                        </div>

                        {/* Connect Box */}
                        <div className="bg-[#F8D7DA] bg-opacity-60 rounded-2xl p-5 sm:p-6">
                            <h3 className="font-bold text-black text-lg mb-4">Connect with us</h3>
                            <div className="flex flex-nowrap gap-2 items-center">
                                {/* Instagram */}
                                <a href="https://www.instagram.com/@weddingzon.in" target="_blank" rel="noopener noreferrer" className="w-8 h-8 bg-gradient-to-tr from-yellow-400 via-red-500 to-purple-500 rounded-full flex flex-shrink-0 items-center justify-center text-white hover:scale-110 transition-transform shadow-sm">
                                    <FaInstagram size={16} />
                                </a>

                                {/* LinkedIn */}
                                <a href="https://www.linkedin.com/in/maninder-singh-bhandol-2a3761320/" target="_blank" rel="noopener noreferrer" className="w-8 h-8 bg-[#0077B5] rounded-full flex flex-shrink-0 items-center justify-center text-white hover:scale-110 transition-transform shadow-sm">
                                    <FaLinkedin size={16} />
                                </a>

                                {/* Facebook */}
                                <a href="https://www.facebook.com/22manindersingh/" target="_blank" rel="noopener noreferrer" className="w-8 h-8 bg-[#1877F2] rounded-full flex flex-shrink-0 items-center justify-center text-white hover:scale-110 transition-transform shadow-sm">
                                    <FaFacebookF size={16} />
                                </a>

                                {/* Youtube */}
                                <a href="https://www.youtube.com/@weddingzon" target="_blank" rel="noopener noreferrer" className="w-8 h-8 bg-[#FF0000] rounded-full flex flex-shrink-0 items-center justify-center text-white hover:scale-110 transition-transform shadow-sm">
                                    <FaYoutube size={16} />
                                </a>

                                {/* Pinterest */}
                                <a href="https://in.pinterest.com/wedding_zon/" target="_blank" rel="noopener noreferrer" className="w-8 h-8 bg-[#BD081C] rounded-full flex flex-shrink-0 items-center justify-center text-white hover:scale-110 transition-transform shadow-sm">
                                    <FaPinterestP size={16} />
                                </a>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </footer>
    );
};

export default Footer;
