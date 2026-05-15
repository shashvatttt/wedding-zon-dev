import React from 'react';

interface ProfileTabsProps {
    activeTab: 'profile' | 'preferences' | 'reviews';
    onTabChange: (tab: 'profile' | 'preferences' | 'reviews') => void;
    userRole?: string;
}


const ProfileTabs = ({ activeTab, onTabChange, userRole }: ProfileTabsProps) => {
    return (
        <div className="flex items-center gap-6 md:gap-10 mb-8 px-4 border-b border-gray-100 overflow-x-auto no-scrollbar">
            {userRole === 'vendor' ? (
                <div
                    className="cursor-pointer pb-4 relative group shrink-0"
                    onClick={() => onTabChange('reviews')}
                >
                    <h2 className={`font-playfair font-black text-xl md:text-2xl transition-all ${activeTab === 'reviews'
                        ? 'text-[#EF2F55]'
                        : 'text-gray-400 group-hover:text-gray-900'
                        }`}>
                        Reviews
                    </h2>
                    {activeTab === 'reviews' && (
                        <div className="absolute bottom-0 left-0 right-0 h-1 bg-[#EF2F55] rounded-full animate-in fade-in slide-in-from-bottom-1" />
                    )}
                </div>
            ) : (
                <div
                    className="cursor-pointer pb-4 relative group shrink-0"
                    onClick={() => onTabChange('profile')}
                >
                    <h2 className={`font-playfair font-black text-xl md:text-2xl transition-all ${activeTab === 'profile'
                        ? 'text-[#EF2F55]'
                        : 'text-gray-400 group-hover:text-gray-900'
                        }`}>
                        Profile
                    </h2>
                    {activeTab === 'profile' && (
                        <div className="absolute bottom-0 left-0 right-0 h-1 bg-[#EF2F55] rounded-full animate-in fade-in slide-in-from-bottom-1" />
                    )}
                </div>
            )}

            <div
                className="cursor-pointer pb-4 relative group shrink-0"
                onClick={() => onTabChange('preferences')}
            >
                <h2 className={`font-playfair font-black text-xl md:text-2xl transition-all ${activeTab === 'preferences'
                    ? 'text-[#EF2F55]'
                    : 'text-gray-400 group-hover:text-gray-900'
                    }`}>
                    Partner Preferences
                </h2>
                {activeTab === 'preferences' && (
                    <div className="absolute bottom-0 left-0 right-0 h-1 bg-[#EF2F55] rounded-full animate-in fade-in slide-in-from-bottom-1" />
                )}
            </div>
        </div>
    );
};

export default ProfileTabs;
