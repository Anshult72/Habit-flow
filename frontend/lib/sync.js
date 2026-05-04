import { doc, onSnapshot, setDoc, getDoc } from 'firebase/firestore';
import { db } from './firebase';
import useStore from '@/store/useStore';

let isUpdatingFromFirestore = false;

export const subscribeToFirestore = (userId) => {
  if (!userId) return () => {};

  const docRef = doc(db, 'users', userId);
  
  return onSnapshot(docRef, (docSnap) => {
    if (docSnap.exists()) {
      const data = docSnap.data();
      isUpdatingFromFirestore = true;
      
      // Update Zustand store with Firestore data
      useStore.setState({
        habits: data.habits || [],
        completions: data.completions || {},
        xp: data.xp || 0,
        level: data.level || 1,
        missions: data.missions || [],
        matrixTasks: data.matrixTasks || [],
        subjects: data.subjects || [],
        memos: data.memos || [],
        wishlist: data.wishlist || [],
        xpHistory: data.xpHistory || [],
      });
      
      isUpdatingFromFirestore = false;
    }
  });
};

export const syncStateToFirestore = async (userId, state) => {
  if (!userId || isUpdatingFromFirestore) return;

  const docRef = doc(db, 'users', userId);
  const dataToSync = {
    habits: state.habits,
    completions: state.completions,
    xp: state.xp,
    level: state.level,
    missions: state.missions,
    matrixTasks: state.matrixTasks,
    subjects: state.subjects,
    memos: state.memos,
    wishlist: state.wishlist,
    xpHistory: state.xpHistory,
    lastSync: new Date().toISOString(),
  };

  try {
    await setDoc(docRef, dataToSync, { merge: true });
  } catch (error) {
    console.error("Error syncing to Firestore:", error);
  }
};
