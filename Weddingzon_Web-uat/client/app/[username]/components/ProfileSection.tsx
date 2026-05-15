import React, { ReactNode } from 'react';
import { Pencil, Lock } from 'lucide-react';

interface ProfileSectionProps {
    title: string;
    children: ReactNode;
    onEdit?: () => void;
    onAdd?: () => void;
    showAdd?: boolean;
    restricted?: boolean;
    status?: 'none' | 'pending' | 'granted' | 'rejected';
    onRequestAccess?: () => void;
}

const ProfileSection = ({
    title,
    children,
    onEdit,
    onAdd,
    showAdd = true,
    restricted = false,
    status = 'none',
    onRequestAccess
}: ProfileSectionProps) => {
    return (
        <div className="bg-white rounded-[24px] shadow-[0_4px_20px_rgba(0,0,0,0.03)] border border-gray-50 p-8 mb-6 relative overflow-hidden group hover:border-pink-100/50 transition-all duration-300">
            <div className="flex justify-between items-start mb-6">
                <h3 className="font-playfair font-bold text-xl text-gray-900 tracking-tight">{title}</h3>
                {/* Edit Icon - Only show if not restricted */}
                {!restricted && (
                    <button onClick={onEdit} className="text-gray-400 hover:text-gray-600">
                        <Pencil className="w-4 h-4" />
                    </button>
                )}
            </div>

            <div className={`space-y-4 transition-all duration-300 ${restricted ? 'blur-sm select-none opacity-50' : ''}`}>
                {children}
            </div>

            {/* Restricted Overlay */}
            {restricted && (
                <div className="absolute inset-0 flex flex-col items-center justify-center bg-white/10 backdrop-blur-[2px] z-10 p-4 text-center">
                    <div className="bg-white p-4 rounded-full shadow-lg mb-3">
                        <Lock className="w-6 h-6 text-gray-400" />
                    </div>
                    <h4 className="text-gray-900 font-semibold mb-1">Details Locked</h4>
                    <p className="text-gray-500 text-sm mb-4 max-w-[200px]">
                        This section is visible to connected members only.
                    </p>
                    <button
                        onClick={onRequestAccess}
                        disabled={status === 'pending'}
                        className={`px-6 py-2 text-white text-sm font-medium rounded-full shadow-md transition-colors ${status === 'pending'
                            ? 'bg-gray-400 cursor-not-allowed'
                            : 'bg-[#EF2F55] hover:bg-[#D41F45]'
                            }`}
                    >
                        {status === 'pending' ? "Request Sent" : "Request Access"}
                    </button>
                </div>
            )}

            {onAdd && !restricted && (
                <div className="flex justify-end mt-4">
                    <button onClick={onAdd} className="text-[#EF2F55] font-medium text-sm hover:underline">
                        Add
                    </button>
                </div>
            )}
        </div>
    );
};

export default ProfileSection;
