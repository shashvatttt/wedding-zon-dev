import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function proxy(request: NextRequest) {
    const { pathname } = request.nextUrl;

    const accessToken = request.cookies.get('access_token')?.value;
    const refreshToken = request.cookies.get('refresh_token')?.value;
    const token = accessToken || refreshToken;

    // Debug Log
    console.log(`[Proxy] Processing: ${pathname}`);
    console.log(`[Proxy] Tokens - Access: ${!!accessToken}, Refresh: ${!!refreshToken}`);

    // Define PUBLIC paths that do NOT require authentication
    const publicPaths = [
        '/',
        '/login',
        '/signup',
        '/register',
        '/forgot-password',
        '/reset-password',
        '/verify-email',
        '/about',
        '/contact',
        '/privacy',
        '/terms',
        '/franchise/login',
        '/matrimony',
        '/explore',
        '/franchise/entry',
        '/vendor', // Vendor login selection page
        '/services', // Public vendor listing
        '/feed' // Public feed access
    ];

    // Reserved system/app segments that MUST be protected
    const reservedSegments = [
        'admin', 'api', 'chats', 'connections', 'feed', 'franchise', 
        'onboarding', 'phonebook', 'profile', 'requests', 
        'settings'
    ];

    // Check if the current path is explicitly in publicPaths
    let isPublicPath = publicPaths.some(path =>
        path === '/' ? pathname === '/' : pathname.startsWith(path)
    );

    // If not explicitly public, check if it's a root-level dynamic route (username)
    if (!isPublicPath) {
        const segments = pathname.split('/').filter(Boolean);
        // Path is like /username (single segment) and not a reserved system segment
        if (segments.length === 1 && !reservedSegments.includes(segments[0])) {
            isPublicPath = true;
            console.log(`[Proxy] Allowing public access to profile: ${pathname}`);
        }
    }

    // Bypass for static assets and API routes
    if (
        pathname.startsWith('/_next') ||
        pathname.startsWith('/api') ||
        pathname === '/favicon.ico'
    ) {
        return NextResponse.next();
    }

    if (!isPublicPath && !token) {
        console.log(`[Proxy] Redirecting unauthenticated user from ${pathname} to /`);
        return NextResponse.redirect(new URL('/', request.url));
    }

    return NextResponse.next();
}

export const config = {
    // Matcher: Match all paths except static files, api, and image optimization
    matcher: ['/((?!api|_next/static|_next/image|favicon.ico|.*\\.(?:png|jpg|jpeg|gif|webp|svg|ico|woff|woff2|ttf|otf)$).*)'],
};
