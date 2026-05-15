import React, { useRef, useEffect } from 'react';
import api from '../services/api';
import FeedCard from '../feed/components/FeedCard'; // Updated import
import useSWRInfinite from 'swr/infinite';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { StaggerContainer, StaggerItem } from '@/components/animations/StaggerContainer';
import { FadeIn } from '@/components/animations/FadeIn';
import { motion, AnimatePresence } from 'framer-motion';
import useSWR from 'swr';
import AdCard from '../feed/components/AdCard';

interface FeedUser {
    _id: string;
    first_name?: string;
    last_name?: string;
    username: string;
    profilePhoto: string;
    bio: string;
    photos: { url: string; _id?: string }[];
    role?: string;
    connectionStatus?: 'none' | 'pending' | 'accepted' | 'rejected';
    photoRequestStatus?: 'none' | 'pending' | 'granted' | 'rejected';

    // Add other fields that might come from backend even if optional
    age?: number;
    height?: string;
    city?: string;
    caste?: string;
    religion?: string;
    education?: string;
    occupation?: string;
    income?: string;
    marital_status?: string;
    isOnline?: boolean;
    lastSeen?: string;
}

const fetcher = (url: string) => api.get(url).then(res => res.data);

import { useSearchParams } from 'next/navigation';

const Feed = ({ viewAs, readOnly = false, onOnlineCountUpdate }: { viewAs?: string | null, readOnly?: boolean, onOnlineCountUpdate?: (count: number) => void }) => {
    const searchParams = useSearchParams();
    const sort = searchParams.get('sort');

    // SWR Infinite Key Logic
    const getKey = (pageIndex: number, previousPageData: any) => {
        // If reached end (no data or no next cursor), return null
        if (previousPageData && !previousPageData.nextCursor) return null;

        const base = `/users/feed`;
        const params = new URLSearchParams(searchParams.toString()); // Copy all existing params (filters)

        if (viewAs) params.set('viewAs', viewAs); // Ensure viewAs override if prop exists
        // sort is already in searchParams

        // First page
        if (pageIndex === 0) return `${base}?${params.toString()}`;

        // Subsequent pages
        params.append('cursor', previousPageData.nextCursor);
        return `${base}?${params.toString()}`;
    };

    // Fetch Ads
    const { data: adsData } = useSWR('/ads/active', fetcher);
    const ads = adsData?.data || [];

    const { data, size, setSize, isLoading, isValidating } = useSWRInfinite(
        getKey,
        fetcher,
        {
            revalidateFirstPage: false,
            revalidateOnFocus: false, // Prevent shuffling on window focus
            persistSize: true, // Keep page size on navigation
        }
    );

    // Flatten users from all pages
    const feedUsers: FeedUser[] = data ? data.flatMap(page => page.data) : [];

    // Notify about online count (from the first page of data)
    useEffect(() => {
        if (data?.[0]?.onlineCount !== undefined && onOnlineCountUpdate) {
            onOnlineCountUpdate(data[0].onlineCount);
        }
    }, [data, onOnlineCountUpdate]);

    // Check if we have more data to load
    const isEmpty = data?.[0]?.data?.length === 0;
    const isReachingEnd = isEmpty || (data && !data[data.length - 1]?.nextCursor);

    const loaderRef = useRef<HTMLDivElement>(null);

    // Infinite Scroll Observer
    useEffect(() => {
        const observer = new IntersectionObserver((entries) => {
            if (entries[0].isIntersecting && !isReachingEnd && !isValidating) {
                setSize((size: number) => size + 1);
            }
        }, { threshold: 0.1, rootMargin: '200px' });

        if (loaderRef.current) {
            observer.observe(loaderRef.current);
        }

        return () => observer.disconnect();
    }, [isReachingEnd, isValidating, setSize]);

    return (
        <div className="flex flex-col w-full pb-10">
            {feedUsers.length === 0 && !isLoading ? (
                <FadeIn className="text-center py-20 text-zinc-500 flex flex-col items-center gap-4">
                    <div>
                        <p className="text-lg font-medium text-gray-900">No matches found</p>
                        <p className="text-sm mt-2">Try adjusting your filters to see more results.</p>
                    </div>
                    <div className="flex gap-3 mt-4">
                        <Link href="?openFilters=true" scroll={false}>
                            <Button variant="outline" className="rounded-full border-rose-200 text-rose-600 hover:bg-rose-50">Edit Preferences</Button>
                        </Link>
                        <Button
                            variant="ghost"
                            className="rounded-full text-zinc-500 hover:text-zinc-700 hover:bg-zinc-100"
                            onClick={async () => {
                                try {
                                    await api.put('/users/preferences', { reset: true });
                                    // Refresh the feed
                                    window.location.href = '/feed';
                                } catch (error) {
                                    console.error('Failed to reset preferences', error);
                                }
                            }}
                        >
                            Reset & Show All
                        </Button>
                    </div>
                </FadeIn>
            ) : (
                <div className="flex flex-col gap-6">
                    {/* Fallback Banner */}
                    {data?.[0]?.isFallback && (
                        <FadeIn duration={0.5}>
                            <div className="bg-rose-50 border border-rose-200 rounded-lg p-4 mb-4 flex flex-col md:flex-row items-center justify-between gap-4 text-center md:text-left">
                                <div>
                                    <h3 className="text-rose-800 font-semibold">Broadening your search</h3>
                                    <p className="text-rose-600 text-sm">
                                        We couldn't find exact matches, so we're showing you all available profiles.
                                    </p>
                                </div>
                                <Button
                                    variant="outline"
                                    className="bg-white border-rose-200 text-rose-600 hover:bg-rose-100 whitespace-nowrap"
                                    onClick={() => window.location.href = '?openFilters=true'}
                                >
                                    Refine Search
                                </Button>
                            </div>
                        </FadeIn>
                    )}

                    <AnimatePresence mode="popLayout">
                        {feedUsers.map((user, idx) => {
                            const showAd = (idx + 1) % 5 === 0;
                            const adIndex = Math.floor(idx / 5) % ads.length;
                            const ad = ads[adIndex];

                            return (
                                <React.Fragment key={user._id}>
                                    <StaggerItem
                                        layout
                                        initial={{ opacity: 0, scale: 0.95 }}
                                        animate={{ opacity: 1, scale: 1 }}
                                        exit={{ opacity: 0, scale: 0.95 }}
                                        transition={{ duration: 0.3 }}
                                    >
                                        <FeedCard
                                            user={user}
                                            initialConnectionStatus={user.connectionStatus || 'none'}
                                        />
                                    </StaggerItem>
                                    
                                    {showAd && ad && (
                                        <StaggerItem
                                            key={`ad-${ad._id}-${idx}`}
                                            layout
                                            initial={{ opacity: 0, scale: 0.95 }}
                                            animate={{ opacity: 1, scale: 1 }}
                                            exit={{ opacity: 0, scale: 0.95 }}
                                            transition={{ duration: 0.3 }}
                                        >
                                            <AdCard ad={ad} />
                                        </StaggerItem>
                                    )}
                                </React.Fragment>
                            );
                        })}
                    </AnimatePresence>
                </div>
            )}

            <div ref={loaderRef} className="flex justify-center p-6 h-20 items-center">
                {(isLoading || isValidating) && (
                    <div className="flex flex-col items-center gap-2">
                        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-pink-500"></div>
                        <span className="text-xs text-pink-400 font-medium">Loading more love...</span>
                    </div>
                )}
                {isReachingEnd && feedUsers.length > 0 && (
                    <div className="text-zinc-400 text-sm font-medium">
                        You're all caught up! ✨
                    </div>
                )}
            </div>
        </div>
    );
};

export default Feed;
