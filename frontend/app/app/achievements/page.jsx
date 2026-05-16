'use client';

import { useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Award, Star, Flame, Zap, CheckCircle, Target, Clock, Shield, Sparkles, Trophy, BookOpen, Droplets, Moon } from 'lucide-react';
import { format, subDays } from 'date-fns';
import useStore from '@/store/useStore';

export default function Achievements() {
  const { achievements, xp, level, habits, completions, unlockAchievement } = useStore();

  const today = new Date();
  const todayStr = format(today, 'yyyy-MM-dd');
  const totalCompletions = Object.keys(completions).length;

  // Compute current streak
  const currentStreak = useMemo(() => {
    let streak = 0;
    let d = new Date();
    while (true) {
      const dStr = format(d, 'yyyy-MM-dd');
      const completedOnDay = habits.some(h => completions[`${h.id}-${dStr}`]);
      if (completedOnDay) {
        streak++;
        d = subDays(d, 1);
      } else {
        if (dStr === todayStr) { d = subDays(d, 1); } else { break; }
      }
    }
    return streak;
  }, [completions, habits, todayStr]);

  const allAchievements = [
    {
      id: 'first_habit',
      name: 'First Steps',
      desc: 'Complete your very first habit',
      icon: CheckCircle,
      color: '#22c55e',
      threshold: () => totalCompletions >= 1,
      rarity: 'Common',
    },
    {
      id: '10_habits',
      name: 'Getting Started',
      desc: 'Complete 10 habits total',
      icon: Target,
      color: '#3b82f6',
      threshold: () => totalCompletions >= 10,
      rarity: 'Uncommon',
    },
    {
      id: '50_habits',
      name: 'Consistency Master',
      desc: 'Complete 50 habits total',
      icon: Award,
      color: '#a855f7',
      threshold: () => totalCompletions >= 50,
      rarity: 'Rare',
    },
    {
      id: '100_habits',
      name: 'Unstoppable',
      desc: 'Complete 100 habits — a machine',
      icon: Zap,
      color: '#FF6B2C',
      threshold: () => totalCompletions >= 100,
      rarity: 'Epic',
    },
    {
      id: 'streak_7',
      name: '7-Day Streak',
      desc: 'Maintain a 7-day streak',
      icon: Flame,
      color: '#f97316',
      threshold: () => currentStreak >= 7,
      rarity: 'Uncommon',
    },
    {
      id: 'streak_30',
      name: 'Monk Mode',
      desc: 'Maintain a 30-day streak',
      icon: Moon,
      color: '#8b5cf6',
      threshold: () => currentStreak >= 30,
      rarity: 'Legendary',
    },
    {
      id: 'level_5',
      name: 'Level 5 Ascension',
      desc: 'Reach Level 5',
      icon: Star,
      color: '#eab308',
      threshold: () => level >= 5,
      rarity: 'Uncommon',
    },
    {
      id: 'level_10',
      name: 'Level 10 Elite',
      desc: 'Reach Level 10',
      icon: Trophy,
      color: '#FF6B2C',
      threshold: () => level >= 10,
      rarity: 'Rare',
    },
    {
      id: 'xp_500',
      name: 'XP Grinder',
      desc: 'Earn 500 total XP',
      icon: Shield,
      color: '#06b6d4',
      threshold: () => xp >= 500,
      rarity: 'Uncommon',
    },
    {
      id: 'early_riser',
      name: 'Early Riser',
      desc: 'Start your habit journey',
      icon: Clock,
      color: '#f59e0b',
      threshold: () => habits.length >= 1,
      rarity: 'Common',
    },
    {
      id: 'habit_collector',
      name: 'Protocol Builder',
      desc: 'Create 5 or more habits',
      icon: BookOpen,
      color: '#10b981',
      threshold: () => habits.length >= 5,
      rarity: 'Uncommon',
    },
    {
      id: 'hydration_king',
      name: 'Hydration King',
      desc: 'Add a health habit',
      icon: Droplets,
      color: '#0ea5e9',
      threshold: () => habits.some(h => h.category === 'Health'),
      rarity: 'Common',
    },
  ];

  const rarityColors = {
    Common: 'text-gray-400 border-gray-500/30 bg-gray-500/10',
    Uncommon: 'text-green-400 border-green-500/30 bg-green-500/10',
    Rare: 'text-blue-400 border-blue-500/30 bg-blue-500/10',
    Epic: 'text-purple-400 border-purple-500/30 bg-purple-500/10',
    Legendary: 'text-[#FF8C42] border-[#FF6B2C]/30 bg-[#FF6B2C]/10',
  };

  const unlockedCount = allAchievements.filter(a => a.threshold() || achievements.includes(a.id)).length;

  return (
    <div className="space-y-8 pb-10">
      {/* Header */}
      <div className="relative z-10 flex flex-col md:flex-row justify-between items-start md:items-end gap-6">
        <div>
          <motion.div
            initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }}
            className="flex items-center gap-2 px-3 py-1 rounded-full bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42] text-[10px] font-bold uppercase tracking-[0.2em] mb-4 w-fit"
          >
            <Sparkles size={12} /> Achievement System
          </motion.div>
          <h1 className="text-4xl font-display font-bold text-white tracking-tight flex items-center gap-3">
            Trophies & Milestones <Award className="text-[#FF8C42]" />
          </h1>
          <p className="text-text-muted mt-2 text-lg">Your legacy of productivity, immortalized.</p>
        </div>
        {/* Summary stat */}
        <div className="glass-card px-8 py-5 rounded-2xl border border-white/5 text-right">
          <p className="text-[10px] text-text-muted uppercase tracking-widest mb-1">Unlocked</p>
          <p className="text-4xl font-display font-bold text-white">
            {unlockedCount}<span className="text-text-muted text-xl">/{allAchievements.length}</span>
          </p>
        </div>
      </div>

      {/* Progress bar */}
      <div className="relative z-10 glass-card p-6 rounded-2xl border border-white/5">
        <div className="flex justify-between items-center mb-3">
          <p className="text-sm font-bold text-white uppercase tracking-wider">Overall Progress</p>
          <p className="text-[#FF8C42] font-bold">{Math.round((unlockedCount / allAchievements.length) * 100)}%</p>
        </div>
        <div className="h-3 bg-white/5 rounded-full overflow-hidden">
          <motion.div
            initial={{ width: 0 }}
            animate={{ width: `${(unlockedCount / allAchievements.length) * 100}%` }}
            transition={{ duration: 1.5, ease: 'easeOut' }}
            className="h-full bg-gradient-to-r from-[#FF6B2C] to-[#FFB347] rounded-full relative"
          >
            <div className="absolute top-0 right-0 w-8 h-full bg-white/30 blur-md" />
          </motion.div>
        </div>
      </div>

      {/* Achievement Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 relative z-10">
        <AnimatePresence>
          {allAchievements.map((achievement, i) => {
            const isUnlocked = achievement.threshold() || achievements.includes(achievement.id);
            const Icon = achievement.icon;
            const rarityClass = rarityColors[achievement.rarity] || rarityColors.Common;

            return (
              <motion.div
                key={achievement.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.07, ease: [0.16, 1, 0.3, 1] }}
                className={`p-6 rounded-3xl border transition-all duration-500 overflow-hidden relative group ${
                  isUnlocked
                    ? 'bg-white/5 border-[#FF6B2C]/30 hover:border-[#FF6B2C]/60 shadow-[0_0_30px_rgba(255,107,44,0.05)] hover:shadow-[0_0_40px_rgba(255,107,44,0.15)]'
                    : 'bg-white/[0.02] border-white/5 opacity-50 grayscale hover:opacity-60 hover:grayscale-0 transition-all duration-500'
                }`}
              >
                {/* Glow on unlock */}
                {isUnlocked && (
                  <div
                    className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-500"
                    style={{ background: `radial-gradient(ellipse at top right, ${achievement.color}15, transparent 70%)` }}
                  />
                )}

                <div className="flex items-start gap-4 relative z-10">
                  <div
                    className={`w-14 h-14 rounded-2xl flex items-center justify-center shrink-0 transition-all duration-500 ${
                      isUnlocked
                        ? 'text-white shadow-[0_0_20px_rgba(255,107,44,0.4)] group-hover:scale-110'
                        : 'bg-white/10 text-white/30'
                    }`}
                    style={isUnlocked ? { background: `linear-gradient(135deg, ${achievement.color}, ${achievement.color}99)` } : {}}
                  >
                    <Icon size={28} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-2 mb-1">
                      <h3 className={`font-display font-bold text-lg leading-tight ${isUnlocked ? 'text-white' : 'text-white/50'}`}>
                        {achievement.name}
                      </h3>
                    </div>
                    <p className="text-sm text-text-muted leading-snug mb-3">{achievement.desc}</p>
                    <span className={`text-[10px] font-bold uppercase tracking-widest px-2 py-0.5 rounded-full border ${rarityClass}`}>
                      {achievement.rarity}
                    </span>
                  </div>
                </div>

                {isUnlocked && (
                  <motion.div
                    initial={{ scale: 0, rotate: -180 }}
                    animate={{ scale: 1, rotate: 0 }}
                    transition={{ type: 'spring', stiffness: 300, damping: 20, delay: i * 0.07 + 0.2 }}
                    className="absolute top-4 right-4 text-[#FF8C42]"
                  >
                    <Sparkles size={16} />
                  </motion.div>
                )}

                {!isUnlocked && (
                  <div className="absolute inset-0 flex items-center justify-center">
                    <div className="text-4xl opacity-10">🔒</div>
                  </div>
                )}
              </motion.div>
            );
          })}
        </AnimatePresence>
      </div>
    </div>
  );
}
