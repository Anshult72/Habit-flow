import { supabase } from './supabaseClient';
import type { Session, User, AuthChangeEvent } from '@supabase/supabase-js';

// ─── Sign Up ─────────────────────────────────────────────────────────────────
export const signUp = async (email: string, password: string) => {
  const { data, error } = await supabase.auth.signUp({ email, password });
  if (error) throw error;
  return data;
};

// ─── Sign In ─────────────────────────────────────────────────────────────────
export const signIn = async (email: string, password: string) => {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });
  if (error) throw error;
  return data;
};

// ─── Sign Out ────────────────────────────────────────────────────────────────
export const signOut = async () => {
  const { error } = await supabase.auth.signOut();
  if (error) throw error;
};

// ─── Get Current Session ─────────────────────────────────────────────────────
export const getSession = async (): Promise<Session | null> => {
  try {
    const { data, error } = await supabase.auth.getSession();
    if (error) throw error;
    return data.session;
  } catch (error) {
    console.error('[supabaseAuth] getSession error:', error);
    return null;
  }
};

// ─── Get Current User ────────────────────────────────────────────────────────
export const getCurrentUser = async (): Promise<User | null> => {
  try {
    const { data, error } = await supabase.auth.getUser();
    if (error) throw error;
    return data.user ?? null;
  } catch (error) {
    console.error('[supabaseAuth] getUser error:', error);
    return null;
  }
};

// ─── Auth State Listener ─────────────────────────────────────────────────────
// Returns an unsubscribe function — same API shape as Firebase onAuthStateChanged
export const subscribeToAuthChanges = (
  callback: (user: User | null, event: AuthChangeEvent) => void
): (() => void) => {
  const {
    data: { subscription },
  } = supabase.auth.onAuthStateChange((event, session) => {
    callback(session?.user ?? null, event);
  });

  return () => subscription.unsubscribe();
};
