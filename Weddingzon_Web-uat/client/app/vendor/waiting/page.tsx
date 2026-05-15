'use client';

import { useState, useEffect, useCallback } from 'react';
import { Clock, CheckCircle, RefreshCw, AlertCircle, ShieldCheck, ArrowRight } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../../context/AuthContext';
import api from '../../services/api';
import { motion, AnimatePresence } from 'framer-motion';

export default function VendorWaitingPage() {
    const router = useRouter();
    const { user, loading, checkAuth, logout } = useAuth();
    const [checking, setChecking] = useState(false);
    const [statusMessage, setStatusMessage] = useState<string | null>(null);

    // Initial check on mount logic
    useEffect(() => {
        if (!loading && user) {
            if (user.role !== 'vendor') {
                router.push('/feed');
            } else if (!user.vendor_details?.business_name) {
                router.push('/vendor/onboarding');
            } else if (user.vendor_status === 'active') {
                router.push('/vendor/dashboard');
            }
        }
    }, [user, loading, router]);

    const handleCheckStatus = useCallback(async (isAuto = false) => {
        if (!isAuto) setChecking(true);
        setStatusMessage(null);
        try {
            await checkAuth(); // Refreshes user state from backend
        } catch (error) {
            console.error('Status check failed', error);
            if (!isAuto) setStatusMessage('Failed to check status. Please try again.');
        } finally {
            if (!isAuto) setChecking(false);
        }
    }, [checkAuth]);

    useEffect(() => {
        const interval = setInterval(() => {
            handleCheckStatus(true);
        }, 8000);

        return () => clearInterval(interval);
    }, [handleCheckStatus]);

    if (loading) return (
        <div className="min-h-screen bg-gray-50 flex flex-col items-center justify-center">
            <div className="w-10 h-10 border-4 border-[#7C3AED] border-t-transparent rounded-full animate-spin"></div>
        </div>
    );

    const isRejected = user?.vendor_status === 'rejected';

    const steps = [
        { label: 'Registration', status: 'completed' },
        { label: 'Payment', status: 'completed' },
        { label: 'Final Admin Review', status: 'current' },
        { label: 'Activated', status: 'pending' },
    ];

    return (
        <div className="min-h-screen bg-gradient-to-br from-[#F5F3FF] to-[#FAF8FF] flex flex-col items-center justify-center p-6 font-inter">
            <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="max-w-xl w-full"
            >
                {/* Main Card */}
                <div className="bg-white rounded-[2rem] shadow-[0_20px_50px_rgba(124,58,237,0.1)] overflow-hidden border border-purple-50/50">
                    {/* Header */}
                    <div className="bg-gradient-to-r from-[#7C3AED] to-[#9254FF] p-10 text-center relative overflow-hidden">
                        {/* Decorative background circles */}
                        <div className="absolute top-[-20%] left-[-10%] w-40 h-40 bg-white/10 rounded-full blur-2xl" />
                        <div className="absolute bottom-[-20%] right-[-10%] w-40 h-40 bg-white/10 rounded-full blur-2xl" />

                        <div className="relative z-10">
                            {isRejected ? (
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
                                        <Clock className="h-10 w-10 text-[#7C3AED]" />
                                    </div>
                                </div>
                            )}

                            <h1 className="text-3xl font-bold text-white mb-2">
                                {isRejected ? 'Application Rejected' : 'Verification Underway'}
                            </h1>
                            <p className="text-purple-100 font-medium">
                                Reviewing <strong>{user?.vendor_details?.business_name}</strong>
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
                                        <div className={`w-10 h-10 rounded-full flex items-center justify-center relative z-10 transition-all duration-500 ${step.status === 'completed' ? 'bg-[#7C3AED] text-white' :
                                                step.status === 'current' ? 'bg-white border-4 border-[#7C3AED] text-[#7C3AED] shadow-lg scale-110' :
                                                    'bg-white border-2 border-gray-200 text-gray-300'
                                            }`}>
                                            {step.status === 'completed' ? <CheckCircle className="w-6 h-6" /> :
                                                step.status === 'current' ? <RefreshCw className="w-5 h-5 animate-spin" /> :
                                                    <span className="text-xs font-bold">{idx + 1}</span>}
                                        </div>
                                        <span className={`text-[10px] md:text-xs font-bold uppercase tracking-wider ${step.status === 'current' ? 'text-[#7C3AED]' : 'text-gray-400'
                                            }`}>
                                            {step.label}
                                        </span>
                                    </div>
                                ))}
                            </div>
                        </div>

                        {/* Status Message Card */}
                        <div className="bg-[#F5F3FF] rounded-24 p-6 border border-purple-100 shadow-sm relative overflow-hidden group">
                            <div className="absolute top-0 right-0 p-2 opacity-5">
                                <ShieldCheck className="w-24 h-24 text-[#7C3AED]" />
                            </div>
                            <h3 className="text-purple-900 font-bold mb-3 flex items-center gap-2">
                                <AlertCircle className="w-5 h-5" />
                                Review Notification
                            </h3>
                            <p className="text-purple-700/80 leading-relaxed text-sm md:text-base pr-8">
                                {isRejected
                                    ? 'Your business application was not approved by the regional admin. Please check your details and resubmit.'
                                    : 'Our administrative team is verifying your business credentials and service details. This usually takes 24-48 business hours.'}
                            </p>
                        </div>

                        {/* Actions */}
                        <div className="space-y-4">
                            {isRejected ? (
                                <button
                                    onClick={() => router.push('/vendor/onboarding')}
                                    className="w-full flex items-center justify-center gap-3 bg-red-600 hover:bg-red-700 text-white font-bold py-4 px-6 rounded-2xl transition-all shadow-lg hover:shadow-red-200 active:scale-[0.98]"
                                >
                                    <RefreshCw className="h-5 w-5" />
                                    Review & Resubmit
                                </button>
                            ) : (
                                <button
                                    onClick={() => handleCheckStatus(false)}
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

                            <button
                                onClick={logout}
                                className="w-full text-center text-sm font-medium text-gray-400 hover:text-gray-600 transition-colors"
                            >
                                Sign out of account
                            </button>
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
                        className="text-gray-500 hover:text-[#7C3AED] font-medium transition-colors text-sm flex items-center justify-center gap-1 mx-auto"
                    >
                        Partner Support <ArrowRight className="w-4 h-4" />
                    </button>
                </motion.div>
            </motion.div>
        </div>
    );
}
