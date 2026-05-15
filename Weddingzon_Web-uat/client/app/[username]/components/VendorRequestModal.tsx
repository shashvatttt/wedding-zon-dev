'use client';

import React, { useState } from 'react';
import { Calendar, Info, X, Send, CheckCircle2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useToast } from '@/app/contexts/ToastContext';
import api from '@/app/services/api';
import { motion, AnimatePresence } from 'framer-motion';

interface VendorRequestModalProps {
    isOpen: boolean;
    onClose: () => void;
    vendorId: string;
    vendorName: string;
    initialType?: 'quote' | 'availability';
}

export default function VendorRequestModal({ isOpen, onClose, vendorId, vendorName, initialType = 'quote' }: VendorRequestModalProps) {
    const { addToast } = useToast();
    const [type, setType] = useState<'quote' | 'availability'>(initialType);
    const [eventDate, setEventDate] = useState('');
    const [details, setDetails] = useState('');
    const [loading, setLoading] = useState(false);
    const [success, setSuccess] = useState(false);

    const handleSubmit = async () => {
        if (!eventDate || !details.trim()) {
            addToast("Please provide both event date and details", 'error');
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
            await api.post('/vendor-features/requests', {
                vendorId,
                type,
                eventDate,
                details
            });
            setSuccess(true);
            setTimeout(() => {
                setSuccess(false);
                onClose();
            }, 3000);
        } catch (error: any) {
            addToast(error.response?.data?.message || "Failed to send request", 'error');
        } finally {
            setLoading(false);
        }
    };

    return (
        <AnimatePresence>
            {isOpen && (
                <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        onClick={onClose}
                        className="absolute inset-0 bg-black/60 backdrop-blur-sm"
                    />

                    <motion.div
                        initial={{ opacity: 0, scale: 0.95, y: 20 }}
                        animate={{ opacity: 1, scale: 1, y: 0 }}
                        exit={{ opacity: 0, scale: 0.95, y: 20 }}
                        className="relative w-full max-w-[500px] bg-white rounded-[32px] shadow-2xl overflow-hidden flex flex-col"
                    >
                        {/* Header */}
                        <div className="bg-[#EF2F55] p-8 text-white relative">
                            <button
                                onClick={onClose}
                                className="absolute top-6 right-6 p-2 hover:bg-white/10 rounded-full transition-colors"
                            >
                                <X className="w-5 h-5" />
                            </button>
                            <div className="flex items-center gap-4 mb-2">
                                <div className="p-3 bg-white/20 rounded-2xl backdrop-blur-md">
                                    <Send className="w-6 h-6" />
                                </div>
                                <div>
                                    <h3 className="text-2xl font-black tracking-tight">{type === 'quote' ? "Get a Quote" : "Check Availability"}</h3>
                                    <p className="text-white/80 text-xs font-bold uppercase tracking-widest">{vendorName}</p>
                                </div>
                            </div>
                        </div>

                        <div className="p-8 space-y-6">
                            {success ? (
                                <div className="py-10 text-center animate-in zoom-in-95 duration-500">
                                    <div className="w-20 h-20 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center mx-auto mb-6">
                                        <CheckCircle2 className="w-10 h-10" />
                                    </div>
                                    <h4 className="text-2xl font-black text-gray-900 mb-2">Request Sent!</h4>
                                    <p className="text-gray-500 font-medium">Your request has been delivered to the vendor. They will get back to you soon.</p>
                                    <p className="text-[#EF2F55] text-sm font-bold mt-4 uppercase tracking-widest">Opening Chat...</p>
                                </div>
                            ) : (
                                <>
                                    <div className="flex p-1 bg-gray-100 rounded-2xl">
                                        <button
                                            className={`flex-1 py-3 rounded-xl font-bold text-sm transition-all ${type === 'quote' ? 'bg-white text-[#EF2F55] shadow-sm' : 'text-gray-500'}`}
                                            onClick={() => setType('quote')}
                                        >
                                            Price Quote
                                        </button>
                                        <button
                                            className={`flex-1 py-3 rounded-xl font-bold text-sm transition-all ${type === 'availability' ? 'bg-white text-[#EF2F55] shadow-sm' : 'text-gray-500'}`}
                                            onClick={() => setType('availability')}
                                        >
                                            Availability
                                        </button>
                                    </div>

                                    <div className="space-y-4">
                                        <div>
                                            <label className="text-gray-400 text-[10px] font-black uppercase tracking-widest mb-2 block">Event Date</label>
                                            <div className="relative">
                                                <Calendar className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400 pointer-events-none" />
                                                <input
                                                    type="date"
                                                    value={eventDate}
                                                    onChange={(e) => setEventDate(e.target.value)}
                                                    min={new Date().toISOString().split('T')[0]}
                                                    className="w-full pl-12 pr-4 py-4 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-[#EF2F55] font-medium text-gray-900"
                                                />
                                            </div>
                                        </div>

                                        <div>
                                            <label className="text-gray-400 text-[10px] font-black uppercase tracking-widest mb-2 block">{type === 'quote' ? "Requirement Details" : "Event Description"}</label>
                                            <div className="relative">
                                                <Info className="absolute left-4 top-5 w-5 h-5 text-gray-400 pointer-events-none" />
                                                <textarea
                                                    value={details}
                                                    onChange={(e) => setDetails(e.target.value)}
                                                    placeholder={type === 'quote' ? "Tell us about your event (date, number of guests, specific services needed)..." : "Tell us about your event and ask about their availability on your date..."}
                                                    className="w-full pl-12 pr-4 py-4 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-[#EF2F55] font-medium text-gray-900 min-h-[140px]"
                                                />
                                            </div>
                                        </div>
                                    </div>

                                    <Button
                                        onClick={handleSubmit}
                                        disabled={loading}
                                        className="w-full py-8 text-lg font-black uppercase tracking-widest bg-[#EF2F55] hover:bg-rose-700 text-white rounded-2xl shadow-xl shadow-pink-200 transition-all transform active:scale-95"
                                    >
                                        {loading ? "Sending Request..." : "Send Request"}
                                    </Button>
                                </>
                            )}
                        </div>
                    </motion.div>
                </div>
            )}
        </AnimatePresence>
    );
}
