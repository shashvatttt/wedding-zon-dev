'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import api from '../../services/api';
import { useAuth } from '../../context/AuthContext';
import { Eye, EyeOff, Lock, User } from 'lucide-react';
import LanguageSwitcher from '@/components/LanguageSwitcher';

export default function FranchiseLoginPage() {
    const router = useRouter();
    const { login } = useAuth();
    const [formData, setFormData] = useState({ username: '', password: '' });
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);
    const [showPassword, setShowPassword] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError('');
        setLoading(true);

        try {
            const res = await api.post('/auth/login', formData);
            if (res.data.success) {
                const { user, accessToken } = res.data;
                // Use Auth Context to set state
                login(accessToken, '', user);

                // Redirect based on role
                if (user.role === 'franchise') {
                    router.push('/franchise');
                } else if (user.role === 'member' || user.role === 'bride' || user.role === 'groom') {
                    router.push('/feed');
                } else {
                    router.push('/feed');
                }
            }
        } catch (err: any) {
            console.error('Login Failed', err);
            setError(err.response?.data?.message || 'Invalid Request');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4 relative">
            {/* Language Switcher Overlay */}
            <div className="absolute top-4 right-4 z-50">
                <LanguageSwitcher />
            </div>

            <div className="max-w-md w-full space-y-8 bg-white p-10 rounded-xl shadow-lg">
                <div className="text-center">
                    <button
                        onClick={() => router.back()}
                        className="flex items-center text-sm text-gray-500 hover:text-gray-700 mb-4 transition-colors"
                    >
                        &larr; Back
                    </button>
                    <h2 className="mt-2 text-3xl font-extrabold text-gray-900">Franchise Login</h2>
                    <p className="mt-2 text-sm text-gray-600">Access your Franchise Account or Member Profile</p>
                </div>
                <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
                    <div className="rounded-md shadow-sm -space-y-px">
                        <div className="relative">
                            <User className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                            <input
                                name="username"
                                type="text"
                                required
                                className="appearance-none rounded-none relative block w-full px-10 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-rose-500 focus:border-rose-500 focus:z-10 sm:text-sm"
                                placeholder="Username"
                                value={formData.username}
                                onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                            />
                        </div>
                        <div className="relative">
                            <Lock className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                            <input
                                name="password"
                                type={showPassword ? 'text' : 'password'}
                                required
                                className="appearance-none rounded-none relative block w-full px-10 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-rose-500 focus:border-rose-500 focus:z-10 sm:text-sm"
                                placeholder="Password"
                                value={formData.password}
                                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                            />
                            <button
                                type="button"
                                onClick={() => setShowPassword(!showPassword)}
                                className="absolute right-3 top-3 text-gray-400 hover:text-gray-600"
                            >
                                {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                            </button>
                        </div>
                    </div>

                    {error && (
                        <div className="text-red-500 text-sm text-center bg-red-50 p-2 rounded">
                            {error}
                        </div>
                    )}

                    <div>
                        <button
                            type="submit"
                            disabled={loading}
                            className={`group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-md text-white ${loading ? 'bg-rose-400' : 'bg-rose-600 hover:bg-rose-700'} focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-rose-500 transition-colors`}
                        >
                            {loading ? 'Signing in...' : 'Sign in'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}
