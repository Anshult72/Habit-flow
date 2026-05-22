'use client';

import { useState, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Zap, Flame, Trophy, Star, Sparkles, Award } from 'lucide-react';

/**
 * XP Toast notification system for Learning Hub.
 * Shows premium XP reward feedback with animations.
 */

// Global event system for XP toasts
const xpEventListeners = new Set();

export function emitXpEvent(event) {
  xpEventListeners.forEach(listener => listener(event));
}

export function XpToastProvider({ children }) {
  const [toasts, setToasts] = useState([]);

  const addToast = useCallback((event) => {
    const id = crypto.randomUUID();
    setToasts(prev => [...prev, { ...event, id }]);
    setTimeout(() => {
      setToasts(prev => prev.filter(t => t.id !== id));
    }, event.duration || 3500);
  }, []);

  useEffect(() => {
    xpEventListeners.add(addToast);
    return () => xpEventListeners.delete(addToast);
  }, [addToast]);

  return (
    <>
      {children}
      <div className="fixed top-6 right-6 z-[9999] flex flex-col gap-3 pointer-events-none" style={{ maxWidth: '420px' }}>
        <AnimatePresence mode="popLayout">
          {toasts.map((toast) => (
            <XpToast key={toast.id} toast={toast} />
          ))}
        </AnimatePresence>
      </div>
    </>
  );
}

function XpToast({ toast }) {
  const { type, xp, message, subMessage, streakDays, milestone } = toast;

  const configs = {
    'topic-xp': {
      icon: Zap,
      gradient: 'from-[#FF6B2C] to-[#E85D04]',
      glow: 'rgba(255, 107, 44, 0.4)',
      border: 'border-[#FF6B2C]/30',
    },
    'level-up': {
      icon: Sparkles,
      gradient: 'from-[#10B981] to-[#059669]',
      glow: 'rgba(16, 185, 129, 0.4)',
      border: 'border-[#10B981]/30',
    },
    'module-bonus': {
      icon: Trophy,
      gradient: 'from-[#FFD700] to-[#FFA500]',
      glow: 'rgba(255, 215, 0, 0.4)',
      border: 'border-[#FFD700]/30',
    },
    'chapter-bonus': {
      icon: Award,
      gradient: 'from-[#8B5CF6] to-[#7C3AED]',
      glow: 'rgba(139, 92, 246, 0.4)',
      border: 'border-[#8B5CF6]/30',
    },
    'streak-milestone': {
      icon: Flame,
      gradient: 'from-[#FF6B2C] to-[#FFD700]',
      glow: 'rgba(255, 107, 44, 0.5)',
      border: 'border-[#FFD700]/30',
    },
    'xp-capped': {
      icon: Star,
      gradient: 'from-[#475569] to-[#334155]',
      glow: 'rgba(71, 85, 105, 0.3)',
      border: 'border-white/10',
    },
  };

  const config = configs[type] || configs['topic-xp'];
  const Icon = config.icon;

  return (
    <motion.div
      layout
      initial={{ opacity: 0, x: 100, scale: 0.8 }}
      animate={{ opacity: 1, x: 0, scale: 1 }}
      exit={{ opacity: 0, x: 80, scale: 0.9 }}
      transition={{ type: 'spring', stiffness: 400, damping: 30 }}
      className={`pointer-events-auto relative overflow-hidden rounded-2xl border ${config.border} backdrop-blur-xl`}
      style={{
        background: 'rgba(10, 10, 10, 0.9)',
        boxShadow: `0 20px 60px -10px ${config.glow}, 0 0 0 1px rgba(255,255,255,0.05)`,
      }}
    >
      {/* Animated glow bar at top */}
      <motion.div
        className={`absolute top-0 left-0 right-0 h-0.5 bg-gradient-to-r ${config.gradient}`}
        initial={{ scaleX: 0 }}
        animate={{ scaleX: 1 }}
        transition={{ duration: 0.5, ease: 'easeOut' }}
        style={{ transformOrigin: 'left' }}
      />

      <div className="flex items-center gap-4 p-4 pr-6">
        {/* Icon container */}
        <motion.div
          initial={{ rotate: -20, scale: 0 }}
          animate={{ rotate: 0, scale: 1 }}
          transition={{ type: 'spring', stiffness: 500, damping: 15, delay: 0.1 }}
          className={`w-12 h-12 rounded-xl bg-gradient-to-br ${config.gradient} flex items-center justify-center flex-shrink-0 shadow-lg`}
          style={{ boxShadow: `0 8px 25px ${config.glow}` }}
        >
          <Icon size={22} className="text-white" />
        </motion.div>

        {/* Content */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2">
            <span className="text-white font-bold text-sm truncate">{message}</span>
            {type === 'streak-milestone' && (
              <motion.div
                animate={{ rotate: [0, 15, -15, 0] }}
                transition={{ duration: 0.5, repeat: 2 }}
              >
                <Sparkles size={14} className="text-[#FFD700]" />
              </motion.div>
            )}
          </div>
          {subMessage && (
            <p className="text-[10px] text-white/40 font-bold uppercase tracking-widest mt-0.5">{subMessage}</p>
          )}
        </div>

        {/* XP Amount */}
        {xp > 0 && (
          <motion.div
            initial={{ scale: 0, y: 10 }}
            animate={{ scale: 1, y: 0 }}
            transition={{ type: 'spring', stiffness: 500, damping: 20, delay: 0.2 }}
            className="flex items-center gap-1.5 flex-shrink-0"
          >
            <span className={`text-xl font-black bg-gradient-to-r ${config.gradient} bg-clip-text text-transparent`}>
              +{xp}
            </span>
            <span className="text-[9px] font-black uppercase tracking-widest text-white/30">XP</span>
          </motion.div>
        )}
      </div>

      {/* Streak milestone extra flair */}
      {type === 'streak-milestone' && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="px-4 pb-3 flex items-center gap-2"
        >
          <Flame size={12} className="text-[#FFD700]" />
          <span className="text-[10px] font-black uppercase tracking-widest text-[#FFD700]/60">
            {streakDays}-Day Streak Achieved
          </span>
          <div className="flex-1 h-px bg-gradient-to-r from-[#FFD700]/20 to-transparent" />
        </motion.div>
      )}
    </motion.div>
  );
}

/**
 * Full-screen celebration overlay for major milestones.
 */
export function CelebrationOverlay({ show, type, onComplete }) {
  useEffect(() => {
    if (show) {
      const timer = setTimeout(() => onComplete?.(), 3000);
      return () => clearTimeout(timer);
    }
  }, [show, onComplete]);

  const configs = {
    'module-complete': {
      title: 'MODULE MASTERED',
      subtitle: 'Knowledge Node Finalized',
      icon: Trophy,
      gradient: 'from-[#FFD700] to-[#FFA500]',
      particles: '#FFD700',
    },
    'chapter-complete': {
      title: 'CHAPTER CONQUERED',
      subtitle: 'Knowledge Pathway Complete',
      icon: Award,
      gradient: 'from-[#8B5CF6] to-[#7C3AED]',
      particles: '#8B5CF6',
    },
    'streak-7': {
      title: '7-DAY STREAK',
      subtitle: 'Commitment Protocol Active',
      icon: Flame,
      gradient: 'from-[#3B82F6] to-[#2563EB]',
      particles: '#3B82F6',
    },
    'streak-21': {
      title: '21-DAY STREAK',
      subtitle: 'Dedication Protocol Active',
      icon: Flame,
      gradient: 'from-[#FFD700] to-[#FFA500]',
      particles: '#FFD700',
    },
    'streak-90': {
      title: '90-DAY STREAK',
      subtitle: 'Legendary Protocol Achieved',
      icon: Flame,
      gradient: 'from-[#FF6B2C] to-[#E85D04]',
      particles: '#FF6B2C',
    },
  };

  const config = configs[type] || configs['module-complete'];
  const Icon = config.icon;

  return (
    <AnimatePresence>
      {show && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.3 }}
          className="fixed inset-0 z-[10000] flex items-center justify-center bg-black/80 backdrop-blur-xl"
          onClick={() => onComplete?.()}
        >
          {/* Particle burst effect */}
          <div className="absolute inset-0 overflow-hidden pointer-events-none">
            {Array.from({ length: 20 }).map((_, i) => (
              <motion.div
                key={i}
                initial={{
                  x: '50%',
                  y: '50%',
                  scale: 0,
                  opacity: 1,
                }}
                animate={{
                  x: `${20 + Math.random() * 60}%`,
                  y: `${10 + Math.random() * 80}%`,
                  scale: [0, 1.5, 0],
                  opacity: [1, 0.8, 0],
                }}
                transition={{
                  duration: 1.5 + Math.random(),
                  delay: Math.random() * 0.5,
                  ease: 'easeOut',
                }}
                className="absolute w-2 h-2 rounded-full"
                style={{ backgroundColor: config.particles }}
              />
            ))}
          </div>

          {/* Main content */}
          <motion.div
            initial={{ scale: 0.5, y: 40 }}
            animate={{ scale: 1, y: 0 }}
            exit={{ scale: 0.8, opacity: 0 }}
            transition={{ type: 'spring', stiffness: 300, damping: 20 }}
            className="relative text-center space-y-8"
          >
            <motion.div
              initial={{ scale: 0, rotate: -180 }}
              animate={{ scale: 1, rotate: 0 }}
              transition={{ type: 'spring', stiffness: 200, damping: 15, delay: 0.2 }}
              className={`w-28 h-28 mx-auto rounded-3xl bg-gradient-to-br ${config.gradient} flex items-center justify-center shadow-2xl`}
              style={{ boxShadow: `0 20px 60px ${config.particles}50` }}
            >
              <Icon size={56} className="text-white" />
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.4 }}
              className="space-y-3"
            >
              <h2 className={`text-5xl md:text-6xl font-display font-black bg-gradient-to-r ${config.gradient} bg-clip-text text-transparent tracking-tight`}>
                {config.title}
              </h2>
              <p className="text-white/40 text-xs font-black uppercase tracking-[0.4em]">
                {config.subtitle}
              </p>
            </motion.div>

            <motion.p
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 1.5 }}
              className="text-white/20 text-[10px] font-bold uppercase tracking-widest"
            >
              Tap anywhere to continue
            </motion.p>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
