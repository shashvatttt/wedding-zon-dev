'use client';

import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';
import { FadeIn } from '@/components/animations/FadeIn';
import { Search, UserPlus, Phone, MessageSquare, ShieldAlert } from 'lucide-react';

export default function PhonebookPage() {
    const contacts = [
        { id: 1, name: 'Sanjana Singh', status: 'Connected', relationship: 'Match' },
        { id: 2, name: 'Rahul Sharma', status: 'Draft', relationship: 'Interested' },
        { id: 3, name: 'Priya Verma', status: 'Connected', relationship: 'Friend' },
    ];

    return (
        <div className="min-h-screen flex flex-col bg-[#FFF9FA]">
            <Navbar />
            <main className="flex-grow pt-24 pb-12">
                <FadeIn className="max-w-5xl mx-auto px-4">
                    <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                        {/* Sidebar/Stats */}
                        <div className="lg:col-span-1 space-y-6">
                            <div className="bg-white rounded-[32px] p-8 shadow-[0_10px_30px_rgba(0,0,0,0.04)] border border-gray-50">
                                <h1 className="text-3xl font-bold text-gray-900 mb-6">
                                    Your <span className="text-[#EF2F55]">Phonebook</span>
                                </h1>
                                <div className="space-y-4">
                                    <div className="flex items-center justify-between p-4 bg-pink-50 rounded-2xl">
                                        <span className="text-gray-600 font-medium">Total Contacts</span>
                                        <span className="text-[#EF2F55] font-black text-xl">12</span>
                                    </div>
                                    <div className="flex items-center justify-between p-4 bg-gray-50 rounded-2xl">
                                        <span className="text-gray-600 font-medium">Requests</span>
                                        <span className="text-gray-900 font-black text-xl">4</span>
                                    </div>
                                </div>
                            </div>

                            <div className="bg-white rounded-[32px] p-6 shadow-sm border border-gray-100">
                                <h3 className="font-bold text-gray-900 mb-4 flex items-center gap-2">
                                    <ShieldAlert className="w-4 h-4 text-[#EF2F55]" />
                                    Security Tip
                                </h3>
                                <p className="text-sm text-gray-500 leading-relaxed">
                                    Never share your OTP or financial details with anyone on the platform. Keep your conversations within WeddingZon for safety.
                                </p>
                            </div>
                        </div>

                        {/* Contact List */}
                        <div className="lg:col-span-2 space-y-6">
                            <div className="bg-white rounded-[32px] shadow-[0_10px_30px_rgba(0,0,0,0.04)] border border-gray-50 overflow-hidden">
                                <div className="p-6 border-b border-gray-50 flex items-center justify-between bg-white sticky top-0 z-10">
                                    <div className="relative flex-1 max-w-md">
                                        <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                                        <input
                                            type="text"
                                            placeholder="Search contacts..."
                                            className="w-full pl-11 pr-4 py-2 bg-gray-50 rounded-full border-none focus:ring-2 focus:ring-pink-200 outline-none text-sm"
                                        />
                                    </div>
                                    <button className="ml-4 p-2 bg-pink-50 text-[#EF2F55] rounded-full hover:bg-pink-100 transition-colors">
                                        <UserPlus className="w-5 h-5" />
                                    </button>
                                </div>

                                <div className="divide-y divide-gray-50">
                                    {contacts.map((contact) => (
                                        <div key={contact.id} className="p-6 hover:bg-pink-50/30 transition-colors group flex items-center justify-between">
                                            <div className="flex items-center gap-4">
                                                <div className="w-12 h-12 rounded-full bg-gradient-to-tr from-pink-100 to-rose-50 flex items-center justify-center font-bold text-[#EF2F55]">
                                                    {contact.name[0]}
                                                </div>
                                                <div>
                                                    <h4 className="font-bold text-gray-900">{contact.name}</h4>
                                                    <p className="text-xs text-gray-400 font-medium uppercase tracking-wider">{contact.relationship}</p>
                                                </div>
                                            </div>
                                            <div className="flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                                <button className="p-2 hover:bg-white rounded-full text-gray-400 hover:text-green-500 shadow-sm transition-all"><Phone className="w-4 h-4" /></button>
                                                <button className="p-2 hover:bg-white rounded-full text-gray-400 hover:text-blue-500 shadow-sm transition-all"><MessageSquare className="w-4 h-4" /></button>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                                <div className="p-8 text-center text-gray-400 text-sm italic font-medium">
                                    End of your phonebook list.
                                </div>
                            </div>
                        </div>
                    </div>
                </FadeIn>
            </main>
            <Footer />
        </div>
    );
}
