import { useState, useEffect, useRef, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Zap, Clock, Play, Pause, RotateCcw, 
  Settings, History, BarChart3, Maximize2, 
  Volume2, Music, Coffee, Brain, 
  ChevronRight, CheckCircle2, Star, Target,
  Flame, Calendar, Monitor, Award, Plus, X
} from 'lucide-react';
import { format, subDays } from 'date-fns';
import useStore from '../store/useStore';
import { Line, Bar } from 'react-chartjs-2';

export default function FocusZone() {
  const { focusSessions, totalFocusMinutes, addFocusSession } = useStore();
  const [activeMode, setActiveMode] = useState('pomodoro'); // 'pomodoro', 'stopwatch', 'custom'
  const [isFullscreen, setIsFullscreen] = useState(false);

  return (
    <div className="min-h-screen bg-[#050505] text-white pb-20 relative overflow-x-hidden">
      {/* Cinematic Background */}
      <div className="fixed inset-0 pointer-events-none z-0">
        <div className="absolute top-[20%] right-[-10%] w-[60%] h-[60%] bg-[#FF6B2C]/5 rounded-full blur-[150px] animate-pulse" />
        <div className="absolute bottom-[-10%] left-[-10%] w-[40%] h-[40%] bg-[#E85D04]/3 rounded-full blur-[120px]" />
      </div>

      <div className="relative z-10 max-w-7xl mx-auto px-6 pt-12 space-y-12">
        
        {/* Hero Section */}
        <header className="text-center space-y-4">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
          >
            <h1 className="text-5xl md:text-7xl font-display font-black tracking-tighter text-transparent bg-clip-text bg-gradient-to-b from-white to-white/40">
              Enter Deep Focus.
            </h1>
            <p className="text-textMuted text-xl font-light mt-4">
              Time is your greatest weapon. Use it intentionally.
            </p>
          </motion.div>

          {/* Mode Switcher */}
          <div className="flex justify-center pt-8">
            <div className="glass-card p-1.5 rounded-2xl border-white/5 flex items-center gap-1">
              {[
                { id: 'pomodoro', label: 'Pomodoro', icon: Clock },
                { id: 'stopwatch', label: 'Stopwatch', icon: History },
                { id: 'custom', label: 'Custom Timer', icon: Zap }
              ].map((mode) => (
                <button
                  key={mode.id}
                  onClick={() => setActiveMode(mode.id)}
                  className={`flex items-center gap-2 px-6 py-3 rounded-xl text-sm font-bold transition-all relative ${
                    activeMode === mode.id ? 'text-white' : 'text-textMuted hover:text-white/60'
                  }`}
                >
                  {activeMode === mode.id && (
                    <motion.div 
                      layoutId="activeMode"
                      className="absolute inset-0 bg-[#FF6B2C] rounded-xl shadow-[0_0_20px_rgba(255,107,44,0.3)]"
                    />
                  )}
                  <mode.icon size={16} className="relative z-10" />
                  <span className="relative z-10">{mode.label}</span>
                </button>
              ))}
            </div>
          </div>
        </header>

        {/* Main Content Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
          
          {/* Left Column: Timer Area */}
          <div className="lg:col-span-8 space-y-8">
            <AnimatePresence mode="wait">
              {activeMode === 'pomodoro' && (
                <motion.div
                  key="pomodoro"
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.95 }}
                  className="glass-card p-12 rounded-[3rem] border-white/5 flex flex-col items-center text-center space-y-10 relative overflow-hidden"
                >
                  <div className="absolute top-0 right-0 p-8 opacity-5">
                    <Clock size={200} />
                  </div>
                  <PomodoroTimer onSessionComplete={addFocusSession} />
                  <button 
                    onClick={() => setIsFullscreen(true)}
                    className="absolute bottom-10 right-10 p-4 rounded-full bg-white/5 border border-white/10 text-white/20 hover:text-white transition-all"
                  >
                    <Maximize2 size={24} />
                  </button>
                </motion.div>
              )}
              {activeMode === 'stopwatch' && (
                <motion.div
                  key="stopwatch"
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.95 }}
                  className="glass-card p-12 rounded-[3rem] border-white/5 flex flex-col items-center text-center space-y-10"
                >
                  <Stopwatch onSessionComplete={addFocusSession} />
                </motion.div>
              )}
              {activeMode === 'custom' && (
                <motion.div
                  key="custom"
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.95 }}
                  className="glass-card p-12 rounded-[3rem] border-white/5 flex flex-col items-center text-center space-y-10"
                >
                  <CustomTimer onSessionComplete={addFocusSession} />
                </motion.div>
              )}
            </AnimatePresence>

            {/* Quick Stats Grid */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
              {[
                { label: 'Focus Today', value: '124m', icon: Clock, color: '#FF6B2C' },
                { label: 'Sessions', value: '5', icon: Target, color: '#3B82F6' },
                { label: 'Current Streak', value: '4 Days', icon: Flame, color: '#FFD700' },
                { label: 'Total XP', value: '840', icon: Zap, color: '#E85D04' }
              ].map((stat, i) => (
                <div key={i} className="glass-card p-6 rounded-2xl border-white/5 space-y-2">
                  <stat.icon size={18} style={{ color: stat.color }} />
                  <p className="text-2xl font-display font-bold text-white">{stat.value}</p>
                  <p className="text-[10px] text-textMuted uppercase tracking-widest font-bold">{stat.label}</p>
                </div>
              ))}
            </div>
          </div>

          {/* Right Column: Insights & History */}
          <aside className="lg:col-span-4 space-y-8">
            {/* Music/Ambience Selector */}
            <div className="glass-card p-8 rounded-3xl border-white/5 space-y-6">
              <h3 className="text-sm font-bold text-white uppercase tracking-widest flex items-center gap-2">
                <Music size={16} className="text-[#FF6B2C]" /> Ambience
              </h3>
              <div className="grid grid-cols-2 gap-3">
                {[
                  { label: 'Lo-Fi Chill', icon: Coffee },
                  { label: 'Deep Rain', icon: Volume2 },
                  { label: 'Focus Flow', icon: Brain },
                  { label: 'Library', icon: History }
                ].map((item, i) => (
                  <button key={i} className="flex flex-col items-center justify-center p-4 rounded-2xl bg-white/5 border border-white/10 hover:border-[#FF6B2C]/30 hover:bg-[#FF6B2C]/5 transition-all group">
                    <item.icon size={20} className="text-white/20 group-hover:text-[#FF6B2C] mb-2" />
                    <span className="text-[10px] font-bold text-white/40 group-hover:text-white uppercase tracking-widest">{item.label}</span>
                  </button>
                ))}
              </div>
            </div>

            {/* Focus Analytics Mini Chart */}
            <div className="glass-card p-8 rounded-3xl border-white/5 space-y-6">
              <div className="flex items-center justify-between">
                <h3 className="text-sm font-bold text-white uppercase tracking-widest flex items-center gap-2">
                  <BarChart3 size={16} className="text-blue-400" /> Efficiency
                </h3>
                <span className="text-[10px] text-success font-black">+14%</span>
              </div>
              <div className="h-32">
                <Bar 
                  data={{
                    labels: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
                    datasets: [{
                      data: [45, 60, 90, 120, 80, 40, 30],
                      backgroundColor: 'rgba(255,107,44,0.3)',
                      borderRadius: 4
                    }]
                  }}
                  options={{
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                      x: { display: false },
                      y: { display: false }
                    }
                  }}
                />
              </div>
              <p className="text-[10px] text-textMuted text-center font-medium">Daily Focus Distribution (Last 7 Days)</p>
            </div>

            {/* Recent History */}
            <div className="glass-card p-8 rounded-3xl border-white/5 space-y-6">
              <h3 className="text-sm font-bold text-white uppercase tracking-widest flex items-center gap-2">
                <History size={16} className="text-purple-400" /> Recent
              </h3>
              <div className="space-y-4">
                {focusSessions.slice(0, 4).map((session, i) => (
                  <div key={i} className="flex items-center justify-between group">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-xl bg-white/5 border border-white/10 flex items-center justify-center text-white/20 group-hover:text-[#FF6B2C] transition-colors">
                        {session.type === 'pomodoro' ? <Clock size={16} /> : <Zap size={16} />}
                      </div>
                      <div>
                        <p className="text-sm font-bold text-white capitalize">{session.type}</p>
                        <p className="text-[10px] text-textMuted uppercase">{session.duration} minutes</p>
                      </div>
                    </div>
                    <span className="text-[10px] font-black text-success">+{session.xpEarned} XP</span>
                  </div>
                ))}
                {focusSessions.length === 0 && (
                  <p className="text-xs text-textMuted italic text-center py-4">No sessions tracked yet.</p>
                )}
              </div>
              <button className="w-full py-3 rounded-xl border border-white/10 hover:bg-white/5 text-[10px] font-bold text-white/40 hover:text-white uppercase tracking-widest transition-all">View All History</button>
            </div>
          </aside>
        </div>
      </div>

      <AnimatePresence>
        {isFullscreen && (
          <DeepFocusOverlay 
            onClose={() => setIsFullscreen(false)} 
            activeMode={activeMode}
          />
        )}
      </AnimatePresence>
    </div>
  );
}

function PomodoroTimer({ onSessionComplete }) {
  const [timeLeft, setTimeLeft] = useState(25 * 60);
  const [isActive, setIsActive] = useState(false);
  const [isBreak, setIsBreak] = useState(false);
  
  useEffect(() => {
    let interval = null;
    if (isActive && timeLeft > 0) {
      interval = setInterval(() => {
        setTimeLeft((prev) => prev - 1);
      }, 1000);
    } else if (timeLeft === 0) {
      clearInterval(interval);
      setIsActive(false);
      handleComplete();
    }
    return () => clearInterval(interval);
  }, [isActive, timeLeft]);

  const handleComplete = () => {
    if (!isBreak) {
      onSessionComplete({
        type: 'pomodoro',
        duration: 25,
        xpEarned: 15,
        rating: 5
      });
      // Start break?
      setIsBreak(true);
      setTimeLeft(5 * 60);
    } else {
      setIsBreak(false);
      setTimeLeft(25 * 60);
    }
  };

  const minutes = Math.floor(timeLeft / 60);
  const seconds = timeLeft % 60;
  const progress = isBreak 
    ? ((5 * 60 - timeLeft) / (5 * 60)) * 100 
    : ((25 * 60 - timeLeft) / (25 * 60)) * 100;

  return (
    <div className="space-y-12 w-full flex flex-col items-center">
      <div className="relative w-72 h-72 md:w-96 md:h-96">
        <svg className="w-full h-full -rotate-90" viewBox="0 0 100 100">
          <circle cx="50" cy="50" r="45" stroke="rgba(255,255,255,0.05)" strokeWidth="4" fill="none" />
          <motion.circle
            cx="50" cy="50" r="45"
            stroke={isBreak ? '#22c55e' : '#FF6B2C'}
            strokeWidth="4" fill="none"
            strokeDasharray="283"
            initial={{ strokeDashoffset: 283 }}
            animate={{ strokeDashoffset: 283 - (progress / 100) * 283 }}
            transition={{ duration: 0.5, ease: "linear" }}
            strokeLinecap="round"
            style={{ filter: `drop-shadow(0 0 8px ${isBreak ? '#22c55e' : '#FF6B2C'})` }}
          />
        </svg>
        <div className="absolute inset-0 flex flex-col items-center justify-center space-y-2">
          <span className="text-[10px] font-black uppercase tracking-[0.4em] text-textMuted">
            {isBreak ? 'Regenerating' : 'Operational Focus'}
          </span>
          <p className="text-7xl md:text-9xl font-display font-black text-white">
            {String(minutes).padStart(2, '0')}:{String(seconds).padStart(2, '0')}
          </p>
          <div className="flex gap-1">
            {[1, 2, 3, 4].map(i => (
              <div key={i} className="w-1.5 h-1.5 rounded-full bg-[#FF6B2C] shadow-[0_0_5px_#FF6B2C]" />
            ))}
          </div>
        </div>
      </div>

      <div className="flex items-center gap-6">
        <button 
          onClick={() => {
            setIsActive(false);
            setTimeLeft(isBreak ? 5 * 60 : 25 * 60);
          }}
          className="p-5 rounded-2xl bg-white/5 border border-white/10 text-white/40 hover:text-white transition-all"
        >
          <RotateCcw size={24} />
        </button>
        <button 
          onClick={() => setIsActive(!isActive)}
          className="w-24 h-24 rounded-full bg-[#FF6B2C] text-white flex items-center justify-center shadow-[0_10px_30px_rgba(255,107,44,0.3)] hover:scale-110 transition-all"
        >
          {isActive ? <Pause size={40} fill="white" /> : <Play size={40} fill="white" className="ml-2" />}
        </button>
        <button className="p-5 rounded-2xl bg-white/5 border border-white/10 text-white/40 hover:text-white transition-all">
          <Settings size={24} />
        </button>
      </div>
    </div>
  );
}

function Stopwatch({ onSessionComplete }) {
  const [time, setTime] = useState(0);
  const [isActive, setIsActive] = useState(false);
  const startTime = useRef(0);

  useEffect(() => {
    let interval = null;
    if (isActive) {
      interval = setInterval(() => {
        setTime((prev) => prev + 1);
      }, 1000);
    } else {
      clearInterval(interval);
    }
    return () => clearInterval(interval);
  }, [isActive]);

  const h = Math.floor(time / 3600);
  const m = Math.floor((time % 3600) / 60);
  const s = time % 60;

  return (
    <div className="space-y-12 w-full flex flex-col items-center">
      <div className="relative">
        <div className="text-[10px] font-black uppercase tracking-[0.4em] text-textMuted mb-4">Tactical Duration</div>
        <p className="text-8xl md:text-[10rem] font-display font-black text-white tracking-tighter">
          {String(h).padStart(2, '0')}:{String(m).padStart(2, '0')}:{String(s).padStart(2, '0')}
        </p>
      </div>

      <div className="flex items-center gap-6">
        <button 
          onClick={() => {
            setIsActive(false);
            if (time > 60) {
              onSessionComplete({
                type: 'stopwatch',
                duration: Math.floor(time / 60),
                xpEarned: Math.floor(time / 120) * 10,
                rating: 4
              });
            }
            setTime(0);
          }}
          className="px-8 py-4 rounded-2xl bg-white/5 border border-white/10 text-white/40 hover:text-white transition-all font-bold uppercase tracking-widest text-xs"
        >
          Stop & Save
        </button>
        <button 
          onClick={() => setIsActive(!isActive)}
          className="w-24 h-24 rounded-full bg-[#FF6B2C] text-white flex items-center justify-center shadow-[0_10px_30px_rgba(255,107,44,0.3)] hover:scale-110 transition-all"
        >
          {isActive ? <Pause size={40} fill="white" /> : <Play size={40} fill="white" className="ml-2" />}
        </button>
        <button className="px-8 py-4 rounded-2xl bg-white/5 border border-white/10 text-white/40 hover:text-white transition-all font-bold uppercase tracking-widest text-xs">
          Lap
        </button>
      </div>
    </div>
  );
}

function CustomTimer({ onSessionComplete }) {
  const [duration, setDuration] = useState(10); // minutes
  const [timeLeft, setTimeLeft] = useState(10 * 60);
  const [isActive, setIsActive] = useState(false);

  useEffect(() => {
    let interval = null;
    if (isActive && timeLeft > 0) {
      interval = setInterval(() => {
        setTimeLeft((prev) => prev - 1);
      }, 1000);
    } else if (timeLeft === 0) {
      setIsActive(false);
      onSessionComplete({
        type: 'custom',
        duration: duration,
        xpEarned: 10,
        rating: 5
      });
    }
    return () => clearInterval(interval);
  }, [isActive, timeLeft]);

  const m = Math.floor(timeLeft / 60);
  const s = timeLeft % 60;

  return (
    <div className="space-y-12 w-full flex flex-col items-center">
      <div className="flex gap-4">
        {[5, 10, 15, 30, 45, 60].map((d) => (
          <button
            key={d}
            onClick={() => {
              setDuration(d);
              setTimeLeft(d * 60);
              setIsActive(false);
            }}
            className={`px-4 py-2 rounded-xl text-[10px] font-bold uppercase transition-all ${
              duration === d 
                ? 'bg-[#FF6B2C] text-white' 
                : 'bg-white/5 border border-white/10 text-white/40 hover:bg-white/10'
            }`}
          >
            {d}m
          </button>
        ))}
      </div>

      <p className="text-8xl md:text-[10rem] font-display font-black text-white tracking-tighter">
        {String(m).padStart(2, '0')}:{String(s).padStart(2, '0')}
      </p>

      <div className="flex items-center gap-6">
        <button 
          onClick={() => setIsActive(!isActive)}
          className="px-12 py-5 rounded-2xl bg-[#FF6B2C] text-white font-bold uppercase tracking-widest shadow-[0_10px_30px_rgba(255,107,44,0.3)] hover:scale-105 transition-all"
        >
          {isActive ? 'Pause Operation' : 'Initiate Timer'}
        </button>
      </div>
    </div>
  );
}

function DeepFocusOverlay({ onClose, activeMode }) {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-[2000] bg-black flex flex-col items-center justify-center p-6"
    >
      <div className="absolute inset-0 z-0">
        <div className="absolute inset-0 bg-gradient-to-b from-[#FF6B2C]/10 via-transparent to-black" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full h-full opacity-10">
          <motion.div 
            animate={{ 
              scale: [1, 1.1, 1],
              opacity: [0.3, 0.5, 0.3]
            }}
            transition={{ duration: 10, repeat: Infinity }}
            className="w-full h-full border-[1px] border-white rounded-full blur-[100px]"
          />
        </div>
      </div>

      <button 
        onClick={onClose}
        className="absolute top-10 right-10 z-50 p-4 rounded-full border border-white/10 text-white/20 hover:text-white transition-all"
      >
        <X size={32} />
      </button>

      <div className="relative z-10 w-full max-w-4xl text-center space-y-20">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="space-y-4"
        >
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#FF6B2C]/20 border border-[#FF6B2C]/40 text-[#FF8C42] text-[10px] font-bold uppercase tracking-[0.4em]">
            <Sparkles size={14} /> Deep Focus Protocol Active
          </div>
          <h2 className="text-4xl md:text-5xl font-display font-black text-white">Silence the Noise.</h2>
        </motion.div>

        {activeMode === 'pomodoro' && <PomodoroTimer onSessionComplete={() => {}} />}
        {activeMode === 'stopwatch' && <Stopwatch onSessionComplete={() => {}} />}
        {activeMode === 'custom' && <CustomTimer onSessionComplete={() => {}} />}

        <div className="text-textMuted italic font-light text-xl">
          "The successful warrior is the average man, with laser-like focus."
        </div>
      </div>
    </motion.div>
  );
}
