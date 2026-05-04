'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Search, Rocket, Sparkles, 
  ArrowRight, Clock, ChevronRight, Zap, Bug,
  TrendingUp, BookOpen, Newspaper, Megaphone, Calendar
} from 'lucide-react';
import Link from 'next/link';
import { articles, updates } from '@/lib/resourcesData';

export default function ProductivityHubPage() {
  const [activeTab, setActiveTab] = useState('articles');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');

  const filterOptions = ['All', 'Planning', 'Deep Work', 'Habits'];

  const filteredArticles = articles.filter(article => {
    const matchesSearch = article.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         article.description.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = selectedCategory === 'All' || article.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  const featuredArticle = articles[0];
  const sideArticles = articles.slice(1, 3); // 2 smaller cards

  return (
    <div className="space-y-12 pb-20 pt-28 max-w-7xl mx-auto px-6 md:px-12">
      {/* 1. HERO SECTION - Minimal */}
      <div className="flex flex-col items-center text-center space-y-4 max-w-3xl mx-auto mb-10">
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42] text-[10px] font-bold uppercase tracking-[0.2em]"
        >
          <Sparkles size={14} /> Knowledge Base
        </motion.div>
        <motion.h1 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="text-4xl md:text-6xl font-display font-bold text-white tracking-tight"
        >
          Productivity Hub
        </motion.h1>
        <motion.p 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="text-text-muted text-lg leading-relaxed max-w-2xl"
        >
          Master your workflow, learn elite performance strategies, and stay synchronized with the latest HabitFlow evolutions.
        </motion.p>
      </div>

      {/* 3. TABS */}
      <div className="flex justify-center mb-12">
        <div className="flex bg-white/5 p-1 rounded-xl border border-white/10 shadow-lg">
          <button 
            onClick={() => setActiveTab('articles')}
            className={`px-8 py-2.5 rounded-lg text-sm font-bold transition-all flex items-center gap-2 ${
              activeTab === 'articles' ? 'bg-gradient-to-r from-[#FF6B2C] to-[#FF8C42] text-white shadow-[0_0_20px_rgba(255,107,44,0.3)]' : 'text-white/50 hover:text-white'
            }`}
          >
            <Newspaper size={16} /> Guides & Articles
          </button>
          <button 
            onClick={() => setActiveTab('updates')}
            className={`px-8 py-2.5 rounded-lg text-sm font-bold transition-all flex items-center gap-2 ${
              activeTab === 'updates' ? 'bg-gradient-to-r from-[#FF6B2C] to-[#FF8C42] text-white shadow-[0_0_20px_rgba(255,107,44,0.3)]' : 'text-white/50 hover:text-white'
            }`}
          >
            <Megaphone size={16} /> System Updates
          </button>
        </div>
      </div>

      <AnimatePresence mode="wait">
        {activeTab === 'articles' ? (
          <motion.div
            key="articles-tab"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="space-y-16"
          >
            {/* 2. FEATURED SECTION - 2 Column */}
            {!searchQuery && selectedCategory === 'All' && featuredArticle && (
              <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
                {/* Left: Featured Article (60% approx -> col-span-3) */}
                <Link href={`/productivity-hub/${featuredArticle.slug}`} className="lg:col-span-3 group relative rounded-[2rem] overflow-hidden border border-white/5 hover:border-[#FF6B2C]/40 transition-all duration-500 block h-[450px]">
                  <img src={featuredArticle.image} alt={featuredArticle.title} className="absolute inset-0 w-full h-full object-cover opacity-60 group-hover:scale-105 group-hover:opacity-80 transition-all duration-700" />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/90 via-black/40 to-transparent" />
                  <div className="absolute inset-x-0 bottom-0 p-8 md:p-10 flex flex-col justify-end h-full">
                    <span className="px-3 py-1 rounded-md bg-[#FF6B2C]/20 border border-[#FF6B2C]/30 text-[#FF8C42] text-[10px] font-black uppercase tracking-widest inline-block w-max mb-4 backdrop-blur-md">Featured</span>
                    <h2 className="text-3xl md:text-4xl font-display font-bold text-white mb-3 group-hover:text-[#FF6B2C] transition-colors leading-snug">{featuredArticle.title}</h2>
                    <p className="text-white/70 line-clamp-2 mb-6 text-sm">{featuredArticle.description}</p>
                    <div className="flex items-center gap-4 text-xs font-bold uppercase tracking-widest text-[#FF8C42]">
                      Read Protocol <ArrowRight size={14} className="group-hover:translate-x-1 transition-transform" />
                    </div>
                  </div>
                </Link>

                {/* Right: Smaller Cards (40% approx -> col-span-2) */}
                {sideArticles.length > 0 && (
                  <div className="lg:col-span-2 flex flex-col gap-6 h-[450px]">
                    {sideArticles.map(article => (
                      <Link key={article.id} href={`/productivity-hub/${article.slug}`} className="group flex-1 rounded-[2rem] glass-card border-white/5 hover:border-[#FF6B2C]/30 transition-all duration-500 overflow-hidden relative flex flex-col justify-end p-6 md:p-8">
                         <img src={article.image} alt={article.title} className="absolute inset-0 w-full h-full object-cover opacity-30 group-hover:opacity-50 group-hover:scale-105 transition-all duration-700" />
                         <div className="absolute inset-0 bg-gradient-to-t from-black/95 via-black/60 to-transparent" />
                         <div className="relative z-10">
                           <span className="text-[10px] font-bold uppercase tracking-widest text-text-muted group-hover:text-[#FF8C42] transition-colors mb-2 block">{article.category}</span>
                           <h3 className="text-xl font-bold text-white leading-snug mb-2 group-hover:text-[#FF6B2C] transition-colors">{article.title}</h3>
                           <div className="flex items-center gap-2 text-[10px] font-bold text-white/40 uppercase tracking-widest mt-4">
                             <Clock size={12} /> {article.readTime}
                           </div>
                         </div>
                      </Link>
                    ))}
                  </div>
                )}
              </div>
            )}

            <div className="space-y-8 pt-8 border-t border-white/5">
              {/* 5. CATEGORY FILTER & SEARCH */}
              <div className="flex flex-col md:flex-row justify-between items-center gap-6">
                <div className="flex items-center gap-2 bg-[#050505]/50 p-1.5 rounded-xl border border-white/5 overflow-x-auto w-full md:w-auto">
                  {filterOptions.map(cat => (
                    <button
                      key={cat}
                      onClick={() => setSelectedCategory(cat)}
                      className={`px-5 py-2 rounded-lg text-xs font-bold transition-all whitespace-nowrap ${
                        selectedCategory === cat 
                          ? 'bg-white/10 text-white shadow-sm' 
                          : 'text-text-muted hover:text-white hover:bg-white/5'
                      }`}
                    >
                      {cat}
                    </button>
                  ))}
                </div>

                <div className="relative w-full md:w-72 group">
                  <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-white/30 group-focus-within:text-[#FF6B2C] transition-colors" size={16} />
                  <input 
                    type="text" 
                    placeholder="Search protocols..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="w-full bg-[#050505]/50 border border-white/10 rounded-xl py-2.5 pl-11 pr-4 text-sm text-white focus:outline-none focus:border-[#FF6B2C]/50 transition-all placeholder:text-white/30"
                  />
                </div>
              </div>

              {/* 4. GRID */}
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                {filteredArticles.map((article, i) => (
                  <ArticleCard key={article.id} article={article} index={i} />
                ))}
              </div>

              {filteredArticles.length === 0 && (
                <div className="py-24 text-center space-y-4 glass-card rounded-[2rem] border-white/5">
                  <div className="w-16 h-16 rounded-full bg-white/5 flex items-center justify-center mx-auto text-white/20">
                    <Search size={24} />
                  </div>
                  <h3 className="text-lg font-bold text-white">No protocols found</h3>
                  <p className="text-text-muted text-sm">Adjust your search parameters to locate specific knowledge nodes.</p>
                </div>
              )}
            </div>
          </motion.div>
        ) : (
          <motion.div
            key="updates-tab"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="max-w-4xl mx-auto space-y-8"
          >
            <div className="space-y-8 relative">
              <div className="absolute left-[27px] top-4 bottom-4 w-px bg-white/5" />
              {updates.map((update, i) => (
                <UpdateCard key={update.id} update={update} index={i} />
              ))}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

function ArticleCard({ article, index }) {
  return (
    <Link href={`/productivity-hub/article?slug=${article.slug}`}>
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: index * 0.1 }}
        className="group flex flex-col glass-card rounded-[2rem] border-white/5 overflow-hidden hover:border-[#FF6B2C]/30 hover:shadow-[0_10px_30px_rgba(255,107,44,0.05)] transition-all duration-500 h-full"
      >
        <div className="relative h-48 overflow-hidden">
          <img 
            src={article.image} 
            alt={article.title} 
            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700 opacity-70 group-hover:opacity-100"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#050505] to-transparent opacity-60" />
        </div>
        
        <div className="p-6 flex flex-col flex-1">
          <div className="flex items-center justify-between mb-3">
            <span className="text-[9px] font-bold uppercase tracking-widest text-[#FF8C42] bg-[#FF6B2C]/10 px-2 py-1 rounded">
              {article.category}
            </span>
            <span className="text-[10px] text-text-muted font-medium flex items-center gap-1.5">
              <Clock size={12} /> {article.readTime}
            </span>
          </div>
          <h3 className="text-lg font-bold text-white group-hover:text-[#FF6B2C] transition-colors leading-snug mb-3">
            {article.title}
          </h3>
          <p className="text-text-muted text-xs line-clamp-2 mb-6 flex-1">
            {article.description}
          </p>
          <div className="mt-auto text-[10px] font-black uppercase tracking-widest text-white/50 group-hover:text-[#FF8C42] transition-colors flex items-center gap-2">
            Read Guide <ChevronRight size={14} className="group-hover:translate-x-1 transition-transform" />
          </div>
        </div>
      </motion.div>
    </Link>
  );
}

function UpdateCard({ update, index }) {
  const typeStyles = {
    feature: { icon: Zap, color: '#3B82F6', bg: 'bg-blue-500/10', border: 'border-blue-500/20' },
    improvement: { icon: TrendingUp, color: '#FF6B2C', bg: 'bg-[#FF6B2C]/10', border: 'border-[#FF6B2C]/20' },
    fix: { icon: Bug, color: '#10B981', bg: 'bg-emerald-500/10', border: 'border-emerald-500/20' }
  };

  const style = typeStyles[update.type] || typeStyles.improvement;
  const Icon = style.icon;

  return (
    <motion.div
      initial={{ opacity: 0, x: -20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ delay: index * 0.1 }}
      className="relative pl-16 group"
    >
      <div className={`absolute left-0 top-0 w-14 h-14 rounded-2xl ${style.bg} ${style.border} border flex items-center justify-center transition-all duration-500 z-10 group-hover:scale-110 shadow-lg`} style={{ color: style.color }}>
        <Icon size={20} />
      </div>

      <div className="glass-card p-6 md:p-8 rounded-[2rem] border-white/5 hover:border-white/10 transition-all duration-500 relative overflow-hidden bg-[#0A0A0A]/50 hover:bg-[#0A0A0A]/80">
        <div className="absolute top-0 right-0 p-8 opacity-[0.02] group-hover:opacity-[0.04] transition-all duration-700">
          <Icon size={100} />
        </div>
        
        <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-4 mb-5 relative z-10">
          <div className="space-y-1">
            <div className="flex items-center gap-3">
              <h3 className="text-xl font-bold text-white group-hover:text-[#FF6B2C] transition-colors">{update.title}</h3>
              <span className={`px-2 py-0.5 rounded text-[8px] font-black uppercase tracking-widest ${style.bg} border ${style.border}`} style={{ color: style.color }}>
                {update.type}
              </span>
            </div>
            <p className="text-xs text-text-muted font-medium flex items-center gap-2">
              <Calendar size={12} className="opacity-50" /> {update.createdAt}
            </p>
          </div>
          <div className="flex items-center gap-2 px-3 py-1.5 rounded-lg bg-white/5 border border-white/5 text-[10px] font-bold uppercase tracking-widest text-white/40">
            Version {1.4 + index * 0.1}
          </div>
        </div>
        
        <p className="text-white/70 text-sm leading-relaxed max-w-2xl relative z-10">
          {update.description}
        </p>
      </div>
    </motion.div>
  );
}
