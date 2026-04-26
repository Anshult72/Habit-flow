import { useState } from 'react';
import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { LayoutDashboard, ListTodo, BarChart3, Calendar, Settings as SettingsIcon, Menu, X, ArrowLeft } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

const NAV_ITEMS = [
  { path: '/app', label: 'Dashboard', icon: LayoutDashboard, exact: true },
  { path: '/app/habits', label: 'Habits', icon: ListTodo },
  { path: '/app/calendar', label: 'Calendar', icon: Calendar },
  { path: '/app/analytics', label: 'Analytics', icon: BarChart3 },
  { path: '/app/settings', label: 'Settings', icon: SettingsIcon },
];

export default function DashboardLayout() {
  return (
    <div className="min-h-screen bg-[#050505] text-textMain font-sans relative pt-[81px]">
      {/* Main Content Area */}
      <main className="min-h-[calc(100vh-81px)] overflow-y-auto overflow-x-hidden relative">
        <div className="p-6 md:p-10 lg:p-12 w-full max-w-[1400px] mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
          >
            <Outlet />
          </motion.div>
        </div>

        {/* Global Dashboard Ambience */}
        <div className="fixed inset-0 pointer-events-none z-[-1] overflow-hidden">
          <div className="absolute top-[20%] left-[20%] w-[60%] h-[60%] bg-[#FF6B2C]/5 rounded-full blur-[160px]" />
          <div className="absolute bottom-[10%] right-[10%] w-[40%] h-[40%] bg-[#E85D04]/3 rounded-full blur-[120px]" />
        </div>
      </main>
    </div>
  );
}
