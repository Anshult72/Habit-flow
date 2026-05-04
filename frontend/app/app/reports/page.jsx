'use client';

import { useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  FileText, TrendingUp, Calendar, Zap, 
  ArrowUpRight, ArrowDownRight, Activity, 
  Filter, Download, Share2, Sparkles, Brain,
  ChevronRight, Target, Clock, Trophy, IndianRupee,
  Shield, CheckCircle2, AlertCircle, BarChart3, PieChart
} from 'lucide-react';
import { 
  Chart as ChartJS, 
  CategoryScale, 
  LinearScale, 
  PointElement, 
  LineElement, 
  BarElement,
  ArcElement,
  Title, 
  Tooltip, 
  Legend, 
  Filler
} from 'chart.js';
import { Line, Bar } from 'react-chartjs-2';
import useStore from '@/store/useStore';
import { format, subDays, startOfMonth, endOfMonth, eachDayOfInterval } from 'date-fns';

// Register ChartJS
ChartJS.register(
  CategoryScale, 
  LinearScale, 
  PointElement, 
  LineElement, 
  BarElement,
  ArcElement,
  Title, 
  Tooltip, 
  Legend, 
  Filler
);

export default function Reports() {
  const { habits, completions, getStats, xp, level } = useStore();
  const [reportType, setReportType] = useState('weekly'); // 'weekly', 'monthly', 'yearly'
  
  const stats = getStats();

  const reportData = useMemo(() => {
    const days = reportType === 'weekly' ? 7 : 30;
    const labels = Array.from({ length: days }, (_, i) => {
      const date = subDays(new Date(), days - 1 - i);
      return format(date, reportType === 'weekly' ? 'EEE' : 'MMM d');
    });

    const completionData = Array.from({ length: days }, (_, i) => {
      const date = subDays(new Date(), days - 1 - i);
      const dateStr = format(date, 'yyyy-MM-dd');
      return habits.filter(h => completions[`${h.id}-${dateStr}`]).length;
    });

    return {
      labels,
      datasets: [
        {
          label: 'System Synchronizations',
          data: completionData,
          borderColor: '#FF6B2C',
          backgroundColor: 'rgba(255, 107, 44, 0.1)',
          fill: true,
          tension: 0.4,
          pointRadius: 4,
          pointBackgroundColor: '#FF6B2C',
          borderWidth: 3,
        }
      ]
    };
  }, [reportType, habits, completions]);

  const categoryDistribution = useMemo(() => {
    const categories = {};
    habits.forEach(h => {
      categories[h.category] = (categories[h.category] || 0) + 1;
    });

    return {
      labels: Object.keys(categories),
      datasets: [{
        data: Object.values(categories),
        backgroundColor: [
          '#FF6B2C', '#E85D04', '#FF8C42', '#fb923c', '#f97316', '#ea580c'
        ],
        borderWidth: 0,
        hoverOffset: 20
      }]
    };
  }, [habits]);

  const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: false },
      tooltip: {
        backgroundColor: '#111',
        titleFont: { size: 14, weight: 'bold' },
        bodyFont: { size: 13 },
        padding: 12,
        cornerRadius: 8,
        displayColors: false
      }
    },
    scales: {
      x: {
        grid: { display: false, drawBorder: false },
        ticks: { color: 'rgba(255,255,255,0.3)', font: { size: 10, weight: 'bold' } }
      },
      y: {
        grid: { color: 'rgba(255,255,255,0.05)', drawBorder: false },
        ticks: { color: 'rgba(255,255,255,0.3)', font: { size: 10 } }
      }
    }
  };

  return (
    <div className="min-h-screen text-white pt-6 pb-24 px-4 md:px-10">
      <div className="max-w-7xl mx-auto space-y-12">
        
        {/* Header Section */}
        <div className="flex flex-col xl:flex-row justify-between items-start xl:items-center gap-8">
          <div className="space-y-2">
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              className="flex items-center gap-4"
            >
              <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-[#FF6B2C] to-[#E85D04] flex items-center justify-center shadow-[0_0_30px_rgba(255,107,44,0.4)]">
                <BarChart3 className="text-white" size={28} />
              </div>
              <div>
                <h1 className="text-4xl md:text-5xl font-display font-black tracking-tight text-white">System Intelligence</h1>
                <p className="text-textMuted uppercase tracking-[0.3em] text-[10px] font-bold">Comprehensive Performance Audit</p>
              </div>
            </motion.div>
          </div>

          <div className="flex flex-wrap items-center gap-4 w-full xl:w-auto">
            <div className="flex items-center gap-1 bg-white/5 p-1.5 rounded-2xl border border-white/10 backdrop-blur-xl">
              {['weekly', 'monthly', 'yearly'].map(type => (
                <button
                  key={type}
                  onClick={() => setReportType(type)}
                  className={`px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all ${
                    reportType === type ? 'bg-[#FF6B2C] text-white shadow-lg' : 'text-white/30 hover:text-white'
                  }`}
                >
                  {type}
                </button>
              ))}
            </div>
            
            <motion.button
              whileHover={{ scale: 1.02 }}
              className="px-6 py-3.5 rounded-2xl bg-white/5 border border-white/10 text-white font-bold flex items-center gap-2 hover:bg-white/10 transition-all"
            >
              <Download size={18} className="text-[#FF6B2C]" />
              <span className="text-xs uppercase tracking-widest">Export intelligence</span>
            </motion.button>
          </div>
        </div>

        {/* Global Efficiency Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {[
            { label: 'Overall Efficiency', value: '87.4%', icon: Activity, color: 'text-success', trend: '+4.2%' },
            { label: 'Total Yield', value: `${xp.toLocaleString()}`, icon: Zap, color: 'text-[#FF8C42]', trend: '+1.2k' },
            { label: 'Sync Consistency', value: '14 Days', icon: Shield, color: 'text-blue-400', trend: 'Stable' },
            { label: 'Active Protocols', value: habits.length, icon: Target, color: 'text-purple-400', trend: '+2' }
          ].map((stat, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.1 }}
              className="glass-card p-8 rounded-3xl border-white/5 relative overflow-hidden group"
            >
              <div className="absolute top-0 right-0 p-6 opacity-5 group-hover:opacity-10 transition-opacity">
                <stat.icon size={60} />
              </div>
              <div className="relative z-10 space-y-4">
                <div className="flex justify-between items-start">
                  <div className={`w-10 h-10 rounded-xl bg-white/5 flex items-center justify-center ${stat.color}`}>
                    <stat.icon size={20} />
                  </div>
                  <span className={`text-[10px] font-black uppercase tracking-widest ${stat.trend.startsWith('+') ? 'text-success' : 'text-textMuted'}`}>
                    {stat.trend}
                  </span>
                </div>
                <div>
                  <p className="text-[10px] text-textMuted uppercase font-black tracking-[0.2em]">{stat.label}</p>
                  <p className="text-3xl font-display font-bold text-white mt-1">{stat.value}</p>
                </div>
              </div>
            </motion.div>
          ))}
        </div>

        <div className="glass-card p-10 rounded-[2.5rem] border-white/5 flex flex-col space-y-8 h-[500px]">
            <div className="flex items-center justify-between">
              <div className="space-y-1">
                <h3 className="text-xl font-display font-bold text-white tracking-tight">Performance Trajectory</h3>
                <p className="text-[10px] text-textMuted uppercase font-black tracking-widest">Protocol Sync Frequency</p>
              </div>
              <div className="flex items-center gap-6">
                <div className="flex items-center gap-2">
                  <div className="w-2.5 h-2.5 rounded-full bg-[#FF6B2C]" />
                  <span className="text-[10px] font-bold text-white/40 uppercase tracking-widest">Active Syncs</span>
                </div>
              </div>
            </div>
            <div className="flex-1">
              <Line data={reportData} options={chartOptions} />
            </div>
          </div>

        {/* Tactical Log */}
        <div className="glass-card p-10 rounded-[2.5rem] border-white/5 space-y-8">
          <div className="flex items-center justify-between">
            <div className="space-y-1">
              <h3 className="text-2xl font-display font-bold text-white tracking-tight">Intelligence Log</h3>
              <p className="text-[10px] text-textMuted uppercase font-black tracking-widest">Recent System Events</p>
            </div>
            <button className="p-3 rounded-xl bg-white/5 text-white/20 hover:text-white transition-all">
              <Filter size={20} />
            </button>
          </div>

          <div className="space-y-4">
            {[
              { type: 'milestone', msg: 'Rank Up achieved: Level 12 reached.', time: '2h ago', icon: Trophy, color: 'text-warning' },
              { type: 'sync', msg: 'Elite Protocol "Monk Mode" completed with 100% efficiency.', time: '5h ago', icon: Zap, color: 'text-[#FF8C42]' },
              { type: 'alert', msg: 'Protocol "Hydration" streak at critical risk (24h remaining).', time: '8h ago', icon: AlertCircle, color: 'text-red-400' },
              { type: 'intelligence', msg: 'AI detected 14% efficiency increase in Morning Routines.', time: '1d ago', icon: Brain, color: 'text-purple-400' }
            ].map((log, i) => (
              <div key={i} className="flex items-center gap-6 p-6 rounded-2xl bg-white/[0.02] border border-white/5 hover:border-white/10 transition-all group">
                <div className={`w-12 h-12 rounded-xl bg-white/5 flex items-center justify-center ${log.color} group-hover:scale-110 transition-transform`}>
                  <log.icon size={22} />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-bold text-white">{log.msg}</p>
                  <p className="text-[10px] text-textMuted uppercase font-black tracking-widest mt-1">{log.time} • System Audit</p>
                </div>
                <button className="opacity-0 group-hover:opacity-100 p-2 text-white/20 hover:text-white transition-all">
                  <ChevronRight size={18} />
                </button>
              </div>
            ))}
          </div>
        </div>

      </div>
    </div>
  );
}
