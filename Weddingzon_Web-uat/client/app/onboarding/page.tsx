'use client';

import { useState, useEffect, useRef, Suspense } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import api from '../services/api';
import {
    Briefcase,
    MapPin,
    Users,
    GraduationCap,
    Heart,
    User,
    Phone,
    Info,
    Camera,
    Check,
    ChevronRight,
    ChevronLeft
} from 'lucide-react';
import PhotoUploadGrid from '../components/PhotoUploadGrid';
import { useToast } from '../contexts/ToastContext';
import { useAuth } from '../context/AuthContext';
import { motion, AnimatePresence } from 'framer-motion';
import LanguageSwitcher from '@/components/LanguageSwitcher';

// --- Constants & Options ---
const indianStates = [
    "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh", "Goa", "Gujarat",
    "Haryana", "Himachal Pradesh", "Jharkhand", "Karnataka", "Kerala", "Madhya Pradesh",
    "Maharashtra", "Manipur", "Meghalaya", "Mizoram", "Nagaland", "Odisha", "Punjab",
    "Rajasthan", "Sikkim", "Tamil Nadu", "Telangana", "Tripura", "Uttar Pradesh",
    "Uttarakhand", "West Bengal", "Andaman and Nicobar Islands", "Chandigarh",
    "Dadra and Nagar Haveli and Daman and Diu", "Delhi", "Jammu and Kashmir", "Ladakh",
    "Lakshadweep", "Puducherry"
];

// Steps Configuration - Will be translated inside the component
const GET_STEPS = () => [
    { id: 'basic', title: 'Basic Details', icon: User },
    { id: 'location', title: 'Location', icon: MapPin },
    { id: 'family', title: 'Family', icon: Users },
    { id: 'education', title: 'Education & Career', icon: GraduationCap },
    { id: 'religious', title: 'Religious', icon: Heart },
    { id: 'lifestyle', title: 'Lifestyle', icon: Info },
    { id: 'contact', title: 'Contact', icon: Phone },
    { id: 'about', title: 'About Me', icon: User },
    { id: 'property', title: 'Property', icon: Briefcase },
    { id: 'photos', title: 'Photos', icon: Camera },
];

export default function Onboarding() {
    return (
        <Suspense fallback={
            <div className="min-h-screen flex items-center justify-center bg-white text-[#EF2F55]">
                <div className="animate-pulse font-black text-xl">Loading...</div>
            </div>
        }>
            <OnboardingContent />
        </Suspense>
    );
}

function OnboardingContent() {
    const router = useRouter();
    const searchParams = useSearchParams();
    const stepParam = searchParams.get('step');
    const { addToast } = useToast();
    const { checkAuth } = useAuth();
    const STEPS = GET_STEPS();

    // UI State
    const [currentStep, setCurrentStep] = useState(0);
    const [direction, setDirection] = useState(0); // -1 for prev, 1 for next

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
        weight: '',
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
        manglik_status: '',
        time_of_birth: '',
        place_of_birth: '',
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
        profilePhoto: '',
    });

    const [loading, setLoading] = useState(true);
    const [dynamicFilters, setDynamicFilters] = useState<any[]>([]);
    const [calculatedAge, setCalculatedAge] = useState<number | null>(null);
    const [usernameError, setUsernameError] = useState<string>('');
    const [aadharError, setAadharError] = useState<string>('');
    const [isLocating, setIsLocating] = useState(false);

    // --- Fetch User Data ---
    useEffect(() => {
        const fetchUser = async () => {
            try {
                const res = await api.get('/auth/me?full=true');
                const user = res.data;
                const formattedDob = user.dob ? new Date(user.dob).toISOString().split('T')[0] : '';

                // Merge fetched data with initial state to ensure all fields exist
                setFormData(prev => ({
                    ...prev,
                    ...user,
                    dob: formattedDob,
                    hobbies: user.hobbies || [],
                    property_types: user.property_types || [],
                    land_types: user.land_types || [],
                    house_types: user.house_types || [],
                    business_types: user.business_types || [],
                }));

                if (user.photos) {
                    setPhotos(user.photos);
                }

                if (formattedDob) {
                    calculateAge(formattedDob);
                }

                // Initial Step Navigation Logic based on completion
                if (stepParam) {
                    const stepIdx = STEPS.findIndex(s => s.id === stepParam);
                    if (stepIdx !== -1) {
                        setCurrentStep(stepIdx);
                        setLoading(false);
                        return;
                    }
                }

                if (!user.first_name || !formattedDob || !user.gender) setCurrentStep(0);
                else if (!user.country || !user.state) setCurrentStep(1);
                else if (!user.family_status) setCurrentStep(2);
                else if (!user.highest_education) setCurrentStep(3);
                else if (!user.religion) setCurrentStep(4);
                else if (!user.appearance) setCurrentStep(5);
                else if (!user.phone) setCurrentStep(6);
                else if (!user.about_me) setCurrentStep(7);
                else setCurrentStep(8); // Property or Photos

            } catch (error) {
                console.error('Failed to fetch user', error);
            } finally {
                setLoading(false);
            }
        };

        const fetchFilters = async () => {
            try {
                const filterRes = await api.get('/filters');
                if (filterRes.data && filterRes.data.success) {
                    // Only include filters explicitly enabled for onboarding
                    const enabledFilters = filterRes.data.data.filter((f: any) => f.onboardingEnabled);
                    setDynamicFilters(enabledFilters);
                }
            } catch (err) {
                console.error('Failed to fetch dynamic filters', err);
            }
        };

        fetchUser();
        fetchFilters();
    }, [stepParam]);

    // --- Helpers ---
    const calculateAge = (dobValue: string) => {
        const today = new Date();
        const birthDate = new Date(dobValue);
        let age = today.getFullYear() - birthDate.getFullYear();
        const m = today.getMonth() - birthDate.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
            age--;
        }
        setCalculatedAge(age);
        return age; // Return for immediate validation
    };

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
        const { name, value } = e.target;

        if (name === 'aadhar_number') {
            const numericValue = value.replace(/\D/g, '');
            if (numericValue.length > 12) return;
            setFormData(prev => ({ ...prev, [name]: numericValue }));
            if (numericValue.length > 0 && numericValue.length !== 12) setAadharError('Must be 12 digits');
            else setAadharError('');
            return;
        }

        if (name === 'alternate_mobile') {
            const numericValue = value.replace(/\D/g, '');
            if (numericValue.length > 10) return;
            setFormData(prev => ({ ...prev, [name]: numericValue }));
            return;
        }

        if (name === 'country') {
            setFormData(prev => ({ ...prev, [name]: value, state: '', city: '' }));
        } else if (name.startsWith('extra_details.')) {
            const key = name.replace('extra_details.', '');
            setFormData(prev => ({
                ...prev,
                extra_details: {
                    ...(prev as any).extra_details,
                    [key]: value
                }
            }));
        } else {
            setFormData(prev => ({ ...prev, [name]: value }));
        }

        if (name === 'dob') {
            const age = calculateAge(value);
            if (age < 18) addToast("You must be at least 18 years old.", 'error');
            else if (age > 150) addToast("Please enter a valid date of birth.", 'error');
        }
    };

    const handleUseCurrentLocation = () => {
        if (!navigator.geolocation) {
            addToast("Geolocation is not supported by your browser.", 'error');
            return;
        }
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
                        city: data.address.city || data.address.town || data.address.village || ''
                    }));
                    addToast("Location updated successfully!", 'success');
                }
            } catch (error) {
                addToast("Failed to fetch location. Please enter manually.", 'error');
            } finally {
                setIsLocating(false);
            }
        }, () => {
            addToast("Location permission denied.", 'error');
            setIsLocating(false);
        });
    };

    // --- Validation Logic ---
    const validateStep = (stepIndex: number): boolean => {
        const stepId = STEPS[stepIndex].id;

        switch (stepId) {
            case 'basic':
                if (!formData.first_name || !formData.last_name || !formData.dob || !formData.gender || !formData.height || !formData.marital_status || !formData.mother_tongue) {
                    addToast("Please fill all mandatory fields.", 'error');
                    return false;
                }
                if (calculatedAge !== null && (calculatedAge < 18 || calculatedAge > 150)) {
                    addToast("Invalid age. Must be between 18 and 150.", 'error');
                    return false;
                }
                if (formData.aadhar_number && formData.aadhar_number.length !== 12) {
                    addToast("Aadhar number must be 12 digits.", 'error');
                    return false;
                }
                return true;
            case 'location':
                if (!formData.country || !formData.state || !formData.city) {
                    addToast("Please fill all mandatory fields.", 'error');
                    return false;
                }
                return true;
            case 'family':
                if (!formData.father_status || !formData.mother_status || !formData.family_status || !formData.family_type || !formData.family_values) {
                    addToast("Please fill all mandatory fields.", 'error');
                    return false;
                }
                return true;
            case 'education':
                if (!formData.highest_education || !formData.occupation || !formData.employed_in || !formData.personal_income) {
                    addToast("Please fill all mandatory fields.", 'error');
                    return false;
                }
                return true;
            case 'religious':
                if (!formData.religion || !formData.community) {
                    addToast("Please fill all mandatory fields.", 'error');
                    return false;
                }
                return true;
            case 'lifestyle':
                if (!formData.appearance || !formData.living_status || !formData.eating_habits) {
                    addToast("Please fill all mandatory fields.", 'error');
                    return false;
                }
                return true;
            case 'contact':
                // Phone is read-only now
                if (formData.alternate_mobile && formData.alternate_mobile.length !== 10) {
                    addToast("Alternate mobile must be 10 digits.", 'error');
                    return false;
                }
                return true;
            case 'about':
                if (!formData.about_me || formData.about_me.length < 50) {
                    addToast(`About me must be at least 50 characters. Current: ${formData.about_me?.length || 0}`, 'error');
                    return false;
                }
                return true;
            case 'property':
                return true; // Optional mostly
            case 'photos':
                const validPhotos = photos.filter(p => !p.isTemp && !p.error);
                if (validPhotos.length === 0) {
                    addToast("Please upload at least one photo.", 'error');
                    return false;
                }
                const isUploading = photos.some(p => p.isTemp && p.status !== 'error');
                if (isUploading) {
                    addToast("Please wait for all photos to finish uploading.", 'warning');
                    return false;
                }
                return true;
            default:
                return true;
        }
    };

    // --- Navigation Handlers ---
    const nextStep = async () => {
        if (!validateStep(currentStep)) return;

        // Save progress (auto-save)
        try {
            await api.post('/auth/register-details', formData);
        } catch (err) {
            console.error('Auto-save failed', err);
            // Don't block navigation on auto-save fail, but maybe warn? 
            // We'll proceed for UX smoothness unless it's critical.
        }

        if (currentStep < STEPS.length - 1) {
            setDirection(1);
            setCurrentStep(prev => prev + 1);
            window.scrollTo({ top: 0, behavior: 'smooth' });
        } else {
            // Final Submit
            handleSubmit();
        }
    };

    const prevStep = () => {
        if (currentStep > 0) {
            setDirection(-1);
            setCurrentStep(prev => prev - 1);
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }
    };

    const handleSubmit = async () => {
        try {
            const res = await api.post('/auth/register-details', { ...formData, is_profile_complete: true });
            if (res.status === 200) {
                await checkAuth();
                router.push('/settings/preferences');
            }
        } catch (error) {
            console.error('Final submit failed', error);
            addToast("Failed to save your details. Please try again.", 'error');
        }
    };

    if (loading) return (
        <div className="min-h-screen flex items-center justify-center bg-[#444444] text-white">
            <div className="animate-pulse">Loading Profile...</div>
        </div>
    );

    const CurrentStepIcon = STEPS[currentStep].icon;

    // Framer Motion Variants
    const variants = {
        enter: (direction: number) => ({
            x: direction > 0 ? '100%' : '-100%',
            opacity: 0,
        }),
        center: {
            x: 0,
            opacity: 1,
        },
        exit: (direction: number) => ({
            x: direction < 0 ? '100%' : '-100%',
            opacity: 0,
        }),
    };

    return (
        <div className="min-h-screen bg-white py-10 px-4 sm:px-6 lg:px-8 font-inter flex flex-col items-center relative">
            {/* Language Switcher Overlay */}
            <div className="absolute top-4 right-4 z-50">
                <LanguageSwitcher />
            </div>

            {/* Header Area */}
            <div className="text-center mb-12 max-w-2xl">
                <h1 className="text-[48px] font-black text-gray-900 mb-2 tracking-tight">
                    Create <span className="text-[#EF2F55]">Profile</span>
                </h1>
            </div>

            {/* Stepper (Desktop) */}
            <div className="w-full max-w-6xl mb-16 hidden md:flex items-center justify-between px-8 relative">
                {/* Background Line (Static Grey) */}
                <div className="absolute top-[20px] left-[8%] right-[8%] h-[2px] bg-gray-100 -z-0" />

                {/* Active Progress Line (Animated Pink) */}
                <motion.div
                    className="absolute top-[20px] left-[8%] h-[2px] bg-[#EF2F55] -z-0"
                    initial={false}
                    animate={{ width: `${(currentStep / (STEPS.length - 1)) * 84}%` }}
                    transition={{ type: "spring", stiffness: 100, damping: 20 }}
                />

                {STEPS.map((step, idx) => {
                    const isActive = idx === currentStep;
                    const isCompleted = idx < currentStep;
                    const Icon = step.icon;
                    return (
                        <div
                            key={step.id}
                            className="flex flex-col items-center relative z-10 flex-1 cursor-pointer group"
                            onClick={() => setCurrentStep(idx)}
                        >
                            <motion.div
                                animate={{
                                    backgroundColor: isActive || isCompleted ? '#EF2F55' : '#FFFFFF',
                                    borderColor: isActive || isCompleted ? '#EF2F55' : '#F3F4F6',
                                    scale: isActive ? 1.2 : 1,
                                    boxShadow: isActive ? '0 0 20px rgba(239,47,85,0.4)' : '0 0 0px rgba(0,0,0,0)',
                                }}
                                transition={{ duration: 0.3 }}
                                className={`w-10 h-10 rounded-full border-2 flex items-center justify-center relative active:scale-95`}
                            >
                                {isCompleted ? (
                                    <Check className="w-5 h-5 text-white" />
                                ) : (
                                    <Icon className={`w-5 h-5 transition-colors duration-300 ${isActive ? 'text-white' : 'text-gray-400 group-hover:text-[#EF2F55]'}`} />
                                )}

                                {isActive && (
                                    <motion.div
                                        layoutId="active-glow"
                                        className="absolute inset-0 rounded-full bg-[#EF2F55] opacity-20"
                                        initial={{ scale: 1 }}
                                        animate={{ scale: 1.5, opacity: 0 }}
                                        transition={{ repeat: Infinity, duration: 1.5 }}
                                    />
                                )}
                            </motion.div>

                            <div className="min-h-[32px] flex items-start justify-center mt-3">
                                <span className={`text-[10px] uppercase tracking-tighter font-black text-center max-w-[70px] leading-[1.1] transition-colors duration-300 ${isActive ? 'text-[#EF2F55]' : isCompleted ? 'text-gray-900' : 'text-gray-400 group-hover:text-gray-600'
                                    }`}>
                                    {step.title}
                                </span>
                            </div>
                        </div>
                    );
                })}
            </div>

            {/* Stepper (Mobile) */}
            <div className="w-full max-w-md mb-8 md:hidden px-4">
                <div className="flex items-center justify-between text-gray-900 mb-2">
                    <span className="text-sm font-black uppercase tracking-widest">{STEPS[currentStep].title}</span>
                    <span className="text-xs text-gray-400 font-bold">Step {currentStep + 1} of {STEPS.length}</span>
                </div>
                <div className="h-1.5 bg-gray-100 rounded-full overflow-hidden">
                    <motion.div
                        className="h-full bg-[#EF2F55]"
                        initial={{ width: 0 }}
                        animate={{ width: `${((currentStep + 1) / STEPS.length) * 100}%` }}
                        transition={{ duration: 0.3 }}
                    />
                </div>
            </div>

            {/* Main Card Content */}
            <div className="w-full max-w-4xl bg-white rounded-[32px] border border-gray-50 shadow-[0_20px_50px_rgba(0,0,0,0.05)] overflow-hidden min-h-[600px] flex flex-col relative scale-[1.01]">

                {/* Card Header for Current Step */}
                <div className="bg-white p-8 border-b border-gray-50 flex items-center gap-4">
                    <div className="p-3 bg-pink-50 rounded-2xl">
                        <CurrentStepIcon className="w-8 h-8 text-[#EF2F55]" />
                    </div>
                    <div>
                        <h2 className="text-2xl font-black text-gray-900 tracking-tight">{STEPS[currentStep].title}</h2>
                        <p className="text-xs text-gray-400 font-bold uppercase tracking-wider">Step {currentStep + 1} of {STEPS.length}</p>
                    </div>
                </div>

                {/* Scrollable Form Area */}
                <div className="flex-1 p-8 md:p-12 overflow-y-auto overflow-x-hidden relative">
                    <AnimatePresence initial={false} custom={direction} mode="wait">
                        <motion.div
                            key={currentStep}
                            custom={direction}
                            variants={variants}
                            initial="enter"
                            animate="center"
                            exit="exit"
                            transition={{ x: { type: "spring", stiffness: 300, damping: 30 }, opacity: { duration: 0.2 } }}
                            className="w-full h-full"
                        >
                            {renderStepContent(currentStep, formData, setFormData, handleChange, indianStates, calculatedAge, photos, setPhotos, handleUseCurrentLocation, dynamicFilters)}
                        </motion.div>
                    </AnimatePresence>
                </div>

                {/* Footer Actions */}
                <div className="p-8 bg-white border-t border-gray-50 flex justify-between items-center z-20 relative">
                    <button
                        onClick={prevStep}
                        disabled={currentStep === 0}
                        className={`flex items-center px-8 py-4 rounded-2xl font-black uppercase tracking-widest text-[10px] transition-all ${currentStep === 0
                            ? 'text-gray-200 cursor-not-allowed'
                            : 'text-gray-400 hover:text-gray-900 hover:bg-gray-50'
                            }`}
                    >
                        <ChevronLeft className="w-4 h-4 mr-2" />
                        Back
                    </button>

                    <button
                        onClick={nextStep}
                        className="flex items-center px-12 py-4 rounded-2xl bg-[#EF2F55] text-white font-black uppercase tracking-widest text-[10px] shadow-xl shadow-pink-200 hover:bg-[#D41F45] hover:shadow-pink-300 transition-all transform hover:-translate-y-1 active:translate-y-0"
                    >
                        {currentStep === STEPS.length - 1 ? "Finish Profile" : "Next Step"}
                        {currentStep !== STEPS.length - 1 && <ChevronRight className="w-4 h-4 ml-2" />}
                    </button>
                </div>
            </div>

            {/* Privacy Note */}
            <p className="mt-6 text-gray-500 text-xs text-center max-w-lg">
                Your information is safe with us. We do not share your personal contact details without your permission.
            </p>
        </div>
    );
}

// --- Render Helper Function (Splitting UI for readability) ---
function renderStepContent(
    step: number,
    formData: any,
    setFormData: any,
    handleChange: any,
    indianStates: string[],
    calculatedAge: number | null,
    photos: any[],
    setPhotos: any,
    handleLocationFetch: () => void,
    dynamicFilters: any[] = []
) {
    const inputClass = "mt-1 block w-full h-[48px] rounded-[8px] border border-gray-300 px-4 focus:border-[#EF2F55] focus:outline-none focus:ring-1 focus:ring-[#EF2F55] text-black bg-white transition-shadow hover:shadow-sm disabled:bg-gray-50 disabled:text-gray-400";
    const labelClass = "block text-sm font-medium text-gray-700 mb-1";
    const gridClass = "grid grid-cols-1 md:grid-cols-2 gap-6";

    // Helper to render dynamic fields for the current step
    const renderDynamicFields = (stepIndex: number) => {
        const stepNumber = stepIndex + 1;

        // Fields already hardcoded in the UI to avoid duplication
        const handledOnboardingKeys = [
            'username', 'first_name', 'last_name', 'dob', 'gender', 'height', 'weight',
            'marital_status', 'mother_tongue', 'aadhar_number', 'country', 'state', 'city',
            'father_status', 'mother_status', 'brothers', 'sisters', 'family_status',
            'family_type', 'family_values', 'annual_income', 'highest_education', 'occupation',
            'employed_in', 'personal_income', 'religion', 'community', 'appearance',
            'living_status', 'eating_habits', 'smoking_habits', 'drinking_habits', 'about_me',
            'manglik_status'
        ];

        return dynamicFilters
            .filter(f => f.onboardingStep === stepNumber && !handledOnboardingKeys.includes(f.key))
            .map(f => {
                const value = (formData as any).extra_details?.[f.key] || formData[f.key] || '';
                const name = (formData as any)[f.key] !== undefined ? f.key : `extra_details.${f.key}`;

                return (
                    <div key={f.key} className="flex flex-col gap-1.5">
                        <label className={labelClass}>{f.label}{f.onboardingRequired && '*'}</label>
                        {f.type === 'select' ? (
                            <select
                                name={name}
                                value={value}
                                onChange={handleChange}
                                className={inputClass}
                                required={f.onboardingRequired}
                            >
                                <option value="">Select {f.label}</option>
                                {f.options.map((opt: string) => (
                                    <option key={opt} value={opt}>{opt}</option>
                                ))}
                            </select>
                        ) : f.type === 'number' ? (
                            <input
                                type="number"
                                name={name}
                                value={value}
                                onChange={handleChange}
                                placeholder={f.placeholder || `Enter ${f.label}`}
                                className={inputClass}
                                required={f.onboardingRequired}
                            />
                        ) : f.type === 'textarea' ? (
                            <textarea
                                name={name}
                                value={value}
                                onChange={handleChange}
                                placeholder={f.placeholder || `Enter ${f.label}`}
                                rows={3}
                                className={`${inputClass} h-auto py-3`}
                                required={f.onboardingRequired}
                            />
                        ) : (
                            <input
                                type="text"
                                name={name}
                                value={value}
                                onChange={handleChange}
                                placeholder={f.placeholder || `Enter ${f.label}`}
                                className={inputClass}
                                required={f.onboardingRequired}
                            />
                        )}
                        {f.description && <p className="text-[10px] text-gray-400 mt-0.5 ml-1">{f.description}</p>}
                    </div>
                );
            });
    };

    const content = (() => {
        switch (step) {
            case 0: // Basic
                return (
                    <div className={gridClass}>
                        <div>
                            <label className={labelClass}>Username</label>
                            <input type="text" value={formData.username} disabled className={`${inputClass} bg-gray-100 cursor-not-allowed text-gray-500`} />
                        </div>
                        <div>
                            <label className={labelClass}>First Name*</label>
                            <input type="text" name="first_name" value={formData.first_name} onChange={handleChange} className={inputClass} />
                        </div>
                        <div>
                            <label className={labelClass}>Last Name*</label>
                            <input type="text" name="last_name" value={formData.last_name} onChange={handleChange} className={inputClass} />
                        </div>
                        <div>
                            <label className={labelClass}>Date of Birth*</label>
                            <input type="date" name="dob" value={formData.dob} onChange={handleChange} className={inputClass} />
                            {calculatedAge !== null && <span className="text-xs text-[#EF2F55] mt-1 font-medium">Age: {calculatedAge} Years</span>}
                        </div>
                        <div>
                            <label className={labelClass}>Gender*</label>
                            <select name="gender" value={formData.gender} onChange={handleChange} className={inputClass}>
                                <option value="">Select Gender</option>
                                <option value="Male">Male</option>
                                <option value="Female">Female</option>
                            </select>
                        </div>
                        <div>
                            <label className={labelClass}>Height*</label>
                            <select name="height" value={formData.height} onChange={handleChange} className={inputClass}>
                                <option value="">Select</option>
                                {["4'5\"", "4'6\"", "4'7\"", "4'8\"", "4'9\"", "4'10\"", "4'11\"", "5'0\"", "5'1\"", "5'2\"", "5'3\"", "5'4\"", "5'5\"", "5'6\"", "5'7\"", "5'8\"", "5'10\"", "5'11\"", "6'0\"", "6'1\"", "6'2\""].map(h => (
                                    <option key={h} value={h}>{h}</option>
                                ))}
                                <option value="Other">Select</option>
                            </select>
                        </div>
                        <div>
                            <label className={labelClass}>Marital Status*</label>
                            <select name="marital_status" value={formData.marital_status} onChange={handleChange} className={inputClass}>
                                <option value="">Select Status</option>
                                <option value="Never Married">Never Married</option>
                                <option value="Divorced">Divorced</option>
                                <option value="Widowed">Widowed</option>
                                <option value="Awaiting Divorce">Awaiting Divorce</option>
                            </select>
                        </div>
                        <div>
                            <label className={labelClass}>Mother Tongue*</label>
                            <select name="mother_tongue" value={formData.mother_tongue} onChange={handleChange} className={inputClass}>
                                <option value="">Select Language</option>
                                {["Hindi", "English", "Punjabi", "Bengali", "Marathi", "Tamil", "Telugu", "Gujarati", "Kannada", "Malayalam", "Odia", "Urdu"].map(l => (
                                    <option key={l} value={l}>{l}</option>
                                ))}
                            </select>
                        </div>
                        <div>
                            <label className={labelClass}>Aadhar Number</label>
                            <input type="text" name="aadhar_number" value={formData.aadhar_number} onChange={handleChange} placeholder="xxxxxxxxxxxx" className={inputClass} />
                        </div>
                        {renderDynamicFields(0)}
                    </div>
                );

            case 1: // Location
                return (
                    <div className={gridClass}>
                        <div className="col-span-full flex justify-between items-center mb-2">
                            <p className="text-xs text-gray-500">Provide your current residence details.</p>
                            <button
                                type="button"
                                onClick={handleLocationFetch}
                                className="text-xs flex items-center gap-1 text-[#EF2F55] font-medium hover:underline"
                            >
                                <MapPin className="w-3 h-3" /> Fetch Current Location
                            </button>
                        </div>
                        <div>
                            <label className={labelClass}>Country*</label>
                            <select name="country" value={formData.country} onChange={handleChange} className={inputClass}>
                                <option value="">Select Country</option>
                                <option value="India">India</option>
                                <option value="USA">USA</option>
                                <option value="UK">UK</option>
                                <option value="Canada">Canada</option>
                                <option value="Australia">Australia</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                        <div>
                            <label className={labelClass}>State*</label>
                            {formData.country === 'India' ? (
                                <select name="state" value={formData.state} onChange={handleChange} className={inputClass}>
                                    <option value="">Select State</option>
                                    {indianStates.map(s => <option key={s} value={s}>{s}</option>)}
                                </select>
                            ) : (
                                <input type="text" name="state" value={formData.state} onChange={handleChange} className={inputClass} />
                            )}
                        </div>
                        <div className="md:col-span-2">
                            <label className={labelClass}>City*</label>
                            <input type="text" name="city" value={formData.city} onChange={handleChange} className={inputClass} />
                        </div>
                        {renderDynamicFields(1)}
                    </div>
                );

            case 2: // Family
                return (
                    <div className={gridClass}>
                        <div>
                            <label className={labelClass}>Father's Status*</label>
                            <select name="father_status" value={formData.father_status} onChange={handleChange} className={inputClass}>
                                <option value="">Select</option>
                                <option value="Employed">Employed</option>
                                <option value="Business">Business</option>
                                <option value="Retired">Retired</option>
                                <option value="Not Employed">Not Employed</option>
                                <option value="Passed Away">Passed Away</option>
                            </select>
                        </div>
                        <div>
                            <label className={labelClass}>Mother's Status*</label>
                            <select name="mother_status" value={formData.mother_status} onChange={handleChange} className={inputClass}>
                                <option value="">Select</option>
                                <option value="Homemaker">Homemaker</option>
                                <option value="Employed">Employed</option>
                                <option value="Business">Business</option>
                                <option value="Retired">Retired</option>
                                <option value="Passed Away">Passed Away</option>
                            </select>
                        </div>
                        <div>
                            <label className={labelClass}>Family Status*</label>
                            <select name="family_status" value={formData.family_status} onChange={handleChange} className={inputClass}>
                                <option value="">Select</option>
                                <option value="Middle Class">Middle Class</option>
                                <option value="Upper Middle Class">Upper Middle Class</option>
                                <option value="Rich">Rich</option>
                                <option value="Affluent">Affluent</option>
                            </select>
                        </div>
                        <div>
                            <label className={labelClass}>Family Type*</label>
                            <select name="family_type" value={formData.family_type} onChange={handleChange} className={inputClass}>
                                <option value="">Select</option>
                                <option value="Joint">Joint</option>
                                <option value="Nuclear">Nuclear</option>
                            </select>
                        </div>
                        <div>
                            <label className={labelClass}>Family Values*</label>
                            <select name="family_values" value={formData.family_values} onChange={handleChange} className={inputClass}>
                                <option value="">Select</option>
                                <option value="Traditional">Traditional</option>
                                <option value="Moderate">Moderate</option>
                                <option value="Liberal">Liberal</option>
                            </select>
                        </div>
                        <div>
                            <label className={labelClass}>Family Income</label>
                            <select name="annual_income" value={formData.annual_income} onChange={handleChange} className={inputClass}>
                                <option value="">Select Range</option>
                                <option value="0-2 Lakh">0-2 Lakh</option>
                                <option value="2-5 Lakh">2-5 Lakh</option>
                                <option value="5-10 Lakh">5-10 Lakh</option>
                                <option value="10-20 Lakh">10-20 Lakh</option>
                                <option value="20+ Lakh">20+ Lakh</option>
                            </select>
                        </div>
                        {renderDynamicFields(2)}
                    </div>
                );

            case 3: // Education
                return (
                    <div className={gridClass}>
                        <div>
                            <label className={labelClass}>Highest Education*</label>
                            <select name="highest_education" value={formData.highest_education} onChange={handleChange} className={inputClass}>
                                <option value="">Select</option>
                                <option value="High School">High School</option>
                                <option value="Bachelors">Bachelors</option>
                                <option value="Masters">Masters</option>
                                <option value="Doctorate">Doctorate</option>
                                <option value="Diploma">Diploma</option>
                            </select>
                        </div>
                        <div>
                             <label className={labelClass}>Occupation*</label>
                            {(() => {
                                const OCCUPATIONS = [
                                    "Private Sector", "Government Service", "Business", "Self Employed", "Not Working",
                                    "Software Engineer", "Civil Engineer", "Mechanical Engineer", "Electrical Engineer",
                                    "Doctor", "Surgeon", "Dentist", "Nurse", "Pharmacist",
                                    "Teacher", "Professor", "Researcher", "Scientist",
                                    "Chartered Accountant", "Company Secretary", "Banker", "Financial Analyst",
                                    "Lawyer", "Judge", "Legal Consultant",
                                    "Civil Services", "Government Official", "Defense Officer", "Police Officer",
                                    "Entrepreneur", "Manager", "Marketing Professional", "HR Professional", "Sales Professional", "Consultant",
                                    "Architect", "Interior Designer", "Graphic Designer", "Fashion Designer",
                                    "Artist", "Writer", "Journalist", "Content Creator", "Actor", "Musician", "Photographer",
                                    "Pilot", "Flight Attendant", "Merchant Navy",
                                    "Hotel Management", "Chef", "Event Manager",
                                    "Social Worker", "Farmer", "Businessman", "MNC Job", "Private Job", "Government Job", "NRI", "Sports Professional",
                                    "Student", "Homemaker", "Retired", "Other"
                                ];

                                // Check if current value is "Other" or a custom value not in list
                                const isCustom = formData.occupation && !OCCUPATIONS.includes(formData.occupation) && formData.occupation !== 'Other';
                                const dropdownValue = isCustom ? 'Other' : (formData.occupation || '');

                                // If user selected "Other" explicitly OR has a custom value, show input
                                const showInput = dropdownValue === 'Other';

                                return (
                                    <div className="space-y-2">
                                        <select
                                            name="occupation_select"
                                            value={dropdownValue}
                                            onChange={(e) => {
                                                const val = e.target.value;
                                                if (val === 'Other') {
                                                    if (OCCUPATIONS.includes(formData.occupation)) {
                                                        handleChange({ target: { name: 'occupation', value: '' } } as any);
                                                    }
                                                } else {
                                                    handleChange({ target: { name: 'occupation', value: val } } as any);
                                                }
                                            }}
                                            className={inputClass}
                                        >
                                            <option value="">Select</option>
                                            {OCCUPATIONS.map(occ => (
                                                <option key={occ} value={occ}>{occ}</option>
                                            ))}
                                        </select>

                                        {showInput && (
                                            <input
                                                type="text"
                                                name="occupation"
                                                value={formData.occupation === 'Other' ? '' : formData.occupation}
                                                onChange={handleChange}
                                                placeholder="Enter your occupation"
                                                className={inputClass}
                                                autoFocus
                                            />
                                        )}
                                    </div>
                                );
                            })()}
                        </div>
                        <div>
                            <label className={labelClass}>Employed In*</label>
                            <select name="employed_in" value={formData.employed_in} onChange={handleChange} className={inputClass}>
                                <option value="">Select</option>
                                <option value="Private">Private</option>
                                <option value="Government">Government</option>
                                <option value="Defense">Defense</option>
                                <option value="Business">Business</option>
                                <option value="Self Employed">Self Employed</option>
                            </select>
                        </div>
                        <div>
                             <label className={labelClass}>Detailed Education</label>
                            <input type="text" name="educational_details" value={formData.educational_details} onChange={handleChange} placeholder="e.g. B.Tech CS" className={inputClass} />
                        </div>
                        <div>
                            <label className={labelClass}>Annual Income*</label>
                            <select name="personal_income" value={formData.personal_income} onChange={handleChange} className={inputClass}>
                                <option value="">Select Range</option>
                                <option value="0-2 Lakh">0-2 Lakh</option>
                                <option value="2-5 Lakh">2-5 Lakh</option>
                                <option value="5-10 Lakh">5-10 Lakh</option>
                                <option value="10-15 Lakh">10-15 Lakh</option>
                                <option value="15-20 Lakh">15-20 Lakh</option>
                                <option value="20+ Lakh">20+ Lakh</option>
                            </select>
                        </div>
                        {renderDynamicFields(3)}
                    </div>
                );

            case 4: // Religious
                return (
                    <div className={gridClass}>
                        <div>
                            <label className={labelClass}>Religion*</label>
                            <select name="religion" value={formData.religion} onChange={handleChange} className={inputClass}>
                                <option value="">Select</option>
                                <option value="Hindu">Hindu</option>
                                <option value="Muslim">Muslim</option>
                                <option value="Christian">Christian</option>
                                <option value="Sikh">Sikh</option>
                                <option value="Jain">Jain</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                        <div>
                             <label className={labelClass}>Community/Caste*</label>
                            <input type="text" name="community" value={formData.community} onChange={handleChange} className={inputClass} />
                        </div>
                        <div>
                            <label className={labelClass}>Manglik Status</label>
                            <select name="manglik_status" value={formData.manglik_status} onChange={handleChange} className={inputClass}>
                                <option value="">Select</option>
                                <option value="Manglik">Manglik</option>
                                <option value="Non-Manglik">Non-Manglik</option>
                                <option value="Anshik Manglik">Anshik Manglik</option>
                                <option value="Don't Know">Don't Know</option>
                            </select>
                        </div>
                        <div>
                             <label className={labelClass}>Place of Birth</label>
                            <input type="text" name="place_of_birth" value={formData.place_of_birth} onChange={handleChange} className={inputClass} />
                        </div>
                        {renderDynamicFields(4)}
                    </div>
                );

            case 5: // Lifestyle
                return (
                    <div className={gridClass}>
                        <div>
                            <label className={labelClass}>Appearance*</label>
                            <select name="appearance" value={formData.appearance} onChange={handleChange} className={inputClass}>
                                <option value="">Select</option>
                                <option value="Fair">Fair</option>
                                <option value="Wheatish">Wheatish</option>
                                <option value="Dark">Dark</option>
                            </select>
                        </div>
                        <div>
                            <label className={labelClass}>Living Status*</label>
                            <select name="living_status" value={formData.living_status} onChange={handleChange} className={inputClass}>
                                <option value="">Select</option>
                                <option value="Own House">Own House</option>
                                <option value="Rented">Rented</option>
                            </select>
                        </div>
                        <div>
                            <label className={labelClass}>Eating Habits*</label>
                            <select name="eating_habits" value={formData.eating_habits} onChange={handleChange} className={inputClass}>
                                <option value="">Select</option>
                                <option value="Vegetarian">Vegetarian</option>
                                <option value="Non-Vegetarian">Non-Vegetarian</option>
                                <option value="Eggiterian">Eggiterian</option>
                            </select>
                        </div>
                        <div>
                            <label className={labelClass}>Smoking</label>
                            <select name="smoking_habits" value={formData.smoking_habits} onChange={handleChange} className={inputClass}>
                                <option value="">Select</option>
                                <option value="No">No</option>
                                <option value="Yes">Yes</option>
                                <option value="Occasionally">Occasionally</option>
                            </select>
                        </div>
                        <div>
                            <label className={labelClass}>Drinking</label>
                            <select name="drinking_habits" value={formData.drinking_habits} onChange={handleChange} className={inputClass}>
                                <option value="">Select</option>
                                <option value="No">No</option>
                                <option value="Yes">Yes</option>
                                <option value="Occasionally">Occasionally</option>
                            </select>
                        </div>
                        {renderDynamicFields(5)}
                    </div>
                );

            case 6: // Contact
                return (
                    <div className={gridClass}>
                        <div>
                             <label className={labelClass}>Email</label>
                            <input type="email" value={formData.email} disabled className={`${inputClass} bg-gray-100 cursor-not-allowed text-gray-500`} />
                        </div>
                        <div>
                             <label className={labelClass}>Phone Number</label>
                             <input type="text" name="phone" value={formData.phone} disabled className={`${inputClass} bg-gray-100 cursor-not-allowed text-gray-500`} />
                         </div>
                         <div>
                             <label className={labelClass}>Alternate Mobile</label>
                             <input type="text" name="alternate_mobile" value={formData.alternate_mobile} onChange={handleChange} placeholder="Optional" className={inputClass} />
                        </div>
                        {renderDynamicFields(6)}
                    </div>
                );

            case 7: // About
                return (
                    <div className="space-y-4">
                        <div>
                             <label className={labelClass}>About Me* (Tell us about your personality, interests, and what you're looking for)</label>
                            <textarea
                                name="about_me"
                                value={formData.about_me}
                                onChange={handleChange}
                                rows={8}
                                className={`${inputClass} h-auto py-4 resize-none`}
                                 placeholder="I'm a software engineer who loves traveling..."
                            />
                            <div className="mt-2 flex justify-between items-center text-xs">
                                <span className={formData.about_me.length >= 50 ? "text-green-500 font-bold" : "text-[#EF2F55] font-bold"}>
                                     {formData.about_me.length} / 50 characters min
                                </span>
                            </div>
                        </div>
                        {renderDynamicFields(7)}
                    </div>
                );

            case 8: // Property
                const landAreaRaw = formData.land_area || '';
                let landVal = '';
                let landUnit = 'Acres';

                // Parse existing value
                if (landAreaRaw && typeof landAreaRaw === 'string') {
                    if (landAreaRaw.includes('No Land')) {
                        landVal = '';
                        landUnit = 'No Land';
                    } else {
                        const parts = landAreaRaw.split(' ');
                        landVal = parts[0];
                        landUnit = parts.slice(1).join(' ') || 'Acres';
                    }
                }

                // Helper to trigger update for Land Area
                const updateLandArea = (val: string, unit: string) => {
                    if (unit === 'No Land') {
                        handleChange({ target: { name: 'land_area', value: '0 No Land' } } as any);
                    } else {
                        handleChange({ target: { name: 'land_area', value: `${val} ${unit}` } } as any);
                    }
                };

                // Helper for Property Types (Multi-select)
                const togglePropertyType = (type: string) => {
                    const current = formData.property_types || [];
                    const updated = current.includes(type)
                        ? current.filter((t: string) => t !== type)
                        : [...current, type];
                    setFormData((prev: any) => ({ ...prev, property_types: updated }));
                };

                const PROPERTY_OPTIONS = ["Commercial", "Farming", "Plots", "Factory", "Shops", "Houses", "Rental"];

                return (
                    <div className="space-y-8">
                        <div className={gridClass}>
                            <div>
                                <label className={labelClass}>Land Area</label>
                                <div className="flex gap-2">
                                    <input
                                        type="number"
                                        name="land_area_val"
                                        value={landUnit === 'No Land' ? '' : landVal}
                                        onChange={(e) => updateLandArea(e.target.value, landUnit)}
                                        min="0"
                                        disabled={landUnit === 'No Land'}
                                        placeholder={landUnit === 'No Land' ? "Not Applicable" : "Enter Land Area"}
                                        className={`${inputClass} disabled:bg-gray-100 disabled:text-gray-400`}
                                    />
                                    <select
                                        value={landUnit}
                                        onChange={(e) => updateLandArea(landVal, e.target.value)}
                                        className={`${inputClass} !w-36`}
                                    >
                                        <option value="Acres">Acres</option>
                                        <option value="Bigha">Bigha</option>
                                        <option value="Ghaz">Ghaz</option>
                                        <option value="Sq. Ft.">Sq. Ft.</option>
                                        <option value="No Land">No Land</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        {/* Property Types Section */}
                        <div>
                            <label className="block text-sm font-bold text-gray-900 mb-4 tracking-wide uppercase">
                                Property Types
                            </label>
                            <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                                {PROPERTY_OPTIONS.map((type) => {
                                    const isSelected = (formData.property_types || []).includes(type);
                                    return (
                                        <div
                                            key={type}
                                            onClick={() => togglePropertyType(type)}
                                            className={`
                                            cursor-pointer rounded-xl px-4 py-3 border-2 transition-all duration-200 flex items-center gap-3
                                            ${isSelected
                                                    ? 'border-[#EF2F55] bg-pink-50 text-[#EF2F55]'
                                                    : 'border-gray-100 bg-white text-gray-600 hover:border-pink-200'
                                                }
                                        `}
                                        >
                                            <div className={`
                                            w-5 h-5 rounded-md border flex items-center justify-center transition-colors
                                            ${isSelected ? 'bg-[#EF2F55] border-[#EF2F55]' : 'border-gray-300 bg-white'}
                                        `}>
                                                {isSelected && <Check className="w-3 h-3 text-white" />}
                                            </div>
                                            <span className="font-medium text-sm">{type}</span>
                                        </div>
                                    );
                                })}
                            </div>
                        </div>
                        {renderDynamicFields(8)}
                    </div>
                );

            case 9: // Photos
                return (
                    <div className="h-full">
                        <div className="bg-pink-50 border border-pink-100 p-4 rounded-2xl flex gap-3">
                            <div className="p-2 bg-white rounded-xl shadow-sm h-fit">
                                <Camera className="w-5 h-5 text-[#EF2F55]" />
                            </div>
                            <div>
                                <h4 className="text-sm font-black text-gray-900 uppercase tracking-widest mb-1">Important Note</h4>
                                <p className="text-xs text-gray-600 leading-relaxed font-medium">
                                    Quality photos are the most important part of your profile. Profiles with photos get 10x more responses.
                                </p>
                            </div>
                        </div>
                        <PhotoUploadGrid
                            photos={photos}
                            setPhotos={setPhotos}
                            updateProfilePhotoLocal={(url) => {
                                setFormData((prev: any) => ({ ...prev, profilePhoto: url }));
                            }}
                            autoCropFirst={true}
                            maxPhotos={6}
                        />

                        {formData.profilePhoto && (
                            <div className="mt-8 p-6 bg-gray-50 rounded-[24px] border border-gray-100 flex flex-col items-center animate-in fade-in zoom-in duration-500">
                                <h4 className="text-xs font-black text-gray-400 uppercase tracking-[0.2em] mb-4">Final Profile Preview</h4>
                                <div className="relative w-32 h-32 rounded-full overflow-hidden ring-4 ring-white shadow-xl">
                                    <img
                                        src={formData.profilePhoto}
                                        alt="Profile"
                                        className="w-full h-full object-cover"
                                    />
                                    <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent" />
                                </div>
                                <p className="mt-4 text-[10px] font-bold text-gray-500 uppercase tracking-widest">Looking Great!</p>
                            </div>
                        )}
                    </div>
                );

            default:
                return <div>Unknown Step</div>;
        }
    })();

    return content;
}
