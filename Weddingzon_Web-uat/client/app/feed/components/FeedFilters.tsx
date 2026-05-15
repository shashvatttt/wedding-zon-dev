import { SlidersHorizontal, Bell, Settings, User as UserIcon, X, Check, ChevronRight } from 'lucide-react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { useState, useRef, useEffect, useMemo } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { createPortal } from 'react-dom';
import useSWR from 'swr';
import api from '@/app/services/api';

interface FeedFiltersProps {
    user: any;
    onSettingsClick?: () => void;
}

// Fetcher for SWR
const fetcher = (url: string) => api.get(url).then(res => res.data.data);

export default function FeedFilters({ user, onSettingsClick }: FeedFiltersProps) {
    const router = useRouter();
    const searchParams = useSearchParams();
    const [isFilterOpen, setIsFilterOpen] = useState(false);
    const [mounted, setMounted] = useState(false);

    // Fetch Dynamic Filters from Admin Configuration
    const { data: dynamicFilters, error, isLoading } = useSWR('/filters', fetcher);

    // Initial Filter State
    const [filters, setFilters] = useState<Record<string, string>>({});

    // Core Sections that must always exist (ordered)
    const CORE_SECTIONS = ['Basic', 'Location', 'Religious', 'Education', 'Lifestyle', 'Family', 'Property', 'Other'];
    const [activeSection, setActiveSection] = useState('Basic');

    useEffect(() => {
        setMounted(true);
    }, []);

    // Sync State with URL Params
    useEffect(() => {
        const currentParams: Record<string, string> = {};
        searchParams.forEach((value, key) => {
            currentParams[key] = value;
        });
        setFilters(currentParams);

        if (searchParams.get('openFilters') === 'true') {
            setIsFilterOpen(true);
        }
    }, [searchParams]);

    // Compute Available Sections from Dynamic Data + Core
    const sections = useMemo(() => {
        if (!dynamicFilters) return CORE_SECTIONS;

        // Get all unique sections from data
        const dataSections = Array.from(new Set(dynamicFilters.map((f: any) => f.section)));

        // Merge with Core to maintain order, add any others at the end
        const merged = [...CORE_SECTIONS];
        dataSections.forEach((s: any) => {
            if (!merged.includes(s)) merged.push(s);
        });

        return merged;
    }, [dynamicFilters]);

    const handleApplyFilters = () => {
        const params = new URLSearchParams(searchParams.toString());

        // Update params
        Object.entries(filters).forEach(([key, value]) => {
            if (value && value !== 'Any') {
                params.set(key, value);
            } else {
                params.delete(key);
            }
        });

        // Implicitly reset to page 1 in Feed logic (cursor reset)
        router.push(`/feed?${params.toString()}`);
        setIsFilterOpen(false);
    };

    const handleClearFilters = () => {
        const params = new URLSearchParams(searchParams.toString());

        // Clear all keys found in dynamicFilters and our hardcoded map
        const allKeys = dynamicFilters ? dynamicFilters.map((f: any) => f.key) : [];
        const hardcodedKeys = ['minAge', 'maxAge', 'city', 'state', 'country', 'minHeight', 'maxHeight'];

        [...allKeys, ...hardcodedKeys].forEach(key => params.delete(key));

        setFilters({});
        router.push(`/feed?${params.toString()}`);
        // Keep modal open or close? Usually keep open to show cleared state
    };

    const activeFilterCount = Object.keys(filters).filter(k =>
        filters[k] && filters[k] !== 'Any' && !['sort', 'viewAs'].includes(k)
    ).length;

    // --- RENDER HELPERS ---

    const FilterOption = ({ label, value, checked, onChange, type = 'radio' }: any) => (
        <label className="flex items-center gap-3 cursor-pointer group py-2">
            <div className={`w-4 h-4 rounded-full border flex items-center justify-center transition-colors ${checked ? 'border-[#EF2F55]' : 'border-gray-500 bg-white group-hover:border-gray-400'}`}>
                {checked && <div className="w-2.5 h-2.5 rounded-full bg-[#EF2F55]" />}
            </div>
            <span className={`text-[16px] leading-[140%] ${checked ? 'text-gray-900 font-medium' : 'text-gray-600'}`}>
                {label}
            </span>
            <input
                type={type}
                className="hidden"
                checked={checked}
                onChange={() => onChange(value)}
            />
        </label>
    );

    const renderSectionContent = () => {
        if (isLoading) return <div className="p-8 text-gray-500">Loading filters...</div>;
        if (!dynamicFilters) return <div className="p-8 text-gray-500">No filters configuration found.</div>;

        // 1. Identify Filters for Current Section
        const sectionFilters = dynamicFilters.filter((f: any) => f.section === activeSection);

        // 2. Special Injection for Hardcoded Fields if in Basic/Location
        let content = [];

        if (activeSection === 'Basic') {
            content.push(
                <div key="age-custom" className="space-y-4 mb-8 pb-6 border-b border-gray-100">
                    <Label className="text-base font-semibold">Age Range</Label>
                    <div className="flex gap-4 items-center">
                        <div className="space-y-1.5">
                            <Label className="text-xs text-gray-500">Min</Label>
                            <Input
                                type="number"
                                placeholder="18"
                                value={filters.minAge || ''}
                                onChange={(e) => setFilters({ ...filters, minAge: e.target.value })}
                                className="w-24 border-gray-300 focus:border-[#EF2F55] focus:ring-[#EF2F55]"
                            />
                        </div>
                        <span className="text-gray-300 mt-5">-</span>
                        <div className="space-y-1.5">
                            <Label className="text-xs text-gray-500">Max</Label>
                            <Input
                                type="number"
                                placeholder="60"
                                value={filters.maxAge || ''}
                                onChange={(e) => setFilters({ ...filters, maxAge: e.target.value })}
                                className="w-24 border-gray-300 focus:border-[#EF2F55] focus:ring-[#EF2F55]"
                            />
                        </div>
                    </div>
                </div>
            );
        }

        if (activeSection === 'Location') {
            content.push(
                <div key="location-custom" className="space-y-4 mb-8 pb-6 border-b border-gray-100">
                    <Label className="text-base font-semibold">Location Search</Label>
                    <div className="grid gap-3">
                        <Input
                            placeholder="City"
                            value={filters.city || ''}
                            onChange={(e) => setFilters({ ...filters, city: e.target.value })}
                        />
                        <Input
                            placeholder="State"
                            value={filters.state || ''}
                            onChange={(e) => setFilters({ ...filters, state: e.target.value })}
                        />
                        <Input
                            placeholder="Country"
                            value={filters.country || ''}
                            onChange={(e) => setFilters({ ...filters, country: e.target.value })}
                        />
                    </div>
                </div>
            );
        }

        // 3. Render Dynamic Filters
        if (sectionFilters.length === 0 && content.length === 0) {
            return <div className="text-gray-400 italic">No filters available for this section.</div>;
        }

        return (
            <div className="space-y-8 animate-in fade-in duration-300">
                {content}
                {sectionFilters.map((f: any) => {
                    // Logic to render different types
                    return (
                        <div key={f._id} className="space-y-3">
                            <Label className="text-base font-semibold text-gray-800">{f.label}</Label>

                            {/* SELECT / RADIO */}
                            {(f.type === 'select' || f.type === 'radio') && (
                                <div className="space-y-1">
                                    {/* Default "Any" option */}
                                    <FilterOption
                                        label="Any"
                                        value="Any"
                                        checked={!filters[f.key] || filters[f.key] === 'Any'}
                                        onChange={() => {
                                            const newF = { ...filters };
                                            delete newF[f.key];
                                            setFilters(newF);
                                        }}
                                    />
                                    {f.options.map((opt: string) => (
                                        <FilterOption
                                            key={opt}
                                            label={opt}
                                            value={opt}
                                            checked={filters[f.key] === opt}
                                            onChange={(val: string) => setFilters({ ...filters, [f.key]: val })}
                                        />
                                    ))}
                                </div>
                            )}

                            {/* TEXT / NUMBER */}
                            {(f.type === 'text' || f.type === 'number') && (
                                <Input
                                    type={f.type === 'number' ? 'number' : 'text'}
                                    placeholder={`Enter ${f.label}`}
                                    value={filters[f.key] || ''}
                                    onChange={(e) => setFilters({ ...filters, [f.key]: e.target.value })}
                                    className="max-w-xs border-gray-300 focus:border-[#EF2F55] focus:ring-[#EF2F55]"
                                />
                            )}

                            {/* RANGE */}
                            {f.type === 'range' && (
                                <div className="space-y-4">
                                    <div className="flex gap-4 items-center">
                                        <div className="space-y-1.5 flex-1">
                                            <Label className="text-xs text-gray-500 uppercase font-bold tracking-wider">Min {f.label}</Label>
                                            <Input
                                                type="number"
                                                placeholder="Min"
                                                value={filters[`min${f.key.charAt(0).toUpperCase() + f.key.slice(1)}`] || ''}
                                                onChange={(e) => setFilters({ ...filters, [`min${f.key.charAt(0).toUpperCase() + f.key.slice(1)}`]: e.target.value })}
                                                className="border-gray-300 focus:border-[#EF2F55] focus:ring-[#EF2F55]"
                                            />
                                        </div>
                                        <span className="text-gray-300 mt-5">-</span>
                                        <div className="space-y-1.5 flex-1">
                                            <Label className="text-xs text-gray-500 uppercase font-bold tracking-wider">Max {f.label}</Label>
                                            <Input
                                                type="number"
                                                placeholder="Max"
                                                value={filters[`max${f.key.charAt(0).toUpperCase() + f.key.slice(1)}`] || ''}
                                                onChange={(e) => setFilters({ ...filters, [`max${f.key.charAt(0).toUpperCase() + f.key.slice(1)}`]: e.target.value })}
                                                className="border-gray-300 focus:border-[#EF2F55] focus:ring-[#EF2F55]"
                                            />
                                        </div>
                                    </div>
                                    {/* Quick helper for Land Area (optional) */}
                                    {f.key === 'landArea' && (
                                        <div className="flex flex-wrap gap-2 pt-1">
                                            {[1, 2, 5, 10].map(val => (
                                                <button
                                                    key={val}
                                                    onClick={() => setFilters({ ...filters, minLandArea: val.toString() })}
                                                    className="px-3 py-1 text-xs border border-gray-200 rounded-full hover:border-[#EF2F55] hover:text-[#EF2F55] transition-colors"
                                                >
                                                    {val}+ Acres
                                                </button>
                                            ))}
                                        </div>
                                    )}
                                </div>
                            )}
                        </div>
                    );
                })}
            </div>
        );
    };

    const filterBtnClass = "flex items-center gap-2 px-6 py-2.5 border border-[#FBC3CF] rounded-full hover:bg-pink-50 transition-all text-sm font-bold text-gray-900 whitespace-nowrap";

    return (
        <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between mb-6 md:mb-8 relative z-30">
            {/* Mobile View Header - Matches the requested design */}
            <div className="flex md:hidden items-center justify-between w-full gap-2 px-4">
                <button
                    className={`w-10 h-10 flex items-center justify-center border border-[#FBC3CF] rounded-full hover:bg-pink-50 transition-all text-gray-900 shrink-0 ${activeFilterCount > 0 ? 'bg-pink-50 border-pink-300' : ''}`}
                    onClick={() => setIsFilterOpen(true)}
                >
                    <SlidersHorizontal className="w-[18px] h-[18px] stroke-[2.5px]" />
                </button>

                <Link href="/feed" className="flex-1">
                    <button className="w-full py-2.5 border border-[#FBC3CF] rounded-full text-sm font-bold text-gray-900 bg-white hover:bg-pink-50 transition-all">
                        Matches
                    </button>
                </Link>

                <Link href="/map-search" className="flex-1">
                    <button className="w-full py-2.5 border border-[#FBC3CF] rounded-full text-sm font-bold text-gray-900 bg-white hover:bg-pink-50 transition-all">
                        Nearby
                    </button>
                </Link>

                <Button
                    variant="ghost"
                    size="icon"
                    className="bg-[#FFF0F4] hover:bg-[#FAD1D9] text-[#42445A] rounded-full w-10 h-10 shrink-0"
                    onClick={onSettingsClick}
                >
                    <Settings className="w-5 h-5 stroke-[2px]" />
                </Button>

                <Link href="/requests?tab=notifications">
                    <Button
                        variant="ghost"
                        size="icon"
                        className="bg-[#FFF0F4] hover:bg-[#FAD1D9] text-[#42445A] rounded-full w-10 h-10 shrink-0"
                    >
                        <Bell className="w-5 h-5 stroke-[2px]" />
                    </Button>
                </Link>
            </div>

            {/* Desktop View Header - Original Layout kept for md and up */}
            {/* Left Container: Quick Search/Filters */}
            <div className="hidden md:flex items-center gap-4 bg-white border border-gray-50 px-6 py-4 rounded-[32px] shadow-[0_8px_30px_rgba(0,0,0,0.04)] relative w-auto overflow-x-auto no-scrollbar">
                {/* Main Filters Button */}
                <button
                    className={`${filterBtnClass} shrink-0 ${activeFilterCount > 0 ? 'bg-pink-50 border-pink-300' : ''}`}
                    onClick={() => setIsFilterOpen(true)}
                >
                    <SlidersHorizontal className="w-[18px] h-[18px] stroke-[2.5px]" />
                    <span>Filters {activeFilterCount > 0 && `(${activeFilterCount})`}</span>
                </button>

                {/* MODAL OVERLAY (PORTAL) */}
                {isFilterOpen && mounted && createPortal(
                    <div className="fixed inset-0 z-[99999] flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in duration-200">
                        {/* Overlay Click Handler */}
                        <div className="absolute inset-0" onClick={() => setIsFilterOpen(false)}></div>

                        {/* Modal Content */}
                        <div
                            className="relative w-full max-w-[950px] h-[85vh] max-h-[750px] bg-white rounded-3xl shadow-2xl flex flex-col overflow-hidden animate-in zoom-in-95 duration-200"
                            onClick={(e) => e.stopPropagation()}
                        >
                            {/* HEADER */}
                            <div className="flex items-center justify-between px-8 py-6 border-b border-gray-100 bg-white z-10">
                                <h2 className="text-[28px] font-bold text-gray-900 tracking-tight">Filters</h2>
                                <div className="flex items-center gap-4">
                                    <button
                                        onClick={handleClearFilters}
                                        className="text-[#EF2F55] font-semibold text-[15px] hover:bg-pink-50 px-4 py-2 rounded-full transition-colors"
                                    >
                                        Reset All
                                    </button>
                                    <button
                                        onClick={() => setIsFilterOpen(false)}
                                        className="p-2 rounded-full bg-gray-100 hover:bg-gray-200 text-gray-600 transition-colors"
                                    >
                                        <X className="w-5 h-5" />
                                    </button>
                                </div>
                            </div>

                            {/* BODY (Split View) */}
                            <div className="flex flex-1 overflow-hidden">
                                {/* LEFT SIDEBAR - Hidden on mobile, improved mobile view needed for complex filters but keeping split for now or stack */}
                                <div className="hidden md:block w-[260px] bg-gray-50/50 border-r border-gray-100 h-full overflow-y-auto py-6 px-4 space-y-1">
                                    {sections.map(sec => (
                                        <button
                                            key={sec}
                                            onClick={() => setActiveSection(sec)}
                                            className={`w-full text-left px-5 py-3.5 rounded-xl text-[16px] font-medium transition-all flex items-center justify-between group
                                                ${activeSection === sec
                                                    ? 'bg-white shadow-sm text-[#EF2F55] ring-1 ring-gray-100'
                                                    : 'text-gray-600 hover:bg-gray-100 hover:text-gray-900'
                                                }`}
                                        >
                                            {sec}
                                            {activeSection === sec && <ChevronRight className="w-4 h-4 opacity-100" />}
                                            {activeSection !== sec && <ChevronRight className="w-4 h-4 opacity-0 group-hover:opacity-50 transition-opacity" />}
                                        </button>
                                    ))}
                                </div>
                                {/* Mobile Section Selector - Simple Dropdown or Scroll Row could go here */}

                                {/* RIGHT CONTENT */}
                                <div className="flex-1 h-full overflow-y-auto bg-white p-6 md:p-8">
                                    <div className="max-w-2xl">
                                        {/* Mobile Section Tabs (Visible only on mobile) */}
                                        <div className="md:hidden flex overflow-x-auto gap-2 mb-6 pb-2 no-scrollbar">
                                            {sections.map(sec => (
                                                <button
                                                    key={sec}
                                                    onClick={() => setActiveSection(sec)}
                                                    className={`px-4 py-2 rounded-full text-sm whitespace-nowrap border transition-colors ${activeSection === sec
                                                        ? 'bg-[#EF2F55] text-white border-[#EF2F55]'
                                                        : 'bg-white text-gray-600 border-gray-200'
                                                        }`}
                                                >
                                                    {sec}
                                                </button>
                                            ))}
                                        </div>

                                        {renderSectionContent()}
                                    </div>
                                </div>
                            </div>

                            {/* FOOTER */}
                            <div className="border-t border-gray-100 p-6 px-8 flex justify-between items-center bg-white z-10">
                                <div className="text-sm text-gray-500 font-medium hidden md:block">
                                    {activeFilterCount > 0 ? `${activeFilterCount} filters applied` : 'No filters applied'}
                                </div>
                                <div className="flex gap-3 w-full md:w-auto">
                                    <Button variant="outline" size="lg" onClick={() => setIsFilterOpen(false)} className="rounded-full px-8 border-gray-200 text-gray-700 hover:bg-gray-50 font-semibold flex-1 md:flex-none">
                                        Cancel
                                    </Button>
                                    <Button size="lg" onClick={handleApplyFilters} className="rounded-full bg-[#EF2F55] hover:bg-rose-600 px-10 text-lg font-bold shadow-lg shadow-pink-200 flex-1 md:flex-none">
                                        Apply
                                    </Button>
                                </div>
                            </div>
                        </div>
                    </div>,
                    document.body
                )}

                {/* Quick Filters - Added shrink-0 to prevent compression */}
                <Link href="/feed?verified=true" className="shrink-0">
                    <button className={`${filterBtnClass} ${searchParams.get('verified') === 'true' ? 'bg-pink-50 border-pink-300' : ''}`}>
                        Verified
                    </button>
                </Link>

                <Link href="/map-search" className="shrink-0">
                    <button className={filterBtnClass}>
                        Nearby
                    </button>
                </Link>

                <Link href="/feed?sort=newest" className="shrink-0">
                    <button className={`${filterBtnClass} ${searchParams.get('sort') === 'newest' ? 'bg-pink-50 border-pink-300' : ''}`}>
                        Just Joined
                    </button>
                </Link>
            </div>

            {/* Right Container: Account Actions (Desktop Only) */}
            <div className="hidden md:flex items-center gap-6 bg-white border border-gray-50 px-8 py-4 rounded-[32px] shadow-[0_8px_30px_rgba(0,0,0,0.04)] justify-start w-auto">
                <Button
                    variant="ghost"
                    size="icon"
                    className="bg-[#FCE4E9] hover:bg-[#FAD1D9] text-gray-800 rounded-full w-11 h-11 flex items-center justify-center shadow-sm transition-all active:scale-95"
                    onClick={onSettingsClick}
                >
                    <Settings className="w-5 h-5 stroke-[2px]" />
                </Button>

                <Link href="/requests?tab=notifications">
                    <Button
                        variant="ghost"
                        size="icon"
                        className="bg-[#FCE4E9] hover:bg-[#FAD1D9] text-gray-800 rounded-full w-11 h-11 flex items-center justify-center shadow-sm transition-all active:scale-95"
                    >
                        <Bell className="w-5 h-5 stroke-[2px]" />
                    </Button>
                </Link>

                {user?.username ? (
                    <Link href={`/${user.username}`}>
                        <Button
                            variant="ghost"
                            size="icon"
                            className="bg-[#FCE4E9] hover:bg-[#FAD1D9] text-gray-800 rounded-full w-11 h-11 flex items-center justify-center shadow-sm transition-all active:scale-95"
                        >
                            <UserIcon className="w-5 h-5 stroke-[2px]" />
                        </Button>
                    </Link>
                ) : (
                    <Button
                        variant="ghost"
                        size="icon"
                        className="bg-[#FCE4E9] hover:bg-[#FAD1D9] text-gray-800 rounded-full w-11 h-11 flex items-center justify-center shadow-sm transition-all active:scale-95"
                    >
                        <UserIcon className="w-5 h-5 stroke-[2px]" />
                    </Button>
                )}
            </div>
        </div>
    );
}
