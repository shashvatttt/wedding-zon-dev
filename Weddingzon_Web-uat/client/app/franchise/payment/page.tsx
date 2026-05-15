'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import api from '../../services/api';
import { CreditCard, CheckCircle, ShieldCheck, ArrowRight, Zap, Sparkles } from 'lucide-react';
import { useToast } from '../../contexts/ToastContext';
import { useAuth } from '../../context/AuthContext';
import { motion } from 'framer-motion';

export default function FranchisePaymentPage() {
    const router = useRouter();
    const { addToast } = useToast();
    const [loading, setLoading] = useState(false);

    const { checkAuth } = useAuth();

    const handlePayment = async () => {
        setLoading(true);
        try {
            await api.post('/franchise/payment');
            // Refresh auth state so AuthContext knows we've paid
            await checkAuth();
            router.push('/franchise/waiting');
        } catch (err) {
            console.error('Payment submission failed:', err);
            addToast('Payment failed. Please try again.', 'error');
        } finally {
            setLoading(false);
        }
    };

    const benefits = [
        "Official WeddingZon Partner Badge",
        "Unlimited Member Profiles Access",
        "Lead Management & Analytics Tool",
        "Dedicated Relationship Manager",
        "Premium Listing in Search Results"
    ];

    return (
        <div className="min-h-screen bg-gradient-to-tr from-[#FFF5F7] via-white to-[#FFF0F3] flex flex-col items-center justify-center p-6 font-inter">
            <motion.div
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                className="max-w-[480px] w-full"
            >
                {/* Premium Banner */}
                <div className="bg-gradient-to-r from-[#EF2F55] to-[#FF6B8B] rounded-t-[2.5rem] p-8 text-center relative overflow-hidden shadow-lg">
                    <div className="absolute top-0 right-0 p-4 opacity-20">
                        <Sparkles className="w-12 h-12 text-white" />
                    </div>
                    <motion.div
                        initial={{ y: 10, opacity: 0 }}
                        animate={{ y: 0, opacity: 1 }}
                        transition={{ delay: 0.2 }}
                    >
                        <h1 className="text-3xl font-extrabold text-white tracking-tight">Franchise Activation</h1>
                        <p className="text-rose-100 mt-2 font-medium">Unlock your business potential today</p>
                    </motion.div>
                </div>

                {/* Main Content Card */}
                <div className="bg-white rounded-b-[2.5rem] shadow-[0_25px_60px_rgba(239,47,85,0.12)] p-8 md:p-10 border-x border-b border-rose-50">
                    <div className="flex justify-center mb-8">
                        <div className="relative">
                            <motion.div
                                animate={{ rotate: 360 }}
                                transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
                                className="absolute inset-[-8px] border-2 border-dashed border-rose-200 rounded-full"
                            />
                            <div className="h-24 w-24 bg-rose-50 rounded-full flex items-center justify-center shadow-inner">
                                <ShieldCheck className="h-12 w-12 text-[#EF2F55]" />
                            </div>
                        </div>
                    </div>

                    <div className="text-center mb-10">
                        <div className="inline-flex items-center gap-2 bg-rose-50 text-[#EF2F55] px-4 py-1.5 rounded-full text-xs font-bold uppercase tracking-widest mb-4">
                            <Zap className="w-3.5 h-3.5 fill-current" />
                            Lifetime Access
                        </div>
                        <div className="flex items-baseline justify-center gap-1">
                            <span className="text-2xl font-bold text-gray-400">₹</span>
                            <h2 className="text-6xl font-black text-gray-900 tracking-tighter">25,000</h2>
                        </div>
                        <p className="text-gray-500 font-medium mt-2">One-time Franchise Integration Fee</p>
                    </div>

                    <div className="space-y-4 mb-10 bg-gray-50/50 p-6 rounded-3xl border border-gray-100">
                        <h4 className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-2">What's included:</h4>
                        {benefits.map((benefit, i) => (
                            <motion.div
                                key={i}
                                initial={{ x: -10, opacity: 0 }}
                                animate={{ x: 0, opacity: 1 }}
                                transition={{ delay: 0.4 + (i * 0.1) }}
                                className="flex items-center gap-3"
                            >
                                <div className="bg-green-100 rounded-full p-1">
                                    <CheckCircle className="h-3.5 w-3.5 text-green-600" />
                                </div>
                                <span className="text-gray-700 text-sm font-medium">{benefit}</span>
                            </motion.div>
                        ))}
                    </div>

                    <motion.button
                        whileHover={{ scale: 1.02 }}
                        whileTap={{ scale: 0.98 }}
                        onClick={handlePayment}
                        disabled={loading}
                        className="w-full bg-gray-900 hover:bg-black text-white py-5 rounded-2xl font-bold text-lg shadow-2xl shadow-gray-200 transition-all flex items-center justify-center gap-3 group disabled:opacity-70"
                    >
                        {loading ? (
                            <div className="h-6 w-6 border-2 border-white border-t-transparent rounded-full animate-spin" />
                        ) : (
                            <>
                                <CreditCard className="h-6 w-6" />
                                <span>Complete Payment</span>
                                <ArrowRight className="h-5 w-5 group-hover:translate-x-1 transition-transform" />
                            </>
                        )}
                    </motion.button>

                    <div className="mt-8 flex items-center justify-center gap-4 text-[10px] text-gray-400 font-medium">
                        <span className="flex items-center gap-1"><ShieldCheck className="w-3 h-3" /> Secure Payment</span>
                        <span className="h-1 w-1 bg-gray-300 rounded-full" />
                        <span>Instant Activation</span>
                        <span className="h-1 w-1 bg-gray-300 rounded-full" />
                        <span>24/7 Support</span>
                    </div>
                </div>

                <p className="text-center text-xs text-gray-400 mt-8 px-8 leading-relaxed">
                    By proceeding with payment, you agree to our <a href="#" className="underline">Partnership Agreement</a> and <a href="#" className="underline">Refund Policy</a>.
                    Transactions are processed securely via SSL encryption.
                </p>
            </motion.div>
        </div>
    );
}
