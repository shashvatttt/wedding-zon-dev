'use client';

import React, { useState } from 'react';
import { Send, CheckCircle2, Mail, Phone, Info } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useToast } from '@/app/contexts/ToastContext';
import api from '@/app/services/api';

interface InquiryFormProps {
    vendorId: string;
    vendorName: string;
}

export default function InquiryForm({ vendorId, vendorName }: InquiryFormProps) {
    const { addToast } = useToast();
    const [email, setEmail] = useState('');
    const [phone, setPhone] = useState('');
    const [details, setDetails] = useState('');
    const [loading, setLoading] = useState(false);
    const [success, setSuccess] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!email || !phone) {
            addToast("Please provide both email and phone", 'error');
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

        setLoading(true);
        try {
            await api.post('/vendor-features/inquiry', {
                vendorId,
                email,
                phone,
                details: details || `Inquiry for ${vendorName}`
            });
            setSuccess(true);
            setEmail('');
            setPhone('');
            setDetails('');
        } catch (error: any) {
            addToast(error.response?.data?.message || "Failed to send inquiry", 'error');
        } finally {
            setLoading(false);
        }
    };

    if (success) {
        return (
            <div className="w-full bg-emerald-50 border border-emerald-100 rounded-[32px] p-8 text-center animate-in zoom-in-95 duration-500">
                <div className="w-16 h-16 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center mx-auto mb-4">
                    <CheckCircle2 className="w-8 h-8" />
                </div>
                <h4 className="text-xl font-black text-gray-900 mb-2">Request Sent!</h4>
                <p className="text-gray-600 text-sm font-medium">The vendor has received your inquiry and will contact you shortly.</p>
                <Button 
                    variant="ghost" 
                    onClick={() => setSuccess(false)}
                    className="mt-4 text-emerald-600 font-bold hover:bg-emerald-100/50"
                >
                    Send another inquiry
                </Button>
            </div>
        );
    }

    return (
        <div className="w-full bg-white rounded-[32px] shadow-2xl shadow-rose-100/50 border border-rose-100/50 overflow-hidden">
            <div className="bg-[#EF2F55] p-6 text-white text-center">
                <h3 className="text-xl font-black tracking-tight flex items-center justify-center gap-2">
                    <Send className="w-5 h-5" />
                    Get a Free Quote
                </h3>
                <p className="text-white/80 text-[10px] font-bold uppercase tracking-widest mt-1">Response within 24 hours</p>
            </div>

            <form onSubmit={handleSubmit} className="p-6 space-y-4">
                <div className="space-y-4">
                    <div>
                        <label className="text-gray-400 text-[10px] font-black uppercase tracking-widest mb-1.5 block px-1">Email Address</label>
                        <div className="relative">
                            <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                            <input
                                type="email"
                                required
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                placeholder="Enter your email"
                                className="w-full pl-11 pr-4 py-3 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-[#EF2F55]/20 focus:border-[#EF2F55] font-medium text-gray-900 text-sm transition-all"
                            />
                        </div>
                    </div>

                    <div>
                        <label className="text-gray-400 text-[10px] font-black uppercase tracking-widest mb-1.5 block px-1">Phone Number</label>
                        <div className="relative">
                            <Phone className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                            <input
                                type="tel"
                                required
                                value={phone}
                                onChange={(e) => setPhone(e.target.value)}
                                placeholder="Enter your phone number"
                                className="w-full pl-11 pr-4 py-3 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-[#EF2F55]/20 focus:border-[#EF2F55] font-medium text-gray-900 text-sm transition-all"
                            />
                        </div>
                    </div>

                    <div>
                        <label className="text-gray-400 text-[10px] font-black uppercase tracking-widest mb-1.5 block px-1">Message (Optional)</label>
                        <div className="relative">
                            <Info className="absolute left-4 top-4 w-4 h-4 text-gray-400" />
                            <textarea
                                value={details}
                                onChange={(e) => setDetails(e.target.value)}
                                placeholder="Tell us about your event..."
                                className="w-full pl-11 pr-4 py-3 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-[#EF2F55]/20 focus:border-[#EF2F55] font-medium text-gray-900 text-sm transition-all min-h-[80px] resize-none"
                            />
                        </div>
                    </div>
                </div>

                <Button
                    type="submit"
                    disabled={loading}
                    className="w-full py-6 text-sm font-black uppercase tracking-widest bg-[#EF2F55] hover:bg-rose-700 text-white rounded-2xl shadow-lg shadow-pink-100 transition-all transform active:scale-95"
                >
                    {loading ? "Sending..." : "Submit Inquiry"}
                </Button>
                
                <p className="text-[9px] text-gray-400 text-center font-medium">
                    By submitting, you agree to being contacted by this vendor.
                </p>
            </form>
        </div>
    );
}
