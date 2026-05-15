'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import api from '../services/api';
import { useAuth } from '@/app/context/AuthContext';
import { Users, Plus, Settings, AlertCircle, FileText, Sliders, Mail, LogOut, ArrowLeft, Trash2 } from 'lucide-react';

import MatchPreferencesModal from './components/MatchPreferencesModal';
import { useToast } from '../contexts/ToastContext';

export default function FranchiseDashboard() {
    const router = useRouter();
    const { addToast } = useToast();
    const { user, loading: authLoading, logout } = useAuth();
    const [profiles, setProfiles] = useState<any[]>([]);
    const [dataLoading, setDataLoading] = useState(true);
    const [selectedProfileForPrefs, setSelectedProfileForPrefs] = useState<any>(null);

    const refreshProfiles = async () => {
        try {
            const profilesRes = await api.get('/franchise/profiles');
            setProfiles(profilesRes.data.profiles);
        } catch (error) {
            console.error('Failed to refresh profiles', error);
        }
    };

    useEffect(() => {
        const fetchProfiles = async () => {
            if (authLoading) return;

            if (!user) {
                // Should be handled by AuthContext, but just in case
                return;
            }

            // Check Role
            if (user.role !== 'franchise') {
                router.push('/feed');
                return;
            }

            // Check Franchise Status
            // Check for specific statuses
            if (!user.franchise_status || user.franchise_status === 'pending_payment') {
                router.push('/franchise/payment');
                return;
            }
            if (user.franchise_status === 'pending_approval' || user.franchise_status === 'rejected') {
                router.push('/franchise/waiting');
                return;
            }

            // If Active, Fetch Profiles
            if (user.franchise_status === 'active') {
                try {
                    const profilesRes = await api.get('/franchise/profiles');
                    setProfiles(profilesRes.data.profiles);
                } catch (error) {
                    console.error('Failed to fetch profiles', error);
                } finally {
                    setDataLoading(false);
                }
            } else {
                setDataLoading(false);
            }
        };

        fetchProfiles();
    }, [user, authLoading, router]);

    if (authLoading || (user?.franchise_status === 'active' && dataLoading)) {
        return (
            <div className="flex h-screen items-center justify-center">
                <div className="h-12 w-12 animate-spin rounded-full border-b-2 border-pink-600"></div>
            </div>
        );
    }



    return (
        <div className="min-h-screen bg-rose-50/30">
            {/* Navbar */}
            <nav className="bg-white shadow-sm border-b border-rose-100">
                <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
                    <div className="flex h-16 justify-between items-center">
                        <div className="flex items-center gap-4">
                            <button
                                onClick={() => router.push('/feed')}
                                className="p-2 -ml-2 text-gray-400 hover:text-gray-600 transition-colors"
                                title="Back to Feed"
                            >
                                <ArrowLeft className="w-5 h-5" />
                            </button>
                            <div className="flex items-center gap-2">
                                <div className="h-8 w-8 bg-pink-600 rounded-lg flex items-center justify-center text-white font-bold">F</div>
                                <h1 className="text-xl font-bold text-gray-900">Franchise Dashboard</h1>
                            </div>
                        </div>
                        <div className="flex items-center gap-4">
                            <div className="text-right hidden sm:block">
                                <p className="text-sm font-medium text-gray-900">{user?.first_name || 'Partner'}</p>
                                <p className="text-xs text-green-600 font-medium">Verified Partner</p>
                            </div>
                            <button
                                onClick={logout}
                                className="bg-gray-100 hover:bg-gray-200 text-gray-700 px-4 py-2 sm:px-6 sm:py-2.5 rounded-full flex items-center gap-2 font-medium transition-all transform hover:-translate-y-0.5"
                            >
                                <LogOut className="w-4 h-4 sm:w-5 sm:h-5" />
                                <span className="hidden xs:inline">Log Out</span>
                            </button>
                        </div>
                    </div>
                </div>
            </nav>

            <main className="mx-auto max-w-7xl py-8 px-4 sm:px-6 lg:px-8">
                {/* Stats / Overview */}
                <div className="grid grid-cols-1 gap-6 sm:grid-cols-3 mb-8">
                    <div className="bg-white p-6 rounded-2xl shadow-sm border border-rose-100 flex items-center gap-4">
                        <div className="h-12 w-12 bg-blue-50 text-blue-600 rounded-full flex items-center justify-center">
                            <Users className="h-6 w-6" />
                        </div>
                        <div>
                            <p className="text-sm text-gray-500">Total Members</p>
                            <p className="text-2xl font-bold text-gray-900">{profiles.length}</p>
                        </div>
                    </div>
                    <div className="bg-white p-6 rounded-2xl shadow-sm border border-rose-100 flex items-center gap-4">
                        <div className="h-12 w-12 bg-green-50 text-green-600 rounded-full flex items-center justify-center">
                            <CheckCircleIcon className="h-6 w-6" />
                        </div>
                        <div>
                            <p className="text-sm text-gray-500">Active Profiles</p>
                            <p className="text-2xl font-bold text-gray-900">{profiles.filter(p => !p.isHidden).length}</p>
                        </div>
                    </div>
                    <div className="bg-white p-6 rounded-2xl shadow-sm border border-rose-100 flex items-center gap-4">
                        <div className="h-12 w-12 bg-pink-50 text-pink-600 rounded-full flex items-center justify-center">
                            <AlertCircle className="h-6 w-6" />
                        </div>
                        <div>
                            <p className="text-sm text-gray-500">Pending Actions</p>
                            <p className="text-2xl font-bold text-gray-900">0</p>
                        </div>
                    </div>
                </div>

                {/* Profiles Section */}
                <div className="flex justify-between items-center mb-6">
                    <h2 className="text-xl font-bold text-gray-900">Managed Profiles</h2>
                    <button
                        onClick={() => router.push('/franchise/add-member')}
                        className="flex items-center gap-2 bg-pink-600 text-white px-6 py-2.5 rounded-full font-medium hover:bg-pink-700 transition-all shadow-lg shadow-pink-600/20 transform hover:-translate-y-0.5"
                    >
                        <Plus className="h-5 w-5" />
                        Add Member
                    </button>
                </div>

                {profiles.length > 0 ? (
                    <div className="bg-white shadow-sm border border-rose-100 rounded-2xl overflow-hidden">
                        <div className="overflow-x-auto">
                            <table className="min-w-full divide-y divide-rose-50">
                                <thead className="bg-rose-50/50">
                                    <tr>
                                        <th className="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Member</th>
                                        <th className="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                                        <th className="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                                        <th className="px-6 py-4 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                                    </tr>
                                </thead>
                                <tbody className="bg-white divide-y divide-rose-50">
                                    {profiles.map((profile) => (
                                        <tr key={profile._id} className="hover:bg-rose-50/30 transition-colors">
                                            <td className="px-6 py-4 whitespace-nowrap">
                                                <div className="flex items-center">
                                                    <div className="h-10 w-10 flex-shrink-0">
                                                        {profile.profilePhoto ? (
                                                            <img className="h-10 w-10 rounded-full object-cover" src={profile.profilePhoto} alt="" />
                                                        ) : (
                                                            <div className="h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center text-gray-500">
                                                                <UserIcon className="h-5 w-5" />
                                                            </div>
                                                        )}
                                                    </div>
                                                    <div className="ml-4">
                                                        <div className="text-sm font-medium text-gray-900">{profile.first_name} {profile.last_name}</div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4 whitespace-nowrap">
                                                <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${profile.role === 'groom' ? 'bg-blue-100 text-blue-800' : 'bg-pink-100 text-pink-800'
                                                    }`}>
                                                    {profile.role === 'groom' ? "Groom" : "Bride"}
                                                </span>
                                            </td>
                                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                                Active
                                            </td>
                                            <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                                <div className="flex justify-end gap-3">
                                                    <button
                                                        type="button"
                                                        onClick={async () => {
                                                            try {
                                                                const response = await api.get(`/franchise/custom-matches/${profile._id}/pdf`, { responseType: 'blob' });
                                                                const url = window.URL.createObjectURL(new Blob([response.data]));
                                                                const link = document.createElement('a');
                                                                link.href = url;
                                                                link.setAttribute('download', `matches_${profile.first_name}.pdf`);
                                                                document.body.appendChild(link);
                                                                link.click();
                                                                link.remove();
                                                            } catch (err) {
                                                                addToast('Failed to download PDF', 'error');
                                                            }
                                                        }}
                                                        className="text-blue-600 hover:text-blue-900 flex items-center gap-1"
                                                        title="Download Matches PDF"
                                                    >
                                                        <FileText className="h-4 w-4" />
                                                        <span className="text-xs font-semibold">Download PDF</span>
                                                    </button>
                                                    <button
                                                        type="button"
                                                        onClick={async () => {
                                                            if (confirm('Are you sure? This will reset the password and send new credentials to the user.')) {
                                                                try {
                                                                    await api.post(`/franchise/profiles/${profile._id}/send-credentials`);
                                                                    addToast('Credentials sent successfully', 'success');
                                                                } catch (err) {
                                                                    addToast('Failed to send credentials', 'error');
                                                                }
                                                            }
                                                        }}
                                                        className="text-green-600 hover:text-green-900 flex items-center gap-1"
                                                        title="Send Credentials via Email/SMS"
                                                    >
                                                        <Mail className="h-4 w-4" />
                                                        <span className="text-xs font-semibold">Send Credentials</span>
                                                    </button>
                                                    <Link
                                                        href={`/feed?viewAs=${profile._id}`}
                                                        className="text-indigo-600 hover:text-indigo-900 flex items-center gap-1"
                                                        title="View Feed as this member"
                                                    >
                                                        <span className="text-xs font-semibold">View Feed</span>
                                                    </Link>
                                                    <button
                                                        type="button"
                                                        onClick={() => setSelectedProfileForPrefs(profile)}
                                                        className="text-pink-600 hover:text-pink-900 flex items-center justify-end gap-1"
                                                        title="Manage Partner Preferences"
                                                    >
                                                        <Sliders className="h-4 w-4" />
                                                        <span className="text-xs font-semibold">Match Prefs</span>
                                                    </button>
                                                    <button
                                                        type="button"
                                                        onClick={() => router.push(`/franchise/member/${profile._id}/manage`)}
                                                        className="text-orange-600 hover:text-orange-900 flex items-center justify-end gap-1"
                                                    >
                                                        <Settings className="h-4 w-4" />
                                                        Manage
                                                    </button>
                                                    <button
                                                        type="button"
                                                        onClick={async () => {
                                                            if (confirm(`Are you sure you want to delete ${profile.first_name}'s profile? This action cannot be undone.`)) {
                                                                try {
                                                                    await api.delete(`/franchise/profiles/${profile._id}`);
                                                                    addToast('Profile deleted successfully', 'success');
                                                                    refreshProfiles();
                                                                } catch (err) {
                                                                    addToast('Failed to delete profile', 'error');
                                                                }
                                                            }
                                                        }}
                                                        className="text-red-600 hover:text-red-900 flex items-center justify-end gap-1"
                                                        title="Delete Profile"
                                                    >
                                                        <Trash2 className="h-4 w-4" />
                                                        Delete
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>

                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </div>
                ) : (
                    <div className="text-center py-20 bg-white rounded-xl border border-dashed border-gray-300">
                        <div className="mx-auto h-12 w-12 text-gray-400">
                            <Users className="h-12 w-12" />
                        </div>
                        <h3 className="mt-2 text-sm font-medium text-gray-900">No members managed yet</h3>
                        <p className="mt-1 text-sm text-gray-500">Start by adding members to your franchise and manage their matches.</p>
                        <div className="mt-6">
                            <button
                                onClick={() => router.push('/franchise/add-member')}
                                className="inline-flex items-center rounded-full border border-transparent bg-pink-600 px-6 py-2.5 text-sm font-medium text-white shadow-lg shadow-pink-600/20 hover:bg-pink-700 transition-all transform hover:-translate-y-0.5"
                            >
                                <Plus className="-ml-1 mr-2 h-5 w-5" aria-hidden="true" />
                                Add Member
                            </button>
                        </div>
                    </div>
                )}
            </main>

            {selectedProfileForPrefs && (
                <MatchPreferencesModal
                    profile={selectedProfileForPrefs}
                    onClose={() => setSelectedProfileForPrefs(null)}
                    onSuccess={refreshProfiles}
                />
            )}
        </div>
    );
}

function CheckCircleIcon(props: any) {
    return (
        <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" /><polyline points="22 4 12 14.01 9 11.01" /></svg>
    )
}

function UserIcon(props: any) {
    return (
        <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2" /><circle cx="12" cy="7" r="4" /></svg>
    )
}
