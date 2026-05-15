'use client';

import React, { useState, useRef } from 'react';
import { Image as ImageIcon, Plus, Trash2, Loader2, Camera, Star } from 'lucide-react';
import Image from 'next/image';
import api from '@/app/services/api';
import { useToast } from '@/app/contexts/ToastContext';
import ConfirmationModal from '@/components/ConfirmationModal';
import {
    Carousel,
    CarouselContent,
    CarouselItem,
    CarouselNext,
    CarouselPrevious,
} from "@/components/ui/carousel";
import Autoplay from 'embla-carousel-autoplay';

interface Photo {
    _id: string;
    url: string;
    isProfile: boolean;
    key?: string;
}

interface VendorGalleryProps {
    vendorId: string;
    photos: Photo[];
    isOwner: boolean;
    onUpdate: (photos: Photo[]) => void;
}

export default function VendorGallery({ vendorId, photos, isOwner, onUpdate }: VendorGalleryProps) {
    const [uploading, setUploading] = useState(false);
    const [deleteModalOpen, setDeleteModalOpen] = useState(false);
    const [photoToDelete, setPhotoToDelete] = useState<string | null>(null);
    const fileInputRef = useRef<HTMLInputElement>(null);
    const { addToast } = useToast();
    const plugin = React.useRef(
        Autoplay({ delay: 4000, stopOnInteraction: true })
    );

    const maxPhotos = 5;

    const handleUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        if (!e.target.files?.length) return;
        
        const files = Array.from(e.target.files);
        const remainingSlots = maxPhotos - photos.length;
        
        if (remainingSlots <= 0) {
            addToast(`You can only upload up to ${maxPhotos} photos.`, 'error');
            return;
        }

        const filesToUpload = files.slice(0, remainingSlots);
        if (files.length > remainingSlots) {
            addToast(`Only the first ${remainingSlots} photos will be uploaded.`, 'info');
        }

        setUploading(true);
        try {
            const formData = new FormData();
            filesToUpload.forEach(file => {
                formData.append('photos', file);
            });

            const res = await api.post('/users/upload-photos', formData, {
                headers: { 'Content-Type': 'multipart/form-data' }
            });

            if (res.data.success) {
                onUpdate(res.data.data);
                addToast('Photos uploaded successfully', 'success');
            }
        } catch (error: any) {
            addToast(error.response?.data?.message || 'Failed to upload photos', 'error');
        } finally {
            setUploading(false);
            if (fileInputRef.current) fileInputRef.current.value = '';
        }
    };

    const handleDelete = async () => {
        if (!photoToDelete) return;

        try {
            const res = await api.delete(`/users/photos/${photoToDelete}`);
            if (res.data.success) {
                onUpdate(res.data.data);
                addToast('Photo deleted', 'success');
            }
        } catch (error: any) {
            addToast('Failed to delete photo', 'error');
        } finally {
            setDeleteModalOpen(false);
            setPhotoToDelete(null);
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <h3 className="text-2xl font-bold text-gray-900 flex items-center gap-3">
                    <ImageIcon className="w-6 h-6 text-[#EF2F55]" />
                    Work Portfolio
                </h3>
                {isOwner && photos.length < maxPhotos && (
                    <button
                        onClick={() => fileInputRef.current?.click()}
                        disabled={uploading}
                        className="flex items-center gap-2 bg-[#EF2F55] hover:bg-rose-600 text-white px-4 py-2 rounded-xl text-sm font-bold transition-all disabled:opacity-50 shadow-lg shadow-rose-100"
                    >
                        {uploading ? <Loader2 className="w-4 h-4 animate-spin" /> : <Plus className="w-4 h-4" />}
                        Add Photos ({photos.length}/{maxPhotos})
                    </button>
                )}
                <input
                    type="file"
                    ref={fileInputRef}
                    onChange={handleUpload}
                    multiple
                    accept="image/*"
                    className="hidden"
                />
            </div>

            {photos.length === 0 ? (
                <div className="bg-gray-50 rounded-3xl p-12 flex flex-col items-center justify-center border-2 border-dashed border-gray-200">
                    <Camera className="w-12 h-12 text-gray-300 mb-4" />
                    <p className="text-gray-500 font-medium text-center">
                        {isOwner ? "Upload your business photos to showcase your work." : "This vendor hasn't uploaded any work photos yet."}
                    </p>
                </div>
            ) : (
                <div className="relative max-w-5xl mx-auto px-16 group">
                    <Carousel
                        plugins={[plugin.current]}
                        opts={{
                            align: "start",
                            loop: true,
                        }}
                        className="w-full"
                    >
                        <CarouselContent className="-ml-0">
                            {photos.map((photo, index) => (
                                <CarouselItem key={photo._id || index} className="pl-0 basis-full">
                                    <div className="relative aspect-video bg-gray-100 rounded-[48px] overflow-hidden group border border-gray-100 shadow-2xl shadow-rose-100/20 mx-1">
                                        <Image
                                            src={photo.url}
                                            alt={`Work sample ${index + 1}`}
                                            fill
                                            className="object-cover transition-transform duration-1000 group-hover:scale-105"
                                            unoptimized
                                        />
                                        
                                        {/* Overlay Info */}
                                        <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500">
                                            <div className="absolute bottom-10 left-10 text-white">
                                                <p className="text-xs font-black uppercase tracking-[0.2em] mb-2 text-rose-400">Portfolio Capture {index + 1}</p>
                                                <h4 className="text-2xl font-black">{photo.isProfile ? "Featured Main Showcase" : "Work Portfolio Collection"}</h4>
                                            </div>
                                        </div>

                                        {isOwner && (
                                            <button
                                                onClick={() => { setPhotoToDelete(photo._id); setDeleteModalOpen(true); }}
                                                className="absolute top-8 right-8 p-3 bg-white/95 hover:bg-red-50 text-red-500 rounded-[24px] shadow-2xl opacity-0 group-hover:opacity-100 transition-all hover:scale-110 z-10"
                                            >
                                                <Trash2 className="w-6 h-6" />
                                            </button>
                                        )}
                                        {photo.isProfile && (
                                            <div className="absolute top-8 left-8 bg-[#EF2F55] text-white text-[10px] font-black px-5 py-2.5 rounded-full shadow-2xl flex items-center gap-2 uppercase tracking-widest z-10">
                                                <Star className="w-4 h-4 fill-white" /> Gallery Featured
                                            </div>
                                        )}
                                    </div>
                                </CarouselItem>
                            ))}
                            
                            {/* Empty Slots for Owner in Carousel */}
                            {isOwner && Array.from({ length: maxPhotos - photos.length }).map((_, i) => (
                                <CarouselItem key={`empty-${i}`} className="pl-0 basis-full">
                                    <div 
                                        onClick={() => fileInputRef.current?.click()}
                                        className="aspect-video bg-rose-50/10 rounded-[48px] border-2 border-dashed border-rose-200 flex flex-col items-center justify-center cursor-pointer hover:bg-rose-50/20 transition-all group active:scale-95 mx-1"
                                    >
                                        <div className="w-16 h-16 bg-white rounded-[24px] flex items-center justify-center shadow-xl group-hover:shadow-rose-100/50 transition-all mb-4">
                                            <Plus className="w-8 h-8 text-rose-300 group-hover:text-[#EF2F55] transition-colors" />
                                        </div>
                                        <p className="text-sm font-black text-gray-400 uppercase tracking-widest group-hover:text-gray-600 transition-colors">Add Photo to Portfolio</p>
                                        <p className="text-[10px] text-gray-400/60 mt-2 font-bold uppercase tracking-tighter">Slot {photos.length + i + 1} of 5</p>
                                    </div>
                                </CarouselItem>
                            ))}
                        </CarouselContent>
                        <div className="absolute top-1/2 -left-4 -right-4 -translate-y-1/2 flex justify-between pointer-events-none px-4 opacity-0 group-hover:opacity-100 transition-opacity">
                            <CarouselPrevious className="static pointer-events-auto h-14 w-14 bg-white/90 backdrop-blur-md border-none hover:bg-[#EF2F55] hover:text-white transition-all shadow-2xl" />
                            <CarouselNext className="static pointer-events-auto h-14 w-14 bg-white/90 backdrop-blur-md border-none hover:bg-[#EF2F55] hover:text-white transition-all shadow-2xl" />
                        </div>
                    </Carousel>
                </div>
            )}

            <ConfirmationModal
                isOpen={deleteModalOpen}
                onClose={() => setDeleteModalOpen(false)}
                onConfirm={handleDelete}
                title="Delete Photo"
                message="Are you sure you want to delete this work photo? This cannot be undone."
                confirmText="Delete Photo"
                isDangerous={true}
            />
        </div>
    );
}
