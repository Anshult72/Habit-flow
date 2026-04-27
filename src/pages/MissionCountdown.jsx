import { useState, useEffect, useMemo } from 'react';
import { motion, AnimatePresence, useScroll, useTransform } from 'framer-motion';
import { 
  Rocket, Target, Clock, Trophy, Plus, 
  ChevronRight, Sparkles, Zap, Brain, 
  X, Calendar, Quote, Link2, TrendingUp,
  Shield, Flame, Star, Activity, Monitor
} from 'lucide-react';
import { format, differenceInDays, differenceInSeconds, addDays, parseISO } from 'date-fns';
import useStore from '../store/useStore';

export default function MissionCountdown() {
  const { missions, habits, completions, addMission, updateMission, deleteMission } = useStore();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedMission, setSelectedMission] = useState(null);
  const [visionModeId, setVisionModeId] = useState(null);

  const activeMission = useMemo(() => 
    missions.find(m => m.id === visionModeId) || missions[0]
  , [missions, visionModeId]);

  return (
    <div className="min-h-screen bg-[#050505] text-white pb-20 overflow-x-hidden">
      {/* Background Ambience */}
      <div className="fixed inset-0 pointer-events-none z-0">
        <div className="absolute top-[10%] left-[-10%] w-[50%] h-[50%] bg-[#FF6B2C]/5 rounded-full blur-[120px] animate-pulse" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-[#E85D04]/3 rounded-full blur-[100px]" />
      </div>

      <div className="relative z-10 max-w-7xl mx-auto px-6 pt-12 space-y-16">
        
        {/* Hero Section */}
        <section className="text-center space-y-8">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            className="space-y-4"
          >
            <h1 className="text-5xl md:text-7xl font-display font-black tracking-tighter text-transparent bg-clip-text bg-gradient-to-b from-white to-white/40">
              Your Future Is Already <br /> Counting Down.
            </h1>
            <p className="text-textMuted text-xl font-light max-w-2xl mx-auto">
              Every habit you complete brings your mission closer. <br />
              The clock never stops for those who chase greatness.
            </p>
          </motion.div>

          <div className="flex justify-center">
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => setIsModalOpen(true)}
              className="group relative px-8 py-4 rounded-2xl bg-[#FF6B2C] text-white font-bold shadow-[0_0_30px_rgba(255,107,44,0.3)] hover:shadow-[0_0_50px_rgba(255,107,44,0.5)] transition-all flex items-center gap-3 overflow-hidden"
            >
              <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent -translate-x-full group-hover:animate-shimmer" />
              <Plus size={20} />
              Initiate New Mission
            </motion.button>
          </div>
        </section>

        {/* Global Progress Overview */}
        {missions.length > 0 && (
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="grid grid-cols-1 md:grid-cols-3 gap-6"
          >
            <div className="glass-card p-6 rounded-3xl border-white/5 flex items-center gap-6">
              <div className="w-14 h-14 rounded-2xl bg-[#FF6B2C]/10 flex items-center justify-center text-[#FF6B2C]">
                <Target size={28} />
              </div>
              <div>
                <p className="text-xs text-textMuted font-bold uppercase tracking-widest">Active Missions</p>
                <p className="text-3xl font-display font-bold">{missions.length}</p>
              </div>
            </div>
            <div className="glass-card p-6 rounded-3xl border-white/5 flex items-center gap-6">
              <div className="w-14 h-14 rounded-2xl bg-blue-500/10 flex items-center justify-center text-blue-400">
                <Flame size={28} />
              </div>
              <div>
                <p className="text-xs text-textMuted font-bold uppercase tracking-widest">Total Momentum</p>
                <p className="text-3xl font-display font-bold">84%</p>
              </div>
            </div>
            <div className="glass-card p-6 rounded-3xl border-white/5 flex items-center gap-6">
              <div className="w-14 h-14 rounded-2xl bg-purple-500/10 flex items-center justify-center text-purple-400">
                <Brain size={28} />
              </div>
              <div>
                <p className="text-xs text-textMuted font-bold uppercase tracking-widest">AI Readiness</p>
                <p className="text-3xl font-display font-bold text-success">Optimal</p>
              </div>
            </div>
          </motion.div>
        )}

        {/* Missions Grid */}
        <section className="space-y-10">
          <div className="flex items-center justify-between">
            <h2 className="text-2xl font-display font-bold text-white flex items-center gap-3">
              <Rocket className="text-[#FF6B2C]" /> Active Operations
            </h2>
            <div className="flex items-center gap-4 text-sm text-textMuted">
              <span className="flex items-center gap-1.5"><div className="w-2 h-2 rounded-full bg-success" /> On Track</span>
              <span className="flex items-center gap-1.5"><div className="w-2 h-2 rounded-full bg-warning" /> Critical</span>
            </div>
          </div>

          {missions.length === 0 ? (
            <div className="py-20 flex flex-col items-center justify-center text-center space-y-6">
              <div className="relative">
                <motion.div 
                  animate={{ scale: [1, 1.2, 1], opacity: [0.3, 0.6, 0.3] }}
                  transition={{ duration: 4, repeat: Infinity }}
                  className="absolute inset-0 bg-[#FF6B2C] rounded-full blur-[40px]"
                />
                <div className="relative w-24 h-24 rounded-full border-2 border-dashed border-white/20 flex items-center justify-center">
                  <Rocket size={40} className="text-white/20" />
                </div>
              </div>
              <div className="space-y-2">
                <h3 className="text-2xl font-bold text-white">No Missions Detected.</h3>
                <p className="text-textMuted">The future belongs to those who define it. Create your first mission.</p>
              </div>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              <AnimatePresence mode="popLayout">
                {missions.map((mission, i) => (
                  <MissionCard 
                    key={mission.id} 
                    mission={mission} 
                    index={i} 
                    onOpenVision={() => setVisionModeId(mission.id)}
                    onDelete={() => deleteMission(mission.id)}
                  />
                ))}
              </AnimatePresence>
            </div>
          )}
        </section>

        {/* AI Insight Section */}
        {missions.length > 0 && (
          <section className="glass-card p-10 rounded-[2.5rem] border-white/5 relative overflow-hidden group">
            <div className="absolute top-0 right-0 p-8 text-[#FF6B2C] opacity-10 group-hover:opacity-20 transition-all duration-700">
              <Brain size={120} />
            </div>
            <div className="relative z-10 flex flex-col md:flex-row items-center gap-10">
              <div className="space-y-4 max-w-md">
                <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42] text-[10px] font-bold uppercase tracking-[0.2em]">
                  <Sparkles size={12} /> Tactical Intelligence
                </div>
                <h3 className="text-3xl font-display font-bold text-white">AI Performance Insights</h3>
                <p className="text-textMuted leading-relaxed">
                  Our algorithm analyzes your consistency across all linked protocols to forecast mission success.
                </p>
              </div>
              <div className="flex-1 grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="p-5 rounded-2xl bg-white/5 border border-white/10 space-y-2">
                  <div className="flex items-center gap-2 text-success">
                    <TrendingUp size={16} />
                    <span className="text-[10px] font-black uppercase tracking-widest">Efficiency Up</span>
                  </div>
                  <p className="text-sm font-medium italic">"Your consistency improved this mission by 23% this week."</p>
                </div>
                <div className="p-5 rounded-2xl bg-white/5 border border-white/10 space-y-2">
                  <div className="flex items-center gap-2 text-[#FF6B2C]">
                    <Activity size={16} />
                    <span className="text-[10px] font-black uppercase tracking-widest">Impact Core</span>
                  </div>
                  <p className="text-sm font-medium italic">"Gym habits contribute most to your 'Dream Physique' mission."</p>
                </div>
              </div>
            </div>
          </section>
        )}
      </div>

      {/* Modals & Overlays */}
      <AnimatePresence>
        {isModalOpen && (
          <CreateMissionModal 
            onClose={() => setIsModalOpen(false)} 
            onAdd={addMission}
            habits={habits}
          />
        )}
        {visionModeId && (
          <VisionMode 
            mission={activeMission} 
            onClose={() => setVisionModeId(null)} 
          />
        )}
      </AnimatePresence>
    </div>
  );
}

function MissionCard({ mission, index, onOpenVision, onDelete }) {
  const [timeLeft, setTimeLeft] = useState(null);

  useEffect(() => {
    const timer = setInterval(() => {
      const now = new Date();
      const target = parseISO(mission.targetDate);
      const totalSeconds = Math.max(0, differenceInSeconds(target, now));
      
      const d = Math.floor(totalSeconds / (3600 * 24));
      const h = Math.floor((totalSeconds % (3600 * 24)) / 3600);
      const m = Math.floor((totalSeconds % 3600) / 60);
      const s = totalSeconds % 60;

      setTimeLeft({ d, h, m, s });
    }, 1000);

    return () => clearInterval(timer);
  }, [mission.targetDate]);

  const progress = 65; // Mock progress for now

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, scale: 0.95 }}
      transition={{ delay: index * 0.1 }}
      className="group relative flex flex-col glass-card rounded-[2.5rem] border-white/5 overflow-hidden hover:border-[#FF6B2C]/30 transition-all duration-500"
    >
      {/* Category Tag */}
      <div className="absolute top-6 left-6 z-10 px-3 py-1 rounded-full bg-white/5 border border-white/10 backdrop-blur-md text-[10px] font-black uppercase tracking-widest text-[#FF8C42]">
        {mission.category}
      </div>

      {/* Progress Background */}
      <div className="absolute inset-0 bg-gradient-to-b from-[#FF6B2C]/5 to-transparent pointer-events-none" />

      {/* Card Header */}
      <div className="p-8 pb-4 space-y-4 relative z-10">
        <div className="h-12 flex justify-between items-start">
          <div className="w-12 h-12 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center text-white/40 group-hover:text-[#FF6B2C] group-hover:border-[#FF6B2C]/30 transition-all duration-500">
            <Rocket size={24} />
          </div>
          <button 
            onClick={onDelete}
            className="p-2 text-white/10 hover:text-red-500 transition-colors"
          >
            <X size={16} />
          </button>
        </div>
        <div className="space-y-1">
          <h3 className="text-2xl font-display font-bold text-white group-hover:text-[#FF6B2C] transition-colors">{mission.title}</h3>
          <p className="text-textMuted text-sm line-clamp-2 leading-relaxed italic">"{mission.motivationQuote}"</p>
        </div>
      </div>

      {/* Countdown Grid */}
      <div className="px-8 py-6 grid grid-cols-4 gap-2 relative z-10">
        {[
          { label: 'Days', value: timeLeft?.d ?? 0 },
          { label: 'Hrs', value: timeLeft?.h ?? 0 },
          { label: 'Min', value: timeLeft?.m ?? 0 },
          { label: 'Sec', value: timeLeft?.s ?? 0 },
        ].map((unit, i) => (
          <div key={i} className="bg-white/5 border border-white/10 rounded-2xl p-3 text-center">
            <p className="text-xl font-display font-black text-white">{String(unit.value).padStart(2, '0')}</p>
            <p className="text-[8px] text-textMuted font-bold uppercase tracking-tighter">{unit.label}</p>
          </div>
        ))}
      </div>

      {/* Progress & Stats */}
      <div className="p-8 pt-0 space-y-6 relative z-10">
        <div className="space-y-2">
          <div className="flex justify-between items-end">
            <span className="text-[10px] text-textMuted font-black uppercase tracking-widest">Mission Momentum</span>
            <span className="text-sm font-bold text-[#FF8C42]">{progress}%</span>
          </div>
          <div className="h-2 bg-white/5 rounded-full overflow-hidden border border-white/5">
            <motion.div 
              initial={{ width: 0 }}
              animate={{ width: `${progress}%` }}
              className="h-full bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] rounded-full shadow-[0_0_15px_rgba(255,107,44,0.4)]"
            />
          </div>
        </div>

        <div className="flex items-center justify-between pt-4 border-t border-white/5">
          <div className="flex items-center gap-2">
            <div className="flex -space-x-2">
              {[1, 2, 3].map(i => (
                <div key={i} className="w-6 h-6 rounded-full bg-white/5 border border-[#050505] flex items-center justify-center text-[8px] text-textMuted">
                  <Activity size={10} />
                </div>
              ))}
            </div>
            <span className="text-[10px] text-textMuted font-bold uppercase">Linked Habits</span>
          </div>
          <button 
            onClick={onOpenVision}
            className="flex items-center gap-2 text-[10px] font-black uppercase tracking-[0.2em] text-white hover:text-[#FF6B2C] transition-all"
          >
            Enter Vision Mode <ChevronRight size={14} />
          </button>
        </div>
      </div>
    </motion.div>
  );
}

function CreateMissionModal({ onClose, onAdd, habits }) {
  const [formData, setFormData] = useState({
    title: '',
    desc: '',
    category: 'Career',
    targetDate: '',
    priority: 'High',
    motivationQuote: '',
    linkedHabitIds: []
  });

  const categories = ['Wealth', 'Fitness', 'Study', 'Career', 'Discipline', 'Health', 'Custom'];

  const handleSubmit = (e) => {
    e.preventDefault();
    onAdd(formData);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-[1000] flex items-center justify-center p-4">
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        onClick={onClose}
        className="absolute inset-0 bg-black/90 backdrop-blur-2xl"
      />
      <motion.div
        initial={{ opacity: 0, scale: 0.95, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.95, y: 20 }}
        className="relative w-full max-w-3xl glass-card rounded-[3rem] border border-white/10 shadow-[0_0_100px_rgba(255,107,44,0.15)] overflow-hidden"
      >
        <div className="p-12 space-y-10 max-h-[90vh] overflow-y-auto custom-scrollbar">
          <div className="flex justify-between items-start">
            <div className="space-y-2">
              <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-[#FF6B2C] to-[#E85D04] flex items-center justify-center shadow-[0_0_20px_rgba(255,107,44,0.4)]">
                <Rocket className="text-white" size={32} />
              </div>
              <h2 className="text-4xl font-display font-black text-white">Initiate Mission</h2>
              <p className="text-textMuted uppercase tracking-[0.2em] text-xs font-bold">Constructing the future trajectory</p>
            </div>
            <button onClick={onClose} className="w-12 h-12 rounded-full border border-white/10 flex items-center justify-center text-white/20 hover:text-white hover:border-white transition-all">
              <X size={24} />
            </button>
          </div>

          <form onSubmit={handleSubmit} className="space-y-8">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              <div className="space-y-6">
                <div className="space-y-2">
                  <label className="text-[10px] uppercase tracking-widest font-black text-[#FF8C42] ml-2">Mission Title</label>
                  <input
                    required
                    type="text"
                    placeholder="e.g., Build Dream Physique"
                    className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-all"
                    value={formData.title}
                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-[10px] uppercase tracking-widest font-black text-[#FF8C42] ml-2">Target Date</label>
                  <input
                    required
                    type="date"
                    className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-all [color-scheme:dark]"
                    value={formData.targetDate}
                    onChange={(e) => setFormData({ ...formData, targetDate: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-[10px] uppercase tracking-widest font-black text-[#FF8C42] ml-2">Category</label>
                  <div className="flex flex-wrap gap-2">
                    {categories.map(cat => (
                      <button
                        key={cat}
                        type="button"
                        onClick={() => setFormData({ ...formData, category: cat })}
                        className={`px-4 py-2 rounded-xl text-[10px] font-bold uppercase transition-all ${
                          formData.category === cat 
                            ? 'bg-[#FF6B2C] text-white' 
                            : 'bg-white/5 border border-white/10 text-white/40 hover:bg-white/10'
                        }`}
                      >
                        {cat}
                      </button>
                    ))}
                  </div>
                </div>
              </div>

              <div className="space-y-6">
                <div className="space-y-2">
                  <label className="text-[10px] uppercase tracking-widest font-black text-[#FF8C42] ml-2">Motivational Mantra</label>
                  <textarea
                    rows={4}
                    placeholder="A quote that moves you..."
                    className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-all resize-none"
                    value={formData.motivationQuote}
                    onChange={(e) => setFormData({ ...formData, motivationQuote: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-[10px] uppercase tracking-widest font-black text-[#FF8C42] ml-2">Connect Habits</label>
                  <div className="grid grid-cols-1 gap-2 max-h-32 overflow-y-auto custom-scrollbar pr-2">
                    {habits.map(habit => (
                      <button
                        key={habit.id}
                        type="button"
                        onClick={() => {
                          const ids = formData.linkedHabitIds.includes(habit.id)
                            ? formData.linkedHabitIds.filter(id => id !== habit.id)
                            : [...formData.linkedHabitIds, habit.id];
                          setFormData({ ...formData, linkedHabitIds: ids });
                        }}
                        className={`flex items-center justify-between p-3 rounded-xl border transition-all ${
                          formData.linkedHabitIds.includes(habit.id)
                            ? 'bg-[#FF6B2C]/10 border-[#FF6B2C] text-white'
                            : 'bg-white/5 border-white/5 text-white/40 hover:bg-white/10'
                        }`}
                      >
                        <span className="text-xs font-bold">{habit.name}</span>
                        <Link2 size={14} className={formData.linkedHabitIds.includes(habit.id) ? 'text-[#FF8C42]' : 'text-white/10'} />
                      </button>
                    ))}
                  </div>
                </div>
              </div>
            </div>

            <div className="pt-6 flex gap-4">
              <button
                type="button"
                onClick={onClose}
                className="flex-1 py-5 rounded-2xl border border-white/10 text-white font-bold hover:bg-white/5 transition-all"
              >
                Cancel Initialization
              </button>
              <button
                type="submit"
                className="flex-[2] py-5 rounded-2xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white font-bold shadow-[0_10px_40px_rgba(255,107,44,0.3)] hover:shadow-[0_15px_60px_rgba(255,107,44,0.5)] transition-all flex items-center justify-center gap-3"
              >
                <Target size={20} /> Launch Mission
              </button>
            </div>
          </form>
        </div>
      </motion.div>
    </div>
  );
}

function VisionMode({ mission, onClose }) {
  const [timeLeft, setTimeLeft] = useState(null);

  useEffect(() => {
    const timer = setInterval(() => {
      const now = new Date();
      const target = parseISO(mission.targetDate);
      const diff = differenceInSeconds(target, now);
      
      const d = Math.floor(diff / (3600 * 24));
      const h = Math.floor((diff % (3600 * 24)) / 3600);
      const m = Math.floor((diff % 3600) / 60);
      const s = diff % 60;

      setTimeLeft({ d, h, m, s });
    }, 1000);

    return () => clearInterval(timer);
  }, [mission.targetDate]);

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-[2000] bg-black flex flex-col items-center justify-center overflow-hidden"
    >
      {/* Background Visuals */}
      <div className="absolute inset-0 z-0">
        <div className="absolute inset-0 bg-gradient-to-b from-[#FF6B2C]/10 via-transparent to-black" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full h-full">
          <motion.div 
            animate={{ 
              scale: [1, 1.2, 1],
              rotate: [0, 90, 180, 270, 360],
              opacity: [0.1, 0.2, 0.1]
            }}
            transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
            className="absolute inset-0 border-[1px] border-[#FF6B2C]/20 rounded-full blur-md"
          />
        </div>
        {/* Animated Particles Simulation */}
        <div className="absolute inset-0 overflow-hidden opacity-30">
          {[...Array(50)].map((_, i) => (
            <motion.div
              key={i}
              initial={{ x: Math.random() * window.innerWidth, y: Math.random() * window.innerHeight }}
              animate={{ 
                y: [null, -100],
                opacity: [0, 1, 0]
              }}
              transition={{ duration: Math.random() * 5 + 5, repeat: Infinity, ease: "linear" }}
              className="absolute w-1 h-1 bg-white rounded-full"
            />
          ))}
        </div>
      </div>

      <button 
        onClick={onClose}
        className="absolute top-10 right-10 z-50 w-16 h-16 rounded-full border border-white/10 flex items-center justify-center text-white/40 hover:text-white transition-all group"
      >
        <X size={32} className="group-hover:rotate-90 transition-transform" />
      </button>

      <div className="relative z-10 text-center space-y-16 max-w-4xl px-6">
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="space-y-6"
        >
          <div className="inline-flex items-center gap-3 px-4 py-2 rounded-full bg-[#FF6B2C]/20 border border-[#FF6B2C]/40 text-[#FF8C42] font-black uppercase tracking-[0.4em] text-xs">
            <Sparkles size={16} /> Vision Mode Active
          </div>
          <h2 className="text-6xl md:text-8xl font-display font-black tracking-tighter text-white">
            {mission.title}
          </h2>
          <p className="text-3xl text-white/40 font-light italic">
            "{mission.motivationQuote}"
          </p>
        </motion.div>

        {/* Massive Countdown */}
        <div className="flex flex-wrap justify-center gap-8 md:gap-16">
          {[
            { label: 'Days', value: timeLeft?.d ?? 0 },
            { label: 'Hours', value: timeLeft?.h ?? 0 },
            { label: 'Minutes', value: timeLeft?.m ?? 0 },
            { label: 'Seconds', value: timeLeft?.s ?? 0 },
          ].map((unit, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, scale: 0.5 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: 0.5 + i * 0.1 }}
              className="space-y-4"
            >
              <p className="text-7xl md:text-9xl font-display font-black text-transparent bg-clip-text bg-gradient-to-b from-white to-[#FF6B2C]/20">
                {String(unit.value).padStart(2, '0')}
              </p>
              <p className="text-sm md:text-lg font-black uppercase tracking-[0.5em] text-white/20">
                {unit.label}
              </p>
            </motion.div>
          ))}
        </div>

        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1 }}
          className="pt-12"
        >
          <div className="w-full h-1 bg-white/5 rounded-full overflow-hidden max-w-lg mx-auto">
            <motion.div 
              initial={{ x: '-100%' }}
              animate={{ x: '100%' }}
              transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
              className="w-1/2 h-full bg-[#FF6B2C] blur-sm"
            />
          </div>
          <p className="mt-6 text-textMuted uppercase tracking-widest text-[10px] font-bold">
            Synchronizing with your current trajectory...
          </p>
        </motion.div>
      </div>
    </motion.div>
  );
}
