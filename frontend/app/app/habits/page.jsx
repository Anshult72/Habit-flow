'use client';

import { useState, useEffect } from 'react';
import { Plus, Edit2, Trash2, X, Sparkles, Search, Filter, Layers, Zap, Flame, Target, Star } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import toast from 'react-hot-toast';
import useStore from '@/store/useStore';
import { DIFFICULTY_TIERS, normaliseComplexity, getXpForDifficulty } from '@/lib/xp';

export default function Habits() {
  const { habits, addHabit, updateHabit, deleteHabit, syncData, bundles } = useStore();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  
  const getCategoryHexColor = (cat) => {
    const map = {
      'Health': '#10B981',
      'Mindfulness': '#A855F7',
      'Learning': '#3B82F6',
      'Fitness': '#EF4444',
      'Productivity': '#EAB308',
      'Finance': '#14B8A6',
      'Deep Work': '#6366F1',
      'Detox': '#EC4899',
    };
    return map[cat] || '#FF6B2C';
  };

  const [formData, setFormData] = useState({ name: '', category: 'Health', color: getCategoryHexColor('Health'), goal: 30, difficulty: 'Standard', isActive: true });

  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [isTemplatesModalOpen, setIsTemplatesModalOpen] = useState(false);

  const categories = ['Health', 'Mindfulness', 'Learning', 'Fitness', 'Productivity', 'Finance', 'Deep Work', 'Detox'];
  const difficulties = DIFFICULTY_TIERS;

  const templates = [
    { name: 'Monk Mode', category: 'Deep Work', color: getCategoryHexColor('Deep Work'), goal: 30, difficulty: 'Elite' },
    { name: 'Dopamine Detox', category: 'Detox', color: getCategoryHexColor('Detox'), goal: 30, difficulty: 'Advanced' },
    { name: 'Fitness Routine', category: 'Fitness', color: getCategoryHexColor('Fitness'), goal: 20, difficulty: 'Standard' },
    { name: 'Study System', category: 'Learning', color: getCategoryHexColor('Learning'), goal: 25, difficulty: 'Advanced' },
    { name: 'Morning Routine', category: 'Productivity', color: getCategoryHexColor('Productivity'), goal: 28, difficulty: 'Standard' },
  ];

  // Fetch habits from API on mount
  useEffect(() => {
    const fetchHabits = async () => {
      setIsLoading(true);
      try {
        await syncData();
      } catch (err) {
        console.error('Failed to fetch habits:', err);
      } finally {
        setIsLoading(false);
      }
    };
    fetchHabits();
  }, []);

  // Helper: get display name (handles both 'name' and 'title' from DB)
  const getHabitName = (habit) => habit.name || habit.title || 'Unnamed';

  const filteredHabits = habits.filter(h => {
    const habitName = getHabitName(h);
    const matchesSearch = habitName.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = selectedCategory === 'All' || h.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  const applyTemplate = async (template) => {
    await addHabit(template);
    setIsTemplatesModalOpen(false);
  };

  const activateBundle = async (bundle) => {
    const bundleHabits = [
      { name: 'Cold Shower', category: 'Health', color: getCategoryHexColor('Health'), goal: 30, difficulty: 'Advanced' },
      { name: 'Morning Journal', category: 'Mindfulness', color: getCategoryHexColor('Mindfulness'), goal: 30, difficulty: 'Basic' },
      { name: 'Deep Meditation', category: 'Mindfulness', color: getCategoryHexColor('Mindfulness'), goal: 30, difficulty: 'Standard' }
    ];
    for (const h of bundleHabits) {
      await addHabit(h);
    }
    toast.success(`Protocol Bundle "${bundle.name}" activated!`, {
      icon: '⚡',
      style: { border: '1px solid #FF6B2C' }
    });
  };

  const handleOpenModal = (habit = null) => {
    if (habit) {
      setEditingId(habit.id);
      setFormData({ 
        name: getHabitName(habit), 
        category: habit.category, 
        color: habit.color || getCategoryHexColor(habit.category), 
        goal: habit.goal, 
        difficulty: habit.difficulty || 'Standard',
        isActive: habit.isActive !== false,
        isArchived: habit.isArchived === true
      });
    } else {
      setEditingId(null);
      setFormData({ name: '', category: 'Health', color: getCategoryHexColor('Health'), goal: 30, difficulty: 'Standard', isActive: true, isArchived: false });
    }
    setIsModalOpen(true);
  };

  const handleSave = async (e) => {
    e.preventDefault();
    if (!formData.name) return;

    if (editingId) {
      await updateHabit(editingId, formData);
    } else {
      await addHabit(formData);
    }
    setIsModalOpen(false);
  };

  const handleDelete = async (id) => {
    await deleteHabit(id);
  };

  if (isLoading) {
    return (
      <div className="h-96 flex items-center justify-center">
        <motion.div animate={{ rotate: 360 }} transition={{ duration: 2, repeat: Infinity, ease: 'linear' }} className="w-12 h-12 border-2 border-[#FF6B2C] border-t-transparent rounded-full shadow-[0_0_20px_rgba(255,107,44,0.4)]" />
      </div>
    );
  }

  return (
    <div className="space-y-8 pb-10">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6 relative z-10">
        <div>
          <h1 className="text-4xl font-display font-bold text-white tracking-tight flex items-center gap-3">
            Protocol Config <Sparkles className="text-[#FF8C42]" />
          </h1>
          <p className="text-textMuted mt-2 text-lg">Define and calibrate your daily operational habits.</p>
        </div>
        <div className="flex gap-3">
          <button
            onClick={() => setIsTemplatesModalOpen(true)}
            className="px-6 py-3 rounded-full bg-white/5 hover:bg-white/10 text-white font-medium flex items-center gap-2 border border-white/10 transition-all"
          >
            <Layers size={20} className="text-[#FF8C42]" />
            Templates
          </button>
          <button
            onClick={() => handleOpenModal()}
            className="group relative px-6 py-3 rounded-full bg-white text-black font-medium overflow-hidden flex items-center gap-2"
          >
            <div className="absolute inset-0 w-full h-full bg-gradient-to-r from-[#FF6B2C]/20 to-[#E85D04]/20 group-hover:opacity-100 opacity-0 transition-opacity" />
            <Plus size={20} className="relative z-10" />
            <span className="relative z-10">New Protocol</span>
          </button>
        </div>
      </div>

      {/* Protocol Bundles Quick Access */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 relative z-10">
        {bundles.map((bundle) => (
          <motion.div key={bundle.id} whileHover={{ y: -5 }} onClick={() => activateBundle(bundle)} className="glass-card p-5 rounded-2xl border-white/5 hover:border-[#FF6B2C]/40 transition-all cursor-pointer group">
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 rounded-xl bg-[#FF6B2C]/10 flex items-center justify-center border border-[#FF6B2C]/20 group-hover:scale-110 transition-transform">
                <Zap size={20} className="text-[#FF8C42]" />
              </div>
              <div className="flex-1 min-w-0">
                <h3 className="text-sm font-bold text-white truncate">{bundle.name}</h3>
                <p className="text-[10px] text-textMuted uppercase tracking-widest font-medium">Activate Bundle</p>
              </div>
            </div>
          </motion.div>
        ))}
      </div>

      <div className="flex flex-col md:flex-row gap-4 relative z-10">
        <div className="relative flex-1">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-textMuted" size={20} />
          <input
            type="text" placeholder="Search protocols..." value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full bg-white/5 border border-white/10 rounded-2xl pl-12 pr-4 py-3 text-white focus:outline-none focus:border-[#FF6B2C] transition-colors"
          />
        </div>
        <div className="relative min-w-[200px]">
          <Filter className="absolute left-4 top-1/2 -translate-y-1/2 text-textMuted" size={20} />
          <select
            value={selectedCategory} onChange={(e) => setSelectedCategory(e.target.value)}
            className="w-full bg-white/5 border border-white/10 rounded-2xl pl-12 pr-4 py-3 text-white focus:outline-none focus:border-[#FF6B2C] transition-colors appearance-none"
          >
            <option value="All" className="bg-background">All Classifications</option>
            {categories.map(c => (
              <option key={c} value={c} className="bg-background" style={{ color: getCategoryHexColor(c) }}>{c}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Habits Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <AnimatePresence>
          {filteredHabits.map((habit, i) => (
            <motion.div
              key={habit.id} layout initial={{ opacity: 0, scale: 0.9, y: 20 }} animate={{ opacity: 1, scale: 1, y: 0 }} exit={{ opacity: 0, scale: 0.9, y: -20 }}
              transition={{ delay: i * 0.05 }} className="glass-card p-6 rounded-3xl flex flex-col justify-between group hover:border-white/20 transition-all relative overflow-hidden"
            >
              <div className="absolute top-0 right-0 w-32 h-32 opacity-10 rounded-full blur-3xl transform translate-x-10 -translate-y-10 group-hover:opacity-30 transition-opacity" style={{ backgroundColor: getCategoryHexColor(habit.category) }} />
              <div className="flex justify-between items-start mb-6 relative z-10">
                <div className="flex items-start gap-4">
                  <div className="w-4 h-4 rounded-full mt-1" style={{ backgroundColor: getCategoryHexColor(habit.category), boxShadow: `0 0 15px ${getCategoryHexColor(habit.category)}` }} />
                  <div>
                    <h3 className="font-display font-bold text-xl text-white mb-1">{getHabitName(habit)}</h3>
                    <div className="flex items-center gap-2">
                      <span className="text-[10px] px-2 py-0.5 bg-white/5 border border-white/10 rounded uppercase tracking-wide" style={{ color: getCategoryHexColor(habit.category) }}>{habit.category}</span>
                      {habit.isActive === false ? (
                        <span className="text-[10px] px-2 py-0.5 bg-white/[0.02] border border-white/[0.04] rounded uppercase tracking-wide text-white/20">Inactive</span>
                      ) : habit.isXpEligible !== false ? (
                        <span className={`text-[10px] px-2 py-0.5 bg-white/5 border border-white/10 rounded uppercase tracking-wide font-bold ${difficulties.find(d => d.label === normaliseComplexity(habit.difficulty))?.color || 'text-white'}`}>
                          {normaliseComplexity(habit.difficulty)}
                        </span>
                      ) : (
                        <span className="text-[10px] px-2 py-0.5 bg-white/[0.04] border border-white/[0.06] rounded uppercase tracking-wide font-bold text-white/25">
                          TRACKING ONLY
                        </span>
                      )}
                    </div>
                  </div>
                </div>
                <div className="flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                  <button onClick={() => handleOpenModal(habit)} className="p-2 bg-white/5 hover:bg-white/10 rounded-xl text-textMuted hover:text-white transition-colors"><Edit2 size={16} /></button>
                  <button onClick={() => handleDelete(habit.id)} className="p-2 bg-danger/10 hover:bg-danger/20 rounded-xl text-danger hover:text-red-400 transition-colors border border-danger/20 hover:border-danger/40"><Trash2 size={16} /></button>
                </div>
              </div>
              <div className="mt-auto pt-6 border-t border-white/5 flex justify-between items-end relative z-10">
                <div>
                  <p className="text-xs text-textMuted uppercase tracking-wider mb-1">Target</p>
                  <p className="font-display text-2xl font-bold text-white">{habit.goal || 30} <span className="text-sm font-medium text-textMuted">Days/Mo</span></p>
                </div>
                <div className="text-right">
                  <p className="text-[10px] text-textMuted uppercase tracking-wider mb-1">XP Value</p>
                  <p className="font-bold text-[#FF8C42]">
                    {habit.isActive !== false && habit.isXpEligible !== false 
                      ? `${getXpForDifficulty(habit.difficulty)} XP` 
                      : '0 XP'}
                  </p>
                </div>
              </div>
            </motion.div>
          ))}
        </AnimatePresence>
      </div>

      {/* Empty State */}
      {!isLoading && filteredHabits.length === 0 && (
        <motion.div 
          initial={{ opacity: 0, y: 20 }} 
          animate={{ opacity: 1, y: 0 }} 
          className="flex flex-col items-center justify-center py-20 text-center"
        >
          <div className="relative mb-6">
            <motion.div 
              animate={{ scale: [1, 1.2, 1], opacity: [0.2, 0.4, 0.2] }}
              transition={{ duration: 4, repeat: Infinity }}
              className="absolute inset-0 bg-[#FF6B2C] rounded-full blur-[40px]"
            />
            <div className="relative w-24 h-24 rounded-full border-2 border-dashed border-white/20 flex items-center justify-center">
              <Target size={40} className="text-white/20" />
            </div>
          </div>
          <h3 className="text-2xl font-bold text-white mb-2">No Protocols Found</h3>
          <p className="text-textMuted max-w-sm mb-6">
            {searchQuery || selectedCategory !== 'All' 
              ? 'No habits match your current filters. Try adjusting your search.' 
              : 'No habits yet — create your first protocol to begin your journey.'}
          </p>
          {!searchQuery && selectedCategory === 'All' && (
            <button
              onClick={() => handleOpenModal()}
              className="px-6 py-3 rounded-full bg-[#FF6B2C] text-white font-bold shadow-[0_0_20px_rgba(255,107,44,0.3)] hover:shadow-[0_0_30px_rgba(255,107,44,0.5)] transition-all flex items-center gap-2"
            >
              <Plus size={20} /> Initialize First Protocol
            </button>
          )}
        </motion.div>
      )}

      {/* Create/Edit Modal */}
      <AnimatePresence>
        {isModalOpen && (
          <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="absolute inset-0 bg-background/80 backdrop-blur-xl" onClick={() => setIsModalOpen(false)} />
            <motion.div initial={{ opacity: 0, scale: 0.95, y: 20 }} animate={{ opacity: 1, scale: 1, y: 0 }} exit={{ opacity: 0, scale: 0.95, y: 20 }}
              className="glass-card border border-white/10 rounded-3xl p-8 w-full max-w-md relative z-10 shadow-2xl"
            >
              <div className="absolute top-0 right-0 w-64 h-64 bg-[#FF6B2C]/20 rounded-full blur-[80px] -z-10 pointer-events-none" />
              <div className="flex justify-between items-center mb-8">
                <h2 className="text-2xl font-display font-bold text-white">{editingId ? 'Reconfigure Protocol' : 'Initialize Protocol'}</h2>
                <button onClick={() => setIsModalOpen(false)} className="text-textMuted hover:text-white p-2 rounded-full hover:bg-white/5 transition-colors"><X size={24} /></button>
              </div>
              <form onSubmit={handleSave} className="space-y-6">
                <div>
                  <label className="block text-xs font-bold mb-2 text-textMuted uppercase tracking-[0.2em]">Designation</label>
                  <input type="text" required value={formData.name} onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="w-full bg-black/40 border border-white/10 rounded-xl px-5 py-3 text-white focus:outline-none focus:border-[#FF6B2C] focus:ring-1 focus:ring-primary transition-all font-medium placeholder:text-textMuted/50"
                    placeholder="e.g. Morning Run"
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-bold mb-2 text-textMuted uppercase tracking-[0.2em]">Classification</label>
                    <select value={formData.category} onChange={(e) => setFormData({ ...formData, category: e.target.value, color: getCategoryHexColor(e.target.value) })}
                      className="w-full bg-black/40 border border-white/10 rounded-xl px-5 py-3 text-white focus:outline-none focus:border-[#FF6B2C] transition-all font-medium appearance-none"
                    >
                      {categories.map((c) => (<option key={c} value={c} className="bg-background" style={{ color: getCategoryHexColor(c) }}>{c}</option>))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-xs font-bold mb-2 text-textMuted uppercase tracking-[0.2em]">Complexity</label>
                    <select value={formData.difficulty} onChange={(e) => setFormData({ ...formData, difficulty: e.target.value })}
                      className="w-full bg-black/40 border border-white/10 rounded-xl px-5 py-3 text-white focus:outline-none focus:border-[#FF6B2C] transition-all font-medium appearance-none"
                    >
                      {difficulties.map((d) => (<option key={d.label} value={d.label} className="bg-background text-white">{d.label} ({d.xp} XP)</option>))}
                    </select>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold mb-2 text-textMuted uppercase tracking-[0.2em]">Monthly Target (Days)</label>
                  <input type="number" min="1" max="31" value={formData.goal} onChange={(e) => setFormData({ ...formData, goal: parseInt(e.target.value) || 0 })}
                    className="w-full bg-black/40 border border-white/10 rounded-xl px-5 py-3 text-white focus:outline-none focus:border-[#FF6B2C] transition-all font-medium font-display text-xl"
                  />
                </div>

                <div className="flex items-center gap-3 p-4 rounded-xl bg-white/5 border border-white/10">
                  <input 
                    type="checkbox" 
                    id="isActiveToggle"
                    checked={formData.isActive !== false} 
                    onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })}
                    className="w-4 h-4 rounded border-white/10 bg-black/40 text-[#FF6B2C] focus:ring-[#FF6B2C] cursor-pointer"
                  />
                  <div>
                    <label htmlFor="isActiveToggle" className="block text-xs font-bold text-white uppercase tracking-wider cursor-pointer">Active Tracking</label>
                    <p className="text-[10px] text-textMuted mt-0.5 leading-normal">Disable to pause XP earning and streak tracking for this protocol.</p>
                  </div>
                </div>
                <div className="pt-4 flex gap-4">
                  <button type="button" onClick={() => setIsModalOpen(false)} className="flex-1 px-4 py-3 rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 text-white transition-colors font-medium">Abort</button>
                  <button type="submit" className="flex-1 px-4 py-3 rounded-xl bg-white text-black hover:bg-gray-200 transition-colors font-bold shadow-[0_0_20px_rgba(255,255,255,0.3)]">Deploy</button>
                </div>
              </form>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* Templates Modal */}
      <AnimatePresence>
        {isTemplatesModalOpen && (
          <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="absolute inset-0 bg-background/80 backdrop-blur-xl" onClick={() => setIsTemplatesModalOpen(false)} />
            <motion.div initial={{ opacity: 0, scale: 0.95, y: 20 }} animate={{ opacity: 1, scale: 1, y: 0 }} exit={{ opacity: 0, scale: 0.95, y: 20 }}
              className="glass-card border border-white/10 rounded-3xl p-8 w-full max-w-2xl relative z-10 shadow-2xl"
            >
              <div className="flex justify-between items-center mb-8">
                <h2 className="text-2xl font-display font-bold text-white flex items-center gap-2"><Layers className="text-[#FF8C42]" /> Ready-Made Systems</h2>
                <button onClick={() => setIsTemplatesModalOpen(false)} className="text-textMuted hover:text-white p-2 rounded-full hover:bg-white/5 transition-colors"><X size={24} /></button>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {templates.map((tpl, i) => (
                  <motion.div key={i} whileHover={{ scale: 1.02 }} onClick={() => applyTemplate(tpl)}
                    className="p-5 rounded-2xl bg-white/5 border border-white/10 hover:border-[#FF6B2C]/50 cursor-pointer transition-all relative overflow-hidden group"
                  >
                    <div className="absolute top-0 right-0 w-24 h-24 rounded-full blur-2xl opacity-10 group-hover:opacity-30 transition-opacity" style={{ backgroundColor: tpl.color }} />
                    <h3 className="text-lg font-bold text-white mb-1">{tpl.name}</h3>
                    <div className="flex items-center gap-2 text-sm text-textMuted">
                      <span className="px-2 py-0.5 rounded-md bg-white/5 uppercase tracking-wide text-[10px]" style={{ color: getCategoryHexColor(tpl.category) }}>{tpl.category}</span>
                      <span>• {tpl.goal} Days</span>
                      <span className="text-[10px] text-[#FF8C42] font-bold">{tpl.difficulty}</span>
                    </div>
                  </motion.div>
                ))}
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
