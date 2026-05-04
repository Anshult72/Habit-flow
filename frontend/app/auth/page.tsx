'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { Sparkles, Mail, Lock, Eye, EyeOff, Zap, ArrowRight } from 'lucide-react';
import { signIn, signUp } from '@/lib/supabaseAuth';
import toast from 'react-hot-toast';

export default function AuthPage() {
  const router = useRouter();
  const [mode, setMode] = useState<'login' | 'signup'>('login');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) return;

    setLoading(true);
    try {
      if (mode === 'login') {
        await signIn(email, password);
        toast.success('Welcome back. System online.', { icon: '⚡' });
        // Redirect: if onboarding already done go to /app, else /onboarding
        const hasOnboarded = localStorage.getItem('hasCompletedOnboarding') === 'true';
        router.push(hasOnboarded ? '/app' : '/onboarding');
      } else {
        await signUp(email, password);
        toast.success('Account initialized. Check your email to confirm.', { icon: '🚀', duration: 6000 });
        setMode('login');
      }
    } catch (err: any) {
      toast.error(err?.message || 'Authentication failed. Try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#050505] flex items-center justify-center p-4 relative overflow-hidden">
      {/* Ambient background */}
      <div className="fixed inset-0 pointer-events-none z-0">
        <div className="absolute top-1/4 left-1/4 w-[700px] h-[700px] bg-[#FF6B2C]/5 rounded-full blur-[160px] animate-pulse" />
        <div className="absolute bottom-1/4 right-1/4 w-[500px] h-[500px] bg-[#E85D04]/3 rounded-full blur-[140px]" />
      </div>

      <div className="relative z-10 w-full max-w-md">
        {/* Logo */}
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          className="flex flex-col items-center mb-10"
        >
          <div className="relative mb-4">
            <div className="absolute inset-0 bg-[#FF6B2C]/20 blur-2xl rounded-full" />
            <img
              src="/assets/eagle-logo-simplified.png"
              alt="HabitFlow"
              className="w-14 h-14 object-contain relative z-10 drop-shadow-[0_0_20px_rgba(255,107,44,0.5)]"
            />
          </div>
          <h1 className="text-2xl font-display font-bold text-white tracking-tight">HabitFlow</h1>
          <p className="text-[10px] font-bold text-[#FF6B2C] uppercase tracking-[0.4em] opacity-60 mt-1">
            COMMAND SYSTEM
          </p>
        </motion.div>

        {/* Card */}
        <motion.div
          initial={{ opacity: 0, y: 20, scale: 0.98 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          transition={{ delay: 0.1, ease: [0.16, 1, 0.3, 1] }}
          className="glass-card rounded-3xl border border-white/10 p-8 shadow-[0_40px_80px_rgba(0,0,0,0.6)]"
        >
          {/* Mode Toggle */}
          <div className="flex items-center gap-1 bg-white/5 p-1 rounded-2xl border border-white/10 mb-8">
            {(['login', 'signup'] as const).map((m) => (
              <button
                key={m}
                onClick={() => setMode(m)}
                className={`flex-1 py-2.5 rounded-xl text-[11px] font-black uppercase tracking-widest transition-all ${
                  mode === m
                    ? 'bg-[#FF6B2C] text-white shadow-[0_4px_20px_rgba(255,107,44,0.4)]'
                    : 'text-white/30 hover:text-white'
                }`}
              >
                {m === 'login' ? 'Sign In' : 'Sign Up'}
              </button>
            ))}
          </div>

          <AnimatePresence mode="wait">
            <motion.div
              key={mode}
              initial={{ opacity: 0, x: mode === 'login' ? -10 : 10 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.2 }}
            >
              <div className="mb-6">
                <h2 className="text-xl font-display font-bold text-white">
                  {mode === 'login' ? 'System Access' : 'Initialize Account'}
                </h2>
                <p className="text-[11px] text-textMuted mt-1">
                  {mode === 'login'
                    ? 'Enter credentials to access your command center.'
                    : 'Create your HabitFlow identity. Confirm email to activate.'}
                </p>
              </div>

              <form onSubmit={handleSubmit} className="space-y-4">
                {/* Email */}
                <div className="relative">
                  <Mail size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-textMuted" />
                  <input
                    id="auth-email"
                    type="email"
                    required
                    autoComplete="email"
                    placeholder="Email address"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="w-full bg-white/5 border border-white/10 rounded-xl pl-11 pr-4 py-3.5 text-white text-sm placeholder:text-textMuted/50 focus:outline-none focus:border-[#FF6B2C] focus:bg-[#FF6B2C]/5 transition-all"
                  />
                </div>

                {/* Password */}
                <div className="relative">
                  <Lock size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-textMuted" />
                  <input
                    id="auth-password"
                    type={showPassword ? 'text' : 'password'}
                    required
                    autoComplete={mode === 'login' ? 'current-password' : 'new-password'}
                    placeholder="Password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="w-full bg-white/5 border border-white/10 rounded-xl pl-11 pr-12 py-3.5 text-white text-sm placeholder:text-textMuted/50 focus:outline-none focus:border-[#FF6B2C] focus:bg-[#FF6B2C]/5 transition-all"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-4 top-1/2 -translate-y-1/2 text-textMuted hover:text-white transition-colors"
                  >
                    {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>

                {/* Hint for signup */}
                {mode === 'signup' && (
                  <p className="text-[10px] text-textMuted pl-1">
                    Use at least 6 characters. You'll receive a confirmation email.
                  </p>
                )}

                {/* Submit */}
                <button
                  id="auth-submit"
                  type="submit"
                  disabled={loading || !email || !password}
                  className="w-full py-3.5 rounded-xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white font-bold text-sm
                    flex items-center justify-center gap-2 shadow-[0_8px_30px_rgba(255,107,44,0.3)]
                    hover:shadow-[0_12px_40px_rgba(255,107,44,0.5)] hover:scale-[1.01] active:scale-[0.99]
                    transition-all disabled:opacity-40 disabled:cursor-not-allowed disabled:scale-100"
                >
                  {loading ? (
                    <motion.div
                      animate={{ rotate: 360 }}
                      transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
                      className="w-5 h-5 border-2 border-white border-t-transparent rounded-full"
                    />
                  ) : (
                    <>
                      <Zap size={16} fill="white" />
                      {mode === 'login' ? 'Access System' : 'Create Account'}
                      <ArrowRight size={16} />
                    </>
                  )}
                </button>
              </form>

              {/* Toggle mode hint */}
              <p className="text-center text-[11px] text-textMuted mt-6">
                {mode === 'login' ? (
                  <>
                    No account?{' '}
                    <button
                      onClick={() => setMode('signup')}
                      className="text-[#FF8C42] font-bold hover:text-white transition-colors"
                    >
                      Sign up
                    </button>
                  </>
                ) : (
                  <>
                    Already have an account?{' '}
                    <button
                      onClick={() => setMode('login')}
                      className="text-[#FF8C42] font-bold hover:text-white transition-colors"
                    >
                      Sign in
                    </button>
                  </>
                )}
              </p>
            </motion.div>
          </AnimatePresence>
        </motion.div>

        <p className="text-center text-[10px] text-white/10 mt-6 uppercase tracking-widest">
          Secured by Supabase Auth
        </p>
      </div>
    </div>
  );
}
