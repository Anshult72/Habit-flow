'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Sparkles, ArrowRight, Play, Cpu, Zap, Activity } from 'lucide-react';

const WORDS = [
  'Habits',
  'Analytics',
  'Calendar',
  'Streaks',
  'Focus',
  'Pomodoro',
  'Goals',
  'Discipline',
  'Matrix',
  'Features'
];

export default function FeaturesHero() {
  const [index, setIndex] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setIndex((prev) => (prev + 1) % WORDS.length);
    }, 2500);
    return () => clearInterval(timer);
  }, []);

  return (
    <section id="features" className="relative min-h-[90vh] flex flex-col items-center justify-center py-20 overflow-hidden bg-[#050505]">
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-[#FF6B2C]/5 rounded-full blur-[120px] opacity-40" />
        <div className="absolute top-1/4 left-1/4 w-[400px] h-[400px] bg-[#FF8C42]/3 rounded-full blur-[100px] opacity-20" />
        <div className="absolute bottom-1/4 right-1/4 w-[500px] h-[500px] bg-[#E85D04]/3 rounded-full blur-[100px] opacity-20" />

        <div className="absolute inset-0 opacity-20">
          {[...Array(20)].map((_, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0 }}
              animate={{
                opacity: [0.1, 0.4, 0.1],
                scale: [1, 1.2, 1],
                y: [0, -40, 0]
              }}
              transition={{
                duration: 4 + Math.random() * 4,
                repeat: Infinity,
                delay: Math.random() * 5
              }}
              className="absolute w-1 h-1 bg-white rounded-full"
              style={{
                left: `${Math.random() * 100}%`,
                top: `${Math.random() * 100}%`
              }}
            />
          ))}
        </div>
      </div>

      <div className="relative z-10 max-w-7xl mx-auto px-6 text-center">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full border border-white/5 bg-white/5 text-white/50 mb-10 backdrop-blur-xl"
        >
          <Cpu size={14} className="text-[#FF6B2C]" />
          <span className="text-[10px] font-bold uppercase tracking-[0.2em]">Next Gen Productivity</span>
        </motion.div>

        <div className="mb-10 flex flex-col items-center">
          <motion.h2
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-5xl md:text-7xl lg:text-8xl font-display font-bold text-white tracking-tight mb-4"
          >
            Master Your Productivity
          </motion.h2>

          <div className="flex flex-col md:flex-row items-center gap-4 text-5xl md:text-7xl lg:text-8xl font-display font-bold">
            <span className="text-white">with</span>
            <div className="h-[1.2em] relative overflow-hidden min-w-[300px] md:min-w-[450px]">
              <AnimatePresence mode="wait">
                <motion.span
                  key={WORDS[index]}
                  initial={{ y: '100%', opacity: 0 }}
                  animate={{ y: '0%', opacity: 1 }}
                  exit={{ y: '-100%', opacity: 0 }}
                  transition={{
                    duration: 0.8,
                    ease: [0.16, 1, 0.3, 1]
                  }}
                  className="absolute inset-0 flex items-center justify-center md:justify-start text-transparent bg-clip-text"
                  style={{ backgroundImage: 'linear-gradient(90deg, #FF6B2C, #FF8C42, #FFB347)' }}
                >
                  {WORDS[index]}
                </motion.span>
              </AnimatePresence>
            </div>
          </div>
        </div>

        <motion.p
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ delay: 0.4 }}
          className="text-lg md:text-xl text-text-muted max-w-3xl mx-auto font-light leading-relaxed mb-12"
        >
          A premium AI-powered productivity system designed to help you stay focused,
          build consistency, and achieve elite performance through cinematic data visualization.
        </motion.p>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ delay: 0.5 }}
          className="flex flex-col sm:flex-row items-center justify-center gap-5"
        >
          <button className="shine-sweep group relative flex items-center gap-3 px-10 py-5 rounded-2xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white font-bold text-lg shadow-[0_0_30px_rgba(255,107,44,0.3)] hover:shadow-[0_0_50px_rgba(255,107,44,0.6)] hover:-translate-y-1 transition-all duration-300">
            Explore Features
            <ArrowRight size={20} className="group-hover:translate-x-1 transition-transform" />
          </button>
          <button className="group relative flex items-center gap-3 px-10 py-5 rounded-2xl bg-white/5 border border-white/10 text-white font-semibold text-lg hover:bg-white/10 hover:border-[#FF6B2C]/40 transition-all duration-300">
            <Play size={18} className="text-[#FF8C42]" />
            Watch Demo
          </button>
        </motion.div>

        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ delay: 0.8 }}
          className="mt-24 flex flex-wrap justify-center gap-8 md:gap-16 opacity-40 grayscale hover:grayscale-0 transition-all duration-500"
        >
          <div className="flex items-center gap-2">
            <Zap size={16} />
            <span className="text-xs font-bold uppercase tracking-widest">Real-time Sync</span>
          </div>
          <div className="flex items-center gap-2">
            <Activity size={16} />
            <span className="text-xs font-bold uppercase tracking-widest">Advanced Metrics</span>
          </div>
          <div className="flex items-center gap-2">
            <Sparkles size={16} />
            <span className="text-xs font-bold uppercase tracking-widest">AI Insights</span>
          </div>
        </motion.div>
      </div>

      <div className="absolute bottom-0 left-0 right-0 h-32 bg-gradient-to-t from-[#050505] to-transparent pointer-events-none" />
    </section>
  );
}
