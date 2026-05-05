'use client';

import { useRouter } from 'next/navigation';
import { signOut } from '@/lib/supabaseAuth';
import useStore from '@/store/useStore';
import toast from 'react-hot-toast';

/**
 * useLogout — call logout() from any component.
 * Clears Supabase session, clears Zustand user, redirects to /auth.
 */
export function useLogout() {
  const router = useRouter();
  const setUser = useStore((s) => s.setUser);

  const logout = async () => {
    try {
      await signOut();
      setUser(null);
      router.replace('/login');
      toast.success('Session terminated.', { icon: '👋' });
    } catch (err: any) {
      toast.error(err?.message || 'Logout failed.');
    }
  };

  return logout;
}
