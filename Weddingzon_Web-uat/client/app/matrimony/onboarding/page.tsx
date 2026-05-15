'use client';
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { ChevronLeft, ChevronRight, Upload, MapPin, Calendar, Heart, GraduationCap, Home, Users } from 'lucide-react';
import api from '../../services/api';

// --- Types ---
interface FormData {
    // Basic
    first_name: string;
    last_name: string;
    dob: string;
    aadhar_number: string;
    // Contact
    email: string;
    phone: string;
    // Location
    country: string;
    state: string;
    city: string;
    // Personal I
    gender: string;
    marital_status: string;
    height: string;
    weight: string;
    complexion: string; // Appearance
    diet: string;
    smoking: string;
    drinking: string;
    // Personal II
    religion: string;
    mother_tongue: string;
    blood_group: string;
    disability: string;
    disability_type?: string;
    disability_description?: string;
    sub_community?: string;
    // Education & Career
    highest_education: string;
    college_name: string;
    occupation: string;
    working_sector: string;
    annual_income: string;
    // Family
    live_with_family: string;
    family_type: string;
    family_values: string;
    family_status: string; // Rich/Middle Class etc
    // Parents
    father_name: string;
    mother_name: string;
    father_occupation: string;
    mother_occupation: string;
    brothers: number;
    sisters: number;
    // Property
    property_type: string;
    property_possession_type: string;
    land_area_range: string;
    // Photos
    photos: File[];
}

const STEPS = [
    { title: 'Basic Details', icon: <Calendar className="w-5 h-5" /> },
    { title: 'Contact', icon: <MapPin className="w-5 h-5" /> },
    { title: 'Location', icon: <MapPin className="w-5 h-5" /> },
    { title: 'Appearance & Lifestyle', icon: <Heart className="w-5 h-5" /> },
    { title: 'Background', icon: <Users className="w-5 h-5" /> },
    { title: 'Education & Career', icon: <GraduationCap className="w-5 h-5" /> },
    { title: 'Family Details', icon: <Home className="w-5 h-5" /> },
    { title: 'Parents & Siblings', icon: <Users className="w-5 h-5" /> },
    { title: 'Assets', icon: <Home className="w-5 h-5" /> },
    { title: 'Photos', icon: <Upload className="w-5 h-5" /> },
];

export default function OnboardingPage() {
    const router = useRouter();
    const [step, setStep] = useState(0);
    const [loading, setLoading] = useState(false);
    const [formData, setFormData] = useState<FormData>({
        first_name: '', last_name: '', dob: '', aadhar_number: '',
        email: '', phone: '',
        country: 'India', state: '', city: '',
        gender: '', marital_status: '', height: '', weight: '', complexion: '',
        diet: '', smoking: 'No', drinking: 'No',
        religion: '', mother_tongue: '', blood_group: '', disability: 'No',
        highest_education: '', college_name: '', occupation: '', working_sector: '', annual_income: '',
        live_with_family: 'Yes', family_type: 'Nuclear', family_values: 'Moderate', family_status: 'Middle Class',
        father_name: '', mother_name: '', father_occupation: '', mother_occupation: '',
        brothers: 0, sisters: 0,
        property_type: '', property_possession_type: '', land_area_range: '',
        photos: []
    });

    // --- Handlers ---
    const handleChange = (field: keyof FormData, value: any) => {
        setFormData(prev => ({ ...prev, [field]: value }));
    };

    const handleNext = () => {
        if (step < STEPS.length - 1) setStep(step + 1);
    };

    const handleBack = () => {
        if (step > 0) setStep(step - 1);
    };

    const handleSubmit = async () => {
        setLoading(true);
        try {
            // 1. Upload Photos if any
            let uploadedPhotoUrls: any[] = [];
            if (formData.photos.length > 0) {
                const photoData = new FormData();
                formData.photos.forEach(file => {
                    photoData.append('photos', file);
                });

                // Use the generic user upload endpoint
                const headerConfig = {
                    headers: { 'Content-Type': 'multipart/form-data' }
                };

                // Note: Ensure this endpoint returns the array of uploaded file objects/urls
                const uploadRes = await api.post('/users/upload-photos', photoData, headerConfig);
                if (uploadRes.data && uploadRes.data.data) { // Assuming response structure { success: true, data: [...] }
                    // The backend likely returns objects with { url, key, ... }
                    // We need to verify what upload-photos returns. 
                    // Usually standard Weddingzon upload returns { data: [ { url: '...', key: '...' } ] }
                    uploadedPhotoUrls = uploadRes.data.data;
                }
            }

            // 2. Prepare Profile Payload
            // Merge form data with existing structure. 
            // Note: We are sending flat fields, backend 'registerDetails' handles them.
            const payload = {
                ...formData,
                is_profile_complete: true,
                // If backend expects 'photos' as array of objects in the user profile update?
                // Actually auth.controller.js doesn't seem to explicitly handle 'photos' array update in registerDetails...
                // Wait, registerDetails doesn't have 'photos' logic!
                // The /upload-photos endpoint (user.controller.uploadPhotos) SAVES them to the user document directly!
                // So we don't need to send photos in registerDetails.
            };

            // 3. Update Profile Data
            const res = await api.post('/auth/register-details', payload);

            if (res.data) {
                alert('Profile Completed Successfully!');
                router.push('/settings/preferences'); // Redirect to preferences
            }

        } catch (error: any) {
            console.error('Submission Error:', error);
            alert(error.response?.data?.message || 'Failed to submit profile. Please try again.');
        } finally {
            setLoading(false);
        }
    };

    const renderStepContent = () => {
        switch (step) {
            case 0:
                return (
                    <div className="space-y-6 animate-in fade-in slide-in-from-right-4 duration-300">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">First Name *</label>
                                <input
                                    type="text"
                                    className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] focus:ring-4 focus:ring-pink-50/50 outline-none transition font-medium"
                                    placeholder="Enter your name"
                                    value={formData.first_name}
                                    onChange={(e) => handleChange('first_name', e.target.value)}
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">Last Name *</label>
                                <input
                                    type="text"
                                    className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] focus:ring-4 focus:ring-pink-50/50 outline-none transition font-medium"
                                    placeholder="Enter your name"
                                    value={formData.last_name}
                                    onChange={(e) => handleChange('last_name', e.target.value)}
                                />
                            </div>
                        </div>
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Date of Birth *</label>
                            <input
                                type="date"
                                className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] focus:ring-4 focus:ring-pink-50/50 outline-none transition font-medium"
                                value={formData.dob}
                                onChange={(e) => handleChange('dob', e.target.value)}
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Aadhar Number</label>
                            <input
                                type="text"
                                className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] focus:ring-4 focus:ring-pink-50/50 outline-none transition font-medium"
                                placeholder="XXXX XXXX XXXX"
                                value={formData.aadhar_number}
                                onChange={(e) => handleChange('aadhar_number', e.target.value)}
                            />
                        </div>
                    </div>
                );
            case 1:
                return (
                    <div className="space-y-6 animate-in fade-in slide-in-from-right-4 duration-300">
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Email Address *</label>
                            <input
                                type="email"
                                className="w-full p-4 rounded-xl bg-gray-50 border border-gray-200 outline-none transition font-medium text-gray-500 cursor-not-allowed"
                                placeholder="Enter your email"
                                value={formData.email}
                                readOnly
                            />
                            <p className="text-xs text-gray-400 mt-1">Email cannot be changed.</p>
                        </div>
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Mobile Number *</label>
                            <div className="flex gap-4">
                                <div className="w-24 p-4 rounded-xl bg-gray-50 border border-gray-200 font-medium text-center text-gray-500">
                                    +91
                                </div>
                                <input
                                    type="tel"
                                    className="flex-1 p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] focus:ring-4 focus:ring-pink-50/50 outline-none transition font-medium"
                                    placeholder="Enter your phone number"
                                    value={formData.phone}
                                    onChange={(e) => handleChange('phone', e.target.value)}
                                />
                            </div>
                        </div>
                    </div>
                );
            case 2:
                return (
                    <div className="space-y-6 animate-in fade-in slide-in-from-right-4 duration-300">
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Country *</label>
                            <select
                                className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] focus:ring-4 focus:ring-pink-50/50 outline-none transition font-medium"
                                value={formData.country}
                                onChange={(e) => handleChange('country', e.target.value)}
                            >
                                <option value="India">India</option>
                                <option value="USA">USA</option>
                                <option value="Canada">Canada</option>
                                <option value="UK">UK</option>
                                <option value="Australia">Australia</option>
                            </select>
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">State *</label>
                                <input
                                    type="text"
                                    className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] focus:ring-4 focus:ring-pink-50/50 outline-none transition font-medium"
                                    placeholder="e.g. Maharashtra"
                                    value={formData.state}
                                    onChange={(e) => handleChange('state', e.target.value)}
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">City *</label>
                                <input
                                    type="text"
                                    className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] focus:ring-4 focus:ring-pink-50/50 outline-none transition font-medium"
                                    placeholder="e.g. Mumbai"
                                    value={formData.city}
                                    onChange={(e) => handleChange('city', e.target.value)}
                                />
                            </div>
                        </div>
                    </div>
                );
            case 3:
                return (
                    <div className="space-y-6 animate-in fade-in slide-in-from-right-4 duration-300">
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Marital Status *</label>
                            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                                {['Never Married', 'Divorced', 'Widowed', 'Awaiting Divorce'].map(status => (
                                    <button
                                        key={status}
                                        onClick={() => handleChange('marital_status', status)}
                                        className={`p-3 rounded-xl border font-medium transition ${formData.marital_status === status
                                            ? 'border-[#EF2F55] bg-pink-50 text-[#EF2F55]'
                                            : 'border-gray-200 text-gray-600 hover:border-pink-200'
                                            }`}
                                    >
                                        {status}
                                    </button>
                                ))}
                            </div>
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">Height</label>
                                <select
                                    className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] outline-none"
                                    value={formData.height}
                                    onChange={(e) => handleChange('height', e.target.value)}
                                >
                                    <option value="">Select Height</option>
                                    <option value="5'0">5'0"</option>
                                    <option value="5'5">5'5"</option>
                                    <option value="6'0">6'0"</option>
                                    {/* Add more options later */}
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">Weight (kg)</label>
                                <input
                                    type="number"
                                    className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] outline-none"
                                    placeholder="e.g. 65"
                                    value={formData.weight}
                                    onChange={(e) => handleChange('weight', e.target.value)}
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">Complexion</label>
                                <select
                                    className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] outline-none"
                                    value={formData.complexion}
                                    onChange={(e) => handleChange('complexion', e.target.value)}
                                >
                                    <option value="">Select</option>
                                    <option value="Fair">Fair</option>
                                    <option value="Wheatish">Wheatish</option>
                                    <option value="Dark">Dark</option>
                                </select>
                            </div>
                        </div>
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Habits</label>
                            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                                <div>
                                    <span className="text-xs text-gray-500 block mb-1">Diet</span>
                                    <select
                                        className="w-full p-3 rounded-lg border border-gray-200 focus:border-[#EF2F55] outline-none"
                                        value={formData.diet}
                                        onChange={(e) => handleChange('diet', e.target.value)}
                                    >
                                        <option value="">Select</option>
                                        <option value="Veg">Veg</option>
                                        <option value="Non-Veg">Non-Veg</option>
                                        <option value="Eggetarian">Eggetarian</option>
                                        <option value="Vegan">Vegan</option>
                                    </select>
                                </div>
                                <div>
                                    <span className="text-xs text-gray-500 block mb-1">Smoking</span>
                                    <select
                                        className="w-full p-3 rounded-lg border border-gray-200 focus:border-[#EF2F55] outline-none"
                                        value={formData.smoking}
                                        onChange={(e) => handleChange('smoking', e.target.value)}
                                    >
                                        <option value="No">No</option>
                                        <option value="Yes">Yes</option>
                                        <option value="Occasionally">Occasionally</option>
                                    </select>
                                </div>
                                <div>
                                    <span className="text-xs text-gray-500 block mb-1">Drinking</span>
                                    <select
                                        className="w-full p-3 rounded-lg border border-gray-200 focus:border-[#EF2F55] outline-none"
                                        value={formData.drinking}
                                        onChange={(e) => handleChange('drinking', e.target.value)}
                                    >
                                        <option value="No">No</option>
                                        <option value="Yes">Yes</option>
                                        <option value="Occasionally">Occasionally</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>
                );
            case 4:
                return (
                    <div className="space-y-6 animate-in fade-in slide-in-from-right-4 duration-300">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">Religion *</label>
                                <select
                                    className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] outline-none"
                                    value={formData.religion}
                                    onChange={(e) => handleChange('religion', e.target.value)}
                                >
                                    <option value="">Select</option>
                                    <option value="Hindu">Hindu</option>
                                    <option value="Muslim">Muslim</option>
                                    <option value="Christian">Christian</option>
                                    <option value="Sikh">Sikh</option>
                                    <option value="Jain">Jain</option>
                                    <option value="Buddhist">Buddhist</option>
                                    <option value="Parsi">Parsi</option>
                                    <option value="Jewish">Jewish</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">Mother Tongue *</label>
                                <select
                                    className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] outline-none"
                                    value={formData.mother_tongue}
                                    onChange={(e) => handleChange('mother_tongue', e.target.value)}
                                >
                                    <option value="">Select</option>
                                    <option value="Hindi">Hindi</option>
                                    <option value="English">English</option>
                                    <option value="Marathi">Marathi</option>
                                    <option value="Punjabi">Punjabi</option>
                                    <option value="Bengali">Bengali</option>
                                    <option value="Gujarati">Gujarati</option>
                                    <option value="Tamil">Tamil</option>
                                    <option value="Telugu">Telugu</option>
                                    <option value="Kannada">Kannada</option>
                                    <option value="Malayalam">Malayalam</option>
                                    <option value="Urdu">Urdu</option>
                                </select>
                            </div>
                        </div>
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Sub Community (Caste)</label>
                            <input
                                type="text"
                                className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] outline-none"
                                placeholder="e.g. Brahmin, Maratha, Sunni..."
                                value={formData.sub_community}
                                onChange={(e) => handleChange('sub_community', e.target.value)}
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Any Disability?</label>
                            <div className="flex gap-4 mb-4">
                                {['No', 'Yes'].map(opt => (
                                    <button
                                        key={opt}
                                        onClick={() => handleChange('disability', opt)}
                                        className={`flex-1 p-3 rounded-xl border font-medium ${formData.disability === opt
                                            ? 'border-[#EF2F55] bg-pink-50 text-[#EF2F55]'
                                            : 'border-gray-200 text-gray-600'
                                            }`}
                                    >
                                        {opt}
                                    </button>
                                ))}
                            </div>
                            {formData.disability === 'Yes' && (
                                <div className="space-y-4 p-4 bg-gray-50 rounded-xl">
                                    <input
                                        type="text"
                                        className="w-full p-3 rounded-lg border border-gray-200 outline-none"
                                        placeholder="Type of Disability"
                                        value={formData.disability_type}
                                        onChange={(e) => handleChange('disability_type', e.target.value)}
                                    />
                                    <textarea
                                        className="w-full p-3 rounded-lg border border-gray-200 outline-none"
                                        placeholder="Description (Optional)"
                                        rows={2}
                                        value={formData.disability_description}
                                        onChange={(e) => handleChange('disability_description', e.target.value)}
                                    />
                                </div>
                            )}
                        </div>
                    </div>
                );
            case 5:
                return (
                    <div className="space-y-6 animate-in fade-in slide-in-from-right-4 duration-300">
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Highest Qualification *</label>
                            <input
                                type="text"
                                className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] outline-none"
                                placeholder="e.g. B.Tech, MBA"
                                value={formData.highest_education}
                                onChange={(e) => handleChange('highest_education', e.target.value)}
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">College / University Name *</label>
                            <div className="relative">
                                <GraduationCap className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
                                <input
                                    type="text"
                                    className="w-full p-4 pl-12 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] outline-none"
                                    placeholder="Enter college name"
                                    value={formData.college_name}
                                    onChange={(e) => handleChange('college_name', e.target.value)}
                                />
                            </div>
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">Occupation *</label>
                                <input
                                    type="text"
                                    className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] outline-none"
                                    placeholder="e.g. Software Engineer"
                                    value={formData.occupation}
                                    onChange={(e) => handleChange('occupation', e.target.value)}
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">Working Sector</label>
                                <select
                                    className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] outline-none"
                                    value={formData.working_sector}
                                    onChange={(e) => handleChange('working_sector', e.target.value)}
                                >
                                    <option value="">Select</option>
                                    <option value="Private">Private</option>
                                    <option value="Government">Government</option>
                                    <option value="Business">Business</option>
                                    <option value="Self Employed">Self Employed</option>
                                </select>
                            </div>
                        </div>
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Annual Income</label>
                            <select
                                className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] outline-none"
                                value={formData.annual_income}
                                onChange={(e) => handleChange('annual_income', e.target.value)}
                            >
                                <option value="">Select Income Range</option>
                                <option value="0-3 LPA">0-3 LPA</option>
                                <option value="3-5 LPA">3-5 LPA</option>
                                <option value="5-10 LPA">5-10 LPA</option>
                                <option value="10-15 LPA">10-15 LPA</option>
                                <option value="15+ LPA">15+ LPA</option>
                            </select>
                        </div>
                    </div>
                );
            case 6:
                return (
                    <div className="space-y-6 animate-in fade-in slide-in-from-right-4 duration-300">
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Do you live with your family?</label>
                            <div className="flex gap-4">
                                {['Yes', 'No'].map(opt => (
                                    <button
                                        key={opt}
                                        onClick={() => handleChange('live_with_family', opt)}
                                        className={`px-8 py-3 rounded-full border font-medium ${formData.live_with_family === opt
                                            ? 'border-[#EF2F55] bg-pink-50 text-[#EF2F55]'
                                            : 'border-gray-200 text-gray-600'
                                            }`}
                                    >
                                        {opt}
                                    </button>
                                ))}
                            </div>
                        </div>
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Family Type</label>
                            <div className="flex gap-4">
                                {['Nuclear', 'Joint'].map(opt => (
                                    <button
                                        key={opt}
                                        onClick={() => handleChange('family_type', opt)}
                                        className={`px-8 py-3 rounded-full border font-medium ${formData.family_type === opt
                                            ? 'border-[#EF2F55] bg-pink-50 text-[#EF2F55]'
                                            : 'border-gray-200 text-gray-600'
                                            }`}
                                    >
                                        {opt}
                                    </button>
                                ))}
                            </div>
                        </div>
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Family Values</label>
                            <div className="flex gap-4 flex-wrap">
                                {['Traditional', 'Moderate', 'Liberal'].map(opt => (
                                    <button
                                        key={opt}
                                        onClick={() => handleChange('family_values', opt)}
                                        className={`px-8 py-3 rounded-full border font-medium ${formData.family_values === opt
                                            ? 'border-[#EF2F55] bg-pink-50 text-[#EF2F55]'
                                            : 'border-gray-200 text-gray-600'
                                            }`}
                                    >
                                        {opt}
                                    </button>
                                ))}
                            </div>
                        </div>
                    </div>
                );
            case 7:
                return (
                    <div className="space-y-6 animate-in fade-in slide-in-from-right-4 duration-300">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">Father's Name *</label>
                                <input
                                    type="text"
                                    className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] outline-none"
                                    value={formData.father_name}
                                    onChange={(e) => handleChange('father_name', e.target.value)}
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">Father's Occupation</label>
                                <select
                                    className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] outline-none"
                                    value={formData.father_occupation}
                                    onChange={(e) => handleChange('father_occupation', e.target.value)}
                                >
                                    <option value="">Select</option>
                                    <option value="Private">Private Sector</option>
                                    <option value="Government">Government Sector</option>
                                    <option value="Business">Business</option>
                                    <option value="Retired">Retired</option>
                                    <option value="Not Employed">Not Employed</option>
                                </select>
                            </div>
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">Mother's Name *</label>
                                <input
                                    type="text"
                                    className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] outline-none"
                                    value={formData.mother_name}
                                    onChange={(e) => handleChange('mother_name', e.target.value)}
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">Mother's Occupation</label>
                                <select
                                    className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] outline-none"
                                    value={formData.mother_occupation}
                                    onChange={(e) => handleChange('mother_occupation', e.target.value)}
                                >
                                    <option value="">Select</option>
                                    <option value="Housewife">Housewife</option>
                                    <option value="Private">Private Sector</option>
                                    <option value="Government">Government Sector</option>
                                    <option value="Business">Business</option>
                                    <option value="Retired">Retired</option>
                                </select>
                            </div>
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">Brothers</label>
                                <div className="flex items-center gap-4">
                                    <button onClick={() => handleChange('brothers', Math.max(0, formData.brothers - 1))} className="w-10 h-10 rounded-full border flex items-center justify-center">-</button>
                                    <span className="font-bold text-xl">{formData.brothers}</span>
                                    <button onClick={() => handleChange('brothers', formData.brothers + 1)} className="w-10 h-10 rounded-full border flex items-center justify-center">+</button>
                                </div>
                            </div>
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">Sisters</label>
                                <div className="flex items-center gap-4">
                                    <button onClick={() => handleChange('sisters', Math.max(0, formData.sisters - 1))} className="w-10 h-10 rounded-full border flex items-center justify-center">-</button>
                                    <span className="font-bold text-xl">{formData.sisters}</span>
                                    <button onClick={() => handleChange('sisters', formData.sisters + 1)} className="w-10 h-10 rounded-full border flex items-center justify-center">+</button>
                                </div>
                            </div>
                        </div>
                    </div>
                );
            case 8:
                return (
                    <div className="space-y-6 animate-in fade-in slide-in-from-right-4 duration-300">
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Property Type</label>
                            <div className="flex gap-4 flex-wrap">
                                {['Self-acquired', 'Ancestral', 'Multiple Properties', 'Joint Family'].map(opt => (
                                    <button
                                        key={opt}
                                        onClick={() => handleChange('property_possession_type', opt)}
                                        className={`px-6 py-3 rounded-full border font-medium ${formData.property_possession_type === opt
                                            ? 'border-[#EF2F55] bg-pink-50 text-[#EF2F55]'
                                            : 'border-gray-200 text-gray-600'
                                            }`}
                                    >
                                        {opt}
                                    </button>
                                ))}
                            </div>
                        </div>
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Land Area</label>
                            <select
                                className="w-full p-4 rounded-xl bg-white border border-gray-200 focus:border-[#EF2F55] outline-none"
                                value={formData.land_area_range}
                                onChange={(e) => handleChange('land_area_range', e.target.value)}
                            >
                                <option value="">Select Range</option>
                                <option value="Below 500 sq ft">Below 500 sq ft</option>
                                <option value="500-1000 sq ft">500-1000 sq ft</option>
                                <option value="1000-2000 sq ft">1000-2000 sq ft</option>
                                <option value="Above 2000 sq ft">Above 2000 sq ft</option>
                            </select>
                        </div>
                    </div>
                );
            case 9:
                return (
                    <div className="space-y-6 animate-in fade-in slide-in-from-right-4 duration-300">
                        <div className="text-center">
                            <h3 className="text-xl font-semibold text-gray-800 mb-2">Upload Your Best Photos</h3>
                            <p className="text-gray-500 mb-8">Photos are the first thing matches see. Add at least 3 photos.</p>

                            <div className="border-2 border-dashed border-gray-300 rounded-2xl p-12 flex flex-col items-center justify-center transition hover:border-[#EF2F55] hover:bg-pink-50/30 cursor-pointer relative">
                                <input
                                    type="file"
                                    multiple
                                    accept="image/*"
                                    className="absolute inset-0 opacity-0 cursor-pointer"
                                    onChange={(e) => {
                                        if (e.target.files) {
                                            setFormData(prev => ({
                                                ...prev,
                                                photos: [...prev.photos, ...Array.from(e.target.files || [])]
                                            }));
                                        }
                                    }}
                                />
                                <div className="w-16 h-16 bg-pink-100 rounded-full flex items-center justify-center mb-4 text-[#EF2F55]">
                                    <Upload className="w-8 h-8" />
                                </div>
                                <span className="font-semibold text-gray-700">Click to Upload Photos</span>
                                <span className="text-sm text-gray-400 mt-2">JPG, PNG up to 5MB each</span>
                            </div>

                            {formData.photos.length > 0 && (
                                <div className="mt-8 grid grid-cols-2 md:grid-cols-4 gap-4">
                                    {formData.photos.map((file, idx) => (
                                        <div key={idx} className="relative aspect-[3/4] rounded-xl overflow-hidden shadow-sm border border-gray-100 group">
                                            <img
                                                src={URL.createObjectURL(file)}
                                                alt={`Preview ${idx}`}
                                                className="w-full h-full object-cover"
                                            />
                                            <button
                                                onClick={() => setFormData(prev => ({ ...prev, photos: prev.photos.filter((_, i) => i !== idx) }))}
                                                className="absolute top-2 right-2 bg-black/50 hover:bg-red-500 text-white rounded-full p-1 transition opacity-0 group-hover:opacity-100"
                                            >
                                                ✕
                                            </button>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>
                    </div>
                );
            default:
                return null;
        }
    };

    return (
        <div className="min-h-screen bg-[#444444] flex items-center justify-center p-4">
            <div className="w-full max-w-6xl bg-white rounded-2xl shadow-2xl overflow-hidden flex flex-col md:flex-row min-h-[700px]">
                {/* Sidebar (Steps) */}
                <div className="w-full md:w-1/4 bg-gray-50 border-r border-gray-100 p-6">
                    <h2 className="text-xl font-serif font-bold text-[#EF2F55] mb-6">Create Profile</h2>
                    <div className="space-y-1">
                        {STEPS.map((s, idx) => (
                            <div
                                key={idx}
                                className={`flex items-center gap-3 p-3 rounded-lg text-sm font-medium transition-colors ${step === idx ? 'bg-pink-50 text-[#EF2F55]' :
                                    step > idx ? 'text-green-600' : 'text-gray-400'
                                    }`}
                            >
                                <div className={`w-6 h-6 rounded-full flex items-center justify-center text-xs border ${step === idx ? 'border-[#EF2F55] bg-[#EF2F55] text-white' :
                                    step > idx ? 'border-green-600 bg-green-600 text-white' : 'border-gray-300'
                                    }`}>
                                    {step > idx ? '✓' : idx + 1}
                                </div>
                                <span>{s.title}</span>
                            </div>
                        ))}
                    </div>
                </div>

                {/* Main Content */}
                <div className="flex-1 p-8 md:p-12 relative flex flex-col">
                    <div className="flex-1">
                        <h1 className="font-serif text-3xl md:text-4xl text-gray-900 mb-8 text-center">
                            {STEPS[step].title}
                        </h1>

                        {/* DYNAMIC FORM CONTENT WILL GO HERE */}
                        <div className="max-w-3xl mx-auto min-h-[400px]">
                            {renderStepContent()}
                        </div>
                    </div>

                    {/* Footer Actions */}
                    <div className="mt-8 flex justify-between items-center max-w-3xl mx-auto w-full pt-6 border-t border-gray-100">
                        <button
                            onClick={handleBack}
                            disabled={step === 0}
                            className={`flex items-center gap-2 px-6 py-3 rounded-full font-medium ${step === 0 ? 'opacity-0 pointer-events-none' : 'text-gray-600 hover:bg-gray-100'
                                }`}
                        >
                            <ChevronLeft className="w-5 h-5" /> Back
                        </button>

                        {step === STEPS.length - 1 ? (
                            <button
                                onClick={handleSubmit}
                                disabled={loading}
                                className="bg-[#EF2F55] text-white px-10 py-3 rounded-xl font-bold hover:bg-pink-700 transition flex items-center gap-2"
                            >
                                {loading ? 'Submitting...' : 'Complete Profile'}
                            </button>
                        ) : (
                            <button
                                onClick={handleNext}
                                className="bg-[#EF2F55] text-white px-10 py-3 rounded-xl font-bold hover:bg-pink-700 transition flex items-center gap-2"
                            >
                                Next <ChevronRight className="w-5 h-5" />
                            </button>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}
