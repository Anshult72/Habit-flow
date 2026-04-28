import { useState, useMemo, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { format, subDays } from 'date-fns';
import { useNavigate } from 'react-router-dom';

import { Trophy, Flame, Target, Zap, Sparkles, Shield, Brain, ArrowUpRight, CheckCircle2, ChevronRight, Lock, Rocket, StickyNote, Play, BookOpen, Plus, Clock } from 'lucide-react';
import useStore from '../store/useStore';
import { Line } from 'react-chartjs-2';
import toast from 'react-hot-toast';

export default function Dashboard() {
  const { 
    habits, completions, toggleCompletion, xp, level, 
    streakShields, onboardingDay, useShield, advanceOnboarding, getStats,
    matrixTasks, missions, memos
  } = useStore();
  const navigate = useNavigate();
  
  const [today] = useState(new Date());
  const [dailyFocus, setDailyFocus] = useState(localStorage.getItem('dailyFocus') || '');
  const [xpPopups, setXpPopups] = useState([]);

  const todayStr = format(today, 'yyyy-MM-dd');
  const todayCompletions = habits.filter(h => completions[`${h.id}-${todayStr}`]).length;
  const progress = habits.length ? (todayCompletions / habits.length) * 100 : 0;
  
  const { earnedToday, earnedThisWeek, earnedThisMonth } = getStats();

  const handleToggle = (habit) => {
    const isCompleting = !completions[`${habit.id}-${todayStr}`];
    toggleCompletion(habit.id, todayStr);
    
    if (isCompleting) {
      const difficultyXp = { Easy: 10, Medium: 25, Hard: 50, Elite: 100 };
      const amount = difficultyXp[habit.difficulty || 'Medium'];
      
      const id = Date.now();
      setXpPopups(prev => [...prev, { id, amount }]);
      setTimeout(() => {
        setXpPopups(prev => prev.filter(p => p.id !== id));
      }, 2000);
    }
  };

  const handleFocusChange = (e) => {
    const val = e.target.value;
    setDailyFocus(val);
    localStorage.setItem('dailyFocus', val);
  };

  const currentStreak = useMemo(() => {
    let streak = 0, d = today;
    while (true) {
      const dStr = format(d, 'yyyy-MM-dd');
      const completedOnDay = habits.some(h => completions[`${h.id}-${dStr}`]);
      if (completedOnDay) { streak++; d = subDays(d, 1); }
      else { if (format(d, 'yyyy-MM-dd') === todayStr) d = subDays(d, 1); else break; }
    }
    return streak;
  }, [completions, habits, today, todayStr]);

  const stats = [
    { label: 'Current Streak', value: `${currentStreak} Days`, icon: Flame, color: 'text-orange-400', glow: 'shadow-[0_0_20px_rgba(251,146,60,0.2)]' },
    { label: 'Total XP', value: xp, icon: Zap, color: 'text-[#FF6B2C]', glow: 'shadow-[0_0_20px_rgba(255,107,44,0.2)]' },
    { label: 'Streak Shields', value: streakShields, icon: Shield, color: 'text-blue-400', glow: 'shadow-[0_0_20px_rgba(96,165,250,0.2)]' },
    { label: 'Productivity', value: `${Math.round(progress)}%`, icon: Target, color: 'text-success', glow: 'shadow-[0_0_20px_rgba(16,185,129,0.2)]' },
  ];

  const circumference = 2 * Math.PI * 40;
  const strokeDashoffset = circumference - (progress / 100) * circumference;

  return (
    <div className="space-y-10 pb-20 relative">
      {/* XP Popups Container */}
      <div className="fixed top-24 right-10 z-[100] flex flex-col gap-2 pointer-events-none">
        <AnimatePresence>
          {xpPopups.map(popup => (
            <motion.div key={popup.id} initial={{ opacity: 0, x: 50, scale: 0.5 }} animate={{ opacity: 1, x: 0, scale: 1 }} exit={{ opacity: 0, y: -50, scale: 0.5 }}
              className="bg-[#FF6B2C] text-white px-4 py-2 rounded-xl font-bold flex items-center gap-2 shadow-[0_0_20px_rgba(255,107,44,0.4)]"
            >
              <Zap size={14} fill="currentColor" /> +{popup.amount} XP
            </motion.div>
          ))}
        </AnimatePresence>
      </div>

      <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-6 relative z-10">
        <div>
          <motion.div initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }} className="flex items-center gap-2 px-3 py-1 rounded-full bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42] text-[10px] font-bold uppercase tracking-[0.2em] mb-4">
            <Sparkles size={12} /> System Synchronized
          </motion.div>
          <h1 className="text-4xl md:text-5xl font-display font-bold text-white tracking-tight">
            Control Center <span className="text-2xl inline-block animate-bounce origin-bottom">🛰️</span>
          </h1>
          <p className="text-textMuted mt-3 text-lg font-light">
            Sequence active. <span className="text-white font-bold">{todayCompletions} of {habits.length}</span> objectives synchronized.
          </p>
        </div>
        <div className="flex items-center gap-4">
          <div className="glass-card px-6 py-4 rounded-2xl flex flex-col items-end gap-1 border-white/5">
            <p className="text-[10px] text-textMuted font-bold uppercase tracking-widest">Growth Phase</p>
            <p className="text-lg font-bold text-white tracking-tight">Day {onboardingDay} / 7</p>
          </div>
          {streakShields > 0 && (
            <motion.div whileHover={{ scale: 1.05 }} className="glass-card px-4 py-4 rounded-2xl flex items-center gap-3 border-[#3B82F6]/30 bg-[#3B82F6]/5 cursor-help">
              <Shield size={24} className="text-blue-400" fill="rgba(59,130,246,0.2)" />
              <div className="text-right">
                <p className="text-[9px] text-blue-300/60 font-bold uppercase tracking-widest">Shield Active</p>
                <p className="text-sm font-bold text-white">{streakShields} Charges</p>
              </div>
            </motion.div>
          )}
        </div>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat, i) => {
          const Icon = stat.icon;
          return (
            <motion.div key={i} initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.1 }} className={`glass-card p-7 rounded-2xl relative overflow-hidden group hover:border-[#FF6B2C]/40 transition-all duration-500 ${stat.glow}`}>
              <div className="absolute top-0 right-0 p-6 opacity-5 group-hover:opacity-10 transition-opacity transform translate-x-4 -translate-y-4"><Icon size={90} className={stat.color} /></div>
              <div className="relative z-10">
                <div className="w-12 h-12 rounded-xl flex items-center justify-center mb-6 bg-white/5 border border-white/10 group-hover:scale-110 group-hover:border-[#FF6B2C]/30 transition-all"><Icon size={22} className={stat.color} /></div>
                <p className="text-xs text-textMuted font-bold mb-1 tracking-[0.1em] uppercase">{stat.label}</p>
                <p className="text-3xl font-display font-bold text-white tracking-tight">{stat.value}</p>
              </div>
            </motion.div>
          );
        })}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 space-y-8">
          {/* Onboarding Journey Progress */}
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="glass-card p-8 rounded-[2rem] border-white/5 relative overflow-hidden group">
            <div className="absolute top-0 right-0 w-64 h-64 bg-[#FF6B2C]/5 rounded-full blur-[80px] -z-10 group-hover:bg-[#FF6B2C]/10 transition-all duration-700" />
            <div className="flex items-center justify-between mb-6">
              <div>
                <h3 className="text-lg font-bold text-white mb-1">Evolution Sequence</h3>
                <p className="text-xs text-textMuted">Complete Day {onboardingDay} missions to unlock tier rewards.</p>
              </div>
              <div className="flex gap-1">
                {[1, 2, 3, 4, 5, 6, 7].map(d => (
                  <div key={d} className={`w-6 h-1.5 rounded-full transition-all duration-500 ${d === onboardingDay ? 'bg-[#FF6B2C] w-10 shadow-[0_0_10px_#FF6B2C]' : d < onboardingDay ? 'bg-[#FF6B2C]/40' : 'bg-white/10'}`} />
                ))}
              </div>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="flex items-center gap-4 p-4 rounded-xl bg-white/5 border border-white/10 group-hover:border-[#FF6B2C]/20 transition-all">
                <div className="w-10 h-10 rounded-lg bg-[#FF6B2C]/10 flex items-center justify-center text-[#FF8C42]"><CheckCircle2 size={20} /></div>
                <div><p className="text-xs font-bold text-white">Daily Ritual</p><p className="text-[10px] text-textMuted">Complete all protocols today</p></div>
                <ArrowUpRight size={14} className="ml-auto text-textMuted group-hover:text-[#FF8C42] transition-colors" />
              </div>
              <div className="flex items-center gap-4 p-4 rounded-xl bg-white/5 border border-white/10 group-hover:border-[#FF6B2C]/20 transition-all opacity-50">
                <div className="w-10 h-10 rounded-lg bg-white/5 flex items-center justify-center text-white/20"><Lock size={20} /></div>
                <div><p className="text-xs font-bold text-white">Elite Milestone</p><p className="text-[10px] text-textMuted">Unlocks on Day {onboardingDay + 1}</p></div>
                <ChevronRight size={14} className="ml-auto text-textMuted" />
              </div>
            </div>
          </motion.div>

          {/* Today's Protocols */}
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.4 }} className="glass-card p-8 md:p-10 rounded-[2.5rem] border-white/5">
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-10 gap-6">
              <div>
                <h2 className="text-3xl font-display font-bold text-white tracking-tight">Today's Protocol</h2>
                <p className="text-textMuted text-sm mt-1">Daily directives for current operation</p>
              </div>
              <div className="flex items-center gap-6 bg-white/5 px-6 py-4 rounded-3xl border border-white/10 backdrop-blur-md">
                <div className="text-right">
                  <p className="text-[10px] text-textMuted font-bold uppercase tracking-wider mb-1">XP Earned</p>
                  <p className="text-xl font-bold text-[#FF8C42] leading-none">+{earnedToday}</p>
                </div>
                <div className="relative w-16 h-16 flex items-center justify-center">
                  <svg className="w-full h-full transform -rotate-90" viewBox="0 0 100 100">
                    <circle cx="50" cy="50" r="40" stroke="rgba(255,255,255,0.1)" strokeWidth="8" fill="none" />
                    <motion.circle
                      cx="50" cy="50" r="40" stroke="url(#gradient)" strokeWidth="8" fill="none"
                      strokeDasharray={circumference} initial={{ strokeDashoffset: circumference }}
                      animate={{ strokeDashoffset }} transition={{ duration: 1.5, ease: "easeOut" }} strokeLinecap="round"
                    />
                    <defs><linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="0%"><stop offset="0%" stopColor="#FF6B2C" /><stop offset="100%" stopColor="#FFB347" /></linearGradient></defs>
                  </svg>
                  <div className="absolute inset-0 flex items-center justify-center text-white font-bold text-xs">{todayCompletions}/{habits.length}</div>
                </div>
              </div>
            </div>
            <div className="space-y-4">
              {habits.map((habit, index) => {
                const isCompleted = completions[`${habit.id}-${todayStr}`];
                const difficultyXp = { Easy: 10, Medium: 25, Hard: 50, Elite: 100 };
                return (
                  <motion.div key={habit.id} initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.5 + index * 0.1 }} onClick={() => handleToggle(habit)} className={`flex items-center gap-6 p-5 md:p-6 rounded-2xl cursor-pointer transition-all border group/habit ${isCompleted ? 'bg-[#FF6B2C]/5 border-[#FF6B2C]/40 shadow-[inset_0_0_30px_rgba(255,107,44,0.05)]' : 'bg-white/[0.01] border-white/5 hover:border-white/20'}`}>
                    <div className={`w-8 h-8 rounded-xl flex items-center justify-center transition-all duration-500 ${isCompleted ? 'bg-[#FF6B2C] border-[#FF6B2C] shadow-[0_0_20px_rgba(255,107,44,0.6)]' : 'border-2 border-white/10 group-hover/habit:border-[#FF6B2C]/50'}`}>
                      {isCompleted && <motion.svg initial={{ scale: 0 }} animate={{ scale: 1 }} width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12" /></motion.svg>}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-3 flex-wrap">
                        <h3 className={`font-bold text-xl truncate transition-all duration-500 ${isCompleted ? 'text-white/40 line-through' : 'text-white'}`}>{habit.name}</h3>
                        <span className="px-2 py-0.5 rounded-md bg-white/5 text-[9px] font-bold uppercase tracking-wider text-textMuted group-hover/habit:text-[#FF8C42] transition-colors">{habit.category}</span>
                        <span className={`px-2 py-0.5 rounded-md bg-white/5 text-[9px] font-bold uppercase tracking-wider ${habit.difficulty === 'Elite' ? 'text-purple-400' : habit.difficulty === 'Hard' ? 'text-orange-400' : 'text-textMuted'}`}>{habit.difficulty} ({difficultyXp[habit.difficulty || 'Medium']} XP)</span>
                      </div>
                      <p className="text-xs text-textMuted mt-1 font-medium">{habit.goal} day target cycle</p>
                    </div>
                    <div className="w-4 h-4 rounded-full transition-all duration-500 border border-white/10" style={{ backgroundColor: habit.color, boxShadow: isCompleted ? `0 0 20px ${habit.color}` : 'none', opacity: isCompleted ? 1 : 0.3 }} />
                  </motion.div>
                );
              })}
            </div>
          </motion.div>

          {/* Quick Actions Widget */}
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.6 }} className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {[
              { label: 'Deep Focus', icon: Play, path: '/app/focus-zone', color: 'bg-blue-500/10 text-blue-400 border-blue-500/20 hover:border-blue-500/40' },
              { label: 'New Memo', icon: Plus, path: '/app/memo', color: 'bg-orange-500/10 text-orange-400 border-orange-500/20 hover:border-orange-500/40' },
              { label: 'Study Session', icon: BookOpen, path: '/app/learning-hub', color: 'bg-purple-500/10 text-purple-400 border-purple-500/20 hover:border-purple-500/40' },
              { label: 'Matrix View', icon: Target, path: '/app/matrix', color: 'bg-green-500/10 text-green-400 border-green-500/20 hover:border-green-500/40' },
            ].map((action, idx) => {
              const ActionIcon = action.icon;
              return (
                <button
                  key={idx}
                  onClick={() => navigate(action.path)}
                  className={`glass-card p-4 rounded-2xl border flex flex-col items-center justify-center gap-2 transition-all hover:scale-105 active:scale-95 ${action.color}`}
                >
                  <ActionIcon size={24} />
                  <span className="text-xs font-bold">{action.label}</span>
                </button>
              );
            })}
          </motion.div>
        </div>

        <div className="space-y-8 flex flex-col">
          {/* AI Performance Insights */}
          <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.5 }} className="glass-card p-8 rounded-[2.5rem] border border-[#FF6B2C]/20 bg-[#FF6B2C]/5 relative overflow-hidden group">
            <div className="absolute top-0 right-0 p-6 text-[#FF6B2C] opacity-10 group-hover:opacity-20 transition-opacity"><Brain size={60} /></div>
            <div className="relative z-10">
              <div className="flex items-center gap-2 mb-6">
                <div className="w-8 h-8 rounded-lg bg-[#FF6B2C]/20 flex items-center justify-center border border-[#FF6B2C]/30"><Sparkles size={16} className="text-[#FF8C42]" /></div>
                <h3 className="text-sm font-bold text-white uppercase tracking-widest">AI Intelligence</h3>
              </div>
              <div className="space-y-4">
                <div className="p-4 rounded-xl bg-black/40 border border-white/5">
                  <p className="text-xs text-white/90 leading-relaxed font-medium italic">"Your <span className="text-[#FF8C42] font-bold">Deep Work</span> consistency drops significantly on Tuesdays. Consider shifting the protocol 2 hours earlier."</p>
                </div>
                <div className="p-4 rounded-xl bg-black/40 border border-white/5">
                  <p className="text-xs text-white/90 leading-relaxed font-medium italic">"Protocols initiated before <span className="text-[#FF8C42] font-bold">09:00 AM</span> have a 43% higher completion rate."</p>
                </div>
              </div>
              <button className="w-full mt-6 py-3 rounded-xl border border-[#FF6B2C]/20 hover:bg-[#FF6B2C]/10 text-[10px] font-bold text-[#FF8C42] uppercase tracking-[0.2em] transition-all">View Intelligence Report</button>
            </div>
          </motion.div>

          {/* Matrix Overview Integration */}
          <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.55 }} className="glass-card p-8 rounded-[2.5rem] relative overflow-hidden group border-white/5">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-sm font-bold text-white uppercase tracking-widest flex items-center gap-2">
                <Target size={16} className="text-[#FF6B2C]" /> Matrix Strategy
              </h3>
              <button onClick={() => navigate('/app/matrix')} className="text-[#FF8C42] text-[10px] font-bold uppercase tracking-widest hover:underline">Full View</button>
            </div>
            <div className="grid grid-cols-2 gap-3">
              {[
                { id: 1, label: 'Q1: DO', color: '#FF4D4D' },
                { id: 2, label: 'Q2: PLAN', color: '#FFD700' },
                { id: 3, label: 'Q3: DELEGATE', color: '#3B82F6' },
                { id: 4, label: 'Q4: REMOVE', color: '#10B981' }
              ].map(q => {
                const count = useStore.getState().matrixTasks.filter(t => t.quadrant === q.id && !t.completed).length;
                return (
                  <div key={q.id} className="p-3 rounded-xl bg-white/5 border border-white/10">
                    <div className="flex items-center gap-2 mb-1">
                      <div className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: q.color, boxShadow: `0 0 8px ${q.color}` }} />
                      <span className="text-[8px] font-black text-white/40 tracking-tighter">{q.label}</span>
                    </div>
                    <p className="text-lg font-bold text-white">{count}</p>
                  </div>
                );
              })}
            </div>
          </motion.div>

          {/* Memo / Second Brain Integration */}
          <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.56 }} className="glass-card p-8 rounded-[2.5rem] relative overflow-hidden group border-white/5">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-sm font-bold text-white uppercase tracking-widest flex items-center gap-2">
                <StickyNote size={16} className="text-[#FF6B2C]" /> Cognitive Sync
              </h3>
              <button onClick={() => navigate('/app/memo')} className="text-[#FF8C42] text-[10px] font-bold uppercase tracking-widest hover:underline">Launch Brain</button>
            </div>
            <div className="space-y-3">
              {memos.filter(m => m.isPinned).length > 0 ? (
                memos.filter(m => m.isPinned).slice(0, 2).map(memo => (
                  <div key={memo.id} className="p-4 rounded-xl bg-white/5 border border-white/10 hover:border-[#FF6B2C]/30 transition-all cursor-pointer" onClick={() => navigate('/app/memo')}>
                    <div className="flex justify-between items-start mb-2">
                      <p className="text-xs font-bold text-white truncate pr-4">{memo.title}</p>
                      <span className="text-[8px] font-black text-[#FF8C42] uppercase tracking-widest">{memo.category}</span>
                    </div>
                    <p className="text-[10px] text-textMuted line-clamp-2 leading-relaxed">{memo.content}</p>
                  </div>
                ))
              ) : (
                <div className="p-6 rounded-xl border border-dashed border-white/10 text-center">
                  <p className="text-[10px] text-textMuted uppercase font-bold tracking-widest">No Priority Memos Cached</p>
                </div>
              )}
            </div>
          </motion.div>

          {/* Mission Countdown Integration */}
          <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.58 }} className="glass-card p-8 rounded-[2.5rem] relative overflow-hidden group border-white/5">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-sm font-bold text-white uppercase tracking-widest flex items-center gap-2">
                <Rocket size={16} className="text-[#FF6B2C]" /> Active Missions
              </h3>
              <button onClick={() => navigate('/app/mission-countdown')} className="text-[#FF8C42] text-[10px] font-bold uppercase tracking-widest hover:underline">All Missions</button>
            </div>
            {useStore.getState().missions.length > 0 ? (
              <div className="space-y-4">
                {useStore.getState().missions.slice(0, 1).map(mission => {
                  const daysLeft = Math.max(0, Math.ceil((new Date(mission.targetDate) - new Date()) / (1000 * 60 * 60 * 24)));
                  return (
                    <div key={mission.id} className="space-y-3">
                      <div className="flex justify-between items-end">
                        <p className="text-white font-bold truncate pr-4">{mission.title}</p>
                        <p className="text-[#FF8C42] font-black text-xl leading-none">{daysLeft}<span className="text-[10px] opacity-50 ml-1">Days</span></p>
                      </div>
                      <div className="h-1.5 w-full bg-white/5 rounded-full overflow-hidden">
                        <div className="h-full bg-[#FF6B2C]" style={{ width: '65%' }} />
                      </div>
                    </div>
                  );
                })}
              </div>
            ) : (
              <p className="text-xs text-textMuted italic">No active missions initialized.</p>
            )}
          </motion.div>

          {/* Learning Progress Integration */}
          <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.59 }} className="glass-card p-8 rounded-[2.5rem] relative overflow-hidden group border-white/5">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-sm font-bold text-white uppercase tracking-widest flex items-center gap-2">
                <BookOpen size={16} className="text-[#FF6B2C]" /> Learning Hub
              </h3>
              <button onClick={() => navigate('/app/learning-hub')} className="text-[#FF8C42] text-[10px] font-bold uppercase tracking-widest hover:underline">Modules</button>
            </div>
            <div className="space-y-4">
              <div className="flex items-center gap-4 p-3 rounded-xl bg-white/5 border border-white/10">
                <div className="w-10 h-10 rounded-lg bg-purple-500/20 flex items-center justify-center">
                  <Clock size={18} className="text-purple-400" />
                </div>
                <div className="flex-1">
                  <p className="text-xs font-bold text-white mb-1">Advanced React Patterns</p>
                  <div className="h-1.5 w-full bg-black/50 rounded-full overflow-hidden">
                    <div className="h-full bg-purple-500 w-[45%]" />
                  </div>
                </div>
                <span className="text-xs font-bold text-purple-400">45%</span>
              </div>
            </div>
          </motion.div>

          <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.5 }} className="glass-card p-8 rounded-[2.5rem] relative overflow-hidden group border-white/5">
            <div className="absolute inset-0 bg-gradient-to-br from-[#FF6B2C]/10 via-transparent to-[#E85D04]/10 opacity-40 group-hover:opacity-60 transition-opacity" />
            <div className="relative z-10">
              <div className="flex items-center justify-between mb-8">
                <div className="w-12 h-12 rounded-xl bg-[#FF6B2C]/20 flex items-center justify-center border border-[#FF6B2C]/30 shadow-[0_0_20px_rgba(255,107,44,0.2)]"><Zap className="text-[#FF8C42]" size={24} /></div>
                <div className="text-right">
                  <p className="text-[10px] text-textMuted font-bold uppercase tracking-widest mb-1">Weekly Yield</p>
                  <p className="text-3xl font-display font-bold text-white">{earnedThisWeek} XP</p>
                </div>
              </div>
              <div className="space-y-4">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-white font-bold tracking-tight">Level {level}</span>
                  <span className="text-textMuted font-medium">{500 - (xp % 500)} XP to Rank Up</span>
                </div>
                <div className="h-4 w-full bg-black/50 rounded-full overflow-hidden border border-white/5 p-1 backdrop-blur-md">
                  <motion.div className="h-full bg-gradient-to-r from-[#FF6B2C] to-[#FFB347] rounded-full relative" initial={{ width: 0 }} animate={{ width: `${(xp % 500) / 5}%` }} transition={{ duration: 1.2, type: "spring" }} />
                </div>
                <div className="grid grid-cols-2 gap-4 pt-4 border-t border-white/5">
                  <div><p className="text-[9px] text-textMuted font-bold uppercase tracking-widest mb-1">Today</p><p className="text-sm font-bold text-white">+{earnedToday} XP</p></div>
                  <div><p className="text-[9px] text-textMuted font-bold uppercase tracking-widest mb-1">This Month</p><p className="text-sm font-bold text-white">+{earnedThisMonth} XP</p></div>
                </div>
              </div>
            </div>
          </motion.div>

          <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.6 }} className="glass-card p-10 rounded-[2.5rem] relative flex-1 border-white/5 flex flex-col justify-center overflow-hidden group">
            <div className="absolute top-0 right-0 w-64 h-64 bg-[#FF6B2C]/5 rounded-full blur-[80px] -z-10 group-hover:bg-[#FF6B2C]/10 transition-all duration-700" />
            <div className="relative z-10">
              <div className="flex items-center gap-2 mb-6">
                <div className="w-1.5 h-1.5 rounded-full bg-[#FF6B2C] shadow-[0_0_10px_#FF6B2C]" /><h2 className="text-xs font-bold text-[#FF8C42] uppercase tracking-[0.3em]">Daily Directive</h2>
              </div>
              <textarea value={dailyFocus} onChange={handleFocusChange} placeholder="Declare your primary objective for the current operational cycle..." className="w-full bg-transparent border-none text-2xl text-white font-display font-medium italic leading-relaxed focus:outline-none placeholder:text-white/10 resize-none h-32" />
              <div className="mt-8 flex items-center justify-between">
                <div className="flex items-center gap-4"><div className="w-10 h-[1px] bg-white/20" /><p className="text-[10px] font-bold tracking-[0.3em] uppercase text-textMuted">Focus Lock</p></div>
                {dailyFocus && <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="flex items-center gap-2 text-[#FF6B2C]"><Sparkles size={14} /><span className="text-[10px] font-bold uppercase tracking-widest">Active</span></motion.div>}
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </div>
  );
}
