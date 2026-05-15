'use client';

import { useState, useEffect, useCallback } from 'react';
import { Clock, CheckCircle, RefreshCw, AlertCircle, ShieldCheck, ArrowRight } from 'lucide-react';
import { useRouter } from 'next/navigation';
import api from '@/app/services/api';
import { motion, AnimatePresence } from 'framer-motion';

export default function WaitingForApprovalPage() {
    const router = useRouter();
    const [checking, setChecking] = useState(false);
    const [statusMessage, setStatusMessage] = useState<string | null>(null);

    const checkStatus = useCallback(async (isAuto = false) => {
        if (!isAuto) setChecking(true);
        setStatusMessage(null);
        try {
            const { data: user } = await api.get(`/auth/me?t=${Date.now()}`);

            if (user.role !== 'franchise') {
                router.push('/feed');
                return;
            }

            if (user.franchise_status === 'active') {
                router.push('/franchise');
            } else if (user.franchise_status === 'rejected') {
                setStatusMessage('Your application was rejected. Please contact support.');
            } else if (user.franchise_status === 'pending_payment') {
                if (!isAuto) setStatusMessage('Payment processing or verification pending.');
            } else {
                if (!isAuto) setStatusMessage('Still under review. Please check again later.');
            }
        } catch (error) {
            console.error('Status check failed', error);
            if (!isAuto) setStatusMessage('Failed to check status. Please try again.');
        } finally {
            if (!isAuto) setChecking(false);
        }
    }, [router]);

    useEffect(() => {
        checkStatus(true);
        const interval = setInterval(() => {
            checkStatus(true);
        }, 8000); // Polling every 8 seconds for a smoother feel

        return () => clearInterval(interval);
    }, [checkStatus]);

    const steps = [
        { label: 'Registration', status: 'completed' },
        { label: 'Payment', status: 'completed' },
        { label: 'Final Admin Review', status: 'current' },
        { label: 'Activated', status: 'pending' },
    ];

    return (
        <div className="min-h-screen bg-gradient-to-br from-[#FFF5F7] to-[#FFF0F3] flex flex-col items-center justify-center p-6 font-inter">
            <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="max-w-xl w-full"
            >
                {/* Main Card */}
                <div className="bg-white rounded-[2rem] shadow-[0_20px_50px_rgba(239,47,85,0.1)] overflow-hidden border border-rose-50/50">
                    {/* Header */}
                    <div className="bg-gradient-to-r from-[#EF2F55] to-[#FF4D70] p-10 text-center relative overflow-hidden">
                        {/* Decorative background circles */}
                        <div className="absolute top-[-20%] left-[-10%] w-40 h-40 bg-white/10 rounded-full blur-2xl" />
                        <div className="absolute bottom-[-20%] right-[-10%] w-40 h-40 bg-white/10 rounded-full blur-2xl" />

                        <div className="relative z-10">
                            {statusMessage && statusMessage.includes('rejected') ? (
                                <motion.div
                                    initial={{ scale: 0.8 }}
                                    animate={{ scale: 1 }}
                                    className="mx-auto flex h-20 w-20 items-center justify-center rounded-2xl bg-white/20 backdrop-blur-md mb-6 shadow-xl"
                                >
                                    <AlertCircle className="h-10 w-10 text-white" />
                                </motion.div>
                            ) : (
                                <div className="mx-auto relative h-24 w-24 mb-6">
                                    {/* Pulse animations */}
                                    <motion.div
                                        animate={{ scale: [1, 1.2, 1], opacity: [0.3, 0.1, 0.3] }}
                                        transition={{ duration: 2, repeat: Infinity }}
                                        className="absolute inset-0 bg-white rounded-full"
                                    />
                                    <motion.div
                                        animate={{ scale: [1, 1.4, 1], opacity: [0.2, 0, 0.2] }}
                                        transition={{ duration: 2, repeat: Infinity, delay: 0.5 }}
                                        className="absolute inset-0 bg-white rounded-full"
                                    />
                                    <div className="relative z-20 flex h-24 w-24 items-center justify-center rounded-full bg-white shadow-xl">
                                        <Clock className="h-10 w-10 text-[#EF2F55]" />
                                    </div>
                                </div>
                            )}

                            <h1 className="text-3xl font-bold text-white mb-2">
                                {statusMessage && statusMessage.includes('rejected') ? 'Application Rejected' : 'Approval Pending'}
                            </h1>
                            <p className="text-rose-100 font-medium">
                                We're reviewing your application details
                            </p>
                        </div>
                    </div>

                    {/* Content */}
                    <div className="p-8 md:p-10 space-y-10">
                        {/* Progress Tracker */}
                        <div className="relative">
                            <div className="absolute top-5 left-0 w-full h-1 bg-gray-100 rounded-full" />
                            <div className="relative flex justify-between">
                                {steps.map((step, idx) => (
                                    <div key={idx} className="flex flex-col items-center gap-3">
                                        <div className={`w-10 h-10 rounded-full flex items-center justify-center relative z-10 transition-all duration-500 ${step.status === 'completed' ? 'bg-[#EF2F55] text-white' :
                                                step.status === 'current' ? 'bg-white border-4 border-[#EF2F55] text-[#EF2F55] shadow-lg scale-110' :
                                                    'bg-white border-2 border-gray-200 text-gray-300'
                                            }`}>
                                            {step.status === 'completed' ? <CheckCircle className="w-6 h-6" /> :
                                                step.status === 'current' ? <RefreshCw className="w-5 h-5 animate-spin" /> :
                                                    <span className="text-xs font-bold">{idx + 1}</span>}
                                        </div>
                                        <span className={`text-[10px] md:text-xs font-bold uppercase tracking-wider ${step.status === 'current' ? 'text-[#EF2F55]' : 'text-gray-400'
                                            }`}>
                                            {step.label}
                                        </span>
                                    </div>
                                ))}
                            </div>
                        </div>

                        {/* Status Message Card */}
                        <div className="bg-[#FFF5F7] rounded-24 p-6 border border-rose-100 shadow-sm relative overflow-hidden group">
                            <div className="absolute top-0 right-0 p-2 opacity-5">
                                <ShieldCheck className="w-24 h-24 text-[#EF2F55]" />
                            </div>
                            <h3 className="text-rose-900 font-bold mb-3 flex items-center gap-2">
                                <AlertCircle className="w-5 h-5" />
                                Review Status
                            </h3>
                            <p className="text-rose-700/80 leading-relaxed text-sm md:text-base pr-8">
                                {statusMessage || 'Your documents and payment are currently being verified by our regional administration team. This typically takes 24-48 hours.'}
                            </p>
                        </div>

                        {/* Actions */}
                        <div className="space-y-4">
                            {statusMessage && statusMessage.includes('rejected') ? (
                                <button
                                    onClick={() => router.push('/franchise/onboarding')}
                                    className="w-full flex items-center justify-center gap-3 bg-red-600 hover:bg-red-700 text-white font-bold py-4 px-6 rounded-2xl transition-all shadow-lg hover:shadow-red-200 active:scale-[0.98]"
                                >
                                    <RefreshCw className="h-5 w-5" />
                                    Resubmit Application
                                </button>
                            ) : (
                                <button
                                    onClick={() => checkStatus(false)}
                                    disabled={checking}
                                    className="w-full flex items-center justify-center gap-3 bg-gray-900 hover:bg-black text-white font-bold py-4 px-6 rounded-2xl transition-all shadow-xl hover:shadow-gray-200 disabled:opacity-70 disabled:cursor-not-allowed group active:scale-[0.98]"
                                >
                                    {checking ? (
                                        <RefreshCw className="h-5 w-5 animate-spin" />
                                    ) : (
                                        <RefreshCw className="h-5 w-5 group-hover:rotate-180 transition-transform duration-500" />
                                    )}
                                    {checking ? 'Refreshing Status...' : 'Check Status Now'}
                                </button>
                            )}

                            <p className="text-center text-xs text-gray-400">
                                This page will automatically refresh once your franchise is activated.
                            </p>
                        </div>
                    </div>
                </div>

                {/* Footer Link */}
                <motion.div
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ delay: 0.5 }}
                    className="mt-8 text-center"
                >
                    <button
                        onClick={() => router.push('/support')}
                        className="text-gray-500 hover:text-[#EF2F55] font-medium transition-colors text-sm flex items-center justify-center gap-1 mx-auto"
                    >
                        Need help? Contact our Franchise Support team <ArrowRight className="w-4 h-4" />
                    </button>
                </motion.div>
            </motion.div>
        </div>
    );
}
