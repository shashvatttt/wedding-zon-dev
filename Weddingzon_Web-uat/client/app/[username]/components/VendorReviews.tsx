'use client';

import React, { useState, useEffect } from 'react';
import { Star, User, MessageSquare } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useToast } from '@/app/contexts/ToastContext';
import api from '@/app/services/api';

interface Review {
    _id: string;
    reviewer?: {
        _id: string;
        first_name: string;
        last_name: string;
        profilePhoto?: string;
    };
    reviewerName: string;
    reviewerEmail: string;
    rating: number;
    comment: string;
    created_at: string;
}

interface VendorReviewsProps {
    vendorId: string;
    isOwner: boolean;
}

export default function VendorReviews({ vendorId, isOwner }: VendorReviewsProps) {
    const { addToast } = useToast();
    const [reviews, setReviews] = useState<Review[]>([]);
    const [loading, setLoading] = useState(true);
    const [showReviewForm, setShowReviewForm] = useState(true);
    const [rating, setRating] = useState(0);
    const [comment, setComment] = useState('');
    const [reviewerName, setReviewerName] = useState('');
    const [reviewerEmail, setReviewerEmail] = useState('');
    const [submitting, setSubmitting] = useState(false);
    const [currentUser, setCurrentUser] = useState<any>(null);

    useEffect(() => {
        const fetchMe = async () => {
            try {
                const res = await api.get('/auth/me');
                setCurrentUser(res.data);
                setReviewerName(`${res.data.first_name} ${res.data.last_name || ''}`.trim());
                setReviewerEmail(res.data.email || '');
            } catch (err) {
                // Guest
            }
        };
        fetchMe();
    }, []);

    const fetchReviews = async () => {
        try {
            const res = await api.get(`/vendor-features/reviews/${vendorId}`);
            setReviews(res.data.data);
        } catch (error) {
            console.error('Failed to fetch reviews', error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchReviews();
    }, [vendorId]);

    const handleSubmitReview = async () => {
        if (rating === 0) {
            addToast("Please select a rating", 'error');
            return;
        }
        if (!comment.trim()) {
            addToast("Please enter a comment", 'error');
            return;
        }
        if (!reviewerName.trim()) {
            addToast("Please enter your name", 'error');
            return;
        }
        if (!reviewerEmail.trim()) {
            addToast("Please enter your email", 'error');
            return;
        }

        // Email Validation
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(reviewerEmail)) {
            addToast("Please enter a valid email address", 'error');
            return;
        }

        setSubmitting(true);
        try {
            await api.post('/vendor-features/reviews', {
                vendorId,
                rating,
                comment,
                reviewerName,
                reviewerEmail
            });
            addToast("Review posted successfully", 'success');
            setShowReviewForm(false);
            setRating(0);
            setComment('');
            // Don't reset name/email if they are precious
            fetchReviews();
        } catch (error: any) {
            addToast(error.response?.data?.message || "Failed to post review", 'error');
        } finally {
            setSubmitting(false);
        }
    };

    if (loading) return <div className="text-gray-400 py-10 text-center animate-pulse">Loading reviews...</div>;

    return (
        <div className="space-y-8">
            <div className="flex items-center justify-between">
                <h3 className="text-2xl font-bold text-gray-900">Reviews ({reviews.length})</h3>
                {!isOwner && showReviewForm === false && (
                    <Button
                        onClick={() => setShowReviewForm(true)}
                        className="bg-[#EF2F55] hover:bg-rose-700 text-white rounded-full font-bold px-6"
                    >
                        Write a Review
                    </Button>
                )}
            </div>

            {showReviewForm && !isOwner && (
                <div className="bg-white p-8 rounded-[32px] border border-gray-100 shadow-xl shadow-gray-100/50 space-y-8 animate-in fade-in slide-in-from-top-4 duration-500 overflow-hidden relative">
                    {/* Header with Pencil Icon */}
                    <div className="flex items-center gap-3 border-b border-gray-50 pb-6 mb-2">
                        <div className="w-10 h-10 bg-rose-50 rounded-full flex items-center justify-center">
                            <svg className="w-5 h-5 text-[#EF2F55]" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                <path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z" />
                            </svg>
                        </div>
                        <h4 className="text-xl font-bold text-[#1A1A1A] font-serif">Write A Review</h4>
                    </div>

                    {/* Centered Star Rating */}
                    <div className="flex flex-col items-center gap-3 py-2">
                        <div className="flex gap-2">
                            {[1, 2, 3, 4, 5].map((s) => (
                                <Star
                                    key={s}
                                    className={`w-10 h-10 cursor-pointer transition-all duration-300 transform hover:scale-110 ${s <= rating ? 'fill-yellow-400 text-yellow-400' : 'text-gray-200'}`}
                                    onClick={() => setRating(s)}
                                />
                            ))}
                        </div>
                    </div>

                    {/* Comment Textarea */}
                    <div className="space-y-2">
                        <textarea
                            value={comment}
                            onChange={(e) => setComment(e.target.value)}
                            placeholder="Your Comments"
                            className="w-full p-6 rounded-2xl border border-gray-100 focus:outline-none focus:ring-2 focus:ring-[#EF2F55]/20 focus:border-[#EF2F55] min-h-[180px] bg-gray-50/50 text-gray-700 placeholder:text-gray-400 text-base font-medium transition-all"
                        />
                    </div>

                    {/* Name & Email Fields */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <input
                            type="text"
                            value={reviewerName}
                            onChange={(e) => setReviewerName(e.target.value)}
                            placeholder="Enter your name"
                            className="w-full p-4 rounded-xl border border-gray-100 focus:outline-none focus:ring-2 focus:ring-[#EF2F55]/20 focus:border-[#EF2F55] bg-gray-50/50 text-gray-700 placeholder:text-gray-400 font-medium transition-all"
                        />
                        <input
                            type="email"
                            value={reviewerEmail}
                            onChange={(e) => setReviewerEmail(e.target.value)}
                            placeholder="Enter your email"
                            className="w-full p-4 rounded-xl border border-gray-100 focus:outline-none focus:ring-2 focus:ring-[#EF2F55]/20 focus:border-[#EF2F55] bg-gray-50/50 text-gray-700 placeholder:text-gray-400 font-medium transition-all"
                        />
                    </div>

                    {/* Submit Button */}
                    <div className="flex justify-start">
                        <Button
                            onClick={handleSubmitReview}
                            disabled={submitting}
                            className="bg-[#EF2F55] hover:bg-rose-700 text-white px-10 py-7 rounded-lg font-bold text-lg shadow-lg shadow-rose-100 transition-all hover:-translate-y-0.5 active:translate-y-0"
                        >
                            {submitting ? "Posting..." : "Post Your Comment"}
                        </Button>
                    </div>
                </div>
            )}

            <div className="space-y-6">
                {reviews.length === 0 ? (
                    <div className="bg-gray-50/50 p-10 rounded-3xl border border-dashed border-gray-200 text-center">
                        <MessageSquare className="w-12 h-12 text-gray-300 mx-auto mb-3" />
                        <p className="text-gray-400 font-medium">No reviews yet. Be the first to write one!</p>
                    </div>
                ) : (
                    reviews.map((review) => (
                        <div key={review._id} className="bg-white p-6 rounded-3xl border border-gray-50 shadow-sm flex flex-col sm:flex-row gap-4 items-start text-left">
                            <div className="w-12 h-12 rounded-full bg-gray-100 flex-shrink-0 overflow-hidden relative border-2 border-white shadow-sm">
                                {review.reviewer?.profilePhoto ? (
                                    <img src={review.reviewer.profilePhoto} alt="Reviewer" className="w-full h-full object-cover" />
                                ) : (
                                    <div className="w-full h-full flex items-center justify-center text-gray-400 bg-rose-50 font-bold">
                                        {(review.reviewer?.first_name || review.reviewerName)?.[0]?.toUpperCase()}
                                    </div>
                                )}
                            </div>
                            <div className="flex-1 space-y-2">
                                <div className="flex items-center justify-between">
                                    <h4 className="font-bold text-gray-900">
                                        {review.reviewer ? `${review.reviewer.first_name} ${review.reviewer.last_name}` : review.reviewerName}
                                    </h4>
                                    <span className="text-[10px] text-gray-400 font-bold uppercase tracking-widest">
                                        {new Date(review.created_at).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })}
                                    </span>
                                </div>
                                <div className="flex gap-0.5">
                                    {[1, 2, 3, 4, 5].map((s) => (
                                        <Star
                                            key={s}
                                            className={`w-3.5 h-3.5 ${s <= review.rating ? 'fill-yellow-400 text-yellow-400' : 'text-gray-200'}`}
                                        />
                                    ))}
                                </div>
                                <p className="text-gray-600 text-sm leading-relaxed italic">
                                    "{review.comment}"
                                </p>
                            </div>
                        </div>
                    ))
                )}
            </div>
        </div>
    );
}
