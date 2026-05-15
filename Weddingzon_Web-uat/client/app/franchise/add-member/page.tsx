'use client';

import { useState, useRef, useEffect, Suspense } from 'react';
import { useRouter } from 'next/navigation';
import api from '../../services/api'; // Adjust path
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
    ChevronLeft,
    ChevronRight,
    Check,
    AlertCircle,
    RefreshCw,
    ChevronDown
} from 'lucide-react';
import PhotoUploadGrid from '@/app/components/PhotoUploadGrid';
import { useToast } from '@/app/contexts/ToastContext';
import { motion, AnimatePresence } from 'framer-motion';

const indianStates = [
    "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh", "Goa", "Gujarat",
    "Haryana", "Himachal Pradesh", "Jharkhand", "Karnataka", "Kerala", "Madhya Pradesh",
    "Maharashtra", "Manipur", "Meghalaya", "Mizoram", "Nagaland", "Odisha", "Punjab",
    "Rajasthan", "Sikkim", "Tamil Nadu", "Telangana", "Tripura", "Uttar Pradesh",
    "Uttarakhand", "West Bengal", "Andaman and Nicobar Islands", "Chandigarh",
    "Dadra and Nagar Haveli and Daman and Diu", "Delhi", "Jammu and Kashmir", "Ladakh",
    "Lakshadweep", "Puducherry"
];

const OCCUPATIONS = [
    "Software Engineer", "Doctor", "Teacher", "Engineer", "Accountant",
    "Business Analyst", "Marketing Professional", "Civil Servant",
    "Police Officer", "Armed Forces", "Lawyer", "Architect",
    "Chartered Accountant", "Banking Professional", "Sales Professional",
    "Customer Support", "Data Scientist", "Artist", "Writer", "Designer",
    "Nurse", "Pharmacist", "Dentist", "Physiotherapist", "Professor",
    "Scientist", "Real Estate Broker", "Politician", "Priest",
    "Pilot", "Flight Attendant", "Merchant Navy",
    "Hotel Management", "Chef", "Event Manager",
    "Social Worker", "Farmer", "Sports Professional",
    "Student", "Homemaker", "Retired", "Other"
];

const STEPS = [
    { id: 'basic', title: 'Basic Details', icon: User },
    { id: 'location', title: 'Location Details', icon: MapPin },
    { id: 'family', title: 'Family Details', icon: Users },
    { id: 'education', title: 'Education & Career', icon: GraduationCap },
    { id: 'religious', title: 'Religious Info', icon: Heart },
    { id: 'lifestyle', title: 'Lifestyle', icon: Info },
    { id: 'contact', title: 'Contact Details', icon: Phone },
    { id: 'about', title: 'About Me', icon: User },
    { id: 'property', title: 'Property Details', icon: Briefcase },
    { id: 'photos', title: 'Photos', icon: Camera },
];

export default function AddMemberPage() {
    return (
        <Suspense fallback={
            <div className="min-h-screen flex items-center justify-center bg-white text-[#EF2F55]">
                <div className="animate-pulse font-black text-xl tracking-tight">LOADING...</div>
            </div>
        }>
            <AddMemberContent />
        </Suspense>
    );
}

function AddMemberContent() {
    const router = useRouter();
    const { addToast } = useToast();

    // UI State
    const [currentStep, setCurrentStep] = useState(0);
    const [direction, setDirection] = useState(0); // -1 for prev, 1 for next
    const [loading, setLoading] = useState(false);
    const [isLocating, setIsLocating] = useState(false);

    // Member State
    const [memberId, setMemberId] = useState<string | null>(null);
    const [memberUsername, setMemberUsername] = useState<string | null>(null);
    const [createdCredentials, setCreatedCredentials] = useState<{ username: string, password: string } | null>(null);

    // Form Data State
    const [formData, setFormData] = useState({
        username: '',
        first_name: '',
        last_name: '',
        dob: '',
        gender: '',
        created_for: 'Marriage Bureau',
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
        father_name: '',
        mother_name: '',
        father_occupation: '',
        mother_occupation: '',
        brothers: 0,
        sisters: 0,
        live_with_family: 'Yes',
        family_status: '',
        family_type: '',
        family_values: '',
        annual_income: '',
        family_location: '',
        highest_education: '',
        college_name: '',
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
        complexion: '',
        living_status: '',
        physical_status: '',
        eating_habits: '',
        smoking_habits: '',
        drinking_habits: '',
        hobbies: [],
        property_types: [],
        land_types: [],
        land_area: '',
        land_area_range: '',
        house_types: [],
        business_types: [],
        email: '',
        phone: '',
        alternate_mobile: '',
        suitable_time_to_call: '',
        about_me: '',
    });

    const [calculatedAge, setCalculatedAge] = useState<number | null>(null);
    const [aadharError, setAadharError] = useState<string>('');
    const [phoneError, setPhoneError] = useState<string>('');
    const [photos, setPhotos] = useState<any[]>([]);

    const calculateAge = (dobValue: string) => {
        const today = new Date();
        const birthDate = new Date(dobValue);
        let age = today.getFullYear() - birthDate.getFullYear();
        const m = today.getMonth() - birthDate.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) age--;
        setCalculatedAge(age);
        return age;
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

        if (name === 'phone') {
            const numericValue = value.replace(/\D/g, '');
            if (numericValue.length > 10) return;
            setFormData(prev => ({ ...prev, [name]: numericValue }));
            if (numericValue.length > 0 && numericValue.length !== 10) setPhoneError('Must be 10 digits');
            else setPhoneError('');
            return;
        }

        if (name === 'country') {
            setFormData(prev => ({ ...prev, [name]: value, state: '', city: '' }));
        } else {
            setFormData(prev => ({ ...prev, [name]: value }));
        }

        if (name === 'dob') {
            const age = calculateAge(value);
            if (age < 21) addToast('Age must be at least 21 years.', 'error');
            else if (age > 150) addToast('Age cannot exceed 150 years.', 'error');
        }
    };

    const validateStep = (stepIndex: number): boolean => {
        const stepId = STEPS[stepIndex].id;
        switch (stepId) {
            case 'basic':
                if (!formData.first_name || !formData.last_name || !formData.dob || !formData.gender || !formData.height || !formData.marital_status || !formData.mother_tongue || !formData.created_for || !formData.phone) {
                    addToast('Please fill all mandatory fields.', 'error');
                    return false;
                }
                if (formData.phone && formData.phone.length !== 10) {
                    addToast('Phone number must be exactly 10 digits.', 'error');
                    return false;
                }
                if (calculatedAge !== null && (calculatedAge < 21 || calculatedAge > 150)) return false;
                if (formData.aadhar_number && formData.aadhar_number.length !== 12) return false;
                return true;
            case 'location':
                if (!formData.country || !formData.state || !formData.city) {
                    addToast('Please fill all mandatory fields.', 'error');
                    return false;
                }
                return true;
            case 'family':
                if (!formData.father_status || !formData.mother_status || !formData.family_status || !formData.family_type || !formData.family_values) {
                    addToast('Please fill all mandatory fields.', 'error');
                    return false;
                }
                return true;
            case 'education':
                if (!formData.highest_education || !formData.occupation || !formData.employed_in || !formData.personal_income) {
                    addToast('Please fill all mandatory fields.', 'error');
                    return false;
                }
                return true;
            case 'religious':
                if (!formData.religion || !formData.community) {
                    addToast('Please fill all mandatory fields.', 'error');
                    return false;
                }
                return true;
            case 'lifestyle':
                if (!formData.complexion || !formData.living_status || !formData.eating_habits) {
                    addToast('Please fill all mandatory fields.', 'error');
                    return false;
                }
                return true;
            case 'contact':
                if (!formData.phone) {
                    addToast('Phone number is required.', 'error');
                    return false;
                }
                return true;
            case 'about':
                if (!formData.about_me || formData.about_me.length < 50) {
                    addToast(`About Me must be at least 50 characters (current: ${formData.about_me?.length || 0})`, 'error');
                    return false;
                }
                return true;
            case 'photos':
                const validPhotos = photos.filter(p => !p.isTemp && !p.error);
                if (validPhotos.length === 0) {
                    addToast('Please upload at least one photo.', 'error');
                    return false;
                }
                return true;
            default:
                return true;
        }
    };

    const nextStep = async () => {
        if (!validateStep(currentStep)) return;

        setLoading(true);
        try {
            if (currentStep === 0 && !memberId) {
                // First Step: Create Profile
                const res = await api.post('/franchise/create-profile', formData);
                if (res.data.success) {
                    setMemberId(res.data.profile._id);
                    setMemberUsername(res.data.profile.username);
                    setFormData(prev => ({ ...prev, username: res.data.profile.username }));
                    if (res.data.credentials) setCreatedCredentials(res.data.credentials);
                    addToast('Profile Created!', 'success');
                }
            } else if (memberId) {
                // Subsequent Steps: Update
                await api.patch(`/franchise/profiles/${memberId}`, formData);
            }

            if (currentStep < STEPS.length - 1) {
                setDirection(1);
                setCurrentStep(prev => prev + 1);
                window.scrollTo({ top: 0, behavior: 'smooth' });
            } else {
                handleFinalSubmit();
            }
        } catch (error: any) {
            console.error(error);
            addToast(error.response?.data?.message || 'Failed to save progress.', 'error');
        } finally {
            setLoading(false);
        }
    };

    const prevStep = () => {
        if (currentStep > 0) {
            setDirection(-1);
            setCurrentStep(prev => prev - 1);
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }
    };

    const handleFinalSubmit = async () => {
        if (!memberId) return;
        setLoading(true);
        try {
            await api.patch(`/franchise/profiles/${memberId}`, { ...formData, is_profile_complete: true });
            addToast('Member Profile Completed!', 'success');
            router.push('/franchise');
        } catch (error) {
            addToast('Failed to complete profile.', 'error');
        } finally {
            setLoading(false);
        }
    };

    const handleUseCurrentLocation = () => {
        if (!navigator.geolocation) {
            addToast('Geolocation not supported', 'error');
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
                    addToast('Location updated', 'success');
                }
            } catch (error) {
                addToast('Failed to fetch location', 'error');
            } finally {
                setIsLocating(false);
            }
        }, () => {
            addToast('Location permission denied', 'error');
            setIsLocating(false);
        });
    };

    const updateProfilePhotoLocal = (url: string) => { };

    // Variants for Framer Motion
    const variants = {
        enter: (direction: number) => ({
            x: direction > 0 ? '50%' : '-50%',
            opacity: 0,
        }),
        center: {
            x: 0,
            opacity: 1,
        },
        exit: (direction: number) => ({
            x: direction < 0 ? '50%' : '-50%',
            opacity: 0,
        }),
    };

    const CurrentStepIcon = STEPS[currentStep].icon;

    return (
        <div className="min-h-screen bg-white py-12 px-4 sm:px-6 lg:px-8 font-inter flex flex-col items-center">

            {/* Header */}
            <div className="w-full max-w-4xl mb-12 flex items-center justify-between">
                <button
                    onClick={() => router.push('/franchise')}
                    className="flex items-center text-gray-400 hover:text-gray-900 transition-colors group"
                >
                    <ChevronLeft className="w-5 h-5 mr-1 group-hover:-translate-x-1 transition-transform" />
                    <span className="text-xs font-black uppercase tracking-widest">Dashboard</span>
                </button>
                <div className="text-right">
                    <h1 className="text-4xl font-black text-gray-900 tracking-tight">
                        ADD <span className="text-[#EF2F55]">MEMBER</span>
                    </h1>
                </div>
            </div>

            {/* Stepper (Desktop) */}
            <div className="w-full max-w-6xl mb-16 hidden md:flex items-center justify-between px-8 relative">
                <div className="absolute top-[20px] left-[8%] right-[8%] h-[2px] bg-gray-100 -z-0" />
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
                            onClick={() => memberId && setCurrentStep(idx)}
                        >
                            <motion.div
                                animate={{
                                    backgroundColor: isActive || isCompleted ? '#EF2F55' : '#FFFFFF',
                                    borderColor: isActive || isCompleted ? '#EF2F55' : '#F3F4F6',
                                    scale: isActive ? 1.2 : 1,
                                    boxShadow: isActive ? '0 0 20px rgba(239,47,85,0.4)' : 'none',
                                }}
                                className="w-10 h-10 rounded-full border-2 flex items-center justify-center relative bg-white"
                            >
                                {isCompleted ? (
                                    <Check className="w-5 h-5 text-white" />
                                ) : (
                                    <Icon className={`w-5 h-5 ${isActive ? 'text-white' : 'text-gray-300 group-hover:text-[#EF2F55] transition-colors'}`} />
                                )}
                            </motion.div>
                            <span className={`mt-3 text-[10px] uppercase tracking-tighter font-black text-center max-w-[70px] leading-tight ${isActive ? 'text-[#EF2F55]' : isCompleted ? 'text-gray-900' : 'text-gray-400'}`}>
                                {step.title}
                            </span>
                        </div>
                    );
                })}
            </div>

            {/* Main Card */}
            <div className="w-full max-w-4xl bg-white rounded-[32px] border border-gray-100 shadow-[0_20px_50px_rgba(0,0,0,0.05)] overflow-hidden flex flex-col relative scale-[1.01] min-h-[600px]">

                {/* Card Header */}
                <div className="p-8 border-b border-gray-50 flex items-center gap-4 bg-white z-10">
                    <div className="p-3 bg-rose-50 rounded-2xl">
                        <CurrentStepIcon className="w-8 h-8 text-[#EF2F55]" />
                    </div>
                    <div>
                        <div className="flex items-center gap-2">
                            <h2 className="text-2xl font-black text-gray-900 tracking-tight uppercase">{STEPS[currentStep].title}</h2>
                            {memberUsername && (
                                <span className="text-[10px] font-black bg-gray-100 text-gray-500 px-2 py-0.5 rounded-full">ID: {memberUsername}</span>
                            )}
                        </div>
                        <p className="text-[10px] text-gray-400 font-black uppercase tracking-widest">Step {currentStep + 1} of {STEPS.length}</p>
                    </div>
                </div>

                {/* Form Area */}
                <div className="flex-1 p-8 md:p-12 overflow-y-auto overflow-x-hidden relative bg-white">
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
                            {renderStepContent(currentStep, formData, setFormData, handleChange, indianStates, calculatedAge, photos, setPhotos, handleUseCurrentLocation, memberId, updateProfilePhotoLocal, aadharError, phoneError)}
                        </motion.div>
                    </AnimatePresence>
                </div>

                {/* Footer */}
                <div className="p-8 bg-white border-t border-gray-50 flex justify-between items-center z-20">
                    <button
                        onClick={prevStep}
                        disabled={currentStep === 0 || loading}
                        className={`flex items-center px-8 py-4 rounded-2xl font-black uppercase tracking-widest text-[10px] transition-all ${currentStep === 0 || loading ? 'text-gray-200 cursor-not-allowed' : 'text-gray-400 hover:text-gray-900 hover:bg-gray-50'}`}
                    >
                        <ChevronLeft className="w-4 h-4 mr-2" />
                        Back
                    </button>

                    <button
                        onClick={nextStep}
                        disabled={loading}
                        className="flex items-center px-12 py-4 rounded-2xl bg-[#EF2F55] text-white font-black uppercase tracking-widest text-[10px] shadow-xl shadow-rose-200 hover:bg-[#d42a4a] hover:shadow-rose-300 transition-all transform hover:-translate-y-1 active:translate-y-0 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
                    >
                        {loading ? (
                            <RefreshCw className="w-4 h-4 animate-spin" />
                        ) : (
                            <>
                                {currentStep === STEPS.length - 1 ? 'Finish Profile' : (currentStep === 0 && !memberId ? 'Create & Next' : 'Save & Next')}
                                {currentStep !== STEPS.length - 1 && <ChevronRight className="w-4 h-4 ml-2" />}
                            </>
                        )}
                    </button>
                </div>
            </div>

            {/* Credentials Modal */}
            <AnimatePresence>
                {createdCredentials && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        className="fixed inset-0 z-[100] flex items-center justify-center bg-gray-900/60 backdrop-blur-sm px-4"
                    >
                        <motion.div
                            initial={{ scale: 0.9, y: 20 }}
                            animate={{ scale: 1, y: 0 }}
                            exit={{ scale: 0.9, y: 20 }}
                            className="bg-white rounded-[32px] shadow-2xl max-w-md w-full p-8 text-center relative overflow-hidden border border-gray-100"
                        >
                            <div className="absolute top-0 left-0 w-full h-2 bg-[#EF2F55]" />
                            <div className="mx-auto flex items-center justify-center h-20 w-20 rounded-3xl bg-rose-50 mb-6 rotate-3">
                                <Check className="w-10 h-10 text-[#EF2F55]" />
                            </div>

                            <h3 className="text-2xl font-black text-gray-900 tracking-tight mb-2">ACCOUNT CREATED!</h3>
                            <p className="text-sm text-gray-400 font-medium mb-8 uppercase tracking-wider">Please share these credentials with the member.</p>

                            <div className="space-y-4 mb-8">
                                <div className="bg-gray-50 p-4 rounded-2xl text-left border border-gray-100 hover:border-rose-200 transition-colors">
                                    <span className="text-[10px] text-gray-400 font-extrabold uppercase tracking-widest block mb-1">Username</span>
                                    <span className="text-lg font-mono font-black text-gray-900 select-all tracking-tight">{createdCredentials.username}</span>
                                </div>
                                <div className="bg-gray-50 p-4 rounded-2xl text-left border border-gray-100 hover:border-rose-200 transition-colors">
                                    <span className="text-[10px] text-gray-400 font-extrabold uppercase tracking-widest block mb-1">Password</span>
                                    <span className="text-lg font-mono font-black text-gray-900 select-all tracking-tight">{createdCredentials.password}</span>
                                </div>
                            </div>

                            <button
                                onClick={() => setCreatedCredentials(null)}
                                className="w-full py-4 rounded-2xl bg-gray-900 text-white font-black uppercase tracking-widest text-[10px] hover:bg-black transition-all shadow-lg hover:shadow-gray-200"
                            >
                                Done (Credentials Copied)
                            </button>
                        </motion.div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
}

const SelectField = ({ label, name, value, onChange, options, className, children, ...props }: any) => {
    const labelClass = "block text-[10px] font-black text-gray-400 uppercase tracking-widest mb-1.5 ml-1";
    const inputClass = "mt-1 block w-full h-[56px] rounded-[16px] border border-gray-200 px-5 pr-12 focus:border-[#EF2F55] focus:outline-none focus:ring-1 focus:ring-[#EF2F55] text-gray-900 bg-white transition-all hover:bg-gray-50 hover:border-gray-300 font-medium appearance-none";

    return (
        <div className="w-full">
            {label && <label className={labelClass}>{label}</label>}
            <div className="relative group">
                <select
                    name={name}
                    value={value}
                    onChange={onChange}
                    className={`${inputClass} ${className || ''}`}
                    {...props}
                >
                    {children ? children : (
                        <>
                            <option value="">Select</option>
                            {options?.map((opt: string) => (
                                <option key={opt} value={opt}>{opt}</option>
                            ))}
                        </>
                    )}
                </select>
                <div className="absolute right-5 top-1/2 -translate-y-1/2 pointer-events-none text-gray-400 group-hover:text-gray-600 transition-colors">
                    <ChevronDown className="w-4 h-4" />
                </div>
            </div>
        </div>
    );
};

function renderStepContent(
    step: number,
    formData: any,
    setFormData: any,
    handleChange: (e: any) => void,
    indianStates: string[],
    calculatedAge: number | null,
    photos: any[],
    setPhotos: any,
    handleLocationFetch: () => void,
    memberId: string | null,
    updateProfilePhotoLocal: (url: string) => void,
    aadharError: string,
    phoneError: string
) {
    const inputClass = "mt-1 block w-full h-[56px] rounded-[16px] border border-gray-200 px-5 focus:border-[#EF2F55] focus:outline-none focus:ring-1 focus:ring-[#EF2F55] text-gray-900 bg-white transition-all hover:bg-gray-50 hover:border-gray-300 font-medium";
    const labelClass = "block text-[10px] font-black text-gray-400 uppercase tracking-widest mb-1.5 ml-1";
    const gridClass = "grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6";

    switch (step) {
        case 0: // Basic
            return (
                <div className={gridClass}>
                    <div className="col-span-full">
                        <SelectField
                            label="Profile Created For*"
                            name="created_for"
                            value={formData.created_for}
                            onChange={handleChange}
                            options={["Self", "Parent", "Sibling", "Relative", "Friend", "Marriage Bureau", "Client"]}
                            disabled={true}
                        />
                    </div>
                    <div>
                        <label className={labelClass}>First Name*</label>
                        <input type="text" name="first_name" value={formData.first_name} onChange={handleChange} className={inputClass} />
                    </div>
                    <div>
                        <label className={labelClass}>Last Name*</label>
                        <input type="text" name="last_name" value={formData.last_name} onChange={handleChange} className={inputClass} />
                    </div>
                    <div className="relative">
                        <label className={labelClass}>Phone*</label>
                        <input type="tel" name="phone" value={formData.phone} onChange={handleChange} placeholder="e.g. 9876543210" className={`${inputClass} ${phoneError ? 'border-amber-400' : ''}`} />
                        {phoneError && <p className="text-[10px] text-amber-600 font-bold mt-1 ml-1 flex items-center gap-1"><AlertCircle className="w-3 h-3" /> {phoneError}</p>}
                    </div>
                    <div>
                        <label className={labelClass}>Email (Optional)</label>
                        <input type="email" name="email" value={formData.email} onChange={handleChange} className={inputClass} />
                    </div>
                    <div className="relative">
                        <label className={labelClass}>Date of Birth*</label>
                        <input type="date" name="dob" value={formData.dob} onChange={handleChange} className={inputClass} />
                        {calculatedAge !== null && (
                            <div className="absolute top-0 right-2">
                                <span className="text-[10px] font-black bg-rose-50 text-[#EF2F55] px-2 py-1 rounded-lg">AGE: {calculatedAge}</span>
                            </div>
                        )}
                    </div>
                    <div>
                        <SelectField
                            label="Gender*"
                            name="gender"
                            value={formData.gender}
                            onChange={handleChange}
                            options={["Male", "Female", "Other"]}
                        />
                    </div>
                    <div>
                        <SelectField
                            label="Height*"
                            name="height"
                            value={formData.height}
                            onChange={handleChange}
                            options={["4'0\"", "4'1\"", "4'2\"", "4'3\"", "4'4\"", "4'5\"", "4'6\"", "4'7\"", "4'8\"", "4'9\"", "4'10\"", "4'11\"", "5'0\"", "5'1\"", "5'2\"", "5'3\"", "5'4\"", "5'5\"", "5'6\"", "5'7\"", "5'8\"", "5'9\"", "5'10\"", "5'11\"", "6'0\"", "6'1\"", "6'2\"", "6'3\"", "6'4\"", "6'5\"", "6'6\"", "6'7\"", "6'8\"", "6'9\"", "6'10\"", "6'11\"", "7'0\""]}
                        />
                    </div>
                    <div>
                        <SelectField
                            label="Marital Status*"
                            name="marital_status"
                            value={formData.marital_status}
                            onChange={handleChange}
                            options={["Never Married", "Divorced", "Widowed", "Awaiting Divorce"]}
                        />
                    </div>
                    <div>
                        <SelectField
                            label="Mother Tongue*"
                            name="mother_tongue"
                            value={formData.mother_tongue}
                            onChange={handleChange}
                            options={["Hindi", "English", "Punjabi", "Bengali", "Marathi", "Tamil", "Telugu", "Gujarati", "Kannada", "Malayalam", "Odia", "Urdu"]}
                        />
                    </div>
                    <div>
                        <SelectField
                            label="Weight (Optional)"
                            name="weight"
                            value={formData.weight}
                            onChange={handleChange}
                        >
                            <option value="">Select</option>
                            {Array.from({ length: 111 }, (_, i) => i + 40).map(w => (
                                <option key={w} value={w}>{w} kg</option>
                            ))}
                        </SelectField>
                    </div>
                    <div>
                        <SelectField
                            label="Disability"
                            name="disability"
                            value={formData.disability}
                            onChange={handleChange}
                        >
                            <option value="None">None</option>
                            <option value="Physical">Physical</option>
                            <option value="Mental">Mental</option>
                            <option value="Other">Other</option>
                        </SelectField>
                    </div>
                    {formData.disability !== 'None' && (
                        <>
                            <div>
                                <label className={labelClass}>Disability Type</label>
                                <input type="text" name="disability_type" value={formData.disability_type} onChange={handleChange} className={inputClass} />
                            </div>
                            <div className="col-span-full">
                                <label className={labelClass}>Disability Description</label>
                                <textarea name="disability_description" value={formData.disability_description} onChange={handleChange} className={`${inputClass} h-24 py-3`} />
                            </div>
                        </>
                    )}
                    <div className="relative">
                        <label className={labelClass}>Aadhar Number (Optional)</label>
                        <input type="text" name="aadhar_number" value={formData.aadhar_number} onChange={handleChange} placeholder="12 digit number" className={`${inputClass} ${aadharError ? 'border-amber-400' : ''}`} />
                        {aadharError && <p className="text-[10px] text-amber-600 font-bold mt-1 ml-1 flex items-center gap-1"><AlertCircle className="w-3 h-3" /> {aadharError}</p>}
                    </div>
                    <div>
                        <SelectField
                            label="Blood Group (Optional)"
                            name="blood_group"
                            value={formData.blood_group}
                            onChange={handleChange}
                            options={["A+", "O+", "B+", "AB+", "A-", "O-", "B-", "AB-"]}
                        />
                    </div>
                </div>
            );
        case 1: // Location
            return (
                <div className={gridClass}>
                    <div className="col-span-full flex justify-between items-center mb-2 px-1">
                        <p className="text-[10px] text-gray-400 font-black uppercase tracking-widest">Current Residence</p>
                        <button type="button" onClick={handleLocationFetch} className="text-[10px] flex items-center gap-1 text-[#EF2F55] font-black uppercase tracking-widest hover:bg-rose-50 px-3 py-1.5 rounded-xl transition-all border border-rose-100 shadow-sm">
                            <MapPin className="w-3 h-3" /> Fetch Location
                        </button>
                    </div>
                    <div>
                        <SelectField
                            label="Country*"
                            name="country"
                            value={formData.country}
                            onChange={handleChange}
                            options={["India", "USA", "UK", "Canada", "Australia", "UAE", "Other"]}
                        />
                    </div>
                    <div>
                        <label className={labelClass}>State*</label>
                        {formData.country === 'India' ? (
                            <SelectField
                                label="State*"
                                name="state"
                                value={formData.state}
                                onChange={handleChange}
                                options={indianStates}
                            />
                        ) : (
                            <input type="text" name="state" value={formData.state} onChange={handleChange} className={inputClass} />
                        )}
                    </div>
                    <div className="md:col-span-2">
                        <label className={labelClass}>City*</label>
                        <input type="text" name="city" value={formData.city} onChange={handleChange} className={inputClass} />
                    </div>
                </div>
            );
        case 2: // Family
            return (
                <div className={gridClass}>
                    <div>
                        <label className={labelClass}>Father's Name (Optional)</label>
                        <input type="text" name="father_name" value={formData.father_name} onChange={handleChange} className={inputClass} />
                    </div>
                    <div>
                        <SelectField
                            label="Father's Status*"
                            name="father_status"
                            value={formData.father_status}
                            onChange={handleChange}
                            options={["Employed", "Business", "Retired", "Not Employed", "Passed Away"]}
                        />
                    </div>
                    <div>
                        <label className={labelClass}>Father's Occupation</label>
                        <input type="text" name="father_occupation" value={formData.father_occupation} onChange={handleChange} className={inputClass} />
                    </div>
                    <div>
                        <label className={labelClass}>Mother's Name (Optional)</label>
                        <input type="text" name="mother_name" value={formData.mother_name} onChange={handleChange} className={inputClass} />
                    </div>
                    <div>
                        <SelectField
                            label="Mother's Status*"
                            name="mother_status"
                            value={formData.mother_status}
                            onChange={handleChange}
                            options={["Homemaker", "Employed", "Business", "Retired", "Passed Away"]}
                        />
                    </div>
                    <div>
                        <label className={labelClass}>Mother's Occupation</label>
                        <input type="text" name="mother_occupation" value={formData.mother_occupation} onChange={handleChange} className={inputClass} />
                    </div>
                    <div>
                        <label className={labelClass}>Brothers</label>
                        <input type="number" name="brothers" value={formData.brothers} min="0" onChange={handleChange} className={inputClass} />
                    </div>
                    <div>
                        <label className={labelClass}>Sisters</label>
                        <input type="number" name="sisters" value={formData.sisters} min="0" onChange={handleChange} className={inputClass} />
                    </div>
                    <div>
                        <SelectField
                            label="Family Status*"
                            name="family_status"
                            value={formData.family_status}
                            onChange={handleChange}
                            options={["Middle Class", "Upper Middle Class", "Rich", "Affluent"]}
                        />
                    </div>
                    <div>
                        <SelectField
                            label="Family Type*"
                            name="family_type"
                            value={formData.family_type}
                            onChange={handleChange}
                            options={["Joint", "Nuclear", "Others"]}
                        />
                    </div>
                    <div>
                        <SelectField
                            label="Family Values*"
                            name="family_values"
                            value={formData.family_values}
                            onChange={handleChange}
                            options={["Traditional", "Moderate", "Liberal"]}
                        />
                    </div>
                    <div>
                        <SelectField
                            label="Do you live with family?"
                            name="live_with_family"
                            value={formData.live_with_family}
                            onChange={handleChange}
                        >
                            <option value="Yes">Yes</option>
                            <option value="No">No</option>
                        </SelectField>
                    </div>
                    <div>
                        <label className={labelClass}>Family Location</label>
                        <input type="text" name="family_location" value={formData.family_location} onChange={handleChange} className={inputClass} />
                    </div>
                    <div>
                        <SelectField
                            label="Annual Family Income"
                            name="annual_income"
                            value={formData.annual_income}
                            onChange={handleChange}
                            options={["0-2 Lakh", "2-5 Lakh", "5-10 Lakh", "10-20 Lakh", "20+ Lakh"]}
                        />
                    </div>
                </div>
            );
        case 3: // Education
            return (
                <div className={gridClass}>
                    <div>
                        <SelectField
                            label="Highest Education*"
                            name="highest_education"
                            value={formData.highest_education}
                            onChange={handleChange}
                            options={["High School", "Bachelors", "Masters", "Doctorate", "Diploma", "Other"]}
                        />
                    </div>
                    <div>
                        <label className={labelClass}>College Name (Optional)</label>
                        <input type="text" name="college_name" value={formData.college_name} onChange={handleChange} placeholder="e.g. IIT Delhi" className={inputClass} />
                    </div>
                    <div>
                        <label className={labelClass}>Educational Details</label>
                        <input type="text" name="educational_details" value={formData.educational_details} onChange={handleChange} placeholder="e.g. B.Tech Computer Science" className={inputClass} />
                    </div>
                    <div>
                        <label className={labelClass}>Occupation*</label>
                        {(() => {
                            const isCustom = formData.occupation && !OCCUPATIONS.includes(formData.occupation) && formData.occupation !== 'Other';
                            const dropdownValue = isCustom ? 'Other' : (formData.occupation || '');
                            const showInput = dropdownValue === 'Other';

                            return (
                                <div className="space-y-2">
                                    <SelectField
                                        value={dropdownValue}
                                        onChange={(e: any) => {
                                            const val = e.target.value;
                                            if (val === 'Other') {
                                                if (OCCUPATIONS.includes(formData.occupation)) {
                                                    handleChange({ target: { name: 'occupation', value: '' } } as any);
                                                }
                                            } else {
                                                handleChange({ target: { name: 'occupation', value: val } } as any);
                                            }
                                        }}
                                        options={OCCUPATIONS}
                                    />
                                    {showInput && (
                                        <input
                                            type="text"
                                            name="occupation"
                                            value={formData.occupation === 'Other' ? '' : formData.occupation}
                                            onChange={handleChange}
                                            placeholder="Enter occupation"
                                            className={inputClass}
                                            autoFocus
                                        />
                                    )}
                                </div>
                            );
                        })()}
                    </div>
                    <div>
                        <SelectField
                            label="Employed In*"
                            name="employed_in"
                            value={formData.employed_in}
                            onChange={handleChange}
                            options={["Private", "Government", "Defense", "Business", "Self Employed", "Not Working"]}
                        />
                    </div>
                    <div>
                        <SelectField
                            label="Annual Personal Income*"
                            name="personal_income"
                            value={formData.personal_income}
                            onChange={handleChange}
                            options={["0-2 Lakh", "2-5 Lakh", "5-10 Lakh", "10-15 Lakh", "15-20 Lakh", "20+ Lakh", "No Income"]}
                        />
                    </div>
                    <div>
                        <label className={labelClass}>Working Sector</label>
                        <input type="text" name="working_sector" value={formData.working_sector} onChange={handleChange} placeholder="e.g. IT, Healthcare" className={inputClass} />
                    </div>
                </div>
            );
        case 4: // Religious
            return (
                <div className={gridClass}>
                    <div>
                        <SelectField
                            label="Religion*"
                            name="religion"
                            value={formData.religion}
                            onChange={handleChange}
                            options={["Hindu", "Muslim", "Christian", "Sikh", "Jain", "Buddhist", "Other"]}
                        />
                    </div>
                    <div>
                        <label className={labelClass}>Community / Caste*</label>
                        <input type="text" name="community" value={formData.community} onChange={handleChange} className={inputClass} />
                    </div>
                    <div>
                        <label className={labelClass}>Sub-Community (Optional)</label>
                        <input type="text" name="sub_community" value={formData.sub_community} onChange={handleChange} className={inputClass} />
                    </div>
                    <div>
                        <SelectField
                            label="Manglik Status (Optional)"
                            name="manglik_status"
                            value={formData.manglik_status}
                            onChange={handleChange}
                            options={["Manglik", "Non-Manglik", "Anshik Manglik", "Don't Know"]}
                        />
                    </div>
                    <div>
                        <label className={labelClass}>Time of Birth (Optional)</label>
                        <input type="time" name="time_of_birth" value={formData.time_of_birth} onChange={handleChange} className={inputClass} />
                    </div>
                    <div>
                        <label className={labelClass}>Place of Birth (Optional)</label>
                        <input type="text" name="place_of_birth" value={formData.place_of_birth} onChange={handleChange} className={inputClass} />
                    </div>
                </div>
            );
        case 5: // Lifestyle
            return (
                <div className={gridClass}>
                    <div>
                        <SelectField
                            label="Complexion*"
                            name="complexion"
                            value={formData.complexion}
                            onChange={handleChange}
                            options={["Fair", "Wheatish", "Dark"]}
                        />
                    </div>
                    <div>
                        <SelectField
                            label="Living Status*"
                            name="living_status"
                            value={formData.living_status}
                            onChange={handleChange}
                            options={["With Family", "Alone"]}
                        />
                    </div>
                    <div>
                        <SelectField
                            label="Physical Status*"
                            name="physical_status"
                            value={formData.physical_status}
                            onChange={handleChange}
                        >
                            <option value="Normal">Normal</option>
                            <option value="Physically Challenged">Physically Challenged</option>
                        </SelectField>
                    </div>
                    <div>
                        <SelectField
                            label="Eating Habits*"
                            name="eating_habits"
                            value={formData.eating_habits}
                            onChange={handleChange}
                            options={["Vegetarian", "Non-Vegetarian", "Eggetarian"]}
                        />
                    </div>
                    <div>
                        <SelectField
                            label="Smoking Habits"
                            name="smoking_habits"
                            value={formData.smoking_habits}
                            onChange={handleChange}
                        >
                            <option value="No">No</option>
                            <option value="Yes">Yes</option>
                            <option value="Occasionally">Occasionally</option>
                        </SelectField>
                    </div>
                    <div>
                        <SelectField
                            label="Drinking Habits"
                            name="drinking_habits"
                            value={formData.drinking_habits}
                            onChange={handleChange}
                        >
                            <option value="No">No</option>
                            <option value="Yes">Yes</option>
                            <option value="Occasionally">Occasionally</option>
                        </SelectField>
                    </div>
                </div>
            );
        case 6: // Contact
            return (
                <div className={gridClass}>
                    <div>
                        <label className={labelClass}>Primary Phone*</label>
                        <input type="text" value={formData.phone} disabled className={`${inputClass} bg-gray-50 text-gray-400 cursor-not-allowed`} />
                    </div>
                    <div>
                        <label className={labelClass}>Alternate Mobile</label>
                        <input type="tel" name="alternate_mobile" value={formData.alternate_mobile} onChange={handleChange} className={inputClass} />
                    </div>
                    <div className="md:col-span-2">
                        <label className={labelClass}>Suitable Time To Call</label>
                        <div className="flex gap-4 items-center">
                            <div className="flex-1">
                                <span className="text-[10px] text-gray-400 font-bold mb-1 block ml-1">FROM</span>
                                <input
                                    type="time"
                                    value={formData.suitable_time_to_call?.split(' - ')[0] || ''}
                                    onChange={(e) => {
                                        const start = e.target.value;
                                        const end = formData.suitable_time_to_call?.split(' - ')[1] || '';
                                        handleChange({ target: { name: 'suitable_time_to_call', value: `${start} - ${end}` } } as any);
                                    }}
                                    className={inputClass}
                                />
                            </div>
                            <span className="mt-6 text-gray-300">to</span>
                            <div className="flex-1">
                                <span className="text-[10px] text-gray-400 font-bold mb-1 block ml-1">TO</span>
                                <input
                                    type="time"
                                    value={formData.suitable_time_to_call?.split(' - ')[1] || ''}
                                    onChange={(e) => {
                                        const start = formData.suitable_time_to_call?.split(' - ')[0] || '';
                                        const end = e.target.value;
                                        handleChange({ target: { name: 'suitable_time_to_call', value: `${start} - ${end}` } } as any);
                                    }}
                                    className={inputClass}
                                />
                            </div>
                        </div>
                    </div>
                </div>
            );
        case 7: // About
            return (
                <div className="space-y-4">
                    <label className={labelClass}>About Me* (Minimum 50 Characters)</label>
                    <textarea
                        name="about_me"
                        rows={10}
                        value={formData.about_me}
                        onChange={handleChange}
                        placeholder="Write a brief introduction about yourself, your values, and what you are looking for..."
                        className="w-full rounded-[24px] border border-gray-200 p-6 focus:border-[#EF2F55] focus:outline-none focus:ring-1 focus:ring-[#EF2F55] text-gray-900 bg-white hover:bg-gray-50 transition-all font-medium"
                    />
                    <div className="flex justify-end px-2">
                        <span className={`text-[10px] font-black uppercase tracking-widest ${formData.about_me?.length >= 50 ? 'text-green-500' : 'text-rose-500'}`}>
                            Character Count: {formData.about_me?.length || 0} / 50
                        </span>
                    </div>
                </div>
            );
        case 8: // Property
            const landAreaRaw = formData.land_area || '';
            const parts = landAreaRaw.toString().split(' ');
            let landVal = parts[0];
            let landUnit = parts.slice(1).join(' ') || 'Acres';

            const updateLandArea = (val: string, unit: string) => {
                const numericPart = val.replace(/[^0-9.]/g, '');
                setFormData((prev: any) => ({
                    ...prev,
                    land_area: numericPart ? parseFloat(numericPart) : '',
                    land_area_range: val ? `${val} ${unit}` : ''
                }));
            };

            const toggleMultiSelect = (field: string, value: string) => {
                const current = (formData as any)[field] || [];
                const updated = current.includes(value)
                    ? current.filter((v: string) => v !== value)
                    : [...current, value];
                handleChange({ target: { name: field, value: updated } } as any);
            };

            const renderMultiSelect = (label: string, field: string, options: string[]) => (
                <div className="col-span-full">
                    <label className={labelClass}>{label}</label>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-2 mt-2">
                        {options.map(opt => (
                            <button
                                key={opt}
                                type="button"
                                onClick={() => toggleMultiSelect(field, opt)}
                                className={`px-4 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest border transition-all ${((formData as any)[field] || []).includes(opt)
                                    ? 'bg-[#EF2F55] text-white border-[#EF2F55] shadow-md transform scale-[0.98]'
                                    : 'bg-white text-gray-400 border-gray-100 hover:border-rose-200 hover:bg-rose-50'
                                    }`}
                            >
                                {opt}
                            </button>
                        ))}
                    </div>
                </div>
            );

            return (
                <div className={gridClass}>
                    <div>
                        <label className={labelClass}>Land Area</label>
                        <div className="flex gap-2">
                            <input
                                type="number"
                                value={landVal}
                                onChange={(e) => updateLandArea(e.target.value, landUnit)}
                                min="0"
                                placeholder="Enter Area"
                                className={inputClass}
                            />
                            <SelectField
                                value={landUnit}
                                onChange={(e: any) => updateLandArea(landVal, e.target.value)}
                                className="!w-32"
                            >
                                <option value="Acres">Acres</option>
                                <option value="Bigha">Bigha</option>
                                <option value="Ghaz">Ghaz</option>
                                <option value="Sq. Ft.">Sq. Ft.</option>
                            </SelectField>
                        </div>
                    </div>
                    <div className="col-span-full h-px bg-gray-50 my-2" />
                    {renderMultiSelect("Property Types", "property_types", ["Commercial", "Residential", "Agricultural", "Industrial"])}
                    {renderMultiSelect("Land Types", "land_types", ["Agricultural Land", "Plot", "Farmhouse", "Industrial Land"])}
                    {renderMultiSelect("House Types", "house_types", ["Apartment", "Independent House", "Villa", "Penthouse"])}
                    {renderMultiSelect("Business Types", "business_types", ["Shop", "Office Space", "Warehouse", "Factory"])}
                </div>
            );
        case 9: // Photos
            return (
                <div className="h-full">
                    <div className="bg-rose-50 border border-rose-100 p-6 rounded-[24px] flex gap-4 mb-8">
                        <div className="p-3 bg-white rounded-2xl shadow-sm h-fit">
                            <Camera className="w-6 h-6 text-[#EF2F55]" />
                        </div>
                        <div>
                            <h4 className="text-[10px] font-black text-gray-900 uppercase tracking-widest mb-1">PRO TIP</h4>
                            <p className="text-xs text-gray-600 leading-relaxed font-medium">
                                Upload high-quality photos. Profiles with photos get 10x more interest!
                            </p>
                        </div>
                    </div>

                    <PhotoUploadGrid
                        photos={photos}
                        setPhotos={setPhotos}
                        updateProfilePhotoLocal={updateProfilePhotoLocal}
                        uploadEndpoint={memberId ? `/franchise/profiles/${memberId}/photos` : undefined}
                        deleteEndpoint={memberId ? `/franchise/profiles/${memberId}/photos` : undefined}
                        setProfileEndpoint={memberId ? `/franchise/profiles/${memberId}/photos` : undefined}
                    />

                    {photos.length > 0 && photos[0].url && (
                        <div className="mt-12 p-8 bg-gray-50 rounded-[32px] border border-gray-100 flex flex-col items-center animate-in fade-in zoom-in duration-500">
                            <h4 className="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em] mb-6">Profile Preview</h4>
                            <div className="relative w-40 h-40 rounded-full overflow-hidden ring-[8px] ring-white shadow-2xl">
                                <img
                                    src={photos[0].url}
                                    alt="Profile"
                                    className="w-full h-full object-cover"
                                />
                                <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent" />
                            </div>
                            <p className="mt-4 text-[10px] font-black text-[#EF2F55] uppercase tracking-widest">Looking Stunning!</p>
                        </div>
                    )}
                </div>
            );
        default:
            return null;
    }
}
