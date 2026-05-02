'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useRouter } from 'next/navigation';
import { ArrowRight, Play, Sparkles, Activity, Zap, Shield, CheckCircle2, TrendingUp, Users, Globe, LayoutGrid, Rocket, Flame, Calendar } from 'lucide-react';

const WORDS = [
  'Consistency',
  'Discipline',
  'Focus',
  'Momentum',
  'Clarity',
  'Growth',
  'Mastery'
];

function WordTransition() {
  const [index, setIndex] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setIndex((prev) => (prev + 1) % WORDS.length);
    }, 2500);
    return () => clearInterval(timer);
  }, []);

  return (
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
  );
}

function HeroTypingAnimation() {
  const line1 = "Master Your";
  const line2 = "Daily Flow";
  
  const [text1, setText1] = useState("");
  const [text2, setText2] = useState("");
  const [isLine1Done, setIsLine1Done] = useState(false);
  const [isLine2Done, setIsLine2Done] = useState(false);

  useEffect(() => {
    let timeout;
    if (text1.length < line1.length) {
      timeout = setTimeout(() => {
        setText1(line1.slice(0, text1.length + 1));
      }, 80);
    } else {
      timeout = setTimeout(() => setIsLine1Done(true), 500);
    }
    return () => clearTimeout(timeout);
  }, [text1]);

  useEffect(() => {
    if (!isLine1Done) return;
    let timeout;
    if (text2.length < line2.length) {
      timeout = setTimeout(() => {
        setText2(line2.slice(0, text2.length + 1));
      }, 100);
    } else {
      setIsLine2Done(true);
    }
    return () => clearTimeout(timeout);
  }, [text2, isLine1Done]);

  return (
    <div className="flex flex-col items-center lg:items-start text-6xl md:text-8xl font-display font-bold text-white tracking-tighter mb-8 min-h-[2.4em]">
      <div className="flex items-center h-[1.1em]">
        <span>{text1}</span>
        {!isLine1Done && (
          <motion.span
            animate={{ opacity: [1, 0] }}
            transition={{ duration: 0.8, repeat: Infinity, ease: "linear" }}
            className="inline-block w-[4px] h-[0.8em] bg-[#FF6B2C] ml-2 shadow-[0_0_15px_#FF6B2C]"
          />
        )}
      </div>
      <div className="flex items-center h-[1.1em] text-[#FF8C42] drop-shadow-[0_0_20px_rgba(255,140,66,0.3)]">
        <span>{text2}</span>
        {isLine1Done && !isLine2Done && (
          <motion.span
            animate={{ opacity: [1, 0] }}
            transition={{ duration: 0.8, repeat: Infinity, ease: "linear" }}
            className="inline-block w-[4px] h-[0.8em] bg-[#FF6B2C] ml-2 shadow-[0_0_15px_#FF6B2C]"
          />
        )}
      </div>
    </div>
  );
}

export default function Landing() {
  const router = useRouter();

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.15,
        delayChildren: 0.3,
      },
    },
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 30 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { duration: 1, ease: [0.16, 1, 0.3, 1] },
    },
  };

  return (
    <div className="relative min-h-screen">
      <main>
        <section className="relative pt-32 pb-24 md:pt-40 md:pb-48 overflow-hidden">
          <div className="max-w-7xl mx-auto px-6 md:px-12 relative z-10">
            <motion.div
              variants={containerVariants}
              initial="hidden"
              animate="visible"
              className="flex flex-col lg:flex-row items-center gap-20"
            >
              <div className="flex-1 text-center lg:text-left">
                <motion.div
                  variants={itemVariants}
                  animate={{ y: [0, -8, 0] }}
                  transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
                  className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full border border-[#FF6B2C]/20 bg-[#FF6B2C]/5 text-[#FF8C42] mb-8 backdrop-blur-md shadow-[0_0_20px_rgba(255,107,44,0.1)]"
                >
                  <Sparkles size={14} className="text-[#FF6B2C]" />
                  <span className="text-xs font-bold tracking-[0.15em] uppercase">The Future of Consistency</span>
                </motion.div>
                
                <HeroTypingAnimation />                
                <motion.p 
                  variants={itemVariants}
                  className="text-xl md:text-2xl text-text-muted max-w-2xl mx-auto lg:mx-0 font-light leading-relaxed mb-12"
                >
                  Experience the ultimate cinematic productivity operating system. 
                  Track habits, conquer tasks, and visualize your growth in 
                  stunning high-fidelity.
                </motion.p>
                
                <motion.div 
                  variants={itemVariants}
                  className="flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-5"
                >
                  <button 
                    onClick={() => router.push('/onboarding')}
                    className="shine-sweep group relative flex items-center gap-3 px-8 py-4 rounded-2xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white font-bold text-lg shadow-[0_0_30px_rgba(255,107,44,0.3)] hover:shadow-[0_0_50px_rgba(255,107,44,0.6)] hover:-translate-y-1 transition-all duration-300 active:scale-95"
                  >
                    Start Tracking Now
                    <ArrowRight size={20} className="group-hover:translate-x-1 transition-transform" />
                  </button>
                  <button className="group relative flex items-center gap-3 px-8 py-4 rounded-2xl bg-white/5 border border-white/10 text-white font-semibold text-lg hover:bg-[#FF6B2C]/10 hover:border-[#FF6B2C]/40 hover:shadow-[0_0_20px_rgba(255,107,44,0.15)] hover:scale-[1.02] transition-all duration-300 active:scale-95 overflow-hidden">
                    <div className="absolute inset-0 rounded-2xl border border-transparent group-hover:border-[#FF6B2C]/30 transition-all duration-500" />
                    <Play size={18} className="text-[#FF8C42]" />
                    View Live Demo
                  </button>
                </motion.div>

                <motion.div 
                  variants={itemVariants}
                  className="mt-12 flex items-center justify-center lg:justify-start gap-8"
                >
                  <div className="flex -space-x-3">
                    {[1,2,3,4].map(i => (
                      <div key={i} className="w-10 h-10 rounded-full border-2 border-[#050505] bg-gradient-to-br from-[#FF6B2C] to-[#E85D04] flex items-center justify-center text-[10px] font-bold text-white shadow-lg overflow-hidden">
                        <img src={`https://i.pravatar.cc/100?u=${i}`} alt="user" className="w-full h-full object-cover opacity-80" />
                      </div>
                    ))}
                  </div>
                  <p className="text-sm text-text-muted font-medium">
                    Joined by <span className="text-white">12,000+</span> ambitious high-performers
                  </p>
                </motion.div>
              </div>
              
              <motion.div 
                variants={itemVariants}
                className="flex-1 w-full lg:w-auto relative"
              >
                <div className="relative group">
                  <div className="absolute -inset-1 bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] rounded-2xl blur-2xl opacity-20 group-hover:opacity-30 transition-opacity" />
                  <div className="relative glass-card rounded-2xl border border-white/10 p-2 overflow-hidden shadow-2xl">
                    <div className="aspect-[16/10] bg-[#050505] rounded-xl overflow-hidden relative">
                      <div className="absolute inset-0 p-6 flex flex-col gap-6">
                        <div className="h-8 flex justify-between items-center">
                          <div className="flex gap-2">
                            <div className="w-3 h-3 rounded-full bg-red-500/50" />
                            <div className="w-3 h-3 rounded-full bg-yellow-500/50" />
                            <div className="w-3 h-3 rounded-full bg-green-500/50" />
                          </div>
                          <div className="w-24 h-4 rounded-full bg-white/5" />
                        </div>
                        <div className="flex-1 grid grid-cols-3 gap-6">
                          <div className="col-span-2 flex flex-col gap-6">
                            <div className="h-32 rounded-xl bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 p-4">
                              <div className="w-1/3 h-4 bg-white/10 rounded-full mb-4" />
                              <div className="flex items-end gap-2 h-16">
                                {[40, 60, 35, 90, 55, 75, 45].map((h, i) => (
                                  <motion.div 
                                    key={i}
                                    initial={{ height: 0 }}
                                    animate={{ height: `${h}%` }}
                                    transition={{ delay: 1 + i * 0.1, duration: 1 }}
                                    className="flex-1 bg-gradient-to-t from-[#FF6B2C] to-[#FF8C42] rounded-t-sm" 
                                  />
                                ))}
                              </div>
                            </div>
                            <div className="flex-1 grid grid-cols-2 gap-6">
                              <div className="rounded-xl bg-white/5 border border-white/10 p-4">
                                <div className="w-1/2 h-3 bg-white/10 rounded-full mb-3" />
                                <div className="space-y-2">
                                  <div className="h-2 w-full bg-white/5 rounded-full" />
                                  <div className="h-2 w-3/4 bg-white/5 rounded-full" />
                                </div>
                              </div>
                              <div className="rounded-xl bg-white/5 border border-white/10 p-4">
                                <div className="w-1/2 h-3 bg-white/10 rounded-full mb-3" />
                                <div className="space-y-2">
                                  <div className="h-2 w-full bg-white/5 rounded-full" />
                                  <div className="h-2 w-3/4 bg-white/5 rounded-full" />
                                </div>
                              </div>
                            </div>
                          </div>
                          <div className="rounded-xl bg-[#FF6B2C]/5 border border-[#FF6B2C]/10 p-4 flex flex-col gap-4">
                            <div className="w-full h-24 rounded-lg bg-white/5" />
                            <div className="flex-1 space-y-3">
                              {[1,2,3,4].map(i => (
                                <div key={i} className="h-2 w-full bg-white/5 rounded-full" />
                              ))}
                            </div>
                          </div>
                        </div>
                      </div>
                      <motion.div 
                        animate={{ y: [0, -10, 0] }}
                        transition={{ duration: 5, repeat: Infinity, ease: "easeInOut" }}
                        className="absolute top-1/4 right-[-5%] w-32 p-4 glass-card rounded-xl border border-[#FF6B2C]/30 shadow-xl"
                      >
                        <div className="flex items-center gap-2 mb-2">
                          <Flame size={14} className="text-[#FF6B2C]" />
                          <span className="text-[10px] font-bold text-white">STREAK</span>
                        </div>
                        <div className="text-2xl font-display font-bold text-white">42</div>
                        <div className="text-[8px] text-text-muted uppercase mt-1 tracking-wider">Days in a row</div>
                      </motion.div>
                    </div>
                  </div>
                </div>
              </motion.div>
            </motion.div>
          </div>
        </section>

        <section className="relative py-24 border-y border-white/5">
          <div className="max-w-7xl mx-auto px-6 md:px-12">
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-12 lg:gap-8">
              {[
                { label: 'Active Users', value: '12K+', icon: Users },
                { label: 'Habits Tracked', value: '1.2M', icon: CheckCircle2 },
                { label: 'Consistency Rate', value: '98%', icon: TrendingUp },
                { label: 'Global Rank', value: '#1', icon: Globe },
              ].map((stat, i) => (
                <motion.div 
                  key={i}
                  initial={{ opacity: 0, y: 20 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ delay: i * 0.1 }}
                  className="flex flex-col items-center lg:items-start text-center lg:text-left group"
                >
                  <div className="w-12 h-12 rounded-xl bg-white/5 border border-white/10 flex items-center justify-center mb-6 group-hover:bg-[#FF6B2C]/10 group-hover:border-[#FF6B2C]/30 transition-all">
                    <stat.icon size={22} className="text-[#FF6B2C]" />
                  </div>
                  <div className="text-4xl md:text-5xl font-display font-bold text-white mb-2">{stat.value}</div>
                  <div className="text-sm text-text-muted font-medium uppercase tracking-widest">{stat.label}</div>
                </motion.div>
              ))}
            </div>
          </div>
        </section>

        <section className="relative py-32 overflow-hidden">
          <div className="max-w-7xl mx-auto px-6 md:px-12 relative z-10">
            <div className="flex flex-col items-center text-center">
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full border border-[#FF6B2C]/15 bg-[#050505]/40 text-[#FF8C42]/70 mb-8 backdrop-blur-xl"
              >
                <Sparkles size={14} className="text-[#FF6B2C]/60" />
                <span className="text-xs font-medium tracking-[0.15em] uppercase">Core Capabilities</span>
              </motion.div>
              
              <h2 className="text-4xl md:text-7xl font-display font-bold text-white tracking-tight mb-12">
                Elevate your productivity <br />
                <div className="h-[1.2em] relative overflow-hidden inline-block min-w-[280px] md:min-w-[420px] align-bottom">
                  <WordTransition />
                </div>
              </h2>
              
              <p className="text-xl text-text-muted max-w-2xl font-light mb-20 leading-relaxed">
                Experience a unified operating system for your life. Every feature is designed 
                with a cinematic focus to keep you engaged and consistent.
              </p>

              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 w-full">
                {[
                  { title: 'Strategic Matrix', desc: 'Prioritize tasks with our 2x2 Eisenhower system.', icon: LayoutGrid },
                  { title: 'Goal Missions', desc: 'Set long-term life milestones with live countdowns.', icon: Rocket },
                  { title: 'Deep Focus Zone', desc: 'Immersive timers and analytics for peak flow.', icon: Zap },
                  { title: 'Daily Planner', desc: 'Plan your entire day with structured time blocks and stay in control.', icon: Calendar }
                ].map((f, i) => {
                  const Icon = f.icon;
                  return (
                    <div key={i} className="glass-card p-10 rounded-[2.5rem] border-white/5 text-left hover:border-[#FF6B2C]/20 transition-all group/feat">
                      <div className="w-14 h-14 rounded-2xl bg-[#FF6B2C]/10 flex items-center justify-center text-[#FF6B2C] mb-8 group-hover/feat:bg-[#FF6B2C] group-hover/feat:text-white transition-all">
                        <Icon size={28} />
                      </div>
                      <h3 className="text-2xl font-bold text-white mb-4">{f.title}</h3>
                      <p className="text-text-muted leading-relaxed text-sm">{f.desc}</p>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        </section>

        <section className="relative py-32">
          <div className="max-w-5xl mx-auto px-6 md:px-12">
            <motion.div 
              initial={{ opacity: 0, scale: 0.95 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              className="relative p-12 md:p-20 rounded-[3rem] bg-gradient-to-br from-[#FF6B2C]/10 to-[#E85D04]/5 border border-[#FF6B2C]/20 text-center overflow-hidden"
            >
              <div className="absolute top-0 left-0 w-full h-full bg-[radial-gradient(circle_at_center,rgba(255,107,44,0.1),transparent)]" />
              <div className="relative z-10">
                <h2 className="text-5xl md:text-7xl font-display font-bold text-white mb-8">Ready to Level Up?</h2>
                <p className="text-xl text-white/70 max-w-2xl mx-auto mb-12 font-light">Join thousands of high-performers and start your journey towards mastery today.</p>
                <button 
                  onClick={() => router.push('/onboarding')}
                  className="shine-sweep px-10 py-5 rounded-2xl bg-white text-black font-bold text-xl shadow-[0_0_40px_rgba(255,255,255,0.2)] hover:scale-105 transition-all active:scale-95"
                >
                  Get Started for Free
                </button>
              </div>
            </motion.div>
          </div>
        </section>
      </main>

      <footer className="relative py-20 border-t border-white/5">
        <div className="max-w-7xl mx-auto px-6 md:px-12 flex flex-col md:flex-row justify-between items-center gap-8">
          <div className="flex items-center gap-3">
            <img src="/assets/eagle-logo-transparent.png" alt="HabitFlow" className="w-8 h-8 object-contain" />
            <span className="text-white font-bold text-lg">HabitFlow</span>
          </div>
          <p className="text-text-muted text-sm">© 2026 HabitFlow AI. All rights reserved.</p>
          <div className="flex gap-8 text-sm text-white/50">
            <button className="hover:text-white transition-colors">Twitter</button>
            <button className="hover:text-white transition-colors">Discord</button>
            <button className="hover:text-white transition-colors">Privacy</button>
          </div>
        </div>
      </footer>
    </div>
  );
}
