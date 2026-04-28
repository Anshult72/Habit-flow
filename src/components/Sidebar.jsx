import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useNavigate, useLocation } from 'react-router-dom';
import { 
  LayoutDashboard, ListChecks, Calendar, BarChart3, FileText,
  Zap, Timer, Clock, StopCircle, Sparkles,
  Rocket, Heart, BookOpen, StickyNote, Image,
  Trophy, Swords, Users, Award,
  Settings, Palette, Bell, Sliders, User,
  ChevronLeft, ChevronRight, ChevronDown
} from 'lucide-react';

const navGroups = [
  {
    title: 'CORE TRACKING',
    items: [
      { label: 'Dashboard', path: '/app', icon: LayoutDashboard },
      { label: 'Habits', path: '/app/habits', icon: ListChecks },
      { label: 'Calendar', path: '/app/calendar', icon: Calendar },
      { label: 'Analytics', path: '/app/analytics', icon: BarChart3 },
      { label: 'Reports', path: '/app/reports', icon: FileText },
    ]
  },
  {
    title: 'FOCUS SYSTEM',
    items: [
      { label: 'Focus Zone', path: '/app/focus-zone', icon: Zap },
      { label: 'Pomodoro', path: '/app/pomodoro', icon: Timer },
      { label: 'Stopwatch', path: '/app/stopwatch', icon: StopCircle },
      { label: 'Matrix', path: '/app/matrix', icon: Sparkles },
    ]
  },
  {
    title: 'LIFE OS',
    items: [
      { label: 'Missions', path: '/app/mission-countdown', icon: Rocket },
      { label: 'Wishlist', path: '/app/wishlist', icon: Heart },
      { label: 'Learning Hub', path: '/app/learning-hub', icon: BookOpen },
      { label: 'Memo', path: '/app/memo', icon: StickyNote },
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
    ]
  }
];

export default function Sidebar() {
  const [isExpanded, setIsExpanded] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();

  const isActive = (path) => location.pathname === path;

  return (
    <motion.aside
      onMouseEnter={() => setIsExpanded(true)}
      onMouseLeave={() => setIsExpanded(false)}
      animate={{ width: isExpanded ? 280 : 80 }}
      transition={{ duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
      className="fixed left-0 top-0 bottom-0 z-40 hidden md:flex flex-col bg-[#0A0A0A]/95 backdrop-blur-3xl border-r border-white/5 shadow-[20px_0_40px_rgba(0,0,0,0.5)] overflow-y-auto hidden-scrollbar"
    >
      <div className="flex-1 py-6 px-4 space-y-8">
        {/* App Logo */}
        <div className="flex items-center gap-4 px-3 mb-4 cursor-pointer" onClick={() => navigate('/')}>
          <div className="flex-shrink-0 w-8 h-8 rounded-xl bg-gradient-to-tr from-[#FF6B2C] to-[#E85D04] flex items-center justify-center shadow-[0_0_15px_rgba(255,107,44,0.4)]">
            <span className="text-white text-sm font-bold">H</span>
          </div>
          <AnimatePresence>
            {isExpanded && (
              <motion.span
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -10 }}
                className="text-white font-bold font-display tracking-tight text-xl whitespace-nowrap"
              >
                HabitFlow
              </motion.span>
            )}
          </AnimatePresence>
        </div>

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
                <button
                  key={item.label}
                  onClick={() => navigate(item.path)}
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
                </button>
              );
            })}
          </div>
        ))}
      </div>
    </motion.aside>
  );
}
