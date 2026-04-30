'use client';

import { motion } from 'framer-motion';
import { Bell, User, Flame } from 'lucide-react';
import MobileDock from '@/components/MobileDock';
import Sidebar from '@/components/Sidebar';
import ErrorBoundary from '@/components/ErrorBoundary';
import useStore from '@/store/useStore';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

export default function DashboardLayout({ children }) {
  const { getStreak, isHydrated } = useStore();
  const [streak, setStreak] = useState(0);
  const router = useRouter();

  useEffect(() => {
    if (isHydrated) {
      setStreak(getStreak());
      
      // Onboarding check
      const hasCompleted = localStorage.getItem('hasCompletedOnboarding') === 'true';
      if (!hasCompleted) {
        router.push('/onboarding');
      }
    }
  }, [isHydrated, getStreak, router]);

  return (
    <div className="min-h-screen bg-[#050505] text-text-main font-sans relative flex">
      {/* Cinematic Sidebar */}
      <Sidebar />

      {/* Main Content Area */}
      <main 
        className="flex-1 min-h-screen overflow-y-auto overflow-x-hidden relative pb-24 md:pb-10 transition-all duration-300 md:ml-[80px]"
      >
        {/* Top Utility Strip */}
        <div className="absolute top-6 right-8 md:right-12 flex items-center gap-4 z-20">
          <div className="px-4 py-2 rounded-xl bg-white/5 border border-white/10 flex items-center gap-2 shadow-[0_0_15px_rgba(255,107,44,0.1)] backdrop-blur-md">
            <Flame size={16} className="text-[#FF6B2C]" />
            <span className="text-xs font-bold text-white tracking-widest uppercase">{streak} Day Streak</span>
          </div>
          <button className="w-10 h-10 rounded-xl bg-white/5 border border-white/10 flex items-center justify-center hover:bg-white/10 transition-all text-white/70 hover:text-white">
            <Bell size={18} />
          </button>
          <button className="w-10 h-10 rounded-xl bg-white/5 border border-white/10 flex items-center justify-center hover:border-[#FF6B2C]/50 transition-all text-white/70 hover:text-white group/user overflow-hidden relative">
            <div className="absolute inset-0 bg-[#FF6B2C]/10 opacity-0 group-hover/user:opacity-100 transition-opacity" />
            <User size={18} className="relative z-10" />
          </button>
        </div>

        <div className="p-6 md:p-10 lg:p-12 w-full max-w-[1400px] mx-auto pt-24 md:pt-32">
          <motion.div
            initial={{ opacity: 0, scale: 0.98, filter: 'blur(10px)' }}
            animate={{ opacity: 1, scale: 1, filter: 'blur(0px)' }}
            transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
          >
            <ErrorBoundary>
              {children}
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
