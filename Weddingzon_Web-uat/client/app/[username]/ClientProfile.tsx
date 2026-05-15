/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-unused-vars */
'use client';

import { Suspense, useEffect, useState, use, useCallback } from 'react';
import { AnimatePresence } from 'framer-motion';
import api from '../services/api';
import { useRouter, useSearchParams } from 'next/navigation';
// Removed useTransliteration

import PhotoUploadGrid from '../components/PhotoUploadGrid';
import ProfileHeader from './components/ProfileHeader';
import ProfileTabs from './components/ProfileTabs';
import ProfileCompletionCard from './components/ProfileCompletionCard';
import ProfileSection from './components/ProfileSection';
import PartnerPreferencesView from './components/PartnerPreferencesView';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { StaggerContainer, StaggerItem } from '@/components/animations/StaggerContainer';
import { FadeIn } from '@/components/animations/FadeIn';
import { SlideIn } from '@/components/animations/SlideIn';
import Image from 'next/image';
import Link from 'next/link';
import VendorReviews from './components/VendorReviews';
import VendorGallery from './components/VendorGallery';
import VendorRequestModal from './components/VendorRequestModal';
import InquiryForm from './components/InquiryForm';
import VendorCard from '@/components/VendorCard';
import MessageVendorSection from './components/MessageVendorSection';
import { motion } from 'framer-motion';
import {
    Heart, ArrowLeft, Briefcase, MapPin, Users, User, Camera,
    Lock, Star, Edit, Check, MessageCircle, X, Map, Eye,
    Share2, MoreVertical, Flag, Ban, Home, Ruler, Church,
    Languages, IndianRupee, GraduationCap, Calendar,
    Stethoscope, Clock, Utensils, Cigarette, GlassWater,
    UserCircle, Globe, ImagePlus, ExternalLink, Navigation
} from 'lucide-react';
import ChatWindow from '../components/chat/ChatWindow';
import MediaViewer from '../components/MediaViewer';
import ShareDialog from '../components/ShareDialog';
import { ToastProvider, useToast } from '../contexts/ToastContext';
import LanguageSwitcher from '@/components/LanguageSwitcher';
import ConfirmationModal from '@/components/ConfirmationModal';
import MatchPreferencesModal from '../franchise/components/MatchPreferencesModal';
import VendorCalendar from '../components/VendorCalendar';

// Helper for unwrapping params
function ProfileContent({ params }: { params: Promise<{ username: string }> }) {
    const { username } = use(params);

    const router = useRouter();
    const searchParams = useSearchParams();
    const tabParam = searchParams.get('tab');
    const { addToast } = useToast();
    // Removed useTransliteration

    const translateData = (category: string, value: string | undefined) => {
        return value || '';
    };

    const [confirmModal, setConfirmModal] = useState({
        isOpen: false,
        title: '',
        message: '',
        confirmText: '',
        isDangerous: false,
        onConfirm: () => { }
    });

    const [isPreferencesModalOpen, setIsPreferencesModalOpen] = useState(false);
    const [profile, setProfile] = useState<any>(null);
    const [currentUser, setCurrentUser] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const [isEditing, setIsEditing] = useState(false);
    const [requestModal, setRequestModal] = useState<{
        isOpen: boolean;
        type: 'quote' | 'availability';
    }>({ isOpen: false, type: 'quote' });

    const [formData, setFormData] = useState({
        first_name: '',
        last_name: '',
        bio: '',
        dob: '',
    });

    const [activeTab, setActiveTab] = useState<'profile' | 'preferences' | 'reviews'>(
        tabParam === 'preferences' ? 'preferences' : (profile?.role === 'vendor' ? 'reviews' : 'profile')
    );

    // Update tab if URL param changes
    useEffect(() => {
        if (tabParam === 'preferences') {
            setActiveTab('preferences');
        } else if (tabParam === 'reviews' && profile?.role === 'vendor') {
            setActiveTab('reviews');
        } else if (tabParam === 'profile') {
            setActiveTab('profile');
        } else if (!tabParam && profile?.role === 'vendor' && activeTab === 'profile') {
            // Default to reviews for vendors if no tab param is specified
            setActiveTab('reviews');
        }
    }, [tabParam, profile?.role, activeTab]);

    // Photo State
    const [photos, setPhotos] = useState<any[]>([]);

    // Media Viewer
    const [isViewerOpen, setIsViewerOpen] = useState(false);
    const [viewerIndex, setViewerIndex] = useState(0);

    // Share State
    const [isShareOpen, setIsShareOpen] = useState(false);

    // Chat State
    const [isChatOpen, setIsChatOpen] = useState(false);

    // Menu & Report State
    const [isMenuOpen, setIsMenuOpen] = useState(false);
    const [isReportModalOpen, setIsReportModalOpen] = useState(false);
    const [reportReason, setReportReason] = useState('spam');
    const [reportDesc, setReportDesc] = useState('');

    const handleBlock = () => {
        setConfirmModal({
            isOpen: true,
            title: `Block ${profile.first_name}?`,
            message: `Are you sure you want to block ${profile.first_name}? This will prevent further communication.`,
            confirmText: "Block User",
            isDangerous: true,
            onConfirm: async () => {
                try {
                    await api.post('/users/block', { targetUsername: profile.username });
                    addToast('User blocked successfully', 'success');
                    router.push('/feed');
                } catch (error: any) {
                    addToast(error.response?.data?.message || 'Failed to block user', 'error');
                }
            }
        });
    };

    const submitReport = async () => {
        try {
            await api.post('/users/report', {
                targetUsername: profile.username,
                reason: reportReason,
                description: reportDesc
            });
            setIsReportModalOpen(false);
            setReportDesc('');
            addToast('Report submitted successfully', 'success');
        } catch (error: any) {
            addToast(error.response?.data?.message || 'Failed to submit report', 'error');
        }
    };

    const [isConnecting, setIsConnecting] = useState(false);

    const handleConnectionAction = async () => {
        if (friendStatus === 'accepted') {
            setIsChatOpen(true);
            return;
        }
        if (friendStatus === 'pending') {
            handleCancelRequest('connection');
            return;
        }
        setIsConnecting(true);
        try {
            await handleConnect();
        } finally {
            setIsConnecting(false);
        }
    };

    const updateProfilePhotoLocal = (url: string) => {
        setProfile((prev: any) => ({ ...prev, profilePhoto: url }));
    };

    const fetchData = useCallback(async () => {
        try {
            // Fetch current user first to check ownership
            try {
                const meRes = await api.get('/auth/me');
                setCurrentUser(meRes.data);
            } catch { /* Guest or not logged in */ }

            // Fetch Profile
            const res = await api.get(`/users/${username}`);
            setProfile(res.data.success ? res.data.data : res.data);

            // Record View (if not me)
            const finalProfile = res.data.success ? res.data.data : res.data;
            if (finalProfile && finalProfile._id) {
                api.post(`/users/view/${finalProfile._id}`)
                    .catch(err => console.error('Record View Error', err.message));
            }

            const userData = res.data.success ? res.data.data : res.data;
            setFormData({
                first_name: userData.first_name || '',
                last_name: userData.last_name || '',
                bio: userData.bio || '',
                dob: userData.dob ? userData.dob.split('T')[0] : '',
            });
            if (userData.photos) {
                setPhotos(userData.photos);
            }
        } catch (error: any) {
            if (error.response?.status === 404) {
                console.warn('Profile not found:', username);
                setProfile(null);
            } else {
                console.error('Failed to fetch profile', error);
            }
        } finally {
            setLoading(false);
        }
    }, [username]);

    useEffect(() => {
        if (username) fetchData();
    }, [username, fetchData]);

    const isOwner = currentUser && profile && (currentUser.username === profile.username);

    const [connectionStatus, setConnectionStatus] = useState<'none' | 'pending' | 'accepted' | 'rejected' | 'granted'>('none');
    const [friendStatus, setFriendStatus] = useState<'none' | 'pending' | 'accepted' | 'rejected'>('none');
    const [detailsStatus, setDetailsStatus] = useState<'none' | 'pending' | 'granted' | 'rejected'>('none');

    // Enhanced Check Status
    useEffect(() => {
        const checkStatus = async () => {
            if (currentUser && profile && !isOwner) {
                try {
                    const res = await api.get(`/connections/status/${profile.username}`);
                    setConnectionStatus(res.data.status || 'none');
                    setFriendStatus(res.data.friendStatus || 'none');
                    setDetailsStatus(res.data.detailsStatus || 'none');
                } catch (err) { console.error(err); }
            }
        };
        checkStatus();
    }, [currentUser, profile, isOwner]);

    // DEBUG: Trace parent status
    console.log('ClientProfile Status:', { friendStatus, connectionStatus });

    const handleRequestAccess = () => {
        setConfirmModal({
            isOpen: true,
            title: "Request Photo Access",
            message: "Request access to view private photos. The user will be notified.",
            confirmText: "Send Request",
            isDangerous: false,
            onConfirm: async () => {
                try {
                    await api.post('/connections/request-photo-access', { targetUsername: profile.username });
                    setConnectionStatus('pending');
                    addToast('Photo access request sent', 'success');
                } catch (error: any) {
                    addToast(error.response?.data?.message || 'Failed to send request', 'error');
                }
            }
        });
    };

    const handleRequestDetails = () => {
        setConfirmModal({
            isOpen: true,
            title: "Request Details access",
            message: "Request access to view full profile details. The user will be notified.",
            confirmText: "Send Request",
            isDangerous: false,
            onConfirm: async () => {
                try {
                    await api.post('/connections/request-details-access', { targetUsername: profile.username });
                    setDetailsStatus('pending');
                    addToast('Details access request sent', 'success');
                } catch (error: any) {
                    addToast(error.response?.data?.message || 'Failed to send request', 'error');
                }
            }
        });
    };

    const handleConnect = async () => {
        if (friendStatus !== 'none') return;
        try {
            await api.post('/connections/send', { targetUsername: profile.username });
            setFriendStatus('pending');
            addToast('Connection request sent', 'success');
        } catch (error: any) {
            addToast(error.response?.data?.message || 'Failed to send request', 'error');
        }
    };

    const handleDisconnect = async () => {
        setConfirmModal({
            isOpen: true,
            title: "Disconnect",
            message: "Are you sure you want to disconnect? You will no longer be friends.",
            confirmText: "Disconnect",
            isDangerous: true,
            onConfirm: async () => {
                try {
                    await api.delete('/connections/delete', { data: { targetUsername: profile.username } });
                    setFriendStatus('none');
                    addToast('Disconnected successfully', 'info');
                } catch (error: any) {
                    addToast(error.response?.data?.message || 'Failed to disconnect', 'error');
                }
            }
        });
    };

    const handleCancelRequest = (type: 'connection' | 'photo' | 'details') => {
        setConfirmModal({
            isOpen: true,
            title: "Cancel Request",
            message: "Are you sure you want to cancel this request?",
            confirmText: "Cancel Request",
            isDangerous: true,
            onConfirm: async () => {
                try {
                    await api.post('/connections/cancel', { targetUsername: profile.username, type });
                    if (type === 'connection') setFriendStatus('none');
                    if (type === 'photo') setConnectionStatus('none');
                    if (type === 'details') setDetailsStatus('none');
                    addToast('Request cancelled', 'info');
                } catch (error: any) {
                    addToast(error.response?.data?.message || 'Failed to cancel request', 'error');
                }
            }
        });
    };

    // Process photos to enforce restriction if not connected
    const displayedPhotos = photos.map((p, idx) => {
        // If owner, never restricted
        if (isOwner) return { ...p, restricted: false };
        // VENDOR Logic: Vendors photos are never restricted
        if (profile?.role === 'vendor') return { ...p, restricted: false };

        // If already restricted by backend, keep it
        if (p.restricted) return p;

        // Unlock if:
        // 1. Friend Status is 'accepted' (meaning connected friend)
        // 2. OR Photo Access Status is 'granted' (specific photo unlock)
        const isUnlocked = friendStatus === 'accepted' || connectionStatus === 'granted';

        // If not unlocked, restrict everything except profile photo
        if (!isUnlocked && !p.isProfile) {
            return { ...p, restricted: true }; // Keep URL for blur effect
        }
        return p;
    });

    const onPhotoClick = (index: number, restricted?: boolean) => {
        if (!restricted) {
            setViewerIndex(index);
            setIsViewerOpen(true);
        }
    };

    if (loading) return <div className="flex justify-center items-center h-screen animate-pulse">Loading Profile...</div>;
    if (!profile) return <div className="flex justify-center items-center h-screen">Profile Not Found</div>;

    // DETAILS RESTRICTION: Not for vendors
    const isDetailsRestricted = (profile.role !== 'vendor') && (!isOwner && detailsStatus !== 'granted');
    const isVendor = profile.role === 'vendor';

    // --- RENDER ---
    return (
        <div className="min-h-screen bg-pink-50 pb-20 font-inter">

            {/* VENDOR VIEW */}
            {isVendor ? (
                <div className="max-w-6xl mx-auto px-4 py-8">
                    {/* Clean Header with Back Button */}
                    <div className="mb-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                        <Button variant="ghost" className="gap-2 text-gray-600 hover:text-gray-900 px-0 sm:px-4" onClick={() => router.back()}>
                            <ArrowLeft className="w-5 h-5" /> Back to Search
                        </Button>
                        <div className="flex items-center gap-2 sm:gap-3 w-full sm:w-auto overflow-x-auto sm:overflow-visible pb-2 sm:pb-0 no-scrollbar">
                            <div className="shrink-0">
                                <LanguageSwitcher />
                            </div>
                            <Button variant="outline" className="gap-2 rounded-full border-gray-200 shrink-0" onClick={() => setIsShareOpen(true)}>
                                <Share2 className="w-4 h-4" /> Share
                            </Button>
                            {isOwner && (
                                <Button variant="outline" className="gap-2 rounded-full shrink-0" onClick={() => setIsEditing(true)}>
                                    <Edit className="w-4 h-4" /> Edit
                                </Button>
                            )}
                        </div>
                    </div>

                    <div className="flex flex-col lg:flex-row gap-10 items-start">
                        {/* LEFT: Vendor Card & Contact Info */}
                        <div className="w-full lg:w-80 flex flex-col items-center gap-8 lg:sticky lg:top-24 text-center">
                            <VendorCard
                                vendor={profile}
                                className="shadow-2xl border-none ring-1 ring-gray-100"
                            />


                            {/* NEW: Condition - Show Contact Details ONLY to Owner, else show Inquiry Form */}
                            {isOwner ? (
                                <Card className="w-full shadow-lg border-none ring-1 ring-gray-100 overflow-hidden text-left">
                                    <div className="bg-gray-50/50 px-5 py-3 border-b border-gray-100">
                                        <h3 className="font-bold text-gray-900 flex items-center gap-2">
                                            <div className="w-1.5 h-4 bg-[#EF2F55] rounded-full" />
                                            Contact Information
                                        </h3>
                                    </div>
                                    <CardContent className="p-6 space-y-6">
                                        {/* Location */}
                                        <div className="flex items-start gap-4 text-sm">
                                            <div className="bg-rose-50 p-2 rounded-lg shrink-0">
                                                <MapPin className="w-4 h-4 text-[#EF2F55]" />
                                            </div>
                                            <div>
                                                <p className="font-bold text-gray-900 mb-0.5">Business Address</p>
                                                <p className="text-gray-600 leading-relaxed">
                                                    {profile.vendor_details?.business_address || 'Not Listed'}
                                                </p>
                                                <p className="text-gray-500 font-medium mt-1">{profile.city}, {profile.state}</p>
                                            </div>
                                        </div>

                                        {/* Phone */}
                                        <div className="flex items-center gap-4 text-sm">
                                            <div className="bg-rose-50 p-2 rounded-lg shrink-0 text-[#EF2F55] text-lg font-bold">
                                                📞
                                            </div>
                                            <div>
                                                <p className="font-bold text-gray-900 mb-0.5">Mobile</p>
                                                <p className="text-gray-600 font-medium">{profile.phone || profile.mobile || 'Private'}</p>
                                            </div>
                                        </div>

                                        {/* Email */}
                                        <div className="flex items-center gap-4 text-sm">
                                            <div className="bg-rose-50 p-2 rounded-lg shrink-0 text-[#EF2F55] text-lg font-bold">
                                                ✉️
                                            </div>
                                            <div>
                                                <p className="font-bold text-gray-900 mb-0.5">Email</p>
                                                <p className="text-gray-600 font-medium truncate w-40" title={profile.email}>{profile.email || 'Private'}</p>
                                            </div>
                                        </div>
                                    </CardContent>
                                    <div className="p-4 bg-rose-50/30 border-t border-rose-50 text-center">
                                        {profile.vendor_details?.embedded_map_link || profile.vendor_details?.map_link ? (
                                            <a
                                                href={profile.vendor_details.map_link || profile.vendor_details.embedded_map_link}
                                                target="_blank"
                                                rel="noopener noreferrer"
                                                className="text-[#EF2F55] text-xs font-bold uppercase tracking-widest hover:underline flex items-center justify-center gap-2"
                                            >
                                                <Map className="w-3 h-3" />
                                                View on Google Maps
                                            </a>
                                        ) : (
                                            <button
                                                className="text-gray-400 text-xs font-bold uppercase tracking-widest cursor-not-allowed opacity-50"
                                                disabled
                                            >
                                                No Map Linked
                                            </button>
                                        )}
                                    </div>
                                </Card>
                            ) : (
                                <InquiryForm 
                                    vendorId={profile._id} 
                                    vendorName={profile.vendor_details?.business_name || profile.first_name} 
                                />
                            )}


                            {profile.role !== 'vendor' && !profile.vendor_details && !isOwner && (
                                <Button
                                    onClick={handleConnectionAction}
                                    disabled={isConnecting}
                                    className={`w-full ${profile.connectionStatus === 'none' ? 'bg-[#EF2F55] hover:bg-rose-700' : 'bg-gray-100 hover:bg-gray-200 text-gray-700'} text-white rounded-xl font-bold py-6 shadow-lg shadow-pink-100 transition-all active:scale-95`}
                                >
                                    {isConnecting ? (
                                        <div className="flex items-center gap-2">
                                            <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                                            <span>Connecting...</span>
                                        </div>
                                    ) : (
                                        <div className="flex items-center gap-2">
                                            <MessageCircle className="w-5 h-5" />
                                            <span>{friendStatus === 'accepted' ? "Message" : "Connect"}</span>
                                        </div>
                                    )}
                                </Button>
                            )}

                            {/* Verification Badge */}
                            <div className="bg-blue-50/50 w-full p-4 rounded-2xl flex items-center justify-center gap-3 border border-blue-100">
                                <div className="bg-blue-600 text-white p-1 rounded-full">
                                    <Check className="w-4 h-4" />
                                </div>
                                <div className="text-left">
                                    <p className="text-blue-700 font-bold text-sm">Verified Identity</p>
                                    <p className="text-blue-600/70 text-[10px] font-medium uppercase tracking-wider">Trusted Vendor</p>
                                </div>
                            </div>
                        </div>

                        {/* RIGHT: Full Details (No restrictions) */}
                        <div className="flex-1 space-y-10">
                            <div className="animate-in fade-in slide-in-from-bottom-4 duration-700">
                                <h1 className="text-4xl font-bold text-gray-900 mb-3 tracking-tight">
                                    {[profile.first_name, profile.last_name].filter(Boolean).join(' ') || profile.vendor_details?.business_name || profile.displayName}
                                </h1>
                                <div className="flex items-center gap-3 flex-wrap">
                                    <span className="bg-[#EF2F55]/10 text-[#EF2F55] px-3 py-1 rounded-lg font-bold text-sm">
                                        {profile.vendor_details?.service_type || translateData('occupation', profile.occupation)}
                                    </span>
                                    <span className="text-gray-400">•</span>
                                    <div className="flex items-center gap-1.5 text-gray-600 font-medium">
                                        <MapPin className="w-4 h-4" /> {profile.city}, {profile.state}, {profile.country || 'India'}
                                    </div>
                                    {profile.vendor_details?.averageRating > 0 && (
                                        <>
                                            <span className="text-gray-400">•</span>
                                            <div className="flex items-center gap-2">
                                                <div className="flex gap-0.5 text-yellow-400">
                                                    {[1, 2, 3, 4, 5].map(s => (
                                                        <Star
                                                            key={s}
                                                            className={`w-4 h-4 ${s <= (profile.vendor_details?.averageRating || 0) ? 'fill-current' : 'text-gray-200'}`}
                                                        />
                                                    ))}
                                                </div>
                                                <span className="text-gray-400 text-sm font-bold">
                                                    {profile.vendor_details.averageRating} ({profile.vendor_details.reviewCount} Reviews)
                                                </span>
                                            </div>
                                        </>
                                    )}
                                    {(!profile.vendor_details?.averageRating || profile.vendor_details.averageRating === 0) && (
                                        <>
                                            <span className="text-gray-400">•</span>
                                             <span className="text-gray-400 text-sm font-bold bg-gray-100 px-2 py-0.5 rounded-full uppercase tracking-tighter">New</span>
                                        </>
                                    )}
                                </div>
                            </div>

                            <div className="grid grid-cols-3 gap-6">
                                <div className="bg-white p-6 rounded-2xl ring-1 ring-gray-100 shadow-sm text-center">
                                    <p className="text-3xl font-bold text-gray-900 mb-1">{profile.vendor_details?.experience_years || 0}</p>
                                     <p className="text-xs text-gray-400 font-bold uppercase tracking-widest">Years Experience</p>
                                </div>
                                <div className="bg-white p-6 rounded-2xl ring-1 ring-gray-100 shadow-sm text-center">
                                    <p className="text-3xl font-bold text-[#EF2F55] mb-1">
                                        {profile.photos?.length || 0}
                                    </p>
                                     <p className="text-xs text-gray-400 font-bold uppercase tracking-widest">Work Photos</p>
                                </div>
                                <div className="bg-white p-6 rounded-2xl ring-1 ring-gray-100 shadow-sm text-center">
                                    <p className="text-3xl font-bold text-green-600 mb-1 flex items-center justify-center">
                                        <Check className="w-8 h-8" />
                                    </p>
                                     <p className="text-xs text-gray-400 font-bold uppercase tracking-widest">Verified</p>
                                </div>
                            </div>

                            {/* Vendor Tabs */}
                            <div className="border-b border-gray-200">
                                <div className="flex gap-4 sm:gap-8 pb-1 overflow-x-auto no-scrollbar">
                                    {profile.role === 'vendor' && (
                                        <button
                                            onClick={() => {
                                                const element = document.getElementById('vendor-reviews');
                                                if (element) element.scrollIntoView({ behavior: 'smooth' });
                                            }}
                                            className={`pb-4 text-sm font-bold uppercase tracking-widest transition-all relative shrink-0 text-gray-400 hover:text-gray-600`}
                                        >
                                             Reviews
                                        </button>
                                    )}
                                    {(isOwner || profile.role !== 'vendor') && (
                                        <button
                                            onClick={() => setActiveTab('preferences')}
                                            className={`pb-4 text-sm font-bold uppercase tracking-widest transition-all relative shrink-0 ${activeTab === 'preferences' ? 'text-[#EF2F55]' : 'text-gray-400 hover:text-gray-600'}`}
                                        >
                                             Preferences
                                            {activeTab === 'preferences' && <motion.div layoutId="activeTab" className="absolute bottom-0 left-0 right-0 h-1 bg-[#EF2F55] rounded-full" />}
                                        </button>
                                    )}
                                </div>
                            </div>


                            {activeTab === 'preferences' && (
                                <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
                                    <PartnerPreferencesView
                                        user={profile}
                                        isOwner={isOwner}
                                        onEdit={() => setIsPreferencesModalOpen(true)}
                                    />
                                </div>
                            )}

                            {/* About Us */}
                            <div className="space-y-4">
                                <h3 className="text-2xl font-bold text-gray-900 flex items-center gap-3 text-left">
                                     About Services
                                </h3>
                                <div className="p-8 bg-gray-50/50 rounded-3xl border border-gray-100 leading-relaxed text-gray-700 text-lg italic font-medium text-left">
                                    "{profile.vendor_details?.description || profile.bio || "We are dedicated to making your special day unforgettable with our expert wedding services. Contact us today to learn more."}"
                                </div>
                            </div>

                            {/* Location & Map Section */}
                            {(profile.vendor_details?.embedded_map_link || profile.vendor_details?.map_link) && (
                                <div className="space-y-6">
                                    <h3 className="text-2xl font-bold text-gray-900 flex items-center gap-3 text-left">
                                        <MapPin className="w-6 h-6 text-[#EF2F55]" />
                                        Location & Map
                                    </h3>
                                    
                                    <div className="bg-white p-2 rounded-[32px] ring-1 ring-gray-100 shadow-xl overflow-hidden">
                                        {profile.vendor_details?.embedded_map_link ? (
                                            <div className="aspect-video w-full rounded-[24px] overflow-hidden">
                                                <iframe
                                                    src={profile.vendor_details.embedded_map_link.includes('src=') 
                                                        ? profile.vendor_details.embedded_map_link.split('src="')[1].split('"')[0] 
                                                        : profile.vendor_details.embedded_map_link}
                                                    width="100%"
                                                    height="100%"
                                                    style={{ border: 0 }}
                                                    allowFullScreen
                                                    loading="lazy"
                                                    referrerPolicy="no-referrer-when-downgrade"
                                                />
                                            </div>
                                        ) : (
                                            <div className="aspect-video w-full bg-gray-50 rounded-[24px] flex flex-col items-center justify-center gap-4 text-center p-8">
                                                <div className="bg-rose-50 p-4 rounded-full">
                                                    <MapPin className="w-10 h-10 text-[#EF2F55]" />
                                                </div>
                                                <div>
                                                    <h4 className="text-lg font-bold text-gray-900">Map Available</h4>
                                                    <p className="text-sm text-gray-500 max-w-xs mx-auto mt-1">We couldn't embed the map directly, but you can view the location on Google Maps.</p>
                                                </div>
                                                <Button 
                                                    onClick={() => window.open(profile.vendor_details.map_link, '_blank')}
                                                    className="bg-[#EF2F55] hover:bg-rose-700 text-white gap-2 rounded-full px-8"
                                                >
                                                    <ExternalLink className="w-4 h-4" /> Open in Google Maps
                                                </Button>
                                            </div>
                                        )}
                                        
                                        <div className="p-6 flex items-center justify-between gap-4">
                                            <div className="flex items-start gap-3">
                                                <div className="bg-rose-50 p-2 rounded-lg shrink-0">
                                                    <MapPin className="w-4 h-4 text-[#EF2F55]" />
                                                </div>
                                                <div>
                                                    <p className="text-sm font-bold text-gray-900">{profile.vendor_details?.business_address || 'Address not listed'}</p>
                                                    <p className="text-xs text-gray-500 font-medium">{profile.city}, {profile.state}</p>
                                                </div>
                                            </div>
                                            {profile.vendor_details?.map_link && (
                                                <Button 
                                                    variant="outline" 
                                                    size="sm"
                                                    className="rounded-full border-gray-200 text-gray-600 gap-2 shrink-0"
                                                    onClick={() => window.open(profile.vendor_details.map_link, '_blank')}
                                                >
                                                    <Navigation className="w-4 h-4" /> Directions
                                                </Button>
                                            )}
                                        </div>
                                    </div>
                                </div>
                            )}

                            {/* Gallery & Availability Section */}
                            {/* Full-Width Gallery Section */}
                            <div className="py-10 border-t border-gray-100">
                                <VendorGallery 
                                    vendorId={profile._id} 
                                    photos={photos} 
                                    isOwner={isOwner} 
                                    onUpdate={(newPhotos) => setPhotos(newPhotos)} 
                                />
                            </div>

                            {/* Availability Section (Aligned with Dashboard) */}
                            <div className="py-10 border-t border-gray-100">
                                <div className="max-w-2xl">
                                    <h2 className="text-2xl font-black text-gray-900 flex items-center gap-3 mb-6">
                                        <div className="w-2 h-8 bg-[#EF2F55] rounded-full" />
                                        Availability & Calendar
                                    </h2>
                                    <div className="grid grid-cols-1 md:grid-cols-2 gap-8 items-start">
                                        <div className="max-w-md">
                                            <VendorCalendar
                                                vendorId={profile._id}
                                                initialAvailability={profile.vendor_details?.availability || []}
                                                isEditable={isOwner}
                                                onUpdate={fetchData}
                                            />
                                        </div>
                                        
                                        {/* Booking Policy & Info */}
                                        <div className="bg-rose-50/30 rounded-[40px] p-8 border border-rose-100 h-full flex flex-col justify-center">
                                            <h4 className="text-xl font-black text-gray-900 mb-4 tracking-tight">Booking Policy</h4>
                                            <ul className="space-y-3 text-sm text-gray-600 font-medium list-disc list-inside marker:text-[#EF2F55]">
                                                <li>Cancellations up to 14 days before</li>
                                                <li>Secure payments through WeddingZon</li>
                                                <li>Verified professional services</li>
                                                <li>Customer support available 24/7</li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            {/* VENDOR REVIEWS SECTION */}
                            <div id="vendor-reviews" className="py-12 border-t border-gray-100">
                                <VendorReviews vendorId={profile._id} isOwner={isOwner} />
                            </div>

                            {/* MESSAGE VENDOR SECTION */}
                            {!isOwner && (
                                <div id="message-vendor" className="py-12 border-t border-gray-100">
                                    <MessageVendorSection 
                                        vendorId={profile._id} 
                                        vendorName={profile.vendor_details?.business_name || profile.first_name} 
                                    />
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            ) : (
                <>
                    {/* New Redesign Layout */}

                    {/* 1. Header (Cover + Avatar + Name) */}
                    <FadeIn duration={0.6}>
                        <ProfileHeader
                            user={profile}
                            isOwner={isOwner}
                            onEdit={() => setIsEditing(true)}
                            photos={displayedPhotos}
                            friendStatus={friendStatus}
                            photoStatus={connectionStatus} // connectionStatus here maps to Photo Access Status
                            detailsStatus={detailsStatus}
                            onConnect={handleConnect}
                            onDisconnect={handleDisconnect}
                            onCancelRequest={handleCancelRequest}
                            onRequestPhoto={handleRequestAccess}
                            onRequestDetails={handleRequestDetails}
                            onBlock={handleBlock}
                            onReport={() => setIsReportModalOpen(true)}
                            onPhotoClick={onPhotoClick}
                            onRequestQuote={() => setRequestModal({ isOpen: true, type: 'quote' })}
                            onRequestAvailability={() => setRequestModal({ isOpen: true, type: 'availability' })}
                        />
                    </FadeIn>

                    <div className="max-w-3xl mx-auto px-4 relative z-30 mt-4">
                        {/* 2. Tabs */}
                        <FadeIn delay={0.2}>
                            <ProfileTabs
                                activeTab={activeTab as any}
                                onTabChange={(tab: any) => setActiveTab(tab)}
                                userRole={profile.role}
                            />
                        </FadeIn>

                        {/* 3. Completion Card */}
                        {isOwner && <ProfileCompletionCard user={profile} onPhotoEdit={() => setIsEditing(true)} />}

                        {/* 4. Conditional View Based on Active Tab */}
                        <AnimatePresence mode="wait">
                            {activeTab === 'profile' ? (
                                <StaggerContainer
                                    key="profile"
                                    staggerDelay={0.05}
                                    className="flex flex-col gap-2"
                                >
                                    <StaggerItem>
                                        <ProfileSection
                                            title="Basic Details"
                                            onEdit={() => router.push('/onboarding?step=basic')}
                                            restricted={isDetailsRestricted}
                                            status={detailsStatus}
                                            onRequestAccess={handleRequestDetails}
                                        >
                                            {/* Details Override for Franchise */}
                                            {profile.is_franchise_created && (
                                                <div className="mb-4 p-4 bg-purple-50 rounded-2xl border border-purple-100">
                                                    <div className="flex items-center gap-2 mb-2">
                                                        <div className="w-1.5 h-1.5 bg-purple-600 rounded-full animate-pulse" />
                                                        <p className="text-[10px] font-black text-purple-700 uppercase tracking-widest">Contact Managed by Franchise</p>
                                                    </div>
                                                    <p className="text-xs text-purple-600/80 font-medium leading-relaxed">
                                                        Contact details for this member are managed by <span className="font-bold">{profile.franchise_info?.business_name || 'our authorized franchise'}</span>.
                                                    </p>
                                                </div>
                                            )}

                                            <p className="text-gray-400 text-[10px] font-bold uppercase tracking-wider mb-4">Basic Details</p>
                                            <div className="space-y-4">
                                                <DetailItem icon="Height" value={profile.height} isOwner={isOwner} onAdd={() => router.push('/onboarding?step=basic')} />
                                                <DetailItem icon="Religion" value={profile.religion ? `${translateData('religion', profile.religion)} • ${profile.caste || ''}` : undefined} isOwner={isOwner} onAdd={() => router.push('/onboarding?step=religious')} />
                                                <DetailItem icon="Language" value={profile.mother_tongue ? `Mother Tongue: ${profile.mother_tongue}` : undefined} isOwner={isOwner} onAdd={() => router.push('/onboarding?step=basic')} />
                                                <DetailItem icon="Location" value={profile.city ? `${profile.city}, ${profile.state || ''}, ${profile.country || ''}` : undefined} isOwner={isOwner} onAdd={() => router.push('/onboarding?step=location')} />
                                                <DetailItem icon="Income" value={profile.personal_income ? `${translateData('income', profile.personal_income)}` : undefined} isOwner={isOwner} onAdd={() => router.push('/onboarding?step=education')} />
                                                <DetailItem icon="DOB" value={profile.dob ? new Date(profile.dob).toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' }) : undefined} isOwner={isOwner} onAdd={() => router.push('/onboarding?step=basic')} />
                                                <DetailItem icon="Marital" value={translateData('marital_status', profile.marital_status)} isOwner={isOwner} onAdd={() => router.push('/onboarding?step=basic')} />
                                                <DetailItem icon="User" value={profile.gothra} isOwner={isOwner} onAdd={() => router.push('/onboarding?step=religious')} />
                                            </div>
                                        </ProfileSection>
                                    </StaggerItem>



                                    <StaggerItem>
                                        <ProfileSection
                                            title="Education"
                                            onEdit={isOwner ? () => router.push('/onboarding?step=education') : undefined}
                                            restricted={isDetailsRestricted}
                                            status={detailsStatus}
                                            onRequestAccess={handleRequestDetails}
                                        >
                                            <p className="text-gray-400 text-[10px] font-bold uppercase tracking-wider mb-4">Education</p>
                                            <div className="flex items-center gap-4">
                                                <div className="w-12 h-12 bg-gray-50 rounded-2xl flex items-center justify-center">
                                                    <GraduationCap className="w-6 h-6 text-gray-400" />
                                                </div>
                                                <div>
                                                    <p className="font-bold text-gray-900 text-base">{translateData('education', profile.highest_education) || profile.highest_education || 'B.E/B.Tech'}</p>
                                                    <p className="text-gray-500 text-xs font-bold uppercase tracking-wider">{profile.college_name || 'UG College'}</p>
                                                </div>
                                            </div>
                                            <div className="mt-4 p-5 bg-gray-50/50 rounded-[24px] text-gray-700 text-[15px] italic border border-gray-100/50 font-medium font-playfair">
                                                {profile.education_details || "Tell us about your education..."}
                                            </div>
                                        </ProfileSection>
                                    </StaggerItem>

                                    <StaggerItem>
                                        <ProfileSection
                                            title="Career"
                                            onEdit={isOwner ? () => router.push('/onboarding?step=education') : undefined}
                                            restricted={isDetailsRestricted}
                                            status={detailsStatus}
                                            onRequestAccess={handleRequestDetails}
                                        >
                                            <p className="text-gray-400 text-[10px] font-bold uppercase tracking-wider mb-4">Career</p>
                                            <div className="flex items-center gap-4">
                                                <div className="w-12 h-12 bg-gray-50 rounded-2xl flex items-center justify-center">
                                                    <Briefcase className="w-6 h-6 text-gray-400" />
                                                </div>
                                                <div>
                                                    <p className="font-bold text-gray-900 text-base">{translateData('occupation', profile.occupation) || profile.occupation || 'Software Professional'}</p>
                                                    <p className="text-gray-500 text-xs font-bold uppercase tracking-wider">{profile.company_name || 'Technology Company'}</p>
                                                </div>
                                            </div>
                                            <div className="mt-4 p-5 bg-gray-50/50 rounded-[24px] text-gray-700 text-[15px] italic border border-gray-100/50 font-medium font-playfair">
                                                 {profile.career_details || "No details provided."}
                                            </div>
                                        </ProfileSection>
                                    </StaggerItem>

                                    <StaggerItem>
                                        <ProfileSection
                                            title="Family"
                                            onEdit={isOwner ? () => router.push('/onboarding?step=family') : undefined}
                                            restricted={isDetailsRestricted}
                                            status={detailsStatus}
                                            onRequestAccess={handleRequestDetails}
                                        >
                                            <p className="text-gray-400 text-[10px] font-bold uppercase tracking-wider mb-4">Introduce Family</p>
                                            <div className="space-y-6">
                                                <div className="flex items-center gap-4">
                                                    <div className="w-11 h-11 rounded-full bg-gray-50 flex items-center justify-center"><Users className="w-5 h-5 text-gray-400" /></div>
                                                    <span className="text-[17px] font-bold text-gray-900">
                                                        Joint family from {profile.city || 'New Delhi'}, {profile.state || 'Delhi'}, {profile.country || 'India'}
                                                    </span>
                                                </div>
                                                <div className="flex items-start gap-4">
                                                    <div className="w-11 h-11 rounded-full bg-gray-50 flex items-center justify-center mt-1"><User className="w-5 h-5 text-gray-400" /></div>
                                                    <div className="text-[17px] font-bold text-gray-900 flex-1">
                                                        <p>
                                                            Parents: {profile.father_occupation || 'Retired'} (Father), {profile.mother_occupation || 'Homemaker'} (Mother)
                                                        </p>
                                                        <p className="text-gray-400 text-[11px] font-black uppercase tracking-widest mt-1.5">
                                                            Siblings: {profile.brothers || 0} Brothers, {profile.sisters || 0} Sisters
                                                        </p>
                                                    </div>
                                                </div>
                                            </div>
                                            <div className="mt-6 p-5 bg-gray-50/50 rounded-[24px] text-gray-700 text-[15px] italic border border-gray-100/50 font-medium font-playfair">
                                                {profile.family_details || "Tell us about your family..."}
                                            </div>
                                        </ProfileSection>
                                    </StaggerItem>

                                    <StaggerItem>
                                        <ProfileSection
                                            title="Property"
                                            onEdit={isOwner ? () => router.push('/onboarding?step=property') : undefined}
                                            restricted={isDetailsRestricted}
                                            status={detailsStatus}
                                            onRequestAccess={handleRequestDetails}
                                        >
                                            <p className="text-gray-600 text-[15px] mb-4 font-medium italic font-playfair">Property Details</p>
                                            <div className="space-y-3">
                                                <DetailItem icon="Home" value={profile.property_possession_type ? `Home: ${profile.property_possession_type}` : undefined} isOwner={isOwner} onAdd={() => router.push('/onboarding?step=property')} />
                                                <DetailItem icon="Map" value={profile.land_area_range ? `Land: ${profile.land_area_range}` : undefined} isOwner={isOwner} onAdd={() => router.push('/onboarding?step=property')} />
                                            </div>
                                        </ProfileSection>
                                    </StaggerItem>

                                    <StaggerItem>
                                        <ProfileSection
                                            title="Personal Details"
                                            onEdit={isOwner ? () => router.push('/onboarding?step=lifestyle') : undefined}
                                            restricted={isDetailsRestricted}
                                            status={detailsStatus}
                                            onRequestAccess={handleRequestDetails}
                                        >
                                            <div className="space-y-3">
                                                <DetailItem icon="Heart" value={`Diet: ${profile.diet || '-'}`} />
                                                <DetailItem icon="X" value={`Smoking/Drinking: ${profile.smoking || 'No'} / ${profile.drinking || 'No'}`} />
                                                <DetailItem icon="Flag" value={`Disability: ${profile.disability === 'Yes' ? `${profile.disability_type} (${profile.disability_description})` : 'None'}`} />
                                                <DetailItem icon="User" value={`Sub-Community: ${profile.sub_community || '-'}`} />
                                            </div>
                                        </ProfileSection>
                                    </StaggerItem>
                                    <StaggerItem>
                                        <ProfileSection
                                            title="Kundli & Astrology"
                                            onEdit={isOwner ? () => router.push('/onboarding?step=religious') : undefined}
                                        >
                                            <p className="text-gray-400 text-[10px] font-bold uppercase tracking-wider mb-4">Astro Details</p>
                                            <div className="space-y-4">
                                                <DetailItem icon="User" value={profile.manglik_status ? `Manglik Status: ${profile.manglik_status}` : undefined} isOwner={isOwner} onAdd={() => router.push('/onboarding?step=religious')} />
                                                <DetailItem icon="Age" value={profile.time_of_birth ? `${profile.time_of_birth} | ${profile.place_of_birth || 'Place of Birth'}` : undefined} isOwner={isOwner} onAdd={() => router.push('/onboarding?step=religious')} />
                                            </div>
                                            <div className="mt-4 p-5 bg-gray-50/50 rounded-[24px] text-gray-700 text-[15px] italic border border-gray-100/50 font-medium font-playfair">
                                                {profile.astro_details || "Write about your horoscope..."}
                                            </div>
                                        </ProfileSection>
                                    </StaggerItem>

                                    <StaggerItem>
                                        <ProfileSection
                                            title="Lifestyle"
                                            onEdit={isOwner ? () => router.push('/onboarding?step=lifestyle') : undefined}
                                        >
                                            <p className="text-gray-400 text-[10px] font-bold uppercase tracking-wider mb-4">Glimpse into Lifestyle</p>

                                            <div className="space-y-8">
                                                <div>
                                                    <h4 className="text-gray-900 font-bold text-[17px] mb-4">Lifestyle Habits</h4>
                                                    <div className="grid grid-cols-3 gap-3">
                                                        <div className="bg-white border-2 border-gray-50 rounded-[24px] p-5 flex flex-col items-start gap-3 shadow-sm hover:border-pink-100 transition-all">
                                                            <div className="w-10 h-10 rounded-xl bg-gray-50 flex items-center justify-center text-gray-400">
                                                                <GlassWater className="w-6 h-6" />
                                                            </div>
                                                            <p className="text-[11px] font-black text-gray-400 uppercase leading-none tracking-widest">Drinking</p>
                                                            <p className="text-base font-bold text-gray-900">{profile.drinking || 'Non-Drinker'}</p>
                                                        </div>
                                                        <div className="bg-white border-2 border-gray-50 rounded-[24px] p-5 flex flex-col items-start gap-3 shadow-sm hover:border-pink-100 transition-all">
                                                            <div className="w-10 h-10 rounded-xl bg-gray-50 flex items-center justify-center text-gray-400">
                                                                <Utensils className="w-6 h-6" />
                                                            </div>
                                                            <p className="text-[11px] font-black text-gray-400 uppercase leading-none tracking-widest">Eating Habits</p>
                                                            <p className="text-base font-bold text-gray-900">{profile.diet || 'Vegetarian'}</p>
                                                        </div>
                                                        <div className="bg-white border-2 border-gray-50 rounded-[24px] p-5 flex flex-col items-start gap-3 shadow-sm hover:border-pink-100 transition-all">
                                                            <div className="w-10 h-10 rounded-xl bg-gray-50 flex items-center justify-center text-gray-400">
                                                                <Cigarette className="w-6 h-6" />
                                                            </div>
                                                            <p className="text-[11px] font-black text-gray-400 uppercase leading-none tracking-widest">Smoking</p>
                                                            <p className="text-base font-bold text-gray-900">{profile.smoking || 'Non-Smoker'}</p>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div>
                                                    <h4 className="text-gray-900 font-bold text-[17px] mb-4">Assets</h4>
                                                    <div className="space-y-3">
                                                        <DetailItem icon="Home" value={`Home: ${profile.owns_house || 'Not Specified'}`} />
                                                        <DetailItem icon="Briefcase" value={`Car: ${profile.owns_car || 'Not Specified'}`} />
                                                    </div>
                                                </div>

                                                {profile.medical_history && (
                                                    <div>
                                                        <h4 className="text-gray-900 font-bold text-[17px] mb-4">Medical History</h4>
                                                        <DetailItem icon="Medical" value={profile.medical_history} />
                                                    </div>
                                                )}
                                            </div>
                                        </ProfileSection>
                                    </StaggerItem>

                                    <StaggerItem>
                                        <ProfileSection
                                            title="Partner Preferences"
                                            onEdit={() => setActiveTab('preferences')}
                                        >
                                            <p className="text-gray-600 text-[15px] mb-4 font-medium italic font-playfair">Your Ideal Match</p>
                                            <div className="space-y-3">
                                                <DetailItem icon="Age" value={`${profile.partner_preferences?.minAge || '21'} - ${profile.partner_preferences?.maxAge || '35'} Years`} />
                                                <DetailItem icon="Religion" value={profile.partner_preferences?.religion || 'Any Religion'} />
                                                <DetailItem icon="Location" value={profile.partner_preferences?.location || 'Anywhere'} />
                                                <DetailItem icon="Marital" value={profile.partner_preferences?.marital_status || "Doesn't Matter"} />
                                            </div>
                                            <div className="mt-4 p-5 bg-gray-50/50 rounded-[24px] text-gray-700 text-[15px] italic border border-gray-100/50 font-medium font-playfair">
                                                "{profile.partner_preferences?.about_partner || "No partner details provided"}"
                                            </div>
                                            <Button
                                                variant="link"
                                                className="text-[#EF2F55] font-bold p-0 h-auto text-sm mt-4 uppercase tracking-widest hover:no-underline"
                                                onClick={() => setActiveTab('preferences')}
                                            >
                                                View Full Preferences
                                            </Button>
                                        </ProfileSection>
                                    </StaggerItem>
                                </StaggerContainer>

                            ) : activeTab === 'reviews' ? (
                                <div key="reviews" className="animate-in fade-in duration-500">
                                    <VendorReviews vendorId={profile._id} isOwner={isOwner} />
                                </div>
                            ) : (
                                <div key="preferences" className="animate-in fade-in duration-500">
                                    <PartnerPreferencesView
                                        user={profile}
                                        isOwner={isOwner}
                                        onEdit={() => setIsPreferencesModalOpen(true)}
                                    />
                                </div>
                            )}
                        </AnimatePresence>

                        {/* Spacer for bottom nav/footer if any */}
                        <div className="h-20"></div>
                    </div>
                </>
            )}

            <MediaViewer
                isOpen={isViewerOpen}
                onClose={() => setIsViewerOpen(false)}
                initialIndex={viewerIndex}
                photos={displayedPhotos}
            />

            {isChatOpen && profile && (
                <ChatWindow
                    recipientId={profile._id}
                    recipientUsername={profile.username}
                    recipientName={`${profile.first_name || ''} ${profile.last_name || ''}`.trim() || 'User'}
                    recipientPhoto={profile.profilePhoto}
                    onClose={() => setIsChatOpen(false)}
                />
            )}

            {profile && (
                <ShareDialog
                    isOpen={isShareOpen}
                    onClose={() => setIsShareOpen(false)}
                    profile={profile}
                />
            )}

            {isReportModalOpen && (
                <div className="fixed inset-0 z-[60] flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm animate-in fade-in">
                    <div className="bg-white rounded-2xl shadow-2xl p-6 w-full max-w-md space-y-6">
                        <div className="flex justify-between items-center">
                            <h3 className="text-xl font-bold text-gray-900">Report User</h3>
                            <button onClick={() => setIsReportModalOpen(false)}><X /></button>
                        </div>
                        <div className="space-y-4">
                            <div className="space-y-2">
                                <label className="text-sm font-medium text-gray-700">Reason</label>
                                <select
                                    value={reportReason}
                                    onChange={(e) => setReportReason(e.target.value)}
                                    className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 outline-none"
                                >
                                    <option value="spam">Spam or Fake</option>
                                    <option value="fake">Fake Profile</option>
                                    <option value="harassment">Harassment</option>
                                    <option value="inappropriate">Inappropriate Content</option>
                                    <option value="other">Other</option>
                                </select>
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-medium text-gray-700">Description</label>
                                <textarea
                                    value={reportDesc}
                                    onChange={(e) => setReportDesc(e.target.value)}
                                    className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 outline-none h-24 resize-none"
                                    placeholder="Tell us more about the issue..."
                                ></textarea>
                            </div>
                        </div>
                        <Button onClick={submitReport} className="w-full bg-orange-600 hover:bg-orange-700 text-white">Submit Report</Button>
                    </div>
                </div>
            )}

            {isEditing && (
                <div className="fixed inset-0 z-[60] flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm animate-in fade-in">
                    <div className="bg-white rounded-2xl shadow-2xl w-full max-w-4xl h-[90vh] flex flex-col overflow-hidden">
                        <div className="p-4 border-b flex justify-between items-center">
                            <h3 className="text-xl font-bold text-gray-900">Manage Photos</h3>
                            <button onClick={() => setIsEditing(false)} className="p-2 hover:bg-gray-100 rounded-full">
                                <X className="w-5 h-5" />
                            </button>
                        </div>

                        <div className="flex-1 overflow-y-auto p-6">
                            <PhotoUploadGrid
                                photos={photos}
                                setPhotos={setPhotos}
                                updateProfilePhotoLocal={updateProfilePhotoLocal}
                                setProfileEndpoint="/users/photos"
                                setCoverEndpoint="/users/photos"
                            />
                        </div>
                    </div>
                </div>
            )}

            {isPreferencesModalOpen && profile && (
                <MatchPreferencesModal
                    profile={profile}
                    onClose={() => setIsPreferencesModalOpen(false)}
                    onSuccess={() => {
                        window.location.reload();
                    }}
                    apiEndpoint={`/users/preferences`}
                />
            )}

            <ConfirmationModal
                isOpen={confirmModal.isOpen}
                onClose={() => setConfirmModal(prev => ({ ...prev, isOpen: false }))}
                title={confirmModal.title}
                message={confirmModal.message}
                confirmText={confirmModal.confirmText}
                isDangerous={confirmModal.isDangerous}
                onConfirm={confirmModal.onConfirm}
            />

            {requestModal.isOpen && profile && (
                <VendorRequestModal
                    isOpen={requestModal.isOpen}
                    onClose={() => setRequestModal({ ...requestModal, isOpen: false })}
                    vendorId={profile._id}
                    vendorName={profile.vendor_details?.business_name || profile.displayName || 'Vendor'}
                    initialType={requestModal.type}
                />
            )}
        </div>
    );
}

// DetailCard for vendor section-specific display
function DetailCard({ icon, label, value }: { icon: any, label: string, value: string }) {
    return (
        <div className="bg-white p-5 rounded-3xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow group">
            <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-2xl bg-gray-50 flex items-center justify-center text-gray-400 group-hover:bg-rose-50 group-hover:text-rose-500 transition-colors">
                    {icon}
                </div>
                <div className="flex-1 min-w-0">
                    <p className="text-[11px] font-black text-gray-400 uppercase tracking-widest mb-1">{label}</p>
                    <p className="text-gray-900 font-bold text-base truncate">{value}</p>
                </div>
            </div>
        </div>
    );
}

// Enhanced helper for detail items with icon mapping
function DetailItem({ icon, value, onAdd, isOwner }: { icon: string, value: string | undefined, onAdd?: () => void, isOwner?: boolean }) {
    const iconMap: Record<string, any> = {
        'Height': Ruler,
        'Religion': Church,
        'Language': Languages,
        'Location': MapPin,
        'Income': IndianRupee,
        'DOB': Calendar,
        'Marital': Users,
        'Education': GraduationCap,
        'Career': Briefcase,
        'Home': Home,
        'Map': Map,
        'Heart': Heart,
        'X': X,
        'Flag': Flag,
        'User': User,
        'Age': Clock,
        'Medical': Stethoscope
    };

    const IconComp = iconMap[icon] || Check;

    const label = value || icon;

    return (
        <div className="flex items-center gap-3 w-full">
            <div className="w-8 h-8 rounded-full bg-gray-50 flex items-center justify-center flex-shrink-0">
                <IconComp className="w-4 h-4 text-gray-400" />
            </div>
            <div className="flex-1 flex justify-between items-center min-w-0">
                <span className={`text-[17px] font-semibold ${value ? 'text-gray-900' : 'text-gray-400'} truncate`}>
                    {label}
                </span>
                {!value && onAdd && isOwner && (
                    <button onClick={onAdd} className="text-[#EF2F55] text-[10px] font-semibold uppercase hover:underline ml-2 flex-shrink-0">
                        Add
                    </button>
                )}
            </div>
        </div>
    );
}

export default function ClientProfile({ params }: { params: Promise<{ username: string }> }) {
    return (
        <ToastProvider>
            <Suspense fallback={<div className="h-screen w-full flex items-center justify-center bg-gray-50 text-pink-600 font-medium">Loading...</div>}>
                <ProfileContent params={params} />
            </Suspense>
        </ToastProvider>
    );
}
