'use client';

import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';

import { en } from '@/app/i18n/en';

type Language = 'en' | 'hi' | 'pa';

interface LanguageContextType {
    language: Language;
    setLanguage: (lang: Language) => void;
    t: (key: string, params?: Record<string, any>) => string;
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

export const LanguageProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [language, setLanguageState] = useState<Language>('en');

    useEffect(() => {
        const savedLang = localStorage.getItem('language') as Language;
        if (savedLang && ['en', 'hi', 'pa'].includes(savedLang)) {
            setLanguageState(savedLang);
        }
    }, []);

    const setLanguage = (lang: Language) => {
        setLanguageState(lang);
        localStorage.setItem('language', lang);
        
        // Trigger Google Translate if it's available
        if (typeof window !== 'undefined' && window.triggerGoogleTranslate) {
            window.triggerGoogleTranslate(lang);
        } else if (typeof document !== 'undefined') {
            // Fallback: set cookie directly if script haven't loaded trigger function yet
            const cookieValue = `/en/${lang}`;
            document.cookie = `googtrans=${cookieValue}; path=/;`;
            document.cookie = `googtrans=${cookieValue}; path=/; domain=.${window.location.hostname};`;
        }

        // Auto-refresh to apply translations
        if (typeof window !== 'undefined') {
            window.location.reload();
        }
    };

    // Effect to apply language on initial load if trigger becomes available later
    useEffect(() => {
        if (window.triggerGoogleTranslate) {
            // Avoid triggering on mount if it's already 'en' to prevent potential jitter
            if (language !== 'en') {
                window.triggerGoogleTranslate(language);
            }
        }
    }, [language]);

    // Dummy t function during transition - returns the key or the last part of the key
    // This prevents immediate breakage in files not yet refactored.
    const t = (key: string): string => {
        return key; 
    };

    return (
        <LanguageContext.Provider value={{ language, setLanguage, t }}>
            {children}
        </LanguageContext.Provider>
    );
};

export const useLanguage = () => {
    const context = useContext(LanguageContext);
    if (context === undefined) {
        throw new Error('useLanguage must be used within a LanguageProvider');
    }
    return context;
};
