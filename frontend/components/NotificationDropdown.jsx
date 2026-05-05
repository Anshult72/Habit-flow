'use client';

import { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Bell, Sword, Users, Check, X, Info } from 'lucide-react';
import { apiFetch } from '@/lib/api';
import useStore from '@/store/useStore';
import toast from 'react-hot-toast';

export default function NotificationDropdown() {
  const [isOpen, setIsOpen] = useState(false);
  const [notifications, setNotifications] = useState([]);
  const dropdownRef = useRef(null);
  const { syncData } = useStore();

  const fetchNotifications = async () => {
    try {
      const data = await apiFetch('/notifications');
      setNotifications(data || []);
    } catch (e) {
      console.error('Failed to fetch notifications', e);
    }
  };

  useEffect(() => {
    if (isOpen) {
      fetchNotifications();
    }
  }, [isOpen]);

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target)) {
        setIsOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleRespond = async (notif, accept) => {
    try {
      const { type, metadata } = notif;
      let endpoint = '';
      if (type === 'duel_request') {
        endpoint = `/duels/requests/${metadata.requestId}/respond`;
      } else if (type === 'squad_request') {
        endpoint = `/squads/requests/${metadata.requestId}/respond`;
      }

      if (endpoint) {
        await apiFetch(endpoint, {
          method: 'POST',
          body: JSON.stringify({ accept }),
        });
        toast.success(accept ? 'Accepted!' : 'Declined');
        await apiFetch(`/notifications/${notif.id}/read`, { method: 'PATCH' });
        await fetchNotifications();
        await syncData();
      }
    } catch (e) {
      toast.error(e.message || 'Operation failed');
    }
  };

  const unreadCount = notifications.filter(n => !n.isRead).length;

  return (
    <div className="relative" ref={dropdownRef}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="w-10 h-10 rounded-xl bg-surface border border-surfaceBorder flex items-center justify-center hover:bg-surfaceBorder transition-all text-textMuted hover:text-textMain relative"
      >
        <Bell size={18} />
        {unreadCount > 0 && (
          <span className="absolute -top-1 -right-1 w-5 h-5 bg-[#FF6B2C] text-white text-[10px] font-bold rounded-full flex items-center justify-center border-2 border-background">
            {unreadCount}
          </span>
        )}
      </button>

      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, y: 10, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 10, scale: 0.95 }}
            className="absolute right-0 mt-3 w-80 bg-[#0A0A0A] border border-white/10 rounded-2xl shadow-[0_20px_40px_rgba(0,0,0,0.8)] overflow-hidden z-50"
          >
            <div className="p-4 border-b border-white/5 flex justify-between items-center bg-white/[0.02]">
              <h4 className="text-white font-bold text-sm">Notifications</h4>
              {unreadCount > 0 && <span className="text-[10px] text-[#FF6B2C] font-bold uppercase tracking-wider">{unreadCount} New</span>}
            </div>

            <div className="max-h-96 overflow-y-auto">
              {notifications.length === 0 ? (
                <div className="p-8 text-center">
                  <Bell size={32} className="mx-auto text-white/10 mb-3" />
                  <p className="text-textMuted text-xs">No notifications yet</p>
                </div>
              ) : (
                notifications.map((n) => (
                  <div
                    key={n.id}
                    className={`p-4 border-b border-white/5 hover:bg-white/[0.02] transition-colors ${!n.isRead ? 'bg-[#FF6B2C]/5' : ''}`}
                  >
                    <div className="flex gap-3">
                      <div className={`w-8 h-8 rounded-lg flex items-center justify-center shrink-0 ${
                        n.type.includes('duel') ? 'bg-[#FF6B2C]/20 text-[#FF6B2C]' :
                        n.type.includes('squad') ? 'bg-blue-500/20 text-blue-400' : 'bg-white/10 text-white/40'
                      }`}>
                        {n.type.includes('duel') ? <Sword size={14} /> :
                         n.type.includes('squad') ? <Users size={14} /> : <Info size={14} />}
                      </div>
                      <div className="flex-1">
                        <p className="text-white text-xs font-bold leading-tight">{n.title}</p>
                        <p className="text-textMuted text-[11px] mt-1 leading-normal">{n.message}</p>
                        
                        {(n.type === 'duel_request' || n.type === 'squad_request') && !n.isRead && (
                          <div className="flex gap-2 mt-3">
                            <button
                              onClick={() => handleRespond(n, true)}
                              className="flex-1 py-1.5 rounded-lg bg-[#FF6B2C] text-white text-[10px] font-bold uppercase tracking-wider hover:bg-[#E85D04] transition-colors flex items-center justify-center gap-1"
                            >
                              <Check size={10} /> Accept
                            </button>
                            <button
                              onClick={() => handleRespond(n, false)}
                              className="flex-1 py-1.5 rounded-lg bg-white/5 border border-white/10 text-white/60 text-[10px] font-bold uppercase tracking-wider hover:bg-white/10 transition-colors flex items-center justify-center gap-1"
                            >
                              <X size={10} /> Decline
                            </button>
                          </div>
                        )}
                        <p className="text-[9px] text-white/20 mt-2">{new Date(n.createdAt).toLocaleString()}</p>
                      </div>
                    </div>
                  </div>
                ))
              )}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
