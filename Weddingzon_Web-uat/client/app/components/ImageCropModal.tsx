'use client';

import React, { useState, useCallback } from 'react';
import Cropper from 'react-easy-crop';
import { X, Loader2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Slider } from '@/components/ui/slider';
import { useToast } from '../contexts/ToastContext';
import getCroppedImg from '../utils/cropImage';

interface ImageCropModalProps {
    isOpen: boolean;
    imageSrc: string;
    onClose: () => void;
    onCropComplete: (croppedImage: Blob) => void;
}

const ImageCropModal = ({ isOpen, imageSrc, onClose, onCropComplete }: ImageCropModalProps) => {
    const [crop, setCrop] = useState({ x: 0, y: 0 });
    const [zoom, setZoom] = useState(1);
    const [croppedAreaPixels, setCroppedAreaPixels] = useState<any>(null);
    const [processing, setProcessing] = useState(false);
    const { addToast } = useToast();

    const proxiedImageSrc = `/api/users/render-image?url=${encodeURIComponent(imageSrc)}`;

    const onCropChange = (crop: { x: number; y: number }) => {
        setCrop(crop);
    };

    const onZoomChange = (zoom: number) => {
        setZoom(zoom);
    };

    const onCropAreaComplete = useCallback((_croppedArea: any, croppedAreaPixels: any) => {
        setCroppedAreaPixels(croppedAreaPixels);
    }, []);

    const handleSave = async () => {
        if (!croppedAreaPixels) {
            addToast('Please wait for the image to load completely.', 'info');
            return;
        }
        setProcessing(true);
        console.log('Starting crop process for:', imageSrc);
        console.log('Crop Pixels:', croppedAreaPixels);

        try {
            const croppedImage = await getCroppedImg(proxiedImageSrc, croppedAreaPixels);
            if (croppedImage) {
                console.log('Crop successful, blob size:', croppedImage.size);
                onCropComplete(croppedImage);
            } else {
                addToast('Failed to create cropped image (empty blob).', 'error');
            }
        } catch (e: any) {
            console.error('Full cropping error object:', e);
            const errorMsg = e?.message || e?.name || (typeof e === 'string' ? e : 'Check console for details');
            addToast(`Error: ${errorMsg}`, 'error');
        } finally {
            setProcessing(false);
        }
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-in fade-in duration-200">
            <div className="bg-white rounded-3xl w-full max-w-[600px] shadow-2xl overflow-hidden flex flex-col max-h-[90vh]">
                {/* Header */}
                <div className="p-6 border-b border-gray-100 flex items-center justify-between">
                    <div>
                        <h2 className="text-xl font-bold text-gray-900">Crop Profile Picture</h2>
                        <p className="text-sm text-gray-500 mt-0.5">Adjust the circular area you want to show</p>
                    </div>
                    <button
                        onClick={onClose}
                        className="p-2 hover:bg-gray-100 rounded-full transition-colors text-gray-400 hover:text-gray-600"
                    >
                        <X className="w-5 h-5" />
                    </button>
                </div>

                {/* Cropper Container */}
                <div className="relative flex-1 min-h-[400px] bg-gray-50">
                    <Cropper
                        image={proxiedImageSrc}
                        crop={crop}
                        zoom={zoom}
                        aspect={1 / 1}
                        cropShape="round"
                        showGrid={false}
                        onCropChange={onCropChange}
                        onCropComplete={onCropAreaComplete}
                        onZoomChange={onZoomChange}
                    />
                </div>

                {/* Controls */}
                <div className="p-6 space-y-6 bg-white">
                    <div className="flex items-center gap-4 px-2">
                        <span className="text-sm font-semibold text-gray-700 min-w-[50px]">Zoom</span>
                        <Slider
                            value={[zoom]}
                            min={1}
                            max={3}
                            step={0.1}
                            onValueChange={(vals) => setZoom(vals[0])}
                            className="flex-1"
                        />
                    </div>

                    <div className="flex justify-end gap-3 pt-2">
                        <Button
                            variant="outline"
                            onClick={onClose}
                            className="rounded-xl px-6 h-11 font-semibold border-gray-200 hover:bg-gray-50 text-gray-700"
                        >
                            Cancel
                        </Button>
                        <Button
                            onClick={handleSave}
                            disabled={processing}
                            className="bg-[#EF2F55] hover:bg-[#D42A4C] text-white rounded-xl px-8 h-11 font-semibold shadow-lg shadow-pink-500/20 transition-all active:scale-95 disabled:opacity-70 flex items-center gap-2"
                        >
                            {processing ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Apply Crop'}
                        </Button>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default ImageCropModal;
