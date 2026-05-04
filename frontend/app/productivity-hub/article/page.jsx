'use client';

import { Suspense } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { 
  ArrowLeft, Clock, Calendar, 
  Share2, Bookmark, Heart,
  ChevronRight, Sparkles, User,
  MessageSquare
} from 'lucide-react';
import Link from 'next/link';
import { articles } from '@/lib/resourcesData';

function ArticleDetailContent() {
  const searchParams = useSearchParams();
  const slug = searchParams.get('slug');
  const router = useRouter();
  
  const article = articles.find(a => a.slug === slug);

  if (!article) {
    return (
      <div className="min-h-[60vh] flex flex-col items-center justify-center space-y-6">
        <div className="w-20 h-20 rounded-full bg-white/5 flex items-center justify-center text-white/10">
          <Sparkles size={40} />
        </div>
        <h1 className="text-3xl font-display font-black text-white">Transmission Lost</h1>
        <p className="text-text-muted">The requested article node could not be located in the archives.</p>
        <button 
          onClick={() => router.push('/productivity-hub')}
          className="px-8 py-4 rounded-2xl bg-[#FF6B2C] text-white font-bold hover:shadow-[0_0_30px_rgba(255,107,44,0.4)] transition-all"
        >
          Return to Hub
        </button>
      </div>
    );
  }

  const relatedArticles = articles.filter(a => a.id !== article.id).slice(0, 2);

  return (
    <div className="max-w-5xl mx-auto space-y-12 pb-24">
      {/* Back Button */}
      <motion.button
        initial={{ opacity: 0, x: -20 }}
        animate={{ opacity: 1, x: 0 }}
        onClick={() => router.back()}
        className="group flex items-center gap-3 text-white/40 hover:text-white transition-all text-xs font-black uppercase tracking-[0.3em]"
      >
        <ArrowLeft size={16} className="group-hover:-translate-x-1 transition-transform" /> Back to Knowledge Hub
      </motion.button>

      {/* Hero Section */}
      <div className="space-y-8">
        <div className="space-y-4 text-center md:text-left">
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="px-4 py-1.5 rounded-full bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42] text-[10px] font-black uppercase tracking-widest inline-block"
          >
            {article.category}
          </motion.div>
          <motion.h1 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="text-4xl md:text-6xl font-display font-black text-white leading-[1.1] tracking-tight"
          >
            {article.title}
          </motion.h1>
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="flex flex-wrap items-center justify-center md:justify-start gap-6 text-text-muted text-xs font-bold uppercase tracking-widest"
          >
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-full bg-white/5 border border-white/10 flex items-center justify-center overflow-hidden">
                <User size={14} className="text-white/40" />
              </div>
              <span>By HabitFlow Editorial</span>
            </div>
            <div className="flex items-center gap-2">
              <Calendar size={14} className="text-[#FF6B2C]" />
              <span>{article.createdAt}</span>
            </div>
            <div className="flex items-center gap-2">
              <Clock size={14} className="text-[#FF6B2C]" />
              <span>{article.readTime} Read</span>
            </div>
          </motion.div>
        </div>

        <motion.div 
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.3, duration: 0.8 }}
          className="relative aspect-video rounded-[3rem] overflow-hidden border border-white/10 shadow-[0_0_100px_rgba(255,107,44,0.1)]"
        >
          <img 
            src={article.image} 
            alt={article.title} 
            className="w-full h-full object-cover opacity-90"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
        </motion.div>
      </div>

      {/* Content Area */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-16">
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className="lg:col-span-8 prose prose-invert prose-orange max-w-none 
            prose-h2:font-display prose-h2:font-black prose-h2:text-3xl prose-h2:tracking-tight prose-h2:mt-12 prose-h2:mb-6
            prose-p:text-text-muted prose-p:text-lg prose-p:leading-relaxed prose-p:mb-6
            prose-ul:text-text-muted prose-ul:text-lg prose-ul:space-y-4
            prose-ol:text-text-muted prose-ol:text-lg prose-ol:space-y-4
            prose-strong:text-white prose-strong:font-bold
          "
          dangerouslySetInnerHTML={{ __html: article.content }}
        />

        {/* Sidebar Controls */}
        <motion.div 
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.5 }}
          className="lg:col-span-4 space-y-10"
        >
          {/* Action Cards */}
          <div className="glass-card p-8 rounded-[2.5rem] border-white/5 space-y-6">
            <h3 className="text-[10px] font-black uppercase tracking-[0.3em] text-[#FF8C42]">Interactions</h3>
            <div className="grid grid-cols-2 gap-4">
              <button className="flex flex-col items-center justify-center p-4 rounded-2xl bg-white/5 border border-white/5 hover:border-[#FF6B2C]/50 transition-all gap-2 group">
                <Heart size={20} className="text-white/40 group-hover:text-red-500 transition-colors" />
                <span className="text-[10px] font-bold text-white/40">Like</span>
              </button>
              <button className="flex flex-col items-center justify-center p-4 rounded-2xl bg-white/5 border border-white/5 hover:border-[#FF6B2C]/50 transition-all gap-2 group">
                <Bookmark size={20} className="text-white/40 group-hover:text-[#FF6B2C] transition-colors" />
                <span className="text-[10px] font-bold text-white/40">Save</span>
              </button>
              <button className="flex flex-col items-center justify-center p-4 rounded-2xl bg-white/5 border border-white/5 hover:border-[#FF6B2C]/50 transition-all gap-2 group">
                <Share2 size={20} className="text-white/40 group-hover:text-blue-500 transition-colors" />
                <span className="text-[10px] font-bold text-white/40">Share</span>
              </button>
              <button className="flex flex-col items-center justify-center p-4 rounded-2xl bg-white/5 border border-white/5 hover:border-[#FF6B2C]/50 transition-all gap-2 group">
                <MessageSquare size={20} className="text-white/40 group-hover:text-[#FF6B2C] transition-colors" />
                <span className="text-[10px] font-bold text-white/40">Comment</span>
              </button>
            </div>
          </div>

          {/* Related Articles */}
          <div className="space-y-6">
            <h3 className="text-[10px] font-black uppercase tracking-[0.3em] text-[#FF8C42] ml-4">Continue Protocol</h3>
            <div className="space-y-4">
              {relatedArticles.map((ra, i) => (
                <Link key={ra.id} href={`/productivity-hub/article?slug=${ra.slug}`}>
                  <div className="group flex gap-4 p-4 rounded-3xl bg-white/5 border border-white/5 hover:border-[#FF6B2C]/30 transition-all cursor-pointer">
                    <div className="w-20 h-20 rounded-2xl overflow-hidden flex-shrink-0">
                      <img src={ra.image} alt={ra.title} className="w-full h-full object-cover opacity-60 group-hover:opacity-100 transition-opacity" />
                    </div>
                    <div className="flex flex-col justify-center">
                      <h4 className="text-sm font-bold text-white group-hover:text-[#FF6B2C] transition-colors line-clamp-2 leading-snug">{ra.title}</h4>
                      <span className="text-[10px] text-text-muted mt-1 uppercase font-bold tracking-widest">{ra.category}</span>
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}

export default function ArticleDetail() {
  return (
    <Suspense fallback={
      <div className="min-h-[60vh] flex flex-col items-center justify-center space-y-6">
        <div className="w-20 h-20 rounded-full bg-white/5 flex items-center justify-center text-white/10 animate-pulse">
          <Sparkles size={40} />
        </div>
        <h1 className="text-3xl font-display font-black text-white">Loading Transmission...</h1>
      </div>
    }>
      <ArticleDetailContent />
    </Suspense>
  );
}
