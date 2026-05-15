'use client';

import { Suspense, useState, useEffect } from 'react';
import Image from 'next/image';
import { useGoogleLogin } from '@react-oauth/google';
import api from '../services/api';
import { useRouter, useSearchParams } from 'next/navigation';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../contexts/ToastContext';
import LanguageSwitcher from '@/components/LanguageSwitcher';
import { auth } from '@/lib/firebase';
import { RecaptchaVerifier, signInWithPhoneNumber, type ConfirmationResult } from 'firebase/auth';
import { useRef } from 'react';


export function LoginContent() {
    const router = useRouter();
    const { addToast } = useToast();
    const searchParams = useSearchParams();
    const redirectPath = searchParams.get('redirect') || '/feed';

    const [phone, setPhone] = useState('');
    const [countryCode, setCountryCode] = useState('+91');
    const [otp, setOtp] = useState('');
    const [showOtpInput, setShowOtpInput] = useState(false);
    const [confirmationResult, setConfirmationResult] = useState<ConfirmationResult | null>(null);
    const recaptchaVerifierRef = useRef<RecaptchaVerifier | null>(null);
    const [isSending, setIsSending] = useState(false);
    const [cooldown, setCooldown] = useState(0);
    const [isVendorMode, setIsVendorMode] = useState(searchParams.get('type') === 'vendor');

    useEffect(() => {
        if (searchParams.get('type') === 'vendor') {
            setIsVendorMode(true);
        }
    }, [searchParams]);

    useEffect(() => {
        // Recover cooldown from localStorage on mount
        const storedTime = localStorage.getItem('otp_next_allowed_login');
        if (storedTime) {
            const timeLeft = Math.ceil((parseInt(storedTime) - Date.now()) / 1000);
            if (timeLeft > 0) {
                setCooldown(timeLeft);
            } else {
                localStorage.removeItem('otp_next_allowed_login');
            }
        }
    }, []);

    useEffect(() => {
        let interval: NodeJS.Timeout;
        if (cooldown > 0) {
            interval = setInterval(() => {
                setCooldown((prev) => {
                    if (prev <= 1) {
                        localStorage.removeItem('otp_next_allowed_login');
                        return 0;
                    }
                    return prev - 1;
                });
            }, 1000);
        }
        return () => clearInterval(interval);
    }, [cooldown]);


    const { login: contextLogin, isAuthenticated, loading, user, checkAuth } = useAuth();

    useEffect(() => {
        // Only redirect if user is fully authenticated AND has a phone number
        const handleAutoRole = async () => {
            if (!loading && isAuthenticated && user?.phone) {
                const intendedRole = searchParams.get('role');
                
                // Automated Role Assignment if user has no role
                if (intendedRole && (!user.role || user.role === 'user')) {
                    try {
                        const res = await api.post('/auth/register-details', { role: intendedRole });
                        if (res.status === 200) {
                            await checkAuth();
                            return;
                        }
                    } catch (error) {
                        console.error('Failed to auto-assign role in login:', error);
                    }
                }

                // Priority: Check Role & Completion Status
                if (!user.role || user.role === 'user') {
                    router.push('/');
                    return;
                }

                if (user.role === 'franchise') {
                    router.push('/franchise');
                    return;
                }

                if (user.role === 'vendor') {
                    if (user.vendor_details?.business_name) {
                        router.push('/vendor/dashboard');
                    } else {
                        router.push('/vendor/onboarding');
                    }
                    return;
                }

                // Member/Bride/Groom
                if (['member', 'bride', 'groom'].includes(user.role)) {
                    if (user.is_profile_complete) {
                        router.push(redirectPath !== '/feed' ? redirectPath : '/feed');
                    } else {
                        router.push('/onboarding');
                    }
                    return;
                }

                // Fallback
                router.push(redirectPath);
            }
        };

        handleAutoRole();
    }, [isAuthenticated, loading, router, user, redirectPath, searchParams]);

    const countryCodes = [
        { code: '+91', label: 'IN (+91)' },
        { code: '+1', label: 'US (+1)' },
        { code: '+44', label: 'UK (+44)' },
        { code: '+971', label: 'UAE (+971)' },
    ];

    const login = useGoogleLogin({
        onSuccess: async (codeResponse) => {
            try {
                const res = await api.post('/auth/google', {
                    code: codeResponse.code,
                    redirect_uri: 'postmessage',
                });
                if (res.status === 200) {
                    const user = res.data.user;
                    if (res.data.accessToken) {
                        localStorage.setItem('token', res.data.accessToken);
                        window.dispatchEvent(new Event('auth-change'));
                    }

                    if (!user.phone) {
                        await checkAuth();
                        router.push('/signup?step=2');
                    } else {
                        contextLogin(res.data.accessToken, '', user);
                        router.push(redirectPath);
                    }
                }
            } catch (error) {
                console.error('Google Auth Failed', error);
                addToast('Google Login Failed', 'error');
            }
        },
        flow: 'auth-code',
    });

    const fullPhone = `${countryCode}${phone}`;

    const setupRecaptcha = () => {
        if (recaptchaVerifierRef.current) {
            try {
                recaptchaVerifierRef.current.clear();
            } catch (e) {
                console.warn('Recaptcha clear failed:', e);
            }
            recaptchaVerifierRef.current = null;
        }

        const container = document.getElementById('recaptcha-container');
        if (container) {
            container.innerHTML = '';
        }

        recaptchaVerifierRef.current = new RecaptchaVerifier(auth, 'recaptcha-container', {
            size: 'invisible',
            callback: (response: any) => {
                console.log('reCAPTCHA solved');
            },
            'expired-callback': () => {
                addToast('reCAPTCHA expired. Please try again.', 'error');
            }
        });
    };

    const handleSendOtp = async () => {
        if (!phone || phone.length !== 10) {
            addToast('Phone number must be exactly 10 digits', 'error');
            return;
        }

        setIsSending(true);
        try {
            setupRecaptcha();
            const appVerifier = recaptchaVerifierRef.current;
            if (!appVerifier) throw new Error('Recaptcha failed to initialize');
            
            const result = await signInWithPhoneNumber(auth, fullPhone, appVerifier);
            setConfirmationResult(result);
            
            setShowOtpInput(true);
            setCooldown(60);
            localStorage.setItem('otp_next_allowed_login', (Date.now() + 60000).toString());

            addToast('OTP sent successfully', 'success');
        } catch (error: any) {
            console.error('Send OTP Failed', error);
            const msg = error.code === 'auth/captcha-check-failed' 
                ? 'reCAPTCHA verification failed. Please refresh and try again.' 
                : error.message || 'Failed to send OTP';
            addToast(msg, 'error');
            if (recaptchaVerifierRef.current) {
                recaptchaVerifierRef.current.clear();
                recaptchaVerifierRef.current = null;
            }
        } finally {
            setIsSending(false);
        }
    };

    const handleVerifyOtp = async () => {
        if (!otp) {
            addToast('Please enter OTP', 'error');
            return;
        }

        if (!confirmationResult) {
            addToast('Session expired. Please request a new OTP.', 'error');
            return;
        }

        try {
            const userCredential = await confirmationResult.confirm(otp);
            const firebaseUser = userCredential.user;
            const idToken = await firebaseUser.getIdToken();

            const res = await api.post('/auth/firebase-login', {
                idToken
            });

            if (res.status === 200) {
                const user = res.data.user;
                if (res.data.accessToken) {
                    localStorage.setItem('token', res.data.accessToken);
                    window.dispatchEvent(new Event('auth-change'));
                }

                await checkAuth();

                addToast('Login successful', 'success');

                if (!user.role || user.role === 'user') {
                    router.push('/');
                } else if (user.role === 'member' || user.role === 'bride' || user.role === 'groom') {
                    if (user.is_profile_complete) {
                        router.push(redirectPath);
                    } else {
                        router.push('/onboarding');
                    }
                } else if (user.role === 'vendor') {
                    if (user.vendor_details?.business_name) {
                        router.push('/vendor/dashboard');
                    } else {
                        router.push('/vendor/onboarding');
                    }
                } else if (user.role === 'franchise') {
                    router.push('/franchise');
                } else {
                    router.push(redirectPath);
                }
            }
        } catch (error: any) {
            console.error('Verify OTP Failed', error);
            const msg = error.message || 'Invalid OTP';
            addToast(msg, 'error');
        }
    };

    return (
        <div className="flex min-h-screen w-full items-center justify-center relative overflow-hidden">
            {/* Language Switcher Overlay */}
            <div className="absolute top-4 right-4 z-50">
                <LanguageSwitcher variant="transparent" />
            </div>

            {/* Background Image */}
            <div className="absolute inset-0 z-0">
                <Image
                    src="/wedding-hero-new.png"
                    alt="Background"
                    fill
                    className="object-cover"
                    priority
                />
                {/* Overlay for better text readability if needed, though glass effect handles some */}
                <div className="absolute inset-0 bg-black/30" />
            </div>

            {/* Glassmorphism Card */}
            <div className="relative z-10 w-full max-w-[450px] p-4 sm:p-8">
                <div className="w-full bg-white/20 backdrop-blur-lg border border-white/30 shadow-2xl rounded-3xl p-8 sm:p-10 text-white">
                    <div className="mb-8 text-center">
                        <h2 className="mb-2 text-3xl font-bold tracking-tight text-white drop-shadow-md">
                            {isVendorMode ? 'Vendor Admin Access' : 'Welcome Back'}
                        </h2>
                        <h2 className="text-3xl font-bold tracking-tight text-rose-300 drop-shadow-md mb-2">
                            WeddingZon
                        </h2>
                        <p className="text-sm text-gray-100 font-light">
                            {isVendorMode ? 'OTP-only login/signup for Vendors' : 'Sign in to your account'}
                        </p>
                    </div>

                    <div className="space-y-6">
                        {/* Google Login */}
                        {!isVendorMode && (
                            <div>
                                <button
                                    onClick={() => login()}
                                    className="flex w-full items-center justify-center gap-3 rounded-xl border border-white/40 bg-white/90 px-4 py-3 text-sm font-semibold text-gray-800 shadow-lg hover:bg-white hover:scale-[1.02] transition-all duration-200"
                                >
                                    <svg className="h-5 w-5" viewBox="0 0 24 24">
                                        <path
                                            d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                                            fill="#4285F4"
                                        />
                                        <path
                                            d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.04-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                                            fill="#34A853"
                                        />
                                        <path
                                            d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                                            fill="#FBBC05"
                                        />
                                        <path
                                            d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                                            fill="#EA4335"
                                        />
                                    </svg>
                                    Continue with Google
                                </button>
                            </div>
                        )}

                        {!isVendorMode && (
                            <div className="flex items-center gap-4">
                                <div className="flex-grow border-t border-white/30" />
                                <span className="text-sm text-white/80 whitespace-nowrap">Or continue with phone</span>
                                <div className="flex-grow border-t border-white/30" />
                            </div>
                        )}

                        {/* Phone Login */}
                        <div className="space-y-5">
                            {!showOtpInput ? (
                                <>
                                    <div>
                                        <label htmlFor="phone" className="block text-sm font-medium text-gray-100 mb-1">
                                            Phone Number
                                        </label>
                                        <div className="flex rounded-lg shadow-sm">
                                            <select
                                                value={countryCode}
                                                onChange={(e) => setCountryCode(e.target.value)}
                                                className="relative w-24 rounded-l-lg border border-white/30 bg-white/20 px-3 py-3 text-sm text-white focus:outline-none focus:ring-2 focus:ring-rose-400 [&>option]:text-gray-900"
                                            >
                                                {countryCodes.map((c) => (
                                                    <option key={c.code} value={c.code}>
                                                        {c.code}
                                                    </option>
                                                ))}
                                            </select>
                                            <input
                                                placeholder="Enter your phone number"
                                                value={phone}
                                                onChange={(e) => {
                                                    const val = e.target.value.replace(/\D/g, '');
                                                    if (val.length <= 10) setPhone(val);
                                                }}
                                                className="relative block w-full rounded-r-lg border border-white/30 bg-white/20 px-3 py-3 text-white placeholder-gray-300 focus:outline-none focus:ring-2 focus:ring-rose-400 sm:text-sm"
                                            />
                                        </div>
                                    </div>
                                    <button
                                        onClick={handleSendOtp}
                                        disabled={!phone || cooldown > 0}
                                        className={`flex w-full justify-center rounded-xl px-4 py-3 text-sm font-semibold text-white shadow-lg focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-rose-400 transition-all ${cooldown > 0 ? 'bg-gray-500/50 cursor-not-allowed' : 'bg-rose-600 hover:bg-rose-500 hover:scale-[1.02]'
                                            }`}
                                    >
                                        {cooldown > 0 ? `Resend OTP in ${cooldown}s` : 'Send OTP'}
                                    </button>
                                    <div id="recaptcha-container"></div>
                                </>
                            ) : (
                                <div className="space-y-4 animate-in fade-in slide-in-from-bottom-4 duration-500">
                                    <div>
                                        <div className="flex items-center justify-between mb-2">
                                            <label htmlFor="otp" className="block text-sm font-medium text-gray-100">
                                                Enter Verification Code
                                            </label>
                                            <button
                                                onClick={() => setShowOtpInput(false)}
                                                className="text-xs font-medium text-rose-300 hover:text-rose-200"
                                            >
                                                Change Number
                                            </button>
                                        </div>
                                        <input
                                            id="otp"
                                            type="text"
                                            maxLength={6}
                                            placeholder="• • • • • •"
                                            value={otp}
                                            onChange={(e) => setOtp(e.target.value)}
                                            className="block w-full rounded-xl border border-white/30 bg-white/20 px-3 py-3 text-center text-2xl font-bold tracking-[0.5em] text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-rose-400"
                                        />
                                    </div>
                                    <button
                                        onClick={handleVerifyOtp}
                                        disabled={!otp}
                                        className="flex w-full justify-center rounded-xl bg-rose-600 px-4 py-3 text-sm font-semibold text-white shadow-lg hover:bg-rose-500 hover:scale-[1.02] focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-rose-600 disabled:bg-rose-400/50 disabled:cursor-not-allowed transition-all"
                                    >
                                        Verify & Login
                                    </button>
                                </div>
                            )}
                            <div className="mt-6 text-center space-y-3">
                                <p className="text-sm text-gray-200">
                                    Are you a {isVendorMode ? 'User' : 'Vendor Admin'}?{' '}
                                    <button
                                        onClick={() => setIsVendorMode(!isVendorMode)}
                                        className="text-white hover:text-rose-200 hover:underline font-bold whitespace-nowrap"
                                    >
                                        Click Here
                                    </button>
                                </p>
                                <p className="text-sm text-gray-200">
                                    Are you a Franchise Agent?{' '}
                                    <button
                                        onClick={() => router.push('/franchise/login')}
                                        className="text-white hover:text-rose-200 hover:underline font-bold whitespace-nowrap"
                                    >
                                        Login Here
                                    </button>
                                </p>
                            </div>
                            {!isVendorMode && (
                                <div className="mt-4 text-center">
                                    <p className="text-sm text-gray-200">
                                        OR{' '}
                                        <a href="/signup" className="font-bold text-white hover:text-rose-200 hover:underline transition-colors">
                                            Create Account
                                        </a>
                                    </p>
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

export default function Login() {
    return (
        <Suspense fallback={<div>Loading...</div>}>
            <LoginContent />
        </Suspense>
    );
}
