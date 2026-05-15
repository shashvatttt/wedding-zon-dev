'use client';

import { useEffect } from 'react';

declare global {
  interface Window {
    googleTranslateElementInit: () => void;
    google: any;
    triggerGoogleTranslate: (langCode: string) => void;
  }
}

export default function GoogleTranslateScript() {
    useEffect(() => {
        // Function to set the Google Translate cookie
        const setTransCookie = (langCode: string) => {
            const cookieValue = `/en/${langCode}`;
            document.cookie = `googtrans=${cookieValue}; path=/;`;
            document.cookie = `googtrans=${cookieValue}; path=/; domain=.${window.location.hostname};`;
            // Also try with no subdomain/common domains if hostname is complex, but hostname is usually enough
        };

        const googleTranslateElementInit = () => {
            if (window.google && window.google.translate) {
                new window.google.translate.TranslateElement(
                    {
                        pageLanguage: 'en',
                        includedLanguages: 'hi,pa,en',
                        layout: window.google.translate.TranslateElement.InlineLayout.SIMPLE,
                        autoDisplay: false,
                    },
                    'google_translate_element'
                );
            }
        };

        window.googleTranslateElementInit = googleTranslateElementInit;

        if (!document.querySelector('script[src*="translate.google.com"]')) {
            const addScript = document.createElement('script');
            addScript.src = '//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit';
            addScript.async = true;
            document.body.appendChild(addScript);
        }

        // Global function to trigger translation programmatically
        window.triggerGoogleTranslate = (langCode: string) => {
            // Only set cookie if langCode is not 'en' (default)
            if (langCode !== 'en') {
                setTransCookie(langCode);
            } else {
                // Clear cookies for 'en'
                document.cookie = "googtrans=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
                document.cookie = `googtrans=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/; domain=.${window.location.hostname};`;
            }

            // Try to find the combo box and change it in real-time
            const select = document.querySelector('.goog-te-combo') as HTMLSelectElement;
            if (select) {
                if (select.value !== langCode) {
                    select.value = langCode;
                    select.dispatchEvent(new Event('change'));
                }
            }
            // NO RELOAD here! It causes infinite loops if the widget is slow to load.
        };

        // Aggressive interval to keep banner hidden and layout clean
        const interval = setInterval(() => {
            const banner = document.querySelector('.goog-te-banner-frame') as HTMLElement;
            if (banner) {
                banner.style.display = 'none';
                banner.style.visibility = 'hidden';
                banner.style.height = '0';
            }
            
            // Fix body and html offsets that Google Translate often forces
            if (document.body.style.top !== '0px' && document.body.style.top !== '') {
                document.body.style.top = '0px';
            }
            if (document.documentElement.style.top !== '0px' && document.documentElement.style.top !== '') {
                document.documentElement.style.top = '0px';
            }

            // Clean up skiptranslate classes if they affect layout
            const skiptranslate = document.querySelectorAll('.skiptranslate');
            skiptranslate.forEach((el: any) => {
                if (el.id !== 'google_translate_element' && !el.classList.contains('goog-te-combo')) {
                    el.style.display = 'none';
                }
            });
        }, 500);

        return () => clearInterval(interval);
    }, []);

    return (
        <div className="google-translate-headless">
            <style jsx global>{`
                /* Completely hide the widget and all its clones/banners/scripts UI */
                #google_translate_element {
                    display: none !important;
                }
                .goog-te-banner-frame,
                .goog-te-banner,
                #goog-gt-tt,
                .goog-te-balloon-frame,
                .goog-te-menu-value,
                .goog-te-gadget-icon,
                .goog-te-gadget-simple span {
                    display: none !important;
                    visibility: hidden !important;
                }
                .skiptranslate:not(.goog-te-combo) {
                    display: none !important;
                }
                body {
                    top: 0 !important;
                    position: static !important;
                }
                .goog-text-highlight {
                    background-color: transparent !important;
                    border: none !important;
                    box-shadow: none !important;
                }
            `}</style>
            <div id="google_translate_element" style={{ position: 'absolute', top: '-9999px', left: '-9999px' }} />
        </div>
    );
}
