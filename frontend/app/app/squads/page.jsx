'use client';

import { motion } from 'framer-motion';
import { Users, Zap, Shield, Sparkles, TrendingUp, Trophy, ChevronRight, Activity, Flame } from 'lucide-react';
import useStore from '@/store/useStore';

export default function Squads() {
  const { squads } = useStore();

  return (
    <div className="space-y-10 pb-20">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-6 relative z-10">
        <div>
          <motion.div initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }} className="flex items-center gap-2 px-3 py-1 rounded-full bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42] text-[10px] font-bold uppercase tracking-[0.2em] mb-4">
            <Users size={12} /> Collective Synchronization
          </motion.div>
          <h1 className="text-4xl md:text-5xl font-display font-bold text-white tracking-tight">
            Productivity <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#FF6B2C] to-[#FFB347]">Squads</span>
          </h1>
          <p className="text-text-muted mt-3 text-lg font-light max-w-2xl">
            Join elite tactical units and achieve synchronized productivity bonuses.
          </p>
        </div>
        <button className="px-8 py-4 rounded-2xl bg-white text-black font-bold flex items-center gap-3 shadow-[0_0_30px_rgba(255,255,255,0.2)] hover:scale-105 transition-all">
          <Sparkles size={20} /> Create Squad
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 space-y-6">
          {squads.map((squad) => (
            <motion.div key={squad.id} initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="glass-card p-8 rounded-[2.5rem] border-white/5 relative overflow-hidden group">
              <div className="absolute top-0 right-0 p-8 text-white opacity-5 group-hover:opacity-10 transition-opacity"><Users size={120} /></div>
              <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6 mb-10">
                <div className="flex items-center gap-6">
                  <div className="w-16 h-16 rounded-2xl bg-gradient-to-tr from-[#FF6B2C] to-[#FFB347] flex items-center justify-center shadow-[0_0_25px_rgba(255,107,44,0.3)]">
                    <Users size={32} className="text-white" />
                  </div>
                  <div>
                    <h3 className="text-2xl font-display font-bold text-white mb-1">{squad.name}</h3>
                    <div className="flex items-center gap-3">
                      <span className="text-[10px] px-2 py-0.5 bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 rounded text-[#FF8C42] uppercase tracking-widest font-bold">Level 12 Unit</span>
                      <span className="text-[10px] text-text-muted font-bold uppercase tracking-widest flex items-center gap-1"><Activity size={12} /> {squad.members.length} Members</span>
                    </div>
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-[10px] text-text-muted font-bold uppercase tracking-widest mb-1">Squad Consistency</p>
                  <p className="text-3xl font-display font-bold text-white">{squad.consistency}%</p>
                </div>
              </div>

              <div className="grid grid-cols-2 md:grid-cols-5 gap-4 mb-10">
                {squad.members.map((member, i) => (
                  <div key={i} className="flex flex-col items-center gap-3">
                    <div className="relative">
                      <div className="w-14 h-14 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center text-white/40 font-bold group-hover:border-[#FF6B2C]/40 transition-colors">
                        {member[0]}
                      </div>
                      <div className="absolute -bottom-1 -right-1 w-4 h-4 rounded-full bg-green-500 border-2 border-[#0A0A0B]" />
                    </div>
                    <p className="text-[10px] font-bold text-text-muted uppercase tracking-wider">{member}</p>
                    <div className="w-10 h-1 bg-white/10 rounded-full overflow-hidden">
                      <motion.div initial={{ width: 0 }} animate={{ width: `${80 + Math.random() * 20}%` }} className="h-full bg-[#FF6B2C]" />
                    </div>
                  </div>
                ))}
              </div>

              <div className="flex items-center justify-between p-6 rounded-2xl bg-[#FF6B2C]/5 border border-[#FF6B2C]/10">
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 rounded-xl bg-[#FF6B2C]/20 flex items-center justify-center border border-[#FF6B2C]/30 shadow-[0_0_15px_rgba(255,107,44,0.2)]">
                    <Zap size={24} className="text-[#FF8C42]" />
                  </div>
                  <div>
                    <p className="text-sm font-bold text-white">Synchronization Bonus Active</p>
                    <p className="text-xs text-text-muted mt-0.5">All members consistent today. +25% XP multiplier engaged.</p>
                  </div>
                </div>
                <motion.div animate={{ opacity: [0.5, 1, 0.5] }} transition={{ duration: 2, repeat: Infinity }} className="px-4 py-2 rounded-xl bg-[#FF6B2C] text-white text-[10px] font-bold uppercase tracking-widest">
                  1.25x Active
                </motion.div>
              </div>
            </motion.div>
          ))}
        </div>

        <div className="space-y-8">
          <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} className="glass-card p-8 rounded-[2.5rem] border-white/5 relative overflow-hidden group">
            <h3 className="text-lg font-bold text-white mb-6">Squad Objectives</h3>
            <div className="space-y-4">
              {[
                { label: 'Weekly Group Goal', value: '450/500 Protocols', progress: 90 },
                { label: 'Total XP Pool', value: '12.4K', progress: 65 },
                { label: 'Unit Ranking', value: 'Global #42', progress: 88 },
              ].map((obj, i) => (
                <div key={i}>
                  <div className="flex justify-between text-[10px] font-bold uppercase tracking-widest mb-2">
                    <span className="text-text-muted">{obj.label}</span>
                    <span className="text-white">{obj.value}</span>
                  </div>
                  <div className="h-1.5 w-full bg-white/5 rounded-full overflow-hidden">
                    <motion.div initial={{ width: 0 }} whileInView={{ width: `${obj.progress}%` }} className="h-full bg-gradient-to-r from-[#FF6B2C] to-[#FFB347]" />
                  </div>
                </div>
              ))}
            </div>
            <button className="w-full mt-8 py-3 rounded-xl border border-white/10 hover:border-[#FF6B2C]/40 text-[10px] font-bold text-text-muted hover:text-white uppercase tracking-widest transition-all">Mission Intel</button>
          </motion.div>

          <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} className="glass-card p-8 rounded-[2.5rem] border-[#FF6B2C]/20 bg-[#FF6B2C]/5 relative overflow-hidden group">
            <div className="absolute top-0 right-0 p-6 opacity-5 text-[#FF6B2C] group-hover:opacity-10 transition-opacity"><Trophy size={80} /></div>
            <div className="relative z-10">
              <h3 className="text-lg font-bold text-white mb-2">Squad Hall of Fame</h3>
              <p className="text-xs text-text-muted mb-6 leading-relaxed">The most synchronized units in the HabitFlow ecosystem.</p>
              <div className="space-y-4">
                {[
                  { name: 'Zen Masters', cons: 99 },
                  { name: 'Code Runners', cons: 97 },
                  { name: 'Deep Work Unit', cons: 96 },
                ].map((top, i) => (
                  <div key={i} className="flex items-center justify-between p-3 rounded-xl bg-black/40 border border-white/5">
                    <div className="flex items-center gap-3">
                      <span className="text-xs font-bold text-text-muted">#{i+1}</span>
                      <span className="text-sm font-bold text-white">{top.name}</span>
                    </div>
                    <span className="text-xs font-bold text-[#FF8C42]">{top.cons}%</span>
                  </div>
                ))}
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </div>
  );
}
