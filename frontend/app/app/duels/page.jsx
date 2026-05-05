'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Sword, Zap, Shield, Sparkles, TrendingUp, Trophy, ChevronRight, Activity, Flame, Award, Target, Swords, Plus, X, Users } from 'lucide-react';
import useStore from '@/store/useStore';
import { apiFetch } from '@/lib/api';
import toast from 'react-hot-toast';

export default function Duels() {
  const { duels, user, syncData } = useStore();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [formData, setFormData] = useState({
    entryXP: 100,
    durationDays: 7,
    targetUserId: '',
  });
  const [loading, setLoading] = useState(false);

  const handleCreateChallenge = async (e) => {
    e.preventDefault();
    if (user.xp < formData.entryXP) {
      toast.error('Insufficient XP for this entry fee');
      return;
    }
    setLoading(true);
    try {
      await apiFetch('/duels/challenge', {
        method: 'POST',
        body: JSON.stringify(formData),
      });
      toast.success('Challenge issued!');
      setIsModalOpen(false);
      await syncData();
    } catch (err) {
      toast.error(err.message || 'Failed to issue challenge');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteDuel = async (id) => {
    if (!window.confirm('Are you sure? This action cannot be undone.')) return;
    setLoading(true);
    try {
      await apiFetch(`/duels/${id}`, { method: 'DELETE' });
      toast.success('Duel cancelled successfully');
      await syncData();
    } catch (err) {
      toast.error(err.message || 'Failed to cancel duel');
    } finally {
      setLoading(false);
    }
  };

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
        <button 
          onClick={() => setIsModalOpen(true)}
          className="px-8 py-4 rounded-2xl bg-white text-black font-bold flex items-center gap-3 shadow-[0_0_30px_rgba(255,255,255,0.2)] hover:scale-105 transition-all"
        >
          <Plus size={20} /> Issue Challenge
        </button>
      </div>

      {duels.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {duels.map((duel) => {
            const self = duel.participants?.find(p => p.userId === user?.id) || { progress: 0 };
            const opponent = duel.participants?.find(p => p.userId !== user?.id) || duel.opponent;
            const opponentName = opponent?.name || 'Waiting for opponent...';
            const opponentInitial = opponentName.charAt(0).toUpperCase();
            const isCreator = duel.createdBy === user?.id;

            let daysLeft = 0;
            if (duel.endDate) {
              daysLeft = Math.max(0, Math.ceil((new Date(duel.endDate).getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24)));
            }

            return (
              <motion.div key={duel.id} initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} className="glass-card p-8 rounded-[3rem] border-white/5 relative overflow-hidden group">
                <div className="absolute top-0 right-0 p-8 text-[#FF6B2C] opacity-5 group-hover:opacity-10 transition-opacity"><Sword size={150} className="-rotate-45" /></div>
                
                {/* Delete/Cancel Button for Creator */}
                {isCreator && duel.status !== 'completed' && duel.status !== 'cancelled' && (
                  <button 
                    onClick={() => handleDeleteDuel(duel.id)}
                    className="absolute top-6 right-6 w-10 h-10 rounded-xl bg-red-500/10 border border-red-500/20 text-red-500 flex items-center justify-center hover:bg-red-500 hover:text-white transition-all z-20 group/del"
                    title={duel.status === 'active' ? 'Cancel Duel & Refund' : 'Delete Challenge'}
                  >
                    <X size={18} />
                  </button>
                )}

                <div className="flex justify-between items-center mb-10 relative z-10">
                  <div className="flex items-center gap-4">
                    <div className="w-12 h-12 rounded-2xl bg-gradient-to-tr from-[#FF6B2C] to-[#E85D04] flex items-center justify-center shadow-[0_0_15px_rgba(255,107,44,0.3)]">
                      <span className="text-white font-bold">U</span>
                    </div>
                    <div><p className="text-lg font-bold text-white">You</p><p className="text-[10px] text-text-muted font-bold uppercase tracking-widest">Score: {self.progress}</p></div>
                  </div>
                  <div className="text-center px-4 py-1.5 rounded-full bg-[#FF6B2C]/10 border border-[#FF6B2C]/30 text-[#FF8C42] text-[10px] font-bold uppercase tracking-[0.2em] shadow-[0_0_15px_rgba(255,107,44,0.1)]">VS</div>
                  <div className="flex items-center gap-4 text-right">
                    <div><p className="text-lg font-bold text-white truncate max-w-[100px]">{opponentName}</p><p className="text-[10px] text-text-muted font-bold uppercase tracking-widest">Score: {opponent?.progress || 0}</p></div>
                    <div className="w-12 h-12 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center text-white/40">
                      <span className="font-bold">{opponentInitial}</span>
                    </div>
                  </div>
                </div>

                <div className="space-y-8 relative z-10">
                  <div className="space-y-4">
                    <div className="flex justify-between items-end">
                      <p className="text-xs font-bold text-white uppercase tracking-widest">Consistency Progress</p>
                      <div className="flex gap-4">
                        <p className="text-[10px] font-bold text-[#FF8C42] uppercase tracking-widest">You: {self.progress}%</p>
                        <p className="text-[10px] font-bold text-white/40 uppercase tracking-widest">{opponentName}: {opponent?.progress || 0}%</p>
                      </div>
                    </div>
                    <div className="h-6 w-full bg-black/40 rounded-2xl overflow-hidden border border-white/5 relative p-1">
                      <motion.div initial={{ width: 0 }} animate={{ width: `${Math.min(self.progress, 100)}%` }} className="h-full bg-gradient-to-r from-[#FF6B2C] to-[#FFB347] rounded-xl relative z-10 shadow-[0_0_15px_rgba(255,107,44,0.4)]" />
                      <motion.div initial={{ width: 0 }} animate={{ width: `${Math.min(opponent?.progress || 0, 100)}%` }} className="absolute inset-1 h-4 bg-white/10 rounded-xl" />
                    </div>
                  </div>

                  <div className="grid grid-cols-3 gap-4">
                    <div className="p-4 rounded-2xl bg-white/5 border border-white/10 text-center">
                      <p className="text-[9px] text-text-muted font-bold uppercase tracking-widest mb-1">Entry Fee</p>
                      <p className="text-lg font-bold text-white">{duel.entryXP} XP</p>
                    </div>
                    <div className="p-4 rounded-2xl bg-white/5 border border-white/10 text-center">
                      <p className="text-[9px] text-text-muted font-bold uppercase tracking-widest mb-1">Prize Pool</p>
                      <p className="text-lg font-bold text-white">{duel.entryXP * 2} XP</p>
                    </div>
                    <div className="p-4 rounded-2xl bg-white/5 border border-white/10 text-center">
                      <p className="text-[9px] text-text-muted font-bold uppercase tracking-widest mb-1">Status</p>
                      <p className={`text-[10px] font-bold mt-2 uppercase ${
                        duel.status === 'active' ? 'text-green-400' : 
                        duel.status === 'pending' ? 'text-yellow-400' : 'text-red-400'
                      }`}>{duel.status}</p>
                    </div>
                  </div>
                </div>

                {duel.status === 'active' ? (
                  <div className="mt-10 flex gap-4">
                    <button className="flex-1 py-4 rounded-2xl bg-[#FF6B2C] text-white font-bold text-sm uppercase tracking-[0.2em] shadow-[0_0_30_rgba(255,107,44,0.4)] hover:scale-[1.02] transition-all">Submit Intel</button>
                    <div className="px-6 py-4 rounded-2xl bg-white/5 text-white font-bold text-sm uppercase tracking-widest border border-white/10 flex items-center justify-center">
                      {daysLeft}d left
                    </div>
                  </div>
                ) : (
                  <div className="mt-10 py-4 text-center rounded-2xl bg-white/5 border border-white/10 text-white/40 font-bold text-xs uppercase tracking-[0.2em]">
                    {duel.status === 'pending' ? 'Waiting for Acceptance' : duel.status === 'cancelled' ? 'Duel Cancelled' : 'Duel Concluded'}
                  </div>
                )}
              </motion.div>
            );
          })}
        </div>
      ) : (
        <div className="p-20 rounded-[4rem] border border-dashed border-white/10 flex flex-col items-center justify-center text-center">
          <div className="w-24 h-24 rounded-full bg-white/5 flex items-center justify-center mb-8 text-white/20">
            <Swords size={48} />
          </div>
          <h3 className="text-3xl font-bold text-white tracking-tight mb-4">Tactical Vacuum Detected</h3>
          <p className="text-text-muted max-w-md text-lg font-light leading-relaxed">You have no active or pending duels. Issue a direct challenge to a high-performer using their User ID.</p>
        </div>
      )}

      {/* Challenge Modal */}
      <AnimatePresence>
        {isModalOpen && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-6">
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} onClick={() => setIsModalOpen(false)} className="absolute inset-0 bg-black/80 backdrop-blur-md" />
            <motion.div 
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              className="w-full max-w-lg bg-[#0A0A0A] border border-white/10 rounded-[3rem] p-10 relative z-10 shadow-[0_0_100px_rgba(255,107,44,0.2)]"
            >
              <button onClick={() => setIsModalOpen(false)} className="absolute top-8 right-8 text-white/20 hover:text-white transition-colors"><X size={24} /></button>
              
              <div className="flex items-center gap-4 mb-8">
                <div className="w-14 h-14 rounded-2xl bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 flex items-center justify-center text-[#FF6B2C]">
                  <Sword size={28} />
                </div>
                <div>
                  <h2 className="text-2xl font-bold text-white tracking-tight">Issue Duel</h2>
                  <p className="text-text-muted text-sm uppercase tracking-widest font-bold">Protocol Alpha-1</p>
                </div>
              </div>

              <form onSubmit={handleCreateChallenge} className="space-y-6">
                <div className="space-y-2">
                  <label className="text-[10px] font-bold text-white/40 uppercase tracking-[0.2em] ml-2">Opponent User ID</label>
                  <input 
                    required
                    placeholder="Enter 8-digit numeric ID"
                    value={formData.targetUserId}
                    onChange={e => setFormData({...formData, targetUserId: e.target.value})}
                    className="w-full h-16 bg-white/5 border border-white/10 rounded-2xl px-6 text-white font-medium focus:border-[#FF6B2C]/50 focus:bg-white/[0.08] transition-all outline-none"
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <label className="text-[10px] font-bold text-white/40 uppercase tracking-[0.2em] ml-2">Entry Fee (XP)</label>
                    <input 
                      type="number"
                      required
                      min="0"
                      value={formData.entryXP}
                      onChange={e => setFormData({...formData, entryXP: e.target.value === '' ? '' : parseInt(e.target.value)})}
                      className="w-full h-16 bg-white/5 border border-white/10 rounded-2xl px-6 text-white font-medium focus:border-[#FF6B2C]/50 focus:bg-white/[0.08] transition-all outline-none"
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-bold text-white/40 uppercase tracking-[0.2em] ml-2">Duration (Days)</label>
                    <input 
                      type="number"
                      required
                      min="7"
                      max="90"
                      value={formData.durationDays}
                      onChange={e => setFormData({...formData, durationDays: e.target.value === '' ? '' : parseInt(e.target.value)})}
                      className="w-full h-16 bg-white/5 border border-white/10 rounded-2xl px-6 text-white font-medium focus:border-[#FF6B2C]/50 focus:bg-white/[0.08] transition-all outline-none"
                    />
                  </div>
                </div>

                <div className="p-6 rounded-2xl bg-[#FF6B2C]/5 border border-[#FF6B2C]/20 mt-4">
                  <div className="flex justify-between items-center">
                    <p className="text-sm text-text-muted font-medium">Winner's Bounty</p>
                    <p className="text-xl font-bold text-[#FF6B2C]">{formData.entryXP * 2} XP</p>
                  </div>
                </div>

                <button 
                  disabled={loading}
                  className="w-full h-16 rounded-2xl bg-[#FF6B2C] text-white font-bold uppercase tracking-[0.2em] shadow-[0_0_30px_rgba(255,107,44,0.4)] hover:scale-[1.02] active:scale-[0.98] transition-all disabled:opacity-50"
                >
                  {loading ? 'Transmitting...' : 'Initiate Challenge'}
                </button>
              </form>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
