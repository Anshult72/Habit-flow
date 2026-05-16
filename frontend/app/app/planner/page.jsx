'use client';

import { useState, useEffect, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Plus, Trash2, CheckCircle2, Circle, 
  ChevronLeft, ChevronRight, Calendar as CalendarIcon,
  Clock, Zap, Layout, ArrowLeft, ArrowRight,
  TrendingUp, CheckSquare, ListTodo
} from 'lucide-react';
import { format, addDays, subDays, isSameDay } from 'date-fns';
import useStore from '@/store/useStore';

const DEFAULT_SLOTS = [
  '6 AM – 9 AM',
  '9 AM – 12 PM',
  '12 PM – 3 PM',
  '3 PM – 6 PM',
  '6 PM – 9 PM',
  '9 PM – 12 AM'
];

export default function DailyPlanner() {
  const [currentDate, setCurrentDate] = useState(new Date());
  const [plannerData, setPlannerData] = useState({}); // Keyed by date string
  const [newTask, setNewTask] = useState('');
  const [activeSlot, setActiveSlot] = useState(DEFAULT_SLOTS[0]);

  // Load data from local storage on mount
  useEffect(() => {
    const saved = localStorage.getItem('habitflow-planner-data');
    if (saved) {
      setTimeout(() => setPlannerData(JSON.parse(saved)), 0);
    }
  }, []);

  // Save data to local storage when it changes
  useEffect(() => {
    if (Object.keys(plannerData).length > 0) {
      localStorage.setItem('habitflow-planner-data', JSON.stringify(plannerData));
    }
  }, [plannerData]);

  const dateKey = format(currentDate, 'yyyy-MM-dd');
  const currentDayData = useMemo(() => {
    return plannerData[dateKey] || {
      date: dateKey,
      slots: DEFAULT_SLOTS.map(range => ({ timeRange: range, tasks: [] }))
    };
  }, [plannerData, dateKey]);

  const addTask = (slotRange) => {
    if (!newTask.trim()) return;
    
    const updatedSlots = currentDayData.slots.map(slot => {
      if (slot.timeRange === slotRange) {
        return {
          ...slot,
          tasks: [...slot.tasks, { id: Math.random().toString(36).substr(2, 9), title: newTask, completed: false }]
        };
      }
      return slot;
    });

    setPlannerData({
      ...plannerData,
      [dateKey]: { ...currentDayData, slots: updatedSlots }
    });
    setNewTask('');
  };

  const toggleTask = (slotRange, taskId) => {
    const updatedSlots = currentDayData.slots.map(slot => {
      if (slot.timeRange === slotRange) {
        return {
          ...slot,
          tasks: slot.tasks.map(t => t.id === taskId ? { ...t, completed: !t.completed } : t)
        };
      }
      return slot;
    });

    setPlannerData({
      ...plannerData,
      [dateKey]: { ...currentDayData, slots: updatedSlots }
    });
  };

  const deleteTask = (slotRange, taskId) => {
    const updatedSlots = currentDayData.slots.map(slot => {
      if (slot.timeRange === slotRange) {
        return {
          ...slot,
          tasks: slot.tasks.filter(t => t.id !== taskId)
        };
      }
      return slot;
    });

    setPlannerData({
      ...plannerData,
      [dateKey]: { ...currentDayData, slots: updatedSlots }
    });
  };

  const totalTasks = currentDayData.slots.reduce((acc, s) => acc + s.tasks.length, 0);
  const completedTasks = currentDayData.slots.reduce((acc, s) => acc + s.tasks.filter(t => t.completed).length, 0);
  const progress = totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0;

  return (
    <div className="space-y-10 pb-20">
      {/* Header & Date Navigation */}
      <div className="flex flex-col lg:flex-row justify-between items-start lg:items-center gap-8 bg-white/5 p-8 rounded-[2.5rem] border border-white/10">
        <div className="space-y-2">
          <div className="flex items-center gap-3">
            <div className="p-2 rounded-xl bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42]">
              <CalendarIcon size={20} />
            </div>
            <span className="text-[10px] font-black uppercase tracking-[0.3em] text-[#FF8C42]">Strategic Planning</span>
          </div>
          <h1 className="text-4xl font-display font-black text-white tracking-tight">Daily Protocol</h1>
          <p className="text-text-muted text-sm max-w-md">Orchestrate your day with high-precision time blocks and mission objectives.</p>
        </div>

        <div className="flex flex-col items-center gap-4">
          <div className="flex items-center gap-4 bg-black/40 p-2 rounded-2xl border border-white/5">
            <button 
              onClick={() => setCurrentDate(subDays(currentDate, 1))}
              className="p-3 rounded-xl hover:bg-white/5 text-white/40 hover:text-white transition-all flex items-center gap-2 group"
            >
              <ChevronLeft size={20} className="group-hover:-translate-x-1 transition-transform" />
              <span className="text-[10px] font-bold uppercase tracking-widest hidden md:inline">Yesterday</span>
            </button>
            
            <div className="px-6 py-2 text-center min-w-[180px]">
              <p className="text-sm font-black text-white uppercase tracking-widest">
                {isSameDay(currentDate, new Date()) ? 'Today' : format(currentDate, 'EEEE')}
              </p>
              <p className="text-[10px] text-text-muted font-bold uppercase tracking-[0.2em]">
                {format(currentDate, 'MMMM do, yyyy')}
              </p>
            </div>

            <button 
              onClick={() => setCurrentDate(addDays(currentDate, 1))}
              className="p-3 rounded-xl hover:bg-white/5 text-white/40 hover:text-white transition-all flex items-center gap-2 group"
            >
              <span className="text-[10px] font-bold uppercase tracking-widest hidden md:inline">Tomorrow</span>
              <ChevronRight size={20} className="group-hover:translate-x-1 transition-transform" />
            </button>
          </div>
          
          <button 
            onClick={() => setCurrentDate(new Date())}
            className="text-[10px] font-black uppercase tracking-widest text-[#FF8C42] hover:text-white transition-colors"
          >
            Reset to Today
          </button>
        </div>

        <div className="hidden xl:flex flex-col items-end gap-2">
          <div className="flex items-center gap-4">
            <span className="text-[10px] font-black uppercase tracking-widest text-text-muted">Total Efficiency</span>
            <span className="text-2xl font-display font-black text-[#FF8C42]">{progress}%</span>
          </div>
          <div className="w-48 h-2 bg-white/5 rounded-full overflow-hidden border border-white/5 p-0.5">
            <motion.div 
              initial={{ width: 0 }}
              animate={{ width: `${progress}%` }}
              className="h-full bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] rounded-full shadow-[0_0_15px_rgba(255,107,44,0.3)]"
            />
          </div>
          <p className="text-[10px] text-text-muted font-bold uppercase tracking-widest">
            {completedTasks} / {totalTasks} Missions Accomplished
          </p>
        </div>
      </div>

      {/* Main Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        {currentDayData.slots.map((slot, i) => (
          <motion.div
            key={slot.timeRange}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.05 }}
            className={`group flex flex-col glass-card rounded-[2.5rem] border transition-all duration-500 overflow-hidden ${
              activeSlot === slot.timeRange ? 'border-[#FF6B2C]/50 bg-[#FF6B2C]/5' : 'border-white/5 hover:border-white/10'
            }`}
            onClick={() => setActiveSlot(slot.timeRange)}
          >
            <div className="p-8 space-y-6">
              <div className="flex justify-between items-center">
                <div className="flex items-center gap-3">
                  <div className={`p-2 rounded-xl border transition-all ${
                    activeSlot === slot.timeRange ? 'bg-[#FF6B2C] text-white border-[#FF6B2C]' : 'bg-white/5 text-white/40 border-white/10'
                  }`}>
                    <Clock size={16} />
                  </div>
                  <h3 className="text-lg font-display font-bold text-white tracking-tight">{slot.timeRange}</h3>
                </div>
                <div className="text-[10px] font-black uppercase tracking-widest text-[#FF8C42]">
                  {slot.tasks.filter(t => t.completed).length}/{slot.tasks.length}
                </div>
              </div>

              <div className="space-y-3 min-h-[120px]">
                {slot.tasks.length === 0 ? (
                  <div className="h-full flex flex-col items-center justify-center text-center py-6 opacity-20 group-hover:opacity-40 transition-opacity">
                    <ListTodo size={32} strokeWidth={1} />
                    <p className="text-[10px] uppercase font-bold tracking-widest mt-2">Zone Unallocated</p>
                  </div>
                ) : (
                  <div className="space-y-2">
                    {slot.tasks.map(task => (
                      <div 
                        key={task.id}
                        className="flex items-center justify-between p-3 rounded-xl bg-white/5 border border-white/5 group/task hover:border-[#FF6B2C]/20 transition-all"
                      >
                        <div className="flex items-center gap-3">
                          <button 
                            onClick={(e) => { e.stopPropagation(); toggleTask(slot.timeRange, task.id); }}
                            className={`transition-colors ${task.completed ? 'text-[#FF6B2C]' : 'text-white/20 hover:text-white/40'}`}
                          >
                            {task.completed ? <CheckCircle2 size={18} /> : <Circle size={18} />}
                          </button>
                          <span className={`text-xs font-medium transition-all ${task.completed ? 'text-white/20 line-through' : 'text-white/80'}`}>
                            {task.title}
                          </span>
                        </div>
                        <button 
                          onClick={(e) => { e.stopPropagation(); deleteTask(slot.timeRange, task.id); }}
                          className="opacity-0 group-hover/task:opacity-100 p-1 text-white/10 hover:text-red-500 transition-all"
                        >
                          <Trash2 size={14} />
                        </button>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              <div className="pt-4 border-t border-white/5 flex gap-2">
                <input 
                  type="text" 
                  placeholder="Allocate task..."
                  className="flex-1 bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-xs focus:outline-none focus:border-[#FF6B2C]/30 transition-all"
                  value={activeSlot === slot.timeRange ? newTask : ''}
                  onChange={(e) => setNewTask(e.target.value)}
                  onKeyPress={(e) => e.key === 'Enter' && addTask(slot.timeRange)}
                  onClick={(e) => e.stopPropagation()}
                />
                <button 
                  onClick={(e) => { e.stopPropagation(); addTask(slot.timeRange); }}
                  className="p-2 rounded-xl bg-white/5 border border-white/10 text-white/40 hover:text-white hover:bg-[#FF6B2C] hover:border-[#FF6B2C] transition-all"
                >
                  <Plus size={18} />
                </button>
              </div>
            </div>
          </motion.div>
        ))}
      </div>

      {/* Quick Summary / Insights */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 glass-card p-8 rounded-[2.5rem] border border-white/5 flex flex-col md:flex-row items-center gap-10">
          <div className="relative w-32 h-32 flex-shrink-0">
            <svg className="w-full h-full transform -rotate-90">
              <circle
                cx="64"
                cy="64"
                r="58"
                stroke="currentColor"
                strokeWidth="8"
                fill="transparent"
                className="text-white/5"
              />
              <motion.circle
                cx="64"
                cy="64"
                r="58"
                stroke="currentColor"
                strokeWidth="8"
                fill="transparent"
                strokeDasharray="364.4"
                initial={{ strokeDashoffset: 364.4 }}
                animate={{ strokeDashoffset: 364.4 - (364.4 * progress) / 100 }}
                className="text-[#FF6B2C]"
                strokeLinecap="round"
              />
            </svg>
            <div className="absolute inset-0 flex flex-col items-center justify-center">
              <span className="text-2xl font-display font-black text-white">{progress}%</span>
            </div>
          </div>
          
          <div className="space-y-4 text-center md:text-left">
            <h3 className="text-xl font-display font-bold text-white tracking-tight">Mission Continuity Analysis</h3>
            <p className="text-text-muted text-sm leading-relaxed max-w-xl">
              {progress === 100 ? 
                "Maximum efficiency attained. Your cognitive load distribution is optimal. Proceed with restorative protocols." :
                progress > 50 ? 
                "Operational momentum is high. Focused execution on remaining time slots will ensure total mission success." :
                "Strategic initiative required. Align your focus with high-impact objectives to regain system equilibrium."
              }
            </p>
            <div className="flex flex-wrap justify-center md:justify-start gap-4 pt-2">
              <div className="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-[#FF6B2C]/10 border border-[#FF6B2C]/20 text-[#FF8C42] text-[10px] font-black uppercase tracking-widest">
                <Zap size={14} /> Peak Performance
              </div>
              <div className="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-white/5 border border-white/10 text-white/40 text-[10px] font-black uppercase tracking-widest">
                <TrendingUp size={14} /> Growth Signal
              </div>
            </div>
          </div>
        </div>

        <div className="glass-card p-8 rounded-[2.5rem] border border-white/5 space-y-6">
          <div className="flex items-center gap-3">
            <div className="p-2 rounded-xl bg-blue-500/10 border border-blue-500/20 text-blue-500">
              <CheckSquare size={18} />
            </div>
            <h3 className="text-sm font-black uppercase tracking-[0.2em] text-white">Focus Points</h3>
          </div>
          <div className="space-y-4">
            <div className="p-4 rounded-2xl bg-white/5 border border-white/5 text-xs text-text-muted">
              Plan your &quot;Big Three&quot; tasks during the <span className="text-white font-bold">9 AM – 12 PM</span> window for maximum cognitive output.
            </div>
            <button className="w-full py-4 rounded-2xl bg-white/5 border border-white/10 text-white font-bold text-[10px] uppercase tracking-[0.3em] hover:bg-[#FF6B2C] hover:border-[#FF6B2C] transition-all">
              Initialize Routine
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
