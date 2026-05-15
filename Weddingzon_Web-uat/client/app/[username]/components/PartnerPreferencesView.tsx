import React from 'react';
import { Edit } from 'lucide-react';
import ProfileSection from './ProfileSection';

interface PartnerPreferencesViewProps {
    user: any;
    isOwner: boolean;
    onEdit: () => void;
}

const PartnerPreferencesView = ({ user, isOwner, onEdit }: PartnerPreferencesViewProps) => {
    const prefs = user.partner_preferences || {};

    const translateData = (category: string, value: string | undefined) => {
        return value || '';
    };

    return (
        <div className="flex flex-col gap-2">
            {/* Partner's Basic Details */}
            <ProfileSection
                title="Partner Basic Details"
                onEdit={isOwner ? onEdit : undefined}
            >
                <p className="text-gray-600 text-[15px] mb-6 font-medium italic">The profile you're looking for</p>
                <div className="space-y-3">
                    <PreferenceItem
                        label="Age Range"
                        value={prefs.minAge && prefs.maxAge ? `${prefs.minAge} Years - ${prefs.maxAge} Years` : "Not Specified"}
                    />
                    <PreferenceItem
                        label="Height Range"
                        value={prefs.minHeight && prefs.maxHeight ? `${prefs.minHeight} - ${prefs.maxHeight}` : "Not Specified"}
                    />
                    <PreferenceItem
                        label="Location"
                        value={prefs.location || "Doesn't Matter"}
                    />
                    <PreferenceItem
                        label="Marital Status"
                        value={translateData('marital_status', prefs.marital_status) || prefs.marital_status || "Never Married"}
                    />
                    <PreferenceItem
                        label="Profile Managed By"
                        value={translateData('profile_created_by', prefs.profile_managed_by) || prefs.profile_managed_by || "Doesn't Matter"}
                    />
                </div>
            </ProfileSection>

            {/* Partner's Education and Occupation */}
            <ProfileSection
                title="Education & Occupation"
                onEdit={isOwner ? onEdit : undefined}
            >
                <div className="space-y-4">
                    <div>
                        <p className="text-base font-bold text-gray-900 mb-1">Highest Degree</p>
                        <p className="text-base text-gray-700">
                            {prefs.education || "Not Specified"}
                        </p>
                    </div>
                    <div>
                        <p className="text-base font-bold text-gray-900 mb-1">UG College</p>
                        <p className="text-base text-gray-700">{prefs.college || "Doesn't Matter"}</p>
                    </div>
                    <div>
                        <p className="text-base font-bold text-gray-900 mb-1">Occupation</p>
                        <p className="text-base text-gray-700">{prefs.occupation || "Doesn't Matter"}</p>
                    </div>
                    <div>
                        <p className="text-base font-bold text-gray-900 mb-1">Income Range</p>
                        <p className="text-base text-gray-700">{prefs.annual_income || "Not Specified"}</p>
                    </div>
                </div>
            </ProfileSection>

            {/* Partner's Religion and Ethnicity */}
            <ProfileSection
                title="Religion & Ethnicity"
                onEdit={isOwner ? onEdit : undefined}
            >
                <div className="space-y-4">
                    <div>
                        <p className="text-sm font-medium text-gray-700 mb-1">Religion</p>
                        <p className="text-sm text-gray-600">{prefs.religion || "Doesn't Matter"}</p>
                    </div>
                    <div>
                        <p className="text-sm font-medium text-gray-700 mb-1">Caste / Community</p>
                        <p className="text-sm text-gray-600">
                            {prefs.caste || prefs.community || "Doesn't Matter"}
                        </p>
                    </div>
                    <div>
                        <p className="text-sm font-medium text-gray-700 mb-1">Mother Tongue</p>
                        <p className="text-sm text-gray-600">{prefs.mother_tongue || "Doesn't Matter"}</p>
                    </div>
                    <div>
                        <p className="text-sm font-medium text-gray-700 mb-1">Manglik Status</p>
                        <p className="text-sm text-gray-600">{translateData('manglik_status', prefs.manglik_status) || prefs.manglik_status || "Doesn't Matter"}</p>
                    </div>
                </div>
            </ProfileSection>

            {/* Partner's Family */}
            <ProfileSection
                title="Family Details"
                onEdit={isOwner ? onEdit : undefined}
            >
                <div className="space-y-4">
                    <div>
                        <p className="text-sm font-medium text-gray-700 mb-1">Family Type</p>
                        <p className="text-sm text-gray-600">{translateData('family_type', prefs.family_type) || prefs.family_type || "Doesn't Matter"}</p>
                    </div>
                </div>
            </ProfileSection>

            {/* Partner's Lifestyle and Appearance */}
            <ProfileSection
                title="Lifestyle & Appearance"
                onEdit={isOwner ? onEdit : undefined}
            >
                <div className="space-y-4">
                    <div>
                        <p className="text-sm font-medium text-gray-700 mb-1">Drinking Habits</p>
                        <p className="text-sm text-gray-600">{translateData('drinking_habits', prefs.drinking_habits) || prefs.drinking_habits || "Doesn't Matter"}</p>
                    </div>
                    <div>
                        <p className="text-sm font-medium text-gray-700 mb-1">Dietary Habits</p>
                        <p className="text-sm text-gray-600">{translateData('eating_habits', prefs.eating_habits) || prefs.eating_habits || "Doesn't Matter"}</p>
                    </div>
                    <div>
                        <p className="text-sm font-medium text-gray-700 mb-1">Smoking Habits</p>
                        <p className="text-sm text-gray-600">{translateData('smoking_habits', prefs.smoking_habits) || prefs.smoking_habits || "Doesn't Matter"}</p>
                    </div>
                    <div>
                        <p className="text-sm font-medium text-gray-700 mb-1">Special Cases</p>
                        <p className="text-sm text-gray-600">{prefs.special_cases || "Doesn't Matter"}</p>
                    </div>
                </div>
            </ProfileSection>

            {/* About My Partner */}
            <ProfileSection
                title="About Partner"
                onEdit={isOwner ? onEdit : undefined}
            >
                <div className="bg-gray-50 rounded-lg p-4 min-h-[100px]">
                    <p className="text-sm text-gray-600 italic">
                        {prefs.about_partner || "No partner details provided"}
                    </p>
                </div>
            </ProfileSection>
        </div>
    );
};

// Helper component for preference items
const PreferenceItem = ({ label, value }: { label: string; value: string }) => {
    return (
        <div className="flex items-start gap-4 py-1">
            <div className="w-6 h-6 flex items-center justify-center mt-1">
                <div className="w-5 h-5 rounded-full border-2 border-pink-100 flex items-center justify-center">
                    <div className="w-1.5 h-1.5 bg-[#EF2F55] rounded-full" />
                </div>
            </div>
            <div className="flex-1">
                <p className="text-[13px] font-black text-gray-400 uppercase tracking-widest mb-0.5">{label}</p>
                <p className="text-[17px] font-bold text-gray-900">{value}</p>
            </div>
        </div>
    );
};

export default PartnerPreferencesView;
