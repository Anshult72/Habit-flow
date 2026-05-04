'use client';

import { useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Heart, ShoppingBag, Plus, Search, Filter, 
  Trash2, ExternalLink, TrendingUp, Target, 
  Calendar, Clock, IndianRupee, Zap, Sparkles,
  ChevronRight, X, Camera, Link as LinkIcon,
  Tag, Info, CheckCircle2, Gift, Rocket,
  Monitor, Car, Bike, Book, GraduationCap,
  Gamepad2, Dumbbell, Sofa, MoreHorizontal,
  ArrowUpRight, AlertCircle, PieChart
} from 'lucide-react';
import useStore from '@/store/useStore';
import { format, differenceInMonths } from 'date-fns';

export default function WishlistSection() {
  const { wishlist, addWishlistItem, updateWishlistItem, deleteWishlistItem, updateSavings } = useStore();
  const [searchQuery, setSearchQuery] = useState('');
  const [activeCategory, setActiveCategory] = useState('All');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSavingsModalOpen, setIsSavingsModalOpen] = useState(false);
  const [selectedItem, setSelectedItem] = useState(null);
  const [savingsAmount, setSavingsAmount] = useState('');

  const categories = ['All', 'Tech', 'Gaming', 'Fitness', 'Vehicle', 'Education', 'Lifestyle', 'Dream Setup'];

  const filteredItems = useMemo(() => {
    return (wishlist || []).filter(item => {
      const matchesSearch = item.title.toLowerCase().includes(searchQuery.toLowerCase());
      const matchesCategory = activeCategory === 'All' || item.category === activeCategory;
      return matchesSearch && matchesCategory;
    });
  }, [wishlist, searchQuery, activeCategory]);

  const totalTarget = (wishlist || []).reduce((acc, curr) => acc + (Number(curr.targetPrice) || 0), 0);
  const totalSaved = (wishlist || []).reduce((acc, curr) => acc + (Number(curr.currentSavings) || 0), 0);
  const overallProgress = totalTarget > 0 ? (totalSaved / totalTarget) * 100 : 0;

  return (
    <div className="min-h-screen text-white pt-6 pb-24 px-4 md:px-10 overflow-x-hidden">
      {/* Background Ambience */}
      <div className="fixed inset-0 pointer-events-none z-0">
        <div className="absolute top-[20%] right-[-10%] w-[50%] h-[50%] bg-[#FF6B2C]/5 rounded-full blur-[120px] animate-pulse" />
        <div className="absolute bottom-[-10%] left-[-5%] w-[40%] h-[40%] bg-[#E85D04]/3 rounded-full blur-[100px]" />
      </div>

      <div className="max-w-[1400px] mx-auto space-y-12 relative z-10">
        
        {/* Header Section */}
        <div className="flex flex-col xl:flex-row justify-between items-start xl:items-center gap-8">
          <div className="space-y-2">
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              className="flex items-center gap-4"
            >
              <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-[#FF6B2C] to-[#E85D04] flex items-center justify-center shadow-[0_0_30px_rgba(255,107,44,0.4)]">
                <Gift className="text-white" size={28} />
              </div>
              <div>
                <h1 className="text-4xl md:text-5xl font-display font-black tracking-tight text-white">Life Vault</h1>
                <p className="text-textMuted uppercase tracking-[0.3em] text-[10px] font-bold">Acquisition Protocol v1.0</p>
              </div>
            </motion.div>
          </div>

          <div className="flex flex-wrap items-center gap-6 w-full xl:w-auto">
            <div className="flex items-center gap-6 bg-white/5 border border-white/10 p-4 rounded-3xl backdrop-blur-xl">
              <div className="space-y-1">
                <p className="text-[10px] text-textMuted uppercase font-black tracking-widest">Total Valuation</p>
                <div className="flex items-center gap-2">
                  <IndianRupee size={16} className="text-[#FF8C42]" />
                  <span className="text-xl font-display font-bold text-white">{totalTarget.toLocaleString()}</span>
                </div>
              </div>
              <div className="w-px h-10 bg-white/10" />
              <div className="space-y-1">
                <p className="text-[10px] text-textMuted uppercase font-black tracking-widest">Sync Progress</p>
                <div className="flex items-center gap-3">
                  <span className="text-xl font-display font-bold text-[#FF6B2C]">{Math.round(overallProgress)}%</span>
                  <div className="w-24 h-1.5 bg-white/5 rounded-full overflow-hidden border border-white/5">
                    <motion.div 
                      initial={{ width: 0 }}
                      animate={{ width: `${overallProgress}%` }}
                      className="h-full bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] shadow-[0_0_10px_rgba(255,107,44,0.4)]"
                    />
                  </div>
                </div>
              </div>
            </div>

            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              onClick={() => setIsModalOpen(true)}
              className="px-8 py-4 rounded-2xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white font-bold shadow-[0_10px_30px_rgba(255,107,44,0.3)] hover:shadow-[0_15px_40px_rgba(255,107,44,0.5)] transition-all flex items-center gap-3 group"
            >
              <Plus size={20} className="group-hover:rotate-90 transition-transform duration-300" />
              Add Life Goal
            </motion.button>
          </div>
        </div>

        {/* Filters & Search */}
        <div className="flex flex-col md:flex-row items-center justify-between gap-6 pb-8 border-b border-white/5">
          <div className="flex items-center gap-2 overflow-x-auto no-scrollbar pb-2 md:pb-0 w-full md:w-auto">
            {categories.map(cat => (
              <button
                key={cat}
                onClick={() => setActiveCategory(cat)}
                className={`px-6 py-3 rounded-xl text-xs font-bold whitespace-nowrap transition-all border ${
                  activeCategory === cat 
                    ? 'bg-[#FF6B2C] border-[#FF6B2C] text-white shadow-[0_0_20px_rgba(255,107,44,0.3)]' 
                    : 'bg-white/5 border-white/10 text-white/40 hover:text-white/60 hover:border-white/20'
                }`}
              >
                {cat}
              </button>
            ))}
          </div>

          <div className="relative w-full md:w-80 group">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20 group-focus-within:text-[#FF6B2C] transition-colors" size={18} />
            <input 
              type="text" 
              placeholder="Locate target..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full bg-white/5 border border-white/10 rounded-2xl py-4 pl-12 pr-6 text-sm focus:outline-none focus:border-[#FF6B2C]/50 transition-all placeholder:text-white/20 text-white"
            />
          </div>
        </div>

        {/* Wishlist Grid */}
        <AnimatePresence mode="popLayout">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8">
            {filteredItems.map((item, i) => (
              <WishlistCard 
                key={item.id} 
                item={item} 
                index={i}
                onUpdateSavings={() => { setSelectedItem(item); setIsSavingsModalOpen(true); }}
                onDelete={() => deleteWishlistItem(item.id)}
              />
            ))}

            {filteredItems.length === 0 && (
              <motion.div 
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="col-span-full py-32 flex flex-col items-center justify-center text-center space-y-6"
              >
                <div className="relative">
                  <motion.div 
                    animate={{ scale: [1, 1.2, 1], opacity: [0.3, 0.6, 0.3] }}
                    transition={{ duration: 4, repeat: Infinity }}
                    className="absolute inset-0 bg-[#FF6B2C] rounded-full blur-[40px]"
                  />
                  <div className="relative w-32 h-32 rounded-full border-2 border-dashed border-white/20 flex items-center justify-center">
                    <Rocket size={48} className="text-white/20" />
                  </div>
                </div>
                <div className="space-y-2">
                  <h3 className="text-3xl font-display font-bold text-white tracking-tight">No Life Goals Initialized.</h3>
                  <p className="text-textMuted max-w-sm mx-auto text-lg font-light leading-relaxed">Your future is a blank canvas. Add your dream items and life goals to start the sync protocol.</p>
                </div>
                <motion.button
                  whileHover={{ scale: 1.05 }}
                  onClick={() => setIsModalOpen(true)}
                  className="px-8 py-3 rounded-full border border-[#FF6B2C]/30 text-[#FF8C42] font-bold uppercase tracking-widest text-xs hover:bg-[#FF6B2C]/5 transition-all"
                >
                  Create First Target
                </motion.button>
              </motion.div>
            )}
          </div>
        </AnimatePresence>
      </div>

      {/* Modals */}
      <AnimatePresence>
        {isModalOpen && (
          <AddGoalModal 
            onClose={() => setIsModalOpen(false)}
            onSave={(item) => {
              addWishlistItem(item);
              setIsModalOpen(false);
            }}
          />
        )}
        {isSavingsModalOpen && selectedItem && (
          <UpdateSavingsModal 
            item={selectedItem}
            onClose={() => { setIsSavingsModalOpen(false); setSelectedItem(null); setSavingsAmount(''); }}
            onSave={(amount) => {
              updateSavings(selectedItem.id, Number(amount));
              setIsSavingsModalOpen(false);
              setSelectedItem(null);
              setSavingsAmount('');
            }}
          />
        )}
      </AnimatePresence>
    </div>
  );
}

function WishlistCard({ item, index, onUpdateSavings, onDelete }) {
  const progress = (Number(item.currentSavings) / Number(item.targetPrice)) * 100;
  const isAcquired = item.status === 'Acquired';

  const categoryIcons = {
    Tech: Monitor,
    Gaming: Gamepad2,
    Fitness: Dumbbell,
    Vehicle: Car,
    Education: GraduationCap,
    Lifestyle: ShoppingBag,
    'Dream Setup': Sofa,
  };

  const Icon = categoryIcons[item.category] || Target;

  return (
    <motion.div
      layout
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, scale: 0.9 }}
      transition={{ delay: index * 0.05 }}
      whileHover={{ y: -5 }}
      className={`group relative flex flex-col glass-card rounded-[2.5rem] border-white/5 overflow-hidden transition-all duration-500 ${
        isAcquired ? 'border-success/30 shadow-[0_0_40px_rgba(34,197,94,0.1)]' : 'hover:border-[#FF6B2C]/30'
      }`}
    >
      {/* Image Container */}
      <div className="relative h-56 overflow-hidden">
        {item.image ? (
          <img src={item.image} alt={item.title} className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700" />
        ) : (
          <div className="w-full h-full bg-white/5 flex items-center justify-center text-white/10 group-hover:text-[#FF6B2C]/20 transition-colors">
            <Icon size={80} strokeWidth={1} />
          </div>
        )}
        
        <div className="absolute inset-0 bg-gradient-to-t from-black via-black/20 to-transparent" />
        
        <div className="absolute top-4 left-4 z-10 px-3 py-1 rounded-full bg-black/60 border border-white/10 backdrop-blur-md text-[9px] font-black uppercase tracking-widest text-white/60">
          {item.category}
        </div>

        {isAcquired && (
          <div className="absolute top-4 right-4 z-10 p-2 rounded-full bg-success text-white shadow-[0_0_20px_rgba(34,197,94,0.5)]">
            <CheckCircle2 size={16} />
          </div>
        )}
      </div>

      <div className="p-7 space-y-6 flex-1 flex flex-col relative z-10">
        <div className="space-y-1">
          <h3 className="text-xl font-display font-bold text-white group-hover:text-[#FF6B2C] transition-colors line-clamp-1">{item.title}</h3>
          <div className="flex items-center gap-1.5 text-[#FF8C42] font-black text-sm">
            <IndianRupee size={14} />
            {Number(item.targetPrice).toLocaleString()}
          </div>
        </div>

        <div className="space-y-3 flex-1">
          <div className="flex justify-between items-end">
            <span className="text-[10px] text-textMuted font-black uppercase tracking-widest">Vault Status</span>
            <span className={`text-sm font-bold ${isAcquired ? 'text-success' : 'text-[#FF8C42]'}`}>{Math.round(progress)}%</span>
          </div>
          <div className="h-2.5 bg-white/5 rounded-full overflow-hidden border border-white/5 p-0.5">
            <motion.div 
              initial={{ width: 0 }}
              animate={{ width: `${progress}%` }}
              className={`h-full rounded-full ${
                isAcquired 
                  ? 'bg-gradient-to-r from-success to-emerald-400 shadow-[0_0_15px_rgba(34,197,94,0.4)]' 
                  : 'bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] shadow-[0_0_15px_rgba(255,107,44,0.4)]'
              }`}
            />
          </div>
          <div className="flex justify-between text-[10px] font-bold text-textMuted uppercase tracking-tighter">
            <span>Saved: {Number(item.currentSavings).toLocaleString()}</span>
            <span>Rem: {(Number(item.targetPrice) - Number(item.currentSavings)).toLocaleString()}</span>
          </div>
        </div>

        {item.deadline && (
          <div className="flex items-center gap-2 px-3 py-2 rounded-xl bg-white/5 border border-white/5 text-[10px] text-textMuted font-bold uppercase tracking-widest">
            <Clock size={12} className="text-[#FFB347]" />
            Target: {format(new Date(item.deadline), 'MMM dd, yyyy')}
          </div>
        )}

        <div className="flex items-center justify-between pt-4 border-t border-white/5">
          <div className="flex items-center gap-2">
            <button 
              onClick={onDelete}
              className="p-2.5 rounded-xl bg-white/5 text-white/20 hover:text-red-500 hover:bg-red-500/10 transition-all"
            >
              <Trash2 size={16} />
            </button>
            {item.link && (
              <a 
                href={item.link} 
                target="_blank" 
                rel="noopener noreferrer"
                className="p-2.5 rounded-xl bg-white/5 text-white/20 hover:text-[#3B82F6] hover:bg-[#3B82F6]/10 transition-all"
              >
                <LinkIcon size={16} />
              </a>
            )}
          </div>
          
          <motion.button 
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            onClick={onUpdateSavings}
            disabled={isAcquired}
            className={`px-5 py-2.5 rounded-2xl text-[10px] font-black uppercase tracking-[0.2em] transition-all flex items-center gap-2 ${
              isAcquired 
                ? 'bg-success/20 text-success cursor-default' 
                : 'bg-[#FF6B2C]/10 border border-[#FF6B2C]/30 text-[#FF8C42] hover:bg-[#FF6B2C] hover:text-white'
            }`}
          >
            {isAcquired ? 'Acquired' : 'Sync Savings'}
            {!isAcquired && <ChevronRight size={14} />}
          </motion.button>
        </div>
      </div>
    </motion.div>
  );
}

function AddGoalModal({ onClose, onSave }) {
  const [formData, setFormData] = useState({
    title: '',
    targetPrice: '',
    currentSavings: '0',
    category: 'Tech',
    link: '',
    image: '',
    deadline: '',
    notes: ''
  });
  const [isImporting, setIsImporting] = useState(false);

  const handleImport = () => {
    if (!formData.link) return;
    setIsImporting(true);
    // Simulate smart import
    setTimeout(() => {
      setFormData(prev => ({
        ...prev,
        title: 'Premium Mechanical Keyboard K2',
        targetPrice: '12999',
        image: 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?auto=format&fit=crop&q=80&w=800',
        category: 'Tech'
      }));
      setIsImporting(false);
    }, 1500);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    onSave(formData);
  };

  return (
    <div className="fixed inset-0 z-[1000] flex items-center justify-center p-4 bg-black/90 backdrop-blur-2xl">
      <motion.div
        initial={{ opacity: 0, scale: 0.95, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        className="relative w-full max-w-4xl glass-card rounded-[3rem] border border-white/10 shadow-[0_0_100px_rgba(255,107,44,0.15)] overflow-hidden"
      >
        <div className="p-12 space-y-10 max-h-[90vh] overflow-y-auto custom-scrollbar">
          <div className="flex justify-between items-start">
            <div className="space-y-2">
              <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-[#FF6B2C] to-[#E85D04] flex items-center justify-center shadow-[0_0_20px_rgba(255,107,44,0.4)]">
                <Target className="text-white" size={32} />
              </div>
              <h2 className="text-4xl font-display font-black text-white">Initialize Target</h2>
              <p className="text-textMuted uppercase tracking-[0.2em] text-xs font-bold">Configuring new life acquisition protocol</p>
            </div>
            <button onClick={onClose} className="p-4 rounded-full border border-white/10 text-white/20 hover:text-white transition-all">
              <X size={24} />
            </button>
          </div>

          <form onSubmit={handleSubmit} className="space-y-10">
            {/* Smart Import */}
            <div className="space-y-4">
              <label className="text-[10px] uppercase tracking-widest font-black text-[#FF8C42] ml-2">Smart Import (URL)</label>
              <div className="flex gap-4">
                <div className="relative flex-1 group">
                  <LinkIcon className="absolute left-5 top-1/2 -translate-y-1/2 text-white/20 group-focus-within:text-[#FF6B2C] transition-colors" size={20} />
                  <input
                    type="url"
                    placeholder="Paste Amazon, Apple, or Flipkart link..."
                    className="w-full bg-white/5 border border-white/10 rounded-2xl py-5 pl-14 pr-6 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-all font-medium"
                    value={formData.link}
                    onChange={(e) => setFormData({ ...formData, link: e.target.value })}
                  />
                </div>
                <button
                  type="button"
                  onClick={handleImport}
                  disabled={!formData.link || isImporting}
                  className="px-8 py-5 rounded-2xl bg-[#FF6B2C]/10 border border-[#FF6B2C]/30 text-[#FF8C42] font-black uppercase tracking-widest text-xs hover:bg-[#FF6B2C] hover:text-white transition-all disabled:opacity-50 flex items-center gap-3"
                >
                  {isImporting ? <motion.div animate={{ rotate: 360 }} transition={{ repeat: Infinity, duration: 1 }}><Sparkles size={18} /></motion.div> : <Zap size={18} />}
                  Auto-Sync
                </button>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-10">
              <div className="space-y-8">
                <div className="space-y-2">
                  <label className="text-[10px] uppercase tracking-widest font-black text-white/20 ml-2">Target Title</label>
                  <input
                    required
                    type="text"
                    placeholder="e.g., MacBook Pro M3 Max"
                    className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-all font-bold text-lg"
                    value={formData.title}
                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  />
                </div>
                <div className="grid grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <label className="text-[10px] uppercase tracking-widest font-black text-white/20 ml-2">Target Price (₹)</label>
                    <input
                      required
                      type="number"
                      placeholder="0.00"
                      className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-all font-bold"
                      value={formData.targetPrice}
                      onChange={(e) => setFormData({ ...formData, targetPrice: e.target.value })}
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] uppercase tracking-widest font-black text-white/20 ml-2">Initial Sync (₹)</label>
                    <input
                      type="number"
                      placeholder="0.00"
                      className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-all font-bold"
                      value={formData.currentSavings}
                      onChange={(e) => setFormData({ ...formData, currentSavings: e.target.value })}
                    />
                  </div>
                </div>
              </div>

              <div className="space-y-8">
                <div className="space-y-2">
                  <label className="text-[10px] uppercase tracking-widest font-black text-white/20 ml-2">Category Sector</label>
                  <div className="grid grid-cols-3 gap-3">
                    {['Tech', 'Gaming', 'Fitness', 'Vehicle', 'Education', 'Lifestyle', 'Dream Setup'].map(cat => (
                      <button
                        key={cat}
                        type="button"
                        onClick={() => setFormData({ ...formData, category: cat })}
                        className={`py-3 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all border ${
                          formData.category === cat 
                            ? 'bg-[#FF6B2C]/10 border-[#FF6B2C]/50 text-[#FF8C42]' 
                            : 'bg-white/5 border-white/10 text-white/20 hover:text-white/40'
                        }`}
                      >
                        {cat}
                      </button>
                    ))}
                  </div>
                </div>
                <div className="space-y-2">
                  <label className="text-[10px] uppercase tracking-widest font-black text-white/20 ml-2">Deadline Protocol</label>
                  <input
                    type="date"
                    className="w-full bg-white/5 border border-white/10 rounded-2xl px-6 py-4 text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-all [color-scheme:dark]"
                    value={formData.deadline}
                    onChange={(e) => setFormData({ ...formData, deadline: e.target.value })}
                  />
                </div>
              </div>
            </div>

            <div className="pt-10 flex gap-6">
              <button
                type="button"
                onClick={onClose}
                className="flex-1 py-6 rounded-3xl border border-white/10 text-white font-bold hover:bg-white/5 transition-all uppercase tracking-widest text-xs"
              >
                Abort Protocol
              </button>
              <button
                type="submit"
                className="flex-[2] py-6 rounded-3xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white font-black uppercase tracking-[0.3em] text-sm shadow-[0_15px_50px_rgba(255,107,44,0.3)] hover:shadow-[0_20px_70px_rgba(255,107,44,0.5)] transition-all flex items-center justify-center gap-4"
              >
                <Rocket size={24} /> Deploy Target
              </button>
            </div>
          </form>
        </div>
      </motion.div>
    </div>
  );
}

function UpdateSavingsModal({ item, onClose, onSave }) {
  const [amount, setAmount] = useState('');

  return (
    <div className="fixed inset-0 z-[1000] flex items-center justify-center p-4 bg-black/95 backdrop-blur-3xl">
      <motion.div
        initial={{ opacity: 0, scale: 0.9, y: 30 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        className="w-full max-w-lg glass-card p-12 rounded-[3rem] border border-white/10 space-y-10 text-center"
      >
        <div className="space-y-4">
          <div className="w-20 h-20 rounded-3xl bg-[#FF6B2C]/10 flex items-center justify-center text-[#FF8C42] mx-auto shadow-[0_0_20px_rgba(255,107,44,0.1)]">
            <IndianRupee size={40} />
          </div>
          <h2 className="text-3xl font-display font-black text-white">Sync Savings</h2>
          <p className="text-textMuted uppercase tracking-[0.2em] text-[10px] font-bold">Injecting capital into target: {item.title}</p>
        </div>

        <div className="space-y-6">
          <div className="relative group">
            <IndianRupee className="absolute left-6 top-1/2 -translate-y-1/2 text-[#FF6B2C]" size={28} />
            <input
              autoFocus
              type="number"
              placeholder="0.00"
              className="w-full bg-white/5 border border-white/10 rounded-3xl py-8 pl-16 pr-8 text-4xl font-display font-black text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-all placeholder:text-white/5"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
            />
          </div>
          
          <div className="flex justify-between text-xs font-bold text-textMuted uppercase tracking-widest px-2">
            <span>Current: ₹{Number(item.currentSavings).toLocaleString()}</span>
            <span>Target: ₹{Number(item.targetPrice).toLocaleString()}</span>
          </div>
        </div>

        <div className="flex gap-4">
          <button
            onClick={onClose}
            className="flex-1 py-5 rounded-2xl border border-white/10 text-white font-bold hover:bg-white/5 transition-all uppercase tracking-widest text-xs"
          >
            Cancel
          </button>
          <button
            onClick={() => onSave(amount)}
            disabled={!amount || Number(amount) <= 0}
            className="flex-[2] py-5 rounded-2xl bg-[#FF6B2C] text-white font-black uppercase tracking-[0.2em] text-xs shadow-[0_10px_30px_rgba(255,107,44,0.3)] hover:shadow-[0_15px_40px_rgba(255,107,44,0.5)] transition-all disabled:opacity-30 disabled:grayscale"
          >
            Initialize Sync
          </button>
        </div>
      </motion.div>
    </div>
  );
}
