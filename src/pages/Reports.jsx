import { motion } from 'framer-motion';
import { FileText, Download, TrendingUp, Calendar, Zap, Target, Flame, Brain, AlertTriangle, ChevronRight, BarChart3, PieChart, CheckCircle2 } from 'lucide-react';
import useStore from '../store/useStore';
import { Line, Bar, Doughnut } from 'react-chartjs-2';
import {
  Chart as ChartJS, CategoryScale, LinearScale, PointElement, LineElement, 
  BarElement, Title, Tooltip, Legend, Filler, ArcElement
} from 'chart.js';

ChartJS.register(
  CategoryScale, LinearScale, PointElement, LineElement, BarElement, 
  Title, Tooltip, Legend, Filler, ArcElement
);

export default function Reports() {
  const { habits, completions, xp, level } = useStore();

  const mockData = {
    bestDay: 'Thursday',
    weakestDay: 'Tuesday',
    completionRate: 84,
    focusTrend: '+12%',
    mostSkipped: 'Meditation',
    strongestHabit: 'Morning Run',
  };

  const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: false },
      tooltip: {
        backgroundColor: 'rgba(10, 10, 12, 0.95)',
        titleColor: '#fff',
        bodyColor: '#94A3B8',
        borderColor: 'rgba(255, 107, 44, 0.2)',
        borderWidth: 1,
        padding: 12,
        cornerRadius: 8,
      }
    },
    scales: {
      y: { display: false },
      x: { grid: { display: false }, ticks: { color: '#64748B', font: { size: 10 } } }
    }
  };

  return (
    <div className="space-y-10 pb-20">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-6 relative z-10">
        <div>
          <motion.div initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }} className="flex items-center gap-2 px-3 py-1 rounded-full bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42] text-[10px] font-bold uppercase tracking-[0.2em] mb-4">
            <Brain size={12} /> Analytical Engine Active
          </motion.div>
          <h1 className="text-4xl md:text-5xl font-display font-bold text-white tracking-tight">
            Performance <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#FF6B2C] to-[#FFB347]">Intelligence</span>
          </h1>
          <p className="text-textMuted mt-3 text-lg font-light max-w-2xl">
            Cross-sectional analysis of your operational capacity and behavioral patterns.
          </p>
        </div>
        <button className="px-8 py-4 rounded-2xl bg-white text-black font-bold flex items-center gap-3 shadow-[0_0_30px_rgba(255,255,255,0.2)] hover:scale-105 transition-all">
          <Download size={20} /> Export Report
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        {[
          { label: 'Elite Day', value: mockData.bestDay, icon: Zap, color: 'text-yellow-400' },
          { label: 'Variance', value: mockData.weakestDay, icon: AlertTriangle, color: 'text-red-400' },
          { label: 'Efficiency', value: `${mockData.completionRate}%`, icon: Target, color: 'text-green-400' },
          { label: 'Momentum', value: mockData.focusTrend, icon: TrendingUp, color: 'text-[#FF6B2C]' },
        ].map((stat, i) => {
          const Icon = stat.icon;
          return (
            <motion.div key={i} initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.1 }} className="glass-card p-6 rounded-2xl border-white/5 relative overflow-hidden group">
              <div className="absolute top-0 right-0 p-4 opacity-5 group-hover:opacity-10 transition-opacity"><Icon size={60} /></div>
              <p className="text-[10px] text-textMuted font-bold uppercase tracking-widest mb-1">{stat.label}</p>
              <p className={`text-2xl font-bold ${stat.color}`}>{stat.value}</p>
            </motion.div>
          );
        })}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 space-y-8">
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="glass-card p-8 rounded-[2.5rem] border-white/5">
            <div className="flex items-center justify-between mb-10">
              <h3 className="text-xl font-bold text-white flex items-center gap-3"><BarChart3 className="text-[#FF6B2C]" /> XP Progression Curve</h3>
              <div className="flex gap-4">
                <span className="flex items-center gap-2 text-[10px] font-bold text-textMuted uppercase tracking-widest"><div className="w-2 h-2 rounded-full bg-[#FF6B2C]" /> Actual</span>
                <span className="flex items-center gap-2 text-[10px] font-bold text-textMuted uppercase tracking-widest"><div className="w-2 h-2 rounded-full bg-white/20" /> Projection</span>
              </div>
            </div>
            <div className="h-80 w-full">
              <Line data={{
                labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                datasets: [
                  { 
                    label: 'XP', data: [120, 190, 150, 300, 280, 450, 520], fill: true, 
                    borderColor: '#FF6B2C', backgroundColor: 'rgba(255, 107, 44, 0.1)', tension: 0.4, borderWidth: 3, pointRadius: 0
                  },
                  { 
                    label: 'Target', data: [100, 200, 300, 400, 500, 600, 700], fill: false, 
                    borderColor: 'rgba(255,255,255,0.1)', borderDash: [5, 5], tension: 0.4, borderWidth: 1, pointRadius: 0
                  }
                ]
              }} options={chartOptions} />
            </div>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="glass-card p-8 rounded-[2.5rem] border-white/5">
              <h3 className="text-lg font-bold text-white mb-8 flex items-center gap-3"><PieChart className="text-[#FF8C42]" /> Categorical Weight</h3>
              <div className="h-64 relative">
                <Doughnut data={{
                  labels: ['Health', 'Work', 'Finance', 'Mind'],
                  datasets: [{
                    data: [35, 45, 10, 10],
                    backgroundColor: ['#FF6B2C', '#E85D04', '#FFB347', '#fb923c'],
                    borderWidth: 0, cutout: '80%'
                  }]
                }} options={{ ...chartOptions, plugins: { ...chartOptions.plugins, tooltip: { enabled: true } } }} />
                <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
                  <p className="text-3xl font-bold text-white">84%</p>
                  <p className="text-[10px] text-textMuted uppercase tracking-widest font-bold">Focus</p>
                </div>
              </div>
            </motion.div>

            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="glass-card p-8 rounded-[2.5rem] border-white/5">
              <h3 className="text-lg font-bold text-white mb-8">Performance Warnings</h3>
              <div className="space-y-4">
                <div className="p-4 rounded-2xl bg-red-400/5 border border-red-400/20 flex gap-4">
                  <div className="w-10 h-10 rounded-xl bg-red-400/10 flex items-center justify-center shrink-0"><AlertTriangle className="text-red-400" size={18} /></div>
                  <div>
                    <p className="text-sm font-bold text-white">Variance Alert</p>
                    <p className="text-xs text-textMuted mt-1">Consistency on Tuesdays has dropped by 18% over the last 3 weeks.</p>
                  </div>
                </div>
                <div className="p-4 rounded-2xl bg-green-400/5 border border-green-400/20 flex gap-4">
                  <div className="w-10 h-10 rounded-xl bg-green-400/10 flex items-center justify-center shrink-0"><CheckCircle2 className="text-green-400" size={18} /></div>
                  <div>
                    <p className="text-sm font-bold text-white">Stability Peak</p>
                    <p className="text-xs text-textMuted mt-1">Morning protocols are 98% consistent. Consider increasing difficulty.</p>
                  </div>
                </div>
              </div>
            </motion.div>
          </div>
        </div>

        <div className="space-y-8">
          <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} className="glass-card p-8 rounded-[2.5rem] border-white/5 bg-gradient-to-b from-white/5 to-transparent">
            <h3 className="text-lg font-bold text-white mb-6">Behavioral Insights</h3>
            <div className="space-y-6">
              {[
                { label: 'Most Skipped', value: mockData.mostSkipped, trend: 'Increasing', trendColor: 'text-red-400' },
                { label: 'Strongest Core', value: mockData.strongestHabit, trend: 'Elite Status', trendColor: 'text-green-400' },
                { label: 'Streak Peak', value: '127 Days', trend: 'Global Top 1%', trendColor: 'text-[#FF8C42]' },
              ].map((insight, i) => (
                <div key={i} className="group cursor-pointer">
                  <p className="text-[10px] text-textMuted uppercase tracking-widest font-bold mb-1">{insight.label}</p>
                  <p className="text-lg font-bold text-white group-hover:text-[#FF6B2C] transition-colors">{insight.value}</p>
                  <p className={`text-[10px] font-bold ${insight.trendColor} mt-1 flex items-center gap-1`}>
                    <TrendingUp size={10} /> {insight.trend}
                  </p>
                  <div className="h-1 w-full bg-white/5 rounded-full mt-3 overflow-hidden">
                    <motion.div initial={{ width: 0 }} whileInView={{ width: '100%' }} className="h-full bg-white/10" />
                  </div>
                </div>
              ))}
            </div>
            <button className="w-full mt-10 py-4 rounded-2xl bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42] font-bold text-xs uppercase tracking-[0.2em] hover:bg-[#FF6B2C]/20 transition-all">Generate PDF Analysis</button>
          </motion.div>

          <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} className="glass-card p-8 rounded-[2.5rem] border-white/5 relative overflow-hidden group">
             <div className="absolute top-0 right-0 p-6 text-white opacity-5"><Zap size={100} /></div>
             <h3 className="text-lg font-bold text-white mb-2">Elite Progression</h3>
             <p className="text-xs text-textMuted mb-8 leading-relaxed">Your productivity velocity has increased by <span className="text-white font-bold">14%</span> since implementing the 'Morning Protocol'.</p>
             <div className="space-y-4">
               <div className="flex items-center justify-between text-[10px] font-bold uppercase tracking-widest text-textMuted">
                 <span>Rank Progress</span>
                 <span>72%</span>
               </div>
               <div className="h-2 w-full bg-white/5 rounded-full overflow-hidden">
                 <motion.div initial={{ width: 0 }} whileInView={{ width: '72%' }} className="h-full bg-gradient-to-r from-[#FF6B2C] to-[#FFB347]" />
               </div>
             </div>
          </motion.div>
        </div>
      </div>
    </div>
  );
}
