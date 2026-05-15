
'use client';

import React, { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import api from '@/app/services/api';
import { Loader2, ArrowLeft, Heart, Share2, MessageCircle, MapPin, Star, User, ShoppingCart, Truck, ShieldCheck, RefreshCw } from 'lucide-react';
import { useCart } from '@/app/context/CartContext';

interface Product {
    _id: string;
    name: string;
    description: string;
    price: number;
    category: string;
    images: string[];
    vendor: {
        _id: string;
        first_name: string;
        last_name: string;
        email: string;
        phone: string;
        profilePhoto?: string;
        vendor_details?: {
            business_name: string;
            business_address: string;
            city: string;
            state: string;
        };
    };
    averageRating?: number;
    numReviews?: number;
}

export default function ProductDetailsPage() {
    const params = useParams();
    const router = useRouter();
    const { addToCart } = useCart();
    const [product, setProduct] = useState<Product | null>(null);
    const [loading, setLoading] = useState(true);
    const [activeImage, setActiveImage] = useState(0);

    useEffect(() => {
        if (params.id) {
            fetchProduct(params.id as string);
        }
    }, [params.id]);

    const fetchProduct = async (id: string) => {
        try {
            const { data } = await api.get(`/products/${id}`);
            if (data.success) {
                setProduct(data.data);
            }
        } catch (error) {
            console.error('Failed to fetch product', error);
        } finally {
            setLoading(false);
        }
    };

    const handleAddToCart = () => {
        if (!product) return;
        addToCart({
            _id: product._id,
            name: product.name,
            price: product.price,
            image: product.images[0] || '',
            vendorName: product.vendor?.vendor_details?.business_name || product.vendor?.first_name || 'Vendor'
        });
    };

    if (loading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gray-50">
                <Loader2 className="animate-spin w-8 h-8 text-pink-600" />
            </div>
        );
    }

    if (!product) {
        return (
            <div className="min-h-screen pt-24 text-center">
                <h1 className="text-2xl font-bold text-gray-900">Product Not Found</h1>
                <button
                    onClick={() => router.back()}
                    className="mt-4 text-pink-600 hover:underline"
                >
                    Go Back
                </button>
            </div>
        );
    }

    const { vendor } = product;
    const businessName = vendor?.vendor_details?.business_name || `${vendor?.first_name} ${vendor?.last_name}`;
    const location = vendor?.vendor_details?.city && vendor?.vendor_details?.state
        ? `${vendor.vendor_details.city}, ${vendor.vendor_details.state}`
        : 'Location unavailable';

    return (
        <div className="min-h-screen bg-gray-50 pt-24 pb-12 px-4 sm:px-6 lg:px-8">
            <div className="max-w-7xl mx-auto">
                <button
                    onClick={() => router.back()}
                    className="flex items-center text-gray-500 hover:text-pink-600 mb-6 transition-colors group text-sm font-medium"
                >
                    <ArrowLeft className="w-4 h-4 mr-2 group-hover:-translate-x-1 transition-transform" />
                    Back to Results
                </button>

                <div className="bg-white rounded-3xl shadow-sm border border-gray-100 overflow-hidden">
                    <div className="grid grid-cols-1 lg:grid-cols-2">
                        {/* Left: Image Gallery */}
                        <div className="p-6 lg:p-8 bg-gray-50/50">
                            <div className="aspect-square bg-white rounded-2xl overflow-hidden shadow-sm border border-gray-100 relative mb-4">
                                {product.images?.[activeImage] ? (
                                    <img
                                        src={product.images[activeImage]}
                                        alt={product.name}
                                        className="w-full h-full object-contain mix-blend-multiply hover:scale-110 transition-transform duration-500 cursor-zoom-in"
                                    />
                                ) : (
                                    <div className="w-full h-full flex items-center justify-center bg-gray-50 text-gray-400">
                                        No Image
                                    </div>
                                )}
                            </div>
                            {product.images && product.images.length > 1 && (
                                <div className="flex gap-4 overflow-x-auto pb-2 scrollbar-hide justify-center">
                                    {product.images.map((img, idx) => (
                                        <button
                                            key={idx}
                                            onMouseEnter={() => setActiveImage(idx)}
                                            onClick={() => setActiveImage(idx)}
                                            className={`w-20 h-20 rounded-lg overflow-hidden border-2 flex-shrink-0 transition-all ${activeImage === idx ? 'border-pink-600 shadow-md ring-2 ring-pink-100' : 'border-transparent opacity-70 hover:opacity-100 bg-white'
                                                }`}
                                        >
                                            <img src={img} alt="" className="w-full h-full object-contain p-1" />
                                        </button>
                                    ))}
                                </div>
                            )}
                        </div>

                        {/* Right: Product Details */}
                        <div className="p-6 lg:p-10 flex flex-col h-full bg-white">
                            <div className="mb-auto">
                                <div className="flex items-start justify-between">
                                    <h1 className="text-3xl font-bold text-gray-900 leading-tight mb-2">{product.name}</h1>
                                    <button className="text-gray-400 hover:text-pink-600 transition-colors p-2 rounded-full hover:bg-pink-50 self-start">
                                        <Heart className="w-6 h-6" />
                                    </button>
                                </div>

                                <div className="flex items-center gap-4 mb-6">
                                    <div className="flex items-center text-yellow-500">
                                        {[...Array(5)].map((_, i) => (
                                            <Star key={i} className="w-4 h-4 fill-current" />
                                        ))}
                                    </div>
                                    <span className="text-blue-600 hover:underline cursor-pointer text-sm font-medium">128 ratings</span>
                                    <div className="w-px h-4 bg-gray-300"></div>
                                    <span className="text-gray-500 text-sm">{product.category}</span>
                                </div>

                                <div className="border-t border-b border-gray-100 py-6 mb-6">
                                    <div className="flex items-baseline gap-2 mb-4">
                                        <span className="text-lg text-gray-500 line-through">₹{(product.price * 1.2).toLocaleString()}</span>
                                        <span className="text-4xl font-bold text-gray-900">₹{product.price.toLocaleString()}</span>
                                        <span className="text-green-600 font-bold text-sm bg-green-50 px-2 py-1 rounded">-20%</span>
                                    </div>
                                    <p className="text-gray-600 text-sm leading-relaxed mb-6">
                                        {product.description}
                                    </p>

                                    {/* Features / Benefits */}
                                    <div className="grid grid-cols-2 gap-4">
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-xl">
                                            <Truck className="w-5 h-5 text-gray-600" />
                                            <span className="text-sm font-medium text-gray-700">Free Delivery</span>
                                        </div>
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-xl">
                                            <ShieldCheck className="w-5 h-5 text-gray-600" />
                                            <span className="text-sm font-medium text-gray-700">Verified Vendor</span>
                                        </div>
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-xl">
                                            <RefreshCw className="w-5 h-5 text-gray-600" />
                                            <span className="text-sm font-medium text-gray-700">7 Day Returns</span>
                                        </div>
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-xl">
                                            <MessageCircle className="w-5 h-5 text-gray-600" />
                                            <span className="text-sm font-medium text-gray-700">Vendor Chat</span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            {/* Action Buttons */}
                            <div className="space-y-4">
                                <div className="flex flex-col sm:flex-row gap-4">
                                    <button
                                        onClick={handleAddToCart}
                                        className="flex-1 bg-yellow-400 hover:bg-yellow-500 text-black py-4 rounded-xl font-bold text-lg shadow-lg shadow-yellow-400/20 transition-all active:scale-[0.98] flex items-center justify-center gap-2"
                                    >
                                        <ShoppingCart className="w-5 h-5" />
                                        Add to Cart
                                    </button>
                                    <button className="flex-1 bg-orange-600 hover:bg-orange-700 text-white py-4 rounded-xl font-bold text-lg shadow-lg shadow-orange-600/20 transition-all active:scale-[0.98]">
                                        Buy Now
                                    </button>
                                </div>
                                <div className="text-xs text-gray-500 text-center">
                                    Sold by <span className="text-blue-600 font-medium">{businessName}</span> and fulfilled by WeddingZon.
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Vendor & Reviews Section */}
                    <div className="border-t border-gray-100 bg-gray-50/50 p-8 lg:p-12">
                        <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
                            {/* Vendor Profile */}
                            <div className="lg:col-span-1">
                                <h3 className="font-bold text-xl text-gray-900 mb-6">About the Vendor</h3>
                                <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 text-center">
                                    <div className="w-24 h-24 rounded-full bg-gray-100 flex items-center justify-center overflow-hidden border border-gray-200 mx-auto mb-4">
                                        {vendor?.profilePhoto ? (
                                            <img src={vendor.profilePhoto} alt="" className="w-full h-full object-cover" />
                                        ) : (
                                            <User className="w-10 h-10 text-gray-400" />
                                        )}
                                    </div>
                                    <h4 className="font-bold text-lg text-gray-900">{businessName}</h4>
                                    <div className="flex items-center justify-center text-gray-500 text-sm mt-1 mb-4">
                                        <MapPin className="w-4 h-4 mr-1" />
                                        {location}
                                    </div>
                                    <button className="w-full bg-white border border-gray-300 hover:bg-gray-50 text-gray-700 font-medium py-2 rounded-lg transition-colors">
                                        Visit Storefront
                                    </button>
                                </div>
                            </div>

                            {/* Reviews (Mock) */}
                            <div className="lg:col-span-2">
                                <h3 className="font-bold text-xl text-gray-900 mb-6">Customer Reviews</h3>
                                <div className="space-y-6">
                                    {[1, 2, 3].map((r) => (
                                        <div key={r} className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                                            <div className="flex items-center gap-3 mb-2">
                                                <div className="w-10 h-10 rounded-full bg-pink-100 flex items-center justify-center text-pink-700 font-bold text-sm">
                                                    JD
                                                </div>
                                                <div>
                                                    <div className="font-medium text-gray-900">Jane Doe</div>
                                                    <div className="flex text-yellow-400 text-xs">
                                                        {[...Array(5)].map((_, i) => (
                                                            <Star key={i} className="w-3 h-3 fill-current" />
                                                        ))}
                                                    </div>
                                                </div>
                                                <span className="ml-auto text-xs text-gray-400">2 days ago</span>
                                            </div>
                                            <p className="text-gray-600 text-sm">
                                                Absolutely loved the quality of this product! The vendor was very responsive and the delivery was on time. Highly recommended for any wedding planning.
                                            </p>
                                        </div>
                                    ))}
                                    <button className="text-pink-600 font-medium hover:underline text-sm">
                                        View all 128 reviews
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

