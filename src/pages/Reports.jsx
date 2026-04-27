import { useMemo } from 'react';
import { motion } from 'framer-motion';
import {
  format, subDays, startOfWeek, endOfWeek, eachDayOfInterval,
  startOfMonth, endOfMonth, getDaysInMonth, eachMonthOfInterval,
  startOfYear, endOfYear, getMonth
} from 'date-fns';
import { Bar, Line } from 'react-chartjs-2';
import {
  Chart as ChartJS, BarElement, LineElement, PointElement,
  CategoryScale, LinearScale, Tooltip, Legend, Filler
} from 'chart.js';
import { FileText, TrendingUp, Flame, Award, Download } from 'lucide-react';
import useStore from '../store/useStore';
import toast from 'react-hot-toast';
import { jsPDF } from 'jspdf';
import 'jspdf-autotable';

ChartJS.register(BarElement, LineElement, PointElement, CategoryScale, LinearScale, Tooltip, Legend, Filler);

const TOOLTIP_STYLE = {
  backgroundColor: 'rgba(10,10,15,0.95)',
  titleColor: '#fff', bodyColor: '#94A3B8',
  borderColor: 'rgba(255,107,44,0.2)', borderWidth: 1,
  padding: 12, cornerRadius: 10,
};

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

export default function Reports() {
  const { habits, completions, screenTime, xp, level, selectedYear } = useStore();

  const now = new Date();
  const todayStr = format(now, 'yyyy-MM-dd');

  // ── Weekly summary ──
  const weekStart = startOfWeek(now, { weekStartsOn: 1 });
  const weekEnd = endOfWeek(now, { weekStartsOn: 1 });
  const weekDays = eachDayOfInterval({ start: weekStart, end: weekEnd });
  const weeklyData = weekDays.map(d => {
    const dStr = format(d, 'yyyy-MM-dd');
    return habits.filter(h => completions[`${h.id}-${dStr}`]).length;
  });
  const weeklyTotal = weeklyData.reduce((a, b) => a + b, 0);
  const weeklyMax = habits.length * 7;
  const weeklyRate = weeklyMax > 0 ? Math.round((weeklyTotal / weeklyMax) * 100) : 0;

  // ── Monthly summary ──
  const thisMonthStart = startOfMonth(now);
  const thisMonthEnd = endOfMonth(now);
  const monthDays = eachDayOfInterval({ start: thisMonthStart, end: thisMonthEnd });
  const monthlyData = monthDays.map(d => {
    const dStr = format(d, 'yyyy-MM-dd');
    return habits.filter(h => completions[`${h.id}-${dStr}`]).length;
  });
  const monthlyTotal = monthlyData.reduce((a, b) => a + b, 0);
  const monthlyMax = habits.length * getDaysInMonth(now);
  const monthlyRate = monthlyMax > 0 ? Math.round((monthlyTotal / monthlyMax) * 100) : 0;

  // ── Yearly month-by-month ──
  const yearMonths = eachMonthOfInterval({
    start: startOfYear(new Date(selectedYear, 0)),
    end: endOfYear(new Date(selectedYear, 0))
  });
  const yearlyMonthData = yearMonths.map(monthDate => {
    const mDays = eachDayOfInterval({ start: startOfMonth(monthDate), end: endOfMonth(monthDate) });
    const total = mDays.reduce((sum, d) => {
      const dStr = format(d, 'yyyy-MM-dd');
      return sum + habits.filter(h => completions[`${h.id}-${dStr}`]).length;
    }, 0);
    const max = habits.length * getDaysInMonth(monthDate);
    return max > 0 ? Math.round((total / max) * 100) : 0;
  });

  // ── Streak calc ──
  const currentStreak = useMemo(() => {
    let streak = 0, d = now;
    while (true) {
      const dStr = format(d, 'yyyy-MM-dd');
      if (habits.some(h => completions[`${h.id}-${dStr}`])) { streak++; d = subDays(d, 1); }
      else { if (dStr === todayStr) d = subDays(d, 1); else break; }
    }
    return streak;
  }, [completions, habits]);

  // Best / Worst habits this month
  const habitRankings = useMemo(() => {
    return habits.map(h => {
      const count = monthDays.filter(d => completions[`${h.id}-${format(d, 'yyyy-MM-dd')}`]).length;
      return { ...h, count, rate: getDaysInMonth(now) > 0 ? Math.round((count / getDaysInMonth(now)) * 100) : 0 };
    }).sort((a, b) => b.rate - a.rate);
  }, [habits, completions]);

  const bestHabit = habitRankings[0];
  const worstHabit = habitRankings[habitRankings.length - 1];

  // ── Charts ──
  const weekBarData = {
    labels: weekDays.map(d => format(d, 'EEE')),
    datasets: [{
      label: 'Habits Done',
      data: weeklyData,
      backgroundColor: weeklyData.map((_, i) => format(weekDays[i], 'yyyy-MM-dd') === todayStr ? '#FF6B2C' : 'rgba(255,107,44,0.25)'),
      borderRadius: 10, borderSkipped: false,
    }],
  };

  const yearlyLineData = {
    labels: MONTHS,
    datasets: [{
      label: 'Completion %',
      data: yearlyMonthData,
      fill: true,
      backgroundColor: ctx => {
        const g = ctx.chart.ctx.createLinearGradient(0, 0, 0, 300);
        g.addColorStop(0, 'rgba(255,107,44,0.3)'); g.addColorStop(1, 'rgba(255,107,44,0)');
        return g;
      },
      borderColor: '#FF6B2C', borderWidth: 2.5, tension: 0.4,
      pointBackgroundColor: '#FF6B2C', pointBorderColor: '#fff', pointRadius: 4, pointHoverRadius: 7,
    }],
  };

  const chartBase = {
    responsive: true, maintainAspectRatio: false,
    plugins: { legend: { display: false }, tooltip: TOOLTIP_STYLE },
  };

  // ── PDF Export ──
  const exportPDF = () => {
    const doc = new jsPDF();
    doc.setFontSize(20);
    doc.text('HabitFlow Monthly Report', 14, 20);
    doc.setFontSize(12);
    doc.text(`Generated: ${format(now, 'MMMM do, yyyy')}`, 14, 32);
    doc.text(`Level: ${level}  |  XP: ${xp}  |  Streak: ${currentStreak} days`, 14, 42);

    const tableData = habitRankings.map(h => [h.name, h.category, `${h.count} days`, `${h.rate}%`]);
    doc.autoTable({
      startY: 55,
      head: [['Habit', 'Category', 'Days Done', 'Completion']],
      body: tableData,
      theme: 'grid',
      headStyles: { fillColor: [255, 107, 44] },
    });
    doc.save(`habitflow-report-${format(now, 'yyyy-MM')}.pdf`);
    toast.success('Monthly report downloaded');
  };

  const insightCards = [
    { label: 'Weekly Completion', value: `${weeklyRate}%`, sub: `${weeklyTotal} habits this week`, icon: TrendingUp, color: '#FF6B2C' },
    { label: 'Monthly Completion', value: `${monthlyRate}%`, sub: `${monthlyTotal} habits this month`, icon: Award, color: '#eab308' },
    { label: 'Active Streak', value: `${currentStreak} days`, sub: 'Consecutive active days', icon: Flame, color: '#f97316' },
    { label: 'XP Earned', value: `${xp} XP`, sub: `Level ${level} operator`, icon: FileText, color: '#a855f7' },
  ];

  return (
    <div className="space-y-8 pb-10">
      {/* Header */}
      <div className="relative z-10 flex flex-col md:flex-row justify-between items-start md:items-end gap-6">
        <div>
          <motion.div
            initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }}
            className="flex items-center gap-2 px-3 py-1 rounded-full bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42] text-[10px] font-bold uppercase tracking-[0.2em] mb-4 w-fit"
          >
            <FileText size={12} /> Performance Reports
          </motion.div>
          <h1 className="text-4xl font-display font-bold text-white tracking-tight">
            Intelligence Reports
          </h1>
          <p className="text-textMuted mt-2 text-lg">Weekly, monthly & yearly performance analysis.</p>
        </div>
        <button
          onClick={exportPDF}
          className="flex items-center gap-2 px-6 py-3 rounded-full bg-white text-black font-bold hover:bg-gray-100 transition-colors shadow-[0_0_20px_rgba(255,255,255,0.2)]"
        >
          <Download size={18} /> Export PDF
        </button>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 relative z-10">
        {insightCards.map((card, i) => {
          const Icon = card.icon;
          return (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.08 }}
              className="glass-card p-6 rounded-2xl border border-white/5 group hover:border-[#FF6B2C]/30 transition-all"
            >
              <div className="flex items-center justify-between mb-4">
                <p className="text-[10px] text-textMuted font-bold uppercase tracking-widest">{card.label}</p>
                <Icon size={16} style={{ color: card.color }} />
              </div>
              <p className="text-2xl font-display font-bold text-white mb-1">{card.value}</p>
              <p className="text-xs text-textMuted">{card.sub}</p>
            </motion.div>
          );
        })}
      </div>

      {/* Weekly Chart */}
      <motion.div
        initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }}
        className="glass-card p-8 rounded-3xl border border-white/5 relative z-10 overflow-hidden"
      >
        <div className="absolute top-0 right-0 w-80 h-80 bg-[#FF6B2C]/8 rounded-full blur-[100px] pointer-events-none" />
        <div className="flex justify-between items-center mb-8">
          <div>
            <h2 className="text-2xl font-display font-bold text-white">Weekly Summary</h2>
            <p className="text-textMuted text-sm mt-1">{format(weekStart, 'MMM do')} – {format(weekEnd, 'MMM do')}</p>
          </div>
          <div className="text-right">
            <p className="text-[10px] text-textMuted uppercase tracking-widest mb-1">This Week</p>
            <p className="text-3xl font-display font-bold text-[#FF8C42]">{weeklyRate}%</p>
          </div>
        </div>
        <div className="h-56 relative z-10">
          <Bar data={weekBarData} options={{ ...chartBase, scales: { y: { beginAtZero: true, grid: { color: 'rgba(255,255,255,0.03)' }, ticks: { color: '#94A3B8', stepSize: 1 } }, x: { grid: { display: false }, ticks: { color: '#94A3B8' } } } }} />
        </div>
      </motion.div>

      {/* Yearly Trend */}
      <motion.div
        initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.4 }}
        className="glass-card p-8 rounded-3xl border border-white/5 relative z-10 overflow-hidden"
      >
        <div className="absolute top-0 left-0 w-64 h-64 bg-[#E85D04]/8 rounded-full blur-[100px] pointer-events-none" />
        <div className="flex justify-between items-center mb-8">
          <div>
            <h2 className="text-2xl font-display font-bold text-white">Yearly Overview {selectedYear}</h2>
            <p className="text-textMuted text-sm mt-1">Month-by-month completion rates</p>
          </div>
          <div className="text-right">
            <p className="text-[10px] text-textMuted uppercase tracking-widest mb-1">Yearly Avg</p>
            <p className="text-3xl font-display font-bold text-[#FF8C42]">
              {yearlyMonthData.filter(v => v > 0).length > 0
                ? Math.round(yearlyMonthData.reduce((a, b) => a + b, 0) / yearlyMonthData.filter(v => v > 0).length)
                : 0}%
            </p>
          </div>
        </div>
        <div className="h-64 relative z-10">
          <Line data={yearlyLineData} options={{ ...chartBase, scales: { y: { min: 0, max: 100, grid: { color: 'rgba(255,255,255,0.03)' }, ticks: { color: '#94A3B8', callback: v => `${v}%` } }, x: { grid: { display: false }, ticks: { color: '#94A3B8' } } } }} />
        </div>
      </motion.div>

      {/* Yearly Heatmap */}
      <motion.div
        initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.45 }}
        className="glass-card p-8 rounded-3xl border border-white/5 relative z-10"
      >
        <h2 className="text-2xl font-display font-bold text-white mb-2">Yearly Heatmap {selectedYear}</h2>
        <p className="text-textMuted text-sm mb-6">Every day of the year, visualized</p>
        <div className="grid grid-cols-[repeat(53,minmax(0,1fr))] gap-[3px] overflow-x-auto">
          {/* Month labels */}
          <div className="col-span-53 flex mb-1">
            {MONTHS.map((m, mi) => (
              <div key={m} className="text-[10px] text-textMuted" style={{ flex: mi === 1 ? '4' : '5' }}>{m}</div>
            ))}
          </div>
          {(() => {
            const yearStart = new Date(selectedYear, 0, 1);
            const yearEnd = new Date(selectedYear, 11, 31);
            const allDays = eachDayOfInterval({ start: yearStart, end: yearEnd });
            // Pad to start from Sunday
            const startPad = new Date(selectedYear, 0, 1).getDay();
            const cells = [];
            for (let p = 0; p < startPad; p++) cells.push(null);
            allDays.forEach(d => cells.push(d));
            return cells.map((d, i) => {
              if (!d) return <div key={`p${i}`} className="w-full aspect-square" />;
              const dStr = format(d, 'yyyy-MM-dd');
              const count = habits.filter(h => completions[`${h.id}-${dStr}`]).length;
              const intensity = habits.length > 0 ? count / habits.length : 0;
              return (
                <div
                  key={dStr}
                  title={`${format(d, 'MMM d')}: ${count} habits`}
                  className="w-full aspect-square rounded-[2px] transition-all hover:scale-150 cursor-pointer"
                  style={{
                    backgroundColor: count === 0 ? 'rgba(255,255,255,0.05)' : `rgba(255,107,44,${0.2 + intensity * 0.8})`,
                    boxShadow: count > 0 ? `0 0 3px rgba(255,107,44,${intensity * 0.6})` : 'none'
                  }}
                />
              );
            });
          })()}
        </div>
        <div className="flex items-center gap-3 mt-4 text-xs text-textMuted">
          <span>Less</span>
          {[0.05, 0.25, 0.5, 0.75, 1].map(v => (
            <div key={v} className="w-3 h-3 rounded-[2px]" style={{ backgroundColor: v === 0.05 ? 'rgba(255,255,255,0.05)' : `rgba(255,107,44,${v})` }} />
          ))}
          <span>More</span>
        </div>
      </motion.div>

      {/* Best / Worst Habits */}
      {habitRankings.length > 0 && (
        <motion.div
          initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.5 }}
          className="grid grid-cols-1 md:grid-cols-2 gap-6 relative z-10"
        >
          {/* Best */}
          <div className="glass-card p-8 rounded-3xl border border-green-500/20 bg-green-500/[0.03] relative overflow-hidden">
            <div className="absolute top-0 right-0 w-32 h-32 bg-green-500/10 rounded-full blur-3xl" />
            <p className="text-[10px] text-green-400 font-bold uppercase tracking-widest mb-4">🏆 Best This Month</p>
            {bestHabit && (
              <>
                <h3 className="text-2xl font-display font-bold text-white mb-2">{bestHabit.name}</h3>
                <p className="text-textMuted text-sm">{bestHabit.category} • {bestHabit.count} days completed</p>
                <div className="mt-4 h-2 bg-white/5 rounded-full overflow-hidden">
                  <div className="h-full bg-green-500 rounded-full" style={{ width: `${bestHabit.rate}%` }} />
                </div>
                <p className="text-green-400 font-bold text-xl mt-2">{bestHabit.rate}% completion</p>
              </>
            )}
          </div>
          {/* Worst */}
          <div className="glass-card p-8 rounded-3xl border border-red-500/20 bg-red-500/[0.03] relative overflow-hidden">
            <div className="absolute top-0 right-0 w-32 h-32 bg-red-500/10 rounded-full blur-3xl" />
            <p className="text-[10px] text-red-400 font-bold uppercase tracking-widest mb-4">⚠️ Needs Attention</p>
            {worstHabit && (
              <>
                <h3 className="text-2xl font-display font-bold text-white mb-2">{worstHabit.name}</h3>
                <p className="text-textMuted text-sm">{worstHabit.category} • {worstHabit.count} days completed</p>
                <div className="mt-4 h-2 bg-white/5 rounded-full overflow-hidden">
                  <div className="h-full bg-red-500 rounded-full" style={{ width: `${worstHabit.rate}%` }} />
                </div>
                <p className="text-red-400 font-bold text-xl mt-2">{worstHabit.rate}% completion</p>
              </>
            )}
          </div>
        </motion.div>
      )}
    </div>
  );
}
