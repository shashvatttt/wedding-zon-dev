
import type { Metadata, ResolvingMetadata } from 'next';
import ClientProfile from './ClientProfile';

// Helper to fetch user data for metadata
// Note: This fetch runs on the Next.js server, so it needs the full backend URL.
// We use the same env var as the rewrites, or default to localhost:5000.
async function fetchUser(username: string) {
    const serverUrl = process.env.SERVER_URL || (process.env.NEXT_PUBLIC_API_URL ? process.env.NEXT_PUBLIC_API_URL.replace(/\/api$/, '') : 'http://127.0.0.1:5000');
    try {
        const res = await fetch(`${serverUrl}/api/users/${username}/public-preview`, {
            next: { revalidate: 60 } // Revalidate metadata every minute also
        });
        if (!res.ok) return null;
        return res.json();
    } catch (e) {
        console.error('Error fetching user metadata:', e);
        return null;
    }
}

export async function generateMetadata(
    { params }: { params: Promise<{ username: string }> },
    parent: ResolvingMetadata
): Promise<Metadata> {
    // Await params for Next.js 15+
    const { username } = await params;

    // Fetch data
    const user = await fetchUser(username);

    // Fallback if user not found
    if (!user) {
        return {
            title: 'User Not Found | WeddingZon',
            description: 'The requested profile could not be found.',
        };
    }

    const fullName = [user.first_name, user.last_name].filter(Boolean).join(' ') || 'User';
    const description = user.bio || `Connect with ${fullName} on WeddingZon, the premier matrimony platform.`;
    const profilePhoto = user.profilePhoto || 'https://dev.d34g4kpybwb3xb.amplifyapp.com/default-og.png'; // Fallback image

    return {
        title: `${fullName} | WeddingZon`,
        description: `Check out ${fullName}'s profile on WeddingZon.`,

        openGraph: {
            type: 'profile',
            title: `${fullName} on WeddingZon `,
            description: description,
            url: `https://dev.d34g4kpybwb3xb.amplifyapp.com/${username}`,
            siteName: 'WeddingZon',
            images: [
                {
                    url: profilePhoto,
                    width: 800,
                    height: 800,
                    alt: `${fullName}'s Profile Photo`,
                },
            ],
            username: username,
            firstName: user.first_name,
            lastName: user.last_name,
        },

        twitter: {
            card: 'summary',
            title: `${fullName} on WeddingZon`,
            description: description,
            images: [profilePhoto],
        },

        // Apple Smart App Banner
        // Note: This meta tag is usually handled via 'other' in Next.js metadata is working
        other: {
            'apple-itunes-app': 'app-id=YOUR_IOS_APP_ID, app-argument=weddingzon://profile/' + username,
            'google-play-app': 'app-id=com.weddingzon.app', // Custom meta tag for Android smart banners if we implement script
        }
    };
}

export default function Page({ params }: { params: Promise<{ username: string }> }) {
    return <ClientProfile params={params} />;
}
