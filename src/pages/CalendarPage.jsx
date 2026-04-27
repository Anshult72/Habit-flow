import { useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  format, getDaysInMonth, startOfMonth, addDays, getDay,
  isSameMonth, subMonths, addMonths, isToday, subDays
} from 'date-fns';
import { ChevronLeft, ChevronRight, Calendar as CalendarIcon, X, FileText, Monitor, Flame, LayoutGrid, Table } from 'lucide-react';
import toast from 'react-hot-toast';
import useStore from '../store/useStore';

const WEEKDAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

export default function CalendarPage() {
  const {
    habits, completions, toggleCompletion,
    selectedMonth, selectedYear, setSelectedMonth, setSelectedYear,
    addXP, notes, setNote, screenTime, setScreenTime
  } = useStore();

  const [selectedDate, setSelectedDate] = useState(null);
  const [noteContent, setNoteContent] = useState('');
  const [screenHours, setScreenHours] = useState(0);
  const [viewMode, setViewMode] = useState('grid'); // 'grid' | 'table'

  const currentDate = new Date(selectedYear, selectedMonth, 1);

  const handlePrevMonth = () => {
    const prev = subMonths(currentDate, 1);
    setSelectedMonth(prev.getMonth());
    setSelectedYear(prev.getFullYear());
  };
  const handleNextMonth = () => {
    const next = addMonths(currentDate, 1);
    setSelectedMonth(next.getMonth());
    setSelectedYear(next.getFullYear());
  };
  const handleToday = () => {
    setSelectedMonth(new Date().getMonth());
    setSelectedYear(new Date().getFullYear());
  };

  const daysInMonth = getDaysInMonth(currentDate);
  const monthStart = startOfMonth(currentDate);
  const startDayOfWeek = getDay(monthStart); // 0=Sun

  // Grid cells: padding + actual days
  const calendarCells = useMemo(() => {
    const cells = [];
    for (let i = 0; i < startDayOfWeek; i++) cells.push(null);
    for (let d = 1; d <= daysInMonth; d++) {
      const date = new Date(selectedYear, selectedMonth, d);
      const dateStr = format(date, 'yyyy-MM-dd');
      const completedHabits = habits.filter(h => completions[`${h.id}-${dateStr}`]);
      const completionPct = habits.length > 0 ? completedHabits.length / habits.length : 0;
      cells.push({ date, dateStr, d, completedHabits, completionPct });
    }
    return cells;
  }, [selectedYear, selectedMonth, habits, completions, daysInMonth, startDayOfWeek]);

  // Streak data
  const streakMap = useMemo(() => {
    const map = {};
    const today = new Date();
    for (let d = 365; d >= 0; d--) {
      const date = subDays(today, d);
      const dStr = format(date, 'yyyy-MM-dd');
      map[dStr] = habits.some(h => completions[`${h.id}-${dStr}`]);
    }
    return map;
  }, [completions, habits]);

  const todayStr = format(new Date(), 'yyyy-MM-dd');

  const handleToggle = (habitId, dateStr) => {
    toggleCompletion(habitId, dateStr);
    if (!completions[`${habitId}-${dateStr}`]) addXP(15);
    else addXP(-15);
  };

  const openDayModal = (dateStr) => {
    setSelectedDate(dateStr);
    setNoteContent(notes[dateStr] || '');
    setScreenHours(screenTime[dateStr] || 0);
  };

  const saveDayData = (e) => {
    e.preventDefault();
    setNote(selectedDate, noteContent);
    setScreenTime(selectedDate, screenHours);
    toast.success('Daily entry saved');
    setSelectedDate(null);
  };

  // Monthly stats
  const allDaysStr = Array.from({ length: daysInMonth }, (_, i) => format(new Date(selectedYear, selectedMonth, i + 1), 'yyyy-MM-dd'));
  const perfectDays = allDaysStr.filter(d => habits.length > 0 && habits.every(h => completions[`${h.id}-${d}`])).length;
  const activeDays = allDaysStr.filter(d => habits.some(h => completions[`${h.id}-${d}`])).length;

  return (
    <div className="space-y-8 pb-10">
      {/* Header */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6 relative z-10">
        <div>
          <h1 className="text-4xl font-display font-bold text-white tracking-tight flex items-center gap-3">
            Chronology <CalendarIcon className="text-[#FF6B2C]" />
          </h1>
          <p className="text-textMuted mt-2 text-lg">Comprehensive habit tracking across time.</p>
        </div>
        {/* Controls */}
        <div className="flex items-center gap-3 flex-wrap">
          {/* View toggle */}
          <div className="flex bg-white/5 border border-white/10 rounded-xl p-1">
            <button
              onClick={() => setViewMode('grid')}
              className={`px-3 py-1.5 rounded-lg text-sm font-medium flex items-center gap-1.5 transition-all ${viewMode === 'grid' ? 'bg-[#FF6B2C] text-white shadow-[0_0_15px_rgba(255,107,44,0.4)]' : 'text-textMuted hover:text-white'}`}
            >
              <LayoutGrid size={14} /> Grid
            </button>
            <button
              onClick={() => setViewMode('table')}
              className={`px-3 py-1.5 rounded-lg text-sm font-medium flex items-center gap-1.5 transition-all ${viewMode === 'table' ? 'bg-[#FF6B2C] text-white shadow-[0_0_15px_rgba(255,107,44,0.4)]' : 'text-textMuted hover:text-white'}`}
            >
              <Table size={14} /> Table
            </button>
          </div>
          {/* Month nav */}
          <div className="flex items-center gap-2 bg-white/5 border border-white/10 rounded-xl p-1">
            <button onClick={handlePrevMonth} className="p-2 hover:bg-white/10 rounded-lg transition-colors text-white">
              <ChevronLeft size={18} />
            </button>
            <span className="font-display font-bold text-white px-3 min-w-[140px] text-center">
              {format(currentDate, 'MMMM yyyy')}
            </span>
            <button onClick={handleNextMonth} className="p-2 hover:bg-white/10 rounded-lg transition-colors text-white">
              <ChevronRight size={18} />
            </button>
          </div>
          <button
            onClick={handleToday}
            className="px-4 py-2 bg-white/5 border border-white/10 hover:border-[#FF6B2C]/50 rounded-xl text-white text-sm font-medium transition-all"
          >
            Today
          </button>
        </div>
      </div>

      {/* Monthly Stats Row */}
      <div className="grid grid-cols-3 gap-4 relative z-10">
        {[
          { label: 'Active Days', value: activeDays, suffix: `/${daysInMonth}`, color: '#FF6B2C' },
          { label: 'Perfect Days', value: perfectDays, suffix: ' days', color: '#22c55e' },
          { label: 'Completion', value: daysInMonth > 0 ? Math.round((activeDays / daysInMonth) * 100) : 0, suffix: '%', color: '#eab308' },
        ].map((stat, i) => (
          <motion.div
            key={i}
            initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.08 }}
            className="glass-card p-5 rounded-2xl border border-white/5 text-center"
          >
            <p className="text-[10px] text-textMuted uppercase tracking-widest mb-2">{stat.label}</p>
            <p className="text-3xl font-display font-bold" style={{ color: stat.color }}>
              {stat.value}<span className="text-sm text-textMuted">{stat.suffix}</span>
            </p>
          </motion.div>
        ))}
      </div>

      {/* Calendar Grid View */}
      <AnimatePresence mode="wait">
        {viewMode === 'grid' && (
          <motion.div key="grid" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="relative z-10">
            <div className="glass-card rounded-3xl border border-white/5 overflow-hidden">
              {/* Weekday headers */}
              <div className="grid grid-cols-7 border-b border-white/5">
                {WEEKDAYS.map(day => (
                  <div key={day} className="py-3 text-center text-[11px] font-bold text-textMuted uppercase tracking-widest">
                    {day}
                  </div>
                ))}
              </div>
              {/* Day cells */}
              <div className="grid grid-cols-7">
                {calendarCells.map((cell, i) => {
                  if (!cell) return <div key={`empty-${i}`} className="border-b border-r border-white/[0.04] min-h-[80px]" />;
                  const isCurrentDay = cell.dateStr === todayStr;
                  const hasNote = !!notes[cell.dateStr];
                  const hasScreen = (screenTime[cell.dateStr] || 0) > 0;
                  const pct = cell.completionPct;

                  return (
                    <motion.div
                      key={cell.dateStr}
                      whileHover={{ scale: 1.02, zIndex: 10 }}
                      onClick={() => openDayModal(cell.dateStr)}
                      className={`relative border-b border-r border-white/[0.04] min-h-[80px] p-2 cursor-pointer transition-colors group
                        ${isCurrentDay ? 'bg-[#FF6B2C]/10' : 'hover:bg-white/[0.03]'}
                        ${(i + 1) % 7 === 0 ? 'border-r-0' : ''}
                      `}
                    >
                      {/* Day number */}
                      <div className={`flex items-center justify-center w-7 h-7 rounded-full mb-1 text-sm font-bold transition-all
                        ${isCurrentDay ? 'bg-[#FF6B2C] text-white shadow-[0_0_12px_rgba(255,107,44,0.6)]' : 'text-white/80 group-hover:text-white'}
                      `}>
                        {cell.d}
                      </div>

                      {/* Completion fill bar */}
                      {pct > 0 && (
                        <div className="absolute bottom-0 left-0 right-0 h-[3px]">
                          <div
                            className="h-full transition-all duration-500"
                            style={{
                              width: `${pct * 100}%`,
                              background: pct === 1 ? 'linear-gradient(90deg,#22c55e,#16a34a)' : 'linear-gradient(90deg,#FF6B2C,#FFB347)',
                              boxShadow: pct === 1 ? '0 0 8px rgba(34,197,94,0.6)' : '0 0 8px rgba(255,107,44,0.4)'
                            }}
                          />
                        </div>
                      )}

                      {/* Habit dots */}
                      {cell.completedHabits.length > 0 && (
                        <div className="flex flex-wrap gap-0.5 mt-1">
                          {cell.completedHabits.slice(0, 4).map(h => (
                            <div
                              key={h.id}
                              className="w-2 h-2 rounded-full"
                              style={{ backgroundColor: h.color, boxShadow: `0 0 4px ${h.color}` }}
                            />
                          ))}
                          {cell.completedHabits.length > 4 && (
                            <span className="text-[9px] text-textMuted">+{cell.completedHabits.length - 4}</span>
                          )}
                        </div>
                      )}

                      {/* Indicators */}
                      <div className="absolute top-1.5 right-1.5 flex gap-0.5">
                        {hasNote && <div className="w-1.5 h-1.5 rounded-full bg-[#FF8C42]" title="Has note" />}
                        {hasScreen && <div className="w-1.5 h-1.5 rounded-full bg-white/40" title="Has screen time" />}
                        {pct === 1 && <div className="w-1.5 h-1.5 rounded-full bg-green-400" title="Perfect day" />}
                      </div>
                    </motion.div>
                  );
                })}
              </div>
            </div>

            {/* Legend */}
            <div className="flex gap-6 mt-4 text-xs text-textMuted flex-wrap">
              <div className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-[#FF6B2C]" /> Partial completion</div>
              <div className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-green-400" /> Perfect day</div>
              <div className="flex items-center gap-2"><div className="w-1.5 h-1.5 rounded-full bg-[#FF8C42]" /> Note</div>
              <div className="flex items-center gap-2"><div className="w-1.5 h-1.5 rounded-full bg-white/40" /> Screen time logged</div>
            </div>
          </motion.div>
        )}

        {/* Table View */}
        {viewMode === 'table' && (
          <motion.div key="table" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="relative z-10">
            <div className="glass-card rounded-3xl border border-white/5 overflow-hidden">
              <div className="overflow-x-auto">
                <table className="w-full text-sm border-collapse">
                  <thead className="bg-white/[0.02] border-b border-white/10">
                    <tr>
                      <th className="p-4 text-left font-bold text-textMuted uppercase tracking-wider text-xs w-48 sticky left-0 bg-background/90 backdrop-blur-md z-20 border-r border-white/10">Protocol</th>
                      {allDaysStr.map((d, i) => {
                        const day = new Date(selectedYear, selectedMonth, i + 1);
                        return (
                          <th
                            key={d}
                            onClick={() => openDayModal(d)}
                            className={`p-1.5 text-center min-w-[36px] border-l border-white/5 cursor-pointer hover:bg-white/5 transition-colors text-textMuted
                              ${d === todayStr ? 'bg-[#FF6B2C]/20 text-white' : ''}
                            `}
                          >
                            <div className="text-[9px] uppercase opacity-60">{format(day, 'eeeee')}</div>
                            <div className={`text-base font-display font-bold ${d === todayStr ? 'text-white' : ''}`}>{i + 1}</div>
                          </th>
                        );
                      })}
                      <th className="p-4 text-center font-bold text-textMuted uppercase tracking-wider text-xs min-w-[80px] sticky right-0 bg-background/90 backdrop-blur-md z-20 border-l border-white/10">Yield</th>
                    </tr>
                  </thead>
                  <tbody>
                    {habits.map(habit => {
                      let monthlyDone = 0;
                      return (
                        <tr key={habit.id} className="border-b border-white/5 hover:bg-white/[0.02] transition-colors group">
                          <td className="p-3 sticky left-0 bg-background/90 backdrop-blur-md z-20 border-r border-white/10 group-hover:bg-background transition-colors">
                            <div className="flex items-center gap-2">
                              <div className="w-2.5 h-2.5 rounded-full shrink-0" style={{ backgroundColor: habit.color, boxShadow: `0 0 6px ${habit.color}` }} />
                              <span className="truncate w-36 text-white font-medium text-sm">{habit.name}</span>
                            </div>
                          </td>
                          {allDaysStr.map((d, i) => {
                            const done = !!completions[`${habit.id}-${d}`];
                            if (done) monthlyDone++;
                            return (
                              <td key={d} className={`p-0.5 text-center border-l border-white/5 ${d === todayStr ? 'bg-[#FF6B2C]/5' : ''}`}>
                                <motion.button
                                  whileTap={{ scale: 0.7 }}
                                  onClick={() => handleToggle(habit.id, d)}
                                  className={`w-7 h-7 rounded-lg mx-auto flex items-center justify-center transition-all ${done ? '' : 'bg-white/[0.03] hover:bg-white/10 border border-white/5'}`}
                                  style={done ? { backgroundColor: habit.color, boxShadow: `0 0 8px ${habit.color}80` } : {}}
                                >
                                  {done && <motion.div initial={{ scale: 0 }} animate={{ scale: 1 }} className="w-2 h-2 rounded-sm bg-white" />}
                                </motion.button>
                              </td>
                            );
                          })}
                          <td className="p-3 text-center sticky right-0 bg-background/90 backdrop-blur-md z-20 border-l border-white/10 group-hover:bg-background transition-colors">
                            <span className={`font-display font-bold text-lg ${monthlyDone >= habit.goal ? 'text-green-400' : 'text-white'}`}>{monthlyDone}</span>
                            <span className="text-[10px] text-textMuted block">/{habit.goal}</span>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Day Modal */}
      <AnimatePresence>
        {selectedDate && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <motion.div
              initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              className="absolute inset-0 bg-black/70 backdrop-blur-xl"
              onClick={() => setSelectedDate(null)}
            />
            <motion.div
              initial={{ opacity: 0, scale: 0.92, y: 24 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.92, y: 24 }}
              transition={{ type: 'spring', stiffness: 280, damping: 28 }}
              className="glass-card border border-white/10 rounded-3xl p-8 w-full max-w-lg relative z-10 shadow-2xl"
            >
              <div className="absolute top-0 right-0 w-64 h-64 bg-[#FF6B2C]/10 rounded-full blur-[80px] pointer-events-none -z-10" />

              <div className="flex justify-between items-start mb-8">
                <div>
                  <h2 className="text-2xl font-display font-bold text-white">Daily Log</h2>
                  <p className="text-[#FF8C42] font-bold mt-1">{format(new Date(selectedDate + 'T12:00:00'), 'EEEE, MMMM do')}</p>
                </div>
                <button onClick={() => setSelectedDate(null)} className="text-textMuted hover:text-white p-2 rounded-full hover:bg-white/5 transition-colors">
                  <X size={22} />
                </button>
              </div>

              {/* Habit completions for the day */}
              <div className="mb-6">
                <p className="text-xs text-textMuted font-bold uppercase tracking-widest mb-3">Habits</p>
                <div className="space-y-2">
                  {habits.map(h => {
                    const done = !!completions[`${h.id}-${selectedDate}`];
                    return (
                      <motion.button
                        key={h.id}
                        whileTap={{ scale: 0.97 }}
                        onClick={() => handleToggle(h.id, selectedDate)}
                        className={`w-full flex items-center gap-3 p-3 rounded-xl border transition-all text-left ${done ? 'border-[#FF6B2C]/40 bg-[#FF6B2C]/5' : 'border-white/5 hover:border-white/20 bg-white/[0.02]'}`}
                      >
                        <div className={`w-5 h-5 rounded-md flex items-center justify-center ${done ? 'bg-[#FF6B2C]' : 'border border-white/20'}`}>
                          {done && <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12" /></svg>}
                        </div>
                        <span className={`text-sm font-medium ${done ? 'text-white/50 line-through' : 'text-white'}`}>{h.name}</span>
                        <div className="ml-auto w-2 h-2 rounded-full" style={{ backgroundColor: h.color }} />
                      </motion.button>
                    );
                  })}
                </div>
              </div>

              <form onSubmit={saveDayData} className="space-y-5">
                <div>
                  <label className="flex items-center gap-2 text-xs font-bold mb-2 text-textMuted uppercase tracking-widest">
                    <FileText size={14} /> Daily Reflection
                  </label>
                  <textarea
                    value={noteContent}
                    onChange={e => setNoteContent(e.target.value)}
                    rows={3}
                    className="w-full bg-black/40 border border-white/10 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-[#FF6B2C] transition-all text-sm placeholder:text-textMuted/40 resize-none"
                    placeholder="What went well? What challenged you today..."
                  />
                </div>
                <div>
                  <label className="flex items-center gap-2 text-xs font-bold mb-2 text-textMuted uppercase tracking-widest">
                    <Monitor size={14} /> Screen Time (hours)
                  </label>
                  <input
                    type="number" step="0.5" min="0" max="24"
                    value={screenHours}
                    onChange={e => setScreenHours(parseFloat(e.target.value) || 0)}
                    className="w-full bg-black/40 border border-white/10 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-[#FF6B2C] transition-all font-display text-xl"
                  />
                  <div className="mt-2 h-1.5 w-full bg-white/5 rounded-full overflow-hidden">
                    <div
                      className="h-full transition-all duration-500"
                      style={{
                        width: `${Math.min((screenHours / 12) * 100, 100)}%`,
                        background: screenHours <= 3 ? '#22c55e' : screenHours <= 6 ? '#eab308' : '#ef4444'
                      }}
                    />
                  </div>
                </div>
                <button
                  type="submit"
                  className="w-full py-3 rounded-xl bg-white text-black font-bold hover:bg-gray-100 transition-colors shadow-[0_0_20px_rgba(255,255,255,0.2)]"
                >
                  Save Entry
                </button>
              </form>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
