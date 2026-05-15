'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import api from '../services/api';
import { useToast } from '../contexts/ToastContext';
import { Save, Loader2 } from 'lucide-react';

export default function MatchPreferences() {
    const router = useRouter();
    const { addToast } = useToast();
    const [loading, setLoading] = useState(false);
    const [fetching, setFetching] = useState(true);
    const [formData, setFormData] = useState({
        minAge: '',
        maxAge: '',
        religion: '',
        community: '',
        location: '',
        marital_status: '',
        eating_habits: '',
        smoking_habits: '',
        drinking_habits: '',
        minHeight: '',
        maxHeight: '', // Not used yet in UI but good to have
        highest_education: '',
        occupation: '',
        annual_income: ''
    });

    useEffect(() => {
        const fetchPreferences = async () => {
            try {
                const res = await api.get('/auth/me');
                if (res.data.partner_preferences) {
                    setFormData(prev => ({
                        ...prev,
                        ...res.data.partner_preferences
                    }));
                }
            } catch (err) {
                console.error('Failed to fetch preferences', err);
            } finally {
                setFetching(false);
            }
        };
        fetchPreferences();
    }, []);

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
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
            await api.put('/users/preferences', {
                preferences: formData
            });
            addToast('Preferences updated successfully', 'success');
            router.push('/feed');
        } catch (err) {
            addToast('Failed to update preferences', 'error');
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    if (fetching) return <div className="p-8 flex justify-center"><Loader2 className="animate-spin text-pink-500" /></div>;

    return (
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
            <div className="p-6 border-b border-gray-100">
                <h2 className="text-xl font-bold text-gray-900">Partner Preferences</h2>
                <p className="text-sm text-gray-500 mt-1">Set your preferences to get better matches in your Feed.</p>
            </div>

            <form onSubmit={handleSubmit} className="p-6 space-y-6">
                {/* Basic Demographics */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Min Age</label>
                        <input
                            type="number"
                            name="minAge"
                            value={formData.minAge}
                            onChange={handleChange}
                            className="w-full h-10 px-3 rounded-lg border border-gray-300 focus:outline-none focus:border-pink-500 focus:ring-1 focus:ring-pink-500"
                            placeholder="e.g. 21"
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Max Age</label>
                        <input
                            type="number"
                            name="maxAge"
                            value={formData.maxAge}
                            onChange={handleChange}
                            className="w-full h-10 px-3 rounded-lg border border-gray-300 focus:outline-none focus:border-pink-500 focus:ring-1 focus:ring-pink-500"
                            placeholder="e.g. 35"
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
                            className="w-full h-10 px-3 rounded-lg border border-gray-300 focus:outline-none focus:border-pink-500 focus:ring-1 focus:ring-pink-500"
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
                            className="w-full h-10 px-3 rounded-lg border border-gray-300 focus:outline-none focus:border-pink-500 focus:ring-1 focus:ring-pink-500"
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
                            className="w-full h-10 px-3 rounded-lg border border-gray-300 focus:outline-none focus:border-pink-500 focus:ring-1 focus:ring-pink-500"
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Location Preferred</label>
                        <input
                            type="text"
                            name="location"
                            placeholder="City, State"
                            value={formData.location}
                            onChange={handleChange}
                            className="w-full h-10 px-3 rounded-lg border border-gray-300 focus:outline-none focus:border-pink-500 focus:ring-1 focus:ring-pink-500"
                        />
                    </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Education</label>
                        <input
                            type="text"
                            name="highest_education"
                            placeholder="e.g. B.Tech, MBA"
                            value={formData.highest_education}
                            onChange={handleChange}
                            className="w-full h-10 px-3 rounded-lg border border-gray-300 focus:outline-none focus:border-pink-500 focus:ring-1 focus:ring-pink-500"
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
                            className="w-full h-10 px-3 rounded-lg border border-gray-300 focus:outline-none focus:border-pink-500 focus:ring-1 focus:ring-pink-500"
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Annual Income (Min)</label>
                        <select
                            name="annual_income"
                            value={formData.annual_income}
                            onChange={handleChange}
                            className="w-full h-10 px-3 rounded-lg border border-gray-300 focus:outline-none focus:border-pink-500 focus:ring-1 focus:ring-pink-500"
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
                                className="w-full h-10 px-3 rounded-lg border border-gray-300 focus:outline-none focus:border-pink-500 focus:ring-1 focus:ring-pink-500"
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
                                className="w-full h-10 px-3 rounded-lg border border-gray-300 focus:outline-none focus:border-pink-500 focus:ring-1 focus:ring-pink-500"
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
                                className="w-full h-10 px-3 rounded-lg border border-gray-300 focus:outline-none focus:border-pink-500 focus:ring-1 focus:ring-pink-500"
                            >
                                <option value="">Any</option>
                                <option value="No">No</option>
                                <option value="Yes">Yes</option>
                                <option value="Occasionally">Occasionally</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div className="pt-4 flex items-center justify-end">
                    <button
                        type="submit"
                        disabled={loading}
                        className="flex items-center gap-2 px-6 py-2 bg-pink-600 text-white rounded-lg hover:bg-pink-700 transition-colors shadow-sm disabled:opacity-70 font-medium"
                    >
                        {loading ? (
                            <Loader2 className="h-4 w-4 animate-spin" />
                        ) : (
                            <Save className="h-4 w-4" />
                        )}
                        Save Preferences
                    </button>
                </div>
            </form>
        </div>
    );
}
