'use client';

import { useState, useEffect } from 'react';
import api from '../../services/api'; // Adjust path if needed
import { Trash2, AlertCircle, Plus, Save } from 'lucide-react';
import ConfirmationModal from '../../../components/ConfirmationModal';
import { useToast } from '../../contexts/ToastContext';

interface FilterConfig {
    _id: string;
    label: string;
    key: string;
    type: string;
    options: string[];
    section: string;
    isVisible: boolean;
    order: number;
    onboardingStep?: number;
    onboardingRequired?: boolean;
    onboardingEnabled?: boolean;
    placeholder?: string;
    description?: string;
    validation?: any;
}

export default function FilterManagement() {
    const { addToast } = useToast();
    const [filters, setFilters] = useState<FilterConfig[]>([]);
    const [loading, setLoading] = useState(true);
    const [activeSection, setActiveSection] = useState('All');

    // Sections for predefined grouping
    const sections = ['All', 'Basic', 'Location', 'Family', 'Education', 'Religious', 'Lifestyle', 'Property', 'Other'];

    // Modal State
    const [confirmModal, setConfirmModal] = useState({
        isOpen: false,
        title: '',
        message: '',
        onConfirm: async () => { },
        isDangerous: false,
        confirmText: 'Confirm'
    });

    const [editModal, setEditModal] = useState({
        isOpen: false,
        filter: null as FilterConfig | null
    });

    useEffect(() => {
        fetchFilters();
    }, []);

    const fetchFilters = async () => {
        try {
            const res = await api.get('/filters/admin');
            if (res.data.success) {
                setFilters(res.data.data);
            }
        } catch (error) {
            console.error('Failed to fetch filters', error);
        } finally {
            setLoading(false);
        }
    };

    const toggleVisibility = async (id: string, currentStatus: boolean) => {
        try {
            await api.put(`/filters/${id}`, { isVisible: !currentStatus });
            setFilters(prev => prev.map(f => f._id === id ? { ...f, isVisible: !currentStatus } : f));
            addToast(`Filter ${!currentStatus ? 'visible' : 'hidden'}`, 'success');
        } catch (error) {
            addToast('Failed to update visibility', 'error');
        }
    };

    const deleteFilter = (id: string) => {
        setConfirmModal({
            isOpen: true,
            title: 'Delete Filter',
            message: 'Are you sure you want to delete this filter? This cannot be undone.',
            confirmText: 'Delete',
            isDangerous: true,
            onConfirm: async () => {
                try {
                    await api.delete(`/filters/${id}`);
                    setFilters(prev => prev.filter(f => f._id !== id));
                    addToast('Filter deleted successfully', 'success');
                } catch (error) {
                    addToast('Failed to delete filter', 'error');
                }
            }
        });
    };

    const handleUpdateFilter = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!editModal.filter) return;

        try {
            const res = await api.put(`/filters/${editModal.filter._id}`, editModal.filter);
            if (res.data.success) {
                setFilters(prev => prev.map(f => f._id === editModal.filter?._id ? res.data.data : f));
                addToast('Filter updated successfully', 'success');
                setEditModal({ isOpen: false, filter: null });
            }
        } catch (error) {
            addToast('Failed to update filter', 'error');
        }
    };

    // Filter by Section for View
    const displayedFilters = activeSection === 'All'
        ? filters
        : filters.filter(f => f.section === activeSection);

    if (loading) return <div className="p-8">Loading...</div>;

    return (
        <div className="p-8 max-w-7xl mx-auto">
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold text-gray-800">Filter Management</h1>
                {/* Add Filter Button could go here (Optional for now as we seeded) */}
            </div>

            {/* Section Tabs */}
            <div className="flex gap-2 mb-6 overflow-x-auto pb-2">
                {sections.map(sec => (
                    <button
                        key={sec}
                        onClick={() => setActiveSection(sec)}
                        className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-colors ${activeSection === sec ? 'bg-indigo-600 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                            }`}
                    >
                        {sec}
                    </button>
                ))}
            </div>

            <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                <table className="w-full text-left">
                    <thead className="bg-gray-50 border-b border-gray-200">
                        <tr>
                            <th className="px-6 py-4 font-semibold text-gray-700">Label</th>
                            <th className="px-6 py-4 font-semibold text-gray-700">Type</th>
                            <th className="px-6 py-4 font-semibold text-gray-700">Section</th>
                            <th className="px-6 py-4 font-semibold text-gray-700 text-center">Visible</th>
                            <th className="px-6 py-4 font-semibold text-gray-700 text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100">
                        {displayedFilters.length === 0 ? (
                            <tr>
                                <td colSpan={5} className="px-6 py-8 text-center text-gray-500">
                                    No filters found in this section.
                                </td>
                            </tr>
                        ) : (
                            displayedFilters.map((filter) => (
                                <tr key={filter._id} className="hover:bg-gray-50 transition-colors">
                                    <td className="px-6 py-4 text-gray-900 font-medium">{filter.label}</td>
                                    <td className="px-6 py-4 text-gray-600 text-sm">
                                        <span className="bg-gray-100 px-2 py-1 rounded text-xs uppercase tracking-wide">
                                            {filter.type}
                                        </span>
                                    </td>
                                    <td className="px-6 py-4 text-gray-600 text-sm">{filter.section}</td>
                                    <td className="px-6 py-4 text-center">
                                        <button
                                            onClick={() => toggleVisibility(filter._id, filter.isVisible)}
                                            className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${filter.isVisible ? 'bg-green-500' : 'bg-gray-300'
                                                }`}
                                        >
                                            <span
                                                className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${filter.isVisible ? 'translate-x-6' : 'translate-x-1'
                                                    }`}
                                            />
                                        </button>
                                    </td>
                                    <td className="px-6 py-4 text-center">
                                        <div className="flex justify-center gap-2">
                                            <button
                                                onClick={() => setEditModal({ isOpen: true, filter: { ...filter } })}
                                                className="text-indigo-600 hover:text-indigo-800 p-2 rounded-full hover:bg-indigo-50 transition-colors"
                                                title="Edit Filter"
                                            >
                                                <Plus className="w-5 h-5" />
                                            </button>
                                            <button
                                                onClick={() => deleteFilter(filter._id)}
                                                className="text-red-500 hover:text-red-700 p-2 rounded-full hover:bg-red-50 transition-colors"
                                                title="Delete Filter"
                                            >
                                                <Trash2 className="w-5 h-5" />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>

            <ConfirmationModal
                isOpen={confirmModal.isOpen}
                onClose={() => setConfirmModal(prev => ({ ...prev, isOpen: false }))}
                onConfirm={confirmModal.onConfirm}
                title={confirmModal.title}
                message={confirmModal.message}
                confirmText={confirmModal.confirmText}
                isDangerous={confirmModal.isDangerous}
            />

            {/* Edit Modal */}
            {editModal.isOpen && editModal.filter && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-white rounded-2xl shadow-xl w-full max-w-2xl overflow-hidden animate-in fade-in zoom-in duration-200">
                        <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
                            <h2 className="text-xl font-bold text-gray-800">Edit Filter: {editModal.filter.label}</h2>
                            <button onClick={() => setEditModal({ isOpen: false, filter: null })} className="text-gray-400 hover:text-gray-600">&times;</button>
                        </div>
                        <form onSubmit={handleUpdateFilter} className="p-6 space-y-6 max-h-[80vh] overflow-y-auto">
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Label</label>
                                    <input
                                        type="text"
                                        value={editModal.filter.label}
                                        onChange={e => setEditModal(prev => ({ ...prev, filter: { ...prev.filter!, label: e.target.value } }))}
                                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-indigo-500 focus:border-indigo-500"
                                        required
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Key</label>
                                    <input
                                        type="text"
                                        value={editModal.filter.key}
                                        className="w-full px-3 py-2 border border-gray-200 bg-gray-50 rounded-md text-gray-500 cursor-not-allowed"
                                        disabled
                                    />
                                </div>
                            </div>

                            <div className="border-t border-gray-100 pt-6">
                                <h3 className="text-lg font-semibold text-gray-800 mb-4 flex items-center gap-2">
                                    <AlertCircle className="w-5 h-5 text-indigo-600" />
                                    Onboarding Configuration
                                </h3>
                                <div className="space-y-4 bg-indigo-50/30 p-4 rounded-xl border border-indigo-100">
                                    <div className="flex items-center justify-between">
                                        <div>
                                            <p className="font-medium text-gray-900">Enable in Onboarding</p>
                                            <p className="text-xs text-gray-500">Should this filter appear during user signup?</p>
                                        </div>
                                        <button
                                            type="button"
                                            onClick={() => setEditModal(prev => ({ ...prev, filter: { ...prev.filter!, onboardingEnabled: !prev.filter?.onboardingEnabled } }))}
                                            className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${editModal.filter.onboardingEnabled ? 'bg-indigo-600' : 'bg-gray-300'}`}
                                        >
                                            <span className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${editModal.filter.onboardingEnabled ? 'translate-x-6' : 'translate-x-1'}`} />
                                        </button>
                                    </div>

                                    {editModal.filter.onboardingEnabled && (
                                        <div className="grid grid-cols-2 gap-4 animate-in slide-in-from-top-2 duration-200">
                                            <div>
                                                <label className="block text-sm font-medium text-gray-700 mb-1">Onboarding Step</label>
                                                <input
                                                    type="number"
                                                    value={editModal.filter.onboardingStep || ''}
                                                    onChange={e => setEditModal(prev => ({ ...prev, filter: { ...prev.filter!, onboardingStep: parseInt(e.target.value) } }))}
                                                    placeholder="e.g. 1"
                                                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-indigo-500 focus:border-indigo-500"
                                                />
                                            </div>
                                            <div className="flex items-end pb-2">
                                                <label className="flex items-center gap-2 cursor-pointer">
                                                    <input
                                                        type="checkbox"
                                                        checked={editModal.filter.onboardingRequired || false}
                                                        onChange={e => setEditModal(prev => ({ ...prev, filter: { ...prev.filter!, onboardingRequired: e.target.checked } }))}
                                                        className="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
                                                    />
                                                    <span className="text-sm font-medium text-gray-700">Required Field</span>
                                                </label>
                                            </div>
                                            <div className="col-span-2">
                                                <label className="block text-sm font-medium text-gray-700 mb-1">Placeholder</label>
                                                <input
                                                    type="text"
                                                    value={editModal.filter.placeholder || ''}
                                                    onChange={e => setEditModal(prev => ({ ...prev, filter: { ...prev.filter!, placeholder: e.target.value } }))}
                                                    placeholder="Enter placeholder text..."
                                                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-indigo-500 focus:border-indigo-500"
                                                />
                                            </div>
                                            <div className="col-span-2">
                                                <label className="block text-sm font-medium text-gray-700 mb-1">Description / Tooltip</label>
                                                <textarea
                                                    value={editModal.filter.description || ''}
                                                    onChange={e => setEditModal(prev => ({ ...prev, filter: { ...prev.filter!, description: e.target.value } }))}
                                                    placeholder="Help text for the user..."
                                                    rows={2}
                                                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-indigo-500 focus:border-indigo-500"
                                                />
                                            </div>
                                        </div>
                                    )}
                                </div>
                            </div>

                            <div className="flex justify-end gap-3 pt-4 border-t border-gray-100">
                                <button
                                    type="button"
                                    onClick={() => setEditModal({ isOpen: false, filter: null })}
                                    className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 transition-colors"
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    className="px-4 py-2 text-sm font-medium text-white bg-indigo-600 rounded-md hover:bg-indigo-700 transition-colors flex items-center gap-2 shadow-sm"
                                >
                                    <Save className="w-4 h-4" />
                                    Save Changes
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
