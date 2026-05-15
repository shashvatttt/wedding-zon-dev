'use client';

import React, { useState } from 'react';
import { useLanguage } from '@/app/context/LanguageContext';
import { Globe, ChevronDown } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

export default function LanguageSwitcher({ className = '', variant = 'default' }: { className?: string, variant?: 'default' | 'transparent' }) {
    const { language, setLanguage } = useLanguage();
    const [isOpen, setIsOpen] = useState(false);

    const languages = [
        { code: 'en', name: 'English' },
        { code: 'hi', name: 'हिन्दी' },
        { code: 'pa', name: 'ਪੰਜਾਬੀ' },
    ];

    const baseStyles = "flex items-center gap-1.5 transition-colors font-medium text-sm px-3 py-1.5 rounded-full shadow-sm hover:shadow-md";
    const defaultStyles = "text-gray-700 hover:text-[#EF2F55] bg-white/50 backdrop-blur-sm border border-gray-100";
    const transparentStyles = "text-white hover:bg-white/20 bg-white/10 backdrop-blur-md border border-white/20";

    return (
        <div className={`relative ${className}`}>
            <button
                onClick={() => setIsOpen(!isOpen)}
                className={`${baseStyles} ${variant === 'transparent' ? transparentStyles : defaultStyles}`}
            >
                <Globe className="w-4 h-4" />
                <span className="uppercase notranslate">{language}</span>
                <ChevronDown className="w-3 h-3" />
            </button>

            <AnimatePresence>
                {isOpen && (
                    <>
                        <div className="fixed inset-0 z-40" onClick={() => setIsOpen(false)} />
                        <motion.div
                            initial={{ opacity: 0, y: 10, scale: 0.95 }}
                            animate={{ opacity: 1, y: 0, scale: 1 }}
                            exit={{ opacity: 0, y: 10, scale: 0.95 }}
                            className="absolute top-full right-0 mt-2 w-32 bg-white rounded-xl shadow-xl border border-gray-100 py-2 z-50 overflow-y-auto max-h-[70vh]"
                        >
                            {languages.map((lang) => (
                                <button
                                    key={lang.code}
                                    onClick={() => {
                                        setLanguage(lang.code as any);
                                        if (typeof window !== 'undefined' && window.triggerGoogleTranslate) {
                                            window.triggerGoogleTranslate(lang.code);
                                        }
                                        setIsOpen(false);
                                    }}
                                    className={`w-full text-left px-4 py-2 text-sm hover:bg-rose-50 hover:text-rose-600 transition-colors flex items-center justify-between ${language === lang.code ? 'text-rose-600 font-bold bg-rose-50/50' : 'text-gray-700'
                                        }`}
                                >
                                    <span className="notranslate">{lang.name}</span>
                                    {language === lang.code && <div className="w-1.5 h-1.5 rounded-full bg-rose-600" />}
                                </button>
                            ))}
                        </motion.div>
                    </>
                )}
            </AnimatePresence>
        </div>
    );
}
