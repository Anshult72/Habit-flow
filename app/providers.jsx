'use client';

import { useEffect, useState } from 'react';
import useStore from '@/store/useStore';
import { subscribeToAuthChanges } from '@/lib/auth';
import { subscribeToFirestore, syncStateToFirestore } from '@/lib/sync';

export function Providers({ children }) {
  const [mounted, setMounted] = useState(false);
  const [user, setUser] = useState(null);

  useEffect(() => {
    setMounted(true);
    
    let unsubscribeFirestore = () => {};

    // Subscribe to Firebase Auth
    const unsubscribeAuth = subscribeToAuthChanges((currentUser) => {
      setUser(currentUser);
      useStore.getState().setUser(currentUser);
      
      if (currentUser) {
        // Subscribe to Firestore data
        unsubscribeFirestore = subscribeToFirestore(currentUser.uid);
      } else {
        unsubscribeFirestore();
      }
    });

    // Subscribe to Zustand state changes to push to Firestore
    const unsubscribeStore = useStore.subscribe((state, prevState) => {
      if (state.user && state.user.uid) {
        // Only sync if certain fields changed (simple check for now)
        if (JSON.stringify(state.habits) !== JSON.stringify(prevState.habits) ||
            JSON.stringify(state.completions) !== JSON.stringify(prevState.completions) ||
            state.xp !== prevState.xp) {
          syncStateToFirestore(state.user.uid, state);
        }
      }
    });

    return () => {
      unsubscribeAuth();
      unsubscribeFirestore();
      unsubscribeStore();
    };
  }, []);

  return (
    <>
      {children}
    </>
  );
}
