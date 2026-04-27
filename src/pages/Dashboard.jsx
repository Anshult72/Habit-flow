import { useState, useMemo, useEffect } from 'react';
import { motion } from 'framer-motion';
import { format, subDays } from 'date-fns';
import { Trophy, Flame, Target, Zap, Sparkles } from 'lucide-react';
import useStore from '../store/useStore';
import { Line } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler
} from 'chart.js';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler
);

export default function Dashboard() {
  const { habits, completions, toggleCompletion, xp, level, addXP } = useStore();
  const [today] = useState(new Date());

  const todayStr = format(today, 'yyyy-MM-dd');
  const todayCompletions = habits.filter(h => completions[`${h.id}-${todayStr}`]).length;
  const progress = habits.length ? (todayCompletions / habits.length) * 100 : 0;

  const handleToggle = (habitId) => {
    toggleCompletion(habitId, todayStr);
    if (!completions[`${habitId}-${todayStr}`]) {
      addXP(15);
    } else {
      addXP(-15);
    }
  };

  const currentStreak = useMemo(() => {
    let streak = 0;
    let d = today;
    while (true) {
      const dStr = format(d, 'yyyy-MM-dd');
      const completedOnDay = habits.some(h => completions[`${h.id}-${dStr}`]);
      if (completedOnDay) {
        streak++;
        d = subDays(d, 1);
      } else {
        if (format(d, 'yyyy-MM-dd') === todayStr) {
          d = subDays(d, 1);
        } else {
          break;
        }
      }
    }
    return streak;
  }, [completions, habits, today]);

  const chartData = useMemo(() => ({
    labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    datasets: [
      {
        label: 'Productivity',
        data: [65, 59, 80, 81, 56, 95, 100],
        fill: true,
        backgroundColor: (context) => {
          const ctx = context.chart.ctx;
          const gradient = ctx.createLinearGradient(0, 0, 0, 200);
          gradient.addColorStop(0, 'rgba(255, 107, 44, 0.4)');
          gradient.addColorStop(1, 'rgba(255, 107, 44, 0.0)');
          return gradient;
        },
        borderColor: '#FF6B2C',
        borderWidth: 2,
        tension: 0.4,
        pointBackgroundColor: '#FF6B2C',
        pointBorderColor: '#fff',
        pointHoverBackgroundColor: '#fff',
        pointHoverBorderColor: '#FF6B2C',
        pointRadius: 4,
        pointHoverRadius: 6,
      },
    ],
  }), []);

  const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { display: false }, tooltip: { mode: 'index', intersect: false, backgroundColor: 'rgba(20, 20, 25, 0.9)', titleColor: '#F8FAFC', bodyColor: '#94A3B8', borderColor: 'rgba(255,255,255,0.1)', borderWidth: 1 } },
    scales: {
      y: { display: false },
      x: { grid: { display: false }, ticks: { color: '#94A3B8', font: { family: 'Inter', size: 12 } } },
    },
    interaction: { mode: 'nearest', axis: 'x', intersect: false },
  };

  const stats = [
    { label: 'Current Streak', value: `${currentStreak} Days`, icon: Flame, color: 'text-orange-400', glow: 'shadow-[0_0_20px_rgba(251,146,60,0.2)]' },
    { label: 'Level', value: level, icon: Trophy, color: 'text-yellow-400', glow: 'shadow-[0_0_20px_rgba(250,204,21,0.2)]' },
    { label: 'Total XP', value: xp, icon: Zap, color: 'text-[#FF6B2C]', glow: 'shadow-[0_0_20px_rgba(255,107,44,0.2)]' },
    { label: 'Completed', value: Object.keys(completions).length, icon: Target, color: 'text-success', glow: 'shadow-[0_0_20px_rgba(16,185,129,0.2)]' },
  ];

  const circumference = 2 * Math.PI * 40;
  const strokeDashoffset = circumference - (progress / 100) * circumference;

  return (
    <div className="space-y-10 pb-20">
      {/* Header Section */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-6 relative z-10">
        <div>
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            className="flex items-center gap-2 px-3 py-1 rounded-full bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42] text-[10px] font-bold uppercase tracking-[0.2em] mb-4"
          >
            <Sparkles size={12} />
            System Synchronized
          </motion.div>
          <h1 className="text-4xl md:text-5xl font-display font-bold text-white tracking-tight">
            Welcome back, User <span className="text-2xl inline-block animate-bounce origin-bottom">👋</span>
          </h1>
          <p className="text-textMuted mt-3 text-lg font-light">
            Protocol active. You've completed <span className="text-white font-bold">{todayCompletions} of {habits.length}</span> objectives today.
          </p>
        </div>
        <div className="glass-card px-6 py-4 rounded-2xl flex flex-col items-end gap-1 border-white/5">
          <p className="text-[10px] text-textMuted font-bold uppercase tracking-widest">Active Sequence</p>
          <p className="text-lg font-bold text-white tracking-tight">{format(today, 'EEEE, MMMM do')}</p>
        </div>
      </div>

      {/* TOP ROW: Stats Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat, i) => {
          const Icon = stat.icon;
          return (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.1, ease: [0.16, 1, 0.3, 1] }}
              className={`glass-card p-7 rounded-2xl relative overflow-hidden group hover:border-[#FF6B2C]/40 transition-all duration-500 ${stat.glow}`}
            >
              <div className="absolute top-0 right-0 p-6 opacity-5 group-hover:opacity-10 transition-opacity transform translate-x-4 -translate-y-4">
                <Icon size={90} className={stat.color} />
              </div>
              <div className="relative z-10">
                <div className={`w-12 h-12 rounded-xl flex items-center justify-center mb-6 bg-white/5 border border-white/10 group-hover:scale-110 group-hover:border-[#FF6B2C]/30 transition-all duration-500`}>
                  <Icon size={22} className={stat.color} />
                </div>
                <p className="text-xs text-textMuted font-bold mb-1 tracking-[0.1em] uppercase">{stat.label}</p>
                <p className="text-3xl font-display font-bold text-white tracking-tight">{stat.value}</p>
              </div>
            </motion.div>
          );
        })}
      </div>

      {/* SECOND ROW: Main Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Today's Protocol (Left) */}
        <div className="lg:col-span-2">
          <motion.div 
            initial={{ opacity: 0, y: 20 }} 
            animate={{ opacity: 1, y: 0 }} 
            transition={{ delay: 0.4 }}
            className="glass-card p-8 md:p-10 rounded-[2.5rem] border-white/5 h-full"
          >
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-10 gap-6">
              <div>
                <h2 className="text-3xl font-display font-bold text-white tracking-tight">Today's Protocol</h2>
                <p className="text-textMuted text-sm mt-1">Daily directives for current operation</p>
              </div>
              <div className="flex items-center gap-6 bg-white/5 px-6 py-4 rounded-3xl border border-white/10 backdrop-blur-md">
                <div className="text-right">
                  <p className="text-[10px] text-textMuted font-bold uppercase tracking-wider mb-1">Efficiency</p>
                  <p className="text-xl font-bold text-[#FF8C42] leading-none">{Math.round(progress)}%</p>
                </div>
                <div className="relative w-16 h-16 flex items-center justify-center">
                  <svg className="w-full h-full transform -rotate-90" viewBox="0 0 100 100">
                    <circle cx="50" cy="50" r="40" stroke="rgba(255,255,255,0.1)" strokeWidth="8" fill="none" />
                    <motion.circle
                      cx="50" cy="50" r="40"
                      stroke="url(#gradient)" strokeWidth="8" fill="none"
                      strokeDasharray={circumference}
                      initial={{ strokeDashoffset: circumference }}
                      animate={{ strokeDashoffset }}
                      transition={{ duration: 1.5, ease: "easeOut" }}
                      strokeLinecap="round"
                    />
                    <defs>
                      <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="0%">
                        <stop offset="0%" stopColor="#FF6B2C" />
                        <stop offset="100%" stopColor="#FFB347" />
                      </linearGradient>
                    </defs>
                  </svg>
                  <div className="absolute inset-0 flex items-center justify-center text-white font-bold text-xs">
                    {todayCompletions}/{habits.length}
                  </div>
                </div>
              </div>
            </div>
            
            <div className="space-y-4">
              {habits.map((habit, index) => {
                const isCompleted = completions[`${habit.id}-${todayStr}`];
                return (
                  <motion.div
                    key={habit.id}
                    initial={{ opacity: 0, x: -20 }} 
                    animate={{ opacity: 1, x: 0 }} 
                    transition={{ delay: 0.5 + index * 0.1 }}
                    whileHover={{ x: 4, backgroundColor: 'rgba(255,255,255,0.03)' }}
                    whileTap={{ scale: 0.995 }}
                    onClick={() => handleToggle(habit.id)}
                    className={`flex items-center gap-6 p-5 md:p-6 rounded-2xl cursor-pointer transition-all border group/habit ${
                      isCompleted 
                        ? 'bg-[#FF6B2C]/5 border-[#FF6B2C]/40 shadow-[inset_0_0_30px_rgba(255,107,44,0.05)]' 
                        : 'bg-white/[0.01] border-white/5 hover:border-white/20'
                    }`}
                  >
                    <div 
                      className={`w-8 h-8 rounded-xl flex items-center justify-center transition-all duration-500 ${
                        isCompleted ? 'bg-[#FF6B2C] border-[#FF6B2C] shadow-[0_0_20px_rgba(255,107,44,0.6)]' : 'border-2 border-white/10 group-hover/habit:border-[#FF6B2C]/50'
                      }`}
                    >
                      {isCompleted && (
                        <motion.svg initial={{ scale: 0 }} animate={{ scale: 1 }} width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round">
                          <polyline points="20 6 9 17 4 12"></polyline>
                        </motion.svg>
                      )}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-3">
                        <h3 className={`font-bold text-xl truncate transition-all duration-500 ${isCompleted ? 'text-white/40 line-through' : 'text-white'}`}>
                          {habit.name}
                        </h3>
                        <span className="px-2 py-0.5 rounded-md bg-white/5 text-[9px] font-bold uppercase tracking-wider text-textMuted group-hover/habit:text-[#FF8C42] transition-colors">{habit.category}</span>
                      </div>
                      <p className="text-xs text-textMuted mt-1 font-medium">{habit.goal} day target cycle</p>
                    </div>
                    <div 
                      className="w-4 h-4 rounded-full transition-all duration-500 border border-white/10"
                      style={{ 
                        backgroundColor: habit.color, 
                        boxShadow: isCompleted ? `0 0 20px ${habit.color}` : 'none',
                        opacity: isCompleted ? 1 : 0.3
                      }}
                    />
                  </motion.div>
                );
              })}
            </div>
          </motion.div>
        </div>

        {/* Evolution & Daily Directive (Right) */}
        <div className="space-y-8 flex flex-col">
          {/* Evolution Card */}
          <motion.div 
            initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.5 }}
            className="glass-card p-8 rounded-[2.5rem] relative overflow-hidden group border-white/5"
          >
            <div className="absolute inset-0 bg-gradient-to-br from-[#FF6B2C]/10 via-transparent to-[#E85D04]/10 opacity-40 group-hover:opacity-60 transition-opacity" />
            <div className="relative z-10">
              <div className="flex items-center justify-between mb-8">
                <div className="w-12 h-12 rounded-xl bg-[#FF6B2C]/20 flex items-center justify-center border border-[#FF6B2C]/30 shadow-[0_0_20px_rgba(255,107,44,0.2)]">
                  <Zap className="text-[#FF8C42]" size={24} />
                </div>
                <div className="text-right">
                  <p className="text-[10px] text-textMuted font-bold uppercase tracking-widest mb-1">Current Tier</p>
                  <p className="text-3xl font-display font-bold text-white">Lvl {level}</p>
                </div>
              </div>
              
              <div className="space-y-4">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-white font-bold tracking-tight">{xp} Total XP</span>
                  <span className="text-textMuted font-medium">{100 - (xp % 100)} XP to Next Rank</span>
                </div>
                <div className="h-4 w-full bg-black/50 rounded-full overflow-hidden border border-white/5 p-1 backdrop-blur-md">
                  <motion.div 
                    className="h-full bg-gradient-to-r from-[#FF6B2C] to-[#FFB347] rounded-full relative"
                    initial={{ width: 0 }} animate={{ width: `${xp % 100}%` }} transition={{ duration: 1.2, type: "spring" }}
                  >
                    <div className="absolute top-0 right-0 w-8 h-full bg-white/30 blur-md" />
                  </motion.div>
                </div>
                <p className="text-[10px] text-textMuted font-medium text-center uppercase tracking-[0.2em] pt-2">Growth Protocol Active</p>
              </div>
            </div>
          </motion.div>

          {/* Daily Directive Card */}
          <motion.div 
            initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.6 }}
            className="glass-card p-10 rounded-[2.5rem] relative flex-1 border-white/5 flex flex-col justify-center overflow-hidden"
          >
            <div className="absolute top-0 right-0 text-[12rem] text-white/[0.03] font-serif leading-none select-none translate-x-12 -translate-y-8 italic">"</div>
            <div className="relative z-10">
              <div className="flex items-center gap-2 mb-6">
                <div className="w-1.5 h-1.5 rounded-full bg-[#FF6B2C] shadow-[0_0_10px_#FF6B2C]" />
                <h2 className="text-xs font-bold text-[#FF8C42] uppercase tracking-[0.3em]">Daily Directive</h2>
              </div>
              <p className="text-2xl text-white font-display font-medium italic leading-relaxed">
                "Success is the product of daily habits—not once-in-a-lifetime transformations. Systemize the ordinary to achieve the extraordinary."
              </p>
              <div className="mt-10 flex items-center gap-4">
                <div className="w-10 h-[1px] bg-white/20" />
                <p className="text-[10px] font-bold tracking-[0.3em] uppercase text-textMuted">HabitFlow Core AI</p>
              </div>
            </div>
          </motion.div>
        </div>
      </div>

      {/* THIRD ROW: Performance Matrix (Full Width) */}
      <motion.div 
        initial={{ opacity: 0, y: 30 }} 
        animate={{ opacity: 1, y: 0 }} 
        transition={{ delay: 0.7 }}
        className="glass-card p-8 md:p-12 rounded-[3rem] border-white/5"
      >
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-10 gap-6">
          <div>
            <h2 className="text-3xl font-display font-bold text-white tracking-tight">Performance Matrix</h2>
            <p className="text-textMuted text-sm mt-1">Cross-sectional analysis of productivity metrics</p>
          </div>
          <div className="flex items-center gap-3 bg-[#FF6B2C]/5 px-4 py-2 rounded-xl border border-[#FF6B2C]/20">
            <div className="w-2 h-2 rounded-full bg-[#FF6B2C] shadow-[0_0_10px_#FF6B2C]" />
            <span className="text-[10px] font-bold text-[#FF8C42] uppercase tracking-widest">Active Week</span>
          </div>
        </div>
        <div className="h-80 w-full relative">
          <Line data={chartData} options={chartOptions} />
        </div>
      </motion.div>
    </div>
  );
}
