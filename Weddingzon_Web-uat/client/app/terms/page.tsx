'use client';

import React from 'react';
import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';
import TermsAndConditions from '../components/TermsAndConditions';

export default function TermsPage() {
    return (
        <div className="min-h-screen bg-white font-sans">
            <Navbar />
            
            <div className="pt-24 pb-12">
                <TermsAndConditions />
            </div>

            <Footer />
        </div>
    );
}
