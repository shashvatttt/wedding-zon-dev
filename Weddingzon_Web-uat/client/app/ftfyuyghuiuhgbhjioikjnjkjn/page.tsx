'use client';

import React, { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import api from '@/app/services/api';
import { Loader2, ShoppingBag, Star, ShoppingCart } from 'lucide-react';
import useEmblaCarousel from 'embla-carousel-react';
import { useCart } from '@/app/context/CartContext';
import { useAuth } from '@/app/context/AuthContext';
import ShopHeader from '@/components/ShopHeader';

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
        vendor_details?: {
            business_name: string;
        };
    };
    averageRating?: number;
    numReviews?: number;
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

const BANNERS = [
    {
        id: 1,
        image: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&q=80&w=2000',
        title: 'Premium Wedding Venues',
        subtitle: 'Book your dream location today'
    },
    {
        id: 2,
        image: 'https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8?auto=format&fit=crop&q=80&w=2000',
        title: 'Exclusive Bridal Jewelry',
        subtitle: 'Shine on your special day'
    },
    {
        id: 3,
        image: 'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?auto=format&fit=crop&q=80&w=2000',
        title: 'Professional Photography',
        subtitle: 'Capture every moment forever'
    }
];

export default function ShopPage() {
    const router = useRouter();
    const { user } = useAuth();
    const { addToCart } = useCart();
    const [products, setProducts] = useState<Product[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [selectedCategories, setSelectedCategories] = useState<string[]>([]);
    const [minPrice, setMinPrice] = useState('');
    const [maxPrice, setMaxPrice] = useState('');
    const [page, setPage] = useState(1);
    const [totalPages, setTotalPages] = useState(1);

    const [emblaRef] = useEmblaCarousel({ loop: true });

    useEffect(() => {
        const timer = setTimeout(() => {
            fetchProducts(1);
        }, 500);
        return () => clearTimeout(timer);
    }, [searchQuery, selectedCategories, minPrice, maxPrice]);

    const fetchProducts = async (pageNum: number = page) => {
        try {
            setLoading(true);
            const queryParams = new URLSearchParams({
                page: pageNum.toString(),
                limit: '12',
                search: searchQuery,
            });

            if (selectedCategories.length > 0) {
                queryParams.append('category', selectedCategories[0]);
            }

            if (minPrice) queryParams.append('minPrice', minPrice);
            if (maxPrice) queryParams.append('maxPrice', maxPrice);

            const { data } = await api.get(`/products?${queryParams.toString()}`);
            if (data.success) {
                setProducts(data.data);
                setTotalPages(data.pagination.pages);
                setPage(pageNum);
            }
        } catch (error) {
            console.error('Failed to fetch products', error);
        } finally {
            setLoading(false);
        }
    };

    const toggleCategory = (cat: string) => {
        setSelectedCategories(prev =>
            prev.includes(cat) ? prev.filter(c => c !== cat) : [cat]
        );
    };

    const handleHeaderCategoryChange = (cat: string) => {
        if (!cat) setSelectedCategories([]);
        else setSelectedCategories([cat]);
    };

    const handleAddToCart = (e: React.MouseEvent, product: Product) => {
        e.stopPropagation();
        addToCart({
            _id: product._id,
            name: product.name,
            price: product.price,
            image: product.images[0] || '',
            vendorName: product.vendor?.vendor_details?.business_name || product.vendor?.first_name || 'Vendor'
        });
    };

    return (
        <div className="min-h-screen bg-gray-50 pb-12">
            <ShopHeader
                onSearch={setSearchQuery}
                onCategoryChange={handleHeaderCategoryChange}
            />

            {/* 32 (header) + 8 (sub-header) + spacing */}
            <div className="pt-28 lg:pt-32">
                {/* Hero Carousel - Amazon Style */}
                <div className="relative bg-gray-900 mb-8 overflow-hidden h-64 md:h-80 lg:h-96 w-full max-w-[1500px] mx-auto">
                    <div className="absolute inset-0 bg-gradient-to-t from-gray-50 via-transparent to-transparent z-10 pointer-events-none" />
                    <div className="overflow-hidden h-full" ref={emblaRef}>
                        <div className="flex h-full">
                            {BANNERS.map((banner) => (
                                <div key={banner.id} className="relative flex-[0_0_100%] min-w-0 h-full">
                                    <img
                                        src={banner.image}
                                        alt={banner.title}
                                        className="w-full h-full object-cover opacity-80"
                                    />
                                    <div className="absolute top-1/2 left-10 md:left-20 transform -translate-y-1/2 z-20 text-white drop-shadow-lg">
                                        <h2 className="text-3xl md:text-5xl font-bold mb-2">{banner.title}</h2>
                                        <p className="text-xl md:text-2xl mb-6">{banner.subtitle}</p>
                                        <button onClick={() => window.scrollTo({ top: 500, behavior: 'smooth' })} className="px-6 py-2 bg-pink-600 hover:bg-pink-700 text-white font-medium rounded shadow-lg transition-colors">
                                            Explore Now
                                        </button>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>

                <div className="max-w-[1500px] mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex flex-col lg:flex-row gap-6">
                        {/* Sidebar Filters */}
                        <div className="w-full lg:w-64 flex-shrink-0 space-y-6">
                            <div className="bg-white p-4 rounded shadow-sm border border-gray-200">
                                <h3 className="font-bold text-gray-900 mb-3 text-sm uppercase tracking-wide">Filters</h3>

                                {/* Categories */}
                                <div className="mb-6">
                                    <h4 className="text-sm font-semibold text-gray-800 mb-2">Category</h4>
                                    <div className="space-y-1 max-h-60 overflow-y-auto custom-scrollbar">
                                        {CATEGORIES.map(cat => (
                                            <label key={cat} className="flex items-center gap-2 cursor-pointer hover:bg-gray-50 p-1 rounded -ml-1">
                                                <input
                                                    type="checkbox"
                                                    checked={selectedCategories.includes(cat)}
                                                    onChange={() => toggleCategory(cat)}
                                                    className="rounded border-gray-300 text-pink-600 focus:ring-pink-500"
                                                />
                                                <span className={`text-sm ${selectedCategories.includes(cat) ? 'font-medium text-pink-600' : 'text-gray-600'}`}>
                                                    {cat}
                                                </span>
                                            </label>
                                        ))}
                                    </div>
                                </div>

                                {/* Price Range */}
                                <div className="mb-6">
                                    <h4 className="text-sm font-semibold text-gray-800 mb-2">Price (₹)</h4>
                                    <div className="flex items-center gap-2">
                                        <input
                                            type="number"
                                            placeholder=""
                                            value={minPrice}
                                            onChange={(e) => setMinPrice(e.target.value)}
                                            className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:border-pink-500 focus:ring-1 focus:border-pink-500 outline-none"
                                        />
                                        <span className="text-gray-400">-</span>
                                        <input
                                            type="number"
                                            placeholder=""
                                            value={maxPrice}
                                            onChange={(e) => setMaxPrice(e.target.value)}
                                            className="w-full px-2 py-1 text-sm border border-gray-300 rounded focus:border-pink-500 focus:ring-1 focus:border-pink-500 outline-none"
                                        />
                                    </div>
                                    <p className="text-[10px] text-gray-400 mt-1">Range: ₹1k - ₹500k</p>
                                </div>

                                {/* Avg Rating Filter (Mock) */}
                                <div>
                                    <h4 className="text-sm font-semibold text-gray-800 mb-2">Customer Reviews</h4>
                                    {[4, 3, 2, 1].map(star => (
                                        <div key={star} className="flex items-center gap-1 cursor-pointer hover:bg-gray-50 p-1 rounded -ml-1">
                                            <div className="flex text-yellow-400">
                                                {[...Array(5)].map((_, i) => (
                                                    <Star key={i} className={`w-4 h-4 ${i < star ? 'fill-current' : 'text-gray-300'}`} />
                                                ))}
                                            </div>
                                            <span className="text-sm text-gray-600">& Up</span>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        </div>

                        {/* Main Content */}
                        <div className="flex-1">
                            {/* Header was here, now in ShopHeader */}
                            <div className="mb-4">
                                <h1 className="text-xl font-bold text-gray-900">Results</h1>
                            </div>

                            {loading ? (
                                <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-4">
                                    {[...Array(8)].map((_, i) => (
                                        <div key={i} className="bg-white rounded border border-gray-200 p-4 h-80 animate-pulse">
                                            <div className="w-full h-48 bg-gray-200 rounded mb-4"></div>
                                            <div className="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
                                            <div className="h-3 bg-gray-200 rounded w-1/2"></div>
                                        </div>
                                    ))}
                                </div>
                            ) : products.length === 0 ? (
                                <div className="text-center py-20 bg-white rounded border border-gray-200">
                                    <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4 text-gray-400">
                                        <ShoppingBag className="w-8 h-8" />
                                    </div>
                                    <h3 className="text-lg font-bold text-gray-900 mb-1">No products found</h3>
                                    <p className="text-gray-500">Try checking your spelling or use more general terms.</p>
                                </div>
                            ) : (
                                <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-4">
                                    {products.map((product) => (
                                        <div
                                            key={product._id}
                                            onClick={() => router.push(`/shop/${product._id}`)}
                                            className="bg-white rounded border border-gray-200 overflow-hidden hover:shadow-lg transition-all cursor-pointer group flex flex-col h-full"
                                        >
                                            <div className="relative aspect-square overflow-hidden bg-gray-100 p-4">
                                                {product.images?.[0] ? (
                                                    <img
                                                        src={product.images[0]}
                                                        alt={product.name}
                                                        className="w-full h-full object-contain mix-blend-multiply group-hover:scale-105 transition-transform duration-300"
                                                    />
                                                ) : (
                                                    <div className="w-full h-full flex items-center justify-center text-gray-300">
                                                        <ShoppingBag className="w-12 h-12" />
                                                    </div>
                                                )}
                                            </div>

                                            <div className="p-4 flex flex-col flex-1">
                                                <h3 className="font-medium text-gray-900 line-clamp-2 mb-1 group-hover:text-pink-600 transition-colors h-10 text-sm">
                                                    {product.name}
                                                </h3>

                                                {/* Rating Mock */}
                                                <div className="flex items-center mb-2">
                                                    <div className="flex text-yellow-400 text-xs">
                                                        {[...Array(5)].map((_, i) => (
                                                            <Star key={i} className={`w-3 h-3 ${i < 4 ? 'fill-current' : 'text-gray-300'}`} />
                                                        ))}
                                                    </div>
                                                    <span className="text-xs text-blue-600 ml-1 hover:underline">128</span>
                                                </div>

                                                <div className="mt-auto">
                                                    <div className="flex items-baseline gap-1 mb-2">
                                                        <span className="text-xs align-top">₹</span>
                                                        <span className="text-xl font-bold text-gray-900">{product.price.toLocaleString()}</span>
                                                    </div>

                                                    <p className="text-xs text-gray-500 mb-3">
                                                        Sold by <span className="text-blue-600 hover:underline">{product.vendor?.vendor_details?.business_name || product.vendor?.first_name || 'Vendor'}</span>
                                                    </p>

                                                    <button
                                                        onClick={(e) => handleAddToCart(e, product)}
                                                        className="w-full bg-yellow-400 hover:bg-yellow-500 text-black text-sm font-medium py-2 px-3 rounded-full transition-colors flex items-center justify-center gap-2"
                                                    >
                                                        <ShoppingCart className="w-4 h-4" /> Add to Cart
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )}

                            {/* Pagination */}
                            {totalPages > 1 && (
                                <div className="flex justify-center mt-8 gap-2">
                                    <button
                                        onClick={() => setPage(p => Math.max(1, p - 1))}
                                        disabled={page === 1}
                                        className="px-4 py-2 bg-white border border-gray-300 rounded text-sm hover:bg-gray-50 disabled:opacity-50"
                                    >
                                        Previous
                                    </button>
                                    <span className="px-4 py-2 text-sm text-gray-700 font-medium flex items-center">
                                        Page {page} of {totalPages}
                                    </span>
                                    <button
                                        onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                                        disabled={page === totalPages}
                                        className="px-4 py-2 bg-white border border-gray-300 rounded text-sm hover:bg-gray-50 disabled:opacity-50"
                                    >
                                        Next
                                    </button>
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

