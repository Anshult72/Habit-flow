'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { Mail, Lock, Eye, EyeOff, Zap, Loader2 } from 'lucide-react';
import { supabase } from '@/lib/supabaseClient';
import toast from 'react-hot-toast';

export default function SignupPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password || !confirmPassword) return;

    if (password !== confirmPassword) {
      setErrorMsg('Passwords do not match');
      return;
    }

    if (password.length < 6) {
      setErrorMsg('Password must be at least 6 characters');
      return;
    }

    setLoading(true);
    setErrorMsg('');
    
    try {
      const { data, error } = await supabase.auth.signUp({ 
        email, 
        password,
        options: {
          emailRedirectTo: `${window.location.origin}/login`
        }
      });
      
      if (error) {
        if (error.message.toLowerCase().includes('already registered') || error.message.toLowerCase().includes('already exists')) {
          toast.error('Account already exists. Please login.');
          router.push('/login');
          return;
        } else {
          setErrorMsg(error.message);
        }
      } else {
        // Supabase behavior: if "confirm email" is on, it might return a fake success to prevent email enumeration.
        // If data.user.identities is empty, it means the user already exists.
        if (data.user && data.user.identities && data.user.identities.length === 0) {
          toast.error('Account already exists. Please login.');
          router.push('/login');
          return;
        }

        toast.success('Account created! Check your email to confirm.', { duration: 5000 });
        router.push('/login');
      }
    } catch (err: any) {
      setErrorMsg(err.message || 'Signup failed');
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleAuth = async () => {
    try {
      const { error } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: `${window.location.origin}/auth/callback`,
        }
      });
      if (error) throw error;
    } catch (err: any) {
      toast.error(err.message || 'Google Auth failed');
    }
  };

  return (
    <div className="min-h-screen bg-[#050505] flex flex-col items-center justify-center p-4">
      {/* Header Logo */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="flex items-center justify-center gap-3 mb-8"
      >
        <img
          src="/assets/eagle-logo-simplified.png"
          alt="HabitFlow"
          className="w-8 h-8 object-contain"
        />
        <h1 className="text-2xl font-display font-bold text-white tracking-tight">HabitFlow</h1>
      </motion.div>

      {/* Main Card */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3 }}
        className="w-full max-w-[400px] bg-[#0A0A0A] border border-white/10 rounded-2xl p-8 shadow-[0_8px_30px_rgba(0,0,0,0.4)]"
      >
        <div className="mb-6 text-center">
          <h2 className="text-xl font-bold text-white mb-1">Create an Account</h2>
          <p className="text-sm text-white/50">Join HabitFlow to start your journey.</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Email Input */}
          <div className="space-y-1">
            <div className="relative group">
              <Mail size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-white/30 group-focus-within:text-white/70 transition-colors" />
              <input
                id="signup-email"
                type="email"
                required
                placeholder="Email address"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full bg-white/5 border border-white/10 rounded-xl pl-10 pr-4 py-3 text-white text-sm placeholder:text-white/30 focus:outline-none focus:border-white/30 focus:bg-white/10 transition-all"
              />
            </div>
          </div>

          {/* Password Input */}
          <div className="space-y-1">
            <div className="relative group">
              <Lock size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-white/30 group-focus-within:text-white/70 transition-colors" />
              <input
                id="signup-password"
                type={showPassword ? 'text' : 'password'}
                required
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full bg-white/5 border border-white/10 rounded-xl pl-10 pr-10 py-3 text-white text-sm placeholder:text-white/30 focus:outline-none focus:border-white/30 focus:bg-white/10 transition-all"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-white/30 hover:text-white/70 transition-colors"
              >
                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>
          </div>

          {/* Confirm Password Input */}
          <div className="space-y-1">
            <div className="relative group">
              <Lock size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-white/30 group-focus-within:text-white/70 transition-colors" />
              <input
                id="signup-confirm-password"
                type={showPassword ? 'text' : 'password'}
                required
                placeholder="Confirm Password"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                className="w-full bg-white/5 border border-white/10 rounded-xl pl-10 pr-10 py-3 text-white text-sm placeholder:text-white/30 focus:outline-none focus:border-white/30 focus:bg-white/10 transition-all"
              />
            </div>
          </div>

          {/* Error Message */}
          {errorMsg && (
            <motion.p
              initial={{ opacity: 0, y: -5 }}
              animate={{ opacity: 1, y: 0 }}
              className="text-red-400 text-xs pl-1"
            >
              {errorMsg}
            </motion.p>
          )}

          {/* Submit Button */}
          <button
            type="submit"
            disabled={loading || !email || !password || !confirmPassword}
            className="w-full py-3 mt-2 rounded-xl bg-white text-black font-semibold text-sm
              hover:bg-gray-100 transition-colors disabled:opacity-50 disabled:cursor-not-allowed
              flex justify-center items-center gap-2"
          >
            {loading ? (
              <Loader2 size={18} className="animate-spin" />
            ) : (
              <>
                <Zap size={18} />
                Create Account
              </>
            )}
          </button>
        </form>

        {/* Google Auth Divider */}
        <div className="mt-6 mb-6 flex items-center gap-3">
          <div className="flex-1 h-px bg-white/10" />
          <span className="text-xs text-white/30 uppercase tracking-wider">or</span>
          <div className="flex-1 h-px bg-white/10" />
        </div>

        {/* Google Auth Button */}
        <button
          onClick={handleGoogleAuth}
          className="w-full py-3 rounded-xl bg-white/5 border border-white/10 text-white text-sm font-medium
            hover:bg-white/10 transition-colors flex items-center justify-center gap-2"
        >
          <svg viewBox="0 0 24 24" className="w-5 h-5">
            <path
              fill="currentColor"
              d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
            />
            <path
              fill="currentColor"
              d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
            />
            <path
              fill="currentColor"
              d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
            />
            <path
              fill="currentColor"
              d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
            />
          </svg>
          Sign up with Google
        </button>

        {/* Footer Link */}
        <p className="mt-8 text-center text-sm text-white/50">
          Already have an account?{' '}
          <button
            onClick={() => router.push('/login')}
            className="text-white hover:underline transition-all"
          >
            Sign in
          </button>
        </p>
      </motion.div>
    </div>
  );
}
