'use client';

import { useState, useMemo, useEffect } from 'react';
import { motion, AnimatePresence, LayoutGroup } from 'framer-motion';
import { 
  BookOpen, Search, Filter, Plus, Rocket, 
  Clock, Zap, Target, Flame, ChevronRight,
  MoreVertical, Trash2, CheckCircle2, Star,
  Activity, BarChart3, Lock, Play, BookMarked,
  Layout, Maximize2, X, Terminal, Code2, 
  Brain, Library, Milestone, Timer, Share2,
  ExternalLink, FileText, Video, PlayCircle, ArrowRight,
  RotateCcw, Sparkles
} from 'lucide-react';
import { Line, Bar } from 'react-chartjs-2';
import useStore from '@/store/useStore';
import { format } from 'date-fns';
import {
  Chart as ChartJS, CategoryScale, LinearScale, PointElement, LineElement, 
  BarElement, Title, Tooltip, Legend, Filler
} from 'chart.js';

ChartJS.register(
  CategoryScale, LinearScale, PointElement, LineElement, BarElement, 
  Title, Tooltip, Legend, Filler
);

export default function LearningHub() {
  const { subjects, addSubject, deleteSubject, toggleChapterStatus } = useStore();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedSubject, setSelectedSubject] = useState(null);
  const [deepStudyId, setDeepStudyId] = useState(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [filterCategory, setFilterCategory] = useState('All');

  const filteredSubjects = useMemo(() => {
    return (subjects || []).filter(s => {
      const matchesSearch = s.title.toLowerCase().includes(searchQuery.toLowerCase());
      const matchesCategory = filterCategory === 'All' || s.category === filterCategory;
      return matchesSearch && matchesCategory;
    });
  }, [subjects, searchQuery, filterCategory]);

  const categories = ['All', 'Development', 'Design', 'Data Science', 'Mathematics', 'Academics', 'Skills'];

  return (
    <div className="min-h-screen bg-[#050505] text-white pt-6 pb-24 px-4 md:px-10 overflow-x-hidden relative">
      {/* Background Ambience */}
      <div className="fixed inset-0 pointer-events-none z-0">
        <div className="absolute top-[15%] right-[-10%] w-[50%] h-[50%] bg-[#FF6B2C]/5 rounded-full blur-[120px] animate-pulse" />
        <div className="absolute bottom-[-5%] left-[-5%] w-[40%] h-[40%] bg-[#E85D04]/3 rounded-full blur-[100px]" />
      </div>

      <div className="max-w-[1600px] mx-auto space-y-12 relative z-10">
        
        {/* Header Section */}
        <div className="flex flex-col xl:flex-row justify-between items-start xl:items-center gap-8">
          <div className="space-y-2">
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              className="flex items-center gap-4"
            >
              <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-[#FF6B2C] to-[#E85D04] flex items-center justify-center shadow-[0_0_30px_rgba(255,107,44,0.4)]">
                <Library className="text-white" size={28} />
              </div>
              <div>
                <h1 className="text-4xl md:text-5xl font-display font-black tracking-tight text-white">Learning Hub</h1>
                <p className="text-text-muted uppercase tracking-[0.3em] text-[10px] font-bold">Self-Improvement Protocol v4.0</p>
              </div>
            </motion.div>
          </div>

          <div className="flex flex-wrap items-center gap-4 w-full xl:w-auto">
            <div className="relative flex-1 xl:w-80 group">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20 group-focus-within:text-[#FF6B2C] transition-colors" size={18} />
              <input 
                type="text" 
                placeholder="Search subjects..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full bg-white/5 border border-white/10 rounded-2xl py-4 pl-12 pr-6 text-sm focus:outline-none focus:border-[#FF6B2C]/50 transition-all placeholder:text-white/20"
              />
            </div>
            
            <div className="flex items-center gap-2 bg-white/5 border border-white/10 p-1.5 rounded-2xl overflow-x-auto no-scrollbar">
              {categories.map(cat => (
                <button
                  key={cat}
                  onClick={() => setFilterCategory(cat)}
                  className={`px-4 py-2.5 rounded-xl text-xs font-bold whitespace-nowrap transition-all ${
                    filterCategory === cat 
                      ? 'bg-[#FF6B2C] text-white shadow-[0_0_20px_rgba(255,107,44,0.3)]' 
                      : 'text-white/40 hover:text-white/60'
                  }`}
                >
                  {cat}
                </button>
              ))}
            </div>

            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              onClick={() => setIsModalOpen(true)}
              className="px-8 py-4 rounded-2xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white font-bold shadow-[0_10px_30px_rgba(255,107,44,0.3)] hover:shadow-[0_15px_40px_rgba(255,107,44,0.5)] transition-all flex items-center gap-3 group"
            >
              <Plus size={20} className="group-hover:rotate-90 transition-transform duration-300" />
              Initialize Subject
            </motion.button>
          </div>
        </div>

        {/* Learning Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {[
            { label: 'Total Study Time', value: '142h', icon: Clock, color: '#FF6B2C', trend: '+12%' },
            { label: 'Daily Streak', value: '18 Days', icon: Flame, color: '#FFD700', trend: 'Optimal' },
            { label: 'Modules Complete', value: '42/68', icon: CheckCircle2, color: '#3B82F6', trend: '62%' },
            { label: 'Intelligence XP', value: '12.4K', icon: Brain, color: '#10B981', trend: '+840' }
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
          <div className="flex items-center justify-between">
            <h2 className="text-2xl font-display font-bold text-white flex items-center gap-3">
              <BookOpen className="text-[#FF6B2C]" /> Active Learning Paths
            </h2>
            <div className="flex items-center gap-4 text-sm text-text-muted">
              <span>{filteredSubjects.length} Paths Detected</span>
            </div>
          </div>

          <AnimatePresence mode="popLayout">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {filteredSubjects.map((subject, i) => (
                <SubjectCard 
                  key={subject.id} 
                  subject={subject} 
                  index={i} 
                  onOpen={() => setSelectedSubject(subject)}
                  onDelete={() => deleteSubject(subject.id)}
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

      {/* Overlays */}
      <AnimatePresence>
        {isModalOpen && (
          <CreateSubjectModal 
            onClose={() => setIsModalOpen(false)} 
            onAdd={addSubject}
          />
        )}
        {selectedSubject && (
          <SubjectDetailsOverlay 
            subject={selectedSubject} 
            onClose={() => setSelectedSubject(null)}
            onToggleChapter={(chapterId) => toggleChapterStatus(selectedSubject.id, chapterId)}
            onDeepStudy={(chapterId) => setDeepStudyId(chapterId)}
          />
        )}
        {deepStudyId && (
          <DeepStudyMode 
            chapter={selectedSubject.chapters.find(c => c.id === deepStudyId)}
            subject={selectedSubject}
            onClose={() => setDeepStudyId(null)}
          />
        )}
      </AnimatePresence>
    </div>
  );
}

function SubjectCard({ subject, index, onOpen, onDelete }) {
  return (
    <motion.div
      layout
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, scale: 0.9 }}
      transition={{ delay: index * 0.1 }}
      className="group relative flex flex-col glass-card rounded-[2.5rem] border-white/5 overflow-hidden hover:border-[#FF6B2C]/30 transition-all duration-500"
    >
      <div className="absolute top-6 left-6 z-10 px-3 py-1 rounded-full bg-white/5 border border-white/10 backdrop-blur-md text-[10px] font-black uppercase tracking-widest text-[#FF8C42]">
        {subject.category}
      </div>

      <div className="absolute top-0 right-0 p-8 text-[#FF6B2C] opacity-5 group-hover:opacity-10 transition-all duration-700">
        <Brain size={120} />
      </div>

      <div className="p-8 pt-16 space-y-6 relative z-10">
        <div className="flex justify-between items-start">
          <div className="space-y-1">
            <h3 className="text-2xl font-display font-bold text-white group-hover:text-[#FF6B2C] transition-colors">{subject.title}</h3>
            <p className="text-text-muted text-xs font-bold uppercase tracking-widest">
              {subject.chapters?.length || 0} Modules Detected
            </p>
          </div>
          <button onClick={onDelete} className="p-2 text-white/10 hover:text-red-500 transition-colors">
            <Trash2 size={16} />
          </button>
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-1">
            <p className="text-[10px] text-text-muted uppercase font-bold tracking-widest">Total Study</p>
            <p className="text-xl font-display font-bold text-white">{subject.totalHours}h</p>
          </div>
          <div className="space-y-1 text-right">
            <p className="text-[10px] text-text-muted uppercase font-bold tracking-widest">Streak</p>
            <p className="text-xl font-display font-bold text-[#FF8C42]">{subject.streak}d</p>
          </div>
        </div>

        <div className="space-y-2">
          <div className="flex justify-between items-end">
            <span className="text-[10px] text-text-muted font-black uppercase tracking-widest">Synaptic Completion</span>
            <span className="text-sm font-bold text-[#FF8C42]">{subject.progress}%</span>
          </div>
          <div className="h-2 bg-white/5 rounded-full overflow-hidden border border-white/5 p-0.5">
            <motion.div 
              initial={{ width: 0 }}
              animate={{ width: `${subject.progress}%` }}
              className="h-full bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] rounded-full shadow-[0_0_15px_rgba(255,107,44,0.4)]"
            />
          </div>
        </div>

        <div className="flex items-center justify-between pt-4 border-t border-white/5">
          <div className="flex items-center gap-2">
            <Zap size={14} className="text-[#FFD700]" />
            <span className="text-[10px] font-black uppercase tracking-widest text-[#FFD700]">+{subject.xpEarned} XP</span>
          </div>
          <button 
            onClick={onOpen}
            className="flex items-center gap-2 text-[10px] font-black uppercase tracking-[0.2em] text-white hover:text-[#FF6B2C] transition-all group/btn"
          >
            Launch System <ChevronRight size={14} className="group-hover/btn:translate-x-1 transition-transform" />
          </button>
        </div>
      </div>
    </motion.div>
  );
}

function SubjectDetailsOverlay({ subject, onClose, onToggleChapter, onDeepStudy }) {
  const [filter, setFilter] = useState('All');
  const filteredChapters = (subject.chapters || []).filter(c => filter === 'All' || c.status === filter);

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-[1000] flex items-center justify-center p-4 bg-black/90 backdrop-blur-2xl"
    >
      <motion.div
        initial={{ opacity: 0, scale: 0.95, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.95, y: 20 }}
        className="relative w-full max-w-6xl h-[85vh] glass-card rounded-[3rem] border border-white/10 shadow-[0_0_100px_rgba(255,107,44,0.15)] overflow-hidden flex flex-col"
      >
        {/* Close Button */}
        <button 
          onClick={onClose}
          className="absolute top-8 right-8 z-50 p-4 rounded-full bg-white/5 border border-white/10 text-white/40 hover:text-white transition-all"
        >
          <X size={24} />
        </button>

        {/* Content */}
        <div className="flex-1 flex flex-col h-full overflow-hidden">
          <div className="p-12 pb-6 flex flex-col md:flex-row justify-between items-start md:items-end gap-6 border-b border-white/5">
            <div className="space-y-4">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42] text-[10px] font-bold uppercase tracking-widest">
                <Target size={12} /> Target Progress
              </div>
              <h2 className="text-4xl md:text-5xl font-display font-black text-white">{subject.title}</h2>
              <div className="flex items-center gap-6">
                <div className="flex items-center gap-2 text-text-muted text-sm font-medium">
                  <Clock size={16} /> {subject.totalHours}h Studied
                </div>
                <div className="flex items-center gap-2 text-[#FFD700] text-sm font-black uppercase tracking-widest">
                  <Flame size={16} /> {subject.streak}d Streak
                </div>
              </div>
            </div>

            <div className="flex gap-2 bg-white/5 p-1 rounded-xl">
              {['All', 'Not Started', 'In Progress', 'Completed'].map(f => (
                <button
                  key={f}
                  onClick={() => setFilter(f)}
                  className={`px-4 py-2 rounded-lg text-[10px] font-bold uppercase tracking-widest transition-all ${
                    filter === f ? 'bg-[#FF6B2C] text-white' : 'text-white/40 hover:text-white/60'
                  }`}
                >
                  {f}
                </button>
              ))}
            </div>
          </div>

          <div className="flex-1 overflow-y-auto custom-scrollbar p-12 pt-8 space-y-4">
            <div className="grid grid-cols-1 gap-4">
              {filteredChapters.map((chapter, i) => (
                <motion.div
                  key={chapter.id}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: i * 0.05 }}
                  className={`group relative flex items-center justify-between p-6 rounded-2xl border transition-all duration-500 ${
                    chapter.status === 'Completed' 
                      ? 'bg-success/5 border-success/20' 
                      : 'bg-white/5 border-white/5 hover:border-[#FF6B2C]/30 hover:bg-[#FF6B2C]/5'
                  }`}
                >
                  <div className="flex items-center gap-6">
                    <div className={`w-12 h-12 rounded-xl flex items-center justify-center font-display font-bold text-xl ${
                      chapter.status === 'Completed' ? 'bg-success text-white shadow-[0_0_15px_rgba(34,197,94,0.4)]' : 'bg-white/5 text-white/40 group-hover:text-white'
                    }`}>
                      {i + 1}
                    </div>
                    <div>
                      <h4 className={`text-lg font-bold transition-all ${chapter.status === 'Completed' ? 'text-success/70 line-through' : 'text-white'}`}>
                        {chapter.title}
                      </h4>
                      <div className="flex items-center gap-4 mt-1">
                        <span className="text-[10px] text-text-muted uppercase font-bold tracking-widest flex items-center gap-1">
                          <Clock size={12} /> {chapter.duration}
                        </span>
                        <span className={`text-[10px] font-black uppercase tracking-widest ${
                          chapter.status === 'Completed' ? 'text-success' : chapter.status === 'In Progress' ? 'text-warning' : 'text-white/20'
                        }`}>
                          {chapter.status}
                        </span>
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center gap-4">
                    <div className="flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button className="p-2 rounded-lg hover:bg-white/10 text-white/40 hover:text-white">
                        <FileText size={18} />
                      </button>
                      <button className="p-2 rounded-lg hover:bg-white/10 text-white/40 hover:text-white">
                        <BookMarked size={18} />
                      </button>
                    </div>
                    <button 
                      onClick={() => onDeepStudy(chapter.id)}
                      className="px-4 py-2 rounded-lg bg-[#FF6B2C]/10 border border-[#FF6B2C]/30 text-[#FF8C42] text-[10px] font-bold uppercase tracking-widest hover:bg-[#FF6B2C] hover:text-white transition-all flex items-center gap-2"
                    >
                      <Zap size={14} /> Focus
                    </button>
                    <button 
                      onClick={() => onToggleChapter(chapter.id)}
                      className={`w-10 h-10 rounded-xl border flex items-center justify-center transition-all ${
                        chapter.status === 'Completed' 
                          ? 'bg-success border-success text-white' 
                          : 'bg-white/5 border-white/10 text-white/20 hover:border-success/50 hover:text-success'
                      }`}
                    >
                      <CheckCircle2 size={20} />
                    </button>
                  </div>
                </motion.div>
              ))}
            </div>
          </div>
        </div>
      </motion.div>
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
      chapters: [...formData.chapters, { ...chapterInput, id: Math.random().toString(36).substr(2, 9), status: 'Not Started' }]
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
        <div className="p-12 space-y-10 max-h-[90vh] overflow-y-auto custom-scrollbar">
          <div className="flex justify-between items-start">
            <div className="space-y-2">
              <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-[#FF6B2C] to-[#E85D04] flex items-center justify-center shadow-[0_0_20px_rgba(255,107,44,0.4)]">
                <BookOpen className="text-white" size={32} />
              </div>
              <h2 className="text-4xl font-display font-black text-white">Initialize Path</h2>
              <p className="text-text-muted uppercase tracking-[0.2em] text-xs font-bold">Constructing a new knowledge trajectory</p>
            </div>
            <button onClick={onClose} className="p-4 rounded-full border border-white/10 text-white/20 hover:text-white transition-all">
              <X size={24} />
            </button>
          </div>

          <form onSubmit={handleSubmit} className="space-y-8">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              <div className="space-y-6">
                <div className="space-y-2">
                  <label className="text-[10px] uppercase tracking-widest font-black text-[#FF8C42] ml-2">Subject Identity</label>
                  <input
                    required
                    type="text"
                    placeholder="e.g., Machine Learning Architect"
                    className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-all"
                    value={formData.title}
                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-[10px] uppercase tracking-widest font-black text-[#FF8C42] ml-2">Sector</label>
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
                  <label className="text-[10px] uppercase tracking-widest font-black text-[#FF8C42] ml-2">Module Protocol</label>
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

            <div className="pt-6 flex gap-4">
              <button
                type="button"
                onClick={onClose}
                className="flex-1 py-5 rounded-2xl border border-white/10 text-white font-bold hover:bg-white/5 transition-all"
              >
                Abort Protocol
              </button>
              <button
                type="submit"
                className="flex-[2] py-5 rounded-2xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white font-bold shadow-[0_10px_40px_rgba(255,107,44,0.3)] hover:shadow-[0_15px_60px_rgba(255,107,44,0.5)] transition-all flex items-center justify-center gap-3"
              >
                <Rocket size={20} /> Deploy Learning Hub
              </button>
            </div>
          </form>
        </div>
      </motion.div>
    </div>
  );
}

function DeepStudyMode({ chapter, subject, onClose }) {
  const [timeLeft, setTimeLeft] = useState(25 * 60);
  const [isActive, setIsActive] = useState(false);

  useEffect(() => {
    let interval = null;
    if (isActive && timeLeft > 0) {
      interval = setInterval(() => setTimeLeft(prev => prev - 1), 1000);
    } else if (timeLeft === 0) {
      setIsActive(false);
    }
    return () => clearInterval(interval);
  }, [isActive, timeLeft]);

  const m = Math.floor(timeLeft / 60);
  const s = timeLeft % 60;

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-[2000] bg-black flex flex-col items-center justify-center overflow-hidden"
    >
      <div className="absolute inset-0 z-0">
        <div className="absolute inset-0 bg-gradient-to-b from-[#FF6B2C]/10 via-transparent to-black" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full h-full opacity-10">
          <motion.div 
            animate={{ 
              scale: [1, 1.2, 1],
              opacity: [0.3, 0.5, 0.3]
            }}
            transition={{ duration: 15, repeat: Infinity }}
            className="w-full h-full border-[1px] border-[#FF6B2C] rounded-full blur-[100px]"
          />
        </div>
      </div>

      <button 
        onClick={onClose}
        className="absolute top-10 right-10 z-50 p-4 rounded-full border border-white/10 text-white/20 hover:text-white transition-all group"
      >
        <Maximize2 size={32} className="group-hover:rotate-90 transition-transform" />
      </button>

      <div className="relative z-10 w-full max-w-5xl px-6 text-center space-y-16">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="space-y-6"
        >
          <div className="inline-flex items-center gap-3 px-4 py-2 rounded-full bg-[#FF6B2C]/20 border border-[#FF6B2C]/40 text-[#FF8C42] font-black uppercase tracking-[0.4em] text-xs">
            <Sparkles size={16} /> Deep Study Protocol Active
          </div>
          <p className="text-xl text-white/40 font-bold uppercase tracking-widest">{subject.title}</p>
          <h2 className="text-6xl md:text-8xl font-display font-black tracking-tighter text-white">
            {chapter?.title}
          </h2>
        </motion.div>

        <div className="space-y-8">
          <p className="text-8xl md:text-[10rem] font-display font-black text-transparent bg-clip-text bg-gradient-to-b from-white to-[#FF6B2C]/20 tracking-tighter">
            {String(m).padStart(2, '0')}:{String(s).padStart(2, '0')}
          </p>
          <div className="flex justify-center gap-6">
            <button 
              onClick={() => setIsActive(!isActive)}
              className="px-12 py-5 rounded-2xl bg-[#FF6B2C] text-white font-black uppercase tracking-widest shadow-[0_10px_40px_rgba(255,107,44,0.3)] hover:scale-105 transition-all"
            >
              {isActive ? 'Pause Flow' : 'Initiate Session'}
            </button>
            <button 
              onClick={() => setTimeLeft(25 * 60)}
              className="p-5 rounded-2xl bg-white/5 border border-white/10 text-white/40 hover:text-white transition-all"
            >
              <RotateCcw size={24} />
            </button>
          </div>
        </div>

        <div className="pt-12 text-white/20 italic font-light text-2xl max-w-2xl mx-auto">
          "The object of opening the mind, as of opening the mouth, is to shut it again on something solid."
        </div>
      </div>
    </motion.div>
  );
}
