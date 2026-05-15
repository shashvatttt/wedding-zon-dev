import React, { useState } from 'react';
import Image from 'next/image';
import { useRouter } from 'next/navigation';
import {
    Camera, Eye, Plus, Check,
    X,
    FileText,
    Clock,
    Lock,
    ArrowLeft,
    MoreVertical,
    Flag,
    Ban,
    Heart,
    Users,
    Star,
} from 'lucide-react';
import { motion } from 'framer-motion';
import api from '../../services/api';
import { useToast } from '../../contexts/ToastContext';
import {
    Carousel,
    CarouselContent,
    CarouselItem,
    CarouselNext,
    CarouselPrevious,
} from '@/components/ui/carousel';
import { Button } from '@/components/ui/button';
import LanguageSwitcher from '@/components/LanguageSwitcher';

interface ProfileHeaderProps {
    user: any;
    isOwner: boolean;
    onEdit?: () => void;
    photos?: any[];
    // Statuses
    friendStatus?: 'none' | 'pending' | 'accepted' | 'rejected';
    photoStatus?: 'none' | 'pending' | 'granted' | 'rejected' | 'accepted';
    detailsStatus?: 'none' | 'pending' | 'granted' | 'rejected' | 'accepted';
    // Handlers
    onConnect?: () => void;
    onDisconnect?: () => void;
    onCancelRequest?: (type: 'connection' | 'photo' | 'details') => void;
    onRequestPhoto?: () => void;
    onRequestDetails?: () => void;
    onBlock?: () => void;
    onReport?: () => void;
    onPhotoClick?: (index: number, restricted?: boolean) => void;
    onRequestQuote?: () => void;
    onRequestAvailability?: () => void;
}

const ProfileHeader = ({
    user,
    isOwner,
    onEdit,
    photos = [],
    friendStatus = 'none',
    photoStatus = 'none',
    detailsStatus = 'none',
    onConnect,
    onDisconnect,
    onCancelRequest,
    onRequestPhoto,
    onRequestDetails,
    onBlock,
    onReport,
    onPhotoClick,
    onRequestQuote,
    onRequestAvailability
}: ProfileHeaderProps) => {
    const router = useRouter();
    const [isMenuOpen, setIsMenuOpen] = useState(false);

    // DEBUG: Trace friend status
    console.log('ProfileHeader Render:', { user: user?.username, friendStatus, photoStatus });

    // Ensure we have at least one slide (cover) if photos empty
    const displayPhotos = photos.length > 0 ? photos : [{ url: user.profilePhoto, isProfile: true, restricted: false }];

    return (
        <div className="relative w-full bg-white mb-4 group">
            {/* Carousel Area */}
            <div className="relative w-full h-[380px] md:h-[420px] overflow-hidden rounded-b-[40px] shadow-2xl">
                <Carousel className="w-full h-full">
                    <CarouselContent className="h-full ml-0">
                        {displayPhotos.map((photo, index) => (
                            <CarouselItem
                                key={index}
                                className="pl-0 h-full relative cursor-pointer"
                                onClick={() => onPhotoClick?.(index, photo.restricted)}
                            >
                                <Image
                                    src={photo.url || user.profilePhoto || "https://images.unsplash.com/photo-1542038784456-1ea8e935640e?q=80&w=2070&auto=format&fit=crop"}
                                    alt={`Profile Photo ${index + 1}`}
                                    fill
                                    className={`object-cover ${photo.restricted ? 'blur-md opacity-50' : ''}`}
                                    unoptimized
                                />
                                {photo.restricted && (
                                    <div className="absolute inset-0 flex items-center justify-center">
                                        <div className="bg-black/40 backdrop-blur-md p-4 rounded-full">
                                            <Lock className="w-8 h-8 text-white" />
                                        </div>
                                    </div>
                                )}
                            </CarouselItem>
                        ))}
                    </CarouselContent>

                    {/* Navigation Arrows (Only if multiple photos) */}
                    {displayPhotos.length > 1 && (
                        <>
                            <CarouselPrevious className="left-4 bg-black/20 hover:bg-black/40 border-none text-white w-10 h-10" />
                            <CarouselNext className="right-4 bg-black/20 hover:bg-black/40 border-none text-white w-10 h-10" />
                        </>
                    )}
                </Carousel>

                {/* Dark Overlay Gradient */}
                <div className="absolute inset-0 bg-gradient-to-t from-black/90 via-transparent to-black/30 pointer-events-none" />

                {isOwner && (
                    <>
                        <div
                            onClick={onEdit}
                            className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center cursor-pointer pointer-events-auto"
                        >
                            <div className="flex flex-col items-center text-white">
                                <Camera className="w-8 h-8 opacity-80" />
                                <span className="text-sm font-medium mt-2">Manage Photos</span>
                            </div>
                        </div>
                    </>
                )}

                {/* Top Actions: Back Button & Menu */}
                <div className="absolute top-4 left-4 z-50 flex items-center gap-3">
                    <Button
                        onClick={() => router.back()}
                        variant="ghost"
                        size="icon"
                        className="bg-white/10 backdrop-blur-md hover:bg-white/20 text-white rounded-full w-10 h-10"
                    >
                        <ArrowLeft className="w-5 h-5" />
                    </Button>
                    <LanguageSwitcher variant="transparent" className="shadow-lg" />
                </div>

                {/* More Options Menu (Non-Owner) */}
                {!isOwner && (
                    <div className="absolute top-4 right-4 z-30">
                        <div className="relative">
                            <Button
                                onClick={() => setIsMenuOpen(!isMenuOpen)}
                                variant="ghost"
                                size="icon"
                                className="bg-white/10 backdrop-blur-md hover:bg-white/20 text-white rounded-full w-10 h-10"
                            >
                                <MoreVertical className="w-5 h-5" />
                            </Button>

                            {isMenuOpen && (
                                <>
                                    <div className="fixed inset-0 z-10" onClick={() => setIsMenuOpen(false)} />
                                    <div className="absolute right-0 mt-2 w-48 bg-white rounded-xl shadow-xl z-20 py-2 border border-gray-100 animate-in fade-in zoom-in-95 duration-200 origin-top-right">
                                        <button
                                            onClick={() => { setIsMenuOpen(false); onReport?.(); }}
                                            className="w-full text-left px-4 py-2 text-gray-700 hover:bg-gray-50 flex items-center gap-2 text-sm font-medium"
                                        >
                                            <Flag className="w-4 h-4 text-orange-500" />
                                            Report User
                                        </button>
                                        <button
                                            onClick={() => { setIsMenuOpen(false); onBlock?.(); }}
                                            className="w-full text-left px-4 py-2 text-red-600 hover:bg-red-50 flex items-center gap-2 text-sm font-medium"
                                        >
                                            <Ban className="w-4 h-4" />
                                            Block User
                                        </button>
                                    </div>
                                </>
                            )}
                        </div>
                    </div>
                )}

                {/* Owner Buttons */}
                {isOwner && (
                    <div className="absolute top-4 right-4 z-10 flex flex-col items-end gap-2 sm:flex-row sm:items-center">
                        <div
                            onClick={onEdit}
                            className="flex items-center gap-2 px-4 py-2 rounded-full bg-white/20 border border-white/30 backdrop-blur-md cursor-pointer hover:bg-white/30 transition-all text-white text-sm font-medium"
                        >
                            <Plus className="w-4 h-4" />
                            <span className="hidden sm:inline">Manage Photos</span>
                        </div>

                        <Button
                            onClick={() => router.push('/connections')}
                            className="bg-white/20 hover:bg-white/30 text-white rounded-full px-4 h-9 border border-white/30 backdrop-blur-md font-medium text-sm flex items-center gap-2"
                            title="My Connections"
                        >
                            <Users className="w-4 h-4" />
                            <span className="hidden sm:inline">Connections</span>
                        </Button>
                        <Button
                            onClick={() => router.push('/profile/viewers')}
                            className="bg-white/20 hover:bg-white/30 text-white rounded-full px-4 h-9 border border-white/30 backdrop-blur-md font-medium text-sm flex items-center gap-2"
                            title="Who viewed your profile"
                        >
                            <Eye className="w-4 h-4" />
                            <span className="hidden sm:inline">Viewers</span>
                        </Button>
                        <Button
                            onClick={() => router.push('/profile/recently-viewed')}
                            className="bg-white/20 hover:bg-white/30 text-white rounded-full px-4 h-9 border border-white/30 backdrop-blur-md font-medium text-sm flex items-center gap-2"
                            title="Profiles you recently viewed"
                        >
                            <Clock className="w-4 h-4" />
                            <span className="hidden sm:inline">History</span>
                        </Button>
                    </div>
                )}

                {/* Visitor Action Bar */}
                {!isOwner && (
                    <div className="absolute bottom-10 right-8 z-20 flex flex-col gap-4 items-end">
                        <div className="flex gap-3">
                            {/* Connection Button Logic - HIDE FOR VENDORS */}
                            {(user.role !== 'vendor' && !isOwner) && (
                                friendStatus === 'accepted' ? (
                                    <motion.div initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }}>
                                        <Button
                                            onClick={onDisconnect}
                                            className="bg-green-500 hover:bg-red-500 text-white rounded-full px-5 h-12 gap-2 shadow-xl border-none font-bold"
                                        >
                                            <Check className="w-4 h-4" />
                                            <span>Connected</span>
                                        </Button>
                                    </motion.div>
                                ) : friendStatus === 'pending' ? (
                                    <Button
                                        onClick={() => onCancelRequest?.('connection')}
                                        className="bg-white/20 backdrop-blur-md hover:bg-red-500 text-white border border-white/30 rounded-full px-5 h-12 shadow-xl font-bold"
                                    >
                                        <Clock className="w-4 h-4" />
                                        <span>Sent</span>
                                    </Button>
                                ) : (
                                    <Button
                                        onClick={onConnect}
                                        className="bg-[#EF2F55] hover:bg-rose-600 text-white rounded-full px-8 h-12 shadow-xl shadow-pink-900/40 border-none font-bold active:scale-95 transition-all"
                                    >
                                        Connect
                                    </Button>
                                )
                            )}

                            <div className="flex gap-2">
                                {/* Photo Request */}
                                <Button
                                    onClick={photoStatus === 'pending' ? () => onCancelRequest?.('photo') : onRequestPhoto}
                                    className={`h-12 w-12 p-0 rounded-full backdrop-blur-md border border-white/30 shadow-xl transition-all ${photoStatus === 'granted' ? 'bg-green-500/80' : photoStatus === 'pending' ? 'bg-orange-500/50' : 'bg-white/10 hover:bg-white/20'}`}
                                >
                                    {photoStatus === 'granted' ? <Eye className="w-5 h-5 text-white" /> : <Lock className="w-5 h-5 text-white" />}
                                </Button>
                            </div>
                        </div>
                    </div>
                )}

                {/* Name & Basic Info Overlay */}
                <div className="absolute bottom-8 left-8 text-left z-10 space-y-2 pointer-events-none">
                    <h1 className="text-white font-playfair font-black text-4xl md:text-6xl drop-shadow-[0_4px_12px_rgba(0,0,0,0.6)] flex items-center gap-4">
                        {[user.first_name, user.last_name].filter(Boolean).join(' ') || "User"}
                        {user.age && <span className="text-2xl font-medium opacity-90">{user.age}</span>}
                        {user.is_franchise_created && (
                            <span className="bg-purple-600/90 backdrop-blur-md text-white text-[10px] md:text-xs px-3 py-1 rounded-full font-black uppercase tracking-widest border border-purple-400/30 flex items-center gap-1.5 shadow-xl animate-in zoom-in duration-500">
                                <span className="w-1.5 h-1.5 bg-white rounded-full animate-pulse" />
                                Created by Franchise
                            </span>
                        )}
                    </h1>

                    <div className="flex items-center gap-4 text-white/90 font-bold text-sm md:text-base drop-shadow-[0_2px_4px_rgba(0,0,0,0.6)]">
                        <div className="flex items-center gap-1.5">
                            <span className="bg-emerald-500 w-2 h-2 rounded-full animate-pulse shadow-[0_0_8px_rgba(16,185,129,0.8)]" />
                            <span>{user.isOnline ? "Online" : "Offline"}</span>
                        </div>
                        {user.city && (
                            <div className="flex items-center gap-1.5 backdrop-blur-md bg-black/20 px-3 py-1 rounded-full border border-white/10">
                                <span>{user.city}, {user.state}</span>
                            </div>
                        )}
                        {user.role === 'vendor' && user.vendor_details?.averageRating > 0 && (
                            <div className="flex items-center gap-1.5 backdrop-blur-md bg-yellow-400/20 px-3 py-1 rounded-full border border-yellow-400/30 text-yellow-400 font-black">
                                <Star className="w-4 h-4 fill-current" />
                                <span>{user.vendor_details.averageRating} ({user.vendor_details.reviewCount})</span>
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
};

export default ProfileHeader;
