import { useEffect, useState } from 'react';

export function useAppSecurity(apiKey: string) {
  const [status, setStatus] = useState({ isBlocked: false, message: '' });

  useEffect(() => {
    // Only run on the client side
    if (typeof window === 'undefined') return;

    async function checkStatus() {
      if (!apiKey) {
        console.warn("Hoocai God API Key is missing");
        return;
      }

      try {
        const res = await fetch(`/api/users/security/check?apiKey=${apiKey}`);
        const data = await res.json();
        
        if (data.isBlocked) {
          setStatus({ 
            isBlocked: true, 
            message: data.blockedMessage || data.message || 'Access Restricted' 
          });
        } else {
          setStatus({ isBlocked: false, message: '' });
        }
      } catch (error) {
        console.error("Security check failed", error);
      }
    }
    
    checkStatus();
    // Check every 5 minutes
    const interval = setInterval(checkStatus, 300000);
    return () => clearInterval(interval);
  }, [apiKey]);

  return status;
}
