'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Users, Plus, X, Shield, Sword, Trophy, Target, Sparkles, Activity, Search } from 'lucide-react';
import useStore from '@/store/useStore';
import { apiFetch } from '@/lib/api';
import toast from 'react-hot-toast';

export default function Squads() {
  const { squads, user, syncData } = useStore();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [inviteModal, setInviteModal] = useState({ open: false, squadId: null });
  const [formData, setFormData] = useState({
    name: '',
    entryXP: 250,
    durationDays: 30,
  });
  const [inviteUserId, setInviteUserId] = useState('');
  const [loading, setLoading] = useState(false);

  const handleCreateSquad = async (e) => {
    e.preventDefault();
    if (user.xp < formData.entryXP) {
      toast.error('Insufficient XP');
      return;
    }
    setLoading(true);
    try {
      await apiFetch('/squads', {
        method: 'POST',
        body: JSON.stringify(formData),
      });
      toast.success('Squad Created!');
      setIsModalOpen(false);
      await syncData();
    } catch (err) {
      toast.error(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleInvite = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await apiFetch(`/squads/${inviteModal.squadId}/invite`, {
        method: 'POST',
        body: JSON.stringify({ targetUserId: inviteUserId }),
      });
      toast.success('Invitation sent!');
      setInviteUserId('');
      setInviteModal({ open: false, squadId: null });
    } catch (err) {
      toast.error(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleDisbandSquad = async (id) => {
    if (!window.confirm('Disband squad? This will refund XP to all members. This cannot be undone.')) return;
    setLoading(true);
    try {
      await apiFetch(`/squads/${id}`, { method: 'DELETE' });
      toast.success('Squad disbanded successfully');
      await syncData();
    } catch (err) {
      toast.error(err.message || 'Failed to disband squad');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-10 pb-20">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-6 relative z-10">
        <div>
          <motion.div initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }} className="flex items-center gap-2 px-3 py-1 rounded-full bg-blue-500/10 border border-blue-500/20 text-blue-400 text-[10px] font-bold uppercase tracking-[0.2em] mb-4">
            <Shield size={12} /> Collective Synchronization Active
          </motion.div>
          <h1 className="text-4xl md:text-5xl font-display font-bold text-white tracking-tight">
            Elite <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-indigo-500">Squads</span>
          </h1>
          <p className="text-text-muted mt-3 text-lg font-light max-w-2xl">
            Form high-performance collectives. Syndicate your efforts for massive XP rewards.
          </p>
        </div>
        <button 
          onClick={() => setIsModalOpen(true)}
          className="px-8 py-4 rounded-2xl bg-white text-black font-bold flex items-center gap-3 shadow-[0_0_30px_rgba(255,255,255,0.2)] hover:scale-105 transition-all"
        >
          <Plus size={20} /> Form Squad
        </button>
      </div>

      {squads.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {squads.map((squad) => {
            const isCreator = squad.createdBy === user?.id;
            return (
              <motion.div key={squad.id} initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} className="glass-card p-8 rounded-[3rem] border-white/5 relative overflow-hidden group">
                <div className="absolute top-0 right-0 p-8 text-blue-500 opacity-5 group-hover:opacity-10 transition-opacity"><Users size={150} /></div>
                
                {/* Disband Button for Creator */}
                {isCreator && squad.status !== 'completed' && (
                  <button 
                    onClick={() => handleDisbandSquad(squad.id)}
                    className="absolute top-6 right-6 w-10 h-10 rounded-xl bg-red-500/10 border border-red-500/20 text-red-500 flex items-center justify-center hover:bg-red-500 hover:text-white transition-all z-20 group/del"
                    title="Disband Squad & Refund Everyone"
                  >
                    <X size={18} />
                  </button>
                )}

                <div className="flex justify-between items-start mb-8 relative z-10">
                  <div>
                    <h3 className="text-2xl font-bold text-white mb-1">{squad.name}</h3>
                    <p className="text-[10px] text-blue-400 font-bold uppercase tracking-[0.2em]">Commander: {squad.createdBy === user?.id ? 'You' : (squad.creator?.name || 'Unknown')}</p>
                  </div>
                  <div className={`px-4 py-2 rounded-xl bg-white/5 border border-white/10 text-[10px] font-bold uppercase tracking-widest ${
                    squad.status === 'active' ? 'text-green-400' : 'text-yellow-400'
                  }`}>
                    {squad.status}
                  </div>
                </div>

              <div className="grid grid-cols-3 gap-4 mb-8 relative z-10">
                <div className="p-4 rounded-2xl bg-white/5 border border-white/10 text-center">
                  <p className="text-[9px] text-text-muted font-bold uppercase tracking-widest mb-1">Members</p>
                  <p className="text-lg font-bold text-white">{squad.members?.length || 0}</p>
                </div>
                <div className="p-4 rounded-2xl bg-white/5 border border-white/10 text-center">
                  <p className="text-[9px] text-text-muted font-bold uppercase tracking-widest mb-1">Entry XP</p>
                  <p className="text-lg font-bold text-white">{squad.entryXP}</p>
                </div>
                <div className="p-4 rounded-2xl bg-white/5 border border-white/10 text-center">
                  <p className="text-[9px] text-text-muted font-bold uppercase tracking-widest mb-1">Duration</p>
                  <p className="text-lg font-bold text-white">{squad.durationDays}d</p>
                </div>
              </div>

              <div className="space-y-4 mb-8 relative z-10">
                <p className="text-[10px] font-bold text-white/40 uppercase tracking-widest">Manifest</p>
                <div className="flex flex-wrap gap-2">
                  {squad.members?.map((m) => (
                    <div key={m.id} className="w-10 h-10 rounded-xl bg-white/5 border border-white/10 flex items-center justify-center overflow-hidden" title={m.user?.name}>
                      {m.user?.avatarUrl ? <img src={m.user.avatarUrl} className="w-full h-full object-cover" /> : <span className="text-white/40 text-xs font-bold">{m.user?.name?.[0]}</span>}
                    </div>
                  ))}
                  <button 
                    onClick={() => setInviteModal({ open: true, squadId: squad.id })}
                    className="w-10 h-10 rounded-xl bg-blue-500/10 border border-blue-500/20 flex items-center justify-center text-blue-400 hover:bg-blue-500/20 transition-all"
                  >
                    <Plus size={18} />
                  </button>
                </div>
              </div>

              <div className="mt-auto pt-6 border-t border-white/5 relative z-10">
                <button className="w-full py-4 rounded-2xl bg-white/5 text-white font-bold text-sm uppercase tracking-[0.2em] hover:bg-white/10 transition-all border border-white/10">View HQ</button>
              </div>
            </motion.div>
          );
        })}
      </div>
    ) : (
        <div className="p-20 rounded-[4rem] border border-dashed border-white/10 flex flex-col items-center justify-center text-center">
          <div className="w-24 h-24 rounded-full bg-white/5 flex items-center justify-center mb-8 text-white/20">
            <Shield size={48} />
          </div>
          <h3 className="text-3xl font-bold text-white tracking-tight mb-4">No Active Syndicates</h3>
          <p className="text-text-muted max-w-md text-lg font-light leading-relaxed">Form a squad to tackle long-term objectives with other high-performers.</p>
        </div>
      )}

      {/* Create Squad Modal */}
      <AnimatePresence>
        {isModalOpen && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-6">
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} onClick={() => setIsModalOpen(false)} className="absolute inset-0 bg-black/80 backdrop-blur-md" />
            <motion.div 
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              className="w-full max-w-lg bg-[#0A0A0A] border border-white/10 rounded-[3rem] p-10 relative z-10 shadow-[0_0_100px_rgba(59,130,246,0.2)]"
            >
              <button onClick={() => setIsModalOpen(false)} className="absolute top-8 right-8 text-white/20 hover:text-white transition-colors"><X size={24} /></button>
              
              <div className="flex items-center gap-4 mb-8">
                <div className="w-14 h-14 rounded-2xl bg-blue-500/10 border border-blue-500/20 flex items-center justify-center text-blue-400">
                  <Plus size={28} />
                </div>
                <div>
                  <h2 className="text-2xl font-bold text-white tracking-tight">Form Squad</h2>
                  <p className="text-text-muted text-sm uppercase tracking-widest font-bold text-blue-500/60">Elite Collective Initialization</p>
                </div>
              </div>

              <form onSubmit={handleCreateSquad} className="space-y-6">
                <div className="space-y-2">
                  <label className="text-[10px] font-bold text-white/40 uppercase tracking-[0.2em] ml-2">Squad Name</label>
                  <input 
                    required
                    placeholder="e.g. Protocol 7"
                    value={formData.name}
                    onChange={e => setFormData({...formData, name: e.target.value})}
                    className="w-full h-16 bg-white/5 border border-white/10 rounded-2xl px-6 text-white font-medium focus:border-blue-500/50 focus:bg-white/[0.08] transition-all outline-none"
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
                      className="w-full h-16 bg-white/5 border border-white/10 rounded-2xl px-6 text-white font-medium focus:border-blue-500/50 focus:bg-white/[0.08] transition-all outline-none"
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
                      className="w-full h-16 bg-white/5 border border-white/10 rounded-2xl px-6 text-white font-medium focus:border-blue-500/50 focus:bg-white/[0.08] transition-all outline-none"
                    />
                  </div>
                </div>

                <button 
                  disabled={loading}
                  className="w-full h-16 rounded-2xl bg-blue-600 text-white font-bold uppercase tracking-[0.2em] shadow-[0_0_30px_rgba(37,99,235,0.4)] hover:scale-[1.02] active:scale-[0.98] transition-all disabled:opacity-50"
                >
                  {loading ? 'Transmitting...' : 'Initialize Collective'}
                </button>
              </form>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* Invite Modal */}
      <AnimatePresence>
        {inviteModal.open && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-6">
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} onClick={() => setInviteModal({ open: false, squadId: null })} className="absolute inset-0 bg-black/80 backdrop-blur-md" />
            <motion.div 
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              className="w-full max-w-sm bg-[#0A0A0A] border border-white/10 rounded-[2.5rem] p-8 relative z-10 shadow-[0_0_80px_rgba(59,130,246,0.15)]"
            >
              <h2 className="text-xl font-bold text-white tracking-tight mb-6 flex items-center gap-2">
                <Users size={20} className="text-blue-400" /> Syndicate Invite
              </h2>

              <form onSubmit={handleInvite} className="space-y-4">
                <div className="space-y-2">
                  <label className="text-[10px] font-bold text-white/40 uppercase tracking-[0.2em] ml-2">Target User ID</label>
                  <input 
                    required
                    placeholder="Enter 8-digit ID"
                    value={inviteUserId}
                    onChange={e => setInviteUserId(e.target.value)}
                    className="w-full h-14 bg-white/5 border border-white/10 rounded-xl px-4 text-white font-medium focus:border-blue-500/50 outline-none"
                  />
                </div>

                <button 
                  disabled={loading}
                  className="w-full h-14 rounded-xl bg-blue-600 text-white font-bold uppercase tracking-widest text-xs hover:scale-[1.02] transition-all disabled:opacity-50"
                >
                  Send Protocol Invite
                </button>
              </form>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
