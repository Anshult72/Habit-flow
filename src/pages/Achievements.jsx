import { useMemo } from 'react';
import { motion } from 'framer-motion';
import { Award, Star, Flame, Zap, CheckCircle, Target, Clock, Shield } from 'lucide-react';
import useStore from '../store/useStore';

export default function Achievements() {
  const { achievements, xp, level, habits, completions } = useStore();

  const totalCompletions = Object.keys(completions).length;

  const allAchievements = [
    { id: 'first_habit', name: 'First Steps', desc: 'Complete your first habit', icon: CheckCircle, threshold: () => totalCompletions >= 1 },
    { id: '10_habits', name: 'Getting Started', desc: 'Complete 10 habits', icon: Target, threshold: () => totalCompletions >= 10 },
    { id: '50_habits', name: 'Consistency Master', desc: 'Complete 50 habits', icon: Award, threshold: () => totalCompletions >= 50 },
    { id: '100_habits', name: 'Unstoppable', desc: 'Complete 100 habits', icon: Zap, threshold: () => totalCompletions >= 100 },
    { id: 'level_5', name: 'Level 5 Reached', desc: 'Reach Level 5', icon: Star, threshold: () => level >= 5 },
    { id: 'level_10', name: 'Level 10 Reached', desc: 'Reach Level 10', icon: Shield, threshold: () => level >= 10 },
    { id: 'early_riser', name: 'Early Riser', desc: 'Complete a habit before 8 AM', icon: Clock, threshold: () => false }, // Placeholder logic
  ];

  return (
    <div className="space-y-8 pb-10">
      <div className="relative z-10">
        <h1 className="text-4xl font-display font-bold text-white tracking-tight flex items-center gap-3">
          Trophies & Milestones <Award className="text-[#FF8C42]" />
        </h1>
        <p className="text-textMuted mt-2 text-lg">Your legacy of productivity, immortalized.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 relative z-10">
        {allAchievements.map((achievement, i) => {
          const isUnlocked = achievement.threshold() || achievements.includes(achievement.id);
          const Icon = achievement.icon;
          
          return (
            <motion.div
              key={achievement.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.1 }}
              className={`p-6 rounded-3xl border transition-all duration-500 overflow-hidden relative group ${
                isUnlocked 
                  ? 'bg-white/5 border-[#FF6B2C]/30 hover:border-[#FF6B2C]/60 shadow-[0_0_30px_rgba(255,107,44,0.05)]' 
                  : 'bg-white/[0.02] border-white/5 opacity-60 grayscale'
              }`}
            >
              {isUnlocked && (
                <div className="absolute inset-0 bg-gradient-to-br from-[#FF6B2C]/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
              )}
              
              <div className="flex items-start gap-4 relative z-10">
                <div className={`w-14 h-14 rounded-2xl flex items-center justify-center shrink-0 ${
                  isUnlocked 
                    ? 'bg-gradient-to-tr from-[#FF6B2C] to-[#E85D04] text-white shadow-[0_0_20px_rgba(255,107,44,0.4)]' 
                    : 'bg-white/10 text-white/40'
                }`}>
                  <Icon size={28} />
                </div>
                <div>
                  <h3 className={`font-display font-bold text-xl mb-1 ${isUnlocked ? 'text-white' : 'text-white/60'}`}>
                    {achievement.name}
                  </h3>
                  <p className="text-sm text-textMuted leading-snug">
                    {achievement.desc}
                  </p>
                </div>
              </div>

              {isUnlocked && (
                <motion.div 
                  initial={{ scale: 0 }} animate={{ scale: 1 }}
                  className="absolute top-4 right-4 text-[#FF8C42]"
                >
                  <Sparkles size={16} />
                </motion.div>
              )}
            </motion.div>
          );
        })}
      </div>
    </div>
  );
}
