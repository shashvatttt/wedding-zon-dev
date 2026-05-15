import React from 'react';
import Image from 'next/image';
import { useRouter } from 'next/navigation';
import { ChevronRight, Camera } from 'lucide-react';
import { calculateProfileCompletion } from '@/lib/profileCompletion';

interface ProfileCompletionCardProps {
    user: any;
}


const ProfileCompletionCard = ({ user, onPhotoEdit }: { user: any, onPhotoEdit?: () => void }) => {
    const router = useRouter();
    const completionPercentage = calculateProfileCompletion(user);

    // SVG Circle properties
    const radius = 30;
    const circumference = 2 * Math.PI * radius;
    const strokeDashoffset = circumference - (completionPercentage / 100) * circumference;

    return (
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 mb-6 relative overflow-hidden">
            <div className="flex items-start gap-4">
                {/* Profile Image Circle with Progress Border */}
                <div
                    className="relative w-16 h-16 flex-shrink-0 cursor-pointer group/pfp"
                    onClick={onPhotoEdit}
                >
                    <svg className="absolute inset-0 w-full h-full -rotate-90">
                        {/* Background Ring */}
                        <circle
                            cx="32"
                            cy="32"
                            r={radius}
                            fill="transparent"
                            stroke="#f3f4f6"
                            strokeWidth="3"
                        />
                        {/* Progress Ring */}
                        <circle
                            cx="32"
                            cy="32"
                            r={radius}
                            fill="transparent"
                            stroke="#EF2F55"
                            strokeWidth="3"
                            strokeDasharray={circumference}
                            style={{ strokeDashoffset, transition: 'stroke-dashoffset 1s ease-in-out' }}
                            strokeLinecap="round"
                        />
                    </svg>

                    <div className="absolute inset-[4px] rounded-full overflow-hidden bg-gray-200">
                        <Image
                            src={user.profilePhoto || '/default-avatar.png'}
                            alt="Profile Photo"
                            fill
                            className="object-cover group-hover/pfp:scale-110 transition-transform"
                        />
                        <div className="absolute inset-0 bg-black/20 opacity-0 group-hover/pfp:opacity-100 transition-opacity flex items-center justify-center">
                            <Camera className="w-4 h-4 text-white" />
                        </div>
                    </div>
                    {/* Small Red Circle Indicator */}
                    <div className="absolute top-0 right-0 w-4 h-4 bg-[#EF2F55] rounded-full border-2 border-white" />
                </div>

                <div className="flex-1 pt-1">
                    <h3 className="font-playfair font-black text-gray-900 text-[15px] leading-tight">
                        {completionPercentage}% Profile Complete
                    </h3>
                    <p className="text-gray-500 text-[11px] font-medium mt-1 uppercase tracking-wider">Add more details to attract matches</p>

                    <div
                        className="flex items-center mt-3 cursor-pointer group w-fit"
                        onClick={() => router.push('/onboarding')}
                    >
                        <span className="text-[#EF2F55] font-black text-[11px] uppercase tracking-widest group-hover:underline flex items-center gap-1">
                            Complete Profile
                            <ChevronRight className="w-3.5 h-3.5" />
                        </span>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default ProfileCompletionCard;
