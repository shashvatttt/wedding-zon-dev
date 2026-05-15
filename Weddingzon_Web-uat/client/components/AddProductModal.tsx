
'use client';

import React, { useState, useEffect } from 'react';
import { X, Upload, Loader2, Image as ImageIcon } from 'lucide-react';
import api from '@/app/services/api';
import { useToast } from '@/app/contexts/ToastContext';

interface Product {
    _id: string;
    name: string;
    description: string;
    price: number;
    category: string;
    images: string[];
    isActive?: boolean;
}

interface AddProductModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSuccess: () => void;
    productToEdit?: Product;
}

const CATEGORIES = [
    'Clothing',
    'Jewelry',
    'Venue',
    'Photography',
    'Makeup',
    'Decor',
    'Gifts',
    'Invitation',
    'Catering',
    'Transportation',
    'Music',
    'Other'
];

export default function AddProductModal({ isOpen, onClose, onSuccess, productToEdit }: AddProductModalProps) {
    const { addToast } = useToast();
    const [formData, setFormData] = useState({
        name: '',
        description: '',
        price: '',
        category: CATEGORIES[0],
        images: [] as string[]
    });
    const [loading, setLoading] = useState(false);
    const [uploading, setUploading] = useState(false);
    const [previewMap, setPreviewMap] = useState<Record<string, string>>({});

    useEffect(() => {
        if (productToEdit) {
            setFormData({
                name: productToEdit.name,
                description: productToEdit.description,
                price: productToEdit.price.toString(),
                category: productToEdit.category,
                images: productToEdit.images || []
            });
        } else {
            // Reset
            setFormData({
                name: '',
                description: '',
                price: '',
                category: CATEGORIES[0],
                images: []
            });
        }
    }, [productToEdit, isOpen]);

    if (!isOpen) return null;

    const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const files = e.target.files;
        if (!files || files.length === 0) return;

        setUploading(true);
        const data = new FormData();
        // Array.from(files).forEach((file) => {
        //     data.append('images', file); 
        // });

        try {
            const newImages = [...formData.images];

            for (let i = 0; i < files.length; i++) {
                const uploadData = new FormData();
                uploadData.append('photo', files[i]);

                const res = await api.post('/uploads', uploadData, {
                    headers: { 'Content-Type': 'multipart/form-data' }
                });

                if (res.data.success) {
                    const { url, signedUrl } = res.data;
                    newImages.push(url);
                    if (signedUrl) {
                        setPreviewMap(prev => ({ ...prev, [url]: signedUrl }));
                    }
                }
            }

            setFormData(prev => ({ ...prev, images: newImages }));

            // Note: If backend already provided signed URLs for existing images in productToEdit,
            // they will just work if we use the URL itself as a fallback in the UI.

            addToast('Images uploaded successfully', 'success');
        } catch (error) {
            console.error('Upload failed', error);
            addToast('Failed to upload images', 'error');
        } finally {
            setUploading(false);
        }
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);

        try {
            const payload = {
                ...formData,
                price: Number(formData.price)
            };

            if (productToEdit) {
                await api.patch(`/products/${productToEdit._id}`, payload);
                addToast('Product updated successfully', 'success');
            } else {
                await api.post('/products', payload);
                addToast('Product created successfully', 'success');
            }

            onSuccess();
        } catch (error) {
            console.error('Failed to save product', error);
            addToast('Failed to save product', 'error');
        } finally {
            setLoading(false);
        }
    };

    const removeImage = (index: number) => {
        setFormData(prev => ({
            ...prev,
            images: prev.images.filter((_, i) => i !== index)
        }));
    };

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
            <div className="bg-white rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto shadow-2xl">
                <div className="p-6 border-b border-gray-100 flex items-center justify-between sticky top-0 bg-white z-10">
                    <h2 className="text-xl font-bold text-gray-900">
                        {productToEdit ? 'Edit Product' : 'Add New Product'}
                    </h2>
                    <button
                        onClick={onClose}
                        className="p-2 hover:bg-gray-100 rounded-full transition-colors text-gray-500"
                    >
                        <X className="w-5 h-5" />
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="p-6 space-y-6">
                    {/* Basic Info */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div className="space-y-2">
                            <label className="text-sm font-medium text-gray-700">Product Name</label>
                            <input
                                type="text"
                                required
                                value={formData.name}
                                onChange={e => setFormData({ ...formData, name: e.target.value })}
                                className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-pink-500/20 focus:border-pink-500 outline-none transition-all"
                                placeholder="e.g., Silk Saree"
                            />
                        </div>

                        <div className="space-y-2">
                            <label className="text-sm font-medium text-gray-700">Category</label>
                            <select
                                value={formData.category}
                                onChange={e => setFormData({ ...formData, category: e.target.value })}
                                className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-pink-500/20 focus:border-pink-500 outline-none transition-all bg-white"
                            >
                                {CATEGORIES.map(cat => (
                                    <option key={cat} value={cat}>{cat}</option>
                                ))}
                            </select>
                        </div>
                    </div>

                    <div className="space-y-2">
                        <label className="text-sm font-medium text-gray-700">Price (₹)</label>
                        <input
                            type="number"
                            required
                            min="0"
                            value={formData.price}
                            onChange={e => setFormData({ ...formData, price: e.target.value })}
                            className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-pink-500/20 focus:border-pink-500 outline-none transition-all"
                            placeholder="0.00"
                        />
                    </div>

                    <div className="space-y-2">
                        <label className="text-sm font-medium text-gray-700">Description</label>
                        <textarea
                            required
                            rows={4}
                            value={formData.description}
                            onChange={e => setFormData({ ...formData, description: e.target.value })}
                            className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-pink-500/20 focus:border-pink-500 outline-none transition-all resize-none"
                            placeholder="Describe your product..."
                        />
                    </div>

                    {/* Images */}
                    <div className="space-y-4">
                        <label className="text-sm font-medium text-gray-700">Product Images</label>

                        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
                            {formData.images.map((img, idx) => (
                                <div key={idx} className="relative aspect-square rounded-lg overflow-hidden border border-gray-200 group">
                                    <img
                                        src={previewMap[img] || img}
                                        alt=""
                                        className="w-full h-full object-cover"
                                    />
                                    <button
                                        type="button"
                                        onClick={() => removeImage(idx)}
                                        className="absolute top-1 right-1 p-1 bg-red-500 text-white rounded-full opacity-0 group-hover:opacity-100 transition-opacity"
                                    >
                                        <X className="w-3 h-3" />
                                    </button>
                                </div>
                            ))}

                            <label className="aspect-square rounded-lg border-2 border-dashed border-gray-300 hover:border-pink-500 hover:bg-pink-50/50 transition-all flex flex-col items-center justify-center cursor-pointer text-gray-400 hover:text-pink-500">
                                {uploading ? (
                                    <Loader2 className="w-6 h-6 animate-spin" />
                                ) : (
                                    <>
                                        <Upload className="w-6 h-6 mb-2" />
                                        <span className="text-xs font-medium">Upload</span>
                                    </>
                                )}
                                <input
                                    type="file"
                                    multiple
                                    accept="image/*"
                                    className="hidden"
                                    onChange={handleFileUpload}
                                    disabled={uploading}
                                />
                            </label>
                        </div>
                    </div>

                    {/* Actions */}
                    <div className="flex justify-end gap-3 pt-4 border-t border-gray-100">
                        <button
                            type="button"
                            onClick={onClose}
                            className="px-6 py-2.5 rounded-lg text-gray-600 hover:bg-gray-100 font-medium transition-colors"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            disabled={loading || uploading}
                            className="px-6 py-2.5 rounded-lg bg-pink-600 hover:bg-pink-700 text-white font-medium transition-colors shadow-lg shadow-pink-600/20 disabled:opacity-70 flex items-center gap-2"
                        >
                            {loading ? <Loader2 className="w-4 h-4 animate-spin" /> : (productToEdit ? 'Save Changes' : 'Create Product')}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}
