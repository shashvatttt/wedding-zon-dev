'use client';

import React from 'react';
import { Shield, FileText, Scale, UserCheck, Bell, Mail, AlertTriangle } from 'lucide-react';

const TermsAndConditions = () => {
    const sections = [
        {
            icon: Shield,
            title: "1. Agreement to Terms",
            content: [
                "By accessing or using WeddingZon, you agree to be bound by these Terms and Conditions and our Privacy Policy.",
                "If you do not agree with any part of these terms, you must not use our services.",
                "These terms apply to all visitors, users, vendors, and others who access or use the Service."
            ]
        },
        {
            icon: UserCheck,
            title: "2. User Accounts",
            content: [
                "When you create an account with us, you must provide information that is accurate, complete, and current at all times.",
                "Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your account.",
                "You are responsible for safeguarding the password that you use to access the Service and for any activities or actions under your password."
            ]
        },
        {
            icon: Scale,
            title: "3. Intellectual Property",
            content: [
                "The Service and its original content, features, and functionality are and will remain the exclusive property of WeddingZon and its licensors.",
                "Our trademarks and trade dress may not be used in connection with any product or service without the prior written consent of WeddingZon."
            ]
        },
        {
            icon: AlertTriangle,
            title: "4. Vendor & Matrimony Services",
            content: [
                "WeddingZon acts as a platform connecting users with wedding vendors and potential matrimonial matches.",
                "We do not guarantee the quality, safety, or legality of the services provided by vendors.",
                "Users are encouraged to perform their own due diligence before entering into agreements with vendors or other users."
            ]
        },
        {
            icon: FileText,
            title: "5. Limitation of Liability",
            content: [
                "In no event shall WeddingZon, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages.",
                "This includes, without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your access to or use of or inability to access or use the Service."
            ]
        },
        {
            icon: Bell,
            title: "6. Changes to Terms",
            content: [
                "We reserve the right, at our sole discretion, to modify or replace these Terms at any time.",
                "If a revision is material, we will try to provide at least 30 days' notice prior to any new terms taking effect.",
                "What constitutes a material change will be determined at our sole discretion."
            ]
        },
        {
            icon: Mail,
            title: "7. Contact Us",
            content: [
                "If you have any questions about these Terms, please contact us at support@weddingzon.com."
            ]
        }
    ];

    return (
        <div className="max-w-4xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
            <div className="text-center mb-16">
                <h1 className="text-4xl md:text-5xl font-serif font-bold text-gray-900 mb-4">
                    Terms & Conditions
                </h1>
                <div className="w-24 h-1.5 bg-[#EF2F55] rounded-full mx-auto" />
                <p className="mt-6 text-gray-500 font-medium">Last Updated: March 2024</p>
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
                    By using WeddingZon, you acknowledge that you have read and understood these Terms and Conditions.
                </p>
            </div>
        </div>
    );
};

export default TermsAndConditions;
