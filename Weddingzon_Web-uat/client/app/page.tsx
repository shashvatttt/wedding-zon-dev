'use client';

import React from 'react';
import Image from "next/image";
import Link from 'next/link';
import { useRouter } from "next/navigation";
import { Instagram, Twitter, Facebook, Youtube, X, ChevronDown } from 'lucide-react';
import { useAuth } from '@/app/context/AuthContext';
import Navbar from '@/components/Navbar';
import ServicesSection from '@/components/ServicesSection';
import WhyWeddingzon from '@/components/WhyWeddingzon';
import AppDownloadSection from '@/components/AppDownloadSection';
import ClientTestimonials from '@/components/ClientTestimonials';
import Footer from '@/components/Footer';
import { FadeIn } from '@/components/animations/FadeIn';
import { SlideIn } from '@/components/animations/SlideIn';
import { StaggerContainer, StaggerItem } from '@/components/animations/StaggerContainer';

// Fix for Lucide icons that might not match exact import names or to replicate exact visual style
const SocialSidebar = () => (
  <StaggerContainer className="absolute right-4 md:right-8 top-1/2 -translate-y-1/2 z-20">
    <div className="bg-black/10 backdrop-blur-md border border-white/20 px-3 py-6 rounded-full flex flex-col gap-6 shadow-2xl">
      <StaggerItem>
        <a href="https://www.instagram.com/@weddingzon.in" target="_blank" rel="noopener noreferrer" className="text-white hover:text-[#EF2F55] transition-colors"><Instagram className="w-6 h-6" /></a>
      </StaggerItem>
      <StaggerItem>
        <a href="https://x.com/weddingzon" target="_blank" rel="noopener noreferrer" className="text-white hover:text-[#EF2F55] transition-colors"><X className="w-6 h-6" /></a>
      </StaggerItem>
      <StaggerItem>
        <a href="https://www.facebook.com/22manindersingh/" target="_blank" rel="noopener noreferrer" className="text-white hover:text-[#EF2F55] transition-colors"><Facebook className="w-6 h-6" /></a>
      </StaggerItem>
      <StaggerItem>
        <a href="https://www.youtube.com/@weddingzon" target="_blank" rel="noopener noreferrer" className="text-white hover:text-[#EF2F55] transition-colors"><Youtube className="w-6 h-6" /></a>
      </StaggerItem>
      <StaggerItem>
        {/* Whatsapp Mock */}
        <a href="https://wa.me/919876543210" target="_blank" rel="noopener noreferrer" className="text-white hover:text-[#EF2F55] transition-colors">
          <div className="w-6 h-6 relative bg-white rounded-full p-1 border border-white/20 shadow-sm">
            <Image src="https://upload.wikimedia.org/wikipedia/commons/6/6b/WhatsApp.svg" alt="Whatsapp" fill className="object-contain p-1" />
          </div>
        </a>
      </StaggerItem>
      <StaggerItem>
        {/* Pinterest Mock */}
        <a href="https://in.pinterest.com/wedding_zon/" target="_blank" rel="noopener noreferrer" className="text-white hover:text-[#EF2F55] transition-colors">
          <div className="w-6 h-6 relative bg-white rounded-full p-1 border border-white/20 shadow-sm">
            <Image src="https://upload.wikimedia.org/wikipedia/commons/0/08/Pinterest-logo.png" alt="Pinterest" fill className="object-contain p-1" />
          </div>
        </a>
      </StaggerItem>
    </div>
  </StaggerContainer>
);

export default function Home() {
  const router = useRouter();
  const { user, loading } = useAuth();
  const [showMenu, setShowMenu] = React.useState(false);

  // Redirect Vendor
  React.useEffect(() => {
    if (!loading && user && user.role === 'vendor') {
      // Check if vendor has completed onboarding (has business name)
      if (!user.vendor_details?.business_name) {
        router.push('/vendor/onboarding');
      } else if (user.vendor_status === 'active') {
        router.push('/vendor/dashboard');
      } else {
        router.push('/vendor/waiting');
      }
    } else if (!loading && user && user.role === 'franchise') {
      if (user.franchise_status === 'active') {
        router.push('/franchise');
      } else if (user.franchise_status === 'pending_payment') {
        router.push('/franchise/payment');
      } else if (user.franchise_status === 'pending_approval' || user.franchise_status === 'rejected') {
        router.push('/franchise/waiting');
      } else if (!user.franchise_details?.business_name) {
        router.push('/franchise/onboarding');
      }
    }
  }, [user, loading, router]);

  return (
    <div className="min-h-screen bg-white font-sans">
      <Navbar />

      {/* --- HERO SECTION --- */}
      <div className="relative w-full h-auto min-[801px]:h-[calc(100vh-80px)] min-[801px]:min-h-[calc(100vh-80px)] min-[801px]:max-h-[900px] overflow-hidden mt-20 flex flex-col">
        {/* Background Image */}
        {/* Background Image - Desktop (Absolute) */}
        {/* Background Image - Desktop (Absolute) */}
        <div className="hidden min-[801px]:block absolute inset-0 z-0">
          <Image
            src="/hero-new.png"
            alt="Weddingzon"
            fill
            className="object-cover object-top"
            priority
            quality={100}
            unoptimized
          />

          {/* Desktop Service Buttons Layer - Positioned around the couple */}
          <div className="absolute inset-0 z-10 pointer-events-none">
            {/* Left Side Buttons */}
            <div className="absolute left-[10%] lg:left-[15%] top-[62%] -translate-y-1/2 flex flex-col gap-16">
              {/* Matrimonial (Bride/Groom) */}
              <Link href="/matrimony" className="pointer-events-auto hover:scale-110 transition-all duration-300">
                <Image
                  src="/image 14.png"
                  alt="Matrimony"
                  width={180}
                  height={72}
                  className="shadow-[0_20px_50px_rgba(0,0,0,0.3)] rounded-xl"
                  unoptimized
                />
              </Link>
              {/* Vendors */}
              <Link href="/services" className="pointer-events-auto hover:scale-110 transition-all duration-300">
                <Image
                  src="/image 17.png"
                  alt="Vendors"
                  width={180}
                  height={72}
                  className="shadow-[0_20px_50px_rgba(0,0,0,0.3)] rounded-xl"
                  unoptimized
                />
              </Link>
            </div>

            {/* Right Side Buttons */}
            <div className="absolute right-[10%] lg:right-[15%] top-[62%] -translate-y-1/2 flex flex-col gap-16">
              {/* Franchisee */}
              <Link href="/franchise/entry?role=franchise" className="pointer-events-auto hover:scale-110 transition-all duration-300">
                <Image
                  src="/image 15.png"
                  alt="Franchise"
                  width={180}
                  height={72}
                  className="shadow-[0_20px_50px_rgba(0,0,0,0.3)] rounded-xl"
                  unoptimized
                />
              </Link>
              {/* Shopping */}
              <Link href="/shop" className="pointer-events-auto hover:scale-110 transition-all duration-300">
                <Image
                  src="/image 16.png"
                  alt="Shopping"
                  width={180}
                  height={72}
                  className="shadow-[0_20px_50px_rgba(0,0,0,0.3)] rounded-xl"
                  unoptimized
                />
              </Link>
            </div>
          </div>
        </div>

        {/* Mobile View Redesign (Matching Android Compact - 106 Specs) */}
        <div className="min-[801px]:hidden block w-full relative min-h-[580px] sm:min-h-[650px] bg-white overflow-hidden pb-12">
          {/* Background Image (unnamed 3) - Centered and Responsive */}
          <div className="absolute inset-0 z-0">
            <Image
              src="/unnamed.png"
              alt="Background"
              fill
              className="object-cover object-top"
              priority
              quality={100}
              unoptimized
            />
          </div>

          {/* Centered Content Wrapper - Flexbox based for responsiveness */}
          <div className="relative z-10 w-full h-full flex flex-col items-center px-4 pt-16">
            {/* Weddingzon Logo Text */}
            <h1 className="font-serif font-black text-3xl sm:text-[32px] leading-tight text-[#EF2F55] text-center mb-2">
              Weddingzon
            </h1>

            {/* Tagline */}
            <p className="font-sans font-normal text-sm sm:text-[14px] leading-tight text-[#111827] text-center mb-12 sm:mb-16 max-w-[280px]">
              India's leading wedding platform connecting couples with the best vendors and matrimonial matches.
            </p>

            {/* Service Buttons Grid - Responsive 2x2 grid */}
            <div className="grid grid-cols-2 gap-x-6 gap-y-10 sm:gap-12 w-fit mx-auto">
              {/* Matrimonial (Left, Top) */}
              <Link href="/matrimony" className="flex flex-col items-center hover:scale-110 transition-all duration-300">
                <Image
                  src="/image 14.png"
                  alt="Matrimony"
                  width={110}
                  height={44}
                  className="shadow-[0_10px_30px_rgba(0,0,0,0.25)] rounded-lg sm:w-[130px] sm:h-auto"
                  unoptimized
                />
              </Link>

              {/* Franchise (Right, Top) */}
              <Link href="/franchise/entry?role=franchise" className="flex flex-col items-center hover:scale-110 transition-all duration-300">
                <Image
                  src="/image 15.png"
                  alt="Franchise"
                  width={110}
                  height={44}
                  className="shadow-[0_10px_30px_rgba(0,0,0,0.25)] rounded-lg sm:w-[130px] sm:h-auto"
                  unoptimized
                />
              </Link>

              {/* Vendors (Left, Bottom) */}
              <Link href="/services" className="flex flex-col items-center hover:scale-110 transition-all duration-300">
                <Image
                  src="/image 17.png"
                  alt="Vendors"
                  width={110}
                  height={44}
                  className="shadow-[0_10px_30px_rgba(0,0,0,0.25)] rounded-lg sm:w-[130px] sm:h-auto"
                  unoptimized
                />
              </Link>

              {/* Shopping (Right, Bottom) */}
              <Link href="/shop" className="flex flex-col items-center hover:scale-110 transition-all duration-300">
                <Image
                  src="/image 16.png"
                  alt="Shopping"
                  width={110}
                  height={44}
                  className="shadow-[0_10px_30px_rgba(0,0,0,0.25)] rounded-lg sm:w-[130px] sm:h-auto"
                  unoptimized
                />
              </Link>
            </div>
          </div>
        </div>

        {/* Social Sidebar - Hidden on mobile to prevent overlap */}
        <div className="hidden sm:block">
          <SocialSidebar />
        </div>
      </div>

      <FadeIn>
        <ServicesSection />
      </FadeIn>

      <FadeIn delay={0.2}>
        <WhyWeddingzon />
      </FadeIn>

      <FadeIn delay={0.2}>
        <AppDownloadSection />
      </FadeIn>

      <FadeIn delay={0.2}>
        <ClientTestimonials />
      </FadeIn>

      {/* Footer */}
      <Footer />
    </div >
  );
}
