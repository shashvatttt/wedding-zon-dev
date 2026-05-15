'use client';

import React from 'react';
import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';
import PrivacyPolicy from '../components/PrivacyPolicy';

export default function PrivacyPolicyPage() {
    return (
        <div className="min-h-screen bg-white font-sans">
            <Navbar />
            
            <div className="pt-24 pb-12">
                <PrivacyPolicy />
            </div>

            <Footer />
        </div>
    );
}
