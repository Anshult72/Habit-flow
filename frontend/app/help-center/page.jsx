'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useRouter } from 'next/navigation';
import {
  Search, BookOpen, Lightbulb, HelpCircle, Palette, Sparkles,
  ArrowLeft, ChevronRight, Command, Rocket, Target, BarChart3,
  Bell, Shield, Users, Layers, RefreshCw, Zap, ListChecks,
  Calendar, LayoutGrid, Timer, Repeat, StickyNote, Keyboard,
  Monitor, ArrowRight, MessageCircle, Headphones, FileText
} from 'lucide-react';

const categories = [
  {
    id: 'beginners',
    icon: Rocket,
    title: "Beginner's Guide",
    description: 'Everything you need to get started with HabitFlow and build your first tracking system.',
    color: '#FF6B2C',
    articles: [
      { title: 'Getting started with HabitFlow', icon: Rocket },
      { title: 'Creating your first habit', icon: Target },
      { title: 'Understanding the tracking dashboard', icon: BarChart3 },
      { title: 'Setting up daily reminders', icon: Bell },
      { title: 'Your first weekly review', icon: RefreshCw },
    ],
  },
  {
    id: 'best-practices',
    icon: Lightbulb,
    title: 'Best Practices',
    description: 'Proven strategies and methodologies to maximize your consistency and productivity.',
    color: '#FF8C42',
    articles: [
      { title: 'Building unbreakable consistency', icon: Shield },
      { title: 'The habit stacking method', icon: Layers },
      { title: 'Productivity systems that work', icon: Zap },
      { title: 'Focus techniques for deep work', icon: Target },
      { title: 'Designing your ideal morning routine', icon: Sparkles },
    ],
  },
  {
    id: 'faq',
    icon: HelpCircle,
    title: 'FAQ',
    description: 'Quick answers to the most commonly asked questions about the platform.',
    color: '#FFB347',
    articles: [
      { title: 'How does syncing work across devices?', icon: RefreshCw },
      { title: 'What is included in the Premium plan?', icon: Sparkles },
      { title: 'How are streaks calculated?', icon: Zap },
      { title: 'Can I export my tracking data?', icon: BarChart3 },
      { title: 'How to reset or delete a habit?', icon: Target },
    ],
  },
  {
    id: 'design-principles',
    icon: Palette,
    title: 'Design Principles',
    description: 'The philosophy, analytics logic, and tracking methodology behind HabitFlow.',
    color: '#E85D04',
    articles: [
      { title: 'Our productivity philosophy', icon: Lightbulb },
      { title: 'How the scoring system works', icon: BarChart3 },
      { title: 'Understanding the analytics engine', icon: Target },
      { title: 'The science of habit formation', icon: BookOpen },
      { title: 'Why gamification drives results', icon: Zap },
    ],
  },
  {
    id: 'whats-new',
    icon: Sparkles,
    title: "What's New",
    description: 'Latest updates, feature releases, and upcoming improvements to the platform.',
    color: '#FF6B2C',
    articles: [
      { title: 'v2.4 — AI-powered habit suggestions', icon: Sparkles },
      { title: 'v2.3 — Team accountability features', icon: Users },
      { title: 'v2.2 — Advanced heatmap analytics', icon: BarChart3 },
      { title: 'v2.1 — Cross-device sync improvements', icon: RefreshCw },
      { title: 'Roadmap — Upcoming features preview', icon: Rocket },
    ],
  },
];

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.08, delayChildren: 0.1 },
  },
};

const itemVariants = {
  hidden: { opacity: 0, y: 30 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { type: 'spring', damping: 22, stiffness: 120 },
  },
};

export default function HelpCenter() {
  const router = useRouter();
  const [searchQuery, setSearchQuery] = useState('');
  const [activeCategory, setActiveCategory] = useState(null);
  const [isSearchFocused, setIsSearchFocused] = useState(false);

  const selectedCategory = categories.find((c) => c.id === activeCategory);

  // Filter categories by search
  const filteredCategories = searchQuery
    ? categories.filter(
        (c) =>
          c.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
          c.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
          c.articles.some((a) => a.title.toLowerCase().includes(searchQuery.toLowerCase()))
      )
    : categories;

  return (
    <div className="relative min-h-screen bg-[#050505]">
      {/* Background Ambience */}
      <div className="fixed inset-0 pointer-events-none overflow-hidden">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-[#FF6B2C]/5 rounded-full blur-[120px]" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-[#E85D04]/3 rounded-full blur-[100px]" />
      </div>

      {/* Main Content */}
      <main className="relative z-10 max-w-7xl mx-auto px-6 md:px-12 lg:px-16 pt-32 md:pt-40 pb-24">
        {!activeCategory ? (
          <>
            {/* Header */}
            <motion.div
              initial={{ opacity: 0, y: 40 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 1, ease: [0.16, 1, 0.3, 1] }}
              className="text-center mb-10"
            >
              <h1 className="text-5xl md:text-7xl lg:text-8xl font-display font-bold text-white tracking-tight mb-6">
                How can we{' '}
                <span
                  className="text-transparent bg-clip-text"
                  style={{ backgroundImage: 'linear-gradient(90deg, #FF6B2C, #FF8C42, #FFB347)' }}
                >
                  help
                </span>
                ?
              </h1>
              <p className="text-lg md:text-2xl text-text-muted max-w-2xl mx-auto font-light leading-relaxed">
                Explore guides, best practices, and answers to help you get the most out of HabitFlow.
              </p>
            </motion.div>

            {/* Search Bar */}
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.15, ease: [0.16, 1, 0.3, 1] }}
              className="max-w-3xl mx-auto mb-14"
            >
              <div
                className={`relative flex items-center gap-4 px-6 py-5 rounded-2xl backdrop-blur-xl transition-all duration-500 ${
                  isSearchFocused
                    ? 'bg-[#0A0A0A]/90 border border-[#FF6B2C]/40 shadow-[0_0_40px_rgba(255,107,44,0.15)]'
                    : 'bg-[#080808]/70 border border-white/5 shadow-[0_4px_20px_rgba(0,0,0,0.3)]'
                }`}
              >
                <Search size={20} className={`flex-shrink-0 transition-colors duration-300 ${isSearchFocused ? 'text-[#FF6B2C]' : 'text-white/30'}`} />
                <input
                  type="text"
                  placeholder="Search articles, guides, and more..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  onFocus={() => setIsSearchFocused(true)}
                  onBlur={() => setIsSearchFocused(false)}
                  className="flex-1 bg-transparent text-white placeholder-white/25 text-lg font-light outline-none"
                />
                <div className="hidden sm:flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-white/5 border border-white/5 text-white/20 text-sm flex-shrink-0">
                  <Command size={13} />
                  <span>K</span>
                </div>
              </div>
            </motion.div>

            {/* Category Cards Grid */}
            <motion.div
              variants={containerVariants}
              initial="hidden"
              animate="visible"
              className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6"
            >
              {filteredCategories.map((cat) => (
                <motion.button
                  key={cat.id}
                  variants={itemVariants}
                  whileHover={{
                    y: -6,
                    transition: { type: 'spring', damping: 25, stiffness: 300 },
                  }}
                  onClick={() => setActiveCategory(cat.id)}
                  className="relative group rounded-2xl p-[1px] text-left w-full"
                >
                  <div className="absolute inset-0 rounded-2xl bg-gradient-to-b from-white/8 via-white/[0.02] to-transparent opacity-50 group-hover:opacity-100 transition-opacity duration-500" />
                  <div className="absolute -inset-2 rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none blur-xl" style={{ background: `radial-gradient(circle, ${cat.color}10, transparent 70%)` }} />

                  <div className="relative bg-[#080808]/80 backdrop-blur-xl rounded-2xl p-8 lg:p-9 flex flex-col h-full group-hover:bg-[#0A0A0A]/90 transition-colors duration-300 shadow-[0_8px_30px_rgba(0,0,0,0.3)]">
                    <div
                      className="w-14 h-14 rounded-xl flex items-center justify-center mb-6 transition-transform duration-300 group-hover:scale-110"
                      style={{ background: `${cat.color}12`, color: cat.color }}
                    >
                      <cat.icon size={24} />
                    </div>

                    <h3 className="text-xl font-bold font-display text-white mb-2 group-hover:text-white transition-colors">
                      {cat.title}
                    </h3>

                    <p className="text-sm md:text-base text-text-muted font-light leading-relaxed mb-6 flex-1">
                      {cat.description}
                    </p>

                    <div className="flex items-center justify-between">
                      <span className="text-xs text-text-muted/60 font-medium">{cat.articles.length} articles</span>
                      <ChevronRight size={16} className="text-white/20 group-hover:text-[#FF6B2C] group-hover:translate-x-1 transition-all duration-300" />
                    </div>
                  </div>
                </motion.button>
              ))}
            </motion.div>

            {/* Feature Guide Section */}
            <motion.div
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-80px' }}
              transition={{ duration: 1, ease: [0.16, 1, 0.3, 1] }}
              className="mt-24"
            >
              <div className="absolute left-1/2 -translate-x-1/2 w-[700px] h-[400px] bg-[#FF6B2C]/4 rounded-full blur-[180px] pointer-events-none" />

              <div className="text-center mb-14 relative z-10">
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.8 }}
                  className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full border border-[#FF6B2C]/15 bg-[#050505]/40 text-[#FF8C42]/70 mb-6 backdrop-blur-xl"
                >
                  <BookOpen size={14} className="text-[#FF6B2C]/60" />
                  <span className="text-xs font-medium tracking-[0.15em] uppercase">Interactive Docs</span>
                </motion.div>
                <h2 className="text-3xl md:text-5xl lg:text-6xl font-display font-bold text-white tracking-tight mb-5">
                  Feature{' '}
                  <span className="text-transparent bg-clip-text" style={{ backgroundImage: 'linear-gradient(90deg, #FF6B2C, #FF8C42, #FFB347)' }}>
                    Guide
                  </span>
                </h2>
                <p className="text-base md:text-lg text-text-muted max-w-2xl mx-auto font-light leading-relaxed">
                  Deep-dive into every capability HabitFlow offers with step-by-step interactive documentation.
                </p>
              </div>

              <motion.div
                variants={containerVariants}
                initial="hidden"
                whileInView="visible"
                viewport={{ once: true, margin: '-40px' }}
                className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 relative z-10"
              >
                {[
                  {
                    icon: ListChecks, color: '#FF6B2C', title: 'Task Management',
                    links: ['Add Tasks', 'Smart Reminders', 'Group & Sort Tasks', 'Timeline Workflow'],
                  },
                  {
                    icon: Calendar, color: '#FF8C42', title: 'Calendar System',
                    links: ['Weekly Planning', 'Monthly Review', 'Daily Schedule View', 'Calendar Sync'],
                  },
                  {
                    icon: LayoutGrid, color: '#FFB347', title: 'Productivity Matrix',
                    links: ['Priority Quadrants', 'Eisenhower Method', 'Batch Processing', 'Weekly Scoring'],
                  },
                  {
                    icon: Timer, color: '#E85D04', title: 'Focus Mode',
                    links: ['Start Focus Sessions', 'Maintain Deep Work', 'Productivity Timer', 'Focus Statistics'],
                  },
                  {
                    icon: Repeat, color: '#FF6B2C', title: 'Habit System',
                    links: ['Create Habits', 'Habit Streak Logic', 'Progress Tracking', 'Productivity Score'],
                  },
                  {
                    icon: Target, color: '#FF8C42', title: 'Countdown Tools',
                    links: ['Goal Deadlines', 'Milestone Tracking', 'Sprint Timers', 'Completion Forecasts'],
                  },
                ].map((feature, i) => (
                  <motion.div
                    key={i}
                    variants={itemVariants}
                    whileHover={{ y: -5, transition: { type: 'spring', damping: 25, stiffness: 300 } }}
                    className="relative group rounded-2xl p-[1px]"
                  >
                    <div className="absolute inset-0 rounded-2xl bg-gradient-to-b from-white/8 via-white/[0.02] to-transparent opacity-40 group-hover:opacity-100 transition-opacity duration-500" />
                    <div className="absolute -inset-2 rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none blur-xl" style={{ background: `radial-gradient(circle, ${feature.color}10, transparent 70%)` }} />

                    <div className="relative bg-[#080808]/80 backdrop-blur-xl rounded-2xl p-8 lg:p-9 h-full group-hover:bg-[#0A0A0A]/90 transition-colors duration-300 shadow-[0_8px_30px_rgba(0,0,0,0.3)]">
                      <div className="w-13 h-13 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-300" style={{ background: `${feature.color}12`, color: feature.color, width: '3.25rem', height: '3.25rem' }}>
                        <feature.icon size={22} />
                      </div>
                      <h3 className="text-xl font-bold font-display text-white mb-5">{feature.title}</h3>
                      <ul className="space-y-3">
                        {feature.links.map((link, li) => (
                          <li key={li}>
                            <a href="#" className="flex items-center gap-2.5 text-sm md:text-base text-white/50 hover:text-[#FF8C42] transition-colors group/link">
                              <ChevronRight size={14} className="text-white/15 group-hover/link:text-[#FF6B2C] group-hover/link:translate-x-0.5 transition-all flex-shrink-0" />
                              {link}
                            </a>
                          </li>
                        ))}
                      </ul>
                    </div>
                  </motion.div>
                ))}
              </motion.div>
            </motion.div>

            {/* Need More Help CTA */}
            <motion.div
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-60px' }}
              transition={{ duration: 1, ease: [0.16, 1, 0.3, 1] }}
              className="mt-24 relative"
            >
              <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[400px] bg-[#FF6B2C]/6 rounded-full blur-[160px] pointer-events-none" />

              <div className="relative bg-[#080808]/60 backdrop-blur-2xl border border-white/5 rounded-3xl p-10 md:p-20 text-center overflow-hidden">
                <div className="relative z-10">
                  <div className="w-20 h-20 rounded-2xl bg-[#FF6B2C]/10 flex items-center justify-center mx-auto mb-8">
                    <Headphones size={34} className="text-[#FF6B2C]" />
                  </div>

                  <h2 className="text-3xl md:text-5xl font-display font-bold text-white tracking-tight mb-4">
                    Need More{' '}
                    <span className="text-transparent bg-clip-text" style={{ backgroundImage: 'linear-gradient(90deg, #FF6B2C, #FF8C42, #FFB347)' }}>
                      Help
                    </span>
                    ?
                  </h2>
                  <p className="text-base md:text-lg text-text-muted font-light max-w-lg mx-auto mb-12 leading-relaxed">
                    Our support team is here to help you get the most out of HabitFlow. Reach out anytime.
                  </p>

                  <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
                    <button className="group flex items-center gap-2.5 px-8 py-4 rounded-xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white font-semibold text-base shadow-[0_0_20px_rgba(255,107,44,0.3)] hover:shadow-[0_0_35px_rgba(255,107,44,0.55)] transition-all">
                      <MessageCircle size={18} />
                      Contact Support
                      <ArrowRight size={16} className="group-hover:translate-x-1 transition-transform" />
                    </button>
                    <button className="flex items-center gap-2.5 px-8 py-4 rounded-xl bg-white/5 border border-white/10 hover:border-[#FF6B2C]/30 text-white/90 hover:text-white font-semibold text-base hover:shadow-[0_0_15px_rgba(255,107,44,0.15)] transition-all">
                      <Headphones size={18} />
                      Live Chat
                    </button>
                  </div>
                </div>
              </div>
            </motion.div>
          </>
        ) : (
          /* Category Detail View */
          <motion.div
            initial={{ opacity: 0, x: 30 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
          >
            <button
              onClick={() => setActiveCategory(null)}
              className="flex items-center gap-2 text-white/50 hover:text-white transition-colors mb-10 group"
            >
              <ArrowLeft size={16} className="group-hover:-translate-x-1 transition-transform" />
              <span className="text-sm font-medium">All Categories</span>
            </button>

            <div className="flex items-center gap-5 mb-12">
              <div
                className="w-16 h-16 rounded-2xl flex items-center justify-center"
                style={{ background: `${selectedCategory.color}15`, color: selectedCategory.color }}
              >
                <selectedCategory.icon size={28} />
              </div>
              <div>
                <h2 className="text-3xl md:text-5xl font-display font-bold text-white tracking-tight">
                  {selectedCategory.title}
                </h2>
                <p className="text-text-muted text-base font-light mt-2">{selectedCategory.description}</p>
              </div>
            </div>

            <motion.div
              variants={containerVariants}
              initial="hidden"
              animate="visible"
              className="space-y-3.5"
            >
              {selectedCategory.articles.map((article, i) => (
                <motion.a
                  key={i}
                  href="#"
                  variants={itemVariants}
                  whileHover={{
                    x: 6,
                    transition: { type: 'spring', damping: 25, stiffness: 300 },
                  }}
                  className="group flex items-center gap-5 px-7 py-6 rounded-2xl bg-[#080808]/60 backdrop-blur-lg border border-white/[0.03] hover:border-white/10 hover:bg-[#0A0A0A]/80 transition-all duration-300 shadow-[0_4px_20px_rgba(0,0,0,0.2)]"
                >
                  <div
                    className="w-12 h-12 rounded-xl flex items-center justify-center flex-shrink-0 transition-colors duration-300"
                    style={{
                      background: `${selectedCategory.color}08`,
                      color: `${selectedCategory.color}90`,
                    }}
                  >
                    <article.icon size={20} />
                  </div>
                  <span className="flex-1 text-white/80 font-medium text-base group-hover:text-white transition-colors">
                    {article.title}
                  </span>
                  <ChevronRight size={16} className="text-white/15 group-hover:text-[#FF6B2C] group-hover:translate-x-1 transition-all flex-shrink-0" />
                </motion.a>
              ))}
            </motion.div>
          </motion.div>
        )}
      </main>
    </div>
  );
}
