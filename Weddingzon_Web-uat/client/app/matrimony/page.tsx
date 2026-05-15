"use client";

import React from 'react';
import Navbar from "@/components/Navbar";
import MatrimonyHero from "@/components/MatrimonyHero";
import MatrimonyDiscover from "@/components/MatrimonyDiscover";
import MatrimonyTestimonials from "@/components/MatrimonyTestimonials";
import Footer from "@/components/Footer";

export default function MatrimonyPage() {
    return (
        <div className="min-h-screen bg-white">
            <Navbar />
            <MatrimonyHero />
            <MatrimonyDiscover />
            <MatrimonyTestimonials />
            <Footer />
        </div>
    );
}
