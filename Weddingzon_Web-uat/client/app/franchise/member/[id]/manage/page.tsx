'use client';

import { useState, useRef, useEffect, use } from 'react';
import { useRouter } from 'next/navigation';
import api from '../../../../services/api';
import { Briefcase, MapPin, Users, GraduationCap, Heart, User, Phone, Info, Camera, ChevronLeft, Sliders } from 'lucide-react';
import PhotoUploadGrid from '../../../../components/PhotoUploadGrid';
import { useToast } from '../../../../contexts/ToastContext';

const indianStates = [
    "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh", "Goa", "Gujarat",
    "Haryana", "Himachal Pradesh", "Jharkhand", "Karnataka", "Kerala", "Madhya Pradesh",
    "Maharashtra", "Manipur", "Meghalaya", "Mizoram", "Nagaland", "Odisha", "Punjab",
    "Rajasthan", "Sikkim", "Tamil Nadu", "Telangana", "Tripura", "Uttar Pradesh",
    "Uttarakhand", "West Bengal", "Andaman and Nicobar Islands", "Chandigarh",
    "Dadra and Nagar Haveli and Daman and Diu", "Delhi", "Jammu and Kashmir", "Ladakh",
    "Lakshadweep", "Puducherry"
];

export default function EditMemberPage({ params }: { params: Promise<{ id: string }> }) {
    const { id } = use(params);
    const router = useRouter();
    const { addToast } = useToast();

    // Member State
    const [memberId, setMemberId] = useState<string | null>(id);
    const [memberUsername, setMemberUsername] = useState<string | null>(null);

    // Section Visibility State
    const [isBasicDetailsOpen, setIsBasicDetailsOpen] = useState(true);
    const [isLocationDetailsOpen, setIsLocationDetailsOpen] = useState(false);
    const [isFamilyDetailsOpen, setIsFamilyDetailsOpen] = useState(false);
    const [isEduCareerDetailsOpen, setIsEduCareerDetailsOpen] = useState(false);
    const [isReligiousOpen, setIsReligiousOpen] = useState(false);
    const [isLifestyleOpen, setIsLifestyleOpen] = useState(false);
    const [isContactOpen, setIsContactOpen] = useState(false);
    const [isAboutOpen, setIsAboutOpen] = useState(false);
    const [isPropertyOpen, setIsPropertyOpen] = useState(false);
    const [isPreferencesOpen, setIsPreferencesOpen] = useState(false);
    const [isPhotosOpen, setIsPhotosOpen] = useState(false);

    // Photos State
    const [photos, setPhotos] = useState<any[]>([]);

    // Form Data State
    const [formData, setFormData] = useState({
        username: '',
        first_name: '',
        last_name: '',
        dob: '',
        gender: '',
        created_for: '',
        height: '',
        marital_status: '',
        mother_tongue: '',
        disability: 'None',
        disability_type: '',
        disability_description: '',
        aadhar_number: '',
        blood_group: '',
        country: '',
        state: '',
        city: '',
        father_status: '',
        mother_status: '',
        brothers: 0,
        sisters: 0,
        family_status: '',
        family_type: '',
        family_values: '',
        annual_income: '',
        family_location: '',
        highest_education: '',
        educational_details: '',
        occupation: '',
        employed_in: '',
        personal_income: '',
        working_sector: '',
        working_location: '',
        religion: '',
        community: '',
        sub_community: '',
        appearance: '',
        living_status: '',
        physical_status: '',
        eating_habits: '',
        smoking_habits: '',
        drinking_habits: '',
        hobbies: [],
        property_types: [],
        land_types: [],
        land_area: '',
        house_types: [],
        business_types: [],
        email: '',
        phone: '',
        alternate_mobile: '',
        suitable_time_to_call: '',
        about_me: '',
        partner_preferences: {
            minAge: '',
            maxAge: '',
            religion: '',
            community: '',
            location: '',
            marital_status: '',
            eating_habits: '',
            smoking_habits: '',
            drinking_habits: '',
            highest_education: '',
            occupation: '',
            annual_income: ''
        }
    });

    const [loading, setLoading] = useState(true);
    const [calculatedAge, setCalculatedAge] = useState<number | null>(null);
    const [aadharError, setAadharError] = useState<string>('');
    const [isLocating, setIsLocating] = useState(false);

    // Fetch Member Data on Mount
    useEffect(() => {
        const fetchMember = async () => {
            try {
                const res = await api.get(`/franchise/profiles/${id}`);
                const member = res.data;
                const formattedDob = member.dob ? new Date(member.dob).toISOString().split('T')[0] : '';

                // Initialize preferences if missing
                const prefs = member.partner_preferences || { minAge: '', maxAge: '', religion: '', community: '', location: '', marital_status: '', eating_habits: '', smoking_habits: '', drinking_habits: '', highest_education: '', occupation: '', annual_income: '' };

                setFormData(prev => ({
                    ...prev,
                    ...member,
                    dob: formattedDob,
                    partner_preferences: prefs,
                    // Ensure arrays are initialized if missing
                    hobbies: member.hobbies || [],
                    property_types: member.property_types || [],
                    land_types: member.land_types || [],
                    house_types: member.house_types || [],
                    business_types: member.business_types || [],
                }));

                setMemberUsername(member.username);
                console.log('DEBUG: Fetched member photos:', member.photos);
                if (member.photos) {
                    // Normalize if necessary (handle case where photos might be strings if schema changed)
                    const normalizedPhotos = member.photos.map((p: any) => {
                        if (typeof p === 'string') return { _id: `legacy_${p}`, url: p, isProfile: false };
                        return p;
                    });
                    // console.log('DEBUG: Normalized photos:', normalizedPhotos);
                    setPhotos(normalizedPhotos);
                }

                // Calculate Age
                if (formattedDob) {
                    const today = new Date();
                    const birthDate = new Date(formattedDob);
                    let age = today.getFullYear() - birthDate.getFullYear();
                    const m = today.getMonth() - birthDate.getMonth();
                    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) age--;
                    setCalculatedAge(age);
                }

                addToast('Member details loaded.', 'success');
            } catch (error) {
                console.error("Failed to fetch member", error);
                addToast('Failed to load member details', 'error');
                router.push('/franchise');
            } finally {
                setLoading(false);
            }
        };

        if (id) fetchMember();
    }, [id, addToast, router]);

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
        const { name, value } = e.target;

        // Aadhar Validation
        if (name === 'aadhar_number') {
            const numericValue = value.replace(/\D/g, '');
            if (numericValue.length > 12) return;
            setFormData(prev => ({ ...prev, [name]: numericValue }));
            if (numericValue.length > 0 && numericValue.length !== 12) {
                setAadharError('Aadhar Number must be exactly 12 digits');
            } else {
                setAadharError('');
            }
            return;
        }

        if (name === 'country') {
            setFormData(prev => ({ ...prev, [name]: value, state: '', city: '' }));
        } else {
            setFormData(prev => ({ ...prev, [name]: value }));
        }

        if (name === 'dob') {
            const today = new Date();
            const birthDate = new Date(value);
            let age = today.getFullYear() - birthDate.getFullYear();
            const m = today.getMonth() - birthDate.getMonth();
            if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) age--;
            setCalculatedAge(age);
            if (age < 18) addToast('Must be at least 18 years old.', 'error');
            else if (age > 150) addToast('Age cannot exceed 150 years.', 'error');
        }
    };

    const handlePreferenceChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            partner_preferences: {
                ...prev.partner_preferences,
                [name]: value
            }
        }));
    };

    // --- Validation Helpers ---
    // --- Validation Helpers (Identical to Onboarding) ---
    const isBasicDetailsComplete = () => {
        return formData.first_name && formData.last_name && formData.dob && formData.gender &&
            formData.height && formData.marital_status && formData.mother_tongue &&
            formData.created_for;
    };

    const isLocationDetailsComplete = () => {
        return formData.country && formData.state && formData.city;
    };

    const isFamilyDetailsComplete = () => {
        return formData.father_status && formData.mother_status && formData.family_status &&
            formData.family_type && formData.family_values;
    };

    const isEduCareerDetailsComplete = () => {
        return formData.highest_education && formData.occupation && formData.employed_in &&
            formData.personal_income;
    };

    const isReligiousDetailsComplete = () => {
        return formData.religion && formData.community;
    };

    const isLifestyleDetailsComplete = () => {
        return formData.appearance && formData.living_status && formData.eating_habits;
    };

    const isContactDetailsComplete = () => {
        return !!formData.phone;
    };

    const isAboutDetailsComplete = () => {
        return formData.about_me && formData.about_me.length >= 50;
    };

    const toggleSection = (section: string) => {
        // Logic similar to Add page, but since we have memberId always, checks are easier
        switch (section) {
            case 'basic': setIsBasicDetailsOpen(!isBasicDetailsOpen); break;
            case 'location': setIsLocationDetailsOpen(!isLocationDetailsOpen); break;
            case 'family': setIsFamilyDetailsOpen(!isFamilyDetailsOpen); break;
            case 'education': setIsEduCareerDetailsOpen(!isEduCareerDetailsOpen); break;
            case 'religious': setIsReligiousOpen(!isReligiousOpen); break;
            case 'lifestyle': setIsLifestyleOpen(!isLifestyleOpen); break;
            case 'contact': setIsContactOpen(!isContactOpen); break;
            case 'about': setIsAboutOpen(!isAboutOpen); break;
            case 'property': setIsPropertyOpen(!isPropertyOpen); break;
            case 'preferences': setIsPreferencesOpen(!isPreferencesOpen); break;
            case 'photos': setIsPhotosOpen(!isPhotosOpen); break;
        }
    };

    const handleUpdate = async (currentSection: string) => {
        setLoading(true);
        try {
            if (currentSection === 'basic') {
                if (formData.aadhar_number && formData.aadhar_number.length !== 12) {
                    addToast('Aadhar Number must be exactly 12 digits.', 'error');
                    setLoading(false);
                    return;
                }
                if (!isBasicDetailsComplete()) {
                    addToast('Please fill all mandatory fields.', 'error');
                    setLoading(false);
                    return;
                }
            }
            // ... Add specific validation per section if needed ...

            await api.patch(`/franchise/profiles/${memberId}`, formData);
            addToast('Section updated successfully', 'success');

            // Auto-advance logic (Optional for Edit, but nice to have)
            if (currentSection === 'basic') { setIsBasicDetailsOpen(false); setIsLocationDetailsOpen(true); }
            else if (currentSection === 'location') { setIsLocationDetailsOpen(false); setIsFamilyDetailsOpen(true); }
            else if (currentSection === 'family') { setIsFamilyDetailsOpen(false); setIsEduCareerDetailsOpen(true); }
            else if (currentSection === 'education') { setIsEduCareerDetailsOpen(false); setIsReligiousOpen(true); }
            else if (currentSection === 'religious') { setIsReligiousOpen(false); setIsLifestyleOpen(true); }
            else if (currentSection === 'lifestyle') { setIsLifestyleOpen(false); setIsContactOpen(true); }
            else if (currentSection === 'contact') { setIsContactOpen(false); setIsAboutOpen(true); }
            else if (currentSection === 'about') { setIsAboutOpen(false); setIsPropertyOpen(true); }
            else if (currentSection === 'property') { setIsPropertyOpen(false); setIsPreferencesOpen(true); }
            else if (currentSection === 'preferences') { setIsPreferencesOpen(false); setIsPhotosOpen(true); }
            else if (currentSection === 'photos') { /* End */ }

        } catch (error: any) {
            console.error(error);
            addToast(error.response?.data?.message || 'Failed to update section.', 'error');
        } finally {
            setLoading(false);
        }
    };

    const handleUseCurrentLocation = () => {
        if (!navigator.geolocation) { addToast('Geolocation not supported', 'error'); return; }
        setIsLocating(true);
        navigator.geolocation.getCurrentPosition(async (position) => {
            const { latitude, longitude } = position.coords;
            try {
                const response = await fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitude}`);
                const data = await response.json();
                if (data.address) {
                    setFormData(prev => ({
                        ...prev,
                        country: data.address.country || 'India',
                        state: data.address.state || data.address.region || '',
                        city: data.address.city || data.address.town || data.address.village || data.address.county || ''
                    }));
                    addToast('Location updated from current location', 'success');
                } else {
                    addToast('Address not found', 'error');
                }
            } catch (error) { addToast('Failed to fetch location', 'error'); }
            finally { setIsLocating(false); }
        }, () => { addToast('Unable to retrieve location', 'error'); setIsLocating(false); });
    };

    const handleFinalSubmit = async () => {
        setLoading(true);
        try {
            await api.patch(`/franchise/profiles/${memberId}`, { ...formData, is_profile_complete: true });
            addToast('Member Profile Updated Successfully!', 'success');
            router.push('/franchise');
        } catch (error) {
            addToast('Failed to update profile.', 'error');
        } finally {
            setLoading(false);
        }
    };

    // Update Profile Photo Local helper for the Grid
    const updateProfilePhotoLocal = (url: string) => { };

    if (loading && !formData.first_name) return <div className="p-10 text-center">Loading Member Details...</div>;

    return (
        <div className="min-h-screen bg-gray-50 py-10 px-4 sm:px-6 lg:px-8">
            <div className="mx-auto max-w-4xl space-y-6">
                <div className="flex items-center justify-between">
                    <button onClick={() => router.back()} className="flex items-center text-gray-600 hover:text-gray-900">
                        <ChevronLeft className="h-5 w-5 mr-1" /> Back to Dashboard
                    </button>
                    <h1 className="text-2xl font-bold text-gray-900">Manage Member</h1>
                </div>

                {/* 1. Basic Details */}
                <div className="rounded-lg bg-white shadow-md overflow-hidden">
                    <button onClick={() => toggleSection('basic')} className="flex w-full items-center justify-between bg-indigo-50 px-6 py-4 text-left hover:bg-indigo-100">
                        <div className="flex items-center gap-3">
                            <User className="h-6 w-6 text-indigo-600" />
                            <h2 className="text-lg font-semibold text-gray-900">Basic Details {memberUsername && <span className="text-sm font-normal text-gray-500">(ID: {memberUsername})</span>}</h2>
                        </div>
                        <span className="text-indigo-600">{isBasicDetailsOpen ? '−' : '+'}</span>
                    </button>
                    {isBasicDetailsOpen && (
                        <div className="p-6 grid grid-cols-1 gap-6 sm:grid-cols-2">
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Profile Created For*</label>
                                <select name="created_for" value={formData.created_for} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="Self">Self</option>
                                    <option value="Parent">Parent</option>
                                    <option value="Sibling">Sibling</option>
                                    <option value="Relative">Relative</option>
                                    <option value="Friend">Friend</option>
                                    <option value="Marriage Bureau">Marriage Bureau</option>
                                    <option value="Client">Client</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">First Name*</label>
                                <input type="text" name="first_name" value={formData.first_name} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Last Name*</label>
                                <input type="text" name="last_name" value={formData.last_name} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Phone*</label>
                                <input type="tel" name="phone" value={formData.phone} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Email</label>
                                <input type="email" name="email" value={formData.email} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Date of Birth*</label>
                                <input type="date" name="dob" value={formData.dob} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                            </div>
                            {calculatedAge !== null && (
                                <div>
                                    <label className="block text-sm font-medium text-gray-700">Age</label>
                                    <input type="text" value={calculatedAge} disabled className="mt-1 block w-full rounded-md border border-gray-300 bg-gray-100 px-3 py-2 text-gray-500 shadow-sm sm:text-sm" />
                                </div>
                            )}
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Gender*</label>
                                <select name="gender" value={formData.gender} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="Male">Male</option>
                                    <option value="Female">Female</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Height*</label>
                                <select name="height" value={formData.height} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="4'0&quot; (121 cm)">4&apos;0&quot; (121 cm)</option>
                                    <option value="4'1&quot; (124 cm)">4&apos;1&quot; (124 cm)</option>
                                    <option value="4'2&quot; (127 cm)">4&apos;2&quot; (127 cm)</option>
                                    <option value="4'3&quot; (130 cm)">4&apos;3&quot; (130 cm)</option>
                                    <option value="4'4&quot; (132 cm)">4&apos;4&quot; (132 cm)</option>
                                    <option value="4'5&quot; (134 cm)">4&apos;5&quot; (134 cm)</option>
                                    <option value="4'6&quot; (137 cm)">4&apos;6&quot; (137 cm)</option>
                                    <option value="4'7&quot; (139 cm)">4&apos;7&quot; (139 cm)</option>
                                    <option value="4'8&quot; (142 cm)">4&apos;8&quot; (142 cm)</option>
                                    <option value="4'9&quot; (144 cm)">4&apos;9&quot; (144 cm)</option>
                                    <option value="4'10&quot; (147 cm)">4&apos;10&quot; (147 cm)</option>
                                    <option value="4'11&quot; (149 cm)">4&apos;11&quot; (149 cm)</option>
                                    <option value="5'0&quot; (152 cm)">5&apos;0&quot; (152 cm)</option>
                                    <option value="5'1&quot; (154 cm)">5&apos;1&quot; (154 cm)</option>
                                    <option value="5'2&quot; (157 cm)">5&apos;2&quot; (157 cm)</option>
                                    <option value="5'3&quot; (160 cm)">5&apos;3&quot; (160 cm)</option>
                                    <option value="5'4&quot; (162 cm)">5&apos;4&quot; (162 cm)</option>
                                    <option value="5'5&quot; (165 cm)">5&apos;5&quot; (165 cm)</option>
                                    <option value="5'6&quot; (167 cm)">5&apos;6&quot; (167 cm)</option>
                                    <option value="5'7&quot; (170 cm)">5&apos;7&quot; (170 cm)</option>
                                    <option value="5'8&quot; (172 cm)">5&apos;8&quot; (172 cm)</option>
                                    <option value="5'9&quot; (175 cm)">5&apos;9&quot; (175 cm)</option>
                                    <option value="5'10&quot; (177 cm)">5&apos;10&quot; (177 cm)</option>
                                    <option value="5'11&quot; (180 cm)">5&apos;11&quot; (180 cm)</option>
                                    <option value="6'0&quot; (182 cm)">6&apos;0&quot; (182 cm)</option>
                                    <option value="6'1&quot; (185 cm)">6&apos;1&quot; (185 cm)</option>
                                    <option value="6'2&quot; (187 cm)">6&apos;2&quot; (187 cm)</option>
                                    <option value="6'3&quot; (190 cm)">6&apos;3&quot; (190 cm)</option>
                                    <option value="6'4&quot; (193 cm)">6&apos;4&quot; (193 cm)</option>
                                    <option value="6'5&quot; (195 cm)">6&apos;5&quot; (195 cm)</option>
                                    <option value="6'6&quot; (198 cm)">6&apos;6&quot; (198 cm)</option>
                                    <option value="6'7&quot; (200 cm)">6&apos;7&quot; (200 cm)</option>
                                    <option value="6'8&quot; (203 cm)">6&apos;8&quot; (203 cm)</option>
                                    <option value="6'9&quot; (205 cm)">6&apos;9&quot; (205 cm)</option>
                                    <option value="6'10&quot; (208 cm)">6&apos;10&quot; (208 cm)</option>
                                    <option value="6'11&quot; (210 cm)">6&apos;11&quot; (210 cm)</option>
                                    <option value="7'0&quot; (213 cm)">7&apos;0&quot; (213 cm)</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Marital Status*</label>
                                <select name="marital_status" value={formData.marital_status} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="Never Married">Never Married</option>
                                    <option value="Divorced">Divorced</option>
                                    <option value="Widowed">Widowed</option>
                                    <option value="Awaiting Divorce">Awaiting Divorce</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Mother Tongue*</label>
                                <select name="mother_tongue" value={formData.mother_tongue} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="Hindi">Hindi</option>
                                    <option value="English">English</option>
                                    <option value="Punjabi">Punjabi</option>
                                    <option value="Bengali">Bengali</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Disability</label>
                                <select name="disability" value={formData.disability} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="None">None</option>
                                    <option value="Physical">Physical</option>
                                    <option value="Mental">Mental</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                            {formData.disability && formData.disability !== 'None' && (
                                <>
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700">Disability Type</label>
                                        <input type="text" name="disability_type" value={formData.disability_type} onChange={handleChange} placeholder="e.g. Visual Impairment" className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                                    </div>
                                    <div className="col-span-full">
                                        <label className="block text-sm font-medium text-gray-700">Disability Description</label>
                                        <textarea name="disability_description" value={formData.disability_description} onChange={handleChange} rows={2} placeholder="Please provide more details..." className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                                    </div>
                                </>
                            )}
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Aadhar Number (Optional)</label>
                                <div className="relative">
                                    <input
                                        type="text"
                                        name="aadhar_number"
                                        value={formData.aadhar_number}
                                        onChange={handleChange}
                                        className={`mt-1 block w-full rounded-md border ${aadharError ? 'border-red-500 focus:border-red-500 focus:ring-red-500' : 'border-gray-300 focus:border-indigo-500 focus:ring-indigo-500'} px-3 py-2 shadow-sm focus:outline-none sm:text-sm text-black`}
                                    />
                                    {aadharError && (
                                        <p className="absolute -bottom-5 left-0 text-xs text-red-500 font-medium">
                                            {aadharError}
                                        </p>
                                    )}
                                </div>
                                <p className={`text-xs text-gray-400 mt-1 ${aadharError ? 'opacity-0' : ''}`}>Verification ensures a trusted profile</p>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Blood Group (Optional)</label>
                                <select name="blood_group" value={formData.blood_group} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="A+">A+</option>
                                    <option value="O+">O+</option>
                                    <option value="B+">B+</option>
                                    <option value="AB+">AB+</option>
                                    <option value="A-">A-</option>
                                    <option value="O-">O-</option>
                                    <option value="B-">B-</option>
                                    <option value="AB-">AB-</option>
                                </select>
                            </div>

                            <button onClick={() => handleUpdate('basic')} className="col-span-full md:col-start-2 bg-indigo-600 text-white py-2 rounded-md hover:bg-indigo-700">
                                Save Changes
                            </button>
                        </div>
                    )}
                </div>

                {/* 2. Location Details */}
                <div className="rounded-lg bg-white shadow-md overflow-hidden">
                    <button onClick={() => toggleSection('location')} className="flex w-full items-center justify-between bg-indigo-50 px-6 py-4 text-left hover:bg-indigo-100">
                        <div className="flex items-center gap-3">
                            <MapPin className="h-6 w-6 text-indigo-600" />
                            <h2 className="text-lg font-semibold text-gray-900">Location Details</h2>
                        </div>
                        <span className="text-indigo-600">{isLocationDetailsOpen ? '−' : '+'}</span>
                    </button>
                    {isLocationDetailsOpen && (
                        <div className="p-6 grid grid-cols-1 gap-6 sm:grid-cols-3">
                            <div className="col-span-full flex justify-end">
                                <button type="button" onClick={handleUseCurrentLocation} disabled={isLocating} className="flex items-center gap-2 text-sm text-indigo-600 hover:text-indigo-800 font-medium disabled:opacity-50">
                                    <MapPin className="h-4 w-4" />
                                    {isLocating ? 'Update from Current Location' : 'Update from Current Location'}
                                </button>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Country*</label>
                                <select name="country" value={formData.country} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="India">India</option>
                                    <option value="USA">USA</option>
                                    <option value="UK">UK</option>
                                    <option value="Canada">Canada</option>
                                    <option value="Australia">Australia</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">State*</label>
                                {formData.country === 'India' ? (
                                    <select name="state" value={formData.state} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                        <option value="">Select State</option>
                                        {indianStates.map(state => <option key={state} value={state}>{state}</option>)}
                                    </select>
                                ) : (
                                    <input type="text" name="state" value={formData.state} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                                )}
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">City*</label>
                                <input type="text" name="city" value={formData.city} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                            </div>
                            <div className="col-span-full">
                                <button onClick={() => handleUpdate('location')} className="w-full rounded-md bg-indigo-600 px-4 py-2 text-white hover:bg-indigo-700">Save Changes</button>
                            </div>
                        </div>
                    )}
                </div>

                {/* 3. Family Details */}
                <div className="rounded-lg bg-white shadow-md overflow-hidden">
                    <button onClick={() => toggleSection('family')} className="flex w-full items-center justify-between bg-indigo-50 px-6 py-4 text-left hover:bg-indigo-100">
                        <div className="flex items-center gap-3">
                            <Users className="h-6 w-6 text-indigo-600" />
                            <h2 className="text-lg font-semibold text-gray-900">Family Details</h2>
                        </div>
                        <span className="text-indigo-600">{isFamilyDetailsOpen ? '−' : '+'}</span>
                    </button>
                    {isFamilyDetailsOpen && (
                        <div className="p-6 grid grid-cols-1 gap-6 sm:grid-cols-2">
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Father&apos;s Status*</label>
                                <select name="father_status" value={formData.father_status} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="Employed">Employed</option>
                                    <option value="Business">Business</option>
                                    <option value="Retired">Retired</option>
                                    <option value="Not Employed">Not Employed</option>
                                    <option value="Passed Away">Passed Away</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Mother&apos;s Status*</label>
                                <select name="mother_status" value={formData.mother_status} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="Homemaker">Homemaker</option>
                                    <option value="Employed">Employed</option>
                                    <option value="Business">Business</option>
                                    <option value="Retired">Retired</option>
                                    <option value="Passed Away">Passed Away</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Brothers</label>
                                <input type="number" name="brothers" value={formData.brothers} onChange={handleChange} min="0" className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Sisters</label>
                                <input type="number" name="sisters" value={formData.sisters} onChange={handleChange} min="0" className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Family Status*</label>
                                <select name="family_status" value={formData.family_status} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="Middle Class">Middle Class</option>
                                    <option value="Upper Middle Class">Upper Middle Class</option>
                                    <option value="Rich">Rich</option>
                                    <option value="Affluent">Affluent</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Family Type*</label>
                                <select name="family_type" value={formData.family_type} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="Joint">Joint</option>
                                    <option value="Nuclear">Nuclear</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Family Values*</label>
                                <select name="family_values" value={formData.family_values} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="Traditional">Traditional</option>
                                    <option value="Moderate">Moderate</option>
                                    <option value="Liberal">Liberal</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Family Annual Income</label>
                                <select name="annual_income" value={formData.annual_income} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="0-2 Lakh">0-2 Lakh</option>
                                    <option value="2-5 Lakh">2-5 Lakh</option>
                                    <option value="5-10 Lakh">5-10 Lakh</option>
                                    <option value="10-20 Lakh">10-20 Lakh</option>
                                    <option value="20+ Lakh">20+ Lakh</option>
                                </select>
                            </div>

                            <button onClick={() => handleUpdate('family')} className="col-span-full md:col-start-2 bg-indigo-600 text-white py-2 rounded-md hover:bg-indigo-700">
                                Save Changes
                            </button>
                        </div>
                    )}
                </div>

                {/* 4. Education & Career */}
                <div className="rounded-lg bg-white shadow-md overflow-hidden">
                    <button onClick={() => toggleSection('education')} className="flex w-full items-center justify-between bg-indigo-50 px-6 py-4 text-left hover:bg-indigo-100">
                        <div className="flex items-center gap-3">
                            <Briefcase className="h-6 w-6 text-indigo-600" />
                            <h2 className="text-lg font-semibold text-gray-900">Education & Career</h2>
                        </div>
                        <span className="text-indigo-600">{isEduCareerDetailsOpen ? '−' : '+'}</span>
                    </button>
                    {isEduCareerDetailsOpen && (
                        <div className="p-6 grid grid-cols-1 gap-6 sm:grid-cols-2">
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Highest Education*</label>
                                <select name="highest_education" value={formData.highest_education} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="High School">High School</option>
                                    <option value="Bachelors">Bachelors</option>
                                    <option value="Masters">Masters</option>
                                    <option value="Doctorate">Doctorate</option>
                                    <option value="Diploma">Diploma</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Educational Details</label>
                                <input type="text" name="educational_details" value={formData.educational_details} onChange={handleChange} placeholder="e.g. B.Tech in CS" className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Occupation*</label>
                                <select name="occupation" value={formData.occupation} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="Private Sector">Private Sector</option>
                                    <option value="Government Service">Government Service</option>
                                    <option value="Business">Business</option>
                                    <option value="Self Employed">Self Employed</option>
                                    <option value="Not Working">Not Working</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Employed In*</label>
                                <select name="employed_in" value={formData.employed_in} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="Private">Private</option>
                                    <option value="Government">Government</option>
                                    <option value="Defense">Defense</option>
                                    <option value="Business">Business</option>
                                    <option value="Self Employed">Self Employed</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Annual Income*</label>
                                <select name="personal_income" value={formData.personal_income} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="0-2 Lakh">0-2 Lakh</option>
                                    <option value="2-5 Lakh">2-5 Lakh</option>
                                    <option value="5-10 Lakh">5-10 Lakh</option>
                                    <option value="10-15 Lakh">10-15 Lakh</option>
                                    <option value="15-20 Lakh">15-20 Lakh</option>
                                    <option value="20+ Lakh">20+ Lakh</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Working Sector (Optional)</label>
                                <input type="text" name="working_sector" value={formData.working_sector} onChange={handleChange} placeholder="e.g. IT, Healthcare" className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                            </div>

                            <button onClick={() => handleUpdate('education')} className="col-span-full md:col-start-2 bg-indigo-600 text-white py-2 rounded-md hover:bg-indigo-700">
                                Save Changes
                            </button>
                        </div>
                    )}
                </div>

                {/* 5. Religious */}
                <div className="rounded-lg bg-white shadow-md overflow-hidden">
                    <button onClick={() => toggleSection('religious')} className="flex w-full items-center justify-between bg-indigo-50 px-6 py-4 text-left hover:bg-indigo-100">
                        <div className="flex items-center gap-3">
                            <Heart className="h-6 w-6 text-indigo-600" />
                            <h2 className="text-lg font-semibold text-gray-900">Religious Info</h2>
                        </div>
                        <span className="text-indigo-600">{isReligiousOpen ? '−' : '+'}</span>
                    </button>
                    {isReligiousOpen && (
                        <div className="p-6 grid grid-cols-1 gap-6 sm:grid-cols-2">
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Religion*</label>
                                <select name="religion" value={formData.religion} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="Hindu">Hindu</option>
                                    <option value="Muslim">Muslim</option>
                                    <option value="Christian">Christian</option>
                                    <option value="Sikh">Sikh</option>
                                    <option value="Jain">Jain</option>
                                    <option value="Buddhist">Buddhist</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Community/Caste*</label>
                                <input type="text" name="community" value={formData.community} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                            </div>
                            <button onClick={() => handleUpdate('religious')} className="col-span-full md:col-start-2 bg-indigo-600 text-white py-2 rounded-md hover:bg-indigo-700">
                                Save Changes
                            </button>
                        </div>
                    )}
                </div>

                {/* 6. Lifestyle */}
                <div className="rounded-lg bg-white shadow-md overflow-hidden">
                    <button onClick={() => toggleSection('lifestyle')} className="flex w-full items-center justify-between bg-indigo-50 px-6 py-4 text-left hover:bg-indigo-100">
                        <div className="flex items-center gap-3">
                            <Info className="h-6 w-6 text-indigo-600" />
                            <h2 className="text-lg font-semibold text-gray-900">Lifestyle</h2>
                        </div>
                        <span className="text-indigo-600">{isLifestyleOpen ? '−' : '+'}</span>
                    </button>
                    {isLifestyleOpen && (
                        <div className="p-6 grid grid-cols-1 gap-6 sm:grid-cols-3">
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Appearance*</label>
                                <select name="appearance" value={formData.appearance} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="Fair">Fair</option>
                                    <option value="Wheatish">Wheatish</option>
                                    <option value="Dark">Dark</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Living Status*</label>
                                <select name="living_status" value={formData.living_status} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="With Family">With Family</option>
                                    <option value="Alone">Alone</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Eating Habits*</label>
                                <select name="eating_habits" value={formData.eating_habits} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Select</option>
                                    <option value="Vegetarian">Vegetarian</option>
                                    <option value="Non-Vegetarian">Non-Vegetarian</option>
                                    <option value="Eggetarian">Eggetarian</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Smoking Habits</label>
                                <select name="smoking_habits" value={formData.smoking_habits} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="No">No</option>
                                    <option value="Yes">Yes</option>
                                    <option value="Occasionally">Occasionally</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Drinking Habits</label>
                                <select name="drinking_habits" value={formData.drinking_habits} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="No">No</option>
                                    <option value="Yes">Yes</option>
                                    <option value="Occasionally">Occasionally</option>
                                </select>
                            </div>

                            <button onClick={() => handleUpdate('lifestyle')} className="col-span-full md:col-start-2 bg-indigo-600 text-white py-2 rounded-md hover:bg-indigo-700">
                                Save Changes
                            </button>
                        </div>
                    )}
                </div>

                {/* 7. Contact Details */}
                <div className="rounded-lg bg-white shadow-md overflow-hidden">
                    <button onClick={() => toggleSection('contact')} className="flex w-full items-center justify-between bg-indigo-50 px-6 py-4 text-left hover:bg-indigo-100">
                        <div className="flex items-center gap-3">
                            <Phone className="h-6 w-6 text-indigo-600" />
                            <h2 className="text-lg font-semibold text-gray-900">Contact Details</h2>
                        </div>
                        <span className="text-indigo-600">{isContactOpen ? '−' : '+'}</span>
                    </button>
                    {isContactOpen && (
                        <div className="p-6 grid grid-cols-1 gap-6 sm:grid-cols-2">
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Phone</label>
                                <input type="text" value={formData.phone} disabled className="mt-1 block w-full bg-gray-100 rounded-md border border-gray-300 px-3 py-2 shadow-sm" />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Alternate Mobile (Optional)</label>
                                <input type="text" name="alternate_mobile" value={formData.alternate_mobile} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Suitable Time To Call (Optional)</label>
                                <div className="flex gap-2 items-center mt-1">
                                    <div className="flex-1">
                                        <label className="text-xs text-gray-500 mb-1 block">From</label>
                                        <input
                                            type="time"
                                            value={formData.suitable_time_to_call?.split(' - ')[0] || ''}
                                            onChange={(e) => {
                                                const start = e.target.value;
                                                const end = formData.suitable_time_to_call?.split(' - ')[1] || '';
                                                setFormData(prev => ({ ...prev, suitable_time_to_call: `${start} - ${end}` }));
                                            }}
                                            className="block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black"
                                        />
                                    </div>
                                    <span className="text-gray-400 mt-5">-</span>
                                    <div className="flex-1">
                                        <label className="text-xs text-gray-500 mb-1 block">To</label>
                                        <input
                                            type="time"
                                            value={formData.suitable_time_to_call?.split(' - ')[1] || ''}
                                            onChange={(e) => {
                                                const start = formData.suitable_time_to_call?.split(' - ')[0] || '';
                                                const end = e.target.value;
                                                setFormData(prev => ({ ...prev, suitable_time_to_call: `${start} - ${end}` }));
                                            }}
                                            className="block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black"
                                        />
                                    </div>
                                </div>
                            </div>

                            <button onClick={() => handleUpdate('contact')} className="col-span-full md:col-start-2 bg-indigo-600 text-white py-2 rounded-md hover:bg-indigo-700">
                                Save Changes
                            </button>
                        </div>
                    )}
                </div>

                {/* 8. About Me */}
                <div className="rounded-lg bg-white shadow-md overflow-hidden">
                    <button onClick={() => toggleSection('about')} className="flex w-full items-center justify-between bg-indigo-50 px-6 py-4 text-left hover:bg-indigo-100">
                        <div className="flex items-center gap-3">
                            <User className="h-6 w-6 text-indigo-600" />
                            <h2 className="text-lg font-semibold text-gray-900">About Me</h2>
                        </div>
                        <span className="text-indigo-600">{isAboutOpen ? '−' : '+'}</span>
                    </button>
                    {isAboutOpen && (
                        <div className="p-6">
                            <label className="block text-sm font-medium text-gray-700">About Me* (Min 50 chars)</label>
                            <textarea name="about_me" rows={5} value={formData.about_me} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm" placeholder="Write something..." />
                            <div className="mt-4 flex justify-end"><button onClick={() => handleUpdate('about')} className="rounded-md bg-indigo-600 px-4 py-2 text-white hover:bg-indigo-700">Save Changes</button></div>
                        </div>
                    )}
                </div>

                {/* 9. Property Details */}
                <div className="rounded-lg bg-white shadow-md overflow-hidden">
                    <button onClick={() => toggleSection('property')} className="flex w-full items-center justify-between bg-indigo-50 px-6 py-4 text-left hover:bg-indigo-100">
                        <div className="flex items-center gap-3">
                            <Briefcase className="h-6 w-6 text-indigo-600" />
                            <h2 className="text-lg font-semibold text-gray-900">Property Details</h2>
                        </div>
                        <span className="text-indigo-600">{isPropertyOpen ? '−' : '+'}</span>
                    </button>
                    {isPropertyOpen && (
                        <div className="p-6 grid grid-cols-1 gap-6 sm:grid-cols-2">
                            <div><label className="block text-sm font-medium text-gray-700">Land Area (Acres)</label><input type="number" name="land_area" value={formData.land_area} onChange={handleChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm" /></div>
                            <div className="col-span-full"><button onClick={() => handleUpdate('property')} className="w-full rounded-md bg-indigo-600 px-4 py-2 text-white hover:bg-indigo-700">Save Changes</button></div>
                        </div>
                    )}
                </div>

                {/* 10. Partner Preferences */}
                <div className="rounded-lg bg-white shadow-md overflow-hidden">
                    <button onClick={() => toggleSection('preferences')} className="flex w-full items-center justify-between bg-indigo-50 px-6 py-4 text-left hover:bg-indigo-100">
                        <div className="flex items-center gap-3">
                            <Sliders className="h-6 w-6 text-indigo-600" />
                            <h2 className="text-lg font-semibold text-gray-900">Partner Preferences</h2>
                        </div>
                        <span className="text-indigo-600">{isPreferencesOpen ? '−' : '+'}</span>
                    </button>
                    {isPreferencesOpen && (
                        <div className="p-6 grid grid-cols-1 gap-6 sm:grid-cols-2">
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Minimum Age (Optional)</label>
                                <input type="number" name="minAge" value={formData.partner_preferences?.minAge} onChange={handlePreferenceChange} min="18" max="100" className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Maximum Age (Optional)</label>
                                <input type="number" name="maxAge" value={formData.partner_preferences?.maxAge} onChange={handlePreferenceChange} min="18" max="100" className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Preferred Religion (Optional)</label>
                                <select name="religion" value={formData.partner_preferences?.religion} onChange={handlePreferenceChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Any</option>
                                    <option value="Hindu">Hindu</option>
                                    <option value="Muslim">Muslim</option>
                                    <option value="Christian">Christian</option>
                                    <option value="Sikh">Sikh</option>
                                    <option value="Jain">Jain</option>
                                    <option value="Buddhist">Buddhist</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Preferred Community (Optional)</label>
                                <input type="text" name="community" value={formData.partner_preferences?.community} onChange={handlePreferenceChange} placeholder="Any" className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Preferred Location (Optional)</label>
                                <input type="text" name="location" value={formData.partner_preferences?.location} onChange={handlePreferenceChange} placeholder="City, State, or Country" className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                            </div>

                            {/* New Filters */}
                            <div>
                                <label className="block text-sm font-medium text-gray-700">Marital Status</label>
                                <select name="marital_status" value={formData.partner_preferences?.marital_status} onChange={handlePreferenceChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Any</option>
                                    <option value="Never Married">Never Married</option>
                                    <option value="Divorced">Divorced</option>
                                    <option value="Widowed">Widowed</option>
                                    <option value="Separated">Separated</option>
                                </select>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700">Eating Habits (Diet)</label>
                                <select name="eating_habits" value={formData.partner_preferences?.eating_habits} onChange={handlePreferenceChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Any</option>
                                    <option value="Vegetarian">Vegetarian</option>
                                    <option value="Non-Vegetarian">Non-Vegetarian</option>
                                    <option value="Eggetarian">Eggetarian</option>
                                </select>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700">Smoking Habits</label>
                                <select name="smoking_habits" value={formData.partner_preferences?.smoking_habits} onChange={handlePreferenceChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Any</option>
                                    <option value="No">No</option>
                                    <option value="Yes">Yes</option>
                                    <option value="Occasionally">Occasionally</option>
                                </select>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700">Drinking Habits</label>
                                <select name="drinking_habits" value={formData.partner_preferences?.drinking_habits} onChange={handlePreferenceChange} className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black">
                                    <option value="">Any</option>
                                    <option value="No">No</option>
                                    <option value="Yes">Yes</option>
                                    <option value="Occasionally">Occasionally</option>
                                </select>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700">Highest Education</label>
                                <input type="text" name="highest_education" value={formData.partner_preferences?.highest_education} onChange={handlePreferenceChange} placeholder="e.g. MBA, B.Tech" className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700">Occupation</label>
                                <input type="text" name="occupation" value={formData.partner_preferences?.occupation} onChange={handlePreferenceChange} placeholder="e.g. Software Engineer" className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700">Annual Income</label>
                                <input type="text" name="annual_income" value={formData.partner_preferences?.annual_income} onChange={handlePreferenceChange} placeholder="e.g. 10 LPA" className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm text-black" />
                            </div>

                            <button onClick={async () => {
                                setLoading(true);
                                try {
                                    await api.put(`/franchise/profiles/${memberId}/preferences`, { preferences: formData.partner_preferences });
                                    addToast('Preferences updated successfully', 'success');
                                    setIsPreferencesOpen(false);
                                    setIsPhotosOpen(true);
                                } catch (error) {
                                    addToast('Failed to update preferences', 'error');
                                } finally {
                                    setLoading(false);
                                }
                            }} className="col-span-full md:col-start-2 bg-indigo-600 text-white py-2 rounded-md hover:bg-indigo-700">
                                Save Preferences
                            </button>
                        </div>
                    )}
                </div>

                {/* 11. Photos */}
                <div className="rounded-lg bg-white shadow-md overflow-hidden">
                    <button onClick={() => toggleSection('photos')} className="flex w-full items-center justify-between bg-indigo-50 px-6 py-4 text-left hover:bg-indigo-100">
                        <div className="flex items-center gap-3">
                            <Camera className="h-6 w-6 text-indigo-600" />
                            <h2 className="text-lg font-semibold text-gray-900">Photos</h2>
                        </div>
                        <span className="text-indigo-600">{isPhotosOpen ? '−' : '+'}</span>
                    </button>
                    {isPhotosOpen && (
                        <div className="p-6">
                            <PhotoUploadGrid
                                photos={photos}
                                setPhotos={setPhotos}
                                updateProfilePhotoLocal={updateProfilePhotoLocal}
                                uploadEndpoint={memberId ? `/franchise/profiles/${memberId}/photos` : undefined}
                                deleteEndpoint={memberId ? `/franchise/profiles/${memberId}/photos` : undefined}
                                setProfileEndpoint={memberId ? `/franchise/profiles/${memberId}/photos` : undefined}
                            />

                            <div className="mt-6 flex justify-end">
                                <button onClick={handleFinalSubmit} className="bg-green-600 text-white py-3 px-8 rounded-xl hover:bg-green-700 font-bold shadow-md">
                                    Return to Dashboard
                                </button>
                            </div>
                        </div>
                    )}
                </div>

            </div>
        </div>
    );
}
