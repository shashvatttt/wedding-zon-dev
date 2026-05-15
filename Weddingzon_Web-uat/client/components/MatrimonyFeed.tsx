import React from 'react';
import MatrimonyHero from '@/components/MatrimonyHero'; // Assuming this is the search hero which might be different from landing hero, but for now using same.
import BlurredMatrimonyFeed from '@/components/BlurredMatrimonyFeed';

// Placeholder for the real feed if user IS logged in (since we only have instructions for the blurred one)
// We will just show the unblurred version or a simple message for now.

const MatrimonyFeed = () => {
    return (
        <div className="min-h-screen pt-20 flex items-center justify-center bg-rose-50">
            <h1 className="text-2xl font-bold text-[#EF2F55]">Welcome to your Matrimony Feed!</h1>
        </div>
    );
}

export { MatrimonyFeed };
