'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useRouter, usePathname } from 'next/navigation';
import { 
  Menu, X, ChevronDown, LayoutDashboard, ListChecks, 
  Calendar as CalendarIcon, BarChart3, Sparkles, ArrowRight
} from 'lucide-react';

export default function Navbar() {
  const router = useRouter();
  const pathname = usePathname();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [isTrackerHovered, setIsTrackerHovered] = useState(false);
  const [isTrackerMobileOpen, setIsTrackerMobileOpen] = useState(false);
  const [hoveredLink, setHoveredLink] = useState(null);
  
  const [showNavbar, setShowNavbar] = useState(true);
  const [lastScrollY, setLastScrollY] = useState(0);

  useEffect(() => {
    const handleScroll = () => {
      if (typeof window !== 'undefined') {
        const currentScrollY = window.scrollY;
        
        // Hide on scroll down (threshold > 50), show on scroll up
        if (currentScrollY > lastScrollY && currentScrollY > 50) {
          setShowNavbar(false);
        } else if (currentScrollY < lastScrollY) {
          setShowNavbar(true);
        }
        
        setLastScrollY(currentScrollY);
      }
    };

    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, [lastScrollY]);

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
      label: 'Explore All Features →', 
      path: '/features', 
      icon: Sparkles, 
      desc: 'Discover the full ecosystem',
      color: '#a855f7'
    }
  ];

  const otherLinks = [
    { label: 'Features', path: '/features' },
    { label: 'Premium', path: '/premium' },
    { label: 'Help Center', path: '/help-center' },
    { label: 'Productivity Hub', path: '/productivity-hub' },
  ];

  const isActive = (path) => pathname === path;
  const isTrackerActive = trackerItems.some(item => isActive(item.path));

  const isAnyHovered = isTrackerHovered || hoveredLink !== null;

  return (
    <>
      <nav className={`fixed top-0 left-0 right-0 px-8 md:px-12 py-5 flex justify-between items-center z-50 bg-[#050505]/40 backdrop-blur-2xl border-b border-white/[0.05] shadow-[0_4px_30px_rgba(0,0,0,0.5)] transition-transform duration-300 ${
        showNavbar ? 'translate-y-0' : '-translate-y-full'
      }`}>
        <button
          onClick={() => router.push('/')}
          className="group flex items-center gap-4 hover:opacity-100 transition-all duration-500"
        >
          <div className="relative">
            <div className="absolute inset-0 bg-[#FF6B2C]/20 blur-xl rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
            <img 
              src="/assets/eagle-logo-transparent.png" 
              alt="HabitFlow Eagle" 
              className="w-12 h-12 object-contain relative z-10 group-hover:scale-110 group-hover:rotate-[2deg] transition-all duration-500 ease-out"
            />
            <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-1 h-1 bg-[#FF6B2C] rounded-full blur-[2px] opacity-0 group-hover:opacity-100 transition-opacity duration-500 shadow-[0_0_8px_#FF6B2C]" />
          </div>
          
          <div className="flex flex-col items-start leading-tight">
            <span className="text-2xl font-bold font-display tracking-tight text-white group-hover:text-[#FF8C42] transition-colors duration-500">
              HabitFlow
            </span>
            <span className="text-[10px] font-bold text-text-muted uppercase tracking-[0.3em] group-hover:text-[#FF6B2C] transition-colors duration-500">
              Elite Performance
            </span>
          </div>
        </button>

        <div className="hidden md:flex items-center gap-10 absolute left-1/2 -translate-x-1/2">
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
                            router.push(item.path);
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
                            <p className="text-[11px] text-text-muted font-light mt-0.5 leading-tight">
                              {item.desc}
                            </p>
                          </div>
                          <div className="absolute right-2 top-1/2 -translate-y-1/2 opacity-0 group-hover/item:opacity-100 group-hover/item:translate-x-0 translate-x-2 transition-all duration-300">
                            <ArrowRight size={14} className="text-[#FF6B2C]" />
                          </div>
                        </button>
                      );
                    })}
                  </div>
                  <div className="mt-4 pt-4 border-t border-white/5 flex items-center justify-between px-2">
                    <p className="text-[10px] text-text-muted/60 uppercase tracking-[0.2em] font-medium">HabitFlow v2.4</p>
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
              onClick={() => router.push(item.path)}
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


        </div>

        <div className="flex items-center gap-4">
          <button
            onClick={() => router.push('/app')}
            className="px-6 py-2.5 rounded-xl bg-white/5 border border-white/10 hover:border-[#FF6B2C]/40 text-white/90 hover:text-white font-medium transition-all shadow-sm hover:shadow-[0_0_15px_rgba(255,107,44,0.2)] backdrop-blur-md hidden md:block active:scale-95"
          >
            Login
          </button>
          <button
            onClick={() => router.push('/onboarding')}
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
                                router.push(item.path);
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
                      router.push(item.path);
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

              </div>
              <div className="flex flex-col gap-4">
                <button
                  onClick={() => router.push('/app')}
                  className="w-full py-3 rounded-lg bg-black/40 border border-[#FF6B2C]/30 text-[#FF8C42] font-medium shadow-[0_0_15px_rgba(255,107,44,0.15)]"
                >
                  Login
                </button>
                <button
                  onClick={() => router.push('/onboarding')}
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
