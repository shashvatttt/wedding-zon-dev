'use client';

import { useState, useEffect, Suspense } from 'react';
import { useRouter } from 'next/navigation';
import FeedSidebar from '../feed/components/FeedSidebar';
import FeedHeader from '../feed/components/FeedHeader';
import { Button } from '@/components/ui/button';
import { Slider } from '@/components/ui/slider';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import api from '../services/api';
import { 
    ExternalLink, Sparkles, Filter, RotateCcw, 
    Heart, Briefcase, GraduationCap, Users, 
    Globe, Search, Utensils, Zap
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { FadeIn } from '@/components/animations/FadeIn';
import { StaggerContainer, StaggerItem } from '@/components/animations/StaggerContainer';
import Image from 'next/image';

// --- Constants ---
const MARITAL_STATUSES = ['Unmarried', 'Doesn’t Matter', 'Awaiting Divorce', 'Divorced', 'Widowed', 'Anulled'];
const RELIGIONS = ['Hindu', 'Sikh', 'Muslim', 'Buddhist', 'Jain', 'Jewish', 'Christian', 'Other'];
const MANGLIK_STATUSES = ['Manglik', 'Non-Manglik', 'Anshik Manglik', "Don't Know", 'Doesn’t Matter'];
const DIETS = ['Veg', 'Non-Veg', 'Vegan', 'Doesn’t Matter'];

// --- Helper Components ---

// Ad Component
const AdWidget = () => {
    const [ads, setAds] = useState<any[]>([]);
    const [currentAdIndex, setCurrentAdIndex] = useState(0);

    useEffect(() => {
        const fetchAds = async () => {
            try {
                const res = await api.get('/ads/active');
                if (res.data.success && res.data.data.length > 0) {
                    setAds(res.data.data);
                }
            } catch (error) {
                console.error("Failed to fetch ads", error);
            }
        };
        fetchAds();
    }, []);

    useEffect(() => {
        if (ads.length <= 1) return;
        const interval = setInterval(() => {
            setCurrentAdIndex(prev => (prev + 1) % ads.length);
        }, 5000); // Rotate every 5 seconds
        return () => clearInterval(interval);
    }, [ads]);

    // Internal Promotions as Fallbacks
    const internalPromos = [
        {
            title: "Join as Vendor",
            description: "Showcase your skills to thousands of couples.",
            image: "/vendor-hero-bg.png",
            link: "/login?type=vendor&role=vendor",
            cta: "Register Now"
        },
        {
            title: "Premium Matrimony",
            description: "Find your perfect match with verified profiles.",
            image: "/matrimony-hero-bg.png",
            link: "/matrimony",
            cta: "Explore More"
        }
    ];

    if (ads.length === 0) {
        const promo = internalPromos[Math.floor(Date.now() / 10000) % internalPromos.length];
        return (
            <div className="bg-white shadow-xl rounded-3xl p-6 lg:sticky lg:top-28 border border-rose-50 overflow-hidden relative group">
                 <div className="absolute -top-12 -right-12 w-24 h-24 bg-rose-50 rounded-full blur-2xl group-hover:bg-rose-100 transition-colors" />
                 
                 <div className="relative z-10">
                    <div className="aspect-[4/5] rounded-2xl overflow-hidden bg-rose-50 mb-6 relative">
                        <Image 
                            src={promo.image} 
                            alt={promo.title} 
                            fill 
                            className="object-cover group-hover:scale-105 transition-transform duration-700"
                            unoptimized
                        />
                    </div>
                    <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-rose-100 text-rose-600 text-[10px] font-bold uppercase tracking-widest mb-3">
                        <Sparkles className="w-3 h-3" /> Featured
                    </div>
                    <h3 className="font-serif text-xl font-black text-gray-900 mb-2">{promo.title}</h3>
                    <p className="text-sm text-gray-500 mb-6 leading-relaxed">{promo.description}</p>
                    <Button 
                        onClick={() => window.location.href = promo.link}
                        className="w-full bg-[#EF2F55] hover:bg-rose-600 rounded-xl font-bold py-6 shadow-lg shadow-rose-200"
                    >
                        {promo.cta}
                    </Button>
                 </div>
            </div>
        );
    }

    const ad = ads[currentAdIndex];

    return (
        <div className="bg-white shadow-xl rounded-3xl p-6 lg:sticky lg:top-28 border border-rose-50 transition-all duration-500">
            <div className="relative w-full aspect-[4/5] rounded-2xl overflow-hidden mb-6 bg-gray-100 group">
                <img
                    src={ad.imageUrl}
                    alt={ad.title}
                    className="object-cover w-full h-full group-hover:scale-105 transition-transform duration-700"
                />
            </div>
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-blue-50 text-blue-600 text-[10px] font-bold uppercase tracking-widest mb-3">
                <Zap className="w-3 h-3" /> Sponsored
            </div>
            <h3 className="font-serif text-xl font-black text-gray-900 mb-4">{ad.title}</h3>
            {ad.link && (
                <a
                    href={ad.link}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="w-full flex items-center justify-center gap-2 bg-gray-900 text-white px-6 py-3 rounded-xl font-bold hover:bg-black transition-all group/btn"
                >
                    Visit Now <ExternalLink className="w-4 h-4 group-hover/btn:translate-x-0.5 transition-transform" />
                </a>
            )}
        </div>
    );
};

// Custom Chip for the design
const FilterChip = ({ label, selected, onClick }: { label: string, selected: boolean, onClick: () => void }) => {
    return (
        <motion.button
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            onClick={onClick}
            className={`
                box-border flex flex-row justify-center items-center px-4 py-2 gap-2
                h-12 rounded-2xl border transition-all duration-300
                font-semibold text-sm lg:text-base text-center whitespace-nowrap
                ${selected
                    ? 'bg-[#EF2F55] border-[#EF2F55] text-white shadow-md shadow-rose-100' 
                    : 'bg-white border-gray-100 text-gray-600 hover:border-rose-200 hover:bg-rose-50/30' 
                }
            `}
        >
            {label}
        </motion.button>
    );
};

function SearchContent() {
    const router = useRouter();
    const [user, setUser] = useState<any>(null);
    const [loading, setLoading] = useState(true);

    // Form State
    const [ageRange, setAgeRange] = useState([18, 60]); 
    const [heightRange, setHeightRange] = useState([48, 84]); 

    // Chips
    const [maritalStatus, setMaritalStatus] = useState<string | null>(null);
    const [religion, setReligion] = useState<string | null>(null);
    const [manglik, setManglik] = useState<string | null>(null);
    const [diet, setDiet] = useState<string | null>(null);

    // Inputs
    const [education, setEducation] = useState('');
    const [occupation, setOccupation] = useState('');

    useEffect(() => {
        const fetchUser = async () => {
            try {
                const res = await api.get('/auth/me');
                if (res.data) setUser(res.data);
            } catch (e) { } finally {
                setLoading(false);
            }
        };
        fetchUser();
    }, []);

    const formatHeight = (inches: number) => {
        const ft = Math.floor(inches / 12);
        const inVal = inches % 12;
        return `${ft}’ ${inVal.toString().padStart(2, '0')}"`;
    };

    const handleSearch = () => {
        const params = new URLSearchParams();
        params.set('minAge', ageRange[0].toString());
        params.set('maxAge', ageRange[1].toString());
        params.set('minHeight', heightRange[0].toString());
        params.set('maxHeight', heightRange[1].toString());

        if (maritalStatus && maritalStatus !== 'Doesn’t Matter') params.set('marital_status', maritalStatus);
        if (religion) params.set('religion', religion);
        if (manglik && manglik !== 'Doesn’t Matter') params.set('manglik', manglik);
        if (diet && diet !== 'Doesn’t Matter') params.set('eating_habits', diet);

        if (education) params.set('highest_education', education);
        if (occupation && occupation !== 'Doesn’t Matter') params.set('occupation', occupation);

        router.push(`/feed?${params.toString()}`);
    };

    const resetFilters = () => {
        setAgeRange([18, 60]);
        setHeightRange([48, 84]);
        setMaritalStatus(null);
        setReligion(null);
        setManglik(null);
        setDiet(null);
        setEducation('');
        setOccupation('');
    };

    if (loading) return null;

    const sections = [
        {
            title: "Marital Status",
            icon: <Heart className="w-5 h-5 text-rose-500" />,
            list: MARITAL_STATUSES,
            state: maritalStatus,
            setState: setMaritalStatus
        },
        {
            title: "Spiritual Preference",
            icon: <Globe className="w-5 h-5 text-indigo-500" />,
            list: RELIGIONS,
            state: religion,
            setState: setReligion
        },
        {
            title: "Astrology",
            icon: <Sparkles className="w-5 h-5 text-amber-500" />,
            list: MANGLIK_STATUSES,
            state: manglik,
            setState: setManglik
        },
        {
            title: "Lifestyle",
            icon: <Utensils className="w-5 h-5 text-emerald-500" />,
            list: DIETS,
            state: diet,
            setState: setDiet
        }
    ];

    return (
        <div className="min-h-screen bg-[#FFF9FA] font-inter">
            <FeedHeader />

            <div className="max-w-[1440px] mx-auto px-4 lg:px-[59px] pt-[110px] pb-12 flex flex-col lg:flex-row gap-8">

                {/* --- Left Sidebar --- */}
                <div className="hidden lg:block shrink-0 sticky top-24 h-fit">
                    <FeedSidebar user={user} activePage="search" />
                </div>

                {/* --- Main Content --- */}
                <div className="flex-1">
                    <FadeIn duration={0.5} className="bg-white shadow-2xl shadow-rose-50/50 rounded-[40px] border border-rose-50 p-6 lg:p-12 relative overflow-hidden">
                        {/* Decorative Background */}
                        <div className="absolute top-0 right-0 w-64 h-64 bg-rose-50/50 rounded-full blur-3xl -mr-32 -mt-32 pointer-events-none" />
                        
                        <div className="relative z-10">
                            {/* Header Widget */}
                            <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-12 gap-6">
                                <div>
                                    <div className="inline-flex items-center gap-2 mb-4">
                                        <div className="w-10 h-10 rounded-2xl bg-rose-500 flex items-center justify-center text-white shadow-lg shadow-rose-200">
                                            <Filter className="w-5 h-5" />
                                        </div>
                                        <div className="h-0.5 w-8 bg-rose-100 rounded-full" />
                                        <span className="text-rose-500 font-black text-xs uppercase tracking-[0.2em]">Explore</span>
                                    </div>
                                    <h1 className="font-serif text-3xl lg:text-5xl font-black text-gray-900 leading-tight">
                                        Advanced <span className="text-[#EF2F55]">Discovery</span>
                                    </h1>
                                    <p className="text-gray-500 font-medium mt-3 text-lg">Define your criteria to find the soul that matches yours.</p>
                                </div>
                                <Button 
                                    variant="outline" 
                                    onClick={resetFilters}
                                    className="rounded-2xl border-gray-100 text-gray-500 hover:bg-rose-50 hover:text-rose-600 font-bold gap-2 px-6 h-12"
                                >
                                    <RotateCcw className="w-4 h-4" /> Reset Filters
                                </Button>
                            </div>

                            <div className="flex flex-col xl:flex-row gap-12">
                                {/* --- Form Column --- */}
                                <div className="flex-1 space-y-12">

                                    <div className="grid grid-cols-1 md:grid-cols-2 gap-12">
                                        {/* Age Slider */}
                                        <div className="space-y-6 p-8 rounded-3xl bg-gray-50/50 border border-white shadow-inner">
                                            <div className="flex justify-between items-center">
                                                <div className="flex items-center gap-3">
                                                    <Users className="w-5 h-5 text-gray-400" />
                                                    <Label className="font-bold text-xl text-gray-900">Age Range</Label>
                                                </div>
                                                <div className="px-3 py-1 bg-white rounded-lg text-rose-500 font-black text-sm shadow-sm border border-rose-50">
                                                    {ageRange[0]} - {ageRange[1]}
                                                </div>
                                            </div>
                                            <Slider
                                                min={18}
                                                max={80}
                                                step={1}
                                                value={ageRange}
                                                onValueChange={setAgeRange}
                                                className="cursor-pointer py-4"
                                            />
                                        </div>

                                        {/* Height Slider */}
                                        <div className="space-y-6 p-8 rounded-3xl bg-gray-50/50 border border-white shadow-inner">
                                            <div className="flex justify-between items-center">
                                                <div className="flex items-center gap-3">
                                                    <Zap className="w-5 h-5 text-gray-400" />
                                                    <Label className="font-bold text-xl text-gray-900">Physique</Label>
                                                </div>
                                                <div className="px-3 py-1 bg-white rounded-lg text-rose-500 font-black text-sm shadow-sm border border-rose-50">
                                                    {formatHeight(heightRange[0])} - {formatHeight(heightRange[1])}
                                                </div>
                                            </div>
                                            <Slider
                                                min={48}
                                                max={96}
                                                step={1}
                                                value={heightRange}
                                                onValueChange={setHeightRange}
                                                className="cursor-pointer py-4"
                                            />
                                        </div>
                                    </div>

                                    <StaggerContainer className="space-y-12">
                                        {sections.map((sec, idx) => (
                                            <StaggerItem key={idx} className="space-y-6">
                                                <div className="flex items-center gap-3">
                                                    {sec.icon}
                                                    <Label className="font-bold text-xl text-gray-900">{sec.title}</Label>
                                                </div>
                                                <div className="flex flex-wrap gap-3">
                                                    {sec.list.map(item => (
                                                        <FilterChip
                                                            key={item}
                                                            label={item}
                                                            selected={sec.state === item}
                                                            onClick={() => sec.setState(sec.state === item ? null : item)}
                                                        />
                                                    ))}
                                                </div>
                                            </StaggerItem>
                                        ))}
                                    </StaggerContainer>

                                    {/* Career & Education */}
                                    <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                                        <StaggerItem className="space-y-4">
                                            <div className="flex items-center gap-3">
                                                <GraduationCap className="w-5 h-5 text-blue-500" />
                                                <Label className="font-bold text-xl text-gray-900">Career Paths</Label>
                                            </div>
                                            <Input
                                                placeholder="e.g. Masters, PhD, Doctorate"
                                                value={education}
                                                onChange={(e) => setEducation(e.target.value)}
                                                className="h-14 bg-gray-50/50 border-gray-100 rounded-2xl px-6 focus:ring-rose-500 focus:border-rose-500"
                                            />
                                        </StaggerItem>

                                        <StaggerItem className="space-y-4">
                                            <div className="flex items-center gap-3">
                                                <Briefcase className="w-5 h-5 text-amber-500" />
                                                <Label className="font-bold text-xl text-gray-900">Specialization</Label>
                                            </div>
                                            <Input
                                                placeholder="e.g. Software, Medical, Arts"
                                                value={occupation}
                                                onChange={(e) => setOccupation(e.target.value)}
                                                className="h-14 bg-gray-50/50 border-gray-100 rounded-2xl px-6 focus:ring-rose-500 focus:border-rose-500"
                                            />
                                        </StaggerItem>
                                    </div>

                                    {/* Action Button */}
                                    <div className="pt-8 group">
                                        <button
                                            onClick={handleSearch}
                                            className="w-full h-20 bg-gray-900 text-white rounded-[30px] font-black text-xl uppercase tracking-widest shadow-2xl hover:bg-black transition-all transform group-hover:-translate-y-1 active:scale-95 flex items-center justify-center gap-4 overflow-hidden relative"
                                        >
                                            <div className="absolute inset-0 bg-gradient-to-r from-rose-500 to-pink-500 translate-x-[-100%] group-hover:translate-x-0 transition-transform duration-500 ease-out z-0" />
                                            <span className="relative z-10 flex items-center gap-4">
                                                <Search className="w-6 h-6" /> Reveal My Matches
                                            </span>
                                        </button>
                                    </div>
                                </div>

                                {/* --- AD Column --- */}
                                <div className="w-full xl:w-[320px] shrink-0">
                                    <AdWidget />
                                </div>
                            </div>
                        </div>
                    </FadeIn>
                </div>
            </div>
        </div>
    );
}

export default function SearchPage() {
    return (
        <Suspense fallback={<div className="min-h-screen flex items-center justify-center">Loading...</div>}>
            <SearchContent />
        </Suspense>
    );
}
