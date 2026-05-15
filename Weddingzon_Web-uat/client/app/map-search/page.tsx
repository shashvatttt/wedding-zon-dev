'use client';

import { useState, useEffect, Suspense } from 'react';
import dynamic from 'next/dynamic';
import { useRouter, useSearchParams } from 'next/navigation';
import api from '../services/api';
import { MapPin, Navigation } from 'lucide-react';
import { useToast } from '../contexts/ToastContext';

// Dynamically import Map to avoid SSR issues with Leaflet
const MapSearch = dynamic(() => import('../components/MapSearch'), {
    ssr: false,
    loading: () => {
        return <div className="h-full w-full flex items-center justify-center bg-gray-100">Loading map...</div>;
    }
});

function MapSearchContent() {
    const router = useRouter();
    const { addToast } = useToast();
    const [center, setCenter] = useState<[number, number] | null>(null);
    const [radius, setRadius] = useState(50);
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(false);
    const [locationAccess, setLocationAccess] = useState<'granted' | 'denied' | 'prompt'>('prompt');
    const [searchQuery, setSearchQuery] = useState('');

    const searchParams = useSearchParams();
    const viewAs = searchParams.get('viewAs');

    useEffect(() => {
        // Try to get location on mount
        getParamsAndFetch();
    }, []);

    const getParamsAndFetch = () => {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    const { latitude, longitude } = position.coords;
                    setCenter([latitude, longitude]);
                    setLocationAccess('granted');
                    fetchNearbyUsers(latitude, longitude, radius);
                    updateUserLocation(latitude, longitude);
                },
                (error) => {
                    console.error("Location error", error);
                    setLocationAccess('denied');
                    addToast("Location access is required to find nearby matches", 'error');
                    // Default to India center or some fallback? 
                    // Let's set a default but show empty or ask for perm.
                    setCenter([20.5937, 78.9629]); // India center
                }
            );
        } else {
            addToast("Geolocation is not supported by this browser", 'error');
        }
    };

    const updateUserLocation = async (lat: number, lng: number) => {
        try {
            await api.patch('/users/location', { latitude: lat, longitude: lng });
        } catch (error) {
            console.error('Failed to update location', error);
        }
    };

    const fetchNearbyUsers = async (lat: number, lng: number, rad: number) => {
        setLoading(true);
        try {
            const res = await api.get('/users/nearby', {
                params: { latitude: lat, longitude: lng, radius: rad, viewAs }
            });
            setUsers(res.data.data || []);
        } catch (error) {
            console.error('Failed to fetch nearby users', error);
            addToast("Failed to load nearby matches", 'error');
        } finally {
            setLoading(false);
        }
    };

    const handleLocationSearch = async () => {
        if (!searchQuery.trim()) return;

        setLoading(true);
        try {
            // Nominatim requires User-Agent. Browser sets it, but we add limit and accept-language.
            const res = await fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(searchQuery)}&limit=1`, {
                headers: {
                    'Accept-Language': 'en-US,en;q=0.9',
                }
            });

            if (!res.ok) {
                throw new Error(`Geocoding failed: ${res.status}`);
            }

            const data = await res.json();

            if (data && data.length > 0) {
                const { lat, lon } = data[0];
                const newLat = parseFloat(lat);
                const newLng = parseFloat(lon);

                setCenter([newLat, newLng]);
                fetchNearbyUsers(newLat, newLng, radius);
                addToast(`Moved to ${searchQuery}`, 'success');
            } else {
                addToast("Location not found", 'error');
            }
        } catch (error: any) {
            console.error('Geocoding error:', error);
            addToast(`Search failed: ${error.message || "Unknown error"}`, 'error');
        } finally {
            setLoading(false);
        }
    };

    const handleRadiusChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        setRadius(Number(e.target.value));
    };

    const handleSearch = () => {
        if (center) {
            fetchNearbyUsers(center[0], center[1], radius);
        }
    };

    if (!center) return <div className="h-screen flex items-center justify-center">Requesting location access...</div>;

    return (
        <div className="h-screen flex flex-col pt-16"> {/* Adjust pt-16 based on your Navbar height */}
            {/* Control Bar */}
            <div className="bg-white shadow-sm p-4 z-10 flex flex-wrap gap-4 items-center justify-between border-b">
                <div className="flex items-center gap-2">
                    <div className="bg-indigo-100 p-2 rounded-full">
                        <MapPin className="h-5 w-5 text-indigo-600" />
                    </div>
                    <div>
                        <h1 className="text-lg font-bold text-gray-900">Nearby Matches</h1>
                        <p className="text-xs text-gray-500">{users.length} users found within {radius}km</p>
                    </div>
                </div>

                <div className="flex items-center gap-4 flex-1 max-w-md">
                    <label className="text-sm font-medium text-gray-700 whitespace-nowrap">Radius: {radius}km</label>
                    <input
                        type="range"
                        min="5"
                        max="500"
                        value={radius}
                        onChange={handleRadiusChange}
                        onMouseUp={handleSearch} // Trigger search on release
                        onTouchEnd={handleSearch}
                        className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer"
                    />
                </div>

                <div className="flex items-center gap-2">
                    <input
                        type="text"
                        placeholder="Search for a city..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        onKeyDown={(e) => e.key === 'Enter' && handleLocationSearch()}
                        className="border border-gray-300 rounded-md px-3 py-2 text-sm text-black focus:outline-none focus:ring-2 focus:ring-indigo-500 w-40 sm:w-auto"
                    />
                    <button
                        onClick={handleLocationSearch}
                        className="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-md text-sm font-medium transition"
                    >
                        Search
                    </button>
                </div>

                <button
                    onClick={getParamsAndFetch}
                    className="flex items-center gap-2 px-4 py-2 bg-gray-100 hover:bg-gray-200 text-gray-800 rounded-md text-sm font-medium transition"
                >
                    <Navigation className="h-4 w-4" />
                    Recenter
                </button>
            </div>

            {/* Content Area: Map + Sidebar */}
            <div className="flex-1 flex overflow-hidden">
                {/* Sidebar List (Hidden on Mobile unless toggled? For now, hidden on very small, visible on md) */}
                <div className="w-80 border-r bg-white overflow-y-auto hidden md:block z-10 shadow-lg">
                    <div className="p-4 border-b bg-gray-50">
                        <h2 className="font-semibold text-gray-700">Matches List</h2>
                        <p className="text-xs text-gray-500">Sorted by proximity</p>
                    </div>
                    {loading ? (
                        <div className="p-8 text-center text-gray-400">Loading...</div>
                    ) : users.length === 0 ? (
                        <div className="p-8 text-center text-gray-400">No matches found in this area</div>
                    ) : (
                        <div className="divide-y">
                            {users.map((user: any) => (
                                <div
                                    key={user._id}
                                    className="p-4 hover:bg-gray-50 transition cursor-pointer flex gap-3 items-start"
                                    onClick={() => router.push(`/${user.username}`)}
                                >
                                    <div className="w-12 h-12 rounded-full bg-gray-200 overflow-hidden flex-shrink-0">
                                        <img src={user.profilePhoto || '/default-avatar.png'} alt={user.first_name} className="w-full h-full object-cover" />
                                    </div>
                                    <div className="flex-1 min-w-0">
                                        <div className="flex justify-between items-baseline mb-1">
                                            <h3 className="font-bold text-gray-900 truncate">{user.first_name || "User"}</h3>
                                            <span className="text-xs font-medium text-emerald-600 whitespace-nowrap">
                                                {user.distance ? `${(user.distance / 1000).toFixed(1)}km away` : "Very near"}
                                            </span>
                                        </div>
                                        <p className="text-xs text-gray-500 truncate">{user.occupation || "Member"}</p>
                                        <p className="text-xs text-gray-400 mt-1 line-clamp-1">{user.about_me}</p>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </div>

                {/* Map View */}
                <div className="flex-1 relative">
                    {locationAccess === 'denied' && (
                        <div className="absolute inset-0 z-50 bg-black/50 flex items-center justify-center">
                            <div className="bg-white p-6 rounded-lg shadow-xl max-w-sm text-center">
                                <MapPin className="h-12 w-12 text-red-500 mx-auto mb-3" />
                                <h3 className="text-lg font-bold text-gray-900 mb-2">Location Access Denied</h3>
                                <p className="text-gray-600 mb-4">Please enable location services in your browser settings to see nearby matches.</p>
                                <button onClick={getParamsAndFetch} className="w-full bg-indigo-600 text-white py-2 rounded-md font-medium">Retry</button>
                            </div>
                        </div>
                    )}
                    <MapSearch users={users} center={center} radius={radius} />
                </div>
            </div>
        </div>
    );
}

export default function MapSearchPage() {
    return (
        <Suspense fallback={<div className="h-screen flex items-center justify-center">Loading...</div>}>
            <MapSearchContent />
        </Suspense>
    );
}
