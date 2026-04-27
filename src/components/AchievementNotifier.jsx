import { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Award, Sparkles, X } from 'lucide-react';
import useStore from '../store/useStore';

export default function AchievementNotifier() {
  const achievements = useStore(state => state.achievements);
  const [lastCount, setLastCount] = useState(achievements.length);
  const [show, setShow] = useState(false);
  const [latestId, setLatestId] = useState(null);

  useEffect(() => {
    if (achievements.length > lastCount) {
      setLatestId(achievements[achievements.length - 1]);
      setShow(true);
      setLastCount(achievements.length);
      
      const timer = setTimeout(() => {
        setShow(false);
      }, 5000);
      return () => clearTimeout(timer);
    }
  }, [achievements, lastCount]);

  const getAchievementData = (id) => {
    const data = {
      'level-5': { title: 'Rising Star', desc: 'Reached Level 5' },
      'level-10': { title: 'Elite Performer', desc: 'Reached Level 10' },
      'xp-500': { title: 'Grinder', desc: 'Accumulated 500 XP' },
      'xp-1000': { title: 'Mastermind', desc: 'Accumulated 1000 XP' },
    };
    return data[id] || { title: 'Achievement Unlocked!', desc: 'You earned a new milestone.' };
  };

  const current = getAchievementData(latestId);

  return (
    <AnimatePresence>
      {show && (
        <motion.div
          initial={{ opacity: 0, y: 50, scale: 0.9 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          exit={{ opacity: 0, y: 20, scale: 0.9 }}
          className="fixed bottom-10 left-1/2 -translate-x-1/2 z-[200] w-[340px]"
        >
          <div className="glass-card p-6 rounded-[2rem] border border-[#FF6B2C]/40 bg-[#0A0A0B]/90 backdrop-blur-2xl shadow-[0_20px_50px_rgba(255,107,44,0.3)] flex items-center gap-5 relative overflow-hidden">
            {/* Cinematic Glow Background */}
            <div className="absolute inset-0 bg-gradient-to-r from-[#FF6B2C]/10 to-transparent pointer-events-none" />
            <motion.div 
              animate={{ opacity: [0.2, 0.5, 0.2] }} 
              transition={{ duration: 2, repeat: Infinity }}
              className="absolute -top-10 -right-10 w-32 h-32 bg-[#FF6B2C]/20 rounded-full blur-3xl" 
            />

            <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-[#FF6B2C] to-[#E85D04] flex items-center justify-center shadow-[0_0_25px_rgba(255,107,44,0.5)] shrink-0">
              <Award size={28} className="text-white" />
            </div>

            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 mb-1">
                <Sparkles size={12} className="text-[#FF8C42]" />
                <span className="text-[10px] font-bold text-[#FF8C42] uppercase tracking-[0.2em]">New Achievement</span>
              </div>
              <h4 className="text-white font-display font-bold text-lg truncate">{current.title}</h4>
              <p className="text-textMuted text-xs">{current.desc}</p>
            </div>

            <button onClick={() => setShow(false)} className="text-white/20 hover:text-white transition-colors p-1">
              <X size={16} />
            </button>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
