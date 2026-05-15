'use client';

import React, { useState } from 'react';
import { Send, CheckCircle2, User, Mail, Phone, Calendar, ArrowRight } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useToast } from '@/app/contexts/ToastContext';
import api from '@/app/services/api';
import Link from 'next/link';

interface MessageVendorSectionProps {
    vendorId: string;
    vendorName: string;
}

export default function MessageVendorSection({ vendorId, vendorName }: MessageVendorSectionProps) {
    const { addToast } = useToast();
    const [name, setName] = useState('');
    const [email, setEmail] = useState('');
    const [phone, setPhone] = useState('');
    const [eventDate, setEventDate] = useState('');
    const [loading, setLoading] = useState(false);
    const [success, setSuccess] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!name || !email || !phone) {
            addToast("Please fill in all required fields", 'error');
            return;
        }

        // Email Validation
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            addToast("Please enter a valid email address", 'error');
            return;
        }

        // Phone Validation (10 digits)
        const phoneRegex = /^\d{10}$/;
        if (!phoneRegex.test(phone.replace(/\D/g, ''))) {
            addToast("Phone number must be 10 digits", 'error');
            return;
        }

        // Event Date Validation (cannot be previous date)
        if (eventDate) {
            const selectedDate = new Date(eventDate);
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            if (selectedDate < today) {
                addToast("Event date cannot be in the past", 'error');
                return;
            }
        }

        setLoading(true);
        try {
            await api.post('/vendor-features/inquiry', {
                vendorId,
                name,
                email,
                phone,
                event_date: eventDate,
                details: `Message Vendor request for ${vendorName}`
            });
            setSuccess(true);
            setName('');
            setEmail('');
            setPhone('');
            setEventDate('');
        } catch (error: any) {
            addToast(error.response?.data?.message || "Failed to send request", 'error');
        } finally {
            setLoading(false);
        }
    };

    if (success) {
        return (
            <div className="w-full bg-white rounded-[40px] p-12 text-center shadow-2xl shadow-rose-100 border border-rose-50 animate-in zoom-in-95 duration-500">
                <div className="w-24 h-24 bg-emerald-50 text-emerald-500 rounded-full flex items-center justify-center mx-auto mb-8 shadow-inner">
                    <CheckCircle2 className="w-12 h-12" />
                </div>
                <h4 className="text-3xl font-black text-gray-900 mb-4 tracking-tight">Request Sent Successfully!</h4>
                <p className="text-gray-500 font-medium text-lg leading-relaxed max-w-md mx-auto">
                    Thank you, <span className="text-[#EF2F55] font-bold">{name}</span>! {vendorName} has received your pricing request and will contact you shortly.
                </p>
                <Button 
                    variant="link" 
                    onClick={() => setSuccess(false)}
                    className="mt-8 text-[#EF2F55] font-black uppercase tracking-widest text-sm hover:no-underline hover:text-rose-700"
                >
                    Send another request
                </Button>
            </div>
        );
    }

    return (
        <div className="w-full bg-white rounded-[40px] shadow-2xl shadow-rose-100 border border-rose-50 overflow-hidden group transition-all duration-500 hover:shadow-pink-100/50">
            <div className="bg-[#EF2F55] p-10 text-white relative overflow-hidden">
                {/* Decorative Pattern */}
                <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16 blur-2xl" />
                <div className="absolute bottom-0 left-0 w-24 h-24 bg-black/10 rounded-full -ml-12 -mb-12 blur-xl" />
                
                <div className="relative z-10">
                    <h3 className="text-3xl font-black tracking-tight flex items-center gap-3">
                        <Send className="w-8 h-8" />
                        Message Vendor
                    </h3>
                    <p className="text-white/80 text-xs font-bold uppercase tracking-[0.2em] mt-2">Get a personalized pricing quote</p>
                </div>
            </div>

            <form onSubmit={handleSubmit} className="p-10 space-y-8">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                    {/* Name */}
                    <div className="space-y-2">
                        <label className="text-gray-400 text-[10px] font-black uppercase tracking-widest ml-1">Your Name</label>
                        <div className="relative group/input">
                            <User className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400 transition-colors group-focus-within/input:text-[#EF2F55]" />
                            <input
                                type="text"
                                required
                                value={name}
                                onChange={(e) => setName(e.target.value)}
                                placeholder="Enter your name"
                                className="w-full pl-12 pr-4 py-4 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-4 focus:ring-[#EF2F55]/5 focus:border-[#EF2F55] font-medium text-gray-900 transition-all placeholder:text-gray-300"
                            />
                        </div>
                    </div>

                    {/* Email */}
                    <div className="space-y-2">
                        <label className="text-gray-400 text-[10px] font-black uppercase tracking-widest ml-1">Email Address</label>
                        <div className="relative group/input">
                            <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400 transition-colors group-focus-within/input:text-[#EF2F55]" />
                            <input
                                type="email"
                                required
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                placeholder="Enter your email"
                                className="w-full pl-12 pr-4 py-4 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-4 focus:ring-[#EF2F55]/5 focus:border-[#EF2F55] font-medium text-gray-900 transition-all placeholder:text-gray-300"
                            />
                        </div>
                    </div>

                    {/* Phone */}
                    <div className="space-y-2">
                        <label className="text-gray-400 text-[10px] font-black uppercase tracking-widest ml-1">Phone Number</label>
                        <div className="relative group/input">
                            <Phone className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400 transition-colors group-focus-within/input:text-[#EF2F55]" />
                            <input
                                type="tel"
                                required
                                value={phone}
                                onChange={(e) => setPhone(e.target.value)}
                                placeholder="Enter your phone number"
                                className="w-full pl-12 pr-4 py-4 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-4 focus:ring-[#EF2F55]/5 focus:border-[#EF2F55] font-medium text-gray-900 transition-all placeholder:text-gray-300"
                            />
                        </div>
                    </div>

                    {/* Date */}
                    <div className="space-y-2">
                        <label className="text-gray-400 text-[10px] font-black uppercase tracking-widest ml-1">Event Date (Optional)</label>
                        <div className="relative group/input">
                            <Calendar className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400 transition-colors group-focus-within/input:text-[#EF2F55]" />
                            <input
                                type="date"
                                value={eventDate}
                                onChange={(e) => setEventDate(e.target.value)}
                                min={new Date().toISOString().split('T')[0]}
                                className="w-full pl-12 pr-4 py-4 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-4 focus:ring-[#EF2F55]/5 focus:border-[#EF2F55] font-medium text-gray-900 transition-all"
                            />
                        </div>
                    </div>
                </div>

                <div className="pt-4 border-t border-gray-50">
                    <Button
                        type="submit"
                        disabled={loading}
                        className="w-full py-8 text-lg font-black uppercase tracking-[0.2em] bg-[#EF2F55] hover:bg-rose-700 text-white rounded-2xl shadow-xl shadow-pink-200 transition-all transform hover:-translate-y-1 active:translate-y-0 active:scale-[0.98] group/btn flex items-center justify-center gap-3"
                    >
                        {loading ? (
                            <div className="flex items-center gap-2">
                                <div className="w-5 h-5 border-4 border-white/30 border-t-white rounded-full animate-spin" />
                                <span>Sending...</span>
                            </div>
                        ) : (
                            <>
                                <span>Request Pricing</span>
                                <ArrowRight className="w-6 h-6 group-hover/btn:translate-x-2 transition-transform" />
                            </>
                        )}
                    </Button>
                    
                    <div className="mt-6 space-y-3">
                        <p className="text-[11px] text-gray-400 text-center font-medium leading-relaxed">
                            By clicking 'Request pricing', I agree to Weddingzon’s{' '}
                            <Link href="/privacy-policy" className="text-[#EF2F55] font-bold hover:underline">Privacy Policy</Link>
                            {' '}and{' '}
                            <Link href="/terms" className="text-[#EF2F55] font-bold hover:underline">Terms of Use</Link>
                        </p>
                    </div>
                </div>
            </form>
        </div>
    );
}
