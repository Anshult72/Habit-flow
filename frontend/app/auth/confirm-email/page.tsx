'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { CheckCircle2, XCircle, Loader2, ArrowRight } from 'lucide-react';
import { supabase } from '@/lib/supabaseClient';

export default function ConfirmEmailPage() {
  const router = useRouter();
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading');
  const [errorMessage, setErrorMessage] = useState('');

  useEffect(() => {
    const checkSession = async () => {
      try {
        // Supabase client handles the hash fragment or code exchange automatically
        // if detectSessionInUrl is true. We just need to check if we have a session now.
        const { data: { session }, error } = await supabase.auth.getSession();

        if (error) throw error;

        if (session) {
          setStatus('success');
        } else {
          // If no session, it might be an invalid or expired link
          // Or the redirect just happened and we need to wait a bit for Supabase to process it
          // But usually getSession() is enough.
          
          // Check if there are error parameters in the URL (Supabase appends them on failure)
          const params = new URLSearchParams(window.location.hash.substring(1));
          const errorDesc = params.get('error_description');
          if (errorDesc) {
            throw new Error(errorDesc);
          }
          
          // Fallback error
          throw new Error('Verification link may have expired or is invalid.');
        }
      } catch (err: any) {
        console.error('Confirmation Error:', err);
        setStatus('error');
        setErrorMessage(err.message || 'Something went wrong while confirming your email.');
      }
    };

    // Small delay to allow Supabase to process the URL fragment
    const timer = setTimeout(checkSession, 1000);
    return () => clearTimeout(timer);
  }, []);

  return (
    <main className="min-h-screen bg-[#050505] flex items-center justify-center p-4 relative overflow-hidden">
      {/* Cinematic Background Effects */}
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_50%_50%,#FF6B2C08_0%,transparent_50%)]" />
      <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-[#FF6B2C05] blur-[120px] rounded-full animate-blob" />
      <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-[#E85D0405] blur-[120px] rounded-full animate-blob animation-delay-2000" />
      
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
        className="w-full max-w-md"
      >
        <div className="glass-card rounded-3xl p-8 md:p-12 border border-white/5 relative overflow-hidden text-center">
          {/* Success State */}
          {status === 'success' && (
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              className="space-y-6"
            >
              <div className="relative inline-block">
                <div className="absolute inset-0 bg-green-500/20 blur-2xl rounded-full" />
                <CheckCircle2 className="w-20 h-20 text-green-500 relative z-10 mx-auto" />
              </div>
              
              <div className="space-y-2">
                <h1 className="text-3xl font-bold tracking-tight text-white font-display">
                  Email Confirmed
                </h1>
                <p className="text-text-muted">
                  Your HabitFlow account is now verified and ready. Welcome to the elite performance system.
                </p>
              </div>

              <button
                onClick={() => router.push('/login')}
                className="group w-full py-4 px-6 bg-gradient-to-r from-primary to-secondary rounded-2xl text-white font-bold text-lg shadow-[0_0_20px_rgba(255,107,44,0.3)] hover:shadow-[0_0_40px_rgba(255,107,44,0.5)] transition-all duration-300 flex items-center justify-center gap-2 active:scale-[0.98]"
              >
                Continue to Login
                <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
              </button>
            </motion.div>
          )}

          {/* Loading State */}
          {status === 'loading' && (
            <div className="space-y-6 py-8">
              <Loader2 className="w-16 h-16 text-primary animate-spin mx-auto" />
              <div className="space-y-2">
                <h1 className="text-2xl font-bold text-white font-display">Verifying Account</h1>
                <p className="text-text-muted">Just a moment while we synchronize your profile...</p>
              </div>
            </div>
          )}

          {/* Error State */}
          {status === 'error' && (
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              className="space-y-6"
            >
              <XCircle className="w-20 h-20 text-red-500 mx-auto" />
              
              <div className="space-y-2">
                <h1 className="text-2xl font-bold text-white font-display">Verification Failed</h1>
                <p className="text-red-400/80 text-sm">{errorMessage}</p>
              </div>

              <div className="space-y-3">
                <button
                  onClick={() => window.location.reload()}
                  className="w-full py-4 px-6 bg-white/5 border border-white/10 rounded-2xl text-white font-semibold hover:bg-white/10 transition-all duration-300 active:scale-[0.98]"
                >
                  Try Again
                </button>
                <button
                  onClick={() => router.push('/login')}
                  className="w-full py-4 px-6 text-text-muted hover:text-white transition-all duration-300 text-sm"
                >
                  Back to Sign In
                </button>
              </div>
            </motion.div>
          )}

          {/* Subtle Branded Footer */}
          <div className="mt-12 pt-8 border-t border-white/5">
            <span className="text-[10px] font-bold text-text-muted uppercase tracking-[0.4em]">
              HabitFlow OS
            </span>
          </div>
        </div>
      </motion.div>
    </main>
  );
}
