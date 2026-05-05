'use client';

import { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { User, LogOut, Settings } from 'lucide-react';
import useStore from '@/store/useStore';
import { useRouter } from 'next/navigation';
import { useLogout } from '@/hooks/useLogout';

export default function ProfileDropdown() {
  const [isOpen, setIsOpen] = useState(false);
  const { user } = useStore();
  const router = useRouter();
  const logout = useLogout();
  const dropdownRef = useRef(null);

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target)) {
        setIsOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  if (!user) return null;

  const displayAvatar = user.avatarUrl || `https://api.dicebear.com/7.x/initials/svg?seed=${user.email || 'User'}&backgroundColor=FF6B2C`;

  return (
    <div className="relative" ref={dropdownRef}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center gap-2 pl-2 pr-4 py-1.5 rounded-full bg-surface border border-surfaceBorder hover:border-white/20 transition-all focus:outline-none"
      >
        <div className="w-7 h-7 rounded-full overflow-hidden border border-[#FF6B2C]/30 bg-[#1A1A1A]">
          <img src={displayAvatar} alt={user.name || 'Profile'} className="w-full h-full object-cover" />
        </div>
        <span className="text-sm font-medium text-white max-w-[100px] truncate">
          {user.name || user.email?.split('@')[0]}
        </span>
      </button>

      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, y: 10, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 10, scale: 0.95 }}
            transition={{ duration: 0.15 }}
            className="absolute right-0 mt-3 w-64 bg-[#0A0A0A] border border-white/10 rounded-2xl shadow-[0_20px_40px_rgba(0,0,0,0.8)] overflow-hidden z-50"
          >
            <div className="p-4 border-b border-white/5 flex items-center gap-3 bg-gradient-to-br from-white/[0.02] to-transparent">
              <div className="w-12 h-12 rounded-full overflow-hidden border border-[#FF6B2C]/30 bg-[#1A1A1A] shrink-0">
                <img src={displayAvatar} alt={user.name || 'Profile'} className="w-full h-full object-cover" />
              </div>
              <div className="overflow-hidden">
                <h4 className="text-white font-bold text-sm truncate">{user.name || 'HabitFlow User'}</h4>
                <p className="text-text-muted text-xs truncate">{user.email}</p>
                <button 
                  onClick={(e) => {
                    e.stopPropagation();
                    navigator.clipboard.writeText(user.userId);
                    import('react-hot-toast').then(t => t.default.success('ID Copied!'));
                  }}
                  className="mt-2 flex items-center gap-1.5 px-2 py-1 rounded-lg bg-white/5 border border-white/10 hover:border-white/20 transition-all group"
                >
                  <span className="text-[10px] font-bold text-white/40 uppercase tracking-widest group-hover:text-white/60">
                    ID: <span className="text-[#FF8C42]">#{user.userId || '---'}</span>
                  </span>
                  <div className="w-3.5 h-3.5 flex items-center justify-center text-white/20 group-hover:text-[#FF8C42]">
                    <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><rect width="14" height="14" x="8" y="8" rx="2" ry="2"/><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/></svg>
                  </div>
                </button>
              </div>
            </div>

            <div className="p-2">
              <button
                onClick={() => {
                  setIsOpen(false);
                  router.push('/app/account');
                }}
                className="w-full flex items-center gap-3 px-3 py-2 rounded-xl text-sm font-medium text-white/80 hover:text-white hover:bg-white/5 transition-colors"
              >
                <Settings size={16} />
                Account Settings
              </button>
              
              <button
                onClick={() => {
                  setIsOpen(false);
                  logout();
                }}
                className="w-full flex items-center gap-3 px-3 py-2 rounded-xl text-sm font-medium text-red-400 hover:text-red-300 hover:bg-red-500/10 transition-colors mt-1"
              >
                <LogOut size={16} />
                Sign Out
              </button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
