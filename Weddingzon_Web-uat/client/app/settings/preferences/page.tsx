'use client';

import MatchPreferences from '../../components/MatchPreferences';
import FeedHeader from '../../feed/components/FeedHeader';
import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';

export default function PreferencesPage() {
    return (
        <div className="min-h-screen bg-[#FFF9FA]">
            <FeedHeader />
            <div className="max-w-4xl mx-auto pt-[100px] px-4 pb-10">
                <div className="mb-6 flex items-center gap-4">
                    <Link href="/feed" className="p-2 hover:bg-gray-100 rounded-full transition-colors">
                        <ArrowLeft className="h-5 w-5 text-gray-600" />
                    </Link>
                    <h1 className="text-2xl font-bold text-gray-900">Settings</h1>
                </div>

                <MatchPreferences />
            </div>
        </div>
    );
}
