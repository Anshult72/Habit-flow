'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useRouter, usePathname } from 'next/navigation';
import { 
  LayoutDashboard, ListChecks, Zap, BarChart3, Menu, X,
  Calendar, FileText, Sparkles, Rocket, Heart, BookOpen, StickyNote, Image,
  Trophy, Swords, Users, Award, Settings, Palette, User
} from 'lucide-react';
import useStore from '@/store/useStore';

const navGroups = [
  {
    title: 'CORE',
    items: [
      { label: 'Planner', path: '/app/planner', icon: Calendar },
      { label: 'Calendar', path: '/app/calendar', icon: Calendar },
      { label: 'Reports', path: '/app/reports', icon: FileText },
    ]
  },
  {
    title: 'FOCUS & OS',
    items: [
      { label: 'Matrix', path: '/app/matrix', icon: Sparkles },
      { label: 'Missions', path: '/app/missions', icon: Rocket },
      { label: 'Wishlist', path: '/app/wishlist', icon: Heart },
      { label: 'Learning Hub', path: '/app/learning', icon: BookOpen },
      { label: 'Memo', path: '/app/memo', icon: StickyNote },
      { label: 'Vision Board', path: '/app/vision-board', icon: Image },
    ]
  },
  {
    title: 'SOCIAL',
    items: [
      { label: 'Leaderboard', path: '/app/leaderboard', icon: Trophy },
      { label: 'Duels', path: '/app/duels', icon: Swords },
      { label: 'Squads', path: '/app/squads', icon: Users },
      { label: 'Achievements', path: '/app/achievements', icon: Award },
    ]
  },
  {
    title: 'SYSTEM',
    items: [
      { label: 'Settings', path: '/app/settings', icon: Settings },
      { label: 'Themes', path: '/app/themes', icon: Palette },
      { label: 'Account', path: '/app/account', icon: User },
    ]
  }
];

export default function MobileDock() {
  const router = useRouter();
  const pathname = usePathname();
  const { level } = useStore();
  const [isMoreOpen, setIsMoreOpen] = useState(false);

  const dockItems = [
    { icon: LayoutDashboard, path: '/app', label: 'Home' },
    { icon: ListChecks, path: '/app/habits', label: 'Habits' },
    { icon: Zap, path: '/app/focus-zone', label: 'Focus' },
    { icon: BarChart3, path: '/app/analytics', label: 'Analytics' },
  ];

  const isActive = (path) => pathname === path && !isMoreOpen;

  return (
    <>
      {/* BOTTOM NAV BAR */}
      <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-[100] md:hidden w-[95%] max-w-[420px]">
        <div className="glass-card bg-surface/90 backdrop-blur-2xl border border-surfaceBorder rounded-3xl px-2 py-2 shadow-2xl flex justify-between items-center relative overflow-hidden">
          {/* Animated Background Glow */}
          <div className="absolute inset-0 bg-gradient-to-r from-transparent via-primary/5 to-transparent pointer-events-none" />
          
          {dockItems.map((item) => {
            const Icon = item.icon;
            const active = isActive(item.path);
            
            return (
              <button
                key={item.path}
                onClick={() => {
                  setIsMoreOpen(false);
                  router.push(item.path);
                }}
                className="relative flex-1 min-h-[56px] flex flex-col items-center justify-center gap-1 group active:scale-95 transition-transform"
              >
                {active && (
                  <motion.div
                    layoutId="dock-indicator"
                    className="absolute inset-1 bg-primary/10 rounded-2xl border border-primary/20 shadow-[0_0_15px_var(--theme-primary-glow)]"
                    transition={{ type: 'spring', bounce: 0.3, duration: 0.6 }}
                  />
                )}
                <Icon 
                  size={24} 
                  className={`relative z-10 transition-all duration-300 ${
                    active ? 'text-primary scale-110' : 'text-textMuted group-hover:text-textMain'
                  }`} 
                />
                <span className={`text-[9px] font-bold uppercase tracking-widest relative z-10 transition-colors mt-0.5 ${
                  active ? 'text-primary' : 'text-textMuted/50'
                }`}>
                  {item.label}
                </span>
              </button>
            );
          })}

          <div className="w-px h-8 bg-surfaceBorder mx-1" />

          {/* MORE BUTTON */}
          <button
            onClick={() => setIsMoreOpen(!isMoreOpen)}
            className="relative flex-1 min-h-[56px] flex flex-col items-center justify-center gap-1 active:scale-95 transition-transform"
          >
            {isMoreOpen && (
              <motion.div
                layoutId="dock-indicator"
                className="absolute inset-1 bg-white/10 rounded-2xl border border-white/20"
                transition={{ type: 'spring', bounce: 0.3, duration: 0.6 }}
              />
            )}
            {isMoreOpen ? <X size={24} className="text-textMain relative z-10" /> : <Menu size={24} className="text-textMuted relative z-10" />}
            <span className={`text-[9px] font-bold uppercase tracking-widest relative z-10 mt-0.5 ${isMoreOpen ? 'text-textMain' : 'text-textMuted/50'}`}>
              More
            </span>
          </button>
        </div>
      </div>

      {/* FULL SCREEN MORE MENU */}
      <AnimatePresence>
        {isMoreOpen && (
          <motion.div 
            initial={{ opacity: 0, y: '100%' }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: '100%' }}
            transition={{ type: 'spring', damping: 25, stiffness: 200 }}
            className="fixed inset-0 z-[90] bg-background md:hidden overflow-y-auto pb-36 pt-12 px-6"
          >
            <div className="flex items-center justify-between mb-8">
              <div>
                <h2 className="text-3xl font-display font-black text-textMain">All Features</h2>
                <p className="text-textMuted text-sm">Explore your productivity ecosystem</p>
              </div>
              <div className="w-12 h-12 rounded-full bg-gradient-to-tr from-primary to-accent flex items-center justify-center shadow-[0_0_20px_var(--theme-primary-glow)]">
                <span className="text-[10px] font-black text-white tracking-widest">LVL<br/>{level}</span>
              </div>
            </div>

            <div className="space-y-8">
              {navGroups.map((group, idx) => (
                <div key={idx} className="space-y-3">
                  <h3 className="text-[10px] font-bold uppercase tracking-[0.2em] text-textMuted ml-2">
                    {group.title}
                  </h3>
                  <div className="grid grid-cols-2 gap-3">
                    {group.items.map((item, i) => {
                      const Icon = item.icon;
                      return (
                        <button
                          key={i}
                          onClick={() => {
                            setIsMoreOpen(false);
                            router.push(item.path);
                          }}
                          className="flex flex-col items-start p-4 bg-surface border border-surfaceBorder rounded-3xl active:scale-95 transition-all text-left shadow-sm"
                        >
                          <div className="w-10 h-10 rounded-full bg-surfaceBorder/50 flex items-center justify-center mb-3">
                            <Icon size={20} className="text-primary" />
                          </div>
                          <span className="text-sm font-bold text-textMain leading-tight">{item.label}</span>
                        </button>
                      );
                    })}
                  </div>
                </div>
              ))}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
