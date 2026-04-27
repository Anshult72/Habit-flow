import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { 
  CheckCircle2, Calendar, LayoutGrid, Circle, 
  Clock, Star, ChevronRight, Sparkles, Briefcase,
  StickyNote, ShoppingCart, Heart, BookOpen, Dumbbell,
  ArrowLeft, ListTodo, Plus
} from 'lucide-react';
import toast from 'react-hot-toast';

const FEATURES = [
  { id: 'task', label: 'Task', icon: CheckCircle2, desc: 'Manage objectives' },
  { id: 'calendar', label: 'Calendar', icon: Calendar, desc: 'Plan your time' },
  { id: 'matrix', label: 'Eisenhower Matrix', icon: LayoutGrid, desc: 'Prioritize tasks' },
  { id: 'pomodoro', label: 'Pomodoro', icon: Circle, desc: 'Deep work focus' },
  { id: 'habit', label: 'Habit Tracker', icon: Clock, desc: 'Build consistency' },
  { id: 'countdown', label: 'Countdown', icon: Star, desc: 'Track deadlines' },
];

const LISTS = [
  { id: 'work', label: 'Work', icon: Briefcase, desc: 'Professional projects' },
  { id: 'memo', label: 'Memo', icon: StickyNote, desc: 'Quick thoughts' },
  { id: 'shopping', label: 'Shopping', icon: ShoppingCart, desc: 'Daily essentials' },
  { id: 'wishlist', label: 'Wishlist', icon: Heart, desc: 'Future goals' },
  { id: 'study', label: 'Study', icon: BookOpen, desc: 'Learning sessions' },
  { id: 'exercise', label: 'Exercise', icon: Dumbbell, desc: 'Physical health' },
];

export default function Onboarding() {
  const [step, setStep] = useState(1);
  const [selectedFeatures, setSelectedFeatures] = useState(['task', 'calendar', 'matrix', 'pomodoro']);
  const [selectedLists, setSelectedLists] = useState(['work', 'study']);
  const [activePreview, setActivePreview] = useState('matrix');
  const [activeListPreview, setActiveListPreview] = useState('work');
  const navigate = useNavigate();

  const toggleFeature = (id) => {
    setSelectedFeatures(prev => 
      prev.includes(id) ? prev.filter(f => f !== id) : [...prev, id]
    );
    setActivePreview(id);
  };

  const toggleList = (id) => {
    setSelectedLists(prev => 
      prev.includes(id) ? prev.filter(f => f !== id) : [...prev, id]
    );
    setActiveListPreview(id);
  };

  const handleContinue = () => {
    if (step === 1) {
      setStep(2);
    } else {
      handleFinish();
    }
  };

  const handleFinish = () => {
    localStorage.setItem('userFeatures', JSON.stringify(selectedFeatures));
    localStorage.setItem('userLists', JSON.stringify(selectedLists));
    localStorage.setItem('hasCompletedOnboarding', 'true');
    toast.success('System initialized. Welcome to HabitFlow.', {
      duration: 4000,
      icon: '🚀',
    });
    navigate('/app');
  };

  return (
    <div className="fixed inset-0 bg-[#050505] flex flex-col md:flex-row overflow-hidden z-[100]">
      {/* Cinematic Background Ambience */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-1/4 left-1/4 w-[800px] h-[800px] bg-[#FF6B2C]/5 rounded-full blur-[160px] animate-pulse" />
        <div className="absolute bottom-1/4 right-1/4 w-[600px] h-[600px] bg-[#E85D04]/3 rounded-full blur-[140px]" />
        <div className="absolute inset-0 bg-[url('https://grainy-gradients.vercel.app/noise.svg')] opacity-[0.15] mix-blend-overlay" />
      </div>

      {/* LEFT SIDE: Dynamic Preview Area (DARK THEME) */}
      <div className="flex-1 relative bg-[#050505] flex items-center justify-center p-6 md:p-12 overflow-hidden">
         {/* Internal Glow */}
         <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(255,107,44,0.03)_0%,transparent_70%)]" />

        <AnimatePresence mode="wait">
          <motion.div
            key={`${step}-${step === 1 ? activePreview : activeListPreview}`}
            initial={{ opacity: 0, scale: 0.98, y: 10 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.98, y: -10 }}
            transition={{ duration: 0.5, ease: [0.23, 1, 0.32, 1] }}
            className="relative w-full max-w-[860px] aspect-[1.4/1] bg-[#0A0A0B] rounded-[2.5rem] shadow-[0_40px_100px_rgba(0,0,0,0.8)] border border-white/5 overflow-hidden flex"
          >
            {/* Mockup Sidebar (Dark) */}
            <div className="w-[80px] border-r border-white/5 flex flex-col items-center py-10 gap-12 bg-[#080808]">
              <div className="w-12 h-12 rounded-2xl bg-gradient-to-tr from-[#FF6B2C] to-[#E85D04] flex items-center justify-center shadow-[0_0_30px_rgba(255,107,44,0.4)] transition-transform hover:scale-110 duration-500">
                 <CheckCircle2 size={24} className="text-white" />
              </div>
              <div className="flex flex-col gap-10 opacity-10">
                 <div className="w-6 h-6 rounded-lg bg-white" />
                 <div className="w-6 h-6 rounded-lg bg-white" />
                 <div className="w-8 h-8 rounded-lg bg-[#FF6B2C] flex items-center justify-center opacity-100">
                    <LayoutGrid size={22} className="text-[#FF6B2C]" />
                 </div>
                 <div className="w-6 h-6 rounded-lg bg-white" />
                 <div className="w-6 h-6 rounded-lg bg-white" />
              </div>
            </div>

            {/* Mockup Content Area (Dark) */}
            <div className="flex-1 bg-[#0A0A0B] relative overflow-hidden">
              {/* Background Light Pattern */}
              <div className="absolute top-0 right-0 w-full h-full bg-[radial-gradient(circle_at_top_right,rgba(255,107,44,0.02),transparent_50%)]" />
              
              <div className="p-12 h-full relative z-10 text-white">
                {step === 1 ? (
                  <>
                    {activePreview === 'task' && <TaskPreview />}
                    {activePreview === 'calendar' && <CalendarPreview />}
                    {activePreview === 'matrix' && <MatrixPreview />}
                    {activePreview === 'pomodoro' && <PomodoroPreview />}
                    {activePreview === 'habit' && <HabitPreview />}
                    {activePreview === 'countdown' && <CountdownPreview />}
                  </>
                ) : (
                  <>
                    {activeListPreview === 'work' && <WorkPreview />}
                    {activeListPreview === 'memo' && <MemoPreview />}
                    {activeListPreview === 'shopping' && <ShoppingPreview />}
                    {activeListPreview === 'wishlist' && <WishlistPreview />}
                    {activeListPreview === 'study' && <StudyPreview />}
                    {activeListPreview === 'exercise' && <ExercisePreview />}
                  </>
                )}
              </div>
            </div>
          </motion.div>
        </AnimatePresence>

        {/* Bottom Progress Tracker (Left) */}
        <div className="absolute bottom-12 left-12 flex items-center gap-3">
          <div className={`h-1.5 rounded-full transition-all duration-500 ${step === 1 ? 'w-10 bg-[#FF6B2C] shadow-[0_0_15px_rgba(255,107,44,0.6)]' : 'w-3 bg-white/20'}`} />
          <div className={`h-1.5 rounded-full transition-all duration-500 ${step === 2 ? 'w-10 bg-[#FF6B2C] shadow-[0_0_15px_rgba(255,107,44,0.6)]' : 'w-3 bg-white/20'}`} />
          <div className="w-3 h-1.5 bg-white/10 rounded-full" />
        </div>
      </div>

      {/* RIGHT SIDE: Onboarding Control Panel (DARK GLASS) */}
      <div className="w-full md:w-[480px] h-screen bg-[#080808] flex flex-col relative shadow-[-50px_0_100px_rgba(0,0,0,0.6)] border-l border-white/5 z-20">
        {/* Step 2 Back Button */}
        {step === 2 && (
          <button 
            onClick={() => setStep(1)}
            className="absolute top-10 left-10 flex items-center gap-2 text-white/40 hover:text-white transition-colors z-30 group"
          >
            <ArrowLeft size={16} className="group-hover:-translate-x-1 transition-transform" />
            <span className="text-xs font-bold uppercase tracking-[0.2em]">Back</span>
          </button>
        )}

        <div className="flex-1 overflow-y-auto px-12 pt-32 pb-12 custom-scrollbar">
          <AnimatePresence mode="wait">
            <motion.div
              key={step}
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              transition={{ duration: 0.4, ease: [0.23, 1, 0.32, 1] }}
              className="w-full"
            >
              <div className="mb-10">
                <h1 className="text-3xl md:text-4xl font-display font-bold text-white tracking-tight mb-4 leading-tight">
                  {step === 1 ? 'Personalize your workspace' : '👋 Choose the lists you need'}
                </h1>
                <p className="text-textMuted font-light leading-relaxed text-sm md:text-base">
                  {step === 1 
                    ? 'Select the core features you want to track. You can always change these later in settings.' 
                    : 'Start with pre-configured lists tailored to your lifestyle. We will help you organize these immediately.'
                  }
                </p>
              </div>

              {/* Selection Grid */}
              <div className="grid grid-cols-1 gap-4 mb-10">
                {(step === 1 ? FEATURES : LISTS).map((item) => {
                  const isSelected = step === 1 
                    ? selectedFeatures.includes(item.id)
                    : selectedLists.includes(item.id);
                  const Icon = item.icon;
                  
                  return (
                    <motion.button
                      key={item.id}
                      whileHover={{ scale: 1.01, backgroundColor: 'rgba(255,107,44,0.04)' }}
                      whileTap={{ scale: 0.99 }}
                      onClick={() => step === 1 ? toggleFeature(item.id) : toggleList(item.id)}
                      className={`flex items-center gap-5 p-5 rounded-3xl border transition-all duration-300 text-left relative group overflow-hidden ${
                        isSelected 
                          ? 'bg-[#FF6B2C]/10 border-[#FF6B2C]/40 shadow-[0_0_20px_rgba(255,107,44,0.1)]' 
                          : 'bg-white/[0.02] border-white/5 hover:border-white/10'
                      }`}
                    >
                      <div className={`w-10 h-10 rounded-xl flex items-center justify-center transition-all duration-500 z-10 ${
                        isSelected ? 'bg-[#FF6B2C] text-white shadow-[0_0_15px_#FF6B2C]' : 'bg-white/5 text-white/20 group-hover:text-white/40'
                      }`}>
                        <Icon size={18} />
                      </div>
                      
                      <div className="flex-1 z-10">
                        <p className={`font-bold text-sm transition-colors ${isSelected ? 'text-white' : 'text-white/40 group-hover:text-white/60'}`}>
                          {item.label}
                        </p>
                        <p className="text-[10px] text-textMuted/60 uppercase tracking-widest mt-0.5">{item.desc}</p>
                      </div>

                      <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center transition-all z-10 ${
                        isSelected ? 'bg-[#FF6B2C] border-[#FF6B2C]' : 'border-white/10'
                      }`}>
                        {isSelected && <CheckCircle2 size={12} strokeWidth={3} className="text-white" />}
                      </div>
                    </motion.button>
                  );
                })}
              </div>
              
              <div className="flex items-center gap-2 mb-8">
                 <div className="w-1.5 h-1.5 rounded-full bg-[#FF6B2C] shadow-[0_0_8px_#FF6B2C]" />
                 <p className="text-[10px] text-textMuted font-bold uppercase tracking-[0.3em]">
                   {step === 1 ? 'Neural Core Online' : 'Lists Synchronized'}
                 </p>
              </div>
            </motion.div>
          </AnimatePresence>
        </div>

        {/* Action Bar (Bottom) */}
        <div className="px-12 py-10 flex items-center justify-between border-t border-white/5 bg-[#080808]/80 backdrop-blur-xl shrink-0">
          <div className="flex gap-2">
             <motion.div 
               animate={{ width: [24, 40, 24], opacity: [0.6, 1, 0.6] }} 
               transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
               className="h-1 bg-[#FF6B2C] rounded-full shadow-[0_0_10px_#FF6B2C]" 
             />
             <div className="w-2 h-1 bg-white/10 rounded-full" />
             <div className="w-2 h-1 bg-white/10 rounded-full" />
          </div>
          <div className="flex items-center gap-8">
            <button 
              onClick={handleFinish}
              className="text-white/30 hover:text-white text-[10px] font-bold transition-all uppercase tracking-[0.2em] relative group"
            >
              Skip Setup
              <span className="absolute -bottom-1 left-0 w-0 h-[1px] bg-[#FF6B2C] transition-all group-hover:w-full opacity-50" />
            </button>
            <button
              onClick={handleContinue}
              disabled={step === 1 ? selectedFeatures.length === 0 : selectedLists.length === 0}
              className="px-10 py-3.5 rounded-2xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] disabled:from-white/5 disabled:to-white/5 disabled:text-white/10 disabled:cursor-not-allowed text-white font-bold text-sm transition-all shadow-[0_10px_30px_rgba(255,107,44,0.3)] hover:shadow-[0_15px_40px_rgba(255,107,44,0.5)] active:scale-95 group relative overflow-hidden"
            >
              <span className="relative z-10 flex items-center gap-2">
                {step === 1 ? 'Continue' : 'Get Started'}
                <ChevronRight size={18} className="group-hover:translate-x-1 transition-transform" />
              </span>
              <div className="absolute inset-0 bg-white/20 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-700 ease-in-out" />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

// --- DARK CINEMATIC PREVIEW COMPONENTS ---

function TaskPreview() {
  return (
    <div className="h-full flex flex-col">
      <div className="w-32 h-5 bg-white/5 rounded-full mb-12 animate-pulse" />
      <div className="space-y-6">
        <div className="flex items-center gap-5 p-2 border-b border-white/5">
           <div className="w-6 h-6 rounded-lg bg-[#FF6B2C] flex items-center justify-center shadow-[0_0_20px_rgba(255,107,44,0.6)]">
             <CheckCircle2 size={14} className="text-white" />
           </div>
           <div className="h-4 w-64 bg-white/10 rounded-full" />
        </div>
        {[...Array(6)].map((_, i) => (
          <div key={i} className="flex items-center gap-5 p-2 opacity-40 group/item transition-all hover:opacity-100">
             <div className="w-6 h-6 rounded-lg border border-white/20 bg-white/5 group-hover/item:border-[#FF6B2C]/50 transition-colors" />
             <div className="h-4 w-80 bg-white/5 rounded-full" />
          </div>
        ))}
      </div>
    </div>
  );
}

function CalendarPreview() {
  return (
    <div className="h-full flex flex-col">
      <div className="w-40 h-6 bg-white/5 rounded-full mb-12" />
      <div className="grid grid-cols-7 gap-5 flex-1">
        {[...Array(35)].map((_, i) => (
          <div key={i} className={`flex flex-col gap-3 p-2 rounded-xl transition-all ${i === 13 ? 'bg-[#FF6B2C]/5 border border-[#FF6B2C]/20 shadow-[inset_0_0_20px_rgba(255,107,44,0.05)]' : ''}`}>
            <span className={`text-[11px] font-bold ${i < 31 ? 'text-white/30' : 'text-white/5'}`}>{i < 31 ? i + 1 : i - 30}</span>
            {i % 4 === 0 && <div className={`h-2 rounded-full w-full ${i === 12 ? 'bg-[#FF6B2C] shadow-[0_0_10px_#FF6B2C]' : 'bg-white/5'}`} />}
            {i % 5 === 0 && <div className={`h-2 rounded-full w-2/3 ${i === 14 ? 'bg-[#FF8C42]/50' : 'bg-white/5'}`} />}
          </div>
        ))}
      </div>
    </div>
  );
}

function MatrixPreview() {
  return (
    <div className="h-full flex flex-col">
      <div className="flex items-center gap-4 mb-10">
        <div className="w-3 h-3 rounded-full bg-[#FF6B2C] shadow-[0_0_12px_#FF6B2C] animate-pulse" />
        <div className="w-48 h-5 bg-white/5 rounded-full" />
      </div>
      <div className="grid grid-cols-2 grid-rows-2 gap-6 flex-1">
        {[
          { label: 'CRITICAL', color: 'bg-[#FF6B2C]/5', accent: 'bg-[#FF6B2C]' },
          { label: 'STRATEGIC', color: 'bg-amber-500/5', accent: 'bg-amber-500/40' },
          { label: 'DELEGATE', color: 'bg-[#E85D04]/5', accent: 'bg-[#E85D04]/40' },
          { label: 'ARCHIVE', color: 'bg-white/[0.01]', accent: 'bg-white/10' }
        ].map((quad, i) => (
          <div key={i} className={`rounded-3xl border border-white/5 ${quad.color} p-8 relative overflow-hidden group/quad transition-all hover:border-[#FF6B2C]/20`}>
             <div className="flex justify-between items-center mb-8">
                <div className={`h-4 w-24 ${quad.accent} rounded-full flex items-center px-3`}>
                   <div className="w-1 h-1 rounded-full bg-white mr-2" />
                   <div className="h-1 flex-1 bg-white/20 rounded-full" />
                </div>
                <div className="flex gap-2">
                   <div className="w-4 h-4 rounded-full bg-white/5 group-hover/quad:bg-[#FF6B2C]/20 transition-colors" />
                </div>
             </div>
             <div className="space-y-4 opacity-50">
                <div className="flex items-center gap-4">
                   <div className="w-4 h-4 rounded-lg border border-white/10 bg-black/40" />
                   <div className="h-2.5 w-full bg-white/10 rounded-full" />
                </div>
                <div className="flex items-center gap-4">
                   <div className="w-4 h-4 rounded-lg border border-white/10 bg-black/40" />
                   <div className="h-2.5 w-3/4 bg-white/10 rounded-full" />
                </div>
             </div>
             {/* Hover Glow */}
             <div className="absolute top-0 right-0 w-32 h-32 bg-[#FF6B2C]/5 blur-3xl opacity-0 group-hover/quad:opacity-100 transition-opacity" />
          </div>
        ))}
      </div>
    </div>
  );
}

function PomodoroPreview() {
  return (
    <div className="h-full flex flex-col items-center justify-center relative">
      <div className="w-48 h-6 bg-white/5 rounded-full mb-16 text-center overflow-hidden">
         <motion.div animate={{ x: [-100, 200] }} transition={{ duration: 3, repeat: Infinity }} className="h-full w-20 bg-gradient-to-r from-transparent via-[#FF6B2C]/20 to-transparent" />
      </div>
      <div className="relative w-80 h-80 flex items-center justify-center mb-16">
        {/* Cinematic Rings */}
        <div className="absolute inset-0 border border-white/5 rounded-full scale-[1.15]" />
        <div className="absolute inset-0 border border-white/[0.02] rounded-full scale-[1.3]" />
        
        <svg className="w-full h-full -rotate-90">
          <circle cx="160" cy="160" r="145" stroke="rgba(255,255,255,0.03)" strokeWidth="6" fill="transparent" />
          <motion.circle 
            cx="160" cy="160" r="145" 
            stroke="#FF6B2C" strokeWidth="6" fill="transparent" 
            strokeDasharray="911" 
            initial={{ strokeDashoffset: 911 }}
            animate={{ strokeDashoffset: 250 }}
            transition={{ duration: 2, ease: "easeOut" }}
            strokeLinecap="round" 
            className="drop-shadow-[0_0_15px_rgba(255,107,44,0.6)]" 
          />
        </svg>
        <div className="absolute inset-0 flex flex-col items-center justify-center">
           <span className="text-8xl font-display font-bold text-white tracking-tighter">23:58</span>
           <span className="text-[11px] font-bold text-[#FF8C42] uppercase tracking-[0.4em] mt-3 opacity-60">Sequence Alpha</span>
        </div>
      </div>
      <button className="px-12 py-4 rounded-2xl border border-[#FF6B2C]/30 bg-[#FF6B2C]/10 flex items-center gap-4 text-[#FF8C42] font-bold shadow-[0_0_40px_rgba(255,107,44,0.2)] hover:scale-105 transition-all active:scale-95">
         <div className="w-2 h-5 bg-[#FF6B2C] rounded-full shadow-[0_0_10px_#FF6B2C]" />
         <div className="w-2 h-5 bg-[#FF6B2C] rounded-full shadow-[0_0_10px_#FF6B2C]" />
         <span className="ml-2 uppercase tracking-widest text-xs">Pause Session</span>
      </button>
    </div>
  );
}

function HabitPreview() {
  return (
    <div className="h-full flex flex-col">
      <div className="w-56 h-6 bg-white/5 rounded-full mb-16" />
      <div className="grid grid-cols-7 gap-8 flex-1">
        {[...Array(21)].map((_, i) => (
          <div key={i} className="flex flex-col gap-6 items-center group/habit">
             <div className="w-16 h-16 rounded-[1.5rem] bg-white/[0.02] border border-white/5 flex items-center justify-center group-hover/habit:border-[#FF6B2C]/40 transition-all duration-500 shadow-xl">
                <div className={`w-4 h-4 rounded-full transition-all duration-700 ${i < 14 ? 'bg-[#FF6B2C] shadow-[0_0_20px_#FF6B2C]' : 'bg-white/10'}`} />
             </div>
             <div className="w-10 h-2.5 bg-white/5 rounded-full transition-all group-hover/habit:bg-[#FF6B2C]/20" />
          </div>
        ))}
      </div>
    </div>
  );
}

function CountdownPreview() {
  return (
    <div className="h-full flex flex-col justify-center gap-12">
       {[...Array(3)].map((_, i) => (
         <motion.div 
           key={i} 
           whileHover={{ x: 10 }}
           className="p-10 rounded-[2.5rem] bg-white/[0.02] border border-white/5 flex items-center justify-between relative overflow-hidden group/cd shadow-2xl"
         >
            <div className="absolute inset-0 bg-gradient-to-r from-[#FF6B2C]/5 to-transparent opacity-0 group-hover/cd:opacity-100 transition-opacity duration-700" />
            <div className="flex gap-8 items-center relative z-10">
               <div className="w-16 h-16 rounded-2xl bg-gradient-to-tr from-[#FF6B2C]/20 to-[#E85D04]/5 border border-[#FF6B2C]/20 flex items-center justify-center shadow-lg group-hover/cd:scale-110 transition-transform duration-500">
                  <Sparkles size={28} className="text-[#FF8C42]" />
               </div>
               <div className="space-y-4">
                  <div className="h-4 w-48 bg-white/10 rounded-full" />
                  <div className="h-2.5 w-32 bg-white/5 rounded-full opacity-60" />
               </div>
            </div>
            <div className="h-6 w-56 bg-black/60 rounded-full border border-white/10 relative z-10 overflow-hidden p-1">
               <motion.div 
                 initial={{ width: 0 }}
                 animate={{ width: `${80 - i * 20}%` }}
                 transition={{ duration: 1.5, delay: 0.5 }}
                 className="h-full bg-[#FF6B2C] rounded-full relative"
               >
                 <div className="absolute top-0 right-0 w-8 h-full bg-white/30 blur-md" />
               </motion.div>
            </div>
         </motion.div>
       ))}
    </div>
  );
}

// --- CATEGORY LIST PREVIEW COMPONENTS ---

function WorkPreview() {
  return (
    <div className="h-full flex flex-col">
      <div className="flex items-center justify-between mb-12">
        <h2 className="text-3xl font-display font-bold">Project Horizon</h2>
        <div className="flex gap-2">
           <div className="w-8 h-8 rounded-full bg-white/10" />
           <div className="w-8 h-8 rounded-full bg-[#FF6B2C]" />
        </div>
      </div>
      <div className="grid grid-cols-3 gap-6 flex-1">
        {['Backlog', 'In Progress', 'Completed'].map((status, i) => (
          <div key={status} className="bg-white/[0.02] border border-white/5 rounded-3xl p-6 flex flex-col gap-4">
             <div className="flex items-center justify-between mb-2">
                <span className="text-[10px] font-bold uppercase tracking-widest text-textMuted">{status}</span>
                <span className="w-5 h-5 rounded-md bg-white/5 flex items-center justify-center text-[10px]">{i === 1 ? 3 : 1}</span>
             </div>
             {[...Array(i === 1 ? 3 : 1)].map((_, j) => (
               <div key={j} className="p-4 bg-[#050505] border border-white/5 rounded-xl space-y-3 shadow-xl">
                  <div className="h-2.5 w-full bg-white/10 rounded-full" />
                  <div className="h-2 w-2/3 bg-white/5 rounded-full" />
                  <div className="flex justify-between items-center pt-2">
                     <div className="flex -space-x-2">
                        <div className="w-5 h-5 rounded-full bg-[#FF6B2C]/20 border border-white/5" />
                        <div className="w-5 h-5 rounded-full bg-white/10 border border-white/5" />
                     </div>
                     <div className="w-10 h-1.5 bg-white/5 rounded-full" />
                  </div>
               </div>
             ))}
             {i === 1 && (
               <div className="p-4 border border-dashed border-white/10 rounded-xl flex items-center justify-center">
                  <Plus size={16} className="text-white/20" />
               </div>
             )}
          </div>
        ))}
      </div>
    </div>
  );
}

function MemoPreview() {
  return (
    <div className="h-full flex flex-col">
      <div className="flex items-center gap-4 mb-12 opacity-30">
        <div className="w-10 h-10 rounded-xl bg-white/5" />
        <div className="w-48 h-4 bg-white/10 rounded-full" />
      </div>
      <div className="grid grid-cols-2 gap-8 flex-1">
        {[
          { title: 'Vision Statement', color: 'bg-[#FF6B2C]/10', text: 'Define the core pillars of the new habit system...' },
          { title: 'Morning Routine', color: 'bg-white/[0.03]', text: '1. Sunlight exposure\n2. Hydration\n3. Movement...' },
          { title: 'Research Links', color: 'bg-white/[0.03]', text: 'Psychology of habit formation, neural plasticity...' },
          { title: 'Quarterly Goals', color: 'bg-[#E85D04]/5', text: 'Reach elite level in discipline tracking...' },
        ].map((note, i) => (
          <div key={i} className={`p-8 rounded-[2rem] border border-white/5 ${note.color} flex flex-col gap-4 relative overflow-hidden group`}>
             <h3 className="text-lg font-bold text-white mb-2">{note.title}</h3>
             <p className="text-sm text-textMuted leading-relaxed whitespace-pre-line">{note.text}</p>
             <div className="absolute bottom-6 right-6 opacity-20 group-hover:opacity-100 transition-opacity">
                <StickyNote size={16} className="text-[#FF6B2C]" />
             </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function ShoppingPreview() {
  return (
    <div className="h-full flex flex-col max-w-2xl mx-auto w-full">
      <div className="flex items-center justify-between mb-12">
        <h2 className="text-3xl font-display font-bold">Grocery Protocol</h2>
        <span className="px-4 py-1.5 rounded-full bg-green-500/10 text-green-500 text-[10px] font-bold uppercase tracking-widest">Optimized</span>
      </div>
      <div className="space-y-4">
        {[
          { item: 'Organic Blueberries', cat: 'Fruit', checked: true },
          { item: 'Cold Brew Coffee', cat: 'Beverage', checked: false },
          { item: 'Greek Yogurt', cat: 'Dairy', checked: true },
          { item: 'Avocados', cat: 'Produce', checked: false },
          { item: 'Almond Milk', cat: 'Dairy', checked: false },
        ].map((item, i) => (
          <div key={i} className={`flex items-center justify-between p-6 rounded-2xl border transition-all ${item.checked ? 'bg-white/[0.01] border-white/5 opacity-40' : 'bg-white/[0.03] border-white/10 shadow-lg'}`}>
            <div className="flex items-center gap-6">
               <div className={`w-6 h-6 rounded-lg border flex items-center justify-center transition-all ${item.checked ? 'bg-green-500 border-green-500' : 'border-white/20'}`}>
                 {item.checked && <CheckCircle2 size={14} className="text-white" />}
               </div>
               <div>
                 <p className={`font-bold ${item.checked ? 'line-through text-textMuted' : 'text-white'}`}>{item.item}</p>
                 <span className="text-[10px] text-textMuted uppercase tracking-widest">{item.cat}</span>
               </div>
            </div>
            <div className="w-12 h-2 bg-white/5 rounded-full" />
          </div>
        ))}
      </div>
    </div>
  );
}

function WishlistPreview() {
  return (
    <div className="h-full flex flex-col">
       <div className="flex items-center gap-3 mb-12">
          <Heart size={24} className="text-[#FF6B2C]" />
          <h2 className="text-3xl font-display font-bold tracking-tight">Acquisition Goals</h2>
       </div>
       <div className="grid grid-cols-3 gap-8">
          {[
            { name: 'Mechanical Keyboard', price: '$180', progress: 75 },
            { name: 'Ultra-wide Monitor', price: '$850', progress: 30 },
            { name: 'Ergonomic Chair', price: '$450', progress: 100 },
          ].map((item, i) => (
            <div key={i} className="glass-card p-8 rounded-3xl border border-white/5 flex flex-col gap-6 relative overflow-hidden group">
               <div className="w-full aspect-square bg-white/5 rounded-2xl flex items-center justify-center relative">
                  <Heart size={40} className={`opacity-10 group-hover:scale-110 transition-transform ${item.progress === 100 ? 'text-[#FF6B2C] opacity-50' : ''}`} />
                  {item.progress === 100 && <div className="absolute top-4 right-4 bg-green-500/20 text-green-500 text-[8px] font-bold px-2 py-1 rounded-full uppercase">Collected</div>}
               </div>
               <div>
                  <h3 className="font-bold text-white mb-1">{item.name}</h3>
                  <p className="text-sm text-textMuted font-mono">{item.price}</p>
               </div>
               <div className="h-1.5 w-full bg-white/5 rounded-full overflow-hidden">
                  <motion.div 
                    initial={{ width: 0 }}
                    animate={{ width: `${item.progress}%` }}
                    transition={{ duration: 1, delay: i * 0.2 }}
                    className={`h-full ${item.progress === 100 ? 'bg-green-500' : 'bg-[#FF6B2C]'}`} 
                  />
               </div>
            </div>
          ))}
       </div>
    </div>
  );
}

function StudyPreview() {
  return (
    <div className="h-full flex flex-col">
      <div className="flex items-center justify-between mb-12">
         <div className="space-y-1">
            <h2 className="text-3xl font-display font-bold">Machine Learning 101</h2>
            <p className="text-textMuted text-sm">34 hours completed this month</p>
         </div>
         <div className="flex gap-4">
            <div className="p-4 bg-white/5 rounded-2xl border border-white/5 flex items-center gap-3">
               <BookOpen size={20} className="text-[#FF6B2C]" />
               <span className="font-bold">12/40 Chapters</span>
            </div>
         </div>
      </div>
      <div className="space-y-6">
        {[
          { title: 'Neural Architectures', time: '45m', status: 'Active' },
          { title: 'Backpropagation Logic', time: '1h 20m', status: 'Completed' },
          { title: 'Optimization Functions', time: '30m', status: 'Next' },
        ].map((item, i) => (
          <div key={i} className={`p-6 rounded-2xl border flex items-center justify-between group transition-all ${item.status === 'Active' ? 'bg-[#FF6B2C]/5 border-[#FF6B2C]/20 shadow-xl' : 'bg-white/[0.02] border-white/5 opacity-50'}`}>
            <div className="flex items-center gap-6">
               <div className="w-12 h-12 rounded-xl bg-white/5 flex items-center justify-center font-bold text-white/40">{i + 1}</div>
               <div>
                  <h4 className="font-bold text-white">{item.title}</h4>
                  <p className="text-xs text-textMuted">{item.time} estimated</p>
               </div>
            </div>
            {item.status === 'Active' ? (
              <div className="flex items-center gap-3">
                 <div className="w-2 h-2 rounded-full bg-[#FF6B2C] animate-ping" />
                 <span className="text-[10px] font-bold text-[#FF6B2C] uppercase tracking-widest">In Progress</span>
              </div>
            ) : (
              <div className="w-8 h-8 rounded-full border border-white/10 flex items-center justify-center">
                 {item.status === 'Completed' ? <CheckCircle2 size={16} className="text-green-500" /> : <Plus size={16} className="text-white/20" />}
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}

function ExercisePreview() {
  return (
    <div className="h-full flex flex-col">
       <div className="flex items-center justify-between mb-16">
          <h2 className="text-3xl font-display font-bold">Hypertrophy Session</h2>
          <div className="flex items-center gap-4">
             <div className="text-right">
                <p className="text-[10px] text-textMuted uppercase font-bold tracking-widest">Heart Rate</p>
                <p className="text-xl font-bold font-mono">142 BPM</p>
             </div>
             <div className="w-14 h-14 rounded-2xl bg-red-500/10 flex items-center justify-center">
                <Activity size={24} className="text-red-500 animate-pulse" />
             </div>
          </div>
       </div>
       <div className="grid grid-cols-2 gap-8 flex-1">
          {[
            { name: 'Deadlift', sets: '4 Sets', reps: '8 Reps', weight: '120kg', active: true },
            { name: 'Pull-ups', sets: '3 Sets', reps: 'AMRAP', weight: 'Bodyweight', active: false },
            { name: 'Dumbbell Rows', sets: '4 Sets', reps: '12 Reps', weight: '30kg', active: false },
            { name: 'Hammer Curls', sets: '3 Sets', reps: '15 Reps', weight: '15kg', active: false },
          ].map((ex, i) => (
            <div key={i} className={`p-8 rounded-[2.5rem] border transition-all ${ex.active ? 'bg-[#FF6B2C]/10 border-[#FF6B2C]/40 shadow-2xl scale-105 z-10' : 'bg-white/[0.02] border-white/5 opacity-40'}`}>
               <div className="flex justify-between items-start mb-6">
                  <h3 className="text-xl font-bold text-white">{ex.name}</h3>
                  <Dumbbell size={20} className={ex.active ? 'text-[#FF6B2C]' : 'text-white/10'} />
               </div>
               <div className="grid grid-cols-3 gap-4">
                  <div>
                     <p className="text-[8px] text-textMuted uppercase font-bold tracking-widest">Sets</p>
                     <p className="text-sm font-bold text-white">{ex.sets}</p>
                  </div>
                  <div>
                     <p className="text-[8px] text-textMuted uppercase font-bold tracking-widest">Reps</p>
                     <p className="text-sm font-bold text-white">{ex.reps}</p>
                  </div>
                  <div>
                     <p className="text-[8px] text-textMuted uppercase font-bold tracking-widest">Weight</p>
                     <p className="text-sm font-bold text-[#FF8C42]">{ex.weight}</p>
                  </div>
               </div>
            </div>
          ))}
       </div>
    </div>
  );
}
