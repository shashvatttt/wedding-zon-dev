import React from 'react';
import Image from 'next/image';
import { Heart, MessageCircle, X, MapPin, Briefcase, GraduationCap, Users } from 'lucide-react';

import { useRouter, useSearchParams } from 'next/navigation';

const BlurredMatrimonyFeed = () => {
    const router = useRouter();
    const searchParams = useSearchParams();
    const jobFilter = searchParams.get('job');

    // Expanded Mock Data
    const allProfiles = [
        {
            id: 1,
            name: "Prety Gupta",
            age: 28,
            height: "4ft 11in",
            location: "New Delhi",
            caste: "Bania-Rauniyar",
            education: "MBA/PGDM, LLB",
            profession: "Education Professional",
            professionCategory: "MNC Job",
            income: "Rs. 8-10 lakh p.a.",
            maritalStatus: "Never Married",
            active: "Active Today",
            image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1887&auto=format&fit=crop"
        },
        {
            id: 2,
            name: "Krity Oberoi",
            age: 28,
            height: "4ft 11in",
            location: "New Delhi",
            caste: "Bania-Rauniyar",
            education: "MBA/PGDM, LLB",
            profession: "Education Professional",
            professionCategory: "MNC Job",
            income: "Rs. 8-10 lakh p.a.",
            maritalStatus: "Never Married",
            active: "Active Today",
            image: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=1888&auto=format&fit=crop"
        },
        {
            id: 3,
            name: "Ivyey Gupta",
            age: 28,
            height: "4ft 11in",
            location: "New Delhi",
            caste: "Bania-Rauniyar",
            education: "MBA/PGDM, LLB",
            profession: "Education Professional",
            professionCategory: "Private Job",
            income: "Rs. 8-10 lakh p.a.",
            maritalStatus: "Never Married",
            active: "Active Today",
            image: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1964&auto=format&fit=crop"
        },
        {
            id: 4,
            name: "Rohan Sharma",
            age: 30,
            height: "5ft 10in",
            location: "Mumbai",
            caste: "Brahmin",
            education: "B.Tech, MBA",
            profession: "Software Engineer",
            professionCategory: "MNC Job",
            income: "Rs. 15-20 lakh p.a.",
            maritalStatus: "Never Married",
            active: "Active 2 hours ago",
            image: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1887&auto=format&fit=crop"
        },
        {
            id: 5,
            name: "Amit Patel",
            age: 32,
            height: "5ft 8in",
            location: "Ahmedabad",
            caste: "Patel",
            education: "B.Com",
            profession: "Business Owner",
            professionCategory: "Businessman",
            income: "Rs. 25-30 lakh p.a.",
            maritalStatus: "Never Married",
            active: "Active Yesterday",
            image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1887&auto=format&fit=crop"
        },
        {
            id: 6,
            name: "Suresh Kumar",
            age: 29,
            height: "5ft 9in",
            location: "Jaipur",
            caste: "Rajput",
            education: "M.A.",
            profession: "Government Teacher",
            professionCategory: "Government Job",
            income: "Rs. 6-8 lakh p.a.",
            maritalStatus: "Never Married",
            active: "Active Today",
            image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1887&auto=format&fit=crop"
        },
        {
            id: 7,
            name: "Vikram Singh",
            age: 31,
            height: "6ft 0in",
            location: "Chandigarh",
            caste: "Jat",
            education: "Hotel Management",
            profession: "Chef / Halwai",
            professionCategory: "Halwai",
            income: "Rs. 5-7 lakh p.a.",
            maritalStatus: "Never Married",
            active: "Active 5 hours ago",
            image: "https://images.unsplash.com/photo-1583394838336-acd977736f90?q=80&w=1884&auto=format&fit=crop"
        },
        {
            id: 8,
            name: "Anjali Mehta",
            age: 27,
            height: "5ft 5in",
            location: "Pune",
            caste: "Jain",
            education: "B.Arch",
            profession: "Architect",
            professionCategory: "Private Job",
            income: "Rs. 10-12 lakh p.a.",
            maritalStatus: "Never Married",
            active: "Active Today",
            image: "https://images.unsplash.com/photo-1531123897727-8f129e1688ce?q=80&w=1887&auto=format&fit=crop"
        },
        {
            id: 9,
            name: "Rahul Verma",
            age: 29,
            height: "5ft 11in",
            location: "Toronto",
            caste: "Punjabi",
            education: "MS",
            profession: "Data Scientist",
            professionCategory: "Abroad",
            income: "$80k - $100k p.a.",
            maritalStatus: "Never Married",
            active: "Active Today",
            image: "https://images.unsplash.com/photo-1480455624313-e29b44bbfde1?q=80&w=1887&auto=format&fit=crop"
        }
    ];

    // Filter Logic
    const profiles = jobFilter
        ? allProfiles.filter(p => p.professionCategory === jobFilter || p.profession.toLowerCase().includes(jobFilter.toLowerCase()))
        : allProfiles;


    const filters = [
        "Type of Matches", "Based Out Of", "Posted By", "Activity On Site",
        "Religion", "Caste", "Subcaste", "Age", "Mother Tongue", "Country",
        "Income", "Employed In", "Education", "Drinking", "Smoking",
        "Eating Habits", "Maritial Status", "Family types", "Siblings",
        "Property Types", "Land Area"
    ];

    const services = [
        "Photographers", 
        "Makeup", 
        "Baraat Band", 
        "Ghodi wale"
    ];

    const handleGlobalClick = () => {
        router.push('/login');
    };

    return (
        <div
            className="min-h-screen bg-white font-sans cursor-pointer relative"
            onClick={handleGlobalClick}
        >
            {/* REMOVED Full Page Blur Overlay - Content is now clear, but global click redirects */}

            {/* Custom Header for Feed Page as per design */}
            <div className="bg-white h-[72px] flex items-center justify-between px-8 shadow-sm relative z-50 border-b border-gray-100">
                <div className="flex items-center gap-2">
                    <div className="relative w-52 h-12">
                        <Image
                            src="/weddingzon-logo.png"
                            alt="WeddingZon"
                            fill
                            className="object-contain object-left"
                            priority
                        />
                    </div>
                </div>

                {/* Center Nav */}
                <div className="hidden md:flex items-center gap-8 absolute left-1/2 -translate-x-1/2">
                    <span className="text-gray-900 font-medium hover:text-[#EF2F55] transition-colors">Home</span>
                    <span className="text-[#EF2F55] font-semibold underline underline-offset-8 decoration-2">Matrimony</span>
                    <span className="text-gray-900 font-medium hover:text-[#EF2F55] transition-colors">Services</span>
                    <span className="text-gray-900 font-medium hover:text-[#EF2F55] transition-colors">Shopping</span>
                </div>

                {/* Right Action */}
                <button className="bg-white border border-gray-200 text-gray-700 px-4 py-2 rounded-full font-medium text-sm flex items-center gap-2 hover:bg-gray-50 transition-colors shadow-sm">
                    Get the App
                    <span className="text-lg">📱</span>
                </button>
            </div>

            <div className="container mx-auto px-4 py-8 flex gap-6 justify-center">

                {/* Left Sidebar - Filters */}
                <div className="w-[280px] hidden lg:block">
                    {/* User Profile Summary Card */}
                    <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 mb-6 flex items-center gap-4">
                        <div className="w-12 h-12 rounded-full bg-gray-200 overflow-hidden relative">
                            {/* Placeholder for current user avatar if available */}
                            <Image
                                src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1887&auto=format&fit=crop"
                                alt="User"
                                fill
                                className="object-cover"
                            />
                        </div>
                        <div>
                            <h4 className="font-bold text-gray-900 leading-tight">Arsh Prabhat</h4>
                            <p className="text-xs text-gray-500">Delhi, India</p>
                            <div className="w-full bg-gray-100 h-1.5 rounded-full mt-2 overflow-hidden">
                                <div className="bg-[#EF2F55] h-full w-[60%]"></div>
                            </div>
                        </div>
                    </div>

                    {/* Menu Links */}
                    <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-2">
                        {[
                            'Complete Your Profile', 
                            'Matches', 
                            'Search', 
                            'Chats', 
                            'Upgrade'
                        ].map((item) => (
                            <div key={item} className="flex justify-between items-center p-4 hover:bg-rose-50 rounded-xl cursor-pointer transition-colors group">
                                <span className="font-medium text-gray-700 group-hover:text-gray-900">{item}</span>
                                <span className="text-gray-400">›</span>
                            </div>
                        ))}
                    </div>

                    {/* Upgrade Card */}
                    <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 mt-6 text-center">
                        <h3 className="text-lg font-medium text-gray-900 mb-1">
                            Upgrade to{' '}
                            <span className="text-[#EF2F55] font-bold">Premium</span>
                        </h3>
                        <div className="h-32 my-4 relative">
                            {/* Illustration placeholder */}
                        </div>
                        <button className="bg-[#EF2F55] text-white w-full py-3 rounded-md font-bold text-sm hover:bg-rose-600 transition-colors shadow-md">
                            Upgrade Now
                        </button>
                    </div>
                </div>

                {/* Center - Feed */}
                <div className="flex-1 max-w-[800px]">
                    {/* Top Quick Filters */}
                    <div className="flex gap-4 mb-6">
                        <div className="flex bg-white rounded-full shadow-sm border border-gray-100 px-2 py-1.5 gap-2">
                            <button className="px-6 py-2 rounded-full border border-gray-200 bg-white text-gray-700 text-sm font-semibold hover:bg-gray-50 flex items-center gap-2">
                                <span className="text-gray-400">⚡</span> Filters
                            </button>
                            <button className="px-6 py-2 rounded-full border border-gray-200 bg-white text-gray-700 text-sm font-semibold hover:bg-gray-50">Verified</button>
                            <button className="px-6 py-2 rounded-full border border-gray-200 bg-white text-gray-700 text-sm font-semibold hover:bg-gray-50">Nearby</button>
                            <button className="px-6 py-2 rounded-full border border-gray-200 bg-white text-gray-700 text-sm font-semibold hover:bg-gray-50">Just Joined</button>
                        </div>
                    </div>

                    {/* Profiles */}
                    <div className="flex flex-col gap-6">
                        {profiles.length > 0 ? (
                            profiles.map((profile) => (
                                <div key={profile.id} className="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 relative overflow-hidden flex gap-6">
                                    {/* Image Section */}
                                    <div className="relative w-[280px] h-[200px] flex-shrink-0 rounded-xl overflow-hidden">
                                        <Image
                                            src={profile.image}
                                            alt={profile.name}
                                            fill
                                            className="object-cover blur-md scale-110" // BLUR APPLIED HERE
                                        />
                                        <div className="absolute inset-0 bg-black/5"></div>
                                    </div>

                                    {/* Details Section */}
                                    <div className="flex-1 py-1">
                                        <div className="flex justify-between items-start mb-1">
                                            <h2 className="text-2xl font-bold text-gray-900">
                                                {profile.name}, {profile.age} <span className="text-[#EF2F55] text-sm font-normal italic ml-2">{profile.active}</span>
                                            </h2>
                                        </div>

                                        <p className="text-gray-500 text-sm mb-3">
                                            {profile.height} • {profile.location} • {profile.caste}
                                        </p>

                                        <div className="space-y-1 mb-5">
                                            <p className="text-gray-700 text-sm flex items-center gap-2">
                                                <Briefcase size={16} className="text-gray-400" />
                                                {profile.profession} • {profile.income}
                                            </p>
                                            <p className="text-gray-700 text-sm flex items-center gap-2">
                                                <GraduationCap size={16} className="text-gray-400" />
                                                {profile.education}
                                                <span className="mx-2 text-gray-300">|</span>
                                                <Users size={16} className="text-gray-400" />
                                                {profile.maritalStatus}
                                            </p>
                                        </div>

                                        {/* Actions */}
                                        <div className="flex gap-3 mt-auto">
                                            <button className="flex items-center gap-2 px-6 py-2 rounded-full bg-[#FFE4E6] text-gray-900 font-semibold hover:bg-[#FDDCDF] transition-colors">
                                                <Heart size={18} className="text-[#EF2F55]" />
                                                Like
                                            </button>
                                            <button className="flex items-center gap-2 px-6 py-2 rounded-full bg-[#F3F4F6] text-gray-700 font-semibold hover:bg-gray-200 transition-colors">
                                                <X size={18} />
                                                Ignore
                                            </button>
                                            <button className="flex items-center gap-2 px-6 py-2 rounded-full bg-[#F3F4F6] text-gray-700 font-semibold hover:bg-gray-200 transition-colors">
                                                <MessageCircle size={18} />
                                                Chat
                                            </button>
                                            <button className="ml-auto bg-[#EF2F55] text-white px-8 py-2.5 rounded-md font-bold text-sm hover:bg-rose-600 transition-colors shadow-md shadow-rose-200">
                                                View Profile
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            ))
                        ) : (
                            <div className="bg-white p-12 rounded-2xl text-center shadow-sm border border-gray-100">
                                <p className="text-gray-500 text-lg">
                                    No profiles found matching "{jobFilter || ''}"
                                </p>
                                <p className="text-gray-400 mt-2">Try a different category</p>
                            </div>
                        )}
                    </div>
                </div>

                {/* Right Sidebar - Services */}
                <div className="w-[240px] hidden xl:block">
                    <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
                        <h3 className="text-lg font-bold text-gray-900 mb-6">Our Services</h3>
                        <div className="flex flex-col gap-6">
                            {services.map((service) => (
                                <div key={service} className="flex justify-between items-center cursor-pointer group hover:opacity-80">
                                    <span className="text-gray-700 font-medium text-sm">{service}</span>
                                    <span className="text-gray-400 text-lg">›</span>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>

            </div>
        </div>
    );
};

export default BlurredMatrimonyFeed;
