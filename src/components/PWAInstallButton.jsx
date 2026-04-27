import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Download, X } from 'lucide-react';
import toast from 'react-hot-toast';

export default function PWAInstallButton() {
  const [deferredPrompt, setDeferredPrompt] = useState(null);
  const [showButton, setShowButton] = useState(false);
  const [dismissed, setDismissed] = useState(false);

  useEffect(() => {
    const handler = (e) => {
      e.preventDefault();
      setDeferredPrompt(e);
      setShowButton(true);
    };
    window.addEventListener('beforeinstallprompt', handler);
    return () => window.removeEventListener('beforeinstallprompt', handler);
  }, []);

  const handleInstall = async () => {
    if (!deferredPrompt) return;
    deferredPrompt.prompt();
    const { outcome } = await deferredPrompt.userChoice;
    if (outcome === 'accepted') {
      toast.success('HabitFlow installed successfully! 🎉');
      setShowButton(false);
    }
    setDeferredPrompt(null);
  };

  if (!showButton || dismissed) return null;

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0, y: 40, scale: 0.9 }}
        animate={{ opacity: 1, y: 0, scale: 1 }}
        exit={{ opacity: 0, y: 40, scale: 0.9 }}
        transition={{ type: 'spring', stiffness: 280, damping: 24 }}
        className="fixed bottom-6 right-6 z-50"
      >
        <div className="relative flex items-center gap-3 px-5 py-4 rounded-2xl border border-[#FF6B2C]/30 bg-black/80 backdrop-blur-2xl shadow-[0_0_40px_rgba(255,107,44,0.2)] group">
          {/* Glow */}
          <div className="absolute inset-0 rounded-2xl bg-gradient-to-r from-[#FF6B2C]/10 to-[#E85D04]/10 opacity-0 group-hover:opacity-100 transition-opacity" />

          <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-[#FF6B2C] to-[#E85D04] flex items-center justify-center shadow-[0_0_15px_rgba(255,107,44,0.5)] shrink-0">
            <Download size={18} className="text-white" />
          </div>

          <div className="relative z-10">
            <p className="text-white font-bold text-sm leading-tight">Install HabitFlow</p>
            <p className="text-textMuted text-xs">Add to home screen</p>
          </div>

          <motion.button
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.9 }}
            onClick={handleInstall}
            className="relative z-10 ml-2 px-4 py-2 rounded-xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white text-xs font-bold shadow-[0_0_15px_rgba(255,107,44,0.4)] hover:shadow-[0_0_25px_rgba(255,107,44,0.7)] transition-all"
          >
            Install
          </motion.button>

          <button
            onClick={() => setDismissed(true)}
            className="relative z-10 text-textMuted hover:text-white transition-colors ml-1"
          >
            <X size={16} />
          </button>
        </div>
      </motion.div>
    </AnimatePresence>
  );
}
