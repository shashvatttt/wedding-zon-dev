'use client';

import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import FeedHeader from '../feed/components/FeedHeader';
import Footer from '@/components/Footer';
import api from './api';
import { MapPin, Search, Star, ChevronRight, X, Camera, ChevronDown, Gem, Shirt, Music } from 'lucide-react';
import VendorCard from '@/components/VendorCard';
import { useAuth } from '../context/AuthContext';
import { Briefcase } from 'lucide-react';
import RegionalHighlights from './components/RegionalHighlights';

// --- Types ---
interface Vendor {
    _id: string;
    displayName: string;
    username: string;
    occupation: string;
    city: string;
    state: string;
    profilePhoto: string | null;
    vendor_details?: {
        business_name?: string;
        business_address?: string;
        service_type?: string;
        price_range?: string;
        experience_years?: number;
        description?: string;
    };
    rating?: number; // Mock if not in API
    price?: number;  // Mock if not in API
    products?: Array<{
        _id: string;
        name: string;
        price: number;
        image: string | null;
    }>;
}

export default function ServicesPage() {
    const router = useRouter();
    const [photographers, setPhotographers] = useState<Vendor[]>([]);
    const [makeupArtists, setMakeupArtists] = useState<Vendor[]>([]);
    const [venues, setVenues] = useState<Vendor[]>([]);
    const [caterers, setCaterers] = useState<Vendor[]>([]);
    const [allVendors, setAllVendors] = useState<Vendor[]>([]);
    const [rajasthanVendors, setRajasthanVendors] = useState<Vendor[]>([]);
    const [upVendors, setUpVendors] = useState<Vendor[]>([]);
    const [delhiVendors, setDelhiVendors] = useState<Vendor[]>([]);
    const [loading, setLoading] = useState(true);
    const { user, isAuthenticated } = useAuth();

    // Search State
    const [searchType, setSearchType] = useState('');
    const [searchLocation, setSearchLocation] = useState('');
    const [searchCountry, setSearchCountry] = useState('');
    const [searchState, setSearchState] = useState('');
    const [minPrice, setMinPrice] = useState('');
    const [maxPrice, setMaxPrice] = useState('');
    const [isSearching, setIsSearching] = useState(false);
    const [searchResults, setSearchResults] = useState<Vendor[]>([]);
    const [searchLoading, setSearchLoading] = useState(false);
    const [activeCategory, setActiveCategory] = useState<string | null>(null);

    // Initial Data Fetch
    useEffect(() => {
        const fetchData = async () => {
            setLoading(true);
            try {
                // Fetch each section independently but in parallel
                // This allows the UI to populate section-by-section
                const fetchSection = async (url: string, setter: (data: any) => void) => {
                    try {
                        const res = await api.get(url);
                        if (res.data.success) setter(res.data.data);
                    } catch (err) {
                        console.error(`Failed to fetch from ${url}`, err);
                    }
                };

                await Promise.allSettled([
                    fetchSection('/users/search?role=vendor&occupation=Photographer&limit=20', setPhotographers),
                    fetchSection('/users/search?role=vendor&occupation=Makeup&limit=20', setMakeupArtists),
                    fetchSection('/users/search?role=vendor&occupation=Venue&limit=20', setVenues),
                    fetchSection('/users/search?role=vendor&occupation=Catering&limit=20', setCaterers),
                    fetchSection('/users/search?role=vendor&limit=20', setAllVendors),
                    fetchSection('/users/search?role=vendor&state=Rajasthan&limit=4', setRajasthanVendors),
                    fetchSection('/users/search?role=vendor&state=Uttar Pradesh&limit=4', setUpVendors),
                    fetchSection('/users/search?role=vendor&state=Delhi&limit=4', setDelhiVendors),
                ]);

            } catch (error) {
                console.error('Failed to fetch vendors', error);
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    // Handle Search / Filter
    const performSearch = async (type = '', city = '', state = '', country = '', minP = '', maxP = '') => {
        setIsSearching(true);
        setSearchLoading(true);
        setActiveCategory(type || 'Custom Search');

        try {
            const params = new URLSearchParams();
            params.append('role', 'vendor');
            params.append('vendor_status', 'active');
            if (type) params.append('occupation', type);
            if (city) params.append('city', city);
            if (state) params.append('state', state);
            if (country) params.append('country', country);
            if (minP) params.append('minPrice', minP);
            if (maxP) params.append('maxPrice', maxP);

            const res = await api.get(`/users/search?${params.toString()}`);
            if (res.data.success) {
                setSearchResults(res.data.data);
            } else {
                setSearchResults([]);
            }
        } catch (error) {
            console.error('Search failed', error);
            setSearchResults([]);
        } finally {
            setSearchLoading(false);
        }
    };

    const handleSearchClick = () => {
        if (!searchType && !searchLocation && !searchCountry && !searchState && !minPrice && !maxPrice) return;
        performSearch(searchType, searchLocation, searchState, searchCountry, minPrice, maxPrice);
    };

    const handleCategoryClick = (categoryTitle: string) => {
        // Map UI titles to backend search terms
        const mapping: Record<string, string> = {
            'Photography': 'Photographer',
            'Jewellery': 'Jewelry',
            'Music/DJ': 'DJ',
            'Fashion': 'Fashion',
            'Makeup': 'Makeup',
            'Venues': 'Venue',
            'Catering': 'Catering'
        };
        const searchTerm = mapping[categoryTitle] || categoryTitle;
        setSearchType(searchTerm); // update input
        performSearch(searchTerm, searchLocation); // keep location if set
    };

    const clearSearch = () => {
        setIsSearching(false);
        setSearchType('');
        setSearchLocation('');
        setSearchState('');
        setSearchCountry('');
        setMinPrice('');
        setMaxPrice('');
        setSearchResults([]);
        setActiveCategory(null);
    };

    const scrollToAllVendors = () => {
        const element = document.getElementById('all-vendors');
        if (element) {
            element.scrollIntoView({ behavior: 'smooth' });
        }
    };

    const handleVendorCTA = () => {
        if (!isAuthenticated) {
            router.push('/login?type=vendor&role=vendor');
        } else if (user?.role === 'vendor') {
            router.push('/vendor/dashboard');
        } else {
            router.push('/');
        }
    };

    return (
        <div className="min-h-screen bg-white font-sans text-gray-900 pt-[72px]">
            <FeedHeader />

            {/* --- HERO SECTION --- */}
            <div
                className="relative w-full min-h-[850px] md:min-h-[700px] lg:h-[650px] flex flex-col items-center justify-start lg:justify-center py-20 lg:py-0 bg-gray-900"
                style={{
                    backgroundImage: `linear-gradient(to bottom, rgba(0, 0, 0, 0.7) 0%, rgba(0, 0, 0, 0.3) 70%, rgba(255, 255, 255, 1) 100%), url('/services-hero.jpg')`,
                    backgroundSize: 'cover',
                    backgroundPosition: 'center',
                    backgroundRepeat: 'no-repeat'
                }}
            >
                {/* Content */}
                <div className="relative z-10 text-center px-4 mt-0 md:mt-[-40px] w-full max-w-[1440px] mx-auto">
                    <h1 className="font-serif font-black text-4xl md:text-7xl text-white tracking-tight mb-2 md:mb-4 drop-shadow-[0_4px_8px_rgba(0,0,0,0.6)]">
                        Find the Perfect Wedding Vendor
                    </h1>
                    <p className="text-lg md:text-2xl text-white mb-10 md:mb-14 font-medium drop-shadow-[0_2px_4px_rgba(0,0,0,0.5)]">
                        Search over 360,000 wedding vendors with reviews, pricing, availability and more
                    </p>


                    {/* Search Box */}
                    <div className="max-w-5xl mx-auto w-full relative z-20">
                        <div className="bg-white rounded-[20px] md:rounded-full shadow-2xl overflow-hidden md:pl-6 md:pr-2 py-2 flex flex-col md:flex-row items-stretch md:h-20 gap-2 md:gap-0">
                            {/* Vendor Type Dropdown */}
                            <div className="relative flex-[1.5] border-b md:border-b-0 md:border-r border-gray-100 flex items-center h-14 md:h-auto">
                                <select
                                    className="w-full h-full outline-none text-[#EF2F55] placeholder-gray-400 font-bold text-lg bg-transparent px-6 md:px-2 appearance-none cursor-pointer"
                                    value={searchType}
                                    onChange={(e) => setSearchType(e.target.value)}
                                >
                                    <option value="" disabled hidden>Choose Vendor Type</option>
                                    <option value="Photographer">Photography</option>
                                    <option value="Venue">Venues</option>
                                    <option value="Catering">Catering</option>
                                    <option value="Makeup">Makeup Artist</option>
                                    <option value="Decorator">Decorator</option>
                                    <option value="DJ">Music/DJ</option>
                                    <option value="Fashion">Fashion</option>
                                    <option value="Jewelry">Jewellery</option>
                                </select>
                                <ChevronDown className="absolute right-6 md:right-4 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-800 pointer-events-none" />
                            </div>

                            {/* Location */}
                            <div className="relative flex-[1.5] border-b md:border-b-0 flex items-center bg-white h-14 md:h-auto">
                                <input
                                    type="text"
                                    placeholder="Location"
                                    className="w-full h-full outline-none text-gray-700 placeholder-gray-500 font-semibold text-lg bg-transparent px-6 md:px-4"
                                    value={searchLocation}
                                    onChange={(e) => setSearchLocation(e.target.value)}
                                />
                            </div>

                            {/* Search Button */}
                            <button
                                onClick={handleSearchClick}
                                className="bg-[#EF2F55] hover:bg-rose-700 text-white px-10 py-3 h-14 md:h-full mx-2 md:mx-0 rounded-[15px] md:rounded-full font-black uppercase tracking-widest text-sm transition-all shadow-md active:scale-95 whitespace-nowrap"
                            >
                                Search Now
                            </button>
                        </div>

                        {/* Featured Categories Pills */}
                        <div className="mt-12 flex flex-col items-center gap-6">
                            <p className="text-white text-xl font-medium drop-shadow-[0_2px_4px_rgba(0,0,0,0.5)]">Or browse featured categories</p>
                            <div className="flex flex-wrap justify-center gap-3">
                                {[
                                    { title: 'Photography', icon: <Camera className="w-5 h-5" />, key: 'Photography' },
                                    { title: 'Jewellery', icon: <Gem className="w-5 h-5" />, key: 'Jewellery' },
                                    { title: 'Fashion', icon: <Shirt className="w-5 h-5" />, key: 'Fashion' },
                                    { title: 'Music', icon: <Music className="w-5 h-5" />, key: 'Music/DJ' }
                                ].map((pill) => (
                                    <button
                                        key={pill.key}
                                        onClick={() => handleCategoryClick(pill.key)}
                                        className="bg-white/90 backdrop-blur-sm text-[#EF2F55] font-bold py-3 sm:py-4 px-4 sm:px-6 rounded-[15px] sm:rounded-[20px] border-2 border-white shadow-lg hover:bg-[#EF2F55] hover:text-white hover:border-[#EF2F55] transition-all transform hover:-translate-y-1 text-base sm:text-lg flex items-center gap-2.5"
                                    >
                                        <span className="opacity-80">{pill.icon}</span>
                                        <span>{pill.title}</span>
                                    </button>
                                ))}
                            </div>
                        </div>
                    </div>


                </div>
            </div>

            {/* --- SEARCH RESULTS VIEW --- */}
            {isSearching ? (
                <div className="max-w-[1440px] mx-auto px-4 sm:px-8 py-12 min-h-[500px]">
                    <div className="flex items-center justify-between mb-8">
                        <h2 className="text-3xl md:text-4xl font-bold text-gray-900">
                            Search Results: <span className="text-[#EF2F55]">{activeCategory}</span>
                            {searchLocation && <span className="text-gray-500 text-2xl font-normal ml-2">in {searchLocation}</span>}
                        </h2>
                        <button
                            onClick={clearSearch}
                            className="flex items-center gap-2 px-4 py-2 rounded-full border border-gray-300 text-gray-600 hover:bg-gray-100 hover:text-gray-900 transition-colors"
                        >
                            <X className="w-4 h-4" /> Clear Search
                        </button>
                    </div>

                    <VendorSection
                        title=""
                        vendors={searchResults}
                        loading={searchLoading}
                        useGrid={true}
                        emptyMessage="No vendors found matching your criteria. Try adjusting your search."
                    />
                </div>
            ) : (
                <>
                    {/* --- CATEGORIES SECTION (DEFAULT VIEW) --- */}
                    <div className="max-w-[1440px] mx-auto px-4 sm:px-8 py-12">
                        <div className="flex flex-col md:flex-row justify-between items-center md:items-end mb-8 gap-4">
                            <h2 className="text-3xl md:text-4xl font-bold text-center md:text-left">Featured Categories</h2>
                            <button
                                onClick={scrollToAllVendors}
                                className="text-[#EF2F55] font-bold uppercase text-sm flex items-center gap-1 hover:underline whitespace-nowrap"
                            >
                                View All <ChevronRight className="w-4 h-4" />
                            </button>
                        </div>

                        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-6">
                            {/* Category Cards - Using Provided Images */}
                            {[
                                { title: 'Photography', img: '/vendor-cat-photography.png', link: '/vendor/search?category=Photography' },
                                { title: 'Jewellery', img: '/vendor-cat-jewellery.png', link: '/vendor/search?category=Jewellery' },
                                { title: 'Music/DJ', img: '/vendor-cat-music.png', link: '/vendor/search?category=DJ' },
                                { title: 'Fashion', img: '/vendor-cat-fashion.png', link: '/vendor/search?category=Fashion' }
                            ].map((cat, idx) => (
                                <div
                                    key={idx}
                                    onClick={() => handleCategoryClick(cat.title)}
                                    className="group relative block w-full aspect-[3/4] rounded-3xl overflow-hidden shadow-lg hover:shadow-xl transition-shadow cursor-pointer"
                                >
                                    <Image
                                        src={cat.img}
                                        alt={cat.title}
                                        fill
                                        className="object-cover group-hover:scale-105 transition-transform duration-500"
                                        quality={100}
                                        unoptimized
                                    />
                                    <div className="absolute inset-0 bg-black/0 group-hover:bg-black/10 transition-colors" />
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* --- TOP WEDDING SHOWCASES --- */}
                    {/* Only show these if NOT searching */}
                    <div className="space-y-8 pb-12">
                        <VendorSection id="photographers" title="Top Wedding Photographers" vendors={photographers} loading={loading} onMore={() => handleCategoryClick('Photography')} priorityFirst={true} />
                        <VendorSection id="makeup" title="Top Makeup Artists" vendors={makeupArtists} loading={loading} onMore={() => handleCategoryClick('Makeup')} />
                        <VendorSection id="venues" title="Top Venues" vendors={venues} loading={loading} onMore={() => handleCategoryClick('Venues')} />
                        <VendorSection id="caterers" title="Top Caterers" vendors={caterers} loading={loading} onMore={() => handleCategoryClick('Catering')} />
                    </div>

                    {/* Catch-all Section */}
                    <div id="all-vendors" className="bg-gray-50 py-12">
                        <div className="max-w-[1440px] mx-auto px-4 sm:px-8">
                            <VendorSection title="All Approved Vendors" vendors={allVendors} loading={loading} useGrid={true} />
                        </div>
                    </div>

                    {/* --- VENDOR CTA SECTION --- */}
                    <div className="bg-white py-20 px-4">
                        <div className="max-w-5xl mx-auto rounded-[40px] bg-gradient-to-br from-[#EF2F55] to-[#D41F45] p-8 md:p-16 text-white relative overflow-hidden shadow-2xl">
                            {/* Decorative Background Elements */}
                            <div className="absolute top-[-50px] right-[-50px] w-64 h-64 bg-white/10 rounded-full blur-3xl" />
                            <div className="absolute bottom-[-50px] left-[-10%] w-80 h-80 bg-black/10 rounded-full blur-3xl" />

                            <div className="relative z-10 flex flex-col md:flex-row items-center justify-between gap-12">
                                <div className="flex-1 text-center md:text-left">
                                    <div className="inline-flex items-center gap-2 bg-white/20 backdrop-blur-md px-4 py-2 rounded-full text-sm font-bold uppercase tracking-widest mb-6">
                                        <Briefcase className="w-4 h-4" /> For Wedding Professionals
                                    </div>
                                    <h2 className="text-4xl md:text-6xl font-serif font-black mb-6 leading-tight">
                                        Grow Your Wedding <br /> <span className="text-pink-200">Business</span> with Us
                                    </h2>
                                    <p className="text-xl text-pink-50 font-medium leading-relaxed max-w-xl">
                                        Join India's most premium wedding network. Showcase your portfolio to thousands of couples and book more weddings.
                                    </p>
                                </div>

                                <div className="shrink-0">
                                    <button
                                        onClick={handleVendorCTA}
                                        className="bg-white text-[#EF2F55] hover:bg-pink-50 px-12 py-6 rounded-2xl font-black uppercase tracking-widest text-lg shadow-xl hover:shadow-2xl transition-all transform hover:-translate-y-2 active:translate-y-0 animate-button-glow"
                                    >
                                        {!isAuthenticated
                                            ? "Register as Vendor"
                                            : user?.role === 'vendor'
                                                ? "Vendor Dashboard"
                                                : "Join as Vendor"
                                        }
                                    </button>
                                    <div className="mt-6 text-center">
                                        <p className="text-pink-100 font-bold opacity-80">
                                            Already a partner?
                                            <button
                                                onClick={() => router.push('/login')}
                                                className="ml-2 text-white underline hover:text-pink-200 transition-colors"
                                            >
                                                Login Here
                                            </button>
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* --- TOP LOCATIONS --- */}
                    <div className="max-w-[1440px] mx-auto px-4 sm:px-8 py-16">
                        <h2 className="text-3xl md:text-4xl font-bold text-center mb-10 text-gray-900">Top Locations</h2>
                        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                            {['Delhi', 'Mumbai', 'Bangalore', 'Goa', 'Chandigarh', 'Jaipur', 'Udaipur', 'Pune'].map(loc => (
                                <div
                                    key={loc}
                                    onClick={() => { setSearchLocation(loc); performSearch(searchType, loc); }}
                                    className="h-24 bg-white border border-gray-200 rounded-xl flex items-center justify-center cursor-pointer hover:border-[#EF2F55] hover:text-[#EF2F55] hover:shadow-md transition-all"
                                >
                                    <span className="text-lg font-semibold text-gray-700">{loc}</span>
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* --- REGIONAL HIGHLIGHTS --- */}
                    <RegionalHighlights 
                        vendors={{
                            rajasthan: rajasthanVendors,
                            up: upVendors,
                            delhi: delhiVendors
                        }}
                        onSearchState={(stateName) => {
                            setSearchState(stateName);
                            setSearchLocation(''); // Clear city when searching state
                            performSearch(searchType, '', stateName, searchCountry, minPrice, maxPrice);
                        }}
                    />
                </>
            )}

            {/* --- FOOTER --- */}
            <Footer />
        </div>
    );
}

// --- Subcomponents ---

function CategoryCard({ title, image, color, onClick }: { title: string, image: string, color: string, onClick?: () => void }) {
    return (
        <div
            onClick={onClick}
            className={`relative h-[250px] md:h-[300px] rounded-2xl overflow-hidden shadow-lg cursor-pointer hover:shadow-2xl hover:-translate-y-1 transition-all group ${color}`}
        >
            {/* Image Placeholder - In real app use Image component with src */}
            <div className="absolute inset-0 bg-black/10 group-hover:bg-black/20 transition-colors" />

            {/* Decorative Icon Wrapper */}
            <div className="absolute top-4 right-4 bg-white/30 backdrop-blur-sm p-2 rounded-full opacity-0 group-hover:opacity-100 transition-opacity">
                <ChevronRight className="w-5 h-5 text-white" />
            </div>

            <div className="absolute inset-0 flex flex-col items-center justify-center text-gray-800 z-10 p-4 text-center">
                <h3 className="font-serif text-3xl md:text-4xl font-bold bg-white/80 px-4 py-2 rounded-xl backdrop-blur-sm shadow-sm">{title}</h3>
                <p className="mt-2 text-sm font-medium opacity-0 group-hover:opacity-100 transition-opacity translate-y-4 group-hover:translate-y-0 bg-black/50 text-white px-3 py-1 rounded-full">
                    View Vendors
                </p>
            </div>
        </div>
    );
}

function VendorSection({
    id,
    title,
    vendors,
    loading,
    emptyMessage,
    useGrid = false,
    onMore,
    priorityFirst
}: {
    id?: string,
    title: string,
    vendors: Vendor[],
    loading: boolean,
    emptyMessage?: string,
    useGrid?: boolean,
    onMore?: () => void,
    priorityFirst?: boolean
}) {
    const router = useRouter();

    if (!loading && vendors.length === 0) {
        if (!title) return <div className="text-center py-20 text-gray-500 bg-gray-50 rounded-xl">{emptyMessage || 'No vendors found.'}</div>;
        // If it's a section like "Top Photographers" and empty, maybe hide it or show empty state?
        // Let's hide sections with no data to keep UI clean, unless it's search results
        if (title) return null;
    }

    return (
        <div id={id} className="relative scroll-mt-24">
            {title && (
                <div className="flex items-center justify-between mb-6 px-4 sm:px-8 max-w-[1440px] mx-auto">
                    <h2 className="text-2xl md:text-3xl font-bold text-gray-900">{title}</h2>
                    {onMore && (
                        <button onClick={onMore} className="text-[#EF2F55] font-semibold text-sm hover:underline flex items-center">
                            See All <ChevronRight className="w-4 h-4" />
                        </button>
                    )}
                </div>
            )}

            <div className={`max-w-[1440px] mx-auto px-4 sm:px-8 ${loading ? 'opacity-50' : ''}`}>

                {useGrid ? (
                    // GRID LAYOUT (Search Results / Catch-all)
                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 justify-items-center">
                        {loading ? [1, 2, 3, 4].map(i => <div key={i} className="w-full h-80 bg-gray-100 rounded-2xl animate-pulse" />) :
                            vendors.map((vendor, idx) => (
                                <VendorCard key={vendor._id} vendor={vendor} priority={priorityFirst && idx < 4} />
                            ))}
                    </div>
                ) : (
                    // HORIZONTAL SCROLL LAYOUT (Top Sections)
                    <div className="flex overflow-x-auto gap-6 pb-6 scrollbar-hide snap-x">
                        {loading ? [1, 2, 3, 4].map(i => <div key={i} className="min-w-[300px] h-80 bg-gray-100 rounded-2xl animate-pulse snap-center" />) :
                            vendors.map((vendor, idx) => (
                                <div key={vendor._id} className="min-w-[300px] snap-center">
                                    <VendorCard vendor={vendor} priority={priorityFirst && idx < 4} />
                                </div>
                            ))}
                    </div>
                )}
            </div>
        </div>
    );
}

