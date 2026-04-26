import { useMemo } from 'react';
import { format, getDaysInMonth, startOfMonth, addDays } from 'date-fns';
import { ChevronLeft, ChevronRight, Calendar as CalendarIcon } from 'lucide-react';
import { motion } from 'framer-motion';
import useStore from '../store/useStore';

export default function CalendarPage() {
  const { habits, completions, toggleCompletion, selectedMonth, selectedYear, setSelectedMonth, setSelectedYear, addXP } = useStore();

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
                  <th key={i} className={`p-2 text-center min-w-[44px] border-l border-white/5 ${day.dateStr === todayStr ? 'bg-primary/20 text-white' : 'text-textMuted'}`}>
                    <div className="text-[10px] uppercase tracking-widest mb-1 opacity-70">{day.dayName}</div>
                    <div className={`font-display text-lg ${day.dateStr === todayStr ? 'font-bold' : 'font-medium'}`}>{day.dayNum}</div>
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
    </div>
  );
}
