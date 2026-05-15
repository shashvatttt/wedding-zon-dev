'use client';

import { useState, useEffect } from 'react';
import api from '../../services/api';
import { Check, X, Store, MapPin } from 'lucide-react';
import { useToast } from '../../contexts/ToastContext';

export default function AdminVendorsPage() {
    const { addToast } = useToast();
    const [requests, setRequests] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchRequests = async () => {
            try {
                // Fetch only pending vendors
                const res = await api.get('/admin/vendors?status=pending_approval');
                setRequests(res.data.data);
            } catch (error) {
                console.error('Failed to fetch vendor requests', error);
            } finally {
                setLoading(false);
            }
        };

        fetchRequests();
    }, []);

    const handleAction = async (id: string, action: 'approve' | 'reject') => {
        try {
            const status = action === 'approve' ? 'active' : 'rejected';
            await api.patch(`/admin/vendors/${id}/status`, { status });

            // Remove from list
            setRequests(requests.filter(req => req._id !== id));
            addToast(`Vendor ${action}d successfully`, 'success');
        } catch (error) {
            console.error(`Failed to ${action}`, error);
            addToast(`Failed to ${action} vendor`, 'error');
        }
    };

    if (loading) return <div className="p-8">Loading...</div>;

    return (
        <div className="p-6">
            <h1 className="text-2xl font-bold mb-6 flex items-center gap-2">
                <Store className="h-6 w-6" />
                Vendor Requests
            </h1>

            {requests.length === 0 ? (
                <div className="text-gray-500 italic">No pending vendor requests.</div>
            ) : (
                <div className="grid gap-4">
                    {requests.map((req) => (
                        <div key={req._id} className="bg-white p-6 rounded-lg shadow-sm border border-gray-200 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                            <div>
                                <h3 className="font-bold text-lg">{req.vendor_details?.business_name || 'No Business Name'}</h3>
                                <p className="text-gray-900 font-medium">{req.first_name} {req.last_name}</p>
                                <p className="text-gray-600">{req.email}</p>
                                <p className="text-gray-500 text-sm mt-1">Phone: {req.phone}</p>

                                {req.vendor_details?.city && (
                                    <div className="flex items-center text-sm text-gray-500 mt-2">
                                        <MapPin className="w-4 h-4 mr-1" />
                                        {req.vendor_details.city}, {req.vendor_details.state}
                                    </div>
                                )}

                                <p className="text-pink-600 text-xs font-medium uppercase mt-2 tracking-wide">Pending Approval</p>
                            </div>
                            <div className="flex gap-3 w-full md:w-auto">
                                <button
                                    onClick={() => handleAction(req._id, 'reject')}
                                    className="flex-1 md:flex-none flex items-center justify-center gap-1 px-4 py-2 border border-red-200 text-red-600 rounded-lg hover:bg-red-50 transition-colors"
                                >
                                    <X className="h-4 w-4" />
                                    Reject
                                </button>
                                <button
                                    onClick={() => handleAction(req._id, 'approve')}
                                    className="flex-1 md:flex-none flex items-center justify-center gap-1 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors shadow-sm"
                                >
                                    <Check className="h-4 w-4" />
                                    Approve
                                </button>
                            </div>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}
