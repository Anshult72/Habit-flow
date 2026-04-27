import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useNavigate, useLocation } from 'react-router-dom';
import { 
  Menu, X, ChevronDown, LayoutDashboard, ListChecks, 
  Calendar as CalendarIcon, BarChart3, Sparkles, ArrowRight,
  Settings, Award, FileText
} from 'lucide-react';

export default function Navbar() {
  const navigate = useNavigate();
  const location = useLocation();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [isResourcesHovered, setIsResourcesHovered] = useState(false);
  const [isTrackerHovered, setIsTrackerHovered] = useState(false);
  const [isTrackerMobileOpen, setIsTrackerMobileOpen] = useState(false);
  const [hoveredLink, setHoveredLink] = useState(null);

  const trackerItems = [
    { 
      label: 'Dashboard', 
      path: '/app', 
      icon: LayoutDashboard, 
      desc: 'Real-time performance overview',
      color: '#FF6B2C'
    },
    { 
      label: 'Habits', 
      path: '/app/habits', 
      icon: ListChecks, 
      desc: 'Track and manage routines',
      color: '#FF8C42'
    },
    { 
      label: 'Calendar', 
      path: '/app/calendar', 
      icon: CalendarIcon, 
      desc: 'Schedule your productivity',
      color: '#FFB347'
    },
    { 
      label: 'Analytics', 
      path: '/app/analytics', 
      icon: BarChart3, 
      desc: 'Advanced data insights',
      color: '#E85D04'
    },
    { 
      label: 'Reports', 
      path: '/app/reports', 
      icon: FileText, 
      desc: 'Weekly & monthly summaries',
      color: '#a855f7'
    },
    { 
      label: 'Achievements', 
      path: '/app/achievements', 
      icon: Award, 
      desc: 'Trophies and milestones',
      color: '#FF6B2C'
    },
    { 
      label: 'Settings', 
      path: '/app/settings', 
      icon: Settings, 
      desc: 'Configure your experience',
      color: '#FFB347'
    },
  ];

  const otherLinks = [
    { label: 'Features', path: '/features' },
    { label: 'Premium', path: '/premium' },
  ];

  const isActive = (path) => location.pathname === path;
  const isTrackerActive = trackerItems.some(item => isActive(item.path));

  // Safety check to ensure we don't render multiple layoutId indicators simultaneously
  const isAnyHovered = isTrackerHovered || isResourcesHovered || hoveredLink !== null;

  return (
    <>
      <nav className="fixed top-0 left-0 right-0 px-8 md:px-12 py-5 flex justify-between items-center z-50 bg-[#050505]/40 backdrop-blur-2xl border-b border-white/[0.05] shadow-[0_4px_30px_rgba(0,0,0,0.5)]">
        {/* Left Side: Logo */}
        <button
          onClick={() => navigate('/')}
          className="text-2xl font-bold font-display tracking-tight text-white flex items-center gap-3 hover:opacity-90 transition-opacity"
        >
          <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-[#FF6B2C] to-[#E85D04] flex items-center justify-center shadow-[0_0_20px_rgba(255,107,44,0.4)]">
            <span className="text-white text-xl">H</span>
          </div>
          HabitFlow
        </button>

        {/* Center: Links */}
        <div className="hidden md:flex items-center gap-10 absolute left-1/2 -translate-x-1/2">
          {/* Tracker Dropdown (Desktop) */}
          <div
            className="relative"
            onMouseEnter={() => setIsTrackerHovered(true)}
            onMouseLeave={() => setIsTrackerHovered(false)}
          >
            <button
              className={`flex items-center gap-1.5 font-medium text-lg transition-colors group relative py-1 ${
                isTrackerActive ? 'text-white' : 'text-white/70 hover:text-white'
              }`}
            >
              Tracker
              <ChevronDown
                size={18}
                className={`transition-transform duration-300 ${
                  isTrackerHovered ? 'rotate-180 text-[#FF6B2C]' : ''
                }`}
              />
              
              {/* Active Indicator */}
              <AnimatePresence>
                {(isTrackerHovered || (isTrackerActive && !isAnyHovered)) && (
                  <motion.div
                    layoutId="navbar-active-indicator"
                    className="absolute -bottom-1.5 left-0 right-0 h-[2px] bg-gradient-to-r from-[#FF6B2C] to-[#FFB347] shadow-[0_0_12px_rgba(255,107,44,0.8)] z-10"
                    initial={{ opacity: 0, scaleX: 0 }}
                    animate={{ opacity: 1, scaleX: 1 }}
                    exit={{ opacity: 0, scaleX: 0 }}
                    transition={{ type: 'spring', stiffness: 380, damping: 30 }}
                  />
                )}
              </AnimatePresence>
              {/* Ambient Active Light */}
              {isTrackerActive && (
                <div className="absolute -bottom-6 left-1/2 -translate-x-1/2 w-12 h-6 bg-[#FF6B2C]/20 blur-xl rounded-full pointer-events-none" />
              )}
            </button>

            <AnimatePresence>
              {isTrackerHovered && (
                <motion.div
                  initial={{ opacity: 0, y: 15, scale: 0.95 }}
                  animate={{ opacity: 1, y: 0, scale: 1 }}
                  exit={{ opacity: 0, y: 15, scale: 0.95 }}
                  transition={{ duration: 0.2, ease: [0.16, 1, 0.3, 1] }}
                  className="absolute top-full mt-7 left-1/2 -translate-x-1/2 w-[480px] bg-[#0A0A0A]/95 backdrop-blur-3xl border border-white/[0.08] rounded-2xl overflow-hidden shadow-[0_30px_60px_rgba(0,0,0,0.8),0_0_40px_rgba(255,107,44,0.1)] p-4"
                >
                  <div className="grid grid-cols-2 gap-2">
                    {trackerItems.map((item) => {
                      const Icon = item.icon;
                      return (
                        <button
                          key={item.label}
                          onClick={() => {
                            navigate(item.path);
                            setIsTrackerHovered(false);
                          }}
                          className={`flex items-start gap-4 p-4 rounded-xl transition-all duration-300 group/item relative overflow-hidden ${
                            isActive(item.path)
                              ? 'bg-[#FF6B2C]/10 border border-[#FF6B2C]/20'
                              : 'hover:bg-white/5 border border-transparent hover:border-white/10'
                          }`}
                        >
                          <div 
                            className={`w-10 h-10 rounded-lg flex items-center justify-center transition-all duration-300 ${
                              isActive(item.path) ? 'bg-[#FF6B2C] text-white shadow-[0_0_15px_rgba(255,107,44,0.4)]' : 'bg-white/5 text-white/40 group-hover/item:text-[#FF8C42] group-hover/item:bg-[#FF6B2C]/10'
                            }`}
                          >
                            {Icon && <Icon size={20} />}
                          </div>
                          <div className="text-left">
                            <p className={`font-bold text-sm transition-colors ${
                              isActive(item.path) ? 'text-white' : 'text-white/80 group-hover/item:text-white'
                            }`}>
                              {item.label}
                            </p>
                            <p className="text-[11px] text-textMuted font-light mt-0.5 leading-tight">
                              {item.desc}
                            </p>
                          </div>
                          {/* Hover Indicator */}
                          <div className="absolute right-2 top-1/2 -translate-y-1/2 opacity-0 group-hover/item:opacity-100 group-hover/item:translate-x-0 translate-x-2 transition-all duration-300">
                            <ArrowRight size={14} className="text-[#FF6B2C]" />
                          </div>
                        </button>
                      );
                    })}
                  </div>
                  {/* Bottom Decor */}
                  <div className="mt-4 pt-4 border-t border-white/5 flex items-center justify-between px-2">
                    <p className="text-[10px] text-textMuted/60 uppercase tracking-[0.2em] font-medium">HabitFlow v2.4</p>
                    <div className="flex items-center gap-1 text-[#FF8C42] text-[11px] font-semibold">
                      <Sparkles size={12} />
                      AI Powered
                    </div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          {otherLinks.map((item) => (
            <button
              key={item.label}
              onMouseEnter={() => setHoveredLink(item.label)}
              onMouseLeave={() => setHoveredLink(null)}
              onClick={() => navigate(item.path)}
              className={`font-medium text-lg relative group transition-colors py-1 ${
                isActive(item.path) ? 'text-white' : 'text-white/70 hover:text-white'
              }`}
            >
              {item.label}
              <AnimatePresence>
                {(hoveredLink === item.label || (isActive(item.path) && !isAnyHovered)) && (
                  <motion.div
                    layoutId="navbar-active-indicator"
                    className="absolute -bottom-1.5 left-0 right-0 h-[2px] bg-gradient-to-r from-[#FF6B2C] to-[#FFB347] shadow-[0_0_12px_rgba(255,107,44,0.8)] z-10"
                    initial={{ opacity: 0, scaleX: 0 }}
                    animate={{ opacity: 1, scaleX: 1 }}
                    exit={{ opacity: 0, scaleX: 0 }}
                    transition={{ type: 'spring', stiffness: 380, damping: 30 }}
                  />
                )}
              </AnimatePresence>
              {isActive(item.path) && (
                <div className="absolute -bottom-6 left-1/2 -translate-x-1/2 w-12 h-6 bg-[#FF6B2C]/20 blur-xl rounded-full pointer-events-none" />
              )}
              {!isActive(item.path) && (
                <span className="absolute -bottom-1.5 left-0 w-0 h-[2px] bg-gradient-to-r from-[#FF6B2C] to-[#FFB347] transition-all group-hover:w-full opacity-50" />
              )}
            </button>
          ))}

          <div
            className="relative"
            onMouseEnter={() => setIsResourcesHovered(true)}
            onMouseLeave={() => setIsResourcesHovered(false)}
          >
            <button
              className={`flex items-center gap-1.5 font-medium text-lg transition-colors group relative py-1 ${
                location.pathname === '/help'
                  ? 'text-white'
                  : 'text-white/70 hover:text-white'
              }`}
            >
              Resources
              <ChevronDown
                size={18}
                className={`transition-transform duration-300 ${
                  isResourcesHovered ? 'rotate-180 text-[#FF6B2C]' : ''
                }`}
              />
              <AnimatePresence>
                {(isResourcesHovered || (location.pathname === '/help' && !isAnyHovered)) && (
                  <motion.div
                    layoutId="navbar-active-indicator"
                    className="absolute -bottom-1.5 left-0 right-0 h-[2px] bg-gradient-to-r from-[#FF6B2C] to-[#FFB347] shadow-[0_0_12px_rgba(255,107,44,0.8)] z-10"
                    initial={{ opacity: 0, scaleX: 0 }}
                    animate={{ opacity: 1, scaleX: 1 }}
                    exit={{ opacity: 0, scaleX: 0 }}
                    transition={{ type: 'spring', stiffness: 380, damping: 30 }}
                  />
                )}
              </AnimatePresence>
              {location.pathname === '/help' && (
                <div className="absolute -bottom-6 left-1/2 -translate-x-1/2 w-12 h-6 bg-[#FF6B2C]/20 blur-xl rounded-full pointer-events-none" />
              )}
            </button>

            <AnimatePresence>
              {isResourcesHovered && (
                <motion.div
                  initial={{ opacity: 0, y: 15, scale: 0.95 }}
                  animate={{ opacity: 1, y: 0, scale: 1 }}
                  exit={{ opacity: 0, y: 15, scale: 0.95 }}
                  transition={{ duration: 0.2, ease: [0.16, 1, 0.3, 1] }}
                  className="absolute top-full mt-7 left-1/2 -translate-x-1/2 w-56 bg-[#0A0A0A]/95 backdrop-blur-3xl border border-white/[0.08] rounded-xl overflow-hidden shadow-[0_20px_40px_rgba(0,0,0,0.6)] flex flex-col p-2"
                >
                  <button
                    onClick={() => navigate('/help')}
                    className="w-full text-left px-4 py-3 text-white/80 hover:text-[#FF8C42] hover:bg-[#FF6B2C]/10 rounded-lg transition-colors font-medium"
                  >
                    Help Center
                  </button>
                  <a
                    href="#"
                    className="px-4 py-3 text-white/80 hover:text-[#FF8C42] hover:bg-[#FF6B2C]/10 rounded-lg transition-colors font-medium"
                  >
                    Productivity Guides
                  </a>
                </motion.div>
              )}
            </AnimatePresence>
          </div>
        </div>

        {/* Right Side: Auth */}
        <div className="flex items-center gap-4">
          <button
            onClick={() => navigate('/app')}
            className="px-6 py-2.5 rounded-xl bg-white/5 border border-white/10 hover:border-[#FF6B2C]/40 text-white/90 hover:text-white font-medium transition-all shadow-sm hover:shadow-[0_0_15px_rgba(255,107,44,0.2)] backdrop-blur-md hidden md:block active:scale-95"
          >
            Login
          </button>
          <button
            onClick={() => navigate('/onboarding')}
            className="px-6 py-2.5 rounded-xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white font-semibold transition-all shadow-[0_0_20px_rgba(255,107,44,0.3)] hover:shadow-[0_0_35px_rgba(255,107,44,0.6)] hidden md:block active:scale-95"
          >
            Sign Up
          </button>

          <button
            className="md:hidden text-white hover:text-[#FF6B2C] transition-colors ml-2"
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
          >
            {isMobileMenuOpen ? <X size={32} /> : <Menu size={32} />}
          </button>
        </div>
      </nav>

      {/* Mobile Menu */}
      <AnimatePresence>
        {isMobileMenuOpen && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            className="fixed top-[81px] left-0 right-0 z-40 bg-[#050505]/95 backdrop-blur-xl border-b border-[#FF6B2C]/20 shadow-[0_10px_30px_rgba(0,0,0,0.8)] md:hidden overflow-hidden"
          >
            <div className="flex flex-col p-6 gap-6">
              <div className="flex flex-col gap-4 border-b border-white/10 pb-6">
                {/* Tracker Expandable (Mobile) */}
                <div className="flex flex-col">
                  <button
                    onClick={() => setIsTrackerMobileOpen(!isTrackerMobileOpen)}
                    className={`text-xl font-medium text-left transition-all flex items-center justify-between ${
                      isTrackerActive ? 'text-[#FF6B2C]' : 'text-white/80'
                    }`}
                  >
                    Tracker
                    <ChevronDown size={20} className={`transition-transform duration-300 ${isTrackerMobileOpen ? 'rotate-180 text-[#FF6B2C]' : ''}`} />
                  </button>
                  <AnimatePresence>
                    {isTrackerMobileOpen && (
                      <motion.div
                        initial={{ opacity: 0, height: 0 }}
                        animate={{ opacity: 1, height: 'auto' }}
                        exit={{ opacity: 0, height: 0 }}
                        className="flex flex-col gap-3 pl-4 mt-4 overflow-hidden"
                      >
                        {trackerItems.map((item) => {
                          const Icon = item.icon;
                          return (
                            <button
                              key={item.label}
                              onClick={() => {
                                navigate(item.path);
                                setIsMobileMenuOpen(false);
                              }}
                              className={`flex items-center gap-3 py-2 text-base transition-colors ${
                                isActive(item.path) ? 'text-[#FF8C42]' : 'text-white/50 hover:text-[#FF6B2C]'
                              }`}
                            >
                              {Icon && <Icon size={18} />}
                              {item.label}
                            </button>
                          );
                        })}
                      </motion.div>
                    )}
                  </AnimatePresence>
                </div>

                {otherLinks.map((item) => (
                  <button
                    key={item.label}
                    onClick={() => {
                      navigate(item.path);
                      setIsMobileMenuOpen(false);
                    }}
                    className={`text-xl font-medium text-left transition-all ${
                      isActive(item.path)
                        ? 'text-[#FF6B2C]'
                        : 'text-white/80 hover:text-[#FF6B2C]'
                    }`}
                  >
                    {item.label}
                  </button>
                ))}
                <button
                  onClick={() => {
                    navigate('/help');
                    setIsMobileMenuOpen(false);
                  }}
                  className={`text-xl font-medium text-left transition-all ${
                    location.pathname === '/help'
                      ? 'text-[#FF6B2C]'
                      : 'text-white/80 hover:text-[#FF6B2C]'
                  }`}
                >
                  Help Center
                </button>
              </div>
              <div className="flex flex-col gap-4">
                <button
                  onClick={() => navigate('/app')}
                  className="w-full py-3 rounded-lg bg-black/40 border border-[#FF6B2C]/30 text-[#FF8C42] font-medium shadow-[0_0_15px_rgba(255,107,44,0.15)]"
                >
                  Login
                </button>
                <button
                  onClick={() => navigate('/onboarding')}
                  className="w-full py-3 rounded-lg bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white font-bold shadow-[0_0_25px_rgba(255,107,44,0.4)]"
                >
                  Sign Up
                </button>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
