'use client';

import React from 'react';
import Image from 'next/image';
import { QRCodeSVG } from 'qrcode.react';
import { APP_LINKS } from '@/constants/links';

export default function AppDownloadSection() {
    return (
        <section className="w-full bg-[#FFF5F7] pb-16 md:pb-24 overflow-hidden">
            <div className="max-w-[1206px] mx-auto px-4 sm:px-8 relative">
                {/* Desktop Main Pink Container (Hidden on Mobile) */}
                <div className="hidden lg:flex w-full bg-[#C97C8A]/20 rounded-[30px] p-8 md:p-12 lg:p-16 relative flex-row items-center min-h-[729px]">
                    {/* Left Content */}
                    <div className="w-1/2 z-10">
                        <h2 className="font-serif text-[40px] md:text-[64px] leading-[1.2] md:leading-[96px] font-semibold text-black mb-4">
                            Download the <br />
                            <span className="flex flex-col items-start gap-0 mt-2">
                                <span className="relative h-[60px] md:h-[100px] w-[220px] md:w-[380px]">
                                    <Image
                                        src="/weddingzon-logo.png"
                                        alt="WeddingZon"
                                        fill
                                        className="object-contain object-left"
                                        priority
                                    />
                                </span>
                                <span className="text-[40px] md:text-[64px] leading-tight">App</span>
                            </span>
                        </h2>
                        <p className="font-sans text-[20px] md:text-[32px] leading-tight text-black mb-12">
                            Your perfect wedding starts here.
                        </p>

                        {/* White Info Card */}
                        <div className="bg-white rounded-2xl p-6 md:p-8 w-full max-w-[576px] shadow-sm">
                            <p className="font-sans text-[18px] md:text-[24px] leading-tight text-center text-black mb-8">
                                Point your phone camera at the QR code or use one of the download links below
                            </p>

                            <div className="flex flex-col md:flex-row items-center justify-center gap-8 md:gap-12 mb-8">
                                {/* QR Code */}
                                <div className="w-[138px] h-[138px] bg-white p-2 rounded-lg shadow-sm flex items-center justify-center">
                                    <QRCodeSVG
                                        value="https://weddingzon.com"
                                        size={122}
                                        level="H"
                                        includeMargin={false}
                                    />
                                </div>

                                {/* Store Buttons */}
                                <div className="flex flex-col gap-4">
                                    <a href={APP_LINKS.GOOGLE_PLAY} target="_blank" rel="noopener noreferrer" className="hover:opacity-80 transition-opacity">
                                        <Image
                                            src="/images/home/Download/Google plasore badge.png"
                                            alt="Get it on Google Play"
                                            width={180}
                                            height={55}
                                            className="h-[55px] w-auto"
                                        />
                                    </a>
                                    <a href={APP_LINKS.APP_STORE} target="_blank" rel="noopener noreferrer" className="hover:opacity-80 transition-opacity">
                                        <Image
                                            src="/images/home/Download/Apple palystore badge.png"
                                            alt="Download on the App Store"
                                            width={180}
                                            height={55}
                                            className="h-[55px] w-auto"
                                        />
                                    </a>
                                </div>
                            </div>

                            <div className="w-full border-t border-gray-100 pt-6">
                                <p className="font-sans text-[18px] md:text-[24px] leading-tight text-center text-black">
                                    Or <a href="#" className="text-[#EF2F55] hover:underline font-semibold">get the download link</a> on your SMS/Email
                                </p>
                            </div>
                        </div>
                    </div>

                    {/* Right Content - iPhone Image */}
                    <div className="absolute right-[-50px] top-[-21px] w-[500px] xl:w-[600px] h-full pointer-events-none">
                        <div className="relative w-full h-[900px]">
                            <Image
                                src="/images/home/Download/iphone16pro.png"
                                alt="WeddingZon App on iPhone"
                                fill
                                className="object-contain object-top"
                                priority
                            />
                        </div>
                    </div>
                </div>

                {/* Mobile Main Pink Container (Figma Specs) */}
                <div className="lg:hidden w-full bg-[#F4D3DA] rounded-[16px] p-6 relative flex flex-col items-center min-h-[550px] overflow-hidden">
                    <h2 className="font-serif text-2xl sm:text-[31.7px] leading-tight font-semibold text-black text-center mb-2 px-4">
                        Download the WeddingZon App
                    </h2>
                    <p className="font-sans text-sm sm:text-[15.8px] leading-tight text-black text-center mb-8 px-4">
                        Your perfect wedding starts here.
                    </p>

                    {/* White Info Card (Frame 20) */}
                    <div className="bg-white rounded-[8px] p-4 w-full max-w-[285px] shadow-sm z-10 mb-8 items-center flex flex-col">
                        <p className="font-sans text-[11.8px] leading-tight text-center text-black mb-4">
                            Point your phone camera at the QR code or use one of the download links below
                        </p>

                        <div className="flex items-center gap-4 mb-4">
                            {/* QR Code */}
                            <div className="w-[68px] h-[68px] bg-white p-1 rounded-md shadow-sm flex items-center justify-center">
                                <QRCodeSVG
                                    value="https://weddingzon.com"
                                    size={60}
                                    level="H"
                                    includeMargin={false}
                                />
                            </div>

                            {/* Store Buttons */}
                            <div className="flex flex-col gap-2">
                                <a href={APP_LINKS.GOOGLE_PLAY} target="_blank" rel="noopener noreferrer">
                                    <Image
                                        src="/images/home/Download/Google plasore badge.png"
                                        alt="Google Play"
                                        width={89}
                                        height={27}
                                        className="h-[27px] w-auto"
                                    />
                                </a>
                                <a href={APP_LINKS.APP_STORE} target="_blank" rel="noopener noreferrer">
                                    <Image
                                        src="/images/home/Download/Apple palystore badge.png"
                                        alt="App Store"
                                        width={89}
                                        height={27}
                                        className="h-[27px] w-auto"
                                    />
                                </a>
                            </div>
                        </div>

                        <p className="font-sans text-[11.8px] leading-tight text-center text-black border-t pt-3 w-full">
                            Or get the download link on your SMS/Email
                        </p>
                    </div>

                    {/* Phone Image Positioned at Bottom - Responsive sizing */}
                    <div className="relative w-[180px] h-[300px] sm:w-[200px] sm:h-[350px] -mb-16 mt-auto">
                        <Image
                            src="/images/home/Download/iphone16pro.png"
                            alt="iPhone"
                            fill
                            className="object-contain object-bottom"
                        />
                    </div>
                </div>
            </div>
        </section>
    );
}
