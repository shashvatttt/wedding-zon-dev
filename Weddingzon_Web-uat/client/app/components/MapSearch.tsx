'use client';

import { useState, useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup, Circle, useMap } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import 'leaflet-defaulticon-compatibility';
import 'leaflet-defaulticon-compatibility/dist/leaflet-defaulticon-compatibility.css';
import { useRouter } from 'next/navigation';

interface User {
    _id: string;
    username: string;
    first_name: string;
    dob?: string;
    gender: string;
    religion: string;
    occupation: string;
    profilePhoto?: string;
    location?: {
        coordinates: [number, number]; // [lng, lat]
    };
    about_me?: string;
}

interface MapSearchProps {
    users: User[];
    center: [number, number]; // [lat, lng]
    radius: number; // in km
}

// Helper component to programmatically move the map
function MapRecenter({ center }: { center: [number, number] }) {
    const map = useMap();
    useEffect(() => {
        map.setView(center);
    }, [center, map]);
    return null;
}

export default function MapSearch({ users, center, radius }: MapSearchProps) {
    const router = useRouter();

    const calculateAge = (dobString?: string) => {
        if (!dobString) return 'N/A';
        const birthDate = new Date(dobString);
        const ageDifMs = Date.now() - birthDate.getTime();
        const ageDate = new Date(ageDifMs);
        return Math.abs(ageDate.getUTCFullYear() - 1970);
    };

    return (
        <MapContainer center={center} zoom={11} scrollWheelZoom={true} style={{ height: '100%', width: '100%' }}>
            <MapRecenter center={center} />
            <TileLayer
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            />

            {/* User's Radius Circle */}
            <Circle center={center} radius={radius * 1000} pathOptions={{ fillColor: 'blue', fillOpacity: 0.1, color: 'blue', weight: 1 }} />

            {/* Current Location Marker (You) */}
            <Marker position={center}>
                <Popup>
                    <div className="text-center font-bold">You are here</div>
                </Popup>
            </Marker>

            {/* Nearby Users */}
            {users.map((user) => {
                if (!user.location?.coordinates) return null;
                // GeoJSON is [lng, lat], Leaflet wants [lat, lng]
                const position: [number, number] = [user.location.coordinates[1], user.location.coordinates[0]];

                return (
                    <Marker key={user._id} position={position}>
                        <Popup>
                            <div className="w-48 p-2">
                                <div className="flex items-center gap-3 mb-2">
                                    <div className="h-12 w-12 rounded-full overflow-hidden bg-gray-200">
                                        <img
                                            src={user.profilePhoto || '/placeholder-user.png'}
                                            alt={user.first_name}
                                            className="h-full w-full object-cover"
                                        />
                                    </div>
                                    <div>
                                        <h3 className="font-bold text-base text-gray-900">{user.first_name}, {calculateAge(user.dob)}</h3>
                                        <p className="text-xs text-gray-500">{user.occupation}</p>
                                    </div>
                                </div>
                                <p className="text-xs text-gray-600 line-clamp-2 mb-2">{user.about_me || "No bio available."}</p>
                                <button
                                    onClick={() => router.push(`/${user.username}`)}
                                    className="w-full bg-indigo-600 text-white text-xs py-1.5 rounded hover:bg-indigo-700 transition"
                                >
                                    View Profile
                                </button>
                            </div>
                        </Popup>
                    </Marker>
                );
            })}
        </MapContainer>
    );
}
