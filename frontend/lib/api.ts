import { supabase } from './supabaseClient';
import useStore from '@/store/useStore';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001/api';

/**
 * Authenticated fetch wrapper.
 *
 * Automatically attaches the Supabase access token to every request.
 * Usage:
 *   const data = await apiFetch('/auth/me');
 *   const habits = await apiFetch('/habits', { method: 'POST', body: JSON.stringify(payload) });
 */
export async function apiFetch<T = any>(
  endpoint: string,
  options: RequestInit = {},
): Promise<T> {
  // Get current Supabase session token
  let token: string | undefined;
  try {
    const { data: { session }, error } = await supabase.auth.getSession();
    if (error) {
      if (error.message.includes('Refresh Token Not Found') || error.message.includes('Invalid Refresh Token')) {
        console.warn('[apiFetch] Auth session stale, clearing session.');
        await supabase.auth.signOut();
        useStore.getState().setUser(null);
      }
      throw error;
    }
    token = session?.access_token;
  } catch (err) {
    console.error('[apiFetch] Auth error:', err);
    // If auth is broken, we don't want to keep trying with a broken token
  }

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...((options.headers as Record<string, string>) || {}),
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  try {
    const response = await fetch(`${API_URL}${endpoint}`, {
      ...options,
      headers,
    });

    if (!response.ok) {
      let errorMessage = `API error ${response.status}`;
      try {
        const errorData = await response.json();
        errorMessage = errorData.message || errorData.error?.message || errorMessage;
      } catch (e) {
        // Fallback for non-JSON errors
      }
      throw new Error(errorMessage);
    }

    return response.json();
  } catch (error) {
    if (error instanceof Error && error.message === 'Failed to fetch') {
      console.error('[apiFetch] Network Error: Backend might be down or CORS blocked.', { url: `${API_URL}${endpoint}` });
      throw new Error('Connection failed. Please ensure the backend server is running.');
    }
    throw error;
  }
}
