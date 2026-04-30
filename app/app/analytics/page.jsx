'use client';

import { useMemo, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  format, startOfMonth, endOfMonth, eachDayOfInterval, getDaysInMonth,
  subDays, startOfYear, endOfYear
} from 'date-fns';
import { Line, Doughnut, Bar } from 'react-chartjs-2';
import {
  Chart as ChartJS, RadialLinearScale, ArcElement, PointElement,
  LineElement, BarElement, Filler, Tooltip, Legend, CategoryScale, LinearScale
} from 'chart.js';
import useStore from '@/store/useStore';
import { Activity, Flame, Target, TrendingUp, Monitor, Award } from 'lucide-react';

ChartJS.register(
  RadialLinearScale, ArcElement, PointElement, LineElement, BarElement,
  Filler, Tooltip, Legend, CategoryScale, LinearScale
);

const TOOLTIP_STYLE = {
  backgroundColor: 'rgba(10,10,15,0.95)',
  titleColor: '#fff',
  bodyColor: '#94A3B8',
  borderColor: 'rgba(255,107,44,0.2)',
  borderWidth: 1,
  padding: 14,
  cornerRadius: 10,
};

export default function Analytics() {
  const { 
    habits, completions, screenTime, selectedMonth, selectedYear, 
    setSelectedMonth, setSelectedYear, matrixTasks 
  } = useStore();
  const [activeTab, setActiveTab] = useState('monthly');

  const now = new Date();
  const monthStart = startOfMonth(new Date(selectedYear, selectedMonth));
  const monthEnd = endOfMonth(new Date(selectedYear, selectedMonth));
  const days = eachDayOfInterval({ start: monthStart, end: monthEnd }).map(d => format(d, 'yyyy-MM-dd'));
  const daysInMonth = getDaysInMonth(new Date(selectedYear, selectedMonth));

  // Streak calc
  const currentStreak = useMemo(() => {
    let streak = 0, d = now;
    const todayStr = format(now, 'yyyy-MM-dd');
    while (true) {
      const dStr = format(d, 'yyyy-MM-dd');
      if (habits.some(h => completions[`${h.id}-${dStr}`])) { streak++; d = subDays(d, 1); }
      else { if (dStr === todayStr) d = subDays(d, 1); else break; }
    }
    return streak;
  }, [completions, habits, now]);

  const bestStreak = useMemo(() => {
    let best = 0, current = 0;
    const allDates = [...new Set(Object.keys(completions).map(k => k.split('-').slice(1).join('-')))].sort();
    allDates.forEach((d) => {
      const had = habits.some(h => completions[`${h.id}-${d}`]);
      if (had) { current++; best = Math.max(best, current); }
      else current = 0;
    });
    return best;
  }, [completions, habits]);

  // Monthly completion line
  const dailyCompletions = days.map(d => habits.filter(h => completions[`${h.id}-${d}`]).length);
  const totalMonthlyCompleted = dailyCompletions.reduce((a, b) => a + b, 0);
  const maxPossible = habits.length * daysInMonth;
  const completionRate = maxPossible > 0 ? Math.round((totalMonthlyCompleted / maxPossible) * 100) : 0;

  // Weekly last 7 days
  const last7 = Array.from({ length: 7 }, (_, i) => subDays(now, 6 - i));
  const weeklyData = last7.map(d => {
    const dStr = format(d, 'yyyy-MM-dd');
    return habits.filter(h => completions[`${h.id}-${dStr}`]).length;
  });
  const weekLabels = last7.map(d => format(d, 'EEE'));

  // Categories
  const categories = useMemo(() => {
    const counts = {};
    habits.forEach(h => { counts[h.category] = (counts[h.category] || 0) + 1; });
    return counts;
  }, [habits]);

  // Habit rankings
  const habitRankings = useMemo(() =>
    habits.map(h => {
      const count = days.filter(d => completions[`${h.id}-${d}`]).length;
      const rate = daysInMonth > 0 ? Math.round((count / daysInMonth) * 100) : 0;
      return { ...h, count, rate };
    }).sort((a, b) => b.count - a.count),
    [habits, completions, days, daysInMonth]
  );

  // Screen time last 7 days
  const screenData = last7.map(d => screenTime[format(d, 'yyyy-MM-dd')] || 0);
  const avgScreenTime = screenData.length > 0 ? (screenData.reduce((a, b) => a + b, 0) / screenData.length).toFixed(1) : 0;

  // Productivity Score
  const productivityScore = useMemo(() => {
    const completionFactor = completionRate;
    const streakFactor = Math.min(currentStreak * 2, 30);
    const screenFactor = avgScreenTime > 0 ? Math.max(0, 20 - avgScreenTime * 2) : 20;
    return Math.min(100, Math.round((completionFactor * 0.6 + streakFactor + screenFactor) / 1.1));
  }, [completionRate, currentStreak, avgScreenTime]);

  // Yearly heatmap
  const yearStart = startOfYear(new Date(selectedYear, 0, 1));
  const yearEnd = endOfYear(new Date(selectedYear, 11, 31));
  const yearDays = eachDayOfInterval({ start: yearStart, end: yearEnd });
  const yearlyHeatmap = yearDays.map(d => {
    const dStr = format(d, 'yyyy-MM-dd');
    const count = habits.filter(h => completions[`${h.id}-${dStr}`]).length;
    return { date: dStr, count, intensity: habits.length > 0 ? count / habits.length : 0 };
  });

  // Chart defaults
  const lineData = {
    labels: days.map(d => d.split('-')[2]),
    datasets: [{
      label: 'Completions',
      data: dailyCompletions,
      fill: true,
      backgroundColor: ctx => {
        const g = ctx.chart.ctx.createLinearGradient(0, 0, 0, 300);
        g.addColorStop(0, 'rgba(255,107,44,0.35)');
        g.addColorStop(1, 'rgba(255,107,44,0)');
        return g;
      },
      borderColor: '#FF6B2C',
      borderWidth: 2.5,
      tension: 0.4,
      pointBackgroundColor: '#FF6B2C',
      pointBorderColor: '#fff',
      pointHoverBackgroundColor: '#fff',
      pointHoverBorderColor: '#FF6B2C',
      pointRadius: 3,
      pointHoverRadius: 6,
    }],
  };

  const weekBarData = {
    labels: weekLabels,
    datasets: [{
      label: 'Habits Done',
      data: weeklyData,
      backgroundColor: weeklyData.map((_, i) => i === 6 ? '#FF6B2C' : 'rgba(255,107,44,0.25)'),
      borderRadius: 8,
      borderSkipped: false,
    }],
  };

  const screenBarData = {
    labels: weekLabels,
    datasets: [{
      label: 'Screen Hours',
      data: screenData,
      backgroundColor: screenData.map(v => v <= 3 ? 'rgba(34,197,94,0.5)' : v <= 6 ? 'rgba(251,191,36,0.5)' : 'rgba(239,68,68,0.5)'),
      borderRadius: 8,
      borderSkipped: false,
    }],
  };

  const doughnutData = {
    labels: Object.keys(categories),
    datasets: [{
      data: Object.values(categories),
      backgroundColor: ['#FF6B2C', '#E85D04', '#FF8C42', '#fb923c', '#f97316', '#ea580c'],
      borderWidth: 0,
      hoverOffset: 12,
    }],
  };

  const chartBase = {
    responsive: true, maintainAspectRatio: false,
    plugins: { legend: { display: false }, tooltip: TOOLTIP_STYLE },
  };

  const tabs = ['monthly', 'weekly', 'yearly', 'screen'];
  const tabLabels = { monthly: 'Monthly', weekly: 'Weekly', yearly: 'Yearly', screen: 'Screen Time' };

  // Score color
  const scoreColor = productivityScore >= 70 ? '#22c55e' : productivityScore >= 40 ? '#eab308' : '#ef4444';
  const circumference = 2 * Math.PI * 42;
  const scoreOffset = circumference - (productivityScore / 100) * circumference;

  return (
    <div className="space-y-8 pb-10">
      <div className="relative z-10 flex flex-col md:flex-row justify-between items-start md:items-end gap-6">
        <div>
          <h1 className="text-4xl font-display font-bold text-white tracking-tight flex items-center gap-3">
            Intelligence Hub <Activity className="text-[#E85D04]" />
          </h1>
          <p className="text-text-muted mt-2 text-lg">Deep analytical review of operational performance.</p>
        </div>
        <div className="flex items-center gap-3">
          <select
            value={selectedMonth}
            onChange={e => setSelectedMonth(+e.target.value)}
            className="bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-white text-sm focus:outline-none focus:border-[#FF6B2C] appearance-none"
          >
            {Array.from({ length: 12 }, (_, i) => (
              <option key={i} value={i} className="bg-background">{format(new Date(2000, i, 1), 'MMMM')}</option>
            ))}
          </select>
          <select
            value={selectedYear}
            onChange={e => setSelectedYear(+e.target.value)}
            className="bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-white text-sm focus:outline-none focus:border-[#FF6B2C] appearance-none"
          >
            {[2023, 2024, 2025, 2026].map(y => (
              <option key={y} value={y} className="bg-background">{y}</option>
            ))}
          </select>
        </div>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 relative z-10">
        {[
          { label: 'Productivity Score', value: `${productivityScore}`, suffix: '/100', icon: TrendingUp, color: scoreColor },
          { label: 'Completion Rate', value: `${completionRate}`, suffix: '%', icon: Target, color: '#FF6B2C' },
          { label: 'Current Streak', value: `${currentStreak}`, suffix: ' days', icon: Flame, color: '#f97316' },
          { label: 'Best Streak', value: `${bestStreak}`, suffix: ' days', icon: Award, color: '#eab308' },
        ].map((kpi, i) => {
          const Icon = kpi.icon;
          return (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 16 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.08 }}
              className="glass-card p-6 rounded-2xl border border-white/5 group hover:border-[#FF6B2C]/30 transition-all duration-300"
            >
              <div className="flex items-center justify-between mb-4">
                <p className="text-[10px] text-text-muted font-bold uppercase tracking-widest">{kpi.label}</p>
                <Icon size={16} style={{ color: kpi.color }} />
              </div>
              <p className="text-3xl font-display font-bold text-white">
                {kpi.value}<span className="text-base text-text-muted">{kpi.suffix}</span>
              </p>
            </motion.div>
          );
        })}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6 relative z-10">
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }}
          className="glass-card p-8 rounded-3xl border border-white/5 flex flex-col items-center justify-center gap-4"
        >
          <p className="text-xs text-text-muted font-bold uppercase tracking-widest">Productivity Score</p>
          <div className="relative w-36 h-36">
            <svg className="w-full h-full -rotate-90" viewBox="0 0 100 100">
              <circle cx="50" cy="50" r="42" stroke="rgba(255,255,255,0.05)" strokeWidth="8" fill="none" />
              <motion.circle
                cx="50" cy="50" r="42"
                stroke={scoreColor}
                strokeWidth="8" fill="none"
                strokeDasharray={circumference}
                initial={{ strokeDashoffset: circumference }}
                animate={{ strokeDashoffset: scoreOffset }}
                transition={{ duration: 2, ease: 'easeOut' }}
                strokeLinecap="round"
                style={{ filter: `drop-shadow(0 0 8px ${scoreColor})` }}
              />
            </svg>
            <div className="absolute inset-0 flex flex-col items-center justify-center">
              <p className="text-4xl font-display font-bold text-white">{productivityScore}</p>
              <p className="text-[10px] text-text-muted uppercase tracking-wider">/ 100</p>
            </div>
          </div>
          <p className="text-sm text-center" style={{ color: scoreColor }}>
            {productivityScore >= 70 ? '🔥 Excellent Form' : productivityScore >= 40 ? '⚡ Building Up' : '💡 Keep Going'}
          </p>
        </motion.div>

        <div className="lg:col-span-3 glass-card rounded-3xl border border-white/5 overflow-hidden">
          <div className="flex border-b border-white/5">
            {tabs.map(tab => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab)}
                className={`flex-1 px-4 py-4 text-sm font-bold uppercase tracking-wider transition-all ${
                  activeTab === tab
                    ? 'text-white border-b-2 border-[#FF6B2C] bg-[#FF6B2C]/5'
                    : 'text-text-muted hover:text-white/80'
                }`}
              >
                {tabLabels[tab]}
              </button>
            ))}
          </div>
          <div className="p-8 h-72">
            <AnimatePresence mode="wait">
              {activeTab === 'monthly' && (
                <motion.div key="monthly" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="h-full">
                  <Line data={lineData} options={{ ...chartBase, scales: { y: { grid: { color: 'rgba(255,255,255,0.03)' }, ticks: { color: '#94A3B8' } }, x: { grid: { display: false }, ticks: { color: '#94A3B8', maxTicksLimit: 10 } } } }} />
                </motion.div>
              )}
              {activeTab === 'weekly' && (
                <motion.div key="weekly" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="h-full">
                  <Bar data={weekBarData} options={{ ...chartBase, scales: { y: { grid: { color: 'rgba(255,255,255,0.03)' }, ticks: { color: '#94A3B8' } }, x: { grid: { display: false }, ticks: { color: '#94A3B8' } } } }} />
                </motion.div>
              )}
              {activeTab === 'screen' && (
                <motion.div key="screen" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="h-full">
                  <Bar data={screenBarData} options={{ ...chartBase, scales: { y: { grid: { color: 'rgba(255,255,255,0.03)' }, ticks: { color: '#94A3B8' } }, x: { grid: { display: false }, ticks: { color: '#94A3B8' } } }, plugins: { legend: { display: false }, tooltip: { ...TOOLTIP_STYLE, callbacks: { label: ctx => `${ctx.parsed.y}h` } } } }} />
                </motion.div>
              )}
              {activeTab === 'yearly' && (
                <motion.div key="yearly" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="h-full overflow-auto">
                  <div className="flex flex-wrap gap-[3px] h-full content-start">
                    {yearlyHeatmap.map((day, i) => (
                      <div
                        key={i}
                        title={`${day.date}: ${day.count} habits`}
                        className="w-[10px] h-[10px] rounded-sm transition-all hover:scale-150 cursor-pointer"
                        style={{
                          backgroundColor: day.count === 0
                            ? 'rgba(255,255,255,0.05)'
                            : `rgba(255,107,44,${0.2 + day.intensity * 0.8})`,
                          boxShadow: day.count > 0 ? `0 0 4px rgba(255,107,44,${day.intensity * 0.5})` : 'none'
                        }}
                      />
                    ))}
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 relative z-10">
        <div className="glass-card p-8 rounded-3xl border border-white/5 relative overflow-hidden">
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 bg-[#E85D04]/10 rounded-full blur-[100px] pointer-events-none" />
          <h2 className="text-xl font-display font-bold text-white mb-8 text-center relative z-10">Protocol Distribution</h2>
          <div className="h-64 flex justify-center relative z-10">
            {Object.keys(categories).length > 0 ? (
              <Doughnut data={doughnutData} options={{ ...chartBase, plugins: { ...chartBase.plugins, legend: { position: 'right', labels: { color: '#F8FAFC', padding: 16, usePointStyle: true } } }, cutout: '68%' }} />
            ) : (
              <div className="flex items-center text-text-muted">Awaiting protocol data.</div>
            )}
          </div>
        </div>

        <div className="glass-card p-8 rounded-3xl border border-white/5 relative overflow-hidden">
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 bg-[#FF6B2C]/10 rounded-full blur-[100px] pointer-events-none" />
          <h2 className="text-xl font-display font-bold text-white mb-8 text-center relative z-10">Strategic Priority Allocation</h2>
          <div className="h-64 flex justify-center relative z-10">
            <Bar 
              data={{
                labels: ['Q1', 'Q2', 'Q3', 'Q4'],
                datasets: [{
                  label: 'Tasks',
                  data: [1, 2, 3, 4].map(id => matrixTasks.filter(t => t.quadrant === id).length),
                  backgroundColor: ['#FF4D4D', '#FFD700', '#3B82F6', '#10B981'],
                  borderRadius: 12,
                }]
              }} 
              options={{ ...chartBase, scales: { y: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94A3B8', stepSize: 1 } }, x: { grid: { display: false }, ticks: { color: '#94A3B8' } } } }} 
            />
          </div>
        </div>
      </div>

      <div className="glass-card p-8 rounded-3xl border border-white/5 relative z-10">
        <div className="flex items-center justify-between mb-8">
          <h2 className="text-2xl font-display font-bold text-white">Habit Performance Ranking</h2>
          <span className="text-[10px] text-text-muted uppercase tracking-widest border border-white/10 px-3 py-1 rounded-full">This Month</span>
        </div>
        <div className="space-y-4">
          {habitRankings.map((habit, i) => (
            <motion.div
              key={habit.id}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: i * 0.06 }}
              className="flex items-center gap-4 group"
            >
              <span className="text-2xl font-display font-bold text-white/20 w-8 text-center">#{i + 1}</span>
              <div className="w-3 h-3 rounded-full shrink-0" style={{ backgroundColor: habit.color, boxShadow: `0 0 8px ${habit.color}` }} />
              <div className="flex-1 min-w-0">
                <div className="flex justify-between items-center mb-1">
                  <span className="text-white font-bold truncate">{habit.name}</span>
                  <span className="text-[#FF8C42] font-bold text-sm ml-4">{habit.count}/{daysInMonth} days</span>
                </div>
                <div className="h-2 bg-white/5 rounded-full overflow-hidden">
                  <motion.div
                    initial={{ width: 0 }}
                    animate={{ width: `${habit.rate}%` }}
                    transition={{ duration: 1, delay: i * 0.06 + 0.2, ease: 'easeOut' }}
                    className="h-full rounded-full"
                    style={{ backgroundColor: habit.color, boxShadow: `0 0 8px ${habit.color}60` }}
                  />
                </div>
              </div>
              <span className="text-white font-display font-bold text-lg w-14 text-right">{habit.rate}%</span>
            </motion.div>
          ))}
          {habitRankings.length === 0 && (
            <p className="text-text-muted text-center py-8">No habits to rank yet. Create some habits to see analytics.</p>
          )}
        </div>
      </div>

      <div className="glass-card p-8 rounded-3xl border border-white/5 relative z-10">
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-8 gap-4">
          <div>
            <h2 className="text-2xl font-display font-bold text-white flex items-center gap-2">
              <Monitor className="text-[#FF8C42]" /> Screen Time Intelligence
            </h2>
            <p className="text-text-muted text-sm mt-1">Track your digital usage patterns</p>
          </div>
          <div className="glass-card px-6 py-3 rounded-2xl border border-white/5">
            <p className="text-[10px] text-text-muted uppercase tracking-widest mb-1">7-Day Avg</p>
            <p className="text-2xl font-display font-bold" style={{ color: +avgScreenTime <= 3 ? '#22c55e' : +avgScreenTime <= 6 ? '#eab308' : '#ef4444' }}>
              {avgScreenTime}h
            </p>
          </div>
        </div>
        <div className="grid grid-cols-7 gap-2">
          {last7.map((d, i) => {
            const hours = screenData[i];
            const pct = Math.min((hours / 12) * 100, 100);
            const color = hours <= 3 ? '#22c55e' : hours <= 6 ? '#eab308' : '#ef4444';
            return (
              <div key={i} className="flex flex-col items-center gap-2">
                <div className="w-full h-24 bg-white/5 rounded-xl overflow-hidden flex flex-col-reverse">
                  <motion.div
                    initial={{ height: 0 }}
                    animate={{ height: `${pct}%` }}
                    transition={{ duration: 1, delay: i * 0.1, ease: 'easeOut' }}
                    className="w-full rounded-xl"
                    style={{ backgroundColor: color, boxShadow: `0 0 10px ${color}40` }}
                  />
                </div>
                <span className="text-xs text-text-muted">{format(d, 'EEE')}</span>
                <span className="text-xs font-bold text-white">{hours > 0 ? `${hours}h` : '–'}</span>
              </div>
            );
          })}
        </div>
        <div className="flex gap-6 mt-6 text-xs text-text-muted">
          <div className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-green-500" /> Low (≤3h)</div>
          <div className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-yellow-500" /> Medium (4–6h)</div>
          <div className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-red-500" /> High (&gt;6h)</div>
        </div>
      </div>
    </div>
  );
}
