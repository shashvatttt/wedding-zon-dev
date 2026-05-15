'use client';

import React, { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/app/context/AuthContext';
import api from '@/app/services/api';
import { Loader2, ArrowLeft, Search, MessageCircle, Phone, Mail, Calendar, User, Filter, Trash2 } from 'lucide-react';
import Image from 'next/image';
import { Button } from '@/components/ui/button';
import FeedHeader from '@/app/feed/components/FeedHeader';
import FeedSidebar from '@/app/feed/components/FeedSidebar';

export default function VendorInquiriesPage() {
    const { user, loading: authLoading } = useAuth();
    const router = useRouter();
    const [inquiries, setInquiries] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [filterStatus, setFilterStatus] = useState('all');

    useEffect(() => {
        if (!authLoading && (!user || user.role !== 'vendor')) {
            router.push('/');
            return;
        }
        fetchInquiries();
    }, [user, authLoading]);

    const fetchInquiries = async () => {
        try {
            const res = await api.get('/vendor-features/my-inquiries');
            if (res.data.success) {
                setInquiries(res.data.data);
            }
        } catch (error) {
            console.error('Failed to fetch inquiries', error);
        } finally {
            setLoading(false);
        }
    };

    const filteredInquiries = inquiries.filter(inquiry => {
        const matchesSearch = 
            inquiry.name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
            inquiry.email?.toLowerCase().includes(searchQuery.toLowerCase()) ||
            inquiry.phone?.includes(searchQuery) ||
            inquiry.details?.toLowerCase().includes(searchQuery.toLowerCase());
        
        const matchesStatus = filterStatus === 'all' || inquiry.status === filterStatus;
        
        return matchesSearch && matchesStatus;
    });

    if (authLoading || loading) {
        return (
            <div className="min-h-screen pt-24 flex justify-center bg-rose-50/30">
                <Loader2 className="animate-spin w-8 h-8 text-pink-600" />
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-[#FFF9FA] font-sans overflow-x-hidden">
            <FeedHeader />
            
            <div className="pt-[100px] pb-12 px-4 max-w-[1440px] mx-auto grid grid-cols-1 lg:grid-cols-[250px_1fr] gap-8">
                {/* Left Sidebar */}
                <div className="hidden lg:block">
                    <div className="sticky top-[100px]">
                        <FeedSidebar user={user} activePage="chats" />
                    </div>
                </div>

                {/* Main Content */}
                <div className="w-full max-w-[1000px]">
                    <div className="flex flex-col gap-6">
                        {/* Page Header */}
                        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                            <div>
                                <h1 className="text-3xl font-black text-gray-900 tracking-tight flex items-center gap-3">
                                    <MessageCircle className="w-8 h-8 text-[#EF2F55]" />
                                    Client Inquiries
                                </h1>
                                <p className="text-gray-500 font-medium mt-1">Manage all leads captured from your "Get Quote" form</p>
                            </div>
                            <Button 
                                onClick={() => router.push('/vendor/dashboard')}
                                variant="outline"
                                className="w-fit border-gray-200 hover:bg-gray-50 rounded-xl font-bold"
                            >
                                <ArrowLeft className="w-4 h-4 mr-2" />
                                Back to Dashboard
                            </Button>
                        </div>

                        {/* Search & Filters */}
                        <div className="bg-white p-4 rounded-[32px] shadow-xl shadow-rose-100/20 border border-rose-50 flex flex-col md:flex-row gap-4 items-center">
                            <div className="relative flex-1 w-full">
                                <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                                <input 
                                    type="text" 
                                    placeholder="Search by name, email, phone or details..."
                                    value={searchQuery}
                                    onChange={(e) => setSearchQuery(e.target.value)}
                                    className="w-full pl-12 pr-4 py-3 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-[#EF2F55]/20 focus:border-[#EF2F55] transition-all font-medium"
                                />
                            </div>
                            <div className="flex gap-2 w-full md:w-auto">
                                <select 
                                    value={filterStatus}
                                    onChange={(e) => setFilterStatus(e.target.value)}
                                    className="flex-1 md:w-40 px-4 py-3 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none font-bold text-sm text-gray-700 appearance-none cursor-pointer"
                                >
                                    <option value="all">All Status</option>
                                    <option value="pending">New/Pending</option>
                                    <option value="contacted">Contacted</option>
                                    <option value="archived">Archived</option>
                                </select>
                            </div>
                        </div>

                        {/* Inquiries List */}
                        {filteredInquiries.length === 0 ? (
                            <div className="bg-white rounded-[40px] p-20 shadow-xl shadow-rose-100/20 border border-rose-50 text-center">
                                <div className="w-24 h-24 bg-rose-50 rounded-full flex items-center justify-center mx-auto mb-6">
                                    <MessageCircle className="w-12 h-12 text-[#EF2F55]" />
                                </div>
                                <h3 className="text-2xl font-black text-gray-900 mb-2">No inquiries found</h3>
                                <p className="text-gray-500 font-medium max-w-sm mx-auto leading-relaxed">
                                    {searchQuery ? "No results match your search criteria." : "When potential clients fill out your 'Get Quote' form, they will appear here!"}
                                </p>
                                {searchQuery && (
                                    <Button 
                                        onClick={() => setSearchQuery('')}
                                        className="mt-6 bg-[#EF2F55] hover:bg-rose-700 text-white rounded-xl px-8"
                                    >
                                        Clear Search
                                    </Button>
                                )}
                            </div>
                        ) : (
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                {filteredInquiries.map((inquiry) => (
                                    <div key={inquiry._id} className="bg-white rounded-[40px] p-8 shadow-xl shadow-rose-100/20 border border-rose-50 hover:border-[#EF2F55]/20 transition-all group relative overflow-hidden flex flex-col h-full">
                                        {inquiry.status === 'pending' && (
                                            <div className="absolute top-0 right-0 w-24 h-24 overflow-hidden pointer-events-none">
                                                <div className="absolute top-4 -right-8 w-32 h-6 bg-[#EF2F55] text-white text-[11px] font-black uppercase tracking-widest flex items-center justify-center rotate-45 shadow-lg">
                                                    New Lead
                                                </div>
                                            </div>
                                        )}
                                        
                                        <div className="flex items-center gap-4 mb-6">
                                            <div className="w-14 h-14 bg-rose-50 rounded-2xl flex items-center justify-center text-[#EF2F55] text-xl font-black border border-rose-100">
                                                {inquiry.name ? inquiry.name.charAt(0).toUpperCase() : inquiry.email.charAt(0).toUpperCase()}
                                            </div>
                                            <div className="flex-1 min-w-0">
                                                <h4 className="text-lg font-black text-gray-900 truncate">
                                                    {inquiry.name || inquiry.email.split('@')[0]}
                                                </h4>
                                                <p className="text-xs text-gray-400 font-black uppercase tracking-widest flex items-center gap-2">
                                                    <Calendar className="w-3 h-3" />
                                                    {new Date(inquiry.created_at).toLocaleDateString(undefined, { month: 'long', day: 'numeric', year: 'numeric' })}
                                                </p>
                                            </div>
                                        </div>

                                        <div className="space-y-4 flex-1">
                                            <div className="flex items-center gap-4 p-4 bg-gray-50/50 rounded-2xl border border-gray-100 transition-colors group-hover:bg-rose-50/50 group-hover:border-rose-100">
                                                <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-sm">
                                                    <Mail className="w-4 h-4 text-[#EF2F55]" />
                                                </div>
                                                <div className="flex-1 min-w-0">
                                                    <p className="text-[10px] text-gray-400 font-black uppercase tracking-widest">Email Address</p>
                                                    <p className="text-sm font-bold text-gray-900 truncate">{inquiry.email}</p>
                                                </div>
                                            </div>

                                            <div className="flex items-center gap-4 p-4 bg-gray-50/50 rounded-2xl border border-gray-100 transition-colors group-hover:bg-rose-50/50 group-hover:border-rose-100">
                                                <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-sm">
                                                    <Phone className="w-4 h-4 text-[#EF2F55]" />
                                                </div>
                                                <div className="flex-1 min-w-0">
                                                    <p className="text-[10px] text-gray-400 font-black uppercase tracking-widest">Phone Number</p>
                                                    <p className="text-sm font-bold text-gray-900">{inquiry.phone}</p>
                                                </div>
                                            </div>

                                            <div className="p-5 bg-rose-50/30 rounded-2xl border border-rose-100 min-h-[120px]">
                                                <p className="text-[10px] text-[#EF2F55] font-black uppercase tracking-widest mb-2 flex items-center gap-2">
                                                    <MessageCircle className="w-3 h-3" />
                                                    Inquiry Details
                                                </p>
                                                <p className="text-sm text-gray-700 font-medium leading-relaxed italic">
                                                    "{inquiry.details}"
                                                </p>
                                            </div>
                                        </div>

                                        <div className="flex items-center gap-3 mt-8">
                                            <button 
                                                onClick={() => window.open(`mailto:${inquiry.email}`)}
                                                className="flex-1 bg-white hover:bg-rose-50 text-[#EF2F55] border-2 border-rose-100 py-4 rounded-2xl text-[11px] font-black uppercase tracking-tighter transition-all flex items-center justify-center gap-2 hover:shadow-lg hover:shadow-rose-100"
                                            >
                                                <Mail className="w-4 h-4" />
                                                Email Client
                                            </button>
                                            <button 
                                                onClick={() => window.open(`tel:${inquiry.phone}`)}
                                                className="flex-1 bg-[#EF2F55] hover:bg-rose-700 text-white py-4 rounded-2xl text-[11px] font-black uppercase tracking-tighter shadow-xl shadow-pink-100 transition-all active:scale-95 flex items-center justify-center gap-2"
                                            >
                                                <Phone className="w-4 h-4" />
                                                Call Now
                                            </button>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}
