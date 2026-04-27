import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { startOfMonth, format } from 'date-fns';

const useStore = create(
  persist(
    (set, get) => ({
      user: null,
      setUser: (user) => set({ user }),
      
      habits: [
        { id: '1', name: 'Running', color: '#FF6B2C', goal: 30, category: 'Health' },
        { id: '2', name: 'Meditation', color: '#E85D04', goal: 30, category: 'Mindfulness' },
        { id: '3', name: 'Reading Books', color: '#FF6B2C', goal: 15, category: 'Learning' },
        { id: '4', name: 'Drink 2L of Water', color: '#E85D04', goal: 30, category: 'Health' },
      ],
      setHabits: (habits) => set({ habits }),
      addHabit: (habit) => set((state) => ({ habits: [...state.habits, habit] })),
      updateHabit: (id, updated) => set((state) => ({
        habits: state.habits.map((h) => (h.id === id ? { ...h, ...updated } : h)),
      })),
      deleteHabit: (id) => set((state) => ({
        habits: state.habits.filter((h) => h.id !== id),
      })),

      completions: {}, // { 'habitId-YYYY-MM-DD': true }
      toggleCompletion: (habitId, dateStr) => set((state) => {
        const key = `${habitId}-${dateStr}`;
        const newCompletions = { ...state.completions };
        if (newCompletions[key]) {
          delete newCompletions[key];
        } else {
          newCompletions[key] = true;
        }
        return { completions: newCompletions };
      }),
      setCompletions: (completions) => set({ completions }),

      currentDate: new Date(),
      selectedMonth: new Date().getMonth(),
      selectedYear: new Date().getFullYear(),
      setSelectedMonth: (month) => set({ selectedMonth: month }),
      setSelectedYear: (year) => set({ selectedYear: year }),
      
      xp: 0,
      level: 1,
      achievements: [], // list of unlocked achievement IDs
      
      addXP: (amount) => set((state) => {
        const newXP = Math.max(0, state.xp + amount);
        const newLevel = Math.floor(newXP / 100) + 1;
        
        // Auto-check for achievements
        const newlyUnlocked = [];
        const possible = [
          { id: 'level-5', condition: newLevel >= 5 },
          { id: 'level-10', condition: newLevel >= 10 },
          { id: 'xp-500', condition: newXP >= 500 },
          { id: 'xp-1000', condition: newXP >= 1000 },
        ];
        
        possible.forEach(p => {
          if (p.condition && !state.achievements.includes(p.id)) {
            newlyUnlocked.push(p.id);
          }
        });

        if (newlyUnlocked.length > 0) {
          // In a real app we'd trigger a toast here, but we can't easily from store
          // unless we use a callback or the component listens to this state
        }

        return { 
          xp: newXP, 
          level: newLevel,
          achievements: [...state.achievements, ...newlyUnlocked]
        };
      }),

      notes: {}, // { 'YYYY-MM-DD': 'Note content' }
      setNote: (dateStr, content) => set((state) => ({
        notes: { ...state.notes, [dateStr]: content }
      })),

      screenTime: {}, // { 'YYYY-MM-DD': hours }
      setScreenTime: (dateStr, hours) => set((state) => ({
        screenTime: { ...state.screenTime, [dateStr]: hours }
      })),

      unlockAchievement: (id) => set((state) => {
        if (!state.achievements.includes(id)) {
          return { achievements: [...state.achievements, id] };
        }
        return state;
      }),
    }),
    {
      name: 'habitflow-v2-storage',
      partialize: (state) => ({ 
        habits: state.habits, 
        completions: state.completions,
        xp: state.xp,
        level: state.level,
        notes: state.notes,
        screenTime: state.screenTime,
        achievements: state.achievements
      }),
    }
  )
);

export default useStore;
