'use client';

import { useState, useMemo, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence, LayoutGroup } from 'framer-motion';
import { 
  BookOpen, Search, Filter, Plus, Rocket, 
  Clock, Zap, Target, Flame, ChevronRight,
  MoreVertical, Trash2, CheckCircle2, Star,
  Activity, BarChart3, Lock, Play, BookMarked,
  Layout, Maximize2, X, Terminal, Code2, 
  Brain, Library, Milestone, Timer, Share2,
  ExternalLink, FileText, Video, PlayCircle, ArrowRight,
  RotateCcw, Sparkles, Award
} from 'lucide-react';
import useStore from '@/store/useStore';
import { format } from 'date-fns';
import { computeLearningStats, getXpPerTopic, getStreakTier } from '@/lib/learningXpEngine';

export default function LearningHub() {
  const { subjects, addSubject, deleteSubject } = useStore();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedSubject, setSelectedSubject] = useState(null);
  const [deepStudyId, setDeepStudyId] = useState(null);
  const [searchQuery, setSearchQuery] = useState('');

  const filteredSubjects = useMemo(() => {
    return (subjects || []).filter(s => {
      return s.title.toLowerCase().includes(searchQuery.toLowerCase());
    });
  }, [subjects, searchQuery]);

  // Compute real learning stats from store data
  const stats = useMemo(() => computeLearningStats(subjects || []), [subjects]);

  const formatXp = (xp) => {
    if (xp >= 1000) return `${(xp / 1000).toFixed(1)}K`;
    return xp.toString();
  };

  return (
    <div className="min-h-screen bg-[#050505] text-white pt-6 pb-24 px-4 md:px-10 overflow-x-hidden relative">
      {/* Background Ambience */}
      <div className="fixed inset-0 pointer-events-none z-0">
        <div className="absolute top-[15%] right-[-10%] w-[50%] h-[50%] bg-[#FF6B2C]/5 rounded-full blur-[120px] animate-pulse" />
        <div className="absolute bottom-[-5%] left-[-5%] w-[40%] h-[40%] bg-[#E85D04]/3 rounded-full blur-[100px]" />
      </div>

      <div className="max-w-[1600px] mx-auto space-y-12 relative z-10">
        
        {/* Header Section */}
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-8">
          <div className="flex items-center gap-6">
            <div className="w-16 h-16 rounded-3xl bg-gradient-to-tr from-[#FF6B2C] to-[#E85D04] flex items-center justify-center shadow-[0_0_40px_rgba(255,107,44,0.3)]">
              <BookOpen className="text-white" size={32} />
            </div>
            <div className="flex flex-col md:flex-row md:items-baseline gap-2 md:gap-4">
              <h1 className="text-5xl md:text-6xl font-display font-black tracking-tight text-white">Active Learning Paths</h1>
              <p className="text-[#FF8C42] font-black text-sm uppercase tracking-widest">{filteredSubjects.length} Paths Detected</p>
            </div>
          </div>

          <div className="flex items-center gap-4 w-full md:w-auto">
            <div className="relative flex-1 md:w-80 group">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20 group-focus-within:text-[#FF6B2C] transition-colors" size={18} />
              <input 
                type="text" 
                placeholder="Search protocols..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full bg-white/5 border border-white/10 rounded-2xl py-4 pl-12 pr-6 text-sm focus:outline-none focus:border-[#FF6B2C]/50 transition-all placeholder:text-white/20"
              />
            </div>

            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => setIsModalOpen(true)}
              className="w-14 h-14 rounded-2xl bg-[#FF6B2C] text-white flex items-center justify-center shadow-[0_10px_30px_rgba(255,107,44,0.3)] hover:bg-[#E85D04] transition-all"
            >
              <Plus size={28} />
            </motion.button>
          </div>
        </div>

        {/* Learning Stats Grid — now using real data */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {[
            { label: 'Total Study Time', value: `${stats.totalStudyHours}h`, icon: Clock, color: '#FF6B2C', trend: `${stats.totalTopics} topics` },
            { label: 'Best Streak', value: `${stats.maxStreak} Days`, icon: Flame, color: '#FFD700', trend: stats.maxStreak >= 21 ? 'Legendary' : stats.maxStreak >= 7 ? 'Committed' : 'Building' },
            { label: 'Modules Complete', value: `${stats.totalCompletedModules}/${stats.totalModules}`, icon: CheckCircle2, color: '#3B82F6', trend: stats.totalModules > 0 ? `${Math.round((stats.totalCompletedModules / stats.totalModules) * 100)}%` : '0%' },
            { label: 'Intelligence XP', value: formatXp(stats.totalXp), icon: Brain, color: '#10B981', trend: `+${formatXp(stats.totalXp)}` }
          ].map((stat, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.1 }}
              className="glass-card p-6 rounded-3xl border-white/5 space-y-4 relative overflow-hidden group"
            >
              <div className="absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-all duration-500">
                <stat.icon size={60} />
              </div>
              <div className="flex items-center gap-3">
                <div className={`w-10 h-10 rounded-xl flex items-center justify-center`} style={{ backgroundColor: `${stat.color}15`, color: stat.color }}>
                  <stat.icon size={20} />
                </div>
                <p className="text-xs text-text-muted font-bold uppercase tracking-widest">{stat.label}</p>
              </div>
              <div className="flex items-end justify-between">
                <h3 className="text-3xl font-display font-black text-white">{stat.value}</h3>
                <span className="text-[10px] font-black text-[#FF8C42] bg-[#FF6B2C]/10 px-2 py-1 rounded-full uppercase">{stat.trend}</span>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Subjects Grid */}
        <div className="space-y-6">
          <AnimatePresence mode="popLayout">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {filteredSubjects.map((s, i) => (
                <SubjectCard 
                  key={s.id} 
                  subject={s} 
                  index={i} 
                  onDelete={() => deleteSubject(s.id)}
                />
              ))}

              {filteredSubjects.length === 0 && (
                <motion.div 
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="col-span-full py-20 flex flex-col items-center justify-center text-center space-y-6"
                >
                  <div className="relative">
                    <motion.div 
                      animate={{ scale: [1, 1.2, 1], opacity: [0.3, 0.6, 0.3] }}
                      transition={{ duration: 4, repeat: Infinity }}
                      className="absolute inset-0 bg-[#FF6B2C] rounded-full blur-[40px]"
                    />
                    <div className="relative w-24 h-24 rounded-full border-2 border-dashed border-white/20 flex items-center justify-center">
                      <Terminal size={40} className="text-white/20" />
                    </div>
                  </div>
                  <div className="space-y-2">
                    <h3 className="text-2xl font-bold text-white">No Learning Paths Detected.</h3>
                    <p className="text-text-muted max-w-sm mx-auto">Build your future one chapter at a time. Create your first subject to initiate the protocol.</p>
                  </div>
                </motion.div>
              )}
            </div>
          </AnimatePresence>
        </div>
      </div>

      <AnimatePresence>
        {isModalOpen && (
          <CreateSubjectModal 
            onClose={() => setIsModalOpen(false)} 
            onAdd={addSubject}
          />
        )}
      </AnimatePresence>
    </div>
  );
}

function SubjectCard({ subject, index, onDelete }) {
  const router = useRouter();
  const streakCount = subject.streakCount || 0;
  const xpPerTopic = getXpPerTopic(streakCount);
  const tier = getStreakTier(streakCount);

  return (
    <motion.div
      layout
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, scale: 0.9 }}
      transition={{ delay: index * 0.1 }}
      className="group relative flex flex-col glass-card rounded-[2.5rem] border-white/5 overflow-hidden hover:border-[#FF6B2C]/30 transition-all duration-500 min-h-[400px]"
    >
      <div className="absolute top-6 left-6 z-10 px-4 py-1.5 rounded-full bg-white/5 border border-white/10 backdrop-blur-md text-[10px] font-black uppercase tracking-[0.2em] text-[#FF8C42]">
        {subject.category}
      </div>

      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 text-[#FF6B2C] opacity-[0.03] group-hover:opacity-[0.07] transition-all duration-700 pointer-events-none">
        <Brain size={280} strokeWidth={1} />
      </div>

      <div className="p-10 pt-20 flex-1 flex flex-col justify-between relative z-10">
        <div className="space-y-6">
          <div className="flex justify-between items-start">
            <div className="space-y-2">
              <h3 className="text-3xl font-display font-black text-white group-hover:text-[#FF6B2C] transition-colors leading-tight">{subject.title}</h3>
              <p className="text-text-muted text-[10px] font-bold uppercase tracking-[0.2em]">
                {subject.chapters?.length || 0} Modules Detected
              </p>
            </div>
            <button onClick={(e) => { e.stopPropagation(); onDelete(); }} className="p-3 rounded-xl bg-white/5 text-white/10 hover:text-red-500 hover:bg-red-500/10 transition-all">
              <Trash2 size={18} />
            </button>
          </div>

          <div className="grid grid-cols-3 gap-4 py-4">
            <div className="space-y-2">
              <p className="text-[10px] text-text-muted uppercase font-black tracking-[0.2em]">Streak</p>
              <div className="flex items-center gap-1.5">
                <Flame size={16} style={{ color: tier.color }} />
                <p className="text-xl font-display font-black" style={{ color: tier.color }}>{streakCount}d</p>
              </div>
            </div>
            <div className="space-y-2 text-center">
              <p className="text-[10px] text-text-muted uppercase font-black tracking-[0.2em]">XP/Topic</p>
              <p className="text-xl font-display font-black text-[#FFD700]">{xpPerTopic}</p>
            </div>
            <div className="space-y-2 text-right">
              <p className="text-[10px] text-text-muted uppercase font-black tracking-[0.2em]">Tier</p>
              <p className="text-xs font-black uppercase tracking-widest" style={{ color: tier.color }}>{tier.label}</p>
            </div>
          </div>

          <div className="space-y-3">
            <div className="flex justify-between items-end">
              <span className="text-[10px] text-text-muted font-black uppercase tracking-[0.2em]">Synaptic Completion</span>
              <span className="text-sm font-black text-[#FF8C42]">{subject.progress || 0}%</span>
            </div>
            <div className="h-3 bg-white/5 rounded-full overflow-hidden border border-white/5 p-0.5">
              <motion.div 
                initial={{ width: 0 }}
                animate={{ width: `${subject.progress || 0}%` }}
                className="h-full bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] rounded-full shadow-[0_0_20px_rgba(255,107,44,0.4)]"
              />
            </div>
          </div>
        </div>

        <div className="flex items-center justify-between pt-8 mt-8 border-t border-white/5">
          <div className="flex items-center gap-2">
            <Zap size={16} className="text-[#FFD700]" />
            <span className="text-xs font-black uppercase tracking-[0.2em] text-[#FFD700]">+{subject.xpEarned || 0} XP</span>
          </div>
          <button 
            onClick={() => router.push(`/app/learning/subject?id=${subject.id}`)}
            className="flex items-center gap-3 text-[10px] font-black uppercase tracking-[0.3em] text-white hover:text-[#FF6B2C] transition-all group/btn"
          >
            Launch System <ChevronRight size={16} className="group-hover/btn:translate-x-1 transition-transform" />
          </button>
        </div>
      </div>
    </motion.div>
  );
}
function CreateSubjectModal({ onClose, onAdd }) {
  const [formData, setFormData] = useState({
    title: '',
    category: 'Development',
    chapters: []
  });
  const [chapterInput, setChapterInput] = useState({ title: '', duration: '45m' });

  const addChapterToForm = () => {
    if (!chapterInput.title) return;
    setFormData({
      ...formData,
      chapters: [...formData.chapters, { ...chapterInput, id: Math.random().toString(36).substr(2, 9), status: 'Not Started', topics: [], progress: 0 }]
    });
    setChapterInput({ title: '', duration: '45m' });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    onAdd(formData);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-[1000] flex items-center justify-center p-4 bg-black/90 backdrop-blur-2xl">
      <motion.div
        initial={{ opacity: 0, scale: 0.95, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        className="relative w-full max-w-3xl glass-card rounded-[3rem] border border-white/10 shadow-[0_0_100px_rgba(255,107,44,0.15)] overflow-hidden"
      >
        <div className="p-8 md:p-16 space-y-12 max-h-[90vh] overflow-y-auto custom-scrollbar">
          <div className="flex justify-between items-start">
            <div className="space-y-4">
              <div className="w-20 h-20 rounded-3xl bg-gradient-to-tr from-[#FF6B2C] to-[#E85D04] flex items-center justify-center shadow-[0_0_40px_rgba(255,107,44,0.4)]">
                <BookOpen className="text-white" size={40} />
              </div>
              <div className="space-y-1">
                <h2 className="text-5xl md:text-6xl font-display font-black text-white tracking-tighter">Initialize Path</h2>
                <p className="text-text-muted uppercase tracking-[0.4em] text-[10px] md:text-xs font-black">Constructing a new knowledge trajectory</p>
              </div>
            </div>
            <button onClick={onClose} className="p-4 rounded-full border border-white/10 text-white/20 hover:text-white transition-all hover:bg-white/5">
              <X size={28} />
            </button>
          </div>

          <form onSubmit={handleSubmit} className="space-y-10">
            <div className="grid grid-cols-1 xl:grid-cols-2 gap-12">
              <div className="space-y-8">
                <div className="space-y-3">
                  <label className="text-[10px] uppercase tracking-[0.3em] font-black text-[#FF8C42] ml-2">SUBJECT IDENTITY</label>
                  <input
                    required
                    type="text"
                    placeholder="e.g., Machine Learni"
                    className="w-full bg-white/5 border border-white/10 rounded-[2rem] px-8 py-6 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-all text-xl md:text-2xl font-bold placeholder:text-white/10"
                    value={formData.title}
                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  />
                </div>
                <div className="space-y-3">
                  <label className="text-[10px] uppercase tracking-[0.3em] font-black text-[#FF8C42] ml-2">SECTOR</label>
                  <select 
                    className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-all appearance-none"
                    value={formData.category}
                    onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                  >
                    {['Development', 'Design', 'Data Science', 'Mathematics', 'Academics', 'Skills'].map(c => (
                      <option key={c} value={c} className="bg-[#050505]">{c}</option>
                    ))}
                  </select>
                </div>
              </div>

              <div className="space-y-6">
                <div className="space-y-2">
                  <label className="text-[10px] uppercase tracking-widest font-black text-[#FF8C42] ml-2">MODULE PROTOCOL</label>
                  <div className="flex gap-2">
                    <input
                      type="text"
                      placeholder="Chapter title..."
                      className="flex-1 bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-xs focus:outline-none focus:border-[#FF6B2C]/50 transition-all"
                      value={chapterInput.title}
                      onChange={(e) => setChapterInput({ ...chapterInput, title: e.target.value })}
                    />
                    <button 
                      type="button"
                      onClick={addChapterToForm}
                      className="p-3 rounded-xl bg-[#FF6B2C] text-white hover:bg-[#E85D04] transition-all"
                    >
                      <Plus size={20} />
                    </button>
                  </div>
                </div>

                <div className="space-y-2">
                  <label className="text-[10px] uppercase tracking-widest font-black text-white/20 ml-2">Staged Modules ({formData.chapters.length})</label>
                  <div className="grid grid-cols-1 gap-2 max-h-32 overflow-y-auto custom-scrollbar pr-2">
                    {formData.chapters.map((ch, i) => (
                      <div key={i} className="flex items-center justify-between p-3 rounded-xl bg-white/5 border border-white/5 text-[10px] font-bold text-white/60">
                        <span>{ch.title}</span>
                        <span className="text-text-muted">{ch.duration}</span>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>

            <div className="pt-8 flex flex-col md:flex-row gap-6">
              <button
                type="button"
                onClick={onClose}
                className="flex-1 py-6 rounded-[2rem] border border-white/10 text-white font-black uppercase tracking-[0.3em] text-xs hover:bg-white/5 transition-all"
              >
                Abort Protocol
              </button>
              <button
                type="submit"
                className="flex-[2] py-6 rounded-[2rem] bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white font-black uppercase tracking-[0.3em] text-sm shadow-[0_20px_50px_rgba(255,107,44,0.3)] hover:shadow-[0_25px_70px_rgba(255,107,44,0.5)] transition-all flex items-center justify-center gap-4 group"
              >
                <Rocket size={24} className="group-hover:-translate-y-1 group-hover:translate-x-1 transition-transform" /> Deploy Subject
              </button>
            </div>
          </form>
        </div>
      </motion.div>
    </div>
  );
}
