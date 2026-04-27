import { useState, useMemo } from 'react';
import { format, getDaysInMonth, startOfMonth, addDays } from 'date-fns';
import { ChevronLeft, ChevronRight, Calendar as CalendarIcon, X, FileText, Monitor } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import toast from 'react-hot-toast';
import useStore from '../store/useStore';

export default function CalendarPage() {
  const { habits, completions, toggleCompletion, selectedMonth, selectedYear, setSelectedMonth, setSelectedYear, addXP, notes, setNote, screenTime, setScreenTime } = useStore();
  const [selectedDate, setSelectedDate] = useState(null);
  const [noteContent, setNoteContent] = useState('');
  const [screenHours, setScreenHours] = useState(0);

  const handlePrevMonth = () => {
    if (selectedMonth === 0) {
      setSelectedMonth(11);
      setSelectedYear(selectedYear - 1);
    } else {
      setSelectedMonth(selectedMonth - 1);
    }
  };

  const handleNextMonth = () => {
    if (selectedMonth === 11) {
      setSelectedMonth(0);
      setSelectedYear(selectedYear + 1);
    } else {
      setSelectedMonth(selectedMonth + 1);
    }
  };

  const daysInMonth = getDaysInMonth(new Date(selectedYear, selectedMonth));
  const monthStart = startOfMonth(new Date(selectedYear, selectedMonth));
  
  const days = useMemo(() => {
    return Array.from({ length: daysInMonth }).map((_, i) => {
      const date = addDays(monthStart, i);
      return {
        date,
        dayNum: format(date, 'd'),
        dayName: format(date, 'eeeee'),
        dateStr: format(date, 'yyyy-MM-dd')
      };
    });
  }, [daysInMonth, monthStart]);

  const handleToggle = (habitId, dateStr) => {
    toggleCompletion(habitId, dateStr);
    if (!completions[`${habitId}-${dateStr}`]) {
      addXP(15);
    } else {
      addXP(-15);
    }
  };

  const openDayModal = (dateStr) => {
    setSelectedDate(dateStr);
    setNoteContent(notes[dateStr] || '');
    setScreenHours(screenTime[dateStr] || 0);
  };

  const saveDayData = (e) => {
    e.preventDefault();
    if (selectedDate) {
      setNote(selectedDate, noteContent);
      setScreenTime(selectedDate, screenHours);
      toast.success('Daily data saved');
      setSelectedDate(null);
    }
  };

  const todayStr = format(new Date(), 'yyyy-MM-dd');

  return (
    <div className="space-y-8 pb-10">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6 relative z-10">
        <div>
          <h1 className="text-4xl font-display font-bold text-white tracking-tight flex items-center gap-3">
            Chronology <CalendarIcon className="text-primary" />
          </h1>
          <p className="text-textMuted mt-2 text-lg">Comprehensive tracking over extended intervals.</p>
        </div>
        
        <div className="glass-panel p-2 rounded-2xl flex items-center gap-4">
          <button onClick={handlePrevMonth} className="p-2 hover:bg-white/10 rounded-xl transition-colors text-white">
            <ChevronLeft size={20} />
          </button>
          <div className="w-48 text-center font-display font-bold text-xl text-white tracking-wide">
            {format(new Date(selectedYear, selectedMonth), 'MMMM yyyy')}
          </div>
          <button onClick={handleNextMonth} className="p-2 hover:bg-white/10 rounded-xl transition-colors text-white">
            <ChevronRight size={20} />
          </button>
        </div>
      </div>

      <div className="glass-card rounded-3xl overflow-hidden shadow-2xl relative">
        <div className="absolute top-0 right-1/4 w-96 h-96 bg-primary/10 rounded-full blur-[100px] pointer-events-none" />
        <div className="overflow-x-auto relative z-10">
          <table className="w-full text-sm text-left border-collapse">
            <thead className="bg-white/[0.02] border-b border-white/10">
              <tr>
                <th className="p-5 font-display text-textMuted uppercase tracking-wider w-56 sticky left-0 bg-background/90 backdrop-blur-md z-20 border-r border-white/10">Protocol</th>
                {days.map((day, i) => (
                  <th 
                    key={i} 
                    onClick={() => openDayModal(day.dateStr)}
                    className={`p-2 text-center min-w-[44px] border-l border-white/5 cursor-pointer hover:bg-white/5 transition-colors ${day.dateStr === todayStr ? 'bg-primary/20 text-white' : 'text-textMuted'}`}
                  >
                    <div className="text-[10px] uppercase tracking-widest mb-1 opacity-70">{day.dayName}</div>
                    <div className={`font-display text-lg ${day.dateStr === todayStr ? 'font-bold' : 'font-medium'}`}>{day.dayNum}</div>
                    <div className="flex justify-center gap-1 mt-1">
                      {notes[day.dateStr] && <div className="w-1.5 h-1.5 rounded-full bg-[#FF8C42]" />}
                      {screenTime[day.dateStr] > 0 && <div className="w-1.5 h-1.5 rounded-full bg-white/50" />}
                    </div>
                  </th>
                ))}
                <th className="p-5 font-display text-textMuted uppercase tracking-wider text-center min-w-[100px] sticky right-0 bg-background/90 backdrop-blur-md z-20 border-l border-white/10">Yield</th>
              </tr>
            </thead>
            <tbody>
              {habits.map((habit) => {
                let monthlyCompleted = 0;
                
                return (
                  <tr key={habit.id} className="border-b border-white/5 hover:bg-white/[0.02] transition-colors group">
                    <td className="p-4 font-medium sticky left-0 bg-background/90 backdrop-blur-md z-20 border-r border-white/10 group-hover:bg-background transition-colors">
                      <div className="flex items-center gap-3">
                        <div className="w-3 h-3 rounded-full" style={{ backgroundColor: habit.color, boxShadow: `0 0 10px ${habit.color}` }} />
                        <span className="truncate w-40 text-white font-medium">{habit.name}</span>
                      </div>
                    </td>
                    
                    {days.map((day, i) => {
                      const isCompleted = completions[`${habit.id}-${day.dateStr}`];
                      if (isCompleted) monthlyCompleted++;
                      const isToday = day.dateStr === todayStr;

                      return (
                        <td key={i} className={`p-1 text-center border-l border-white/5 ${isToday ? 'bg-primary/5' : ''}`}>
                          <motion.button
                            whileTap={{ scale: 0.8 }}
                            onClick={() => handleToggle(habit.id, day.dateStr)}
                            className={`w-8 h-8 rounded-xl mx-auto flex items-center justify-center transition-all ${
                              isCompleted 
                                ? 'shadow-[0_0_15px_rgba(255,255,255,0.1)]' 
                                : 'bg-white/[0.03] hover:bg-white/10 border border-white/5'
                            }`}
                            style={{ 
                              backgroundColor: isCompleted ? habit.color : '',
                              color: isCompleted ? '#fff' : ''
                            }}
                          >
                            {isCompleted && (
                              <motion.div 
                                initial={{ scale: 0 }} 
                                animate={{ scale: 1 }} 
                                className="w-2.5 h-2.5 rounded-sm bg-white"
                              />
                            )}
                          </motion.button>
                        </td>
                      );
                    })}
                    
                    <td className="p-4 text-center sticky right-0 bg-background/90 backdrop-blur-md z-20 border-l border-white/10 group-hover:bg-background transition-colors">
                      <div className="flex flex-col items-center">
                        <span className={`font-display text-xl font-bold ${monthlyCompleted >= habit.goal ? 'text-success drop-shadow-[0_0_10px_rgba(16,185,129,0.5)]' : 'text-white'}`}>
                          {monthlyCompleted}
                        </span>
                        <span className="text-[10px] text-textMuted uppercase tracking-wider">/ {habit.goal} tgt</span>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>

      <AnimatePresence>
        {selectedDate && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <motion.div 
              initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              className="absolute inset-0 bg-background/80 backdrop-blur-xl"
              onClick={() => setSelectedDate(null)}
            />
            <motion.div
              initial={{ opacity: 0, scale: 0.95, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: 20 }}
              className="glass-card border border-white/10 rounded-3xl p-8 w-full max-w-md relative z-10 shadow-2xl"
            >
              <div className="flex justify-between items-center mb-8">
                <h2 className="text-2xl font-display font-bold text-white">
                  Daily Overview
                  <span className="block text-sm text-[#FF8C42] mt-1">{selectedDate}</span>
                </h2>
                <button onClick={() => setSelectedDate(null)} className="text-textMuted hover:text-white p-2 rounded-full hover:bg-white/5 transition-colors">
                  <X size={24} />
                </button>
              </div>

              <form onSubmit={saveDayData} className="space-y-6">
                <div>
                  <label className="flex items-center gap-2 text-sm font-medium mb-2 text-textMuted uppercase tracking-wide">
                    <FileText size={16} /> Reflections & Notes
                  </label>
                  <textarea
                    value={noteContent}
                    onChange={(e) => setNoteContent(e.target.value)}
                    rows={4}
                    className="w-full bg-black/40 border border-white/10 rounded-xl px-5 py-3 text-white focus:outline-none focus:border-[#FF6B2C] transition-all font-medium placeholder:text-textMuted/50 resize-none"
                    placeholder="Log your thoughts, challenges, or wins for today..."
                  />
                </div>

                <div>
                  <label className="flex items-center gap-2 text-sm font-medium mb-2 text-textMuted uppercase tracking-wide">
                    <Monitor size={16} /> Screen Time (Hours)
                  </label>
                  <input
                    type="number" step="0.5" min="0" max="24"
                    value={screenHours}
                    onChange={(e) => setScreenHours(parseFloat(e.target.value) || 0)}
                    className="w-full bg-black/40 border border-white/10 rounded-xl px-5 py-3 text-white focus:outline-none focus:border-[#FF6B2C] transition-all font-medium font-display text-xl"
                  />
                  <div className="mt-2 h-2 w-full bg-white/5 rounded-full overflow-hidden">
                    <div 
                      className="h-full bg-gradient-to-r from-success via-warning to-danger"
                      style={{ width: `${Math.min((screenHours / 12) * 100, 100)}%` }}
                    />
                  </div>
                </div>

                <div className="pt-4">
                  <button
                    type="submit"
                    className="w-full px-4 py-3 rounded-xl bg-white text-black hover:bg-gray-200 transition-colors font-bold shadow-[0_0_20px_rgba(255,255,255,0.3)]"
                  >
                    Save Entry
                  </button>
                </div>
              </form>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
