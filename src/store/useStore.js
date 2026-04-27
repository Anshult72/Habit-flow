import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { format, subDays, startOfWeek, startOfMonth, isSameDay } from 'date-fns';

const useStore = create(
  persist(
    (set, get) => ({
      // Core State
      habits: [],
      completions: {},
      xp: 0,
      level: 1,
      streakShields: 2,
      onboardingDay: 1, // 1-7 day journey
      lastOnboardingUpdate: new Date().toISOString(),

      // XP History for Stats
      xpHistory: [], // Array of { date: 'YYYY-MM-DD', amount: 15 }

      // Bundles System
      bundles: [
        { id: 'b1', name: 'Morning Routine', habits: [], color: '#FF6B2C', icon: 'Sun' },
        { id: 'b2', name: 'Deep Work', habits: [], color: '#E85D04', icon: 'Zap' },
      ],

      // Mock Social Data
      duels: [
        { id: 'd1', opponent: 'CyberRunner', status: 'Active', playerProgress: 65, opponentProgress: 72, daysLeft: 3 },
        { id: 'd2', opponent: 'FocusMaster', status: 'Completed', playerProgress: 100, opponentProgress: 88, winner: 'You' },
      ],
      squads: [
        { id: 's1', name: 'Alpha Unit', members: ['You', 'Alex', 'Sarah', 'Mike', 'Elena'], consistency: 92, syncBonusActive: true },
      ],

      // Achievements Logic
      achievements: [],
      
      // Actions
      addHabit: (habit) => set((state) => ({ 
        habits: [...state.habits, { ...habit, difficulty: habit.difficulty || 'Medium' }] 
      })),

      updateHabit: (id, updatedHabit) => set((state) => ({
        habits: state.habits.map((h) => (h.id === id ? { ...h, ...updatedHabit } : h)),
      })),

      deleteHabit: (id) => set((state) => ({
        habits: state.habits.filter((h) => h.id !== id),
      })),

      setHabits: (habits) => set({ habits }),
      setCompletions: (completions) => set({ completions }),

      toggleCompletion: (habitId, date) => {
        const key = `${habitId}-${date}`;
        const habit = get().habits.find(h => h.id === habitId);
        const difficultyMultipliers = { Easy: 10, Medium: 25, Hard: 50, Elite: 100 };
        const xpAmount = difficultyMultipliers[habit?.difficulty || 'Medium'];

        set((state) => {
          const newCompletions = { ...state.completions };
          if (newCompletions[key]) {
            delete newCompletions[key];
            get().addXP(-xpAmount, date);
          } else {
            newCompletions[key] = true;
            get().addXP(xpAmount, date);
          }
          return { completions: newCompletions };
        });
        
        get().autoCheckAchievements();
      },

      addXP: (amount, date = format(new Date(), 'yyyy-MM-dd')) => set((state) => {
        const newXP = Math.max(0, state.xp + amount);
        const newLevel = Math.floor(newXP / 500) + 1;
        
        // Update XP History
        const newHistory = [...state.xpHistory, { date, amount }];
        
        return { 
          xp: newXP, 
          level: newLevel,
          xpHistory: newHistory
        };
      }),

      useShield: () => set((state) => ({
        streakShields: Math.max(0, state.streakShields - 1)
      })),

      // Onboarding Journey
      advanceOnboarding: () => set((state) => ({
        onboardingDay: Math.min(7, state.onboardingDay + 1),
        lastOnboardingUpdate: new Date().toISOString()
      })),

      autoCheckAchievements: () => {
        const { xp, level, achievements } = get();
        const newAchievements = [...achievements];

        if (level >= 5 && !achievements.includes('level-5')) newAchievements.push('level-5');
        if (level >= 10 && !achievements.includes('level-10')) newAchievements.push('level-10');
        if (xp >= 500 && !achievements.includes('xp-500')) newAchievements.push('xp-500');
        if (xp >= 1000 && !achievements.includes('xp-1000')) newAchievements.push('xp-1000');

        if (newAchievements.length !== achievements.length) {
          set({ achievements: newAchievements });
        }
      },

      // Analytics Getters
      getStats: () => {
        const { xpHistory } = get();
        const now = new Date();
        const todayStr = format(now, 'yyyy-MM-dd');
        const startOfW = startOfWeek(now);
        const startOfM = startOfMonth(now);

        const earnedToday = xpHistory
          .filter(h => h.date === todayStr)
          .reduce((acc, curr) => acc + curr.amount, 0);

        const earnedThisWeek = xpHistory
          .filter(h => new Date(h.date) >= startOfW)
          .reduce((acc, curr) => acc + curr.amount, 0);

        const earnedThisMonth = xpHistory
          .filter(h => new Date(h.date) >= startOfM)
          .reduce((acc, curr) => acc + curr.amount, 0);

        return { earnedToday, earnedThisWeek, earnedThisMonth };
      }
    }),
    {
      name: 'habitflow-v2-storage',
    }
  )
);

export default useStore;
