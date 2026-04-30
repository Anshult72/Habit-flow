'use client';

import React from 'react';
import { AlertTriangle, RefreshCcw, Home } from 'lucide-react';
import { motion } from 'framer-motion';

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error("HabitFlow Caught Error:", error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="flex flex-col items-center justify-center h-full min-h-[60vh] text-center px-4">
          <motion.div 
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            className="glass-card p-10 rounded-[2.5rem] border border-red-500/20 relative overflow-hidden max-w-lg w-full"
          >
            <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 bg-red-500/10 rounded-full blur-[80px] pointer-events-none" />
            
            <div className="absolute top-4 right-4 opacity-20">
              <img src="/assets/eagle-logo-simplified.png" alt="Logo" className="w-8 h-8 object-contain" />
            </div>
            
            <div className="w-20 h-20 rounded-3xl bg-red-500/10 flex items-center justify-center mx-auto mb-6 border border-red-500/20">
              <AlertTriangle size={36} className="text-red-500" />
            </div>
            
            <h2 className="text-2xl font-display font-bold text-white mb-3">Module Offline</h2>
            <p className="text-text-muted mb-8 text-sm">
              The operational module encountered an unexpected anomaly. Our systems have logged the incident.
            </p>
            
            <div className="flex gap-4 justify-center">
              <button 
                onClick={() => window.location.reload()}
                className="px-6 py-3 rounded-xl bg-white/5 border border-white/10 hover:bg-white/10 text-white text-sm font-bold flex items-center gap-2 transition-all"
              >
                <RefreshCcw size={16} /> Reboot System
              </button>
              <button 
                onClick={() => window.location.href = '/app'}
                className="px-6 py-3 rounded-xl bg-[#FF6B2C] text-white text-sm font-bold flex items-center gap-2 shadow-[0_0_20px_rgba(255,107,44,0.3)] hover:scale-105 transition-all"
              >
                <Home size={16} /> Return to Hub
              </button>
            </div>
          </motion.div>
        </div>
      );
    }

    return this.props.children; 
  }
}

export default ErrorBoundary;
