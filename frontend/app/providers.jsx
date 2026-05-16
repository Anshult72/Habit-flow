'use client';

import { useEffect, useState } from 'react';
import useStore from '@/store/useStore';
import { subscribeToAuthChanges } from '@/lib/supabaseAuth';

export function Providers({ children }) {
  const [mounted, setMounted] = useState(false);
  const theme = useStore((state) => state.theme);
  const autoTheme = useStore((state) => state.autoTheme);

  useEffect(() => {
    setTimeout(() => setMounted(true), 0);

    // ── Supabase Auth Listener ──────────────────────────────────────────────
    const unsubscribeAuth = subscribeToAuthChanges((user) => {
      if (user) {
        useStore.getState().setUser({
          uid: user.id,
          email: user.email ?? null,
          displayName: user.user_metadata?.full_name ?? user.email ?? null,
        });
      } else {
        useStore.getState().setUser(null);
      }
    });

    return () => {
      unsubscribeAuth();
    };
  }, []);

  // ── Theme Application ─────────────────────────────────────────────────────
  useEffect(() => {
    const applyTheme = () => {
      let activeTheme = theme || 'dark';

      if (autoTheme) {
        const hour = new Date().getHours();
        if (hour >= 6 && hour < 12) {
          activeTheme = 'light';
        } else if (hour >= 12 && hour < 18) {
          activeTheme = 'calm';
        } else {
          activeTheme = 'focus';
        }
      }

      document.documentElement.setAttribute('data-theme', activeTheme);
    };

    applyTheme();

    let interval;
    if (autoTheme) {
      interval = setInterval(applyTheme, 60_000);
    }

    return () => {
      if (interval) clearInterval(interval);
    };
  }, [theme, autoTheme]);

  return <>{children}</>;
}
