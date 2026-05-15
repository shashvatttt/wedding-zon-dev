import type { Metadata } from "next";
import { Playfair_Display, Lato } from "next/font/google";
import "./globals.css";

import { Providers } from "./providers";
import { ToastProvider } from "./contexts/ToastContext";
import SecurityProvider from "@/components/SecurityProvider";

const playfair = Playfair_Display({
  variable: "--font-playfair",
  subsets: ["latin"],
});

const lato = Lato({
  variable: "--font-lato",
  weight: ["100", "300", "400", "700", "900"],
  subsets: ["latin"],
});



export const metadata: Metadata = {
  title: "WeddingZon",
  description: "Your Wedding, Your Way",
  other: {
    'apple-itunes-app': 'app-id=6740615569, app-argument=https://dev.d34g4kpybwb3xb.amplifyapp.com', // Replace App ID when available
    'google-play-app': 'app-id=com.example.weddingzon',
  }
};

import GlobalNotificationListener from "./components/GlobalNotificationListener";

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${playfair.variable} ${lato.variable} antialiased`}
      >
        <SecurityProvider>
          <Providers>
            <ToastProvider>
              <GlobalNotificationListener />
              {children}
            </ToastProvider>
          </Providers>
        </SecurityProvider>
      </body>
    </html >
  );
}
