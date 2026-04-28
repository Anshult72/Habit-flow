import { useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  StickyNote, Plus, Search, Filter, Pin, 
  Trash2, Edit3, MoreVertical, Sparkles,
  Layers, Brain, Zap, Clock, Bookmark,
  ChevronRight, X, Maximize2, Tag, Palette,
  CheckSquare, FileText, Link, Calendar,
  ArrowUpRight, Info, AlertCircle, Quote
} from 'lucide-react';
import useStore from '../store/useStore';
import { format } from 'date-fns';

export default function MemoSection() {
  const { memos, addMemo, updateMemo, deleteMemo, togglePinMemo } = useStore();
  const [searchQuery, setSearchQuery] = useState('');
  const [activeCategory, setActiveCategory] = useState('All');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingMemo, setEditingMemo] = useState(null);
  const [quickThought, setQuickThought] = useState('');

  const categories = ['All', 'Ideas', 'Study', 'Vision', 'Routine', 'Research', 'Business', 'Coding', 'Personal'];

  const filteredMemos = useMemo(() => {
    return memos.filter(m => {
      const matchesSearch = m.title.toLowerCase().includes(searchQuery.toLowerCase()) || 
                           m.content.toLowerCase().includes(searchQuery.toLowerCase());
      const matchesCategory = activeCategory === 'All' || m.category === activeCategory;
      return matchesSearch && matchesCategory;
    });
  }, [memos, searchQuery, activeCategory]);

  const pinnedMemos = filteredMemos.filter(m => m.isPinned);
  const otherMemos = filteredMemos.filter(m => !m.isPinned);

  const handleQuickAdd = (e) => {
    if (e.key === 'Enter' && quickThought.trim()) {
      addMemo({
        title: 'Quick Thought',
        content: quickThought,
        category: 'Ideas',
        priority: 'Low'
      });
      setQuickThought('');
    }
  };

  return (
    <div className="min-h-screen bg-[#050505] text-white pt-6 pb-24 px-4 md:px-10 overflow-x-hidden">
      {/* Background Ambience */}
      <div className="fixed inset-0 pointer-events-none z-0">
        <div className="absolute top-[10%] left-[5%] w-[40%] h-[40%] bg-[#FF6B2C]/3 rounded-full blur-[120px]" />
        <div className="absolute bottom-[10%] right-[5%] w-[30%] h-[30%] bg-[#E85D04]/2 rounded-full blur-[100px]" />
      </div>

      <div className="max-w-7xl mx-auto space-y-12 relative z-10">
        
        {/* Header & Quick Capture */}
        <div className="flex flex-col lg:flex-row justify-between items-start lg:items-center gap-8">
          <div className="space-y-2">
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              className="flex items-center gap-4"
            >
              <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-[#FF6B2C] to-[#E85D04] flex items-center justify-center shadow-[0_0_30px_rgba(255,107,44,0.4)]">
                <Brain className="text-white" size={28} />
              </div>
              <div>
                <h1 className="text-4xl md:text-5xl font-display font-black tracking-tight text-white">Second Brain</h1>
                <p className="text-textMuted uppercase tracking-[0.3em] text-[10px] font-bold">Cognitive Cache v2.1</p>
              </div>
            </motion.div>
          </div>

          <div className="flex flex-col sm:flex-row items-center gap-4 w-full lg:w-auto">
            <div className="relative flex-1 lg:w-96 group">
              <Zap className="absolute left-4 top-1/2 -translate-y-1/2 text-[#FF6B2C] opacity-40 group-focus-within:opacity-100 transition-opacity" size={18} />
              <input 
                type="text" 
                placeholder="Quick Capture thought... (Enter to save)"
                value={quickThought}
                onChange={(e) => setQuickThought(e.target.value)}
                onKeyDown={handleQuickAdd}
                className="w-full bg-white/5 border border-white/10 rounded-2xl py-4 pl-12 pr-6 text-sm focus:outline-none focus:border-[#FF6B2C]/50 transition-all placeholder:text-white/20 font-medium"
              />
            </div>
            
            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              onClick={() => setIsModalOpen(true)}
              className="px-8 py-4 rounded-2xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white font-bold shadow-[0_10px_30px_rgba(255,107,44,0.3)] hover:shadow-[0_15px_40px_rgba(255,107,44,0.5)] transition-all flex items-center gap-3 group whitespace-nowrap"
            >
              <Plus size={20} className="group-hover:rotate-90 transition-transform duration-300" />
              New Memo
            </motion.button>
          </div>
        </div>

        {/* Filters & Search */}
        <div className="flex flex-col md:flex-row items-center justify-between gap-6 pb-6 border-b border-white/5">
          <div className="flex items-center gap-2 overflow-x-auto no-scrollbar pb-2 md:pb-0 w-full md:w-auto">
            {categories.map(cat => (
              <button
                key={cat}
                onClick={() => setActiveCategory(cat)}
                className={`px-5 py-2.5 rounded-xl text-xs font-bold whitespace-nowrap transition-all border ${
                  activeCategory === cat 
                    ? 'bg-[#FF6B2C] border-[#FF6B2C] text-white shadow-[0_0_20px_rgba(255,107,44,0.3)]' 
                    : 'bg-white/5 border-white/10 text-white/40 hover:text-white/60 hover:border-white/20'
                }`}
              >
                {cat}
              </button>
            ))}
          </div>

          <div className="relative w-full md:w-64 group">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20 group-focus-within:text-[#FF6B2C] transition-colors" size={16} />
            <input 
              type="text" 
              placeholder="Search brain..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full bg-white/5 border border-white/10 rounded-xl py-3 pl-10 pr-4 text-xs focus:outline-none focus:border-[#FF6B2C]/50 transition-all text-white"
            />
          </div>
        </div>

        {/* Pinned Section */}
        {pinnedMemos.length > 0 && (
          <div className="space-y-6">
            <div className="flex items-center gap-3">
              <Pin size={18} className="text-[#FF8C42] rotate-45" />
              <h2 className="text-xl font-display font-bold text-white uppercase tracking-widest">Priority Sync</h2>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {pinnedMemos.map((memo, i) => (
                <MemoCard 
                  key={memo.id} 
                  memo={memo} 
                  index={i}
                  onEdit={() => { setEditingMemo(memo); setIsModalOpen(true); }}
                  onDelete={() => deleteMemo(memo.id)}
                  onTogglePin={() => togglePinMemo(memo.id)}
                />
              ))}
            </div>
          </div>
        )}

        {/* Grid Section */}
        <div className="space-y-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <Layers size={18} className="text-textMuted" />
              <h2 className="text-xl font-display font-bold text-white uppercase tracking-widest">Thought Reservoir</h2>
            </div>
            <span className="text-xs text-textMuted font-bold uppercase tracking-widest">{filteredMemos.length} Units Found</span>
          </div>

          <AnimatePresence mode="popLayout">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {otherMemos.map((memo, i) => (
                <MemoCard 
                  key={memo.id} 
                  memo={memo} 
                  index={i}
                  onEdit={() => { setEditingMemo(memo); setIsModalOpen(true); }}
                  onDelete={() => deleteMemo(memo.id)}
                  onTogglePin={() => togglePinMemo(memo.id)}
                />
              ))}

              {filteredMemos.length === 0 && (
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
                      <StickyNote size={40} className="text-white/20" />
                    </div>
                  </div>
                  <div className="space-y-2">
                    <h3 className="text-2xl font-bold text-white">Synaptic Void Detected.</h3>
                    <p className="text-textMuted max-w-sm mx-auto">No thoughts currently cached. Use Quick Capture or Initialize a new Memo to fill your Second Brain.</p>
                  </div>
                </motion.div>
              )}
            </div>
          </AnimatePresence>
        </div>
      </div>

      {/* Modal */}
      <AnimatePresence>
        {isModalOpen && (
          <MemoModal 
            onClose={() => { setIsModalOpen(false); setEditingMemo(null); }}
            onSave={(data) => {
              if (editingMemo) {
                updateMemo(editingMemo.id, data);
              } else {
                addMemo(data);
              }
              setIsModalOpen(false);
              setEditingMemo(null);
            }}
            initialData={editingMemo}
          />
        )}
      </AnimatePresence>
    </div>
  );
}

function MemoCard({ memo, index, onEdit, onDelete, onTogglePin }) {
  const getPriorityColor = (p) => {
    switch (p) {
      case 'High': return '#ef4444';
      case 'Medium': return '#f59e0b';
      case 'Low': return '#3b82f6';
      default: return '#FF6B2C';
    }
  };

  return (
    <motion.div
      layout
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, scale: 0.9 }}
      transition={{ delay: index * 0.05 }}
      whileHover={{ y: -5 }}
      className={`group relative flex flex-col glass-card rounded-3xl border-white/5 overflow-hidden transition-all duration-300 ${
        memo.isPinned ? 'border-[#FF6B2C]/30 shadow-[0_0_30px_rgba(255,107,44,0.05)]' : 'hover:border-white/10'
      }`}
    >
      {/* Priority Indicator */}
      <div 
        className="absolute top-0 left-0 right-0 h-1" 
        style={{ backgroundColor: memo.color || getPriorityColor(memo.priority) }}
      />

      <div className="p-6 space-y-4 relative z-10">
        <div className="flex justify-between items-start">
          <div className="space-y-1 max-w-[80%]">
            <h3 className="text-lg font-bold text-white group-hover:text-[#FF6B2C] transition-colors truncate">
              {memo.title}
            </h3>
            <span className="inline-block px-2 py-0.5 rounded-full bg-white/5 text-[9px] font-black uppercase tracking-widest text-[#FF8C42]">
              {memo.category}
            </span>
          </div>
          <button 
            onClick={onTogglePin}
            className={`p-1.5 rounded-lg transition-all ${
              memo.isPinned ? 'text-[#FF6B2C] bg-[#FF6B2C]/10 shadow-[0_0_10px_rgba(255,107,44,0.2)]' : 'text-white/10 hover:text-white/40'
            }`}
          >
            <Pin size={14} className={memo.isPinned ? 'rotate-0' : 'rotate-45'} />
          </button>
        </div>

        <p className="text-sm text-textMuted line-clamp-4 leading-relaxed font-medium">
          {memo.content}
        </p>

        <div className="flex items-center justify-between pt-4 border-t border-white/5">
          <span className="text-[10px] text-white/20 font-bold tracking-widest uppercase flex items-center gap-1.5">
            <Clock size={12} /> {format(new Date(memo.createdAt), 'MMM dd, yyyy')}
          </span>
          <div className="flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
            <button 
              onClick={onEdit}
              className="p-2 rounded-lg bg-white/5 text-white/40 hover:text-[#FF6B2C] hover:bg-[#FF6B2C]/10 transition-all"
            >
              <Edit3 size={14} />
            </button>
            <button 
              onClick={onDelete}
              className="p-2 rounded-lg bg-white/5 text-white/40 hover:text-red-500 hover:bg-red-500/10 transition-all"
            >
              <Trash2 size={14} />
            </button>
          </div>
        </div>
      </div>
    </motion.div>
  );
}

function MemoModal({ onClose, onSave, initialData }) {
  const [title, setTitle] = useState(initialData?.title || '');
  const [content, setContent] = useState(initialData?.content || '');
  const [category, setCategory] = useState(initialData?.category || 'Ideas');
  const [priority, setPriority] = useState(initialData?.priority || 'Low');
  const [color, setColor] = useState(initialData?.color || '#FF6B2C');

  const categories = ['Ideas', 'Study', 'Vision', 'Routine', 'Research', 'Business', 'Coding', 'Personal'];
  const priorities = ['Low', 'Medium', 'High'];
  const colors = ['#FF6B2C', '#E85D04', '#FFB347', '#3b82f6', '#10B981', '#ef4444', '#a855f7'];

  return (
    <div className="fixed inset-0 z-[1000] flex items-center justify-center p-4 bg-black/90 backdrop-blur-2xl">
      <motion.div
        initial={{ opacity: 0, scale: 0.95, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        className="relative w-full max-w-2xl glass-card rounded-[2.5rem] border border-white/10 shadow-[0_0_100px_rgba(255,107,44,0.15)] overflow-hidden"
      >
        <div className="p-10 space-y-8">
          <div className="flex justify-between items-center">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-xl bg-[#FF6B2C]/10 flex items-center justify-center text-[#FF6B2C]">
                {initialData ? <Edit3 size={24} /> : <Plus size={24} />}
              </div>
              <div>
                <h2 className="text-3xl font-display font-black text-white">{initialData ? 'Refine Memo' : 'Cache Thought'}</h2>
                <p className="text-textMuted uppercase tracking-[0.2em] text-[10px] font-bold">Synaptic Storage Protocol</p>
              </div>
            </div>
            <button onClick={onClose} className="p-3 rounded-full border border-white/10 text-white/20 hover:text-white transition-all">
              <X size={20} />
            </button>
          </div>

          <div className="space-y-6">
            <div className="space-y-2">
              <label className="text-[10px] uppercase tracking-widest font-black text-[#FF8C42] ml-2">Header</label>
              <input
                type="text"
                placeholder="Title your insight..."
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-all font-bold"
              />
            </div>

            <div className="space-y-2">
              <label className="text-[10px] uppercase tracking-widest font-black text-[#FF8C42] ml-2">Substance</label>
              <textarea
                placeholder="Expand your consciousness here..."
                value={content}
                onChange={(e) => setContent(e.target.value)}
                rows={6}
                className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-all resize-none leading-relaxed"
              />
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <label className="text-[10px] uppercase tracking-widest font-black text-white/20 ml-2">Classification</label>
                <div className="flex flex-wrap gap-2">
                  {categories.map(cat => (
                    <button
                      key={cat}
                      onClick={() => setCategory(cat)}
                      className={`px-3 py-1.5 rounded-lg text-[10px] font-bold uppercase transition-all border ${
                        category === cat ? 'bg-[#FF6B2C] border-[#FF6B2C] text-white' : 'bg-white/5 border-white/10 text-white/40 hover:text-white/60'
                      }`}
                    >
                      {cat}
                    </button>
                  ))}
                </div>
              </div>

              <div className="space-y-4">
                <div className="space-y-2">
                  <label className="text-[10px] uppercase tracking-widest font-black text-white/20 ml-2">Priority Tier</label>
                  <div className="flex gap-2">
                    {priorities.map(p => (
                      <button
                        key={p}
                        onClick={() => setPriority(p)}
                        className={`flex-1 py-2 rounded-lg text-[10px] font-bold uppercase transition-all border ${
                          priority === p ? 'bg-white/10 border-white/20 text-white' : 'bg-white/5 border-white/10 text-white/20 hover:text-white/40'
                        }`}
                      >
                        {p}
                      </button>
                    ))}
                  </div>
                </div>
                <div className="space-y-2">
                  <label className="text-[10px] uppercase tracking-widest font-black text-white/20 ml-2">Aura Color</label>
                  <div className="flex gap-2">
                    {colors.map(c => (
                      <button
                        key={c}
                        onClick={() => setColor(c)}
                        className={`w-6 h-6 rounded-full transition-all ${color === c ? 'scale-125 shadow-[0_0_10px_rgba(255,255,255,0.3)]' : 'opacity-40 hover:opacity-100'}`}
                        style={{ backgroundColor: c }}
                      />
                    ))}
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div className="pt-4 flex gap-4">
            <button
              onClick={onClose}
              className="flex-1 py-5 rounded-2xl border border-white/10 text-white font-bold hover:bg-white/5 transition-all"
            >
              Abort
            </button>
            <button
              onClick={() => onSave({ title, content, category, priority, color })}
              className="flex-[2] py-5 rounded-2xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white font-bold shadow-[0_10px_40px_rgba(255,107,44,0.3)] hover:shadow-[0_15px_60px_rgba(255,107,44,0.5)] transition-all flex items-center justify-center gap-3"
            >
              <Sparkles size={20} /> {initialData ? 'Sync Insight' : 'Commit to Memory'}
            </button>
          </div>
        </div>
      </motion.div>
    </div>
  );
}
