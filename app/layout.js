import "./globals.css";
import { Toaster } from 'react-hot-toast';
import SceneWrapper from '@/components/SceneWrapper';
import { Providers } from './providers';
import NavbarWrapper from '@/components/NavbarWrapper';

export const metadata = {
  title: "HabitFlow | Eagle Productivity OS",
  description: "A premium, cinematic productivity ecosystem for high-achievers.",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en" className="dark">
      <body className="min-h-screen bg-[#050505] text-white selection:bg-[#FF6B2C]/30">
        <Toaster 
          position="top-center"
          toastOptions={{
            style: {
              background: 'rgba(20, 20, 25, 0.9)',
              color: '#fff',
              backdropFilter: 'blur(10px)',
              border: '1px solid rgba(255, 107, 44, 0.2)',
            },
            success: {
              iconTheme: {
                primary: '#FF6B2C',
                secondary: '#fff',
              },
            },
          }}
        />
        <Providers>
          <NavbarWrapper />
          <SceneWrapper>
            {children}
          </SceneWrapper>
        </Providers>
      </body>
    </html>
  );
}
