'use client';

import { motion } from 'framer-motion';
import { useRouter } from 'next/navigation';
import { 
  Zap, Activity, Target, Flame, Sparkles, ArrowRight,
  Shield, CheckCircle2, Globe, Brain
} from 'lucide-react';
import FeaturesHero from '@/components/FeaturesHero';

export default function FeaturesPage() {
  const router = useRouter();

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: { staggerChildren: 0.1, delayChildren: 0.2 }
    }
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.8, ease: [0.16, 1, 0.3, 1] }
    }
  };

  return (
    <div className="relative min-h-screen">
      <FeaturesHero />

      <section className="relative py-32 overflow-hidden bg-[#050505]">
        <div className="max-w-7xl mx-auto px-6 md:px-12">
          <div className="text-center mb-24">
            <h2 className="text-4xl md:text-6xl font-display font-bold text-white tracking-tight mb-6">Built for High Performance</h2>
            <p className="text-lg text-text-muted max-w-2xl mx-auto font-light">Experience the most advanced productivity toolset ever built for the modern digital era.</p>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {[
              { 
                title: 'Core Tracking', 
                icon: Activity, 
                desc: 'Dashboard, Habits, Calendar, and Analytics. Your daily productivity tracking engine.',
                color: 'from-[#FF6B2C] to-[#FF8C42]',
                modules: ['Dashboard', 'Habits', 'Calendar', 'Analytics', 'Reports']
              },
              { 
                title: 'Focus System', 
                icon: Zap, 
                desc: 'Deep work execution. Pomodoro timers, Stopwatches, and the Eisenhower Matrix.',
                color: 'from-[#FF8C42] to-[#FFB347]',
                modules: ['Focus Zone', 'Pomodoro', 'Timer', 'Stopwatch', 'Matrix']
              },
              { 
                title: 'Life Operating System', 
                icon: Target, 
                desc: 'Long-term life optimization. Mission countdowns, learning hubs, and vision boards.',
                color: 'from-[#E85D04] to-[#FF6B2C]',
                modules: ['Missions', 'Wishlist', 'Learning Hub', 'Memo', 'Vision Board']
              },
              { 
                title: 'Social & Gamification', 
                icon: Flame, 
                desc: 'Motivation and engagement. Compete on leaderboards, run duels, and join squads.',
                color: 'from-[#FF6B2C] to-[#E85D04]',
                modules: ['Leaderboard', 'Duels', 'Squads', 'Achievements']
              },
              { 
                title: 'Control Panel', 
                icon: Shield, 
                desc: 'Personalization and control. Custom themes, notifications, and preferences.',
                color: 'from-[#FFB347] to-[#FF8C42]',
                modules: ['Settings', 'Themes', 'Notifications', 'Account']
              },
              { 
                title: 'Global Sync', 
                icon: Globe, 
                desc: 'Seamless real-time synchronization across all your high-performance devices.',
                color: 'from-[#FF8C42] to-[#FF6B2C]',
                modules: ['Cloud Sync', 'Real-time', 'Multi-device', 'Secure']
              },
            ].map((feature, i) => (
              <motion.div 
                key={i}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.1 }}
                className="glass-card p-10 rounded-[2.5rem] border border-white/5 hover:border-[#FF6B2C]/30 transition-all group"
              >
                <div className={`w-14 h-14 rounded-2xl bg-gradient-to-br ${feature.color} p-[1px] mb-8 group-hover:scale-110 transition-transform`}>
                   <div className="w-full h-full rounded-2xl bg-[#050505] flex items-center justify-center">
                    <feature.icon size={28} className="text-[#FF6B2C]" />
                   </div>
                </div>
                <h3 className="text-2xl font-bold text-white mb-4">{feature.title}</h3>
                <p className="text-text-muted leading-relaxed mb-6">{feature.desc}</p>
                <div className="flex flex-wrap gap-2">
                  {feature.modules.map((mod, idx) => (
                    <span key={idx} className="px-3 py-1 rounded-lg bg-white/5 border border-white/10 text-xs font-medium text-white/70 group-hover:border-[#FF6B2C]/30 transition-colors">
                      {mod}
                    </span>
                  ))}
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      <section className="relative py-32 border-t border-white/5 overflow-hidden">
        <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-[#FF6B2C]/5 rounded-full blur-[120px] -translate-y-1/2 translate-x-1/4" />
        <div className="max-w-7xl mx-auto px-6 md:px-12 relative z-10">
          <div className="flex flex-col lg:flex-row items-center gap-20">
            <div className="flex-1">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42] text-[10px] font-bold uppercase tracking-[0.2em] mb-6">
                <Shield size={12} />
                Elite Framework
              </div>
              <h2 className="text-4xl md:text-6xl font-display font-bold text-white tracking-tight mb-8">Systemize Your Ordinary to Achieve the Extraordinary.</h2>
              <div className="space-y-6">
                {[
                  'Advanced habit stacking architecture',
                  'Atomic task decomposition',
                  'Frictionless routine automation',
                  'Customized productivity workflows'
                ].map((item, i) => (
                  <div key={i} className="flex items-center gap-4 group">
                    <div className="w-6 h-6 rounded-full bg-[#FF6B2C]/20 flex items-center justify-center text-[#FF6B2C] group-hover:bg-[#FF6B2C] group-hover:text-white transition-all">
                      <CheckCircle2 size={14} />
                    </div>
                    <span className="text-white/80 font-medium">{item}</span>
                  </div>
                ))}
              </div>
            </div>
            <div className="flex-1 w-full lg:w-auto relative">
              <div className="glass-card p-2 rounded-3xl border border-white/10 shadow-2xl relative">
                <div className="aspect-square bg-white/5 rounded-2xl flex items-center justify-center relative overflow-hidden">
                   <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(255,107,44,0.1),transparent)]" />
                   <Sparkles size={120} className="text-[#FF6B2C] opacity-20 animate-pulse" />
                   <div className="absolute inset-8 border border-white/5 rounded-xl flex items-center justify-center">
                      <div className="w-1/2 h-[2px] bg-gradient-to-r from-transparent via-[#FF6B2C] to-transparent animate-shimmer" />
                   </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="relative py-32 border-t border-white/5">
        <div className="max-w-7xl mx-auto px-6 md:px-12 text-center">
          <h2 className="text-4xl md:text-6xl font-display font-bold text-white tracking-tight mb-8">Data-Driven Evolution</h2>
          <p className="text-lg text-text-muted max-w-2xl mx-auto font-light mb-16">Understand your momentum with precision. HabitFlow translates your efforts into actionable insights.</p>
          <div className="glass-card p-1 rounded-[3rem] border border-white/10 shadow-[0_0_50px_rgba(255,107,44,0.1)]">
            <div className="aspect-[21/9] bg-[#0A0A0A] rounded-[2.8rem] overflow-hidden relative flex items-center justify-center">
               <div className="flex gap-4 items-end h-1/2 w-3/4">
                 {[40, 70, 45, 90, 65, 80, 50, 85, 60, 95].map((h, i) => (
                   <motion.div 
                     key={i}
                     initial={{ height: 0 }}
                     whileInView={{ height: `${h}%` }}
                     transition={{ delay: i * 0.1, duration: 1 }}
                     className="flex-1 bg-gradient-to-t from-[#FF6B2C] to-[#FF8C42] rounded-t-xl" 
                   />
                 ))}
               </div>
               <div className="absolute inset-0 flex items-center justify-center bg-black/40 backdrop-blur-sm opacity-0 hover:opacity-100 transition-opacity">
                 <button className="px-8 py-3 rounded-xl bg-[#FF6B2C] text-white font-bold shadow-lg">Preview Analytics</button>
               </div>
            </div>
          </div>
        </div>
      </section>

      <section className="relative py-32 overflow-hidden bg-gradient-to-b from-transparent to-[#080808]/50">
        <div className="max-w-7xl mx-auto px-6 md:px-12">
          <div className="flex flex-col lg:flex-row-reverse items-center gap-20">
            <div className="flex-1">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42] text-[10px] font-bold uppercase tracking-[0.2em] mb-6">
                <Brain size={12} />
                Cognitive Core
              </div>
              <h2 className="text-4xl md:text-6xl font-display font-bold text-white tracking-tight mb-8">AI-Powered Growth Engine.</h2>
              <p className="text-xl text-text-muted leading-relaxed mb-10 font-light">
                Our advanced algorithms learn your patterns and suggest habit adjustments that maximize your energy and focus.
              </p>
              <div className="grid grid-cols-2 gap-8">
                <div>
                   <h4 className="text-white font-bold mb-2">Smart Reminders</h4>
                   <p className="text-sm text-text-muted">Intelligent notification windows based on your alertness.</p>
                </div>
                <div>
                   <h4 className="text-white font-bold mb-2">Pattern Recognition</h4>
                   <p className="text-sm text-text-muted">Identify friction points in your routine before they break your streak.</p>
                </div>
              </div>
            </div>
            <div className="flex-1">
              <div className="relative group">
                <div className="absolute -inset-4 bg-[#FF6B2C]/10 rounded-[3rem] blur-3xl opacity-50 group-hover:opacity-100 transition-opacity" />
                <div className="relative glass-card p-12 rounded-[3rem] border border-white/10 flex items-center justify-center overflow-hidden">
                  <div className="absolute inset-0 bg-[#050505]/40 backdrop-blur-sm" />
                  <div className="relative z-10 space-y-4 w-full">
                    {[1,2,3].map(i => (
                      <div key={i} className="h-16 w-full rounded-2xl bg-white/5 border border-white/5 flex items-center px-6 gap-4">
                        <div className="w-8 h-8 rounded-full bg-[#FF6B2C]/20" />
                        <div className="flex-1 space-y-2">
                           <div className="h-2 w-3/4 bg-white/10 rounded-full" />
                           <div className="h-2 w-1/2 bg-white/5 rounded-full" />
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
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
            className="relative p-12 md:p-20 rounded-[4rem] bg-gradient-to-br from-[#FF6B2C]/20 to-[#E85D04]/5 border border-[#FF6B2C]/30 text-center overflow-hidden"
          >
            <div className="absolute top-0 left-0 w-full h-full bg-[radial-gradient(circle_at_center,rgba(255,107,44,0.1),transparent)]" />
            <div className="relative z-10">
              <h2 className="text-5xl md:text-7xl font-display font-bold text-white mb-8">Ready to Unleash?</h2>
              <p className="text-xl text-white/70 max-w-2xl mx-auto mb-12 font-light leading-relaxed">Join the elite ranks of high-performers who have systemized their success with HabitFlow.</p>
              <div className="flex flex-col sm:flex-row items-center justify-center gap-6">
                <button 
                  onClick={() => router.push('/app')}
                  className="shine-sweep px-10 py-5 rounded-2xl bg-white text-black font-bold text-xl shadow-[0_0_40px_rgba(255,255,255,0.2)] hover:scale-105 transition-all active:scale-95"
                >
                  Start Pro Trial
                </button>
                <button className="px-10 py-5 rounded-2xl bg-white/5 border border-white/10 text-white font-bold text-xl hover:bg-white/10 transition-all">
                  Join Discord
                </button>
              </div>
            </div>
          </motion.div>
        </div>
      </section>

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
