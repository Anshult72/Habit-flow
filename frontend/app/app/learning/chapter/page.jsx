'use client';

import { useState, useMemo, Suspense, useCallback } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import { 
  ChevronLeft, Plus, Target, 
  Flame, CheckCircle2, MoreVertical,
  Trash2, Edit3, Zap, Layout,
  ArrowRight, BookOpen, Brain,
  Square, CheckSquare, ListTodo, Award,
  Sparkles, Lock, Shield
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import useStore from '@/store/useStore';
import { emitXpEvent, CelebrationOverlay } from '@/components/XpToast';
import { getXpPerTopic, getStreakTier, MAX_XP_ELIGIBLE_TOPICS_PER_MODULE } from '@/lib/learningXpEngine';

function ChapterDetailContent() {
  const searchParams = useSearchParams();
  const subjectId = searchParams.get('subjectId');
  const chapterId = searchParams.get('chapterId');
  const router = useRouter();
  const { subjects, addTopic, deleteTopic, updateTopic, completeTopicWithXp, toggleTopicStatus, getSubjectStreakInfo } = useStore();
  
  const subject = useMemo(() => subjects.find(s => s.id === subjectId), [subjects, subjectId]);
  const chapter = useMemo(() => subject?.chapters.find(c => c.id === chapterId), [subject, chapterId]);
  
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [editingTopic, setEditingTopic] = useState(null);
  const [celebration, setCelebration] = useState({ show: false, type: null });

  if (!subject || !chapter) {
    return (
      <div className="min-h-screen bg-[#050505] flex flex-col items-center justify-center space-y-6">
        <div className="w-20 h-20 rounded-full bg-white/5 flex items-center justify-center animate-pulse">
          <Layout className="text-white/20" size={40} />
        </div>
        <h2 className="text-2xl font-bold text-white">Chapter Not Found</h2>
        <button onClick={() => router.push(`/app/learning/subject?id=${subjectId}`)} className="text-[#FF6B2C] hover:underline">Return to Subject</button>
      </div>
    );
  }

  const topics = chapter.topics || [];
  const completedTopics = topics.filter(t => t.status === 'Completed').length;
  const streakInfo = getSubjectStreakInfo(subjectId);
  const tier = getStreakTier(streakInfo.streakCount);

  // Count XP-eligible completed topics in this module
  const xpEligibleCount = subject.completedTopicsLog?.[chapterId] || 0;
  const xpCapReached = xpEligibleCount >= MAX_XP_ELIGIBLE_TOPICS_PER_MODULE;

  const handleTopicComplete = useCallback((topicId) => {
    const topic = topics.find(t => t.id === topicId);
    if (!topic) return;

    // If already completed, toggle back (uncomplete)
    if (topic.status === 'Completed') {
      toggleTopicStatus(subjectId, chapterId, topicId);
      return;
    }

    // If status is 'Not Started', first move to 'In Progress'
    if (topic.status === 'Not Started') {
      toggleTopicStatus(subjectId, chapterId, topicId);
      return;
    }

    // If status is 'In Progress', complete with XP
    const result = completeTopicWithXp(subjectId, chapterId, topicId);
    
    if (!result || result.action === 'uncompleted') return;

    // === EMIT XP TOAST EVENTS ===
    
    // Topic XP
    if (result.topicXpEligible && result.topicXp > 0) {
      emitXpEvent({
        type: 'topic-xp',
        xp: result.topicXp,
        message: 'Topic Mastered',
        subMessage: `${result.xpPerTopic} XP/Topic · ${result.streakCount}d Streak`,
      });
    } else if (!result.topicXpEligible) {
      emitXpEvent({
        type: 'xp-capped',
        xp: 0,
        message: 'Topic Completed',
        subMessage: result.topicXpReason,
      });
    }

    // Module bonus
    if (result.moduleBonusXp > 0) {
      setTimeout(() => {
        emitXpEvent({
          type: 'module-bonus',
          xp: result.moduleBonusXp,
          message: 'Module Mastered!',
          subMessage: `Completion Bonus · ${result.xpPerTopic} × 5`,
          duration: 4500,
        });
        setCelebration({ show: true, type: 'module-complete' });
      }, 600);
    }

    // Chapter bonus (all modules complete)
    if (result.chapterBonusXp > 0) {
      setTimeout(() => {
        emitXpEvent({
          type: 'chapter-bonus',
          xp: result.chapterBonusXp,
          message: 'All Chapters Conquered!',
          subMessage: `Subject Completion Bonus · ${result.xpPerTopic} × 10`,
          duration: 5000,
        });
        setCelebration({ show: true, type: 'chapter-complete' });
      }, 1200);
    }

    // Streak milestone
    if (result.streakResult?.isStreakMilestone) {
      setTimeout(() => {
        emitXpEvent({
          type: 'streak-milestone',
          xp: 0,
          message: `${result.streakResult.isStreakMilestone}-Day Streak!`,
          subMessage: `XP Per Topic Increased`,
          streakDays: result.streakResult.isStreakMilestone,
          duration: 5000,
        });
        setCelebration({ show: true, type: `streak-${result.streakResult.isStreakMilestone}` });
      }, 1800);
    }
  }, [topics, subjectId, chapterId, completeTopicWithXp, toggleTopicStatus]);

  return (
    <div className="min-h-screen bg-[#050505] text-white pt-6 pb-24 px-4 md:px-10 relative overflow-x-hidden">
      {/* Ambience */}
      <div className="fixed inset-0 pointer-events-none z-0">
        <div className="absolute top-[15%] left-[-10%] w-[50%] h-[50%] bg-[#FF6B2C]/5 rounded-full blur-[150px]" />
      </div>

      <div className="max-w-4xl mx-auto space-y-12 relative z-10">
        {/* Navigation */}
        <button 
          onClick={() => router.push(`/app/learning/subject?id=${subjectId}`)}
          className="flex items-center gap-3 text-text-muted hover:text-white transition-all group"
        >
          <ChevronLeft size={24} className="group-hover:-translate-x-1 transition-transform" />
          <span className="text-sm font-black uppercase tracking-[0.3em]">Back to {subject.title}</span>
        </button>

        {/* Chapter Summary Card */}
        <div className="glass-card p-12 md:p-16 rounded-[4rem] border-white/5 relative overflow-hidden group">
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-12 relative z-10">
            <div className="space-y-8 flex-1">
              <div className="space-y-4">
                <div className="flex items-center gap-3">
                  <p className="text-[10px] text-[#FF8C42] font-black uppercase tracking-[0.3em]">Module Segment</p>
                  {/* XP Rate badge */}
                  <div 
                    className="flex items-center gap-1.5 px-3 py-1 rounded-full text-[9px] font-black uppercase tracking-widest border"
                    style={{ 
                      backgroundColor: `${tier.color}10`, 
                      borderColor: `${tier.color}30`,
                      color: tier.color 
                    }}
                  >
                    <Zap size={10} />
                    {streakInfo.xpPerTopic} XP/Topic
                  </div>
                </div>
                <div className="flex items-center gap-6">
                  <div className="w-20 h-20 rounded-3xl bg-[#FF6B2C] flex items-center justify-center text-white shadow-[0_0_40px_rgba(255,107,44,0.4)]">
                    <BookOpen size={40} />
                  </div>
                  <h1 className="text-5xl md:text-7xl font-display font-black text-white tracking-tighter leading-none">{chapter.title}</h1>
                </div>
              </div>
              <p className="text-text-muted text-xl font-medium max-w-md leading-relaxed">
                Complete all topics to finalize this knowledge module.
              </p>
            </div>

            <div className="flex flex-col items-center md:items-end gap-6">
              <div className="relative w-40 h-40 flex items-center justify-center">
                <svg viewBox="0 0 100 100" className="w-full h-full -rotate-90">
                  <circle 
                    cx="50" cy="50" r="45" 
                    fill="transparent" 
                    stroke="currentColor" 
                    strokeWidth="6"
                    className="text-white/5"
                  />
                  <motion.circle 
                    cx="50" cy="50" r="45" 
                    fill="transparent" 
                    stroke="currentColor" 
                    strokeWidth="8"
                    strokeDasharray="282.7"
                    initial={{ strokeDashoffset: 282.7 }}
                    animate={{ strokeDashoffset: 282.7 - (282.7 * (chapter.progress || 0)) / 100 }}
                    transition={{ duration: 1.5, ease: "circOut" }}
                    className="text-[#FF6B2C]"
                    strokeLinecap="round"
                  />
                </svg>
                <div className="absolute inset-0 flex flex-col items-center justify-center">
                  <p className="text-[10px] text-text-muted font-black uppercase tracking-widest mb-1">Progress</p>
                  <p className="text-4xl font-display font-black text-white">{chapter.progress}%</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* XP Info Bar */}
        <div className="flex flex-wrap items-center gap-4">
          <div className="flex items-center gap-2 px-4 py-2 rounded-xl bg-white/5 border border-white/5">
            <Flame size={14} style={{ color: tier.color }} />
            <span className="text-[10px] font-black uppercase tracking-widest" style={{ color: tier.color }}>
              {streakInfo.streakCount}d Streak
            </span>
          </div>
          <div className="flex items-center gap-2 px-4 py-2 rounded-xl bg-white/5 border border-white/5">
            <Zap size={14} className="text-[#FFD700]" />
            <span className="text-[10px] font-black uppercase tracking-widest text-[#FFD700]">
              {streakInfo.xpPerTopic} XP/Topic
            </span>
          </div>
          <div className="flex items-center gap-2 px-4 py-2 rounded-xl bg-white/5 border border-white/5">
            <Shield size={14} className={xpCapReached ? 'text-white/30' : 'text-[#10B981]'} />
            <span className={`text-[10px] font-black uppercase tracking-widest ${xpCapReached ? 'text-white/30' : 'text-[#10B981]'}`}>
              {xpEligibleCount}/{MAX_XP_ELIGIBLE_TOPICS_PER_MODULE} XP Slots
            </span>
          </div>
          {xpCapReached && (
            <div className="flex items-center gap-2 px-4 py-2 rounded-xl bg-amber-500/10 border border-amber-500/20">
              <Lock size={14} className="text-amber-500" />
              <span className="text-[10px] font-black uppercase tracking-widest text-amber-500">
                Module XP Cap Reached
              </span>
            </div>
          )}
        </div>

        {/* Topics List */}
        <div className="space-y-10 pt-4">
          <div className="flex items-center justify-between">
            <h2 className="text-5xl font-display font-black text-white flex items-center gap-6">
              <ListTodo className="text-[#FF8C42]" size={40} /> Topic Nodes
            </h2>
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => setIsAddModalOpen(true)}
              className="px-8 py-4 rounded-2xl bg-white/5 border border-white/10 text-white font-black uppercase tracking-[0.2em] text-[10px] flex items-center gap-3 hover:bg-white/10 hover:text-white transition-all shadow-xl"
            >
              <Plus size={20} />
              Add Topic
            </motion.button>
          </div>

          <div className="space-y-4">
            <AnimatePresence mode="popLayout">
              {topics.length > 0 ? (
                topics.map((topic, i) => (
                  <TopicItem 
                    key={topic.id}
                    topic={topic}
                    index={i}
                    subjectId={subjectId}
                    xpAwarded={subject.xpAwardedTopics?.[topic.id]}
                    xpPerTopic={streakInfo.xpPerTopic}
                    onToggle={() => handleTopicComplete(topic.id)}
                    onDelete={() => deleteTopic(subjectId, chapterId, topic.id)}
                    onEdit={() => setEditingTopic(topic)}
                  />
                ))
              ) : (
                <div className="py-32 text-center glass-card rounded-[4rem] border border-white/5 flex flex-col items-center gap-8 group">
                  <div className="w-24 h-24 rounded-full bg-white/2 flex items-center justify-center text-white/5 group-hover:text-[#FF8C42]/20 transition-all duration-700">
                    <ListTodo size={48} />
                  </div>
                  <p className="text-text-muted text-xl uppercase tracking-[0.4em] font-black">No topic nodes defined.</p>
                </div>
              )}
            </AnimatePresence>
          </div>
        </div>

        {/* Footer Stats */}
        <div className="pt-24 pb-12 flex justify-center">
           <div className="flex items-center gap-16 px-16 py-8 rounded-[2.5rem] glass-card border border-white/5">
             <div className="text-center space-y-2">
               <p className="text-[10px] text-text-muted font-black uppercase tracking-[0.3em]">Total Nodes</p>
               <p className="text-4xl font-display font-black text-white">{topics.length}</p>
             </div>
             <div className="w-px h-12 bg-white/10" />
             <div className="text-center space-y-2">
               <p className="text-[10px] text-text-muted font-black uppercase tracking-[0.3em]">Finalized</p>
               <p className="text-4xl font-display font-black text-green-500">{completedTopics}</p>
             </div>
             <div className="w-px h-12 bg-white/10" />
             <div className="text-center space-y-2">
               <p className="text-[10px] text-text-muted font-black uppercase tracking-[0.3em]">XP Earned</p>
               <p className="text-4xl font-display font-black text-[#FFD700]">{subject.xpEarned || 0}</p>
             </div>
           </div>
        </div>
      </div>

      {/* Add/Edit Topic Modal */}
      <AnimatePresence>
        {(isAddModalOpen || editingTopic) && (
          <TopicModal 
            onClose={() => {
              setIsAddModalOpen(false);
              setEditingTopic(null);
            }}
            onSave={(data) => {
              if (editingTopic) {
                updateTopic(subjectId, chapterId, editingTopic.id, data);
              } else {
                addTopic(subjectId, chapterId, data);
              }
              setIsAddModalOpen(false);
              setEditingTopic(null);
            }}
            initialData={editingTopic}
          />
        )}
      </AnimatePresence>

      {/* Celebration Overlay */}
      <CelebrationOverlay
        show={celebration.show}
        type={celebration.type}
        onComplete={() => setCelebration({ show: false, type: null })}
      />
    </div>
  );
}

function TopicItem({ topic, index, subjectId, xpAwarded, xpPerTopic, onToggle, onDelete, onEdit }) {
  const statusColors = {
    'Completed': 'text-green-500',
    'In Progress': 'text-[#FF8C42]',
    'Not Started': 'text-white/20'
  };

  return (
    <motion.div
      layout
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, x: 20 }}
      transition={{ delay: index * 0.05 }}
      className={`group flex items-center justify-between p-5 rounded-2xl border transition-all duration-300 ${
        topic.status === 'Completed' 
          ? 'bg-green-500/5 border-green-500/20' 
          : 'bg-white/5 border-white/5 hover:border-white/10'
      }`}
    >
      <div className="flex items-center gap-5">
        <button 
          onClick={onToggle}
          className={`w-6 h-6 rounded-md border flex items-center justify-center transition-all ${
            topic.status === 'Completed' 
              ? 'bg-green-500 border-green-500 text-white' 
              : topic.status === 'In Progress'
                ? 'bg-[#FF8C42]/20 border-[#FF8C42] text-[#FF8C42]'
                : 'bg-white/5 border-white/20 text-transparent group-hover:border-white/40'
          }`}
        >
          {topic.status === 'Completed' ? <CheckSquare size={14} /> : topic.status === 'In Progress' ? <div className="w-2 h-2 rounded-full bg-[#FF8C42] animate-pulse" /> : <Square size={14} />}
        </button>
        
        <div>
          <h4 className={`font-bold transition-all ${topic.status === 'Completed' ? 'text-white/40 line-through' : 'text-white'}`}>
            {topic.title}
          </h4>
          <div className="flex items-center gap-3">
            <p className={`text-[9px] font-black uppercase tracking-widest ${statusColors[topic.status]}`}>
              {topic.status}
            </p>
            {topic.status === 'Completed' && xpAwarded && (
              <span className="text-[9px] font-black uppercase tracking-widest text-[#FFD700] flex items-center gap-1">
                <Zap size={8} /> +{xpPerTopic} XP
              </span>
            )}
            {topic.status === 'In Progress' && (
              <span className="text-[9px] font-black uppercase tracking-widest text-[#FF8C42]/50">
                Click to complete →
              </span>
            )}
          </div>
        </div>
      </div>

      <div className="flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
        <button 
          onClick={onEdit}
          className="p-2 rounded-lg hover:bg-white/5 text-white/20 hover:text-white transition-all"
        >
          <Edit3 size={16} />
        </button>
        <button 
          onClick={onDelete}
          className="p-2 rounded-lg hover:bg-red-500/10 text-white/20 hover:text-red-500 transition-all"
        >
          <Trash2 size={16} />
        </button>
      </div>
    </motion.div>
  );
}

function TopicModal({ onClose, onSave, initialData }) {
  const [title, setTitle] = useState(initialData?.title || '');

  return (
    <div className="fixed inset-0 z-[2000] flex items-center justify-center p-4 bg-black/90 backdrop-blur-2xl">
      <motion.div
        initial={{ opacity: 0, scale: 0.95, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        className="w-full max-w-md glass-card p-10 rounded-[2.5rem] border border-white/10 space-y-8"
      >
        <div className="space-y-2">
          <h3 className="text-3xl font-display font-black text-white">{initialData ? 'Refine Node' : 'Initialize Node'}</h3>
          <p className="text-text-muted text-xs font-bold uppercase tracking-widest">Topic Data Stream v1.0</p>
        </div>

        <div className="space-y-2">
          <label className="text-[10px] font-black uppercase tracking-widest text-[#FF8C42] ml-2">Node Identity</label>
          <input 
            type="text"
            autoFocus
            placeholder="e.g., Backpropagation Logic"
            className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-all"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && onSave({ title })}
          />
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
            className="flex-[2] py-4 rounded-xl bg-[#FF8C42] text-white font-bold shadow-[0_10px_30px_rgba(255,140,66,0.3)] hover:shadow-[0_15px_40px_rgba(255,140,66,0.5)] transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {initialData ? 'Synchronize' : 'Confirm Node'}
          </button>
        </div>
      </motion.div>
    </div>
  );
}

export default function ChapterDetail() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-[#050505] flex flex-col items-center justify-center space-y-6">
        <div className="w-20 h-20 rounded-full bg-white/5 flex items-center justify-center animate-pulse">
          <Layout className="text-white/20" size={40} />
        </div>
        <h2 className="text-2xl font-bold text-white">Loading Chapter...</h2>
      </div>
    }>
      <ChapterDetailContent />
    </Suspense>
  );
}
