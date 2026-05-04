'use client';

import { useState, useMemo, Suspense } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import { 
  ChevronLeft, Plus, Clock, Target, 
  Flame, CheckCircle2, ChevronRight, MoreVertical,
  Trash2, Edit3, Play, Zap, Layout,
  ArrowRight, BookOpen, Milestone, Brain
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import useStore from '@/store/useStore';

function SubjectDetailContent() {
  const searchParams = useSearchParams();
  const subjectId = searchParams.get('id');
  const router = useRouter();
  const { subjects, addChapter, deleteChapter, updateChapter } = useStore();
  
  const subject = useMemo(() => subjects.find(s => s.id === subjectId), [subjects, subjectId]);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [editingChapter, setEditingChapter] = useState(null);

  if (!subject) {
    return (
      <div className="min-h-screen bg-[#050505] flex flex-col items-center justify-center space-y-6">
        <div className="w-20 h-20 rounded-full bg-white/5 flex items-center justify-center animate-pulse">
          <Brain className="text-white/20" size={40} />
        </div>
        <h2 className="text-2xl font-bold text-white">Subject Not Found</h2>
        <button onClick={() => router.push('/app/learning')} className="text-[#FF6B2C] hover:underline">Return to Hub</button>
      </div>
    );
  }

  const chapters = subject.chapters || [];
  const completedChapters = chapters.filter(c => c.status === 'Completed').length;

  return (
    <div className="min-h-screen bg-[#050505] text-white pt-6 pb-24 px-4 md:px-10 relative overflow-x-hidden">
      {/* Ambience */}
      <div className="fixed inset-0 pointer-events-none z-0">
        <div className="absolute top-[10%] right-[-5%] w-[40%] h-[40%] bg-[#FF6B2C]/5 rounded-full blur-[120px]" />
        <div className="absolute bottom-[10%] left-[-5%] w-[30%] h-[30%] bg-[#E85D04]/3 rounded-full blur-[100px]" />
      </div>

      <div className="max-w-6xl mx-auto space-y-12 relative z-10">
        {/* Navigation */}
        <button 
          onClick={() => router.push('/app/learning')}
          className="flex items-center gap-2 text-text-muted hover:text-white transition-all group"
        >
          <ChevronLeft size={20} className="group-hover:-translate-x-1 transition-transform" />
          <span className="text-sm font-bold uppercase tracking-widest">Back to Hub</span>
        </button>

        {/* Header Stats */}
        <div className="glass-card p-10 rounded-[3rem] border-white/5 relative overflow-hidden">
          <div className="absolute top-0 right-0 p-12 opacity-5">
            <Target size={180} className="text-[#FF6B2C]" />
          </div>
          
          <div className="flex flex-col lg:flex-row justify-between items-start lg:items-end gap-10 relative z-10">
            <div className="space-y-6">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42] text-[10px] font-bold uppercase tracking-widest">
                {subject.category}
              </div>
              <h1 className="text-5xl md:text-6xl font-display font-black text-white tracking-tight">{subject.title}</h1>
              <div className="flex flex-wrap gap-8">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-white/5 flex items-center justify-center">
                    <Milestone className="text-[#FF6B2C]" size={20} />
                  </div>
                  <div>
                    <p className="text-[10px] text-text-muted font-bold uppercase tracking-widest">Modules</p>
                    <p className="text-lg font-bold">{completedChapters} / {chapters.length}</p>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-white/5 flex items-center justify-center">
                    <Clock className="text-[#FF8C42]" size={20} />
                  </div>
                  <div>
                    <p className="text-[10px] text-text-muted font-bold uppercase tracking-widest">Study Time</p>
                    <p className="text-lg font-bold">{subject.totalHours}h Total</p>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-white/5 flex items-center justify-center">
                    <Flame className="text-[#FFD700]" size={20} />
                  </div>
                  <div>
                    <p className="text-[10px] text-text-muted font-bold uppercase tracking-widest">Streak</p>
                    <p className="text-lg font-bold">{subject.streak} Days</p>
                  </div>
                </div>
              </div>
            </div>

            <div className="w-full lg:w-72 space-y-4">
              <div className="flex justify-between items-end">
                <span className="text-[10px] text-text-muted font-black uppercase tracking-widest">Overall Sync</span>
                <span className="text-2xl font-display font-black text-[#FF8C42]">{subject.progress}%</span>
              </div>
              <div className="h-3 bg-white/5 rounded-full overflow-hidden border border-white/5 p-0.5">
                <motion.div 
                  initial={{ width: 0 }}
                  animate={{ width: `${subject.progress}%` }}
                  className="h-full bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] rounded-full shadow-[0_0_20px_rgba(255,107,44,0.4)]"
                />
              </div>
            </div>
          </div>
        </div>

        {/* Chapters Section */}
        <div className="space-y-8">
          <div className="flex items-center justify-between">
            <h2 className="text-3xl font-display font-bold text-white flex items-center gap-3">
              <Layout className="text-[#FF6B2C]" /> Chapter Protocol
            </h2>
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => setIsAddModalOpen(true)}
              className="px-6 py-3 rounded-xl bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42] text-sm font-bold flex items-center gap-2 hover:bg-[#FF6B2C] hover:text-white transition-all shadow-[0_0_20px_rgba(255,107,44,0.1)]"
            >
              <Plus size={18} />
              Add Chapter
            </motion.button>
          </div>

          <div className="grid grid-cols-1 gap-6">
            <AnimatePresence mode="popLayout">
              {chapters.length > 0 ? (
                chapters.map((chapter, i) => (
                  <ChapterCard 
                    key={chapter.id}
                    chapter={chapter}
                    index={i}
                    subjectId={subjectId}
                    onDelete={() => deleteChapter(subjectId, chapter.id)}
                    onEdit={() => setEditingChapter(chapter)}
                    onOpen={() => router.push('/app/learning/chapter?subjectId=' + subjectId + '&chapterId=' + chapter.id)}
                  />
                ))
              ) : (
                <div className="py-20 text-center border-2 border-dashed border-white/5 rounded-[2rem] flex flex-col items-center gap-4">
                  <div className="w-16 h-16 rounded-full bg-white/5 flex items-center justify-center text-white/20">
                    <Milestone size={32} />
                  </div>
                  <p className="text-text-muted font-medium">No chapters detected in this path.</p>
                </div>
              )}
            </AnimatePresence>
          </div>
        </div>
      </div>

      {/* Add/Edit Chapter Modal */}
      <AnimatePresence>
        {(isAddModalOpen || editingChapter) && (
          <ChapterModal 
            onClose={() => {
              setIsAddModalOpen(false);
              setEditingChapter(null);
            }}
            onSave={(data) => {
              if (editingChapter) {
                updateChapter(subjectId, editingChapter.id, data);
              } else {
                addChapter(subjectId, data);
              }
              setIsAddModalOpen(false);
              setEditingChapter(null);
            }}
            initialData={editingChapter}
          />
        )}
      </AnimatePresence>
    </div>
  );
}

function ChapterCard({ chapter, index, subjectId, onDelete, onEdit, onOpen }) {
  const statusColors = {
    'Completed': 'text-green-500 bg-green-500/10 border-green-500/20',
    'In Progress': 'text-[#FF8C42] bg-[#FF8C42]/10 border-[#FF8C42]/20',
    'Not Started': 'text-white/20 bg-white/5 border-white/10'
  };

  return (
    <motion.div
      layout
      initial={{ opacity: 0, x: -20 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, scale: 0.95 }}
      transition={{ delay: index * 0.05 }}
      className="group relative flex flex-col md:flex-row items-center justify-between p-8 glass-card rounded-[2rem] border-white/5 hover:border-[#FF6B2C]/30 transition-all duration-500"
    >
      <div className="flex items-center gap-8 w-full md:w-auto">
        <div className={`w-14 h-14 rounded-2xl flex items-center justify-center font-display font-black text-2xl ${
          chapter.status === 'Completed' ? 'bg-green-500 text-white' : 'bg-white/5 text-white/40'
        }`}>
          {index + 1}
        </div>
        <div className="space-y-1">
          <h3 className={`text-xl font-bold transition-all ${chapter.status === 'Completed' ? 'text-white/50 line-through' : 'text-white'}`}>
            {chapter.title}
          </h3>
          <div className="flex items-center gap-4">
            <div className={`px-2 py-0.5 rounded-md text-[8px] font-black uppercase tracking-widest border ${statusColors[chapter.status] || statusColors['Not Started']}`}>
              {chapter.status}
            </div>
            <span className="text-[10px] text-text-muted font-bold uppercase tracking-widest">
              {chapter.topics?.length || 0} Topics
            </span>
            <span className="text-[10px] text-text-muted font-bold uppercase tracking-widest">
              {chapter.progress || 0}% Complete
            </span>
          </div>
        </div>
      </div>

      <div className="flex items-center gap-6 mt-6 md:mt-0 w-full md:w-auto justify-between md:justify-end">
        {/* Local Progress Bar */}
        <div className="hidden lg:block w-32 h-1.5 bg-white/5 rounded-full overflow-hidden">
          <div 
            className="h-full bg-[#FF6B2C]" 
            style={{ width: `${chapter.progress || 0}%` }} 
          />
        </div>

        <div className="flex items-center gap-2">
          <button 
            onClick={onEdit}
            className="p-3 rounded-xl bg-white/5 border border-white/10 text-white/20 hover:text-white hover:bg-white/10 transition-all"
          >
            <Edit3 size={18} />
          </button>
          <button 
            onClick={onDelete}
            className="p-3 rounded-xl bg-white/5 border border-white/10 text-white/20 hover:text-red-500 hover:bg-red-500/10 hover:border-red-500/20 transition-all"
          >
            <Trash2 size={18} />
          </button>
          <button 
            onClick={onOpen}
            className="px-6 py-3 rounded-xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white text-xs font-black uppercase tracking-[0.2em] shadow-lg hover:scale-105 active:scale-95 transition-all flex items-center gap-2"
          >
            Open <ArrowRight size={16} />
          </button>
        </div>
      </div>
    </motion.div>
  );
}

function ChapterModal({ onClose, onSave, initialData }) {
  const [title, setTitle] = useState(initialData?.title || '');

  return (
    <div className="fixed inset-0 z-[2000] flex items-center justify-center p-4 bg-black/90 backdrop-blur-2xl">
      <motion.div
        initial={{ opacity: 0, scale: 0.95, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        className="w-full max-w-md glass-card p-10 rounded-[2.5rem] border border-white/10 space-y-8"
      >
        <div className="space-y-2">
          <h3 className="text-3xl font-display font-black text-white">{initialData ? 'Modify Module' : 'Inject Module'}</h3>
          <p className="text-text-muted text-xs font-bold uppercase tracking-widest">Protocol Chapter v1.0</p>
        </div>

        <div className="space-y-4">
          <div className="space-y-2">
            <label className="text-[10px] font-black uppercase tracking-widest text-[#FF8C42] ml-2">Module Identity</label>
            <input 
              type="text"
              autoFocus
              placeholder="e.g., Quantum Neural Networks"
              className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-all"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && onSave({ title })}
            />
          </div>
        </div>

        <div className="flex gap-4">
          <button 
            onClick={onClose}
            className="flex-1 py-4 rounded-xl border border-white/10 text-white font-bold hover:bg-white/5 transition-all"
          >
            Abort
          </button>
          <button 
            onClick={() => onSave({ title })}
            disabled={!title}
            className="flex-[2] py-4 rounded-xl bg-[#FF6B2C] text-white font-bold shadow-[0_10px_30px_rgba(255,107,44,0.3)] hover:shadow-[0_15px_40px_rgba(255,107,44,0.5)] transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {initialData ? 'Synchronize' : 'Initialize'}
          </button>
        </div>
      </motion.div>
    </div>
  );
}

export default function SubjectDetail() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-[#050505] flex flex-col items-center justify-center space-y-6">
        <div className="w-20 h-20 rounded-full bg-white/5 flex items-center justify-center animate-pulse">
          <Brain className="text-white/20" size={40} />
        </div>
        <h2 className="text-2xl font-bold text-white">Loading Subject...</h2>
      </div>
    }>
      <SubjectDetailContent />
    </Suspense>
  );
}
