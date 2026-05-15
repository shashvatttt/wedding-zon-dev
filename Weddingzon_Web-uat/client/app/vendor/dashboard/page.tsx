
'use client';

import React, { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/app/context/AuthContext';
import api from '@/app/services/api';
import { Loader2, MessageCircle, Upload, Camera, Phone, ArrowRight, Image as ImageIcon, Search, LogOut } from 'lucide-react';
import VendorCalendar from '@/app/components/VendorCalendar';


interface Availability {
    date: string;
    status: string;
    note?: string;
}

interface Inquiry {
    _id: string;
    email: string;
    phone: string;
    name?: string;
    details: string;
    status: string;
    created_at: string;
}

export default function VendorDashboard() {
    const { user, loading, logout, checkAuth } = useAuth();
    const router = useRouter();
    const [inquiries, setInquiries] = useState<Inquiry[]>([]);
    const [inquiriesLoading, setInquiriesLoading] = useState(true);
    const [uploadingImage, setUploadingImage] = useState(false);
    const fileInputRef = React.useRef<HTMLInputElement>(null);

    useEffect(() => {
        if (!loading && user) {
            // Strict Check: Must be active vendor
            if (user.role !== 'vendor') {
                router.push('/feed');
            } else if (!user.vendor_details?.business_name) {
                router.push('/vendor/onboarding');
            } else if (user.vendor_status !== 'active') {
                router.push('/vendor/waiting');
            } else {
                fetchMyInquiries();
            }
        }
    }, [user, loading, router]);

    const fetchMyInquiries = async () => {
        try {
            setInquiriesLoading(true);
            const { data } = await api.get('/vendor-features/my-inquiries');
            if (data.success) {
                setInquiries(data.data);
            }
        } catch (error) {
            console.error('Failed to fetch inquiries', error);
        } finally {
            setInquiriesLoading(false);
        }
    };


    const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        try {
            setUploadingImage(true);
            const formData = new FormData();
            formData.append('photo', file);

            // 1. Upload to S3
            const uploadRes = await api.post('/uploads', formData, {
                headers: { 'Content-Type': 'multipart/form-data' }
            });

            if (uploadRes.data.success) {
                const imageUrl = uploadRes.data.url;

                // 2. Save to Vendor Details & Profile Photo
                await api.post('/auth/register-details', {
                    role: 'vendor',
                    vendor_details: {
                        business_glance: imageUrl
                    },
                    profilePhoto: imageUrl
                });

                // 3. Refresh Auth State
                await checkAuth();
                // We'll show a small toast or just update state implicitly via useAuth
            }
        } catch (error) {
            console.error('Failed to upload image', error);
            alert('Failed to upload image');
        } finally {
            setUploadingImage(false);
            if (fileInputRef.current) fileInputRef.current.value = '';
        }
    };


    if (loading) {
        return (
            <div className="min-h-screen pt-24 flex justify-center">
                <Loader2 className="animate-spin w-8 h-8 text-pink-600" />
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-rose-50/30 pt-24 pb-12 px-4 sm:px-6 lg:px-8">
            <div className="max-w-7xl mx-auto">
                {/* Header */}
                <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6 mb-8">
                    <div className="flex flex-row items-center gap-4 sm:gap-6">
                        <div className="relative group flex-shrink-0">
                            <div className="w-16 h-16 sm:w-24 sm:h-24 rounded-2xl overflow-hidden bg-white shadow-md border-2 border-pink-100 relative">
                                {user?.profilePhoto || user?.vendor_details?.business_glance ? (
                                    <img
                                        src={user.profilePhoto || user.vendor_details?.business_glance}
                                        alt="Business"
                                        className="w-full h-full object-cover"
                                    />
                                ) : (
                                    <div className="w-full h-full flex items-center justify-center bg-pink-50 text-pink-300">
                                        <Upload className="w-8 h-8" />
                                    </div>
                                )}
                                {uploadingImage && (
                                    <div className="absolute inset-0 bg-black/40 flex items-center justify-center">
                                        <Loader2 className="w-6 h-6 text-white animate-spin" />
                                    </div>
                                )}
                            </div>
                            <button
                                onClick={() => fileInputRef.current?.click()}
                                className="absolute -bottom-2 -right-2 p-2 bg-pink-600 rounded-full text-white shadow-lg hover:bg-pink-700 transition-colors z-10"
                                title="Change Image"
                            >
                                <Camera className="w-4 h-4" />
                            </button>
                            <input
                                type="file"
                                ref={fileInputRef}
                                onChange={handleImageUpload}
                                accept="image/*"
                                className="hidden"
                            />
                        </div>
                        <div>
                            <h1 className="text-xl sm:text-3xl font-bold text-gray-900 line-clamp-1">{user?.vendor_details?.business_name || 'Vendor Dashboard'}</h1>
                            <p className="text-xs sm:text-base text-gray-600 mt-0.5 sm:mt-1">Manage inquiries & availability</p>
                        </div>
                    </div>
                    <div className="flex flex-wrap gap-4">
                        <button
                            onClick={() => router.push('/vendor/gallery')}
                            className="bg-white hover:bg-rose-50 text-[#EF2F55] border border-rose-100 px-6 py-2.5 rounded-full flex items-center gap-2 font-bold transition-all shadow-sm hover:shadow-md transform hover:-translate-y-0.5"
                        >
                            <ImageIcon className="w-5 h-5" />
                            Manage Gallery
                        </button>
                        <button
                            onClick={logout}
                            className="bg-gray-100 hover:bg-gray-200 text-gray-700 px-6 py-2.5 rounded-full flex items-center gap-2 font-medium transition-all transform hover:-translate-y-0.5"
                        >
                            <LogOut className="w-5 h-5" />
                            Logout
                        </button>
                    </div>
                </div>

                {/* Stats Cards */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
                    <div className="bg-white p-6 rounded-2xl shadow-sm border border-rose-100">
                        <div className="flex items-center gap-4">
                            <div className="w-12 h-12 rounded-full bg-pink-100 flex items-center justify-center text-pink-600">
                                <MessageCircle className="w-6 h-6" />
                            </div>
                            <div>
                                <p className="text-sm text-gray-500 font-medium">Total Inquiries</p>
                                <h3 className="text-2xl font-bold text-gray-900">{inquiries.length}</h3>
                            </div>
                        </div>
                    </div>
                    <div className="bg-white p-6 rounded-2xl shadow-sm border border-rose-100/50 cursor-pointer hover:border-[#EF2F55]/30 transition-all group" onClick={() => router.push('/vendor/gallery')}>
                        <div className="flex items-center gap-4">
                            <div className="w-12 h-12 rounded-full bg-pink-50 flex items-center justify-center text-[#EF2F55] group-hover:scale-110 transition-transform">
                                <ImageIcon className="w-6 h-6" />
                            </div>
                            <div>
                                <p className="text-sm text-gray-500 font-medium">Gallery Photos</p>
                                <h3 className="text-2xl font-bold text-gray-900">{user?.photos?.length || 0} / 5</h3>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Inquiries Section */}
                <div className="mb-12">
                    <div className="flex items-center justify-between mb-6">
                        <h2 className="text-2xl font-black text-gray-900 flex items-center gap-3">
                            <div className="w-2 h-8 bg-[#EF2F55] rounded-full" />
                            Recent Inquiries
                            {inquiries.length > 0 && <span className="ml-2 text-sm font-bold bg-rose-50 text-[#EF2F55] px-3 py-1 rounded-full">{inquiries.length}</span>}
                        </h2>
                        {inquiries.length > 0 && (
                            <button 
                                onClick={() => router.push('/vendor/inquiries')}
                                className="text-sm font-bold text-[#EF2F55] hover:text-rose-700 flex items-center gap-1 transition-all"
                            >
                                View All Inquiries
                                <ArrowRight className="w-4 h-4" />
                            </button>
                        )}
                    </div>

                    {inquiriesLoading ? (
                        <div className="flex justify-center py-10">
                            <Loader2 className="animate-spin w-8 h-8 text-[#EF2F55]" />
                        </div>
                    ) : inquiries.length === 0 ? (
                        <div className="bg-white rounded-3xl p-12 text-center border border-dashed border-rose-200">
                            <div className="w-20 h-20 bg-rose-50 rounded-full flex items-center justify-center mx-auto mb-4 text-rose-300">
                                <Search className="w-10 h-10" />
                            </div>
                            <h3 className="text-xl font-bold text-gray-900 mb-2">No inquiries yet</h3>
                            <p className="text-gray-500 font-medium max-w-sm mx-auto">When potential clients fill out your "Get Quote" form, they will appear here!</p>
                        </div>
                    ) : (
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                            {inquiries.slice(0, 3).map((inquiry) => (
                                <div key={inquiry._id} className="bg-white rounded-[32px] p-6 shadow-xl shadow-rose-100/20 border border-rose-50 hover:border-[#EF2F55]/20 transition-all group relative overflow-hidden">
                                     {inquiry.status === 'pending' && (
                                        <div className="absolute top-0 right-0 w-24 h-24 overflow-hidden pointer-events-none">
                                            <div className="absolute top-4 -right-8 w-32 h-6 bg-[#EF2F55] text-white text-[10px] font-black uppercase tracking-widest flex items-center justify-center rotate-45 shadow-lg">
                                                New
                                            </div>
                                        </div>
                                    )}
                                    <div className="flex flex-col h-full gap-4">
                                        <div className="flex items-start gap-3">
                                            <div className="w-10 h-10 bg-rose-50 rounded-2xl flex items-center justify-center text-[#EF2F55] font-black">
                                                {inquiry.email.charAt(0).toUpperCase()}
                                            </div>
                                            <div className="flex-1 min-w-0">
                                                <p className="text-sm font-bold text-gray-900 truncate">{inquiry.email}</p>
                                                <p className="text-[10px] text-gray-400 font-black uppercase tracking-widest">{new Date(inquiry.created_at).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })}</p>
                                            </div>
                                        </div>
                                        
                                        <div className="space-y-3 flex-1">
                                            <div className="flex items-center gap-3 text-sm text-gray-600 bg-gray-50/50 p-3 rounded-2xl border border-gray-100 transition-colors group-hover:bg-rose-50/50 group-hover:border-rose-100">
                                                <Phone className="w-4 h-4 text-[#EF2F55]" />
                                                <span className="font-bold">{inquiry.phone}</span>
                                            </div>
                                            <div className="p-4 bg-gray-50/50 rounded-2xl border border-gray-100 min-h-[80px]">
                                                <p className="text-xs text-gray-500 font-medium italic leading-relaxed">"{inquiry.details}"</p>
                                            </div>
                                        </div>

                                        <div className="flex items-center gap-2 pt-2">
                                            <button 
                                                onClick={() => window.open(`mailto:${inquiry.email}`)}
                                                className="flex-1 bg-white hover:bg-rose-50 text-[#EF2F55] border border-rose-100 py-3 rounded-xl text-[10px] font-black uppercase tracking-tighter transition-all"
                                            >
                                                Email Client
                                            </button>
                                            <button 
                                                onClick={() => window.open(`tel:${inquiry.phone}`)}
                                                className="flex-1 bg-[#EF2F55] hover:bg-rose-700 text-white py-3 rounded-xl text-[10px] font-black uppercase tracking-tighter shadow-lg shadow-pink-100 transition-all active:scale-95"
                                            >
                                                Call Now
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </div>

                {/* Availability Section */}
                <div className="mb-8">
                    <h2 className="text-xl font-bold text-gray-900 mb-4">Availability & Calendar</h2>
                    <div className="max-w-md">
                        <VendorCalendar
                            vendorId={user?._id || ''}
                            initialAvailability={(user as any)?.vendor_details?.availability || []}
                            isEditable={true}
                            onUpdate={() => checkAuth()}
                        />
                    </div>
                </div>

            </div>
        </div>
    );
}
