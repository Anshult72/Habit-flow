'use client';

import { motion } from 'framer-motion';
import { Bell, User, Flame } from 'lucide-react';
import MobileDock from '@/components/MobileDock';
import Sidebar from '@/components/Sidebar';
import ErrorBoundary from '@/components/ErrorBoundary';
import { XpToastProvider } from '@/components/XpToast';
import ProfileDropdown from '@/components/ProfileDropdown';
import NotificationDropdown from '@/components/NotificationDropdown';
import useStore from '@/store/useStore';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getSession } from '@/lib/supabaseAuth';
import { useLogout } from '@/hooks/useLogout';

export default function DashboardLayout({ children }) {
  const { getStreak, isHydrated } = useStore();
  const [streak, setStreak] = useState(0);
  const router = useRouter();
  const logout = useLogout();

  useEffect(() => {
    if (!isHydrated) return;

    const checkAuth = async () => {
      setStreak(getStreak());

      // 1. Check Supabase session
      const session = await getSession();
      if (!session) {
        router.replace('/login');
        return;
      }

      // Sync user with backend DB and load initial data
      try {
        await useStore.getState().syncData();
      } catch (e) {
        console.error('Failed to sync user data:', e);
      }

      // 2. Check onboarding completion
      const hasCompleted = localStorage.getItem('hasCompletedOnboarding') === 'true';
      if (!hasCompleted) {
        router.push('/onboarding');
      }
    };

    checkAuth();
  }, [isHydrated, getStreak, router]);

  return (
    <div className="min-h-screen bg-[#050505] text-text-main font-sans relative flex">
      {/* Cinematic Sidebar */}
      <Sidebar />

      {/* Main Content Area */}
      <main 
        className="flex-1 min-h-screen overflow-y-auto overflow-x-hidden relative pb-24 md:pb-10 transition-all duration-300 md:ml-[80px]"
      >
        {/* Top Utility Strip (Hidden on Mobile) */}
        <div className="absolute top-6 right-8 md:right-12 hidden md:flex items-center gap-4 z-20">
          <div className="px-4 py-2 rounded-xl bg-surface border border-surfaceBorder flex items-center gap-2 shadow-sm backdrop-blur-md">
            <Flame size={16} className="text-[#FF6B2C]" />
            <span className="text-xs font-bold text-white tracking-widest uppercase">{streak} Day Streak</span>
          </div>
          <NotificationDropdown />
          <ProfileDropdown />
        </div>

        {/* Mobile Header (Minimal) */}
        <div className="md:hidden flex items-center justify-between px-6 pt-6 pb-2 z-20 relative">
          <div className="flex items-center gap-3">
             <img src="/assets/eagle-logo-transparent.png" className="w-8 h-8 object-contain" alt="HabitFlow" />
             <span className="font-display font-bold text-lg text-textMain tracking-tight">HabitFlow</span>
          </div>
          <div className="px-3 py-1.5 rounded-xl bg-surface border border-surfaceBorder flex items-center gap-2 shadow-sm">
            <Flame size={14} className="text-primary" />
            <span className="text-[10px] font-bold text-textMain tracking-widest uppercase">{streak} Day</span>
          </div>
        </div>

        <div className="p-4 md:p-10 lg:p-12 w-full max-w-[1400px] mx-auto pt-6 md:pt-32">
          <motion.div
            initial={{ opacity: 0, scale: 0.98, filter: 'blur(10px)' }}
            animate={{ opacity: 1, scale: 1, filter: 'blur(0px)' }}
            transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
          >
            <ErrorBoundary>
              <XpToastProvider>
                {children}
              </XpToastProvider>
            </ErrorBoundary>
          </motion.div>
        </div>

        {/* Global Dashboard Ambience */}
        <div className="fixed inset-0 pointer-events-none z-[-1] overflow-hidden">
          <div className="absolute top-[20%] left-[20%] w-[60%] h-[60%] bg-[#FF6B2C]/5 rounded-full blur-[160px]" />
          <div className="absolute bottom-[10%] right-[10%] w-[40%] h-[40%] bg-[#E85D04]/3 rounded-full blur-[120px]" />
        </div>
      </main>

      {/* Floating Mobile Dock */}
      <MobileDock />
    </div>
  );
}
