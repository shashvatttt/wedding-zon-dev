'use client';

import { useState, useEffect } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { Heart, MessageCircle, Share2 } from 'lucide-react';
import MediaViewer from './MediaViewer';
import ShareDialog from './ShareDialog';
import { Card } from '@/components/ui/card';
import {
    Carousel,
    CarouselContent,
    CarouselItem,
    CarouselNext,
    CarouselPrevious,
} from '@/components/ui/carousel';
import { Button } from '@/components/ui/button';
import api from '../services/api';
import { useToast } from '../contexts/ToastContext';

interface FeedItemProps {
    user: {
        _id: string;
        first_name?: string;
        last_name?: string;
        username: string;
        profilePhoto: string; // Changed from avatar
        bio: string;
        photos: { url?: string; _id?: string; restricted?: boolean }[];
    };
    initialConnectionStatus?: 'none' | 'pending' | 'accepted' | 'rejected';
    initialPhotoStatus?: 'none' | 'pending' | 'granted' | 'rejected';
    readOnly?: boolean;
}

export default function FeedItem({ user, initialConnectionStatus = 'none', initialPhotoStatus = 'none', readOnly = false }: FeedItemProps) {
    const { addToast } = useToast();
    const [isViewerOpen, setIsViewerOpen] = useState(false);
    const [viewerIndex, setViewerIndex] = useState(0);
    const [connectionStatus, setConnectionStatus] = useState<'none' | 'pending' | 'accepted' | 'rejected'>(initialConnectionStatus);
    const [isLoading, setIsLoading] = useState(false);
    const [isShareOpen, setIsShareOpen] = useState(false);

    // N+1 Status check removed! Using initial props from bulk fetch.


    const handleConnect = async () => {
        if (connectionStatus !== 'none') return; // Already acted
        setIsLoading(true);
        try {
            await api.post(`/connections/request/${user._id}`);
            setConnectionStatus('pending');
            addToast("Connection request sent", 'success');
        } catch (error) {
            addToast("Failed to send request", 'error');
        } finally {
            setIsLoading(false);
        }
    };

    const onPhotoClick = (index: number, restricted?: boolean) => {
        if (!restricted) {
            setViewerIndex(index);
            setIsViewerOpen(true);
        }
    };

    const handleRequestAccess = async (targetUserId: string) => {
        setIsLoading(true);
        try {
            await api.post('/connections/request-photo-access', { targetUsername: user.username });
            addToast("Photo access request sent", 'success');
        } catch (error: any) {
            const msg = error.response?.data?.message || "Failed to send request";
            addToast(msg, 'error');
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <Card className="mb-8 border-border bg-card overflow-hidden shadow-sm hover:shadow-primary/5 transition-shadow">
            {/* Header */}
            <div className="flex items-center gap-3 p-4 bg-white/80 backdrop-blur-sm border-b border-gray-100">
                <Link href={`/${user.username}`} prefetch={false} className="relative w-12 h-12 rounded-full overflow-hidden border-2 border-white shadow-md cursor-pointer hover:border-[#EF2F55] transition-all">
                    <Image
                        src={user.profilePhoto || `https://ui-avatars.com/api/?name=${user.first_name || "User"}&background=random`}
                        alt={user.first_name || "User"}
                        fill
                        className="object-cover"
                        unoptimized // Important for external URLs like ui-avatars if not configured in next.config
                    />
                </Link>
                <div className="flex flex-col">
                    <Link href={`/${user.username}`} prefetch={false} className="font-serif font-bold text-base text-[var(--foreground)] hover:text-[#EF2F55] transition-colors">
                        {[user.first_name, user.last_name].filter(Boolean).join(' ') || user.username}
                    </Link>
                    <span className="text-xs font-medium text-[#EF2F55] uppercase tracking-wide">Premium Match</span>
                </div>
            </div>

            {/* Media Carousel */}
            <div className="relative w-full aspect-[4/5] bg-black">
                <Carousel className="w-full h-full">
                    <CarouselContent className="h-full ml-0">
                        {user.photos.map((photo, index) => (
                            <CarouselItem key={index} className="pl-0 h-full relative group">
                                {photo.restricted ? (
                                    <div className="w-full h-full relative overflow-hidden">
                                        <Image
                                            src={photo.url || '/default-avatar.png'}
                                            alt="Restricted content"
                                            fill
                                            className="object-cover blur-md scale-110 opacity-60"
                                            unoptimized
                                        />

                                        <div className="absolute inset-0 bg-black/40" />

                                        <div className="absolute inset-0 flex flex-col items-center justify-center p-6 text-center z-10">
                                            <div className="w-16 h-16 rounded-full bg-white/10 flex items-center justify-center mb-4 backdrop-blur-md border border-white/20 shadow-lg">
                                                <span className="text-3xl drop-shadow-md">🔒</span>
                                            </div>
                                            <h3 className="text-white font-bold text-lg mb-1 tracking-tight drop-shadow-md">Private Photo</h3>
                                            <p className="text-white/80 text-sm mb-4 font-medium drop-shadow-md">Request access to view this user's private photos</p>

                                            <Button
                                                size="sm"
                                                className="rounded-full bg-white/20 hover:bg-white/30 text-white border-white/10 backdrop-blur-md shadow-lg transition-all hover:scale-105"
                                                onClick={() => handleRequestAccess(user._id)}
                                                disabled={isLoading}
                                            >
                                                {isLoading ? "Sending..." : "Request Access"}
                                            </Button>
                                        </div>
                                    </div>
                                ) : (
                                    <div
                                        className="w-full h-full relative cursor-pointer"
                                        onClick={() => onPhotoClick(index, photo.restricted)}
                                    >
                                        <Image
                                            src={photo.url || ''}
                                            alt={`Photo of ${user.username}`}
                                            fill
                                            className="object-cover transition-transform duration-500 group-hover:scale-105"
                                            unoptimized
                                        />
                                    </div>
                                )}
                            </CarouselItem>
                        ))}
                    </CarouselContent>
                    {user.photos.length > 1 && (
                        <>
                            <CarouselPrevious className="left-2 bg-black/50 border-none text-white hover:bg-black/70 decoration-clone" />
                            <CarouselNext className="right-2 bg-black/50 border-none text-white hover:bg-black/70" />
                        </>
                    )}
                </Carousel>
            </div>

            {/* Actions */}
            <div className="flex flex-col p-4 gap-3 bg-white/50 backdrop-blur-sm">
                {!readOnly && (
                    <div className="flex gap-4">
                        <Button
                            variant="ghost"
                            size="icon"
                            onClick={handleConnect}
                            disabled={isLoading || connectionStatus !== 'none'}
                            className={`transition-all duration-300 hover:scale-110 ${connectionStatus === 'accepted' ? 'text-[var(--secondary)] bg-rose-50' :
                                connectionStatus === 'pending' ? 'text-rose-300 bg-rose-50/50' :
                                    'text-gray-400 hover:text-[var(--secondary)] hover:bg-rose-50'
                                }`}
                        >
                            <Heart className={`w-7 h-7 ${connectionStatus !== 'none' ? 'fill-current' : ''}`} />
                        </Button>
                        <Button variant="ghost" size="icon" className="text-gray-400 hover:text-[var(--primary)] hover:bg-rose-50 hover:scale-110 transition-all">
                            <MessageCircle className="w-6 h-6" />
                        </Button>
                        <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => setIsShareOpen(true)}
                            className="text-gray-400 hover:text-green-600 hover:bg-green-50 hover:scale-110 ml-auto transition-all"
                        >
                            <Share2 className="w-6 h-6" />
                        </Button>
                    </div>
                )}

                <div className="text-sm space-y-1">
                    <p className="font-serif text-lg font-bold text-[var(--foreground)]">
                        <Link href={`/${user.username}`} className="hover:text-[var(--secondary)] transition-colors">
                            {[user.first_name, user.last_name].filter(Boolean).join(' ') || user.username}
                        </Link>
                    </p>
                    <p className="text-gray-500 font-sans line-clamp-2 leading-relaxed">
                        {user.bio || "No bio available"}
                    </p>
                </div>
            </div>

            <MediaViewer
                isOpen={isViewerOpen}
                onClose={() => setIsViewerOpen(false)}
                initialIndex={viewerIndex}
                photos={user.photos}
            />

            <ShareDialog
                isOpen={isShareOpen}
                onClose={() => setIsShareOpen(false)}
                profile={user}
            />
        </Card>
    );
}
