'use client';

import { useState, useEffect, useRef, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Zap, Clock, Play, Pause, RotateCcw, 
  Settings, History, BarChart3, Maximize2, 
  Volume2, Music, Coffee, Brain, 
  ChevronRight, CheckCircle2, Star, Target,
  Flame, Calendar, Monitor, Award, Plus, X, Sparkles
} from 'lucide-react';
import { 
  Chart as ChartJS, 
  CategoryScale, 
  LinearScale, 
  BarElement,
  Title, 
  Tooltip, 
  Legend
} from 'chart.js';
import { Bar } from 'react-chartjs-2';
import useStore from '@/store/useStore';

// Register ChartJS
ChartJS.register(
  CategoryScale, 
  LinearScale, 
  BarElement,
  Title, 
  Tooltip, 
  Legend
);

export default function FocusZone() {
  const { focusSessions, totalFocusMinutes, addFocusSession } = useStore();
  const [activeMode, setActiveMode] = useState('pomodoro'); // 'pomodoro', 'timer', 'stopwatch'
  const [isFullscreen, setIsFullscreen] = useState(false);
  const [showLofiModal, setShowLofiModal] = useState(false);
  const containerRef = useRef(null);

  useEffect(() => {
    const handleFullscreenChange = () => {
      setIsFullscreen(!!document.fullscreenElement);
    };
    document.addEventListener('fullscreenchange', handleFullscreenChange);
    return () => document.removeEventListener('fullscreenchange', handleFullscreenChange);
  }, []);

  const toggleFullscreen = () => {
    if (!document.fullscreenElement) {
      containerRef.current?.requestFullscreen().catch(err => console.error('Error enabling fullscreen:', err));
    } else {
      document.exitFullscreen();
    }
  };

  return (
    <div className="min-h-screen text-white pb-20 relative overflow-x-hidden">
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
                { id: 'timer', label: 'Timer', icon: Zap },
                { id: 'stopwatch', label: 'Stopwatch', icon: History }
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
            <div ref={containerRef} className={isFullscreen ? 'bg-[#050505] text-white' : ''}>
              <AnimatePresence mode="wait">
                <motion.div
                  key={activeMode}
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.95 }}
                  className={`relative w-full transition-all duration-500 ${
                    isFullscreen 
                      ? 'p-12 flex flex-col items-center justify-center min-h-screen' 
                      : 'glass-card p-12 rounded-[3rem] border-white/5 flex flex-col items-center text-center space-y-10 overflow-hidden'
                  }`}
                >
                  {/* Background clock removed for clean focus UI */}

                  {isFullscreen && (
                    <div className="absolute inset-0 pointer-events-none z-0">
                      <div className="absolute inset-0 bg-gradient-to-b from-[#FF6B2C]/10 via-transparent to-black" />
                      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full h-full opacity-10">
                        <motion.div 
                          animate={{ scale: [1, 1.1, 1], opacity: [0.3, 0.5, 0.3] }}
                          transition={{ duration: 10, repeat: Infinity }}
                          className="w-full h-full border-[1px] border-white rounded-full blur-[100px]"
                        />
                      </div>
                    </div>
                  )}

                  <div className="relative z-10 w-full flex justify-center">
                    {activeMode === 'pomodoro' && <PomodoroTimer onSessionComplete={addFocusSession} />}
                    {activeMode === 'stopwatch' && <Stopwatch onSessionComplete={addFocusSession} />}
                    {activeMode === 'timer' && <Timer onSessionComplete={addFocusSession} />}
                  </div>
                  
                  <button 
                    onClick={toggleFullscreen}
                    className={`absolute ${isFullscreen ? 'top-10 right-10' : 'bottom-10 right-10'} p-4 rounded-full bg-white/5 border border-white/10 text-white/20 hover:text-white transition-all z-50`}
                  >
                    {isFullscreen ? <X size={24} /> : <Maximize2 size={24} />}
                  </button>
                </motion.div>
              </AnimatePresence>
            </div>

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
                  { label: 'Lo-Fi Chill', icon: Coffee, action: () => setShowLofiModal(true) },
                  { label: 'Deep Rain', icon: Volume2, action: null },
                  { label: 'Focus Flow', icon: Brain, action: null },
                  { label: 'Library', icon: History, action: null }
                ].map((item, i) => (
                  <button key={i} onClick={item.action || undefined} className="flex flex-col items-center justify-center p-4 rounded-2xl bg-white/5 border border-white/10 hover:border-[#FF6B2C]/30 hover:bg-[#FF6B2C]/5 transition-all group">
                    <item.icon size={20} className="text-white/20 group-hover:text-[#FF6B2C] mb-2" />
                    <span className="text-[10px] font-bold text-white/40 group-hover:text-white uppercase tracking-widest">{item.label}</span>
                  </button>
                ))}
              </div>
            </div>

            {/* Lo-fi Chill YouTube Modal */}
            <AnimatePresence>
              {showLofiModal && (
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{ opacity: 0 }}
                  className="fixed inset-0 z-[200] flex items-center justify-center p-4 bg-black/80 backdrop-blur-xl"
                  onClick={() => setShowLofiModal(false)}
                >
                  <motion.div
                    initial={{ scale: 0.9, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    exit={{ scale: 0.9, opacity: 0 }}
                    className="glass-card rounded-3xl border border-white/10 overflow-hidden w-full max-w-2xl relative"
                    onClick={e => e.stopPropagation()}
                  >
                    <div className="flex items-center justify-between px-6 py-4 border-b border-white/10">
                      <div className="flex items-center gap-3">
                        <div className="w-2 h-2 rounded-full bg-[#FF6B2C] shadow-[0_0_8px_#FF6B2C]" />
                        <h3 className="text-sm font-bold text-white uppercase tracking-widest">Lo-fi Chill</h3>
                      </div>
                      <button
                        onClick={() => setShowLofiModal(false)}
                        className="p-2 rounded-xl bg-white/5 hover:bg-white/10 text-white/40 hover:text-white transition-all"
                      >
                        <X size={18} />
                      </button>
                    </div>
                    <div className="aspect-video w-full">
                      <iframe
                        width="100%"
                        height="100%"
                        src="https://www.youtube.com/embed/CLeZyIID9Bo?autoplay=1&mute=1"
                        title="Lo-fi Chill"
                        frameBorder="0"
                        allow="autoplay; encrypted-media"
                        allowFullScreen
                        className="w-full h-full"
                      />
                    </div>
                    <div className="px-6 py-3 border-t border-white/10">
                      <p className="text-[10px] text-textMuted font-bold uppercase tracking-widest">Click outside or ✕ to close · Unmute in player controls</p>
                    </div>
                  </motion.div>
                </motion.div>
              )}
            </AnimatePresence>

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
                {(focusSessions || []).slice(0, 4).map((session, i) => (
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
                {(focusSessions || []).length === 0 && (
                  <p className="text-xs text-textMuted italic text-center py-4">No sessions tracked yet.</p>
                )}
              </div>
              <button className="w-full py-3 rounded-xl border border-white/10 hover:bg-white/5 text-[10px] font-bold text-white/40 hover:text-white uppercase tracking-widest transition-all">View All History</button>
            </div>
          </aside>
        </div>
      </div>
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
      if (onSessionComplete) {
        onSessionComplete({
          type: 'pomodoro',
          duration: 25,
          xpEarned: 15,
          rating: 5
        });
      }
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
              if (onSessionComplete) {
                onSessionComplete({
                  type: 'stopwatch',
                  duration: Math.floor(time / 60),
                  xpEarned: Math.floor(time / 120) * 10,
                  rating: 4
                });
              }
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
        <button 
          onClick={() => {
            setIsActive(false);
            setTime(0);
          }}
          className="px-8 py-4 rounded-2xl bg-white/5 border border-white/10 text-white/40 hover:text-white transition-all font-bold uppercase tracking-widest text-xs"
        >
          Reset
        </button>
      </div>
    </div>
  );
}

function Timer({ onSessionComplete }) {
  const [inputMin, setInputMin] = useState(10);
  const [inputSec, setInputSec] = useState(0);
  const [timeLeft, setTimeLeft] = useState(10 * 60);
  const [isActive, setIsActive] = useState(false);
  const [isRinging, setIsRinging] = useState(false);
  const audioIntervalRef = useRef(null);

  const startAlarm = () => {
    setIsRinging(true);
    try {
      const ctx = new (window.AudioContext || window.webkitAudioContext)();
      const playBeep = () => {
        if (ctx.state === 'suspended') ctx.resume();
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.type = 'sine';
        osc.frequency.setValueAtTime(880, ctx.currentTime);
        gain.gain.setValueAtTime(0.1, ctx.currentTime);
        osc.start();
        gain.gain.exponentialRampToValueAtTime(0.00001, ctx.currentTime + 0.5);
        setTimeout(() => osc.stop(), 500);
      };
      playBeep();
      audioIntervalRef.current = setInterval(playBeep, 1000);
      setTimeout(stopAlarm, 5000);
    } catch (e) {
      console.log('Audio error:', e);
    }
  };

  const stopAlarm = () => {
    setIsRinging(false);
    if (audioIntervalRef.current) {
      clearInterval(audioIntervalRef.current);
      audioIntervalRef.current = null;
    }
  };

  useEffect(() => {
    let interval = null;
    if (isActive && timeLeft > 0) {
      interval = setInterval(() => {
        setTimeLeft((prev) => prev - 1);
      }, 1000);
    } else if (isActive && timeLeft === 0) {
      setIsActive(false);
      startAlarm();
      if (onSessionComplete) {
        onSessionComplete({
          type: 'timer',
          duration: inputMin + Math.round(inputSec / 60),
          xpEarned: 10,
          rating: 5
        });
      }
    }
    return () => clearInterval(interval);
  }, [isActive, timeLeft, inputMin, inputSec, onSessionComplete]);

  useEffect(() => {
    return () => stopAlarm();
  }, []);

  const handleStartPause = () => {
    if (isRinging) {
      stopAlarm();
      return;
    }
    if (!isActive && timeLeft === 0) {
      setTimeLeft(inputMin * 60 + inputSec);
    }
    setIsActive(!isActive);
  };

  const handleReset = () => {
    setIsActive(false);
    stopAlarm();
    setTimeLeft(inputMin * 60 + inputSec);
  };

  const handleMinChange = (e) => {
    const val = Math.max(0, parseInt(e.target.value) || 0);
    setInputMin(val);
    if (!isActive) setTimeLeft(val * 60 + inputSec);
  };

  const handleSecChange = (e) => {
    const val = Math.max(0, Math.min(59, parseInt(e.target.value) || 0));
    setInputSec(val);
    if (!isActive) setTimeLeft(inputMin * 60 + val);
  };

  const m = Math.floor(timeLeft / 60);
  const s = timeLeft % 60;

  return (
    <div className="space-y-8 w-full flex flex-col items-center">
      <div className="flex gap-4 items-center mb-2">
        <div className="flex flex-col items-center">
          <label className="text-[10px] font-bold text-textMuted uppercase tracking-widest mb-2">Minutes</label>
          <input 
            type="number" 
            min="0"
            value={inputMin} 
            onChange={handleMinChange}
            disabled={isActive || isRinging}
            className="w-24 bg-white/5 border border-white/10 rounded-xl text-center text-2xl font-display font-bold py-3 text-white focus:outline-none focus:border-[#FF6B2C] disabled:opacity-50"
          />
        </div>
        <span className="text-2xl font-bold text-white/40 mt-6">:</span>
        <div className="flex flex-col items-center">
          <label className="text-[10px] font-bold text-textMuted uppercase tracking-widest mb-2">Seconds</label>
          <input 
            type="number" 
            min="0"
            max="59"
            value={inputSec} 
            onChange={handleSecChange}
            disabled={isActive || isRinging}
            className="w-24 bg-white/5 border border-white/10 rounded-xl text-center text-2xl font-display font-bold py-3 text-white focus:outline-none focus:border-[#FF6B2C] disabled:opacity-50"
          />
        </div>
      </div>

      <div className={`transition-all duration-300 ${isRinging ? 'scale-110 text-[#FF6B2C] drop-shadow-[0_0_20px_rgba(255,107,44,0.5)]' : 'text-white'}`}>
        <p className="text-8xl md:text-[10rem] font-display font-black tracking-tighter">
          {String(m).padStart(2, '0')}:{String(s).padStart(2, '0')}
        </p>
      </div>

      <div className="flex items-center gap-6">
        <button 
          onClick={handleReset}
          className="px-8 py-4 rounded-2xl bg-white/5 border border-white/10 text-white/40 hover:text-white transition-all font-bold uppercase tracking-widest text-xs"
        >
          Reset
        </button>
        <button 
          onClick={handleStartPause}
          className={`w-24 h-24 rounded-full flex items-center justify-center shadow-[0_10px_30px_rgba(255,107,44,0.3)] hover:scale-110 transition-all ${isRinging ? 'bg-red-500 shadow-[0_10px_30px_rgba(239,68,68,0.3)]' : 'bg-[#FF6B2C]'} text-white`}
        >
          {isRinging ? <Volume2 size={40} fill="white" /> : (isActive ? <Pause size={40} fill="white" /> : <Play size={40} fill="white" className="ml-2" />)}
        </button>
      </div>
    </div>
  );
}


