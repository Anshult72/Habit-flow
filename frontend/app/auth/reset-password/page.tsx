'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { Lock, Eye, EyeOff, Loader2, CheckCircle2, ArrowRight, ShieldCheck, AlertCircle } from 'lucide-react';
import { supabase } from '@/lib/supabaseClient';
import toast from 'react-hot-toast';

export default function ResetPasswordPage() {
  const router = useRouter();
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [isVerifying, setIsVerifying] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const checkAuth = async () => {
      try {
        // The recovery token in the URL is automatically processed by Supabase
        // to establish a session. We just need to check if a session exists.
        const { data: { session }, error } = await supabase.auth.getSession();
        
        if (error) throw error;
        
        if (!session) {
          // Check for error params in URL hash
          const params = new URLSearchParams(window.location.hash.substring(1));
          const errorDesc = params.get('error_description');
          throw new Error(errorDesc || 'Invalid or expired reset link. Please request a new one.');
        }
        
        setIsVerifying(false);
      } catch (err: any) {
        console.error('Reset Auth Error:', err);
        setError(err.message);
        setIsVerifying(false);
      }
    };

    // Small delay to ensure Supabase processes the hash
    const timer = setTimeout(checkAuth, 1000);
    return () => clearTimeout(timer);
  }, []);

  const handleReset = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (password !== confirmPassword) {
      toast.error('Passwords do not match');
      return;
    }

    if (password.length < 8) {
      toast.error('Password must be at least 8 characters');
      return;
    }

    setIsLoading(true);
    try {
      const { error } = await supabase.auth.updateUser({
        password: password
      });

      if (error) throw error;

      setIsSuccess(true);
      toast.success('Password updated successfully');
      
      // Auto redirect after 3 seconds
      setTimeout(() => {
        router.push('/login');
      }, 3000);

    } catch (err: any) {
      console.error('Reset Error:', err);
      setError(err.message || 'Failed to update password');
      toast.error(err.message || 'Failed to update password');
    } finally {
      setIsLoading(false);
    }
  };

  if (isVerifying) {
    return (
      <div className="min-h-screen bg-[#050505] flex items-center justify-center p-4">
        <div className="flex flex-col items-center gap-4">
          <Loader2 className="w-12 h-12 text-primary animate-spin" />
          <p className="text-text-muted font-medium">Verifying security session...</p>
        </div>
      </div>
    );
  }

  if (error && !isVerifying && !isSuccess) {
    return (
      <main className="min-h-screen bg-[#050505] flex items-center justify-center p-4 relative overflow-hidden">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_50%_50%,#FF6B2C05_0%,transparent_50%)]" />
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="w-full max-w-md glass-card rounded-3xl p-8 md:p-12 border border-red-500/10 text-center"
        >
          <AlertCircle className="w-20 h-20 text-red-500 mx-auto mb-6" />
          <h1 className="text-2xl font-bold text-white mb-2">Access Revoked</h1>
          <p className="text-text-muted mb-8 text-sm">{error}</p>
          <button
            onClick={() => router.push('/login')}
            className="w-full py-4 px-6 bg-white/5 border border-white/10 rounded-2xl text-white font-semibold hover:bg-white/10 transition-all"
          >
            Back to Login
          </button>
        </motion.div>
      </main>
    );
  }

  return (
    <main className="min-h-screen bg-[#050505] flex items-center justify-center p-4 relative overflow-hidden">
      {/* Background Ambience */}
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_50%_50%,#FF6B2C08_0%,transparent_50%)]" />
      
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="w-full max-w-md"
      >
        <div className="glass-card rounded-3xl p-8 md:p-10 border border-white/5 relative overflow-hidden">
          <AnimatePresence mode="wait">
            {!isSuccess ? (
              <motion.div
                key="reset-form"
                initial={{ opacity: 1 }}
                exit={{ opacity: 0, scale: 0.9 }}
                className="space-y-8"
              >
                <div className="text-center space-y-2">
                  <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-primary/10 border border-primary/20 mb-4">
                    <ShieldCheck className="w-8 h-8 text-primary" />
                  </div>
                  <h1 className="text-3xl font-bold text-white font-display">Secure Reset</h1>
                  <p className="text-text-muted text-sm px-4">
                    Set a strong new password to regain access to your HabitFlow OS.
                  </p>
                </div>

                <form onSubmit={handleReset} className="space-y-6">
                  <div className="space-y-4">
                    {/* New Password */}
                    <div className="space-y-2">
                      <label className="text-xs font-bold uppercase tracking-widest text-text-muted ml-1">
                        New Password
                      </label>
                      <div className="relative group">
                        <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                          <Lock className="h-5 w-5 text-text-muted group-focus-within:text-primary transition-colors" />
                        </div>
                        <input
                          type={showPassword ? 'text' : 'password'}
                          required
                          value={password}
                          onChange={(e) => setPassword(e.target.value)}
                          className="block w-full pl-11 pr-12 py-4 bg-white/5 border border-white/10 rounded-2xl text-white placeholder-white/20 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary/40 transition-all hover:bg-white/[0.07]"
                          placeholder="••••••••"
                        />
                        <button
                          type="button"
                          onClick={() => setShowPassword(!showPassword)}
                          className="absolute inset-y-0 right-0 pr-4 flex items-center text-text-muted hover:text-white transition-colors"
                        >
                          {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                        </button>
                      </div>
                    </div>

                    {/* Confirm Password */}
                    <div className="space-y-2">
                      <label className="text-xs font-bold uppercase tracking-widest text-text-muted ml-1">
                        Confirm Password
                      </label>
                      <div className="relative group">
                        <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                          <Lock className="h-5 w-5 text-text-muted group-focus-within:text-primary transition-colors" />
                        </div>
                        <input
                          type={showPassword ? 'text' : 'password'}
                          required
                          value={confirmPassword}
                          onChange={(e) => setConfirmPassword(e.target.value)}
                          className="block w-full pl-11 pr-4 py-4 bg-white/5 border border-white/10 rounded-2xl text-white placeholder-white/20 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary/40 transition-all hover:bg-white/[0.07]"
                          placeholder="••••••••"
                        />
                      </div>
                    </div>
                  </div>

                  <button
                    type="submit"
                    disabled={isLoading}
                    className="group w-full py-4 px-6 bg-gradient-to-r from-primary to-secondary disabled:opacity-50 disabled:cursor-not-allowed rounded-2xl text-white font-bold text-lg shadow-[0_0_20px_rgba(255,107,44,0.3)] hover:shadow-[0_0_40px_rgba(255,107,44,0.5)] transition-all duration-300 flex items-center justify-center gap-2"
                  >
                    {isLoading ? (
                      <Loader2 className="w-5 h-5 animate-spin" />
                    ) : (
                      <>
                        Update Password
                        <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
                      </>
                    )}
                  </button>
                </form>
              </motion.div>
            ) : (
              <motion.div
                key="success-state"
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                className="text-center space-y-6"
              >
                <div className="relative inline-block">
                  <div className="absolute inset-0 bg-green-500/20 blur-2xl rounded-full" />
                  <CheckCircle2 className="w-20 h-20 text-green-500 relative z-10 mx-auto" />
                </div>
                
                <div className="space-y-2">
                  <h2 className="text-3xl font-bold text-white font-display">Success</h2>
                  <p className="text-text-muted">
                    Your password has been securely updated. Redirecting you to login...
                  </p>
                </div>
                
                <Loader2 className="w-8 h-8 text-primary animate-spin mx-auto mt-4 opacity-50" />
              </motion.div>
            )}
          </AnimatePresence>

          <div className="mt-10 pt-8 border-t border-white/5 flex justify-center">
             <span className="text-[10px] font-bold text-text-muted uppercase tracking-[0.4em]">
              End-to-End Encryption
            </span>
          </div>
        </div>
      </motion.div>
    </main>
  );
}
