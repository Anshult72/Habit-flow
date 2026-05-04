'use client';

import { motion } from 'framer-motion';
import { Construction, ArrowLeft } from 'lucide-react';
import { useRouter, usePathname } from 'next/navigation';

export default function Placeholder({ title }) {
  const router = useRouter();
  const pathname = usePathname();
  const displayTitle = title || pathname.split('/').pop().replace(/-/g, ' ');

  return (
    <div className="flex flex-col items-center justify-center min-h-[70vh] text-center px-4 relative">
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[500px] bg-[#FF6B2C]/5 rounded-full blur-[120px] pointer-events-none" />
      
      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="glass-card p-12 rounded-[3rem] border border-white/5 max-w-xl w-full relative overflow-hidden group"
      >
        <div className="absolute top-6 right-8 opacity-10">
          <img src="/assets/eagle-logo-simplified.png" alt="Logo" className="w-10 h-10 object-contain" />
        </div>
        
        <div className="w-24 h-24 rounded-[2rem] bg-gradient-to-br from-white/5 to-white/[0.01] border border-white/10 flex items-center justify-center mx-auto mb-8 shadow-2xl relative group-hover:scale-110 transition-transform duration-500">
          <div className="absolute inset-0 bg-[#FF6B2C]/10 rounded-[2rem] blur-xl opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
          <Construction size={40} className="text-[#FF8C42] relative z-10" />
        </div>
        
        <h1 className="text-4xl font-display font-bold text-white mb-4 capitalize tracking-tight">
          {displayTitle} <span className="text-transparent bg-clip-text bg-gradient-to-r from-white/20 to-white/5">Module</span>
        </h1>
        
        <p className="text-textMuted text-lg leading-relaxed mb-10 max-w-sm mx-auto">
          This section is currently under construction in the neural forge. Check back in a future update.
        </p>
        
        <button 
          onClick={() => router.push('/app')}
          className="px-8 py-4 rounded-2xl bg-white/5 border border-white/10 hover:border-[#FF6B2C]/30 text-white font-bold flex items-center gap-3 mx-auto group/btn transition-all"
        >
          <ArrowLeft size={18} className="group-hover/btn:-translate-x-1 transition-transform" />
          Back to Dashboard
        </button>
      </motion.div>
    </div>
  );
}
