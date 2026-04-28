import { motion } from 'framer-motion';
import { useNavigate, useLocation } from 'react-router-dom';
import { 
  LayoutDashboard, ListChecks, Calendar, BarChart3, 
  Trophy, Settings, Shield, Award, Rocket, Sparkles, Zap, BookOpen
} from 'lucide-react';
import useStore from '../store/useStore';

export default function MobileDock() {
  const navigate = useNavigate();
  const location = useLocation();
  const { level } = useStore();

  const dockItems = [
    { icon: LayoutDashboard, path: '/app', label: 'Home' },
    { icon: ListChecks, path: '/app/habits', label: 'Habits' },
    { icon: BookOpen, path: '/app/learning-hub', label: 'Learning' },
    { icon: Rocket, path: '/app/mission-countdown', label: 'Missions' },
    { icon: Zap, path: '/app/focus-zone', label: 'Focus' },
  ];

  const isActive = (path) => location.pathname === path;

  return (
    <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-[100] md:hidden w-[90%] max-w-[400px]">
      <div className="glass-card bg-[#0A0A0B]/80 backdrop-blur-2xl border border-white/10 rounded-full px-6 py-3 shadow-[0_20px_50px_rgba(0,0,0,0.5),0_0_20px_rgba(255,107,44,0.1)] flex justify-between items-center relative overflow-hidden">
        {/* Animated Background Glow for Active Item */}
        <div className="absolute inset-0 bg-gradient-to-r from-transparent via-[#FF6B2C]/5 to-transparent pointer-events-none" />
        
        {dockItems.map((item) => {
          const Icon = item.icon;
          const active = isActive(item.path);
          
          return (
            <button
              key={item.path}
              onClick={() => navigate(item.path)}
              className="relative p-2 flex flex-col items-center gap-1 group"
            >
              {active && (
                <motion.div
                  layoutId="dock-indicator"
                  className="absolute -inset-1 bg-[#FF6B2C]/10 rounded-xl border border-[#FF6B2C]/20 shadow-[0_0_15px_rgba(255,107,44,0.2)]"
                  transition={{ type: 'spring', bounce: 0.3, duration: 0.6 }}
                />
              )}
              <Icon 
                size={22} 
                className={`relative z-10 transition-all duration-300 ${
                  active ? 'text-[#FF8C42] scale-110' : 'text-white/40 group-hover:text-white/60'
                }`} 
              />
              <span className={`text-[8px] font-bold uppercase tracking-widest relative z-10 transition-colors ${
                active ? 'text-[#FF8C42]' : 'text-white/20'
              }`}>
                {item.label}
              </span>
            </button>
          );
        })}

        <div className="w-px h-8 bg-white/10 mx-1" />

        <div className="flex flex-col items-center">
          <div className="w-8 h-8 rounded-full bg-gradient-to-tr from-[#FF6B2C] to-[#FFB347] flex items-center justify-center text-[10px] font-bold text-white shadow-[0_0_10px_rgba(255,107,44,0.4)]">
            {level}
          </div>
        </div>
      </div>
    </div>
  );
}
