import { useState } from 'react';
import { Plus, Edit2, Trash2, X, Sparkles, Search, Filter, Layers } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import toast from 'react-hot-toast';
import useStore from '../store/useStore';

export default function Habits() {
  const { habits, addHabit, updateHabit, deleteHabit } = useStore();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [formData, setFormData] = useState({ name: '', category: 'Health', color: '#FF6B2C', goal: 30 });

  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [isTemplatesModalOpen, setIsTemplatesModalOpen] = useState(false);

  const categories = ['Health', 'Mindfulness', 'Learning', 'Fitness', 'Productivity', 'Finance', 'Deep Work', 'Detox'];
  const colors = ['#FF6B2C', '#E85D04', '#FF8C42', '#fb923c', '#f97316', '#ea580c', '#c2410c'];

  const templates = [
    { name: 'Monk Mode', category: 'Deep Work', color: '#E85D04', goal: 30 },
    { name: 'Dopamine Detox', category: 'Detox', color: '#c2410c', goal: 30 },
    { name: 'Fitness Routine', category: 'Fitness', color: '#FF6B2C', goal: 20 },
    { name: 'Study System', category: 'Learning', color: '#f97316', goal: 25 },
    { name: 'Morning Routine', category: 'Productivity', color: '#fb923c', goal: 28 },
  ];

  const filteredHabits = habits.filter(h => {
    const matchesSearch = h.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = selectedCategory === 'All' || h.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  const applyTemplate = (template) => {
    addHabit({ id: Date.now().toString(), ...template });
    toast.success(`Applied template: ${template.name}`);
    setIsTemplatesModalOpen(false);
  };

  const handleOpenModal = (habit = null) => {
    if (habit) {
      setEditingId(habit.id);
      setFormData({ name: habit.name, category: habit.category, color: habit.color, goal: habit.goal });
    } else {
      setEditingId(null);
      setFormData({ name: '', category: 'Health', color: '#FF6B2C', goal: 30 });
    }
    setIsModalOpen(true);
  };

  const handleSave = (e) => {
    e.preventDefault();
    if (!formData.name) return;

    if (editingId) {
      updateHabit(editingId, formData);
    } else {
      addHabit({ id: Date.now().toString(), ...formData });
    }
    setIsModalOpen(false);
  };

  return (
    <div className="space-y-8 pb-10">
      <div className="flex justify-between items-center relative z-10">
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

      <div className="flex flex-col md:flex-row gap-4 relative z-10">
        <div className="relative flex-1">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-textMuted" size={20} />
          <input
            type="text"
            placeholder="Search protocols..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full bg-white/5 border border-white/10 rounded-2xl pl-12 pr-4 py-3 text-white focus:outline-none focus:border-[#FF6B2C] transition-colors"
          />
        </div>
        <div className="relative min-w-[200px]">
          <Filter className="absolute left-4 top-1/2 -translate-y-1/2 text-textMuted" size={20} />
          <select
            value={selectedCategory}
            onChange={(e) => setSelectedCategory(e.target.value)}
            className="w-full bg-white/5 border border-white/10 rounded-2xl pl-12 pr-4 py-3 text-white focus:outline-none focus:border-[#FF6B2C] transition-colors appearance-none"
          >
            <option value="All" className="bg-background">All Classifications</option>
            {categories.map(c => (
              <option key={c} value={c} className="bg-background">{c}</option>
            ))}
          </select>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <AnimatePresence>
          {filteredHabits.map((habit, i) => (
            <motion.div
              key={habit.id}
              layout
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: -20 }}
              transition={{ delay: i * 0.05 }}
              className="glass-card p-6 rounded-3xl flex flex-col justify-between group hover:border-white/20 transition-all relative overflow-hidden"
            >
              <div 
                className="absolute top-0 right-0 w-32 h-32 opacity-10 rounded-full blur-3xl transform translate-x-10 -translate-y-10 group-hover:opacity-30 transition-opacity"
                style={{ backgroundColor: habit.color }}
              />
              <div className="flex justify-between items-start mb-6 relative z-10">
                <div className="flex items-start gap-4">
                  <div 
                    className="w-4 h-4 rounded-full mt-1" 
                    style={{ backgroundColor: habit.color, boxShadow: `0 0 15px ${habit.color}` }}
                  />
                  <div>
                    <h3 className="font-display font-bold text-xl text-white mb-1">{habit.name}</h3>
                    <span className="text-xs px-2 py-1 bg-white/5 border border-white/10 rounded-md text-textMuted uppercase tracking-wide">
                      {habit.category}
                    </span>
                  </div>
                </div>
                <div className="flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                  <button onClick={() => handleOpenModal(habit)} className="p-2 bg-white/5 hover:bg-white/10 rounded-xl text-textMuted hover:text-white transition-colors">
                    <Edit2 size={16} />
                  </button>
                  <button onClick={() => deleteHabit(habit.id)} className="p-2 bg-danger/10 hover:bg-danger/20 rounded-xl text-danger hover:text-red-400 transition-colors border border-danger/20 hover:border-danger/40">
                    <Trash2 size={16} />
                  </button>
                </div>
              </div>
              <div className="mt-auto pt-6 border-t border-white/5 flex justify-between items-end relative z-10">
                <div>
                  <p className="text-xs text-textMuted uppercase tracking-wider mb-1">Target</p>
                  <p className="font-display text-2xl font-bold text-white">{habit.goal} <span className="text-sm font-medium text-textMuted">Days/Mo</span></p>
                </div>
                <div className="w-12 h-12 rounded-2xl bg-white/5 flex items-center justify-center border border-white/10 group-hover:border-white/20 transition-colors text-white">
                  {Math.round((habit.goal / 30) * 100)}%
                </div>
              </div>
            </motion.div>
          ))}
        </AnimatePresence>
      </div>

      <AnimatePresence>
        {isModalOpen && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <motion.div 
              initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              className="absolute inset-0 bg-background/80 backdrop-blur-xl"
              onClick={() => setIsModalOpen(false)}
            />
            
            <motion.div
              initial={{ opacity: 0, scale: 0.95, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: 20 }}
              className="glass-card border border-white/10 rounded-3xl p-8 w-full max-w-md relative z-10 shadow-2xl"
            >
              <div className="absolute top-0 right-0 w-64 h-64 bg-[#FF6B2C]/20 rounded-full blur-[80px] -z-10 pointer-events-none" />
              
              <div className="flex justify-between items-center mb-8">
                <h2 className="text-2xl font-display font-bold text-white">{editingId ? 'Reconfigure Protocol' : 'Initialize Protocol'}</h2>
                <button onClick={() => setIsModalOpen(false)} className="text-textMuted hover:text-white p-2 rounded-full hover:bg-white/5 transition-colors">
                  <X size={24} />
                </button>
              </div>

              <form onSubmit={handleSave} className="space-y-6">
                <div>
                  <label className="block text-sm font-medium mb-2 text-textMuted uppercase tracking-wide">Designation</label>
                  <input
                    type="text" required value={formData.name} onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="w-full bg-black/40 border border-white/10 rounded-xl px-5 py-3 text-white focus:outline-none focus:border-[#FF6B2C] focus:ring-1 focus:ring-primary transition-all font-medium placeholder:text-textMuted/50"
                    placeholder="e.g. Morning Run"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2 text-textMuted uppercase tracking-wide">Classification</label>
                  <select
                    value={formData.category} onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                    className="w-full bg-black/40 border border-white/10 rounded-xl px-5 py-3 text-white focus:outline-none focus:border-[#FF6B2C] transition-all font-medium appearance-none"
                  >
                    {categories.map((c) => (
                      <option key={c} value={c} className="bg-background text-white">{c}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium mb-3 text-textMuted uppercase tracking-wide">Aura Color</label>
                  <div className="flex gap-3 flex-wrap">
                    {colors.map((c) => (
                      <button
                        key={c} type="button" onClick={() => setFormData({ ...formData, color: c })}
                        className={`w-10 h-10 rounded-xl transition-all ${formData.color === c ? 'scale-110 ring-2 ring-white ring-offset-2 ring-offset-background' : 'hover:scale-110 opacity-70 hover:opacity-100'}`}
                        style={{ backgroundColor: c, boxShadow: formData.color === c ? `0 0 20px ${c}` : 'none' }}
                      />
                    ))}
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2 text-textMuted uppercase tracking-wide">Monthly Target (Days)</label>
                  <input
                    type="number" min="1" max="31" value={formData.goal} onChange={(e) => setFormData({ ...formData, goal: parseInt(e.target.value) || 0 })}
                    className="w-full bg-black/40 border border-white/10 rounded-xl px-5 py-3 text-white focus:outline-none focus:border-[#FF6B2C] transition-all font-medium font-display text-xl"
                  />
                </div>

                <div className="pt-4 flex gap-4">
                  <button
                    type="button" onClick={() => setIsModalOpen(false)}
                    className="flex-1 px-4 py-3 rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 text-white transition-colors font-medium"
                  >
                    Abort
                  </button>
                  <button
                    type="submit"
                    className="flex-1 px-4 py-3 rounded-xl bg-white text-black hover:bg-gray-200 transition-colors font-bold shadow-[0_0_20px_rgba(255,255,255,0.3)]"
                  >
                    Deploy
                  </button>
                </div>
              </form>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      <AnimatePresence>
        {isTemplatesModalOpen && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <motion.div 
              initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              className="absolute inset-0 bg-background/80 backdrop-blur-xl"
              onClick={() => setIsTemplatesModalOpen(false)}
            />
            <motion.div
              initial={{ opacity: 0, scale: 0.95, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: 20 }}
              className="glass-card border border-white/10 rounded-3xl p-8 w-full max-w-2xl relative z-10 shadow-2xl"
            >
              <div className="flex justify-between items-center mb-8">
                <h2 className="text-2xl font-display font-bold text-white flex items-center gap-2">
                  <Layers className="text-[#FF8C42]" /> Ready-Made Systems
                </h2>
                <button onClick={() => setIsTemplatesModalOpen(false)} className="text-textMuted hover:text-white p-2 rounded-full hover:bg-white/5 transition-colors">
                  <X size={24} />
                </button>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {templates.map((tpl, i) => (
                  <motion.div
                    key={i}
                    whileHover={{ scale: 1.02 }}
                    className="p-5 rounded-2xl bg-white/5 border border-white/10 hover:border-[#FF6B2C]/50 cursor-pointer transition-all relative overflow-hidden group"
                    onClick={() => applyTemplate(tpl)}
                  >
                    <div className="absolute top-0 right-0 w-24 h-24 rounded-full blur-2xl opacity-10 group-hover:opacity-30 transition-opacity" style={{ backgroundColor: tpl.color }} />
                    <h3 className="text-lg font-bold text-white mb-1">{tpl.name}</h3>
                    <div className="flex items-center gap-2 text-sm text-textMuted">
                      <span className="px-2 py-0.5 rounded-md bg-white/5 uppercase tracking-wide text-[10px]">{tpl.category}</span>
                      <span>• {tpl.goal} Days</span>
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
