'use client';

import React, { useState, useEffect } from 'react';
import { ChevronLeft, ChevronRight, Calendar as CalendarIcon, Info, X, Check } from 'lucide-react';
import { format, addMonths, subMonths, startOfMonth, endOfMonth, startOfWeek, endOfWeek, eachDayOfInterval, isSameMonth, isSameDay, addDays, isBefore, startOfDay } from 'date-fns';
import { motion, AnimatePresence } from 'framer-motion';
import api from '@/app/services/api';
import { useToast } from '@/app/contexts/ToastContext';
import { Button } from '@/components/ui/button';

interface AvailabilityEntry {
    date: Date | string;
    status: 'available' | 'booked' | 'unavailable';
    note?: string;
}

interface VendorCalendarProps {
    vendorId: string;
    initialAvailability?: AvailabilityEntry[];
    isEditable?: boolean;
    onUpdate?: (availability: AvailabilityEntry[]) => void;
}

export default function VendorCalendar({ vendorId, initialAvailability = [], isEditable = false, onUpdate }: VendorCalendarProps) {
    const [currentMonth, setCurrentMonth] = useState(new Date());
    const [availability, setAvailability] = useState<AvailabilityEntry[]>(initialAvailability);
    const [selectedDate, setSelectedDate] = useState<Date | null>(null);
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [note, setNote] = useState('');
    const [status, setStatus] = useState<'booked' | 'unavailable'>('booked');
    const [loading, setLoading] = useState(false);
    const { addToast } = useToast();

    useEffect(() => {
        if (initialAvailability.length > 0) {
            setAvailability(initialAvailability);
        }
    }, [initialAvailability]);

    const nextMonth = () => setCurrentMonth(addMonths(currentMonth, 1));
    const prevMonth = () => setCurrentMonth(subMonths(currentMonth, 1));

    const onDateClick = (day: Date) => {
        if (!isEditable) return;

        // Prevent selecting past dates
        if (isBefore(day, startOfDay(new Date()))) {
            return;
        }

        const existing = availability.find(a => isSameDay(new Date(a.date), day));
        if (existing) {
            setNote(existing.note || '');
            setStatus(existing.status as any);
        } else {
            setNote('');
            setStatus('booked');
        }

        setSelectedDate(day);
        setIsModalOpen(true);
    };

    const handleUpdateAvailability = async (action: 'add' | 'remove') => {
        if (!selectedDate) return;

        setLoading(true);
        try {
            const res = await api.patch('/vendor-features/availability', {
                date: selectedDate,
                status: action === 'add' ? status : 'available',
                note: action === 'add' ? note : '',
                action: action === 'remove' ? 'remove' : 'add'
            });

            if (res.data.success) {
                setAvailability(res.data.data);
                if (onUpdate) onUpdate(res.data.data);
                addToast(action === 'add' ? 'Availability marked' : 'Availability cleared', 'success');
                setIsModalOpen(false);
            }
        } catch (error: any) {
            addToast(error.response?.data?.message || 'Failed to update availability', 'error');
        } finally {
            setLoading(false);
        }
    };

    const renderHeader = () => {
        return (
            <div className="flex items-center justify-between mb-6">
                <h2 className="text-xl font-black text-gray-900 flex items-center gap-2">
                    <CalendarIcon className="w-6 h-6 text-[#EF2F55]" />
                    {format(currentMonth, 'MMMM yyyy')}
                </h2>
                <div className="flex gap-2">
                    <button onClick={prevMonth} className="p-2 hover:bg-gray-100 rounded-full transition-colors text-gray-600">
                        <ChevronLeft className="w-5 h-5" />
                    </button>
                    <button onClick={nextMonth} className="p-2 hover:bg-gray-100 rounded-full transition-colors text-gray-600">
                        <ChevronRight className="w-5 h-5" />
                    </button>
                </div>
            </div>
        );
    };

    const renderDays = () => {
        const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        return (
            <div className="grid grid-cols-7 mb-2">
                {days.map(day => (
                    <div key={day} className="text-center text-[10px] font-black uppercase tracking-widest text-gray-400 py-2">
                        {day}
                    </div>
                ))}
            </div>
        );
    };

    const renderCells = () => {
        const monthStart = startOfMonth(currentMonth);
        const monthEnd = endOfMonth(monthStart);
        const startDate = startOfWeek(monthStart);
        const endDate = endOfWeek(monthEnd);

        const calendarDays = eachDayOfInterval({
            start: startDate,
            end: endDate,
        });

        return (
            <div className="grid grid-cols-7 gap-1">
                {calendarDays.map((day: Date) => {
                    const isSelected = selectedDate && isSameDay(day, selectedDate);
                    const isCurrentMonth = isSameMonth(day, monthStart);
                    const isToday = isSameDay(day, new Date());
                    const isPast = isBefore(day, startOfDay(new Date()));

                    const availabilityEntry = availability.find(a => isSameDay(new Date(a.date), day));
                    const isBooked = availabilityEntry?.status === 'booked';
                    const isUnavailable = availabilityEntry?.status === 'unavailable';

                    return (
                        <motion.div
                            whileHover={!isPast && isEditable ? { scale: 1.05 } : {}}
                            whileTap={!isPast && isEditable ? { scale: 0.95 } : {}}
                            key={day.toString()}
                            onClick={() => onDateClick(day)}
                            className={`
                                relative aspect-square flex flex-col items-center justify-center rounded-2xl cursor-pointer transition-all border
                                ${!isCurrentMonth ? 'text-gray-300 border-transparent' : 'text-gray-700 border-transparent'}
                                ${isToday ? 'ring-2 ring-pink-500/20' : ''}
                                ${isBooked ? 'bg-[#ff204f] border-[#ff204f] text-white shadow-sm shadow-rose-200' : ''}
                                ${isUnavailable ? 'bg-slate-800 border-slate-800 text-white shadow-sm' : ''}
                                ${!isBooked && !isUnavailable && isCurrentMonth ? 'bg-[#90EE90]/40 border-[#90EE90]/20 text-green-900 hover:bg-[#90EE90]/50' : ''}
                                ${!isBooked && !isUnavailable && !isCurrentMonth ? 'bg-gray-50/30' : ''}
                                ${isPast ? 'opacity-40 cursor-not-allowed grayscale-[0.5]' : ''}
                            `}
                        >
                            <span className={`text-sm font-black ${isBooked || isUnavailable ? 'text-white' : ''}`}>
                                {format(day, 'd')}
                            </span>
                            {isBooked && <div className="absolute bottom-2 w-1.5 h-1.5 bg-white rounded-full transition-all" />}
                            {isUnavailable && <div className="absolute bottom-2 w-1.5 h-1.5 bg-white/70 rounded-full transition-all" />}
                            {availabilityEntry?.note && (
                                <div className="absolute -top-1 -right-1">
                                    <div className="w-2.5 h-2.5 bg-blue-500 rounded-full border-2 border-white" />
                                </div>
                            )}
                        </motion.div>
                    );
                })}
            </div>
        );
    };

    return (
        <div className="bg-white p-6 rounded-[32px] shadow-xl border border-rose-100">
            {renderHeader()}
            {renderDays()}
            {renderCells()}

            {/* Legend */}
            <div className="mt-6 flex flex-wrap gap-4 pt-6 border-t border-rose-50">
                <div className="flex items-center gap-2">
                    <div className="w-4 h-4 bg-[#ff204f] border border-[#ff204f] rounded-lg shadow-sm" />
                    <span className="text-xs font-black text-gray-600 uppercase tracking-wider">Booked</span>
                </div>
                <div className="flex items-center gap-2">
                    <div className="w-4 h-4 bg-slate-800 border border-slate-800 rounded-lg shadow-sm" />
                    <span className="text-xs font-black text-gray-600 uppercase tracking-wider">Unavailable</span>
                </div>
                <div className="flex items-center gap-2">
                    <div className="w-4 h-4 bg-[#90EE90]/40 border border-[#90EE90]/20 rounded-lg" />
                    <span className="text-xs font-black text-gray-600 uppercase tracking-wider">Available</span>
                </div>
            </div>

            {/* Edit Modal */}
            <AnimatePresence>
                {isModalOpen && selectedDate && (
                    <div className="fixed inset-0 z-[110] flex items-center justify-center p-4">
                        <motion.div
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            exit={{ opacity: 0 }}
                            onClick={() => setIsModalOpen(false)}
                            className="absolute inset-0 bg-black/60 backdrop-blur-sm"
                        />
                        <motion.div
                            initial={{ opacity: 0, scale: 0.95, y: 20 }}
                            animate={{ opacity: 1, scale: 1, y: 0 }}
                            exit={{ opacity: 0, scale: 0.95, y: 20 }}
                            className="relative w-full max-w-[400px] bg-white rounded-[32px] shadow-2xl overflow-hidden"
                        >
                            <div className="bg-[#EF2F55] p-6 text-white">
                                <h3 className="text-xl font-black">{format(selectedDate, 'do MMMM, yyyy')}</h3>
                                <p className="text-white/80 text-xs font-bold uppercase tracking-widest">Update Availability</p>
                            </div>

                            <div className="p-6 space-y-6">
                                <div className="space-y-3">
                                    <label className="text-[10px] font-black uppercase tracking-widest text-gray-400">Status</label>
                                    <div className="grid grid-cols-2 gap-2">
                                        <button
                                            onClick={() => setStatus('booked')}
                                            className={`py-3 rounded-2xl font-bold text-sm border-2 transition-all ${status === 'booked' ? 'border-[#EF2F55] bg-rose-50 text-[#EF2F55]' : 'border-gray-100 text-gray-500'}`}
                                        >
                                            Booked
                                        </button>
                                        <button
                                            onClick={() => setStatus('unavailable')}
                                            className={`py-3 rounded-2xl font-bold text-sm border-2 transition-all ${status === 'unavailable' ? 'border-gray-900 bg-gray-50 text-gray-900' : 'border-gray-100 text-gray-500'}`}
                                        >
                                            Unavailable
                                        </button>
                                    </div>
                                </div>

                                <div className="space-y-3">
                                    <label className="text-[10px] font-black uppercase tracking-widest text-gray-400">Note (Optional)</label>
                                    <textarea
                                        value={note}
                                        onChange={(e) => setNote(e.target.value)}
                                        placeholder="Add a event detail or note..."
                                        className="w-full p-4 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-[#EF2F55] text-sm font-medium"
                                        rows={3}
                                    />
                                </div>

                                <div className="flex gap-3">
                                    <Button
                                        variant="outline"
                                        className="flex-1 rounded-2xl py-6 font-bold"
                                        onClick={() => handleUpdateAvailability('remove')}
                                        disabled={loading}
                                    >
                                        Clear
                                    </Button>
                                    <Button
                                        className="flex-1 bg-[#EF2F55] hover:bg-rose-700 text-white rounded-2xl py-6 font-bold"
                                        onClick={() => handleUpdateAvailability('add')}
                                        disabled={loading}
                                    >
                                        {loading ? 'Saving...' : 'Save'}
                                    </Button>
                                </div>
                            </div>
                        </motion.div>
                    </div>
                )}
            </AnimatePresence>
        </div>
    );
}
