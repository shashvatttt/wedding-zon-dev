'use client';

import React from 'react';
import { Shield, Lock, FileText, Trash2, UserCheck, Bell, Mail } from 'lucide-react';

const PrivacyPolicy = () => {
    const sections = [
        {
            icon: Shield,
            title: "Introduction",
            content: [
                "At WeddingZon, we prioritize your privacy and the security of your data. This policy explains how we collect, use, and protect your information.",
                "By using our platform, you agree to the collection and use of information in accordance with this policy.",
                "We are committed to being transparent about our data practices."
            ]
        },
        {
            icon: FileText,
            title: "Data Collection",
            content: [
                "We collect information you provide directly, such as when you create or modify your account, request services, or contact customer support.",
                "This includes your name, email address, phone number, profile photos, and other details you choose to share.",
                "We also collect usage data automatically, including IP addresses, browser types, and interaction history.",
                "Cookies and similar technologies are used to enhance your experience and analyze platform performance."
            ]
        },
        {
            icon: UserCheck,
            title: "How We Use Your Data",
            content: [
                "Your information is used to provide, maintain, and improve our matchmaking and vendor services.",
                "We use your details to verify your identity, process transactions, and communicate important updates."
            ]
        },
        {
            icon: Lock,
            title: "Security Measures",
            content: [
                "We implement robust technical and organizational measures to protect your personal data against unauthorized access, loss, or alteration."
            ]
        },
        {
            icon: Trash2,
            title: "Your Rights & Deletion",
            content: [
                "You have the right to access, update, or delete your personal information at any time through your account settings."
            ]
        },
        {
            icon: Bell,
            title: "Changes to This Policy",
            content: [
                "We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page."
            ]
        },
        {
            icon: Mail,
            title: "Contact Us",
            content: [
                "If you have any questions about this Privacy Policy, please contact our support team."
            ]
        }
    ];

    return (
        <div className="max-w-4xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
            <div className="text-center mb-16">
                <h1 className="text-4xl md:text-5xl font-serif font-bold text-gray-900 mb-4">
                    Privacy Policy
                </h1>
                <div className="w-24 h-1.5 bg-[#EF2F55] rounded-full mx-auto" />
            </div>

            <div className="space-y-12">
                {sections.map((section, index) => (
                    <section key={index} className="bg-white rounded-2xl p-8 shadow-sm border border-rose-100 hover:shadow-md transition-shadow">
                        <div className="flex items-center gap-4 mb-6">
                            <div className="p-3 bg-rose-50 rounded-xl text-[#EF2F55]">
                                <section.icon className="w-6 h-6" />
                            </div>
                            <h2 className="text-2xl font-serif font-bold text-gray-900">
                                {section.title}
                            </h2>
                        </div>
                        <div className="space-y-4">
                            {section.content.map((paragraph, pIndex) => (
                                <p key={pIndex} className="text-gray-600 leading-relaxed text-lg">
                                    {paragraph}
                                </p>
                            ))}
                        </div>
                    </section>
                ))}
            </div>

            <div className="mt-16 p-8 bg-rose-50 rounded-3xl text-center">
                <p className="text-gray-700 italic">
                    We are committed to being transparent about our data practices.
                </p>
            </div>
        </div>
    );
};

export default PrivacyPolicy;
