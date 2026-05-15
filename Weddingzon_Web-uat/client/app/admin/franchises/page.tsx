'use client';

import { useState, useEffect } from 'react';
import api from '../../services/api'; // Adjust path based on location
import { Check, X, Building } from 'lucide-react';
import { useToast } from '../../contexts/ToastContext';

export default function AdminFranchisesPage() {
    const { addToast } = useToast();
    const [requests, setRequests] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchRequests = async () => {
            try {
                const res = await api.get('/admin/franchises/requests');
                setRequests(res.data.data);
            } catch (error) {
                console.error('Failed to fetch requests', error);
            } finally {
                setLoading(false);
            }
        };

        fetchRequests();
    }, []);

    const handleAction = async (id: string, action: 'approve' | 'reject') => {
        try {
            const status = action === 'approve' ? 'active' : 'rejected';
            // Use correct endpoint as defined in routes: /api/admin/franchises/:id/approve
            await api.patch(`/admin/franchises/${id}/approve`, { status });

            // Remove from list
            setRequests(requests.filter(req => req._id !== id));
            addToast(`Franchise ${action}d successfully`, 'success');
        } catch (error) {
            console.error(`Failed to ${action}`, error);
            addToast(`Failed to ${action} franchise`, 'error');
        }
    };

    if (loading) return <div className="p-8">Loading...</div>;

    return (
        <div className="p-6">
            <h1 className="text-2xl font-bold mb-6 flex items-center gap-2">
                <Building className="h-6 w-6" />
                Franchise Requests
            </h1>

            {requests.length === 0 ? (
                <div className="text-gray-500 italic">No pending requests.</div>
            ) : (
                <div className="grid gap-4">
                    {requests.map((req) => (
                        <div key={req._id} className="bg-white p-6 rounded-lg shadow-sm border border-gray-200 flex justify-between items-center">
                            <div>
                                <h3 className="font-bold text-lg">{req.first_name} {req.last_name}</h3>
                                <p className="text-gray-600">{req.email}</p>
                                <p className="text-gray-500 text-sm mt-1">Phone: {req.phone}</p>
                                <p className="text-orange-600 text-xs font-medium uppercase mt-2 tracking-wide">Pending Approval</p>
                            </div>
                            <div className="flex gap-3">
                                <button
                                    onClick={() => handleAction(req._id, 'reject')}
                                    className="flex items-center gap-1 px-4 py-2 border border-red-200 text-red-600 rounded-lg hover:bg-red-50 transition-colors"
                                >
                                    <X className="h-4 w-4" />
                                    Reject
                                </button>
                                <button
                                    onClick={() => handleAction(req._id, 'approve')}
                                    className="flex items-center gap-1 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors shadow-sm"
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
