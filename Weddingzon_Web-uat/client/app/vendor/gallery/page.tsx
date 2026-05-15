'use client';

import React, { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/app/context/AuthContext';
import api from '@/app/services/api';
import { Loader2, ArrowLeft, ImageIcon, ShieldCheck, Camera } from 'lucide-react';
import PhotoUploadGrid from '@/app/components/PhotoUploadGrid';
import { ToastProvider, useToast } from '@/app/contexts/ToastContext';

function GalleryContent() {
    const { user, loading, checkAuth } = useAuth();
    const router = useRouter();
    const [photos, setPhotos] = useState<any[]>([]);
    const { addToast } = useToast();

    useEffect(() => {
        if (!loading) {
            if (!user || user.role !== 'vendor') {
                router.push('/feed');
            } else if (user.photos) {
                setPhotos(user.photos);
            }
        }
    }, [user, loading, router]);

    const updateProfilePhotoLocal = (url: string) => {
        // This is handled by checkAuth() usually, but we can update state if needed
        checkAuth();
    };

    if (loading || !user) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gray-50">
                <Loader2 className="w-8 h-8 text-[#EF2F55] animate-spin" />
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-[#FFF5F7] pt-24 pb-12 px-4 sm:px-6 lg:px-8">
            <div className="max-w-4xl mx-auto">
                {/* Header */}
                <div className="mb-8 flex items-center justify-between">
                    <button
                        onClick={() => router.back()}
                        className="flex items-center gap-2 text-gray-600 hover:text-gray-900 font-bold transition-colors group"
                    >
                        <div className="p-2 bg-white rounded-xl shadow-sm group-hover:bg-gray-50 transition-colors">
                            <ArrowLeft className="w-5 h-5" />
                        </div>
                        Back to Dashboard
                    </button>
                    <div className="hidden sm:flex items-center gap-2 bg-white px-4 py-2 rounded-2xl shadow-sm border border-pink-100">
                        <ShieldCheck className="w-4 h-4 text-green-500" />
                        <span className="text-xs font-bold text-gray-500 uppercase tracking-widest">Verified Vendor</span>
                    </div>
                </div>

                {/* Title Section */}
                <div className="bg-white rounded-[40px] p-8 sm:p-12 shadow-xl shadow-pink-100/50 border border-white mb-8 relative overflow-hidden">
                    <div className="absolute top-0 right-0 w-64 h-64 bg-pink-50/50 rounded-full -mr-32 -mt-32 blur-3xl" />
                    
                    <div className="relative z-10">
                        <div className="w-16 h-16 bg-[#EF2F55] rounded-2xl flex items-center justify-center mb-6 shadow-lg shadow-pink-200">
                            <ImageIcon className="w-8 h-8 text-white" />
                        </div>
                        <h1 className="text-3xl sm:text-4xl font-black text-gray-900 mb-4 tracking-tight">Business Portfolio</h1>
                        <p className="text-gray-500 font-medium max-w-xl leading-relaxed">
                            Showcase your best work to potential clients. You can upload up to <span className="text-[#EF2F55] font-bold">5 high-quality photos</span> that will appear prominently on your public profile.
                        </p>
                    </div>
                </div>

                {/* Management Grid */}
                <div className="bg-white rounded-[40px] p-6 sm:p-10 shadow-xl shadow-pink-100/50 border border-white">
                    <div className="flex items-center justify-between mb-8">
                        <div className="flex items-center gap-3">
                            <div className="w-2 h-6 bg-[#EF2F55] rounded-full" />
                            <h2 className="text-xl font-bold text-gray-900 tracking-tight">Manage Photos</h2>
                            <span className="bg-gray-100 text-gray-500 text-[10px] font-black px-2.5 py-1 rounded-full uppercase tracking-widest">
                                {photos.length} / 5
                            </span>
                        </div>
                    </div>

                    <div className="bg-pink-50/30 rounded-3xl p-6 sm:p-8 border border-pink-100/50">
                        <PhotoUploadGrid
                            photos={photos}
                            setPhotos={setPhotos}
                            updateProfilePhotoLocal={updateProfilePhotoLocal}
                            maxPhotos={5}
                            uploadEndpoint="/users/upload-photos"
                            deleteEndpoint="/users/photos"
                        />
                    </div>

                    <div className="mt-8 flex items-start gap-4 p-5 bg-blue-50/50 rounded-3xl border border-blue-100">
                        <div className="bg-blue-100 p-2 rounded-xl text-blue-600">
                            <Camera className="w-5 h-5" />
                        </div>
                        <div>
                            <h4 className="text-sm font-bold text-blue-900 mb-1">Photo Tip</h4>
                            <p className="text-xs text-blue-700/80 font-medium leading-relaxed">
                                Use bright, clear photos that represent your service category. High-resolution images (under 50MB) with a 3:4 aspect ratio look best on your profile.
                            </p>
                        </div>
                    </div>
                </div>

                {/* Bottom Action */}
                <div className="mt-8 text-center">
                    <button
                        onClick={() => router.push(`/${user?.username}`)}
                        className="text-sm font-bold text-[#EF2F55] hover:text-rose-700 underline underline-offset-4"
                    >
                        View Public Profile
                    </button>
                </div>
            </div>
        </div>
    );
}

export default function VendorGalleryPage() {
    return (
        <ToastProvider>
            <GalleryContent />
        </ToastProvider>
    );
}
