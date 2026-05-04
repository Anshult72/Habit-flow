'use client';

import { motion } from 'framer-motion';
import { Sword, Zap, Shield, Sparkles, TrendingUp, Trophy, ChevronRight, Activity, Flame, Award, Target, Swords } from 'lucide-react';
import useStore from '@/store/useStore';

export default function Duels() {
  const { duels } = useStore();

  return (
    <div className="space-y-10 pb-20">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-6 relative z-10">
        <div>
          <motion.div initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }} className="flex items-center gap-2 px-3 py-1 rounded-full bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42] text-[10px] font-bold uppercase tracking-[0.2em] mb-4">
            <Swords size={12} /> Competitive Integrity Engaged
          </motion.div>
          <h1 className="text-4xl md:text-5xl font-display font-bold text-white tracking-tight">
            Tactical <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#FF6B2C] to-[#FFB347]">Duels</span>
          </h1>
          <p className="text-text-muted mt-3 text-lg font-light max-w-2xl">
            Challenge elite performers to 1v1 consistency trials. High stakes, higher rewards.
          </p>
        </div>
        <button className="px-8 py-4 rounded-2xl bg-white text-black font-bold flex items-center gap-3 shadow-[0_0_30px_rgba(255,255,255,0.2)] hover:scale-105 transition-all">
          <Sword size={20} /> Issue Challenge
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        {duels.map((duel) => (
          <motion.div key={duel.id} initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} className="glass-card p-8 rounded-[3rem] border-white/5 relative overflow-hidden group">
            <div className="absolute top-0 right-0 p-8 text-[#FF6B2C] opacity-5 group-hover:opacity-10 transition-opacity"><Sword size={150} className="-rotate-45" /></div>
            
            <div className="flex justify-between items-center mb-10 relative z-10">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-2xl bg-gradient-to-tr from-[#FF6B2C] to-[#E85D04] flex items-center justify-center shadow-[0_0_15px_rgba(255,107,44,0.3)]">
                  <span className="text-white font-bold">U</span>
                </div>
                <div><p className="text-lg font-bold text-white">You</p><p className="text-[10px] text-text-muted font-bold uppercase tracking-widest">Rank #142</p></div>
              </div>
              <div className="text-center px-4 py-1.5 rounded-full bg-[#FF6B2C]/10 border border-[#FF6B2C]/30 text-[#FF8C42] text-[10px] font-bold uppercase tracking-[0.2em] shadow-[0_0_15px_rgba(255,107,44,0.1)]">VS</div>
              <div className="flex items-center gap-4 text-right">
                <div><p className="text-lg font-bold text-white">{duel.opponent}</p><p className="text-[10px] text-text-muted font-bold uppercase tracking-widest">Rank #128</p></div>
                <div className="w-12 h-12 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center text-white/40">
                  <span className="font-bold">{duel.opponent[0]}</span>
                </div>
              </div>
            </div>

            <div className="space-y-8 relative z-10">
              <div className="space-y-4">
                <div className="flex justify-between items-end">
                  <p className="text-xs font-bold text-white uppercase tracking-widest">Consistency Progress</p>
                  <div className="flex gap-4">
                    <p className="text-[10px] font-bold text-[#FF8C42] uppercase tracking-widest">You: {duel.playerProgress}%</p>
                    <p className="text-[10px] font-bold text-white/40 uppercase tracking-widest">{duel.opponent}: {duel.opponentProgress}%</p>
                  </div>
                </div>
                <div className="h-6 w-full bg-black/40 rounded-2xl overflow-hidden border border-white/5 relative p-1">
                  <motion.div initial={{ width: 0 }} animate={{ width: `${duel.playerProgress}%` }} className="h-full bg-gradient-to-r from-[#FF6B2C] to-[#FFB347] rounded-xl relative z-10 shadow-[0_0_15px_rgba(255,107,44,0.4)]" />
                  <motion.div initial={{ width: 0 }} animate={{ width: `${duel.opponentProgress}%` }} className="absolute inset-1 h-4 bg-white/10 rounded-xl" />
                </div>
              </div>

              <div className="grid grid-cols-3 gap-4">
                <div className="p-4 rounded-2xl bg-white/5 border border-white/10 text-center">
                  <p className="text-[9px] text-text-muted font-bold uppercase tracking-widest mb-1">Time Remaining</p>
                  <p className="text-lg font-bold text-white">{duel.daysLeft || 0}d</p>
                </div>
                <div className="p-4 rounded-2xl bg-white/5 border border-white/10 text-center">
                  <p className="text-[9px] text-text-muted font-bold uppercase tracking-widest mb-1">Prize Pool</p>
                  <p className="text-lg font-bold text-white">500 XP</p>
                </div>
                <div className="p-4 rounded-2xl bg-white/5 border border-white/10 text-center">
                  <p className="text-[9px] text-text-muted font-bold uppercase tracking-widest mb-1">Badge</p>
                  <Award size={20} className="mx-auto text-yellow-400 mt-1" />
                </div>
              </div>
            </div>

            {duel.status === 'Active' ? (
              <button className="w-full mt-10 py-4 rounded-2xl bg-[#FF6B2C] text-white font-bold text-sm uppercase tracking-[0.2em] shadow-[0_0_30px_rgba(255,107,44,0.4)] hover:scale-[1.02] transition-all">Submit Daily Intelligence</button>
            ) : (
              <div className="mt-10 py-4 text-center rounded-2xl bg-white/5 border border-white/10 text-[#FF8C42] font-bold text-sm uppercase tracking-[0.2em]">Duel Concluded: {duel.winner} Won</div>
            )}
          </motion.div>
        ))}
      </div>
    </div>
  );
}
