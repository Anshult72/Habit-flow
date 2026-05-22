'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { AlertTriangle, ChevronLeft, ChevronRight } from 'lucide-react';

/**
 * Soft unlock warning dialog for module progression.
 * Shows when user tries to open a module before completing the previous one.
 * Users can still proceed — this is a soft warning, not a hard lock.
 */
export default function SoftUnlockDialog({ isOpen, previousModuleTitle, onContinue, onGoBack }) {
  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 z-[5000] flex items-center justify-center p-4 bg-black/80 backdrop-blur-2xl"
        >
          <motion.div
            initial={{ scale: 0.9, y: 20 }}
            animate={{ scale: 1, y: 0 }}
            exit={{ scale: 0.9, y: 10, opacity: 0 }}
            transition={{ type: 'spring', stiffness: 400, damping: 25 }}
            className="w-full max-w-md overflow-hidden rounded-3xl border border-[#FF8C42]/20 relative"
            style={{
              background: 'rgba(10, 10, 10, 0.95)',
              boxShadow: '0 30px 80px rgba(255, 140, 66, 0.15), 0 0 0 1px rgba(255,255,255,0.05)',
            }}
          >
            {/* Warning glow bar */}
            <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-[#FF8C42] via-[#FF6B2C] to-[#E85D04]" />

            <div className="p-8 space-y-6">
              {/* Icon + Header */}
              <div className="flex items-start gap-5">
                <motion.div
                  initial={{ rotate: -10 }}
                  animate={{ rotate: [0, -5, 5, 0] }}
                  transition={{ duration: 0.6, delay: 0.3 }}
                  className="w-14 h-14 rounded-2xl bg-[#FF8C42]/10 border border-[#FF8C42]/20 flex items-center justify-center flex-shrink-0"
                >
                  <AlertTriangle size={26} className="text-[#FF8C42]" />
                </motion.div>
                <div className="space-y-2">
                  <h3 className="text-xl font-display font-black text-white">Sequence Warning</h3>
                  <p className="text-sm text-white/50 leading-relaxed">
                    The previous module <span className="text-[#FF8C42] font-bold">&ldquo;{previousModuleTitle}&rdquo;</span> is 
                    incomplete. Continue anyway?
                  </p>
                </div>
              </div>

              {/* Info note */}
              <div className="px-4 py-3 rounded-xl bg-white/3 border border-white/5">
                <p className="text-[10px] text-white/30 font-bold uppercase tracking-widest">
                  HabitFlow supports self-directed learning. You retain full freedom to progress in any order.
                </p>
              </div>

              {/* Action buttons */}
              <div className="flex gap-3">
                <button
                  onClick={onGoBack}
                  className="flex-1 py-4 rounded-2xl border border-white/10 text-white/60 font-bold text-sm hover:bg-white/5 transition-all flex items-center justify-center gap-2"
                >
                  <ChevronLeft size={18} />
                  Go Back
                </button>
                <button
                  onClick={onContinue}
                  className="flex-[2] py-4 rounded-2xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white font-bold text-sm shadow-[0_10px_30px_rgba(255,107,44,0.3)] hover:shadow-[0_15px_40px_rgba(255,107,44,0.5)] transition-all flex items-center justify-center gap-2"
                >
                  Continue
                  <ChevronRight size={18} />
                </button>
              </div>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
