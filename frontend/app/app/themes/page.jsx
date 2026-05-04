'use client';

import { motion } from 'framer-motion';
import { Sun, Moon, Zap, Leaf, Clock, CheckCircle2 } from 'lucide-react';
import useStore from '@/store/useStore';

export default function ThemesPage() {
  const { theme, setTheme, autoTheme, setAutoTheme } = useStore();

  const themes = [
    {
      id: 'light',
      name: 'Light Mode',
      desc: 'Clean, bright workspace with soft contrast for daytime focus.',
      icon: Sun,
      colors: { bg: '#F8FAFC', surface: '#FFFFFF', primary: '#FF6B2C' }
    },
    {
      id: 'focus',
      name: 'Focus Mode',
      desc: 'Deep dark background with high contrast purple accents for deep work.',
      icon: Zap,
      colors: { bg: '#000000', surface: '#1A1A1A', primary: '#7C3AED' }
    },
    {
      id: 'calm',
      name: 'Calm Mode',
      desc: 'Soft green tones for a relaxed and easy-on-eyes experience.',
      icon: Leaf,
      colors: { bg: '#0A1110', surface: '#10B9811A', primary: '#10B981' }
    }
  ];

  return (
    <div className="max-w-4xl mx-auto space-y-12 pb-24">
      <header>
        <h1 className="text-3xl font-display font-bold text-white mb-2">Appearance & Themes</h1>
        <p className="text-textMuted">Customize the look and feel of your workspace.</p>
      </header>

      {/* Auto Theme Section */}
      <section className="glass-card p-6 md:p-8 rounded-3xl border-white/5 space-y-4 shadow-[0_10px_40px_rgba(0,0,0,0.5)]">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div className="flex items-start gap-5">
            <div className={`p-4 rounded-2xl transition-colors duration-500 ${autoTheme ? 'bg-[#FF6B2C]/20 text-[#FF6B2C]' : 'bg-white/5 text-white/40'}`}>
              <Clock size={28} />
            </div>
            <div>
              <h3 className="text-xl font-display font-bold text-white mb-2">Auto Theme</h3>
              <p className="text-sm text-textMuted leading-relaxed max-w-lg">
                Automatically adjusts your app theme based on the time of day to match your energy and focus levels.
              </p>
              <div className="mt-4 flex flex-wrap gap-2 text-[10px] uppercase tracking-widest font-bold text-white/40">
                <span className="px-3 py-1.5 rounded-lg bg-white/5">Morning: Balanced</span>
                <span className="px-3 py-1.5 rounded-lg bg-white/5">Evening: Calm</span>
                <span className="px-3 py-1.5 rounded-lg bg-white/5">Night: Focus</span>
              </div>
            </div>
          </div>
          
          <button
            onClick={() => setAutoTheme(!autoTheme)}
            className={`relative w-16 h-9 rounded-full transition-colors shrink-0 ${autoTheme ? 'bg-[#FF6B2C]' : 'bg-white/10'}`}
          >
            <motion.div
              className="absolute top-1 left-1 w-7 h-7 bg-white rounded-full shadow-md"
              animate={{ x: autoTheme ? 28 : 0 }}
              transition={{ type: "spring", stiffness: 500, damping: 30 }}
            />
          </button>
        </div>
      </section>

      {/* Manual Themes Grid */}
      <section className={`space-y-6 transition-all duration-500 ${autoTheme ? 'opacity-40 grayscale-[0.5] pointer-events-none' : 'opacity-100'}`}>
        <div className="flex items-center justify-between">
          <h3 className="text-sm font-bold text-white uppercase tracking-widest">Manual Selection</h3>
          {autoTheme && (
            <span className="text-xs text-[#FF6B2C] font-bold">Disable Auto Theme to select manually</span>
          )}
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {themes.map((t) => {
            const isSelected = theme === t.id && !autoTheme;
            return (
              <button
                key={t.id}
                onClick={() => setTheme(isSelected ? 'dark' : t.id)}
                className={`group relative text-left glass-card p-6 rounded-3xl transition-all duration-500 overflow-hidden ${
                  isSelected 
                    ? 'border-primary ring-1 ring-primary/30 shadow-[0_0_30px_rgba(255,107,44,0.15)] scale-[1.02]' 
                    : 'border-white/5 hover:border-white/20 hover:bg-white/5 hover:scale-[1.01]'
                }`}
              >
                {/* Active Indicator Background Glow */}
                {isSelected && (
                  <div className="absolute inset-0 bg-primary/5 rounded-3xl pointer-events-none" />
                )}

                {/* Check icon */}
                <div className={`absolute top-6 right-6 transition-all duration-300 z-10 ${isSelected ? 'opacity-100 scale-100' : 'opacity-0 scale-50'}`}>
                  <div className="bg-white rounded-full text-primary">
                    <CheckCircle2 size={24} fill="currentColor" />
                  </div>
                </div>
                
                {/* Mini Preview UI */}
                <div className="w-full h-32 rounded-2xl mb-8 overflow-hidden flex border border-white/10 relative z-0 shadow-inner transition-transform group-hover:scale-[1.02]" style={{ backgroundColor: t.colors.bg }}>
                  {/* Mock Sidebar */}
                  <div className="w-1/3 h-full border-r border-white/5 flex flex-col gap-2 p-3" style={{ backgroundColor: t.colors.surface }}>
                    <div className="w-full h-2 rounded bg-white/10" />
                    <div className="w-3/4 h-2 rounded bg-white/5" />
                    <div className="w-5/6 h-2 rounded bg-white/5 mt-auto" />
                  </div>
                  {/* Mock Main Content */}
                  <div className="flex-1 p-4 flex flex-col justify-between items-end relative">
                     <div className="w-full h-3 rounded bg-white/5" />
                     {/* Floating Action Button mock */}
                     <div className="w-10 h-10 rounded-full shadow-[0_4px_15px_rgba(0,0,0,0.5)] flex items-center justify-center border border-white/10" style={{ backgroundColor: t.colors.primary }}>
                       <t.icon size={16} className="text-white" />
                     </div>
                  </div>
                </div>

                {/* Info */}
                <div className="relative z-10">
                  <div className="flex items-center gap-3 mb-3">
                    <div className={`p-2 rounded-lg ${isSelected ? 'bg-primary/20 text-primary' : 'bg-white/5 text-textMuted'}`}>
                      <t.icon size={18} />
                    </div>
                    <h4 className="font-display font-bold text-lg text-white">{t.name}</h4>
                  </div>
                  <p className="text-xs text-textMuted leading-relaxed font-medium">{t.desc}</p>
                </div>
              </button>
            );
          })}
        </div>
      </section>
    </div>
  );
}
