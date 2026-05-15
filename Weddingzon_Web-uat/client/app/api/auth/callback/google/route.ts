import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import axios from 'axios';

export async function GET(request: NextRequest) {
    const { searchParams } = new URL(request.url);
    const code = searchParams.get('code');
    const error = searchParams.get('error');

    if (error) {
        return NextResponse.redirect(new URL('/login?error=' + error, request.url));
    }

    if (!code) {
        return NextResponse.redirect(new URL('/login?error=no_code', request.url));
    }

    try {
        // Exchange code for session at backend
        // Use 127.0.0.1 instead of localhost for server-side fetches to avoid IPv6 issues
        // Fallback if env is missing
        const backendUrl = process.env.NEXT_PUBLIC_API_URL || 'http://127.0.0.1:5000/api';

        // Dynamically determine the redirect_uri that was used by the client
        const origin = new URL(request.url).origin;
        const redirectUri = `${origin}/api/auth/callback/google`;

        console.log(`[DEBUG] Google Callback: calling backend at ${backendUrl}/auth/google`);

        const response = await axios.post(`${backendUrl}/auth/google`, {
            code,
            redirect_uri: redirectUri
        }, {
            headers: { 'Content-Type': 'application/json' },
            withCredentials: true // Important to receive cookies
        });

        const { user } = response.data;

        // Grab cookies from backend response
        const setCookieHeader = response.headers['set-cookie'];

        let redirectUrl = new URL('/feed', request.url);

        // Redirect Logic based on User State
        // Redirect Logic based on User State
        if (user) {
            // 1. Strict Phone Verification Check (Highest Priority)
            if (!user.is_phone_verified) {
                console.log('[DEBUG] Phone not verified. Redirecting to /signup?step=2');
                redirectUrl = new URL('/signup?step=2', request.url);
            }
            // 2. Role Selection Check
            else if (user.role === 'user') {
                console.log('[DEBUG] Role is default. Redirecting to /');
                redirectUrl = new URL('/', request.url);
            }
            // 3. Bride/Groom Check
            else if (user.role === 'bride' || user.role === 'groom') {
                if (!user.is_profile_complete) {
                    console.log('[DEBUG] Bride/Groom profile incomplete. Redirecting to /onboarding');
                    redirectUrl = new URL('/onboarding', request.url);
                } else {
                    console.log('[DEBUG] Bride/Groom profile complete. Redirecting to /feed');
                    redirectUrl = new URL('/feed', request.url);
                }
            }
            // 4. Other Roles
            else if (user.role === 'vendor') {
                if (user.vendor_details?.business_name) {
                    console.log('[DEBUG] Role is Vendor (Completed). Redirecting to /vendor/dashboard');
                    redirectUrl = new URL('/vendor/dashboard', request.url);
                } else {
                    console.log('[DEBUG] Role is Vendor (Incomplete). Redirecting to /vendor/onboarding');
                    redirectUrl = new URL('/vendor/onboarding', request.url);
                }
            }
            else if (user.role === 'franchise') {
                console.log('[DEBUG] Role is Franchise. Redirecting to /franchise');
                redirectUrl = new URL('/franchise', request.url);
            }
            else {
                console.log(`[DEBUG] Role is ${user.role}. Redirecting to /feed`);
                // Redirect to feed for other roles as well
                redirectUrl = new URL('/feed', request.url);
            }

        }

        const nextResponse = NextResponse.redirect(redirectUrl);

        // Forward cookies to the client browser
        if (setCookieHeader) {
            setCookieHeader.forEach(cookie => {
                nextResponse.headers.append('Set-Cookie', cookie);
            });
        }

        return nextResponse;

    } catch (err: any) {
        console.error('[CRITICAL] Callback Error:', err.message);
        const errorMessage = err.response?.data?.message || err.message || 'auth_failed';
        return NextResponse.redirect(new URL(`/login?error=${encodeURIComponent(errorMessage)}`, request.url));
    }
}
