'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useRouter, usePathname } from 'next/navigation';
import Link from 'next/link';
import { 
  LayoutDashboard, ListChecks, Calendar, BarChart3, FileText,
  Zap, Sparkles,
  Rocket, Heart, BookOpen, StickyNote, Image,
  Trophy, Swords, Users, Award,
  Settings, Palette, User,
} from 'lucide-react';

const navGroups = [
  {
    title: 'CORE TRACKING',
    items: [
      { label: 'Dashboard', path: '/app', icon: LayoutDashboard },
      { label: 'Daily Planner', path: '/app/planner', icon: Calendar },
      { label: 'Habits', path: '/app/habits', icon: ListChecks },
      { label: 'Calendar', path: '/app/calendar', icon: Calendar },
      { label: 'Analytics', path: '/app/analytics', icon: BarChart3 },
    ]
  },
  {
    title: 'FOCUS SYSTEM',
    items: [
      { label: 'Focus Zone', path: '/app/focus-zone', icon: Zap },
      { label: 'Matrix', path: '/app/matrix', icon: Sparkles },
    ]
  },
  {
    title: 'LIFE OS',
    items: [
      { label: 'Missions', path: '/app/missions', icon: Rocket },
      { label: 'Wishlist', path: '/app/wishlist', icon: Heart },
      { label: 'Learning Hub', path: '/app/learning', icon: BookOpen },
      { label: 'Memo', path: '/app/memos', icon: StickyNote },
      { label: 'Vision Board', path: '/app/vision-board', icon: Image },
    ]
  },
  {
    title: 'SOCIAL & GAMIFICATION',
    items: [
      { label: 'Leaderboard', path: '/app/leaderboard', icon: Trophy },
      { label: 'Duels', path: '/app/duels', icon: Swords },
      { label: 'Squads', path: '/app/squads', icon: Users },
      { label: 'Achievements', path: '/app/achievements', icon: Award },
    ]
  },
  {
    title: 'CONTROL PANEL',
    items: [
      { label: 'Settings', path: '/app/settings', icon: Settings },
      { label: 'Themes', path: '/app/themes', icon: Palette },
      { label: 'Account', path: '/app/account', icon: User },
      { label: 'Reports', path: '/app/reports', icon: FileText },
    ]
  }
];

export default function Sidebar() {
  const [isExpanded, setIsExpanded] = useState(false);
  const router = useRouter();
  const pathname = usePathname();

  const isActive = (path) => pathname === path;

  return (
    <motion.aside
      onMouseEnter={() => setIsExpanded(true)}
      onMouseLeave={() => setIsExpanded(false)}
      animate={{ width: isExpanded ? 280 : 80 }}
      transition={{ duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
      className="fixed left-0 top-0 bottom-0 z-40 hidden md:flex flex-col bg-[#0A0A0A]/95 backdrop-blur-3xl border-r border-white/5 shadow-[20px_0_40px_rgba(0,0,0,0.5)] overflow-y-auto"
      style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
    >
      <div className="flex-1 py-6 px-4 space-y-8">
        {/* App Logo */}
        <Link 
          href="/"
          className="flex items-center gap-4 px-3 mb-8 cursor-pointer group/logo" 
        >
          <div className="relative flex-shrink-0 w-10 h-10 flex items-center justify-center">
            <div className="absolute inset-0 bg-[#FF6B2C]/20 blur-lg rounded-full opacity-0 group-hover/logo:opacity-100 transition-opacity duration-500" />
            
            <AnimatePresence mode="wait">
              {isExpanded ? (
                <motion.img
                  key="full-logo"
                  src="/assets/eagle-logo-transparent.png"
                  initial={{ opacity: 0, scale: 0.8, rotate: -10 }}
                  animate={{ opacity: 1, scale: 1, rotate: 0 }}
                  exit={{ opacity: 0, scale: 0.8, rotate: 10 }}
                  className="w-10 h-10 object-contain relative z-10"
                />
              ) : (
                <motion.img
                  key="simplified-logo"
                  src="/assets/eagle-logo-simplified.png"
                  initial={{ opacity: 0, scale: 0.8 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.8 }}
                  className="w-8 h-8 object-contain relative z-10"
                />
              )}
            </AnimatePresence>
          </div>
          
          <AnimatePresence>
            {isExpanded && (
              <motion.div
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -10 }}
                className="flex flex-col"
              >
                <span className="text-white font-bold font-display tracking-tight text-xl whitespace-nowrap group-hover/logo:text-[#FF8C42] transition-colors">
                  HabitFlow
                </span>
                <span className="text-[8px] font-bold text-[#FF6B2C] uppercase tracking-[0.4em] opacity-60">
                  COMMAND
                </span>
              </motion.div>
            )}
          </AnimatePresence>
        </Link>

        {navGroups.map((group, groupIdx) => (
          <div key={group.title} className="flex flex-col gap-2 relative">
            <AnimatePresence>
              {isExpanded ? (
                <motion.h3
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -10 }}
                  transition={{ duration: 0.2 }}
                  className="text-[10px] uppercase tracking-widest text-white/40 font-semibold px-3 mb-1 whitespace-nowrap overflow-hidden"
                >
                  {group.title}
                </motion.h3>
              ) : (
                <div className="w-full h-px bg-white/5 my-2" />
              )}
            </AnimatePresence>
            
            {group.items.map((item, i) => {
              const Icon = item.icon;
              const active = isActive(item.path);
              return (
                <Link
                  key={item.label}
                  href={item.path}
                  className={`relative flex items-center gap-4 px-3 py-3 rounded-xl transition-all duration-300 group overflow-hidden ${
                    active 
                      ? 'bg-[#FF6B2C]/10 text-[#FF6B2C]' 
                      : 'text-white/60 hover:text-white hover:bg-white/5'
                  }`}
                  title={!isExpanded ? item.label : undefined}
                >
                  <div className="flex-shrink-0 flex items-center justify-center w-6">
                    <Icon size={20} className={`transition-colors ${active ? 'text-[#FF6B2C]' : 'group-hover:text-[#FF8C42]'}`} />
                  </div>
                  
                  <AnimatePresence>
                    {isExpanded && (
                      <motion.span
                        initial={{ opacity: 0, x: -10 }}
                        animate={{ opacity: 1, x: 0 }}
                        exit={{ opacity: 0, x: -10 }}
                        transition={{ duration: 0.2, delay: i * 0.05 }}
                        className={`font-medium text-sm whitespace-nowrap ${active ? 'text-white' : ''}`}
                      >
                        {item.label}
                      </motion.span>
                    )}
                  </AnimatePresence>

                  {active && (
                    <motion.div
                      layoutId="sidebar-active"
                      className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-6 bg-[#FF6B2C] rounded-r-full shadow-[0_0_10px_rgba(255,107,44,0.6)]"
                      transition={{ type: "spring", stiffness: 300, damping: 30 }}
                    />
                  )}
                </Link>
              );
            })}
          </div>
        ))}
      </div>
    </motion.aside>
  );
}
