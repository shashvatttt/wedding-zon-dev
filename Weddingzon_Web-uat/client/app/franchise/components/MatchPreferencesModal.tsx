import { useState, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { X, Save } from 'lucide-react';
import api from '../../services/api';
import { useToast } from '../../contexts/ToastContext';

interface MatchPreferencesModalProps {
    profile: any;
    onClose: () => void;
    onSuccess: () => void;
    apiEndpoint?: string;
}

export default function MatchPreferencesModal({ profile, onClose, onSuccess, apiEndpoint }: MatchPreferencesModalProps) {
    const { addToast } = useToast();
    const [loading, setLoading] = useState(false);
    const [mounted, setMounted] = useState(false);
    const [formData, setFormData] = useState({
        minAge: 21,
        maxAge: 35,
        religion: '',
        community: '',
        caste: '',
        location: '',
        marital_status: '',
        profile_managed_by: '',
        eating_habits: '',
        smoking_habits: '',
        drinking_habits: '',
        minHeight: '',
        maxHeight: '',
        education: '',
        college: '',
        occupation: '',
        annual_income: '',
        mother_tongue: '',
        manglik_status: '',
        family_type: '',
        special_cases: '',
        about_partner: ''
    });

    useEffect(() => {
        setMounted(true);
        if (profile && profile.partner_preferences) {
            setFormData(prev => ({
                ...prev,
                ...profile.partner_preferences
            }));
        }
        return () => setMounted(false);
    }, [profile]);

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: value
        }));
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);

        try {
            const endpoint = apiEndpoint || `/franchise/profiles/${profile._id}/preferences`;
            await api.put(endpoint, {
                preferences: formData
            });
            onSuccess();
            onClose();
        } catch (err) {
            addToast('Failed to update preferences', 'error');
        } finally {
            setLoading(false);
        }
    };

    // Console log to confirm render cycle
    console.log('MatchPreferencesModal rendering', { mounted, isOpen: true });

    if (!mounted) return null;

    const modalContent = (
        <div
            className="fixed inset-0 z-[9999] flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-in fade-in duration-200"
            style={{
                position: 'fixed',
                top: 0,
                left: 0,
                width: '100vw',
                height: '100vh',
                zIndex: 99999
            }}
        >
            <div className="bg-white rounded-xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto transform transition-all scale-100">
                <div className="flex justify-between items-center p-6 border-b border-gray-100 sticky top-0 bg-white z-10">
                    <div>
                        <h2 className="text-xl font-bold text-gray-900">Partner Preferences</h2>
                        <p className="text-sm text-gray-500">For {profile?.first_name || ''} {profile?.last_name || ''}</p>
                    </div>
                    <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-full transition-colors">
                        <X className="h-6 w-6 text-gray-500" />
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="p-6 space-y-6">
                    {/* Basic Requirements */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Min Age</label>
                            <input
                                type="number"
                                name="minAge"
                                value={formData.minAge}
                                onChange={handleChange}
                                className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Max Age</label>
                            <input
                                type="number"
                                name="maxAge"
                                value={formData.maxAge}
                                onChange={handleChange}
                                className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                            />
                        </div>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Marital Status</label>
                            <select
                                name="marital_status"
                                value={formData.marital_status}
                                onChange={handleChange}
                                className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                            >
                                <option value="">Any</option>
                                <option value="Never Married">Never Married</option>
                                <option value="Divorced">Divorced</option>
                                <option value="Widowed">Widowed</option>
                                <option value="Awaiting Divorce">Awaiting Divorce</option>
                            </select>
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Religion</label>
                            <select
                                name="religion"
                                value={formData.religion}
                                onChange={handleChange}
                                className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                            >
                                <option value="">Any</option>
                                <option value="Hindu">Hindu</option>
                                <option value="Muslim">Muslim</option>
                                <option value="Christian">Christian</option>
                                <option value="Sikh">Sikh</option>
                                <option value="Buddhist">Buddhist</option>
                                <option value="Jain">Jain</option>
                                <option value="Parsi">Parsi</option>
                                <option value="Jewish">Jewish</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Community</label>
                            <input
                                type="text"
                                name="community"
                                placeholder="e.g. Brahmin, Sunni"
                                value={formData.community}
                                onChange={handleChange}
                                className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                            />
                        </div>
                    </div>

                    {/* Height Range */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Min Height</label>
                            <input
                                type="text"
                                name="minHeight"
                                placeholder="e.g. 5'0&quot;"
                                value={formData.minHeight}
                                onChange={handleChange}
                                className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Max Height</label>
                            <input
                                type="text"
                                name="maxHeight"
                                placeholder="e.g. 6'0&quot;"
                                value={formData.maxHeight}
                                onChange={handleChange}
                                className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                            />
                        </div>
                    </div>

                    {/* Profile Managed By */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Profile Managed By</label>
                        <select
                            name="profile_managed_by"
                            value={formData.profile_managed_by}
                            onChange={handleChange}
                            className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                        >
                            <option value="">Doesn't Matter</option>
                            <option value="Self">Self</option>
                            <option value="Parents">Parents</option>
                            <option value="Sibling">Sibling</option>
                            <option value="Friend">Friend</option>
                            <option value="Relative">Relative</option>
                        </select>
                    </div>

                    {/* Education & Occupation */}
                    <div className="border-t border-gray-100 pt-4">
                        <h3 className="text-md font-semibold text-gray-900 mb-3">Education & Occupation</h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Education</label>
                                <input
                                    type="text"
                                    name="education"
                                    placeholder="e.g. B.Tech, MBA"
                                    value={formData.education}
                                    onChange={handleChange}
                                    className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">College/University</label>
                                <input
                                    type="text"
                                    name="college"
                                    placeholder="College name"
                                    value={formData.college}
                                    onChange={handleChange}
                                    className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Occupation</label>
                                <input
                                    type="text"
                                    name="occupation"
                                    placeholder="e.g. Software Engineer"
                                    value={formData.occupation}
                                    onChange={handleChange}
                                    className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                                />
                            </div>
                        </div>
                    </div>

                    {/* Religion & Ethnicity */}
                    <div className="border-t border-gray-100 pt-4">
                        <h3 className="text-md font-semibold text-gray-900 mb-3">Religion & Ethnicity</h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Caste</label>
                                <input
                                    type="text"
                                    name="caste"
                                    placeholder="e.g. Brahmin, Kshatriya"
                                    value={formData.caste}
                                    onChange={handleChange}
                                    className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Mother Tongue</label>
                                <input
                                    type="text"
                                    name="mother_tongue"
                                    placeholder="e.g. Hindi, Punjabi"
                                    value={formData.mother_tongue}
                                    onChange={handleChange}
                                    className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Manglik Status</label>
                                <select
                                    name="manglik_status"
                                    value={formData.manglik_status}
                                    onChange={handleChange}
                                    className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                                >
                                    <option value="">Doesn't Matter</option>
                                    <option value="Manglik">Manglik</option>
                                    <option value="Non-Manglik">Non-Manglik</option>
                                    <option value="Anshik Manglik">Anshik Manglik</option>
                                    <option value="Don't Know">Don't Know</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    {/* Family */}
                    <div className="border-t border-gray-100 pt-4">
                        <h3 className="text-md font-semibold text-gray-900 mb-3">Family</h3>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Family Type</label>
                            <select
                                name="family_type"
                                value={formData.family_type}
                                onChange={handleChange}
                                className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                            >
                                <option value="">Doesn't Matter</option>
                                <option value="Nuclear">Nuclear</option>
                                <option value="Joint">Joint</option>
                            </select>
                        </div>
                    </div>

                    {/* Lifestyle */}
                    <div className="border-t border-gray-100 pt-4">
                        <h3 className="text-md font-semibold text-gray-900 mb-3">Lifestyle Preferences</h3>
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Diet</label>
                                <select
                                    name="eating_habits"
                                    value={formData.eating_habits}
                                    onChange={handleChange}
                                    className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                                >
                                    <option value="">Any</option>
                                    <option value="Vegetarian">Vegetarian</option>
                                    <option value="Non-Vegetarian">Non-Vegetarian</option>
                                    <option value="Eggetarian">Eggetarian</option>
                                    <option value="Vegan">Vegan</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Smoking</label>
                                <select
                                    name="smoking_habits"
                                    value={formData.smoking_habits}
                                    onChange={handleChange}
                                    className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                                >
                                    <option value="">Any</option>
                                    <option value="No">No</option>
                                    <option value="Yes">Yes</option>
                                    <option value="Occasionally">Occasionally</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Drinking</label>
                                <select
                                    name="drinking_habits"
                                    value={formData.drinking_habits}
                                    onChange={handleChange}
                                    className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                                >
                                    <option value="">Any</option>
                                    <option value="No">No</option>
                                    <option value="Yes">Yes</option>
                                    <option value="Occasionally">Occasionally</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    {/* Location & Income */}
                    <div className="border-t border-gray-100 pt-4">
                        <h3 className="text-md font-semibold text-gray-900 mb-3">Location & Income</h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Location Preferred</label>
                                <input
                                    type="text"
                                    name="location"
                                    placeholder="City or State"
                                    value={formData.location}
                                    onChange={handleChange}
                                    className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Annual Income (Min)</label>
                                <select
                                    name="annual_income"
                                    value={formData.annual_income}
                                    onChange={handleChange}
                                    className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                                >
                                    <option value="">Any</option>
                                    <option value="0-3 LPA">0-3 LPA</option>
                                    <option value="3-6 LPA">3-6 LPA</option>
                                    <option value="6-10 LPA">6-10 LPA</option>
                                    <option value="10-15 LPA">10-15 LPA</option>
                                    <option value="15-25 LPA">15-25 LPA</option>
                                    <option value="25-50 LPA">25-50 LPA</option>
                                    <option value="50+ LPA">50+ LPA</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    {/* Special Cases */}
                    <div className="border-t border-gray-100 pt-4">
                        <h3 className="text-md font-semibold text-gray-900 mb-3">Special Cases</h3>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Special Cases</label>
                            <input
                                type="text"
                                name="special_cases"
                                placeholder="Any special requirements"
                                value={formData.special_cases}
                                onChange={handleChange}
                                className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                            />
                        </div>
                    </div>

                    {/* About Partner */}
                    <div className="border-t border-gray-100 pt-4">
                        <h3 className="text-md font-semibold text-gray-900 mb-3">About My Partner</h3>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Describe your ideal partner</label>
                            <textarea
                                name="about_partner"
                                rows={4}
                                placeholder="Write your thoughts about your ideal partner..."
                                value={formData.about_partner}
                                onChange={handleChange}
                                className="w-full rounded-lg border-gray-300 focus:border-orange-500 focus:ring-orange-500"
                            />
                        </div>
                    </div>

                    <div className="pt-4 flex items-center justify-end gap-3 sticky bottom-0 bg-white border-t border-gray-100 mt-6">
                        <button
                            type="button"
                            onClick={onClose}
                            className="px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 rounded-lg transition-colors"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            disabled={loading}
                            className="flex items-center gap-2 px-6 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors shadow-sm disabled:opacity-70 font-medium"
                        >
                            {loading ? (
                                <div className="h-4 w-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                            ) : (
                                <Save className="h-4 w-4" />
                            )}
                            Save Preferences
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );

    return createPortal(modalContent, document.body);
}
