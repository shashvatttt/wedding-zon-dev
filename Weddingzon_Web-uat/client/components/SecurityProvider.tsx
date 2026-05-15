'use client';

import React from 'react';
import { useAppSecurity } from '../app/hooks/useAppSecurity';

interface SecurityProviderProps {
  children: React.ReactNode;
}

const SecurityProvider: React.FC<SecurityProviderProps> = ({ children }) => {
  const [mounted, setMounted] = React.useState(false);
  const apiKey = process.env.NEXT_PUBLIC_HOOCAI_GOD_API_KEY || '';
  const { isBlocked, message } = useAppSecurity(apiKey);

  React.useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) {
    return <>{children}</>;
  }

  if (isBlocked) {
    return (
      <div 
        style={{
          height: '100vh',
          width: '100vw',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          backgroundColor: '#f8f9fa',
          color: '#343a40',
          fontFamily: 'sans-serif',
          textAlign: 'center',
          padding: '20px',
          position: 'fixed',
          top: 0,
          left: 0,
          zIndex: 999999
        }}
      >
        <div style={{
          backgroundColor: '#ffffff',
          padding: '40px',
          borderRadius: '12px',
          boxShadow: '0 10px 25px rgba(0,0,0,0.1)',
          maxWidth: '500px'
        }}>
          <h1 style={{ color: '#dc3545', marginBottom: '20px' }}>Access Restricted</h1>
          <p style={{ fontSize: '18px', lineHeight: '1.6' }}>{message || 'Your access to this application has been restricted.'}</p>
          <div style={{ marginTop: '30px', borderTop: '1px solid #dee2e6', paddingTop: '20px', fontSize: '14px', color: '#6c757d' }}>
            Reference: Hoocai God Security
          </div>
        </div>
      </div>
    );
  }

  return <>{children}</>;
};

export default SecurityProvider;
