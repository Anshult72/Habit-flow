'use client';

import { useState, useMemo, Suspense, useCallback } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import { 
  ChevronLeft, Plus, Clock, Target, 
  Flame, CheckCircle2, ChevronRight, MoreVertical,
  Trash2, Edit3, Play, Zap, Layout,
  ArrowRight, BookOpen, Milestone, Brain, Award, Sparkles
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import useStore from '@/store/useStore';
import { getXpPerTopic, getStreakTier, checkModuleSoftLock } from '@/lib/learningXpEngine';
import SoftUnlockDialog from '@/components/SoftUnlockDialog';

function SubjectDetailContent() {
  const searchParams = useSearchParams();
  const subjectId = searchParams.get('id');
  const router = useRouter();
  const { subjects, addChapter, deleteChapter, updateChapter, getSubjectStreakInfo } = useStore();
  
  const subject = useMemo(() => subjects.find(s => s.id === subjectId), [subjects, subjectId]);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [editingChapter, setEditingChapter] = useState(null);
  
  // Soft unlock dialog state
  const [softUnlockDialog, setSoftUnlockDialog] = useState({ isOpen: false, previousTitle: '', targetUrl: '' });

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
  const streakInfo = getSubjectStreakInfo(subjectId);
  const tier = streakInfo.tier;

  const handleOpenChapter = useCallback((chapter, index) => {
    const targetUrl = '/app/learning/chapter?subjectId=' + subjectId + '&chapterId=' + chapter.id;
    const lockCheck = checkModuleSoftLock(chapters, index);
    
    if (lockCheck.locked) {
      setSoftUnlockDialog({
        isOpen: true,
        previousTitle: lockCheck.previousTitle,
        targetUrl
      });
    } else {
      router.push(targetUrl);
    }
  }, [chapters, subjectId, router]);

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
        <div className="relative glass-card p-12 md:p-16 rounded-[4rem] border-white/5 overflow-hidden group">
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 opacity-[0.05] pointer-events-none">
            <Target size={400} className="text-[#FF6B2C]" />
          </div>
          
          <div className="flex flex-col gap-12 relative z-10">
            <div className="space-y-6">
              <div className="flex items-center gap-3">
                <div className="inline-flex items-center gap-3 px-4 py-1.5 rounded-full bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42] text-[10px] font-black uppercase tracking-[0.2em]">
                  {subject.category}
                </div>
                {/* Streak tier badge */}
                <div 
                  className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full border text-[10px] font-black uppercase tracking-[0.2em]"
                  style={{ 
                    backgroundColor: `${tier.color}10`, 
                    borderColor: `${tier.color}30`,
                    color: tier.color 
                  }}
                >
                  <Flame size={12} />
                  {tier.label} · {streakInfo.xpPerTopic} XP/Topic
                </div>
              </div>
              <h1 className="text-6xl md:text-8xl font-display font-black text-white tracking-tighter leading-none">{subject.title}</h1>
            </div>

            <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
              <div className="flex items-center gap-5">
                <div className="w-16 h-16 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center text-[#FF6B2C]">
                  <Layout size={28} />
                </div>
                <div>
                  <p className="text-[10px] text-text-muted font-black uppercase tracking-[0.2em]">Modules</p>
                  <p className="text-2xl font-display font-black text-white">{completedChapters} / {chapters.length}</p>
                </div>
              </div>
              <div className="flex items-center gap-5">
                <div className="w-16 h-16 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center" style={{ color: tier.color }}>
                  <Flame size={28} />
                </div>
                <div>
                  <p className="text-[10px] text-text-muted font-black uppercase tracking-[0.2em]">Streak</p>
                  <p className="text-2xl font-display font-black" style={{ color: tier.color }}>{streakInfo.streakCount} Days</p>
                </div>
              </div>
              <div className="flex items-center gap-5">
                <div className="w-16 h-16 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center text-[#FFD700]">
                  <Zap size={28} />
                </div>
                <div>
                  <p className="text-[10px] text-text-muted font-black uppercase tracking-[0.2em]">Total XP</p>
                  <p className="text-2xl font-display font-black text-[#FFD700]">{subject.xpEarned || 0}</p>
                </div>
              </div>
              <div className="flex items-center gap-5">
                <div className="w-16 h-16 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center text-[#10B981]">
                  <Award size={28} />
                </div>
                <div>
                  <p className="text-[10px] text-text-muted font-black uppercase tracking-[0.2em]">XP/Topic</p>
                  <p className="text-2xl font-display font-black text-[#10B981]">{streakInfo.xpPerTopic}</p>
                </div>
              </div>
            </div>

            {/* Streak progress to next tier */}
            {tier.nextTier && (
              <div className="space-y-3">
                <div className="flex justify-between items-end">
                  <span className="text-[10px] text-text-muted font-black uppercase tracking-[0.3em]">
                    Next Tier: {tier.nextTier}-Day Streak
                  </span>
                  <span className="text-sm font-black" style={{ color: tier.color }}>
                    {streakInfo.streakCount}/{tier.nextTier}
                  </span>
                </div>
                <div className="h-2 bg-white/5 rounded-full overflow-hidden border border-white/5 p-0.5">
                  <motion.div 
                    initial={{ width: 0 }}
                    animate={{ width: `${Math.min(100, (streakInfo.streakCount / tier.nextTier) * 100)}%` }}
                    className="h-full rounded-full"
                    style={{ 
                      background: `linear-gradient(90deg, ${tier.color}, ${tier.color}CC)`,
                      boxShadow: `0 0 20px ${tier.color}40`
                    }}
                  />
                </div>
              </div>
            )}

            <div className="pt-4 space-y-4">
              <div className="flex justify-between items-end">
                <span className="text-[10px] text-text-muted font-black uppercase tracking-[0.3em]">Overall Sync</span>
                <span className="text-4xl font-display font-black text-[#FF8C42]">{subject.progress}%</span>
              </div>
              <div className="h-4 bg-white/5 rounded-full overflow-hidden border border-white/10 p-1">
                <motion.div 
                  initial={{ width: 0 }}
                  animate={{ width: `${subject.progress}%` }}
                  className="h-full bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] rounded-full shadow-[0_0_30px_rgba(255,107,44,0.4)]"
                />
              </div>
            </div>
          </div>
        </div>

        {/* Chapters Section */}
        <div className="space-y-10 pt-12">
          <div className="flex items-center justify-between">
            <h2 className="text-5xl font-display font-black text-white flex items-center gap-6">
              <Layout className="text-[#FF6B2C]" size={40} /> Chapter Protocol
            </h2>
            <motion.button
              whileHover={{ scale: 1.05, x: 5 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => setIsAddModalOpen(true)}
              className="px-8 py-4 rounded-2xl bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42] text-sm font-black uppercase tracking-[0.2em] flex items-center gap-3 hover:bg-[#FF6B2C] hover:text-white transition-all shadow-[0_0_30px_rgba(255,107,44,0.15)] group"
            >
              <Plus size={20} className="group-hover:rotate-90 transition-transform" />
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
                    xpPerTopic={streakInfo.xpPerTopic}
                    onDelete={() => deleteChapter(subjectId, chapter.id)}
                    onEdit={() => setEditingChapter(chapter)}
                    onOpen={() => handleOpenChapter(chapter, i)}
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

      {/* Soft Unlock Dialog */}
      <SoftUnlockDialog
        isOpen={softUnlockDialog.isOpen}
        previousModuleTitle={softUnlockDialog.previousTitle}
        onContinue={() => {
          setSoftUnlockDialog({ isOpen: false, previousTitle: '', targetUrl: '' });
          router.push(softUnlockDialog.targetUrl);
        }}
        onGoBack={() => {
          setSoftUnlockDialog({ isOpen: false, previousTitle: '', targetUrl: '' });
        }}
      />
    </div>
  );
}

function ChapterCard({ chapter, index, subjectId, xpPerTopic, onDelete, onEdit, onOpen }) {
  const statusColors = {
    'Completed': 'text-green-500 bg-green-500/10 border-green-500/20',
    'In Progress': 'text-[#FF8C42] bg-[#FF8C42]/10 border-[#FF8C42]/20',
    'Not Started': 'text-white/20 bg-white/5 border-white/10'
  };

  const completedTopics = (chapter.topics || []).filter(t => t.status === 'Completed').length;
  const totalTopics = (chapter.topics || []).length;

  return (
    <motion.div
      layout
      initial={{ opacity: 0, x: -20 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, scale: 0.95 }}
      transition={{ delay: index * 0.05 }}
      className="group relative flex flex-col md:flex-row items-center justify-between p-10 glass-card rounded-[3rem] border-white/5 hover:border-[#FF6B2C]/30 transition-all duration-500 min-h-[180px]"
    >
      <div className="flex items-center gap-10 w-full md:w-auto">
        <div className={`w-1.5 h-16 rounded-full ${chapter.status === 'Completed' ? 'bg-green-500' : 'bg-white/10'}`} />
        <div className="space-y-3">
          <h3 className="text-3xl font-display font-black text-white leading-tight">
            {chapter.title}
          </h3>
          <div className="flex items-center gap-6">
            <div className={`px-3 py-1 rounded-md text-[10px] font-black uppercase tracking-[0.2em] border ${statusColors[chapter.status] || statusColors['Not Started']}`}>
              {chapter.status}
            </div>
            <span className="text-[10px] text-text-muted font-black uppercase tracking-[0.2em]">
              {completedTopics}/{totalTopics} Topics
            </span>
            <span className="text-[10px] text-text-muted font-black uppercase tracking-[0.2em]">
              {chapter.progress || 0}% Complete
            </span>
            {chapter.status === 'Completed' && (
              <span className="text-[10px] text-[#FFD700] font-black uppercase tracking-[0.2em] flex items-center gap-1">
                <Sparkles size={10} /> +{xpPerTopic * 5} Bonus
              </span>
            )}
          </div>
        </div>
      </div>

      <div className="flex items-center gap-4 mt-8 md:mt-0 w-full md:w-auto justify-between md:justify-end">
        <div className="flex items-center gap-3">
          <button 
            onClick={onEdit}
            className="p-4 rounded-2xl bg-white/5 border border-white/10 text-white/20 hover:text-white hover:bg-white/10 transition-all"
          >
            <Edit3 size={20} />
          </button>
          <button 
            onClick={onDelete}
            className="p-4 rounded-2xl bg-white/5 border border-white/10 text-white/20 hover:text-red-500 hover:bg-red-500/10 hover:border-red-500/20 transition-all"
          >
            <Trash2 size={20} />
          </button>
        </div>
        <button 
          onClick={onOpen}
          className="px-8 py-4 rounded-2xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white text-[10px] font-black uppercase tracking-[0.3em] shadow-xl hover:scale-105 active:scale-95 transition-all flex items-center gap-3"
        >
          Open <ArrowRight size={18} />
        </button>
      </div>
    </motion.div>
  );
}

function ChapterModal({ onClose, onSave, initialData }) {
  const [title, setTitle] = useState(initialData?.title || '');

  return (
    <div className="fixed inset-0 z-[2000] flex items-center justify-center p-4 bg-black/90 backdrop-blur-3xl">
      <motion.div
        initial={{ opacity: 0, scale: 0.9, y: 30 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        className="w-full max-w-xl glass-card p-12 md:p-16 rounded-[4rem] border border-white/10 space-y-12 shadow-[0_0_100px_rgba(255,107,44,0.2)]"
      >
        <div className="space-y-4">
          <h3 className="text-5xl font-display font-black text-white tracking-tight">{initialData ? 'Modify Module' : 'Inject Module'}</h3>
          <p className="text-text-muted text-[10px] font-black uppercase tracking-[0.4em]">Protocol Chapter v1.0</p>
        </div>

        <div className="space-y-8">
          <div className="space-y-4">
            <label className="text-[10px] font-black uppercase tracking-[0.3em] text-[#FF8C42] ml-4">MODULE IDENTITY</label>
            <input 
              type="text"
              autoFocus
              placeholder="e.g., Quantum Neural N"
              className="w-full bg-white/5 border border-white/10 rounded-[2.5rem] px-10 py-7 text-white text-2xl font-bold focus:outline-none focus:border-[#FF6B2C]/50 transition-all placeholder:text-white/10"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && onSave({ title })}
            />
          </div>
        </div>

        <div className="flex flex-col md:flex-row gap-6 pt-4">
          <button 
            onClick={onClose}
            className="flex-1 py-6 rounded-[2rem] border border-white/10 text-white font-black uppercase tracking-[0.3em] text-xs hover:bg-white/5 transition-all"
          >
            Abort
          </button>
          <button 
            onClick={() => onSave({ title })}
            disabled={!title}
            className="flex-[2] py-6 rounded-[2rem] bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white font-black uppercase tracking-[0.3em] text-sm shadow-[0_20px_50px_rgba(255,107,44,0.3)] hover:shadow-[0_25px_70px_rgba(255,107,44,0.5)] transition-all disabled:opacity-50 disabled:cursor-not-allowed"
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
