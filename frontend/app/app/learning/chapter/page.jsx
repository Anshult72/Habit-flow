'use client';

import { useState, useMemo, Suspense } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import { 
  ChevronLeft, Plus, Target, 
  Flame, CheckCircle2, MoreVertical,
  Trash2, Edit3, Zap, Layout,
  ArrowRight, BookOpen, Brain,
  Square, CheckSquare, ListTodo
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import useStore from '@/store/useStore';

function ChapterDetailContent() {
  const searchParams = useSearchParams();
  const subjectId = searchParams.get('subjectId');
  const chapterId = searchParams.get('chapterId');
  const router = useRouter();
  const { subjects, addTopic, deleteTopic, updateTopic, toggleTopicStatus } = useStore();
  
  const subject = useMemo(() => subjects.find(s => s.id === subjectId), [subjects, subjectId]);
  const chapter = useMemo(() => subject?.chapters.find(c => c.id === chapterId), [subject, chapterId]);
  
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [editingTopic, setEditingTopic] = useState(null);

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
          className="flex items-center gap-2 text-text-muted hover:text-white transition-all group"
        >
          <ChevronLeft size={20} className="group-hover:-translate-x-1 transition-transform" />
          <span className="text-sm font-bold uppercase tracking-widest">Back to {subject.title}</span>
        </button>

        {/* Chapter Summary Card */}
        <div className="glass-card p-10 rounded-[3rem] border-white/5 relative overflow-hidden">
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-8 relative z-10">
            <div className="space-y-4">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 flex items-center justify-center text-[#FF6B2C]">
                  <BookOpen size={24} />
                </div>
                <div>
                  <p className="text-[10px] text-[#FF8C42] font-black uppercase tracking-widest">Module Segment</p>
                  <h1 className="text-4xl font-display font-black text-white tracking-tight">{chapter.title}</h1>
                </div>
              </div>
              <p className="text-text-muted text-sm font-medium">
                Complete all topics to finalize this knowledge module.
              </p>
            </div>

            <div className="flex flex-col items-end gap-3">
              <div className="flex items-center gap-4">
                <div className="text-right">
                  <p className="text-[10px] text-text-muted font-bold uppercase tracking-widest">Progress</p>
                  <p className="text-2xl font-display font-black text-[#FF6B2C]">{chapter.progress}%</p>
                </div>
                <div className="w-16 h-16 flex items-center justify-center relative">
                  <svg viewBox="0 0 64 64" className="w-full h-full -rotate-90 overflow-visible">
                    <circle 
                      cx="32" cy="32" r="28" 
                      fill="transparent" 
                      stroke="currentColor" 
                      strokeWidth="4"
                      className="text-white/5"
                    />
                    <motion.circle 
                      cx="32" cy="32" r="28" 
                      fill="transparent" 
                      stroke="currentColor" 
                      strokeWidth="4"
                      strokeDasharray="175.93"
                      initial={{ strokeDashoffset: 175.93 }}
                      animate={{ strokeDashoffset: 175.93 - (175.93 * (chapter.progress || 0)) / 100 }}
                      transition={{ duration: 1, ease: "easeOut" }}
                      className="text-[#FF6B2C]"
                      strokeLinecap="round"
                    />
                  </svg>
                  <div className="absolute inset-0 flex items-center justify-center">
                    <CheckCircle2 size={16} className={chapter.status === 'Completed' ? 'text-green-500' : 'text-white/10'} />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Topics List */}
        <div className="space-y-8">
          <div className="flex items-center justify-between">
            <h2 className="text-2xl font-display font-bold text-white flex items-center gap-3">
              <ListTodo className="text-[#FF8C42]" /> Topic Nodes
            </h2>
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => setIsAddModalOpen(true)}
              className="px-5 py-2.5 rounded-xl bg-white/5 border border-white/10 text-white/60 text-xs font-bold flex items-center gap-2 hover:bg-white/10 hover:text-white transition-all"
            >
              <Plus size={16} />
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
                    onToggle={() => toggleTopicStatus(subjectId, chapterId, topic.id)}
                    onDelete={() => deleteTopic(subjectId, chapterId, topic.id)}
                    onEdit={() => setEditingTopic(topic)}
                  />
                ))
              ) : (
                <div className="py-20 text-center bg-white/2 rounded-[2rem] border border-white/5 flex flex-col items-center gap-4">
                  <div className="w-12 h-12 rounded-full bg-white/5 flex items-center justify-center text-white/10">
                    <ListTodo size={24} />
                  </div>
                  <p className="text-text-muted text-sm uppercase tracking-widest font-bold">No topic nodes defined.</p>
                </div>
              )}
            </AnimatePresence>
          </div>
        </div>

        {/* Footer Info */}
        <div className="pt-12 flex justify-center">
           <div className="flex items-center gap-8 px-8 py-4 rounded-2xl bg-white/2 border border-white/5">
             <div className="text-center">
               <p className="text-[10px] text-text-muted font-bold uppercase tracking-widest">Total Nodes</p>
               <p className="text-xl font-bold">{topics.length}</p>
             </div>
             <div className="w-px h-8 bg-white/10" />
             <div className="text-center">
               <p className="text-[10px] text-text-muted font-bold uppercase tracking-widest">Finalized</p>
               <p className="text-xl font-bold text-green-500">{completedTopics}</p>
             </div>
             <div className="w-px h-8 bg-white/10" />
             <div className="text-center">
               <p className="text-[10px] text-text-muted font-bold uppercase tracking-widest">Active</p>
               <p className="text-xl font-bold text-[#FF8C42]">{topics.length - completedTopics}</p>
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
    </div>
  );
}

function TopicItem({ topic, index, onToggle, onDelete, onEdit }) {
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
          <p className={`text-[9px] font-black uppercase tracking-widest ${statusColors[topic.status]}`}>
            {topic.status}
          </p>
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
