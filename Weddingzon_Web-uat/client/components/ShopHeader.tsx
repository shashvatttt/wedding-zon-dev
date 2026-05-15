'use client';

import React, { useState } from 'react';
import { Search, ShoppingCart, User, Menu, MapPin, ChevronDown, LogOut } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/app/context/AuthContext';
import { useCart } from '@/app/context/CartContext';

interface ShopHeaderProps {
    onSearch: (query: string) => void;
    onCategoryChange?: (category: string) => void;
}

const CATEGORIES = [
    'All',
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

export default function ShopHeader({ onSearch, onCategoryChange }: ShopHeaderProps) {
    const router = useRouter();
    const { user, logout } = useAuth();
    const { cartCount, toggleCart } = useCart();

    const [searchQuery, setSearchQuery] = useState('');
    const [selectedCategory, setSelectedCategory] = useState('All');
    const [isAccountOpen, setIsAccountOpen] = useState(false);

    const handleSearch = (e: React.FormEvent) => {
        e.preventDefault();
        onSearch(searchQuery);
    };

    const handleCategorySelect = (e: React.ChangeEvent<HTMLSelectElement>) => {
        const cat = e.target.value;
        setSelectedCategory(cat);
        if (onCategoryChange) {
            onCategoryChange(cat === 'All' ? '' : cat);
        }
    };

    return (
        <header className="bg-gray-900 text-white fixed top-0 w-full z-50">
            {/* Top Bar */}
            <div className="flex items-center justify-between px-4 py-2 gap-4 h-16">

                {/* Logo */}
                <div onClick={() => router.push('/shop')} className="cursor-pointer flex items-center hover:outline hover:outline-1 hover:outline-white p-1 rounded">
                    <span className="font-serif text-2xl font-bold tracking-wide">
                        Wedding<span className="text-[#D4AF37]">Zon</span>
                    </span>
                </div>

                {/* Location (Desktop) */}
                <div className="hidden md:flex flex-col text-xs leading-tight cursor-pointer hover:outline hover:outline-1 hover:outline-white p-2 rounded">
                    <div className="text-gray-300 ml-5">Deliver to</div>
                    <div className="font-bold flex items-center gap-1">
                        <MapPin className="w-4 h-4" />
                        {user?.city || 'Select Location'}
                    </div>
                </div>

                {/* Search Bar */}
                <form onSubmit={handleSearch} className="flex-1 max-w-3xl flex h-10 rounded overflow-hidden focus-within:ring-3 focus-within:ring-[#D4AF37]/50">
                    <div className="relative">
                        <select
                            value={selectedCategory}
                            onChange={handleCategorySelect}
                            className="h-full bg-gray-100 text-gray-700 text-xs px-2 border-r border-gray-300 outline-none cursor-pointer hover:bg-gray-200 border-none rounded-l-md w-auto"
                        >
                            {CATEGORIES.map(cat => (
                                <option key={cat} value={cat}>{cat}</option>
                            ))}
                        </select>
                    </div>
                    <input
                        type="text"
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="flex-1 px-4 text-black outline-none w-full"
                        placeholder="Search WeddingZon..."
                    />
                    <button type="submit" className="bg-[#D4AF37] hover:bg-[#b5952f] px-5 text-gray-900">
                        <Search className="w-6 h-6" />
                    </button>
                </form>

                {/* Account & Lists */}
                <div
                    className="relative cursor-pointer hover:outline hover:outline-1 hover:outline-white p-2 rounded group"
                    onMouseEnter={() => setIsAccountOpen(true)}
                    onMouseLeave={() => setIsAccountOpen(false)}
                    onClick={() => setIsAccountOpen(!isAccountOpen)}
                >
                    <div className="text-xs text-gray-300">Hello, {user?.first_name || 'Sign in'}</div>
                    <div className="text-sm font-bold flex items-center gap-1">
                        Account & Lists <ChevronDown className="w-3 h-3" />
                    </div>

                    {/* Dropdown */}
                    {isAccountOpen && (
                        <div className="absolute top-full right-0 w-64 bg-white text-gray-800 rounded shadow-xl border border-gray-200 mt-0 z-50 overflow-hidden">


                            <div className="flex">
                                <div className="w-full py-2">
                                    <div className="px-4 py-2 text-sm font-bold text-gray-900">Your Account</div>
                                    <ul className="text-sm">
                                        <li onClick={() => router.push('/profile')} className="px-4 py-1 hover:bg-gray-100 cursor-pointer hover:text-[#D4AF37]">Your Profile</li>
                                        <li onClick={() => router.push('/orders')} className="px-4 py-1 hover:bg-gray-100 cursor-pointer hover:text-[#D4AF37]">Your Orders</li>
                                        <li onClick={() => router.push('/wishlist')} className="px-4 py-1 hover:bg-gray-100 cursor-pointer hover:text-[#D4AF37]">Your Wish List</li>
                                        {/* <li className="px-4 py-1 hover:bg-gray-100 cursor-pointer hover:text-[#D4AF37]">Vendor Dashboard</li> */}
                                        {user && (
                                            <li onClick={logout} className="px-4 py-1 hover:bg-gray-100 cursor-pointer hover:text-red-600 border-t mt-2 pt-2">Sign Out</li>
                                        )}
                                    </ul>
                                </div>
                            </div>
                        </div>
                    )}
                </div>

                {/* Orders */}
                <div onClick={() => router.push('/coming-soon')} className="hidden sm:block cursor-pointer hover:outline hover:outline-1 hover:outline-white p-2 rounded">
                    <div className="text-xs text-gray-300">Returns</div>
                    <div className="text-sm font-bold">& Orders</div>
                </div>

                {/* Cart */}
                <div onClick={toggleCart} className="cursor-pointer hover:outline hover:outline-1 hover:outline-white p-2 rounded flex items-end">
                    <div className="relative">
                        <ShoppingCart className="w-8 h-8" />
                        <span className="absolute -top-1 -right-1 bg-[#D4AF37] text-gray-900 text-xs font-bold w-5 h-5 flex items-center justify-center rounded-full border border-gray-900">
                            {cartCount}
                        </span>
                    </div>
                    <span className="font-bold text-sm hidden sm:inline mb-1 ml-1">Cart</span>
                </div>
            </div>

            {/* Sub-Header (Categories/Links) */}
            <div className="bg-gray-800 text-white text-sm flex items-center gap-4 px-4 py-1.5 overflow-x-auto whitespace-nowrap scrollbar-hide">
                <div className="flex items-center gap-1 font-bold cursor-pointer hover:text-white/80">
                    <Menu className="w-5 h-5" /> All
                </div>
                {['Today\'s Deals', 'Customer Service', 'Registry', 'Gift Cards', 'Sell'].map(item => (
                    <div key={item} className="cursor-pointer hover:border hover:border-white px-2 py-0.5 rounded transition-all">
                        {item}
                    </div>
                ))}
            </div>
        </header>
    );
}
