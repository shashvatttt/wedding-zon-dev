'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import api from '../../services/api';
import { useAuth } from '../../context/AuthContext';
import {
    Store, MapPin, FileText, ArrowRight,
    CreditCard, Share2, Clock, Upload,
    ChevronDown, Globe
} from 'lucide-react';
import { Slider } from '@/components/ui/slider';

const InputField = ({ label, name, placeholder, value, onChange, type = "text", required = false, disabled = false, maxLength }: any) => (
    <div className="flex flex-col gap-1.5 w-full">
        <label className="text-[#111827] text-sm font-medium ml-1">
            {label}{required && '*'}
        </label>
        <div className="relative shadow-[0px_0px_4px_rgba(0,0,0,0.25)] rounded-md">
            <input
                type={type}
                name={name}
                placeholder={placeholder}
                required={required}
                disabled={disabled}
                maxLength={maxLength}
                className={`w-full h-12 px-4 border border-[#FBC3CF] rounded-md text-[#111827] focus:outline-none focus:ring-1 focus:ring-[#EF2F55] placeholder:text-[#6B7280] transition-all ${disabled ? 'bg-gray-100 text-gray-500 cursor-not-allowed' : 'bg-white'}`}
                value={value}
                onChange={onChange}
            />
        </div>
    </div>
);

const SelectField = ({ label, name, options, value, onChange, required = false }: any) => (
    <div className="flex flex-col gap-1.5 w-full">
        <label className="text-[#111827] text-sm font-medium ml-1">
            {label}{required && '*'}
        </label>
        <div className="relative shadow-[0px_0px_4px_rgba(0,0,0,0.25)] rounded-md">
            <select
                name={name}
                required={required}
                className="w-full h-12 px-4 bg-white border border-[#FBC3CF] rounded-md text-[#111827] appearance-none focus:outline-none focus:ring-1 focus:ring-[#EF2F55] transition-all"
                value={value}
                onChange={onChange}
            >
                <option value="">Select {label}</option>
                {options.map((opt: any) => (
                    <option key={opt} value={opt}>{opt}</option>
                ))}
            </select>
            <ChevronDown className="absolute right-4 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none" />
        </div>
    </div>
);

export default function VendorOnboardingPage() {
    const router = useRouter();
    const { checkAuth, user } = useAuth();
    const [loading, setLoading] = useState(false);
    const [isLocating, setIsLocating] = useState(false);

    const [formData, setFormData] = useState({
        // Root fields
        first_name: '',
        last_name: '',
        email: '',
        aadhar_number: '',
        phone: '',
        country: 'India',
        state: 'Uttar Pradesh',
        city: '',

        // vendor_details fields
        business_name: '',
        service_type: '',
        business_address: '',
        pincode: '',
        starting_price: '1000',
        map_link: '',
        embedded_map_link: '',
        working_hours: '',
        description: '',
        payment_terms: '',

        // nested objects
        bank_details: {
            account_holder_name: '',
            bank_name: '',
            account_number: '',
            ifsc_code: '',
            account_type: 'Savings',
            upi_id: '',
            linked_mobile_number: '',
            gstin: '',
        },
        social_links: {
            instagram: '',
            facebook: '',
            youtube: '',
            twitter: '',
        }
    });

    // Pre-fill email and phone from Auth Context
    useEffect(() => {
        if (user) {
            setFormData(prev => ({
                ...prev,
                email: user.email || prev.email,
                phone: user.phone ? user.phone.replace(/^\+91/, '').replace(/\D/g, '') : prev.phone
            }));
        }
    }, [user]);

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
        const { name, value } = e.target;

        // Validation Logic
        if (name === 'aadhar_number') {
            const numericValue = value.replace(/\D/g, '').slice(0, 12);
            setFormData(prev => ({ ...prev, aadhar_number: numericValue }));
            return;
        }

        if (name === 'phone' || name === 'bank_details.linked_mobile_number') {
            const numericValue = value.replace(/\D/g, '').slice(0, 10);
            if (name.includes('.')) {
                // Handle nested phone update
                const [parent, child] = name.split('.');
                setFormData(prev => ({
                    ...prev,
                    [parent]: {
                        ...(prev[parent as keyof typeof prev] as any),
                        [child]: numericValue
                    }
                }));
            } else {
                setFormData(prev => ({ ...prev, phone: numericValue }));
            }
            return;
        }

        if (name === 'pincode') {
            const numericValue = value.replace(/\D/g, '').slice(0, 6);
            setFormData(prev => ({ ...prev, pincode: numericValue }));
            return;
        }

        if (name.includes('.')) {
            const [parent, child] = name.split('.');
            setFormData(prev => ({
                ...prev,
                [parent]: {
                    ...(prev[parent as keyof typeof prev] as any),
                    [child]: value
                }
            }));
        } else {
            setFormData(prev => ({
                ...prev,
                [name]: value
            }));
        }
    };

    const handleUseCurrentLocation = () => {
        if (!navigator.geolocation) {
            alert('Geolocation is not supported by your browser');
            return;
        }
        setIsLocating(true);
        navigator.geolocation.getCurrentPosition(async (position) => {
            const { latitude, longitude } = position.coords;
            try {
                const response = await fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitude}`);
                const data = await response.json();
                if (data.address) {
                    const addr = data.address;
                    const streetAddress = [addr.road, addr.suburb, addr.neighbourhood, addr.suburb].filter(Boolean).join(', ');
                    setFormData(prev => ({
                        ...prev,
                        country: addr.country || 'India',
                        state: addr.state || addr.region || 'Uttar Pradesh',
                        city: addr.city || addr.town || addr.village || '',
                        business_address: streetAddress || prev.business_address,
                        pincode: addr.postcode ? addr.postcode.replace(/\D/g, '').slice(0, 6) : prev.pincode,
                        map_link: `https://www.google.com/maps?q=${latitude},${longitude}`,
                        embedded_map_link: `https://maps.google.com/maps?q=${latitude},${longitude}&z=15&output=embed`
                    }));
                    alert('Location details and Map Preview updated successfully!');
                }
            } catch (error) {
                console.error('Failed to fetch location', error);
                alert('Failed to fetch location details.');
            } finally {
                setIsLocating(false);
            }
        }, (error) => {
            console.error('Geolocation error', error);
            alert('Location permission denied or unavailable.');
            setIsLocating(false);
        });
    };


    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);

        // Final Validation
        if (formData.aadhar_number.length !== 12) {
            alert('Aadhar Number must be exactly 12 digits');
            setLoading(false);
            return;
        }
        if (formData.phone.length !== 10) {
            alert('Mobile Number must be exactly 10 digits');
            setLoading(false);
            return;
        }
        if (formData.pincode.length !== 6) {
            alert('Pincode must be exactly 6 digits');
            setLoading(false);
            return;
        }

        // Bank Details Validation (Only if provided)
        const ifscRegex = /^[A-Z]{4}0[A-Z0-9]{6}$/;
        const upiRegex = /^[\w.-]+@[\w.-]+$/;
        const gstinRegex = /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/;
        const accountNumberRegex = /^\d{9,18}$/;
        const { bank_details } = formData;

        if (bank_details.account_number && !accountNumberRegex.test(bank_details.account_number)) {
            alert('Invalid account number (9-18 digits required)');
            setLoading(false);
            return;
        }
        if (bank_details.ifsc_code && !ifscRegex.test(bank_details.ifsc_code)) {
            alert('Invalid IFSC code format (e.g., SBIN0001234)');
            setLoading(false);
            return;
        }
        if (bank_details.upi_id && !upiRegex.test(bank_details.upi_id)) {
            alert('Invalid UPI ID format (e.g., username@bank)');
            setLoading(false);
            return;
        }
        if (bank_details.gstin && !gstinRegex.test(bank_details.gstin)) {
            alert('Invalid GSTIN format');
            setLoading(false);
            return;
        }
        if (bank_details.linked_mobile_number && bank_details.linked_mobile_number.length !== 10) {
            alert('Linked Mobile Number must be exactly 10 digits');
            setLoading(false);
            return;
        }


        try {
            const payload = {
                role: 'vendor',
                first_name: formData.first_name,
                last_name: formData.last_name,
                email: formData.email,
                aadhar_number: formData.aadhar_number,
                phone: formData.phone,
                country: formData.country,
                state: formData.state,
                city: formData.city,

                vendor_details: {
                    business_name: formData.business_name,
                    service_type: formData.service_type,
                    business_address: formData.business_address,
                    pincode: formData.pincode,
                    price_range: `Starts from ₹${formData.starting_price}`,
                    map_link: formData.map_link,
                    embedded_map_link: formData.embedded_map_link,
                    working_hours: formData.working_hours,
                    description: formData.description,
                    payment_terms: formData.payment_terms,
                    city: formData.city,
                    state: formData.state,
                    bank_details: formData.bank_details,
                    social_links: formData.social_links
                }
            };

            const res = await api.post('/auth/register-details', payload);

            if (res.status === 200) {
                await checkAuth();
                router.push('/vendor/payment');
            }
        } catch (error: any) {
            console.error('Vendor details update failed', error);
            alert('Failed to save details. Please try again.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen bg-gray-50/50 py-12 px-4 sm:px-6 lg:px-8 font-inter">
            <div className="max-w-[1117px] mx-auto bg-white rounded-2xl shadow-[0px_0px_4px_rgba(0,0,0,0.25)] overflow-hidden">
                {/* Header Section */}
                <div className="px-8 pt-8 pb-4">

                    <h2 className="text-black text-3xl font-medium mb-1">Vendor Listing</h2>
                </div>

                <form onSubmit={handleSubmit} className="px-8 pb-12 space-y-12">
                    {/* Basic Details Section */}
                    <div className="space-y-6">
                        <h3 className="text-[#111827] text-2xl font-medium border-b border-gray-100 pb-2 flex items-center gap-2">
                            <FileText className="w-5 h-5 text-[#EF2F55]" />
                            Basic Details
                        </h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6">
                            <InputField label="Name" name="first_name" placeholder="Enter your name" value={formData.first_name} onChange={handleChange} required />
                            <InputField label="Company Name" name="business_name" placeholder="Enter your Company Name*" value={formData.business_name} onChange={handleChange} required />
                            <InputField
                                label="Email ID"
                                name="email"
                                placeholder="Enter your email"
                                type="email"
                                value={formData.email}
                                onChange={handleChange}
                                required
                            />
                            <InputField label="Aadhar Number" name="aadhar_number" placeholder="Enter your Aadhar Number (12 Digits)" value={formData.aadhar_number} onChange={handleChange} maxLength={12} required />

                            <div className="grid grid-cols-1 gap-x-8 gap-y-6 md:contents">
                                <InputField 
                                    label="Starting Price (₹)" 
                                    name="starting_price" 
                                    placeholder="e.g. 5000" 
                                    value={formData.starting_price} 
                                    onChange={(e: any) => {
                                        const val = e.target.value.replace(/\D/g, '');
                                        setFormData(prev => ({ ...prev, starting_price: val }));
                                    }} 
                                    required 
                                />

                                <div className="flex flex-col gap-1.5 w-full">
                                    <label className="text-[#111827] text-sm font-medium ml-1">Mobile No.</label>
                                    <div className="flex gap-2">
                                        <div className="relative shadow-[0px_0px_4px_rgba(0,0,0,0.25)] rounded-md w-24">
                                            <div className="h-12 border border-[#FBC3CF] rounded-md flex items-center justify-between px-3 bg-white">
                                                <span className="text-gray-700">+91</span>
                                                <ChevronDown className="w-3 h-3 text-gray-400" />
                                            </div>
                                        </div>
                                        <div className="flex-1 shadow-[0px_0px_4px_rgba(0,0,0,0.25)] rounded-md">
                                            <input
                                                type="tel"
                                                name="phone"
                                                placeholder="Enter your phone number"
                                                disabled={true} // Read Only
                                                className="w-full h-12 px-4 bg-gray-100 border border-[#FBC3CF] rounded-md text-gray-500 focus:outline-none cursor-not-allowed placeholder:text-[#6B7280]"
                                                value={formData.phone}
                                                onChange={handleChange}
                                                maxLength={10}
                                            />
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div className="col-span-full flex justify-end mb-2">
                                <button
                                    type="button"
                                    onClick={handleUseCurrentLocation}
                                    disabled={isLocating}
                                    className="flex items-center gap-2 text-[#EF2F55] text-sm font-semibold hover:bg-rose-50 px-4 py-2 rounded-lg border border-rose-100 transition-all shadow-sm"
                                >
                                    <MapPin className={`w-4 h-4 ${isLocating ? 'animate-pulse' : ''}`} />
                                    {isLocating ? 'Fetching Location...' : 'Fetch Location'}
                                </button>
                            </div>

                            <InputField label="Local Address" name="business_address" placeholder="Enter your Local Address" value={formData.business_address} onChange={handleChange} />
                            <InputField label="Pin Code" name="pincode" placeholder="Enter your Pin Code" value={formData.pincode} onChange={handleChange} maxLength={6} required />

                            <SelectField
                                label="Select Services"
                                name="service_type"
                                options={["Photography", "Venue", "Catering", "Makeup Artist", "Decorator", "Other"]}
                                value={formData.service_type}
                                onChange={handleChange}
                                required
                            />

                            <div className="flex flex-col gap-1.5 w-full">
                                <InputField label="Map Link" name="map_link" placeholder="Enter your Map Link" value={formData.map_link} onChange={handleChange} />
                                <button
                                    type="button"
                                    onClick={handleUseCurrentLocation}
                                    disabled={isLocating}
                                    className="self-end mt-1 flex items-center gap-1.5 text-[#EF2F55] text-xs font-semibold hover:bg-rose-50 px-3 py-1.5 rounded-lg border border-rose-100 transition-all shadow-sm"
                                >
                                    <MapPin className={`w-3.5 h-3.5 ${isLocating ? 'animate-pulse' : ''}`} />
                                    {isLocating ? 'Getting Link...' : 'Get Map Link Directly'}
                                </button>
                            </div>
                            <div className="flex flex-col gap-1.5 w-full">
                                <InputField 
                                    label="Embedded Map Link" 
                                    name="embedded_map_link" 
                                    placeholder="Enter your Embedded Map Link (iframe src)" 
                                    value={formData.embedded_map_link} 
                                    onChange={handleChange} 
                                />
                                <button
                                    type="button"
                                    onClick={handleUseCurrentLocation}
                                    disabled={isLocating}
                                    className="self-end mt-1 flex items-center gap-1.5 text-[#EF2F55] text-xs font-semibold hover:bg-rose-50 px-3 py-1.5 rounded-lg border border-rose-100 transition-all shadow-sm"
                                >
                                    <Globe className={`w-3.5 h-3.5 ${isLocating ? 'animate-pulse' : ''}`} />
                                    {isLocating ? 'Fetching Link...' : 'Get Embedded Link Directly'}
                                </button>
                            </div>

                            {/* Map Preview */}
                            {(formData.embedded_map_link || formData.map_link) && (
                                <div className="col-span-full space-y-3">
                                    <label className="text-[#111827] text-sm font-medium ml-1">Map Preview</label>
                                    <div className="bg-white p-2 rounded-xl shadow-inner border border-gray-100 overflow-hidden">
                                        {formData.embedded_map_link ? (
                                            <div className="aspect-video w-full rounded-lg overflow-hidden bg-gray-50">
                                                <iframe
                                                    src={formData.embedded_map_link.includes('src=') 
                                                        ? formData.embedded_map_link.split('src="')[1].split('"')[0] 
                                                        : formData.embedded_map_link}
                                                    width="100%"
                                                    height="100%"
                                                    style={{ border: 0 }}
                                                    allowFullScreen
                                                    loading="lazy"
                                                />
                                            </div>
                                        ) : (
                                            <div className="aspect-video w-full bg-gray-50 rounded-lg flex flex-col items-center justify-center gap-2 text-center p-4">
                                                <MapPin className="w-8 h-8 text-[#EF2F55] opacity-20" />
                                                <p className="text-xs text-gray-400">Preview not available for standard links.<br/>Only embedded links can be previewed.</p>
                                                <a href={formData.map_link} target="_blank" rel="noopener noreferrer" className="text-[#EF2F55] text-xs font-bold hover:underline">
                                                    Test Map Link
                                                </a>
                                            </div>
                                        )}
                                        <p className="text-[10px] text-gray-400 mt-2 px-2">
                                            Tip: For best results, use the "Embed a map" link from Google Maps share menu and paste the <strong>src</strong> URL here.
                                        </p>
                                    </div>
                                </div>
                            )}

                            <InputField label="City" name="city" placeholder="Enter your City" value={formData.city} onChange={handleChange} required />

                            <SelectField
                                label="Country"
                                name="country"
                                options={["India", "USA", "UK", "Canada"]}
                                value={formData.country}
                                onChange={handleChange}
                            />
                            <SelectField
                                label="State"
                                name="state"
                                options={["Uttar Pradesh", "Delhi", "Maharashtra", "Karnataka", "Tamil Nadu"]}
                                value={formData.state}
                                onChange={handleChange}
                            />
                        </div>
                    </div>

                    {/* Bank Details Section */}
                    <div className="space-y-6">
                        <h3 className="text-[#111827] text-2xl font-medium border-b border-gray-100 pb-2 flex items-center gap-2">
                            <CreditCard className="w-5 h-5 text-[#EF2F55]" />
                            Bank Details
                        </h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6">
                            <InputField label="Account Holder Name" name="bank_details.account_holder_name" placeholder="Enter your name" value={formData.bank_details.account_holder_name} onChange={handleChange} />
                            <InputField label="Bank Name" name="bank_details.bank_name" placeholder="Enter your Bank Name" value={formData.bank_details.bank_name} onChange={handleChange} />
                            <InputField label="Account Number" name="bank_details.account_number" placeholder="Enter your Account Number" value={formData.bank_details.account_number} onChange={handleChange} />
                            <InputField label="IFSC Code" name="bank_details.ifsc_code" placeholder="Enter your IFSC Code (e.g., SBIN0001234)" value={formData.bank_details.ifsc_code} onChange={handleChange} />

                            <SelectField
                                label="Account Type"
                                name="bank_details.account_type"
                                options={["Savings", "Current"]}
                                value={formData.bank_details.account_type}
                                onChange={handleChange}
                            />
                            <InputField label="UPI ID" name="bank_details.upi_id" placeholder="Enter your UPI ID (e.g., username@bank)" value={formData.bank_details.upi_id} onChange={handleChange} />

                            <div className="flex flex-col gap-1.5 w-full">
                                <label className="text-[#111827] text-sm font-medium ml-1">Linked Mobile Number</label>
                                <div className="flex gap-2">
                                    <div className="h-12 w-24 border border-[#FBC3CF] rounded-md flex items-center justify-between px-3 bg-white shadow-[0px_0px_4px_rgba(0,0,0,0.25)]">
                                        <span className="text-gray-700">+91</span>
                                        <ChevronDown className="w-3 h-3 text-gray-400" />
                                    </div>
                                    <div className="flex-1 shadow-[0px_0px_4px_rgba(0,0,0,0.25)] rounded-md">
                                        <input
                                            type="tel"
                                            name="bank_details.linked_mobile_number"
                                            placeholder="Enter your phone number"
                                            className="w-full h-12 px-4 bg-white border border-[#FBC3CF] rounded-md text-[#111827] focus:outline-none focus:ring-1 focus:ring-[#EF2F55]"
                                            value={formData.bank_details.linked_mobile_number}
                                            onChange={handleChange}
                                            maxLength={10}
                                        />
                                    </div>
                                </div>
                            </div>
                            <InputField label="GSTIN" name="bank_details.gstin" placeholder="Enter your GSTIN" value={formData.bank_details.gstin} onChange={handleChange} />
                        </div>
                    </div>

                    {/* Social Links Section */}
                    <div className="space-y-6">
                        <h3 className="text-[#111827] text-2xl font-medium border-b border-gray-100 pb-2 flex items-center gap-2">
                            <Share2 className="w-5 h-5 text-[#EF2F55]" />
                            Social Links
                        </h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6">
                            <InputField label="Instagram Link" name="social_links.instagram" placeholder="Enter your Instagram Link" value={formData.social_links.instagram} onChange={handleChange} />
                            <InputField label="Facebook Link" name="social_links.facebook" placeholder="Enter your Facebook Link" value={formData.social_links.facebook} onChange={handleChange} />
                            <InputField label="Youtube Link" name="social_links.youtube" placeholder="Enter your Youtube Link" value={formData.social_links.youtube} onChange={handleChange} />
                            <InputField label="Twitter Link" name="social_links.twitter" placeholder="Enter your Twitter Link" value={formData.social_links.twitter} onChange={handleChange} />

                            {/* Business Glance Removed */}
                        </div>
                    </div>

                    {/* Working Details Section */}
                    <div className="space-y-6">
                        <h3 className="text-[#111827] text-2xl font-medium border-b border-gray-100 pb-2 flex items-center gap-2">
                            <Clock className="w-5 h-5 text-[#EF2F55]" />
                            Working Details
                        </h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6">
                            <div className="space-y-6">
                                <InputField label="Working Hours" name="working_hours" placeholder="Enter your Working Hours" value={formData.working_hours} onChange={handleChange} />
                                <InputField label="Payment" name="payment_terms" placeholder="Enter your Payment" value={formData.payment_terms} onChange={handleChange} />
                            </div>
                            <div className="flex flex-col gap-1.5 w-full">
                                <label className="text-[#111827] text-sm font-medium ml-1">Description</label>
                                <div className="shadow-[0px_0px_4px_rgba(0,0,0,0.25)] rounded-md flex-1">
                                    <textarea
                                        name="description"
                                        placeholder="Enter your Description (What best describes your work?)"
                                        rows={4}
                                        className="w-full h-full p-4 bg-white border border-[#FBC3CF] rounded-md text-[#111827] focus:outline-none focus:ring-1 focus:ring-[#EF2F55] placeholder:text-gray-400"
                                        value={formData.description}
                                        onChange={handleChange}
                                    />
                                </div>
                            </div>
                        </div>
                    </div>



                    {/* Submit Button */}
                    <div className="pt-8">
                        <button
                            type="submit"
                            disabled={loading}
                            className="w-full h-14 flex justify-center items-center gap-2 border border-transparent rounded-xl shadow-lg text-lg font-semibold text-white bg-[#EF2F55] hover:bg-[#d42a4a] focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-[#EF2F55] disabled:opacity-50 transition-all active:scale-[0.98]"
                        >
                            {loading ? 'Submitting Application...' : (
                                <>
                                    Complete Onboarding <ArrowRight className="w-5 h-5" />
                                </>
                            )}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}
