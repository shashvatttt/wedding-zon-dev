'use client';

import { useState, useRef, useCallback, useEffect } from 'react';
import { Loader2, Plus, Upload, X, Star, Trash2, Image as ImageIcon, AlertCircle, RefreshCw } from 'lucide-react';
import Image from 'next/image';
import api from '../services/api';
import { useToast } from '../contexts/ToastContext';
import ConfirmationModal from '../../components/ConfirmationModal';
import ImageCropModal from './ImageCropModal';

interface Photo {
    _id: string; // real ID or temp ID
    url: string; // real URL or blob URL
    publicId?: string;
    isProfile: boolean;
    order?: number;
    // Client-side queue state
    isTemp?: boolean;
    status?: 'pending' | 'uploading' | 'success' | 'error';
    error?: string;
    file?: File;
}

interface PhotoUploadGridProps {
    photos: Photo[];
    setPhotos: React.Dispatch<React.SetStateAction<Photo[]>>;
    updateProfilePhotoLocal: (url: string) => void;
    // Optional custom endpoints for Franchise/Admin usage
    uploadEndpoint?: string;
    deleteEndpoint?: string;
    setProfileEndpoint?: string;
    setCoverEndpoint?: string;
    maxPhotos?: number;
    autoCropFirst?: boolean;
}

export default function PhotoUploadGrid({
    photos,
    setPhotos,
    updateProfilePhotoLocal,
    uploadEndpoint,
    deleteEndpoint,
    setProfileEndpoint,
    setCoverEndpoint,
    maxPhotos = 10,
    autoCropFirst = false
}: PhotoUploadGridProps) {
    const [dragActive, setDragActive] = useState(false);
    const [isGlobalUploading, setIsGlobalUploading] = useState(false);
    const fileInputRef = useRef<HTMLInputElement>(null);
    const { addToast } = useToast();

    // Modal State
    const [deleteModalOpen, setDeleteModalOpen] = useState(false);
    const [photoToDelete, setPhotoToDelete] = useState<string | null>(null);

    const [cropModalOpen, setCropModalOpen] = useState(false);
    const [photoToCrop, setPhotoToCrop] = useState<string | null>(null);
    const [isCropUploading, setIsCropUploading] = useState(false);

    // -- Helper to construct absolute upload URL bypassing Next.js proxy --
    const getFullUploadUrl = (endpoint: string) => {
        const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api';
        const cleanApiUrl = apiUrl.endsWith('/') ? apiUrl.slice(0, -1) : apiUrl;

        let target = endpoint;
        // Ensure endpoint starts with /
        if (!target.startsWith('/')) target = '/' + target;

        // If target already contains /api, remove it as it's usually already in cleanApiUrl
        if (target.startsWith('/api/') && cleanApiUrl.endsWith('/api')) {
            target = target.replace('/api', '');
        } else if (!target.startsWith('/api/') && !cleanApiUrl.endsWith('/api')) {
            // If neither has /api, add it if that's the convention, but here we trust apiUrl
        }

        return `${cleanApiUrl}${target}`;
    };

    // -- Queue Processing Effect --
    useEffect(() => {
        const processQueue = async () => {
            // Prevent multiple simultaneous uploads
            if (isGlobalUploading) return;

            // Find the next pending item
            const nextUpload = photos.find(p => p.isTemp && p.status === 'pending');
            if (!nextUpload) {
                return;
            }

            setIsGlobalUploading(true);

            // Set status to uploading
            setPhotos(prev => prev.map(p =>
                p._id === nextUpload._id ? { ...p, status: 'uploading' } : p
            ));

            try {
                if (!nextUpload.file) throw new Error("File missing");

                const formData = new FormData();
                formData.append('photos', nextUpload.file);

                // Upload Single File (Use custom endpoint if provided)
                const targetEndpoint = uploadEndpoint || '/users/upload-photos';
                const fullUrl = getFullUploadUrl(targetEndpoint);

                const res = await api.post(fullUrl, formData, {
                    headers: { 'Content-Type': 'multipart/form-data' },
                    baseURL: '' // Override baseURL to empty to use absolute URL
                });

                if (res.data.success && res.data.data) {
                    const allServerPhotos = res.data.data;

                    // Update state: Server Photos + Remaining Temps
                    setPhotos(prev => {
                        const remainingTemps = prev.filter(p => p.isTemp && p._id !== nextUpload._id);

                        // Find the new profile photo to update parent
                        const profilePhoto = allServerPhotos.find((p: any) => p.isProfile);
                        if (profilePhoto) {
                            updateProfilePhotoLocal(profilePhoto.url);

                            // Auto-crop if requested and this is the first profile photo
                            if (autoCropFirst && profilePhoto) {
                                setPhotoToCrop(profilePhoto.url);
                                setCropModalOpen(true);
                            }
                        }

                        return [...allServerPhotos, ...remainingTemps];
                    });
                } else {
                    // Handle failure from backend (e.g. limit reached, or specific error)
                    const errorMsg = res.data.errors?.[0]?.error || res.data.message || "Upload failed";
                    throw new Error(errorMsg);
                }

            } catch (error: any) {
                console.error("Upload failed for item:", nextUpload._id, error);
                const msg = error.response?.data?.message || error.message || "Network Error";

                // Mark as error
                setPhotos(prev => prev.map(p =>
                    p._id === nextUpload._id ? { ...p, status: 'error', error: msg } : p
                ));
            } finally {
                setIsGlobalUploading(false);
            }
        };

        processQueue();
    }, [photos, isGlobalUploading]); // Add isGlobalUploading directly to dependency to retry if needed? 
    // Actually, when 'photos' updates (status changes), it triggers. 
    // If isGlobalUploading becomes false (in finally), we need to trigger again to pick up next.
    // So 'isGlobalUploading' MUST be in dependency.


    // Handle File Selection
    const handleFiles = (files: File[]) => {
        if (!files.length) return;

        const validFiles: File[] = [];
        const MAX_SIZE_MB = 50; // Server limit is 50MB
        const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/webp'];

        files.forEach(file => {
            if (ALLOWED_TYPES.includes(file.type) && file.size <= MAX_SIZE_MB * 1024 * 1024) {
                validFiles.push(file);
            } else {
                if (!ALLOWED_TYPES.includes(file.type)) {
                    addToast(`Skipped ${file.name}: Invalid type. Only JPG, PNG, WEBP allowed.`, 'error');
                } else if (file.size > MAX_SIZE_MB * 1024 * 1024) {
                    addToast(`Skipped ${file.name}: File too large (Max ${MAX_SIZE_MB}MB).`, 'error');
                }
            }
        });

        if (validFiles.length === 0) return;

        // Create Temp Photos
        const newPhotos: Photo[] = validFiles.map(file => ({
            _id: `temp_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
            url: URL.createObjectURL(file), // Optimistic Preview
            isProfile: false,
            isTemp: true,
            status: 'pending',
            file: file
        }));

        setPhotos(prev => {
            const spacesAvailable = maxPhotos - prev.length;
            if (newPhotos.length > spacesAvailable) {
                addToast(`Only added first ${spacesAvailable} photos due to limit.`, 'info');
                return [...prev, ...newPhotos.slice(0, spacesAvailable)];
            }
            return [...prev, ...newPhotos];
        });

        // Reset input
        if (fileInputRef.current) fileInputRef.current.value = '';
    };

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.files) handleFiles(Array.from(e.target.files));
    };

    const handleRetry = (photoId: string) => {
        setPhotos(prev => prev.map(p =>
            p._id === photoId ? { ...p, status: 'pending', error: undefined } : p
        ));
    };

    const handleRemove = async (photoId: string) => {
        // Is it a temp/failed photo? Just remove from state
        const photo = photos.find(p => p._id === photoId);
        if (!photo) return;

        if (photo.isTemp) {
            setPhotos(prev => prev.filter(p => p._id !== photoId));
            return;
        }

        // Open Modal for Real Photos
        setPhotoToDelete(photoId);
        setDeleteModalOpen(true);
    };

    const confirmDelete = async () => {
        if (!photoToDelete) return;
        const photoId = photoToDelete;

        try {
            // Use custom delete path if provided
            let url = `/users/photos/${photoId}`;
            if (deleteEndpoint) {
                url = `${deleteEndpoint}/${photoId}`;
            }

            const res = await api.delete(url);
            if (res.data.success) {
                setPhotos(res.data.data);
                const profile = res.data.data.find((p: any) => p.isProfile);
                updateProfilePhotoLocal(profile?.url || '');
                addToast('Photo deleted', 'success');
            }
        } catch (error) {
            addToast('Failed to delete photo', 'error');
        }
    };

    const handleSetProfile = async (photoId: string) => {
        const photo = photos.find(p => p._id === photoId);
        if (!photo) return;
        setPhotoToCrop(photo.url);
        setCropModalOpen(true);
    };

    const handleCropComplete = async (croppedBlob: Blob) => {
        setIsCropUploading(true);
        try {
            const formData = new FormData();
            formData.append('photos', croppedBlob, 'profile_cropped.jpg');
            formData.append('set_as_profile', 'true');

            // Construct full URL (reusing logic from processQueue)
            const targetEndpoint = uploadEndpoint || '/users/upload-photos';
            const fullUrl = getFullUploadUrl(targetEndpoint);

            const res = await api.post(fullUrl, formData, {
                headers: { 'Content-Type': 'multipart/form-data' },
                baseURL: ''
            });

            if (res.data.success) {
                setPhotos(res.data.data);
                const profile = res.data.data.find((p: any) => p.isProfile);
                if (profile) updateProfilePhotoLocal(profile.url);
                addToast('Profile picture updated!', 'success');
            } else {
                throw new Error(res.data.message || 'Upload failed');
            }
        } catch (error: any) {
            console.error('Failed to upload cropped photo:', error);
            addToast('Failed to update profile photo', 'error');
        } finally {
            setIsCropUploading(false);
            setCropModalOpen(false);
        }
    };

    const handleSetCover = async (photoId: string) => {
        try {
            let url = `/users/photos/${photoId}/set-cover`;
            if (setCoverEndpoint) {
                url = `${setCoverEndpoint}/${photoId}/set-cover`;
            }

            const res = await api.patch(url);
            if (res.data.success) {
                setPhotos(res.data.data);
                addToast('Cover photo updated!', 'success');
            }
        } catch (error: any) {
            addToast('Failed to update cover photo', 'error');
        }
    };

    // Drag and Drop
    const handleDrag = useCallback((e: React.DragEvent) => {
        e.preventDefault(); e.stopPropagation();
        if (e.type === 'dragenter' || e.type === 'dragover') setDragActive(true);
        else if (e.type === 'dragleave') setDragActive(false);
    }, []);

    const handleDrop = useCallback((e: React.DragEvent) => {
        e.preventDefault(); e.stopPropagation();
        setDragActive(false);
        if (e.dataTransfer.files?.length) handleFiles(Array.from(e.dataTransfer.files));
    }, [photos]); // eslint-disable-line

    return (
        <div className="w-full space-y-4">
            {/* Upload Area */}
            {photos.length < maxPhotos && (
                <div
                    className={`relative group cursor-pointer border-2 border-dashed rounded-2xl p-8 transition-all duration-300 ease-in-out ${dragActive
                        ? 'border-[#EF2F55] bg-pink-50 scale-[1.01]'
                        : 'border-gray-300 bg-gray-50 hover:bg-gray-100 hover:border-[#FBC3CF]'
                        }`}
                    onDragEnter={handleDrag} onDragLeave={handleDrag} onDragOver={handleDrag} onDrop={handleDrop}
                    onClick={() => fileInputRef.current?.click()}
                >
                    <input ref={fileInputRef} type="file" multiple accept="image/*" onChange={handleChange} className="hidden" />
                    <div className="flex flex-col items-center justify-center text-center space-y-3">
                        <div className={`p-4 rounded-full bg-white shadow-sm ring-1 ring-gray-900/5 group-hover:scale-110 transition-transform duration-300`}>
                            <Upload className="w-6 h-6 text-[#EF2F55]" />
                        </div>
                        <div>
                            <p className="text-sm font-semibold text-gray-900">
                                Click to upload <span className="text-gray-500 font-normal">or drag and drop</span>
                            </p>
                            <p className="text-xs text-gray-500 mt-1">JPG, PNG, WEBP (Max 50MB)</p>
                        </div>
                    </div>
                </div>
            )}

            {/* Photo Grid */}
            {photos.length > 0 && (
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
                    {photos.map((photo) => (
                        <div key={photo._id} className="group relative aspect-[3/4] rounded-xl overflow-hidden bg-gray-100 shadow-md border border-gray-200">

                            {/* Image */}
                            <Image src={photo.url} alt="User photo" fill className={`object-cover transition-transform duration-500 group-hover:scale-105 ${photo.isTemp ? 'opacity-80' : ''}`} unoptimized />

                            {/* Overlay Gradient (Only for real photos or failed ones you want actions on) */}
                            <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />

                            {/* Status Overlays */}
                            {photo.status === 'uploading' && (
                                <div className="absolute inset-0 flex items-center justify-center bg-black/40 backdrop-blur-[1px]">
                                    <Loader2 className="w-8 h-8 text-white animate-spin" />
                                </div>
                            )}

                            {photo.status === 'error' && (
                                <div className="absolute inset-0 flex flex-col items-center justify-center bg-red-500/20 backdrop-blur-[1px] p-2 text-center">
                                    <AlertCircle className="w-8 h-8 text-red-600 mb-2" />
                                    <span className="text-xs text-red-700 bg-white/90 px-2 py-1 rounded font-medium shadow-sm mb-2">{photo.error || 'Failed'}</span>
                                    <button onClick={(e) => { e.stopPropagation(); handleRetry(photo._id); }} className="p-2 bg-white rounded-full shadow hover:bg-gray-50 transition-colors">
                                        <RefreshCw className="w-4 h-4 text-[#EF2F55]" />
                                    </button>
                                </div>
                            )}

                            {/* Badges */}
                            {photo.isProfile && !photo.isTemp && (
                                <div className="absolute top-2 left-2 bg-[#EF2F55]/90 backdrop-blur-sm text-white text-[10px] font-bold px-2 py-1 rounded-full shadow-lg flex items-center gap-1">
                                    <Star className="w-3 h-3 fill-white" /> Profile Pic
                                </div>
                            )}

                            {/* Delete Action */}
                            <button
                                onClick={(e) => { e.stopPropagation(); handleRemove(photo._id); }}
                                className="absolute top-3 right-3 p-2 bg-white/90 hover:bg-red-50 text-red-500 rounded-full shadow-lg transition-all hover:scale-110 z-10"
                                title="Delete/Remove Photo"
                            >
                                <Trash2 className="w-5 h-5" />
                            </button>

                            {/* Actions (Only for real photos) */}
                            {!photo.isTemp && (
                                <div className="absolute bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-black/80 to-transparent flex flex-col gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                    {!photo.isProfile && (
                                        <button
                                            onClick={(e) => { e.stopPropagation(); handleSetProfile(photo._id); }}
                                            className="w-full flex items-center justify-center gap-2 bg-white/20 hover:bg-white/30 backdrop-blur-md text-white text-xs font-semibold py-2 rounded-lg transition-all border border-white/30 shadow-sm"
                                        >
                                            <Star className="w-3 h-3 fill-white/20" /> Set as Profile
                                        </button>
                                    )}
                                </div>
                            )}
                        </div>
                    ))}
                </div>
            )
            }

            <ConfirmationModal
                isOpen={deleteModalOpen}
                onClose={() => setDeleteModalOpen(false)}
                onConfirm={confirmDelete}
                title="Delete Photo"
                message="Are you sure you want to delete this photo?"
                confirmText="Delete"
                isDangerous={true}
            />

            {photoToCrop && (
                <ImageCropModal
                    isOpen={cropModalOpen}
                    imageSrc={photoToCrop}
                    onClose={() => setCropModalOpen(false)}
                    onCropComplete={handleCropComplete}
                />
            )}

            {isCropUploading && (
                <div className="fixed inset-0 z-[100] flex items-center justify-center bg-black/50 backdrop-blur-sm">
                    <div className="bg-white p-6 rounded-2xl shadow-xl flex flex-col items-center gap-4">
                        <Loader2 className="w-10 h-10 text-[#EF2F55] animate-spin" />
                        <p className="font-semibold text-gray-900">Uploading cropped photo...</p>
                    </div>
                </div>
            )}
        </div >
    );
}
