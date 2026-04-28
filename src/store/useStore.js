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

      selectedMonth: new Date().getMonth(),
      selectedYear: new Date().getFullYear(),
      setSelectedMonth: (selectedMonth) => set({ selectedMonth }),
      setSelectedYear: (selectedYear) => set({ selectedYear }),

      notes: {}, 
      setNote: (date, content) => set((state) => ({ notes: { ...state.notes, [date]: content } })),

      screenTime: {}, 
      setScreenTime: (date, hours) => set((state) => ({ screenTime: { ...state.screenTime, [date]: hours } })),

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
      
      // Focus Zone System
      focusSessions: [], // Array of { id, type, duration, date, xpEarned, rating }
      focusStreak: 0,
      totalFocusMinutes: 0,

      // Mission Countdown System
      missions: [], // Array of { id, title, desc, category, targetDate, priority, motivationQuote, linkedHabitIds, createdAt }

      // Matrix System
      matrixTasks: [], // Array of { id, title, desc, quadrant, completed, dueDate, tags }

      // Learning Hub System
      subjects: [], // Array of { id, title, category, progress, chapters: [], totalHours, streak, lastStudied, xpEarned }

      // Memo System
      memos: [], // Array of { id, title, content, category, color, isPinned, priority, createdAt }

      // Wishlist System
      wishlist: [], // Array of { id, title, price, targetPrice, currentSavings, category, link, image, deadline, status: 'Pending' | 'Acquired', createdAt }

      // Actions
      addWishlistItem: (item) => set((state) => ({
        wishlist: [{
          id: crypto.randomUUID(),
          createdAt: new Date().toISOString(),
          currentSavings: 0,
          status: 'Pending',
          ...item
        }, ...state.wishlist]
      })),

      updateWishlistItem: (id, updatedItem) => set((state) => ({
        wishlist: state.wishlist.map((item) => (item.id === id ? { ...item, ...updatedItem } : item)),
      })),

      deleteWishlistItem: (id) => set((state) => ({
        wishlist: state.wishlist.filter((item) => item.id !== id),
      })),

      updateSavings: (id, amount) => set((state) => ({
        wishlist: state.wishlist.map((item) => {
          if (item.id === id) {
            const newSavings = Math.min(item.targetPrice, item.currentSavings + amount);
            return { 
              ...item, 
              currentSavings: newSavings,
              status: newSavings >= item.targetPrice ? 'Acquired' : item.status
            };
          }
          return item;
        }),
      })),

      addMemo: (memo) => set((state) => ({
        memos: [{
          id: crypto.randomUUID(),
          createdAt: new Date().toISOString(),
          isPinned: false,
          priority: 'Low',
          color: '#FF6B2C',
          ...memo
        }, ...state.memos]
      })),

      updateMemo: (id, updatedMemo) => set((state) => ({
        memos: state.memos.map((m) => (m.id === id ? { ...m, ...updatedMemo } : m)),
      })),

      deleteMemo: (id) => set((state) => ({
        memos: state.memos.filter((m) => m.id !== id),
      })),

      togglePinMemo: (id) => set((state) => ({
        memos: state.memos.map((m) => (m.id === id ? { ...m, isPinned: !m.isPinned } : m)),
      })),

      addSubject: (subject) => set((state) => ({
        subjects: [...state.subjects, {
          id: crypto.randomUUID(),
          progress: 0,
          chapters: [],
          totalHours: 0,
          streak: 0,
          lastStudied: null,
          xpEarned: 0,
          ...subject
        }]
      })),

      updateSubject: (id, updatedSubject) => set((state) => ({
        subjects: state.subjects.map((s) => (s.id === id ? { ...s, ...updatedSubject } : s)),
      })),

      deleteSubject: (id) => set((state) => ({
        subjects: state.subjects.filter((s) => s.id !== id),
      })),

      addChapter: (subjectId, chapter) => set((state) => ({
        subjects: state.subjects.map((s) => 
          s.id === subjectId 
            ? { ...s, chapters: [...s.chapters, { id: crypto.randomUUID(), status: 'Not Started', notes: '', bookmarks: [], resources: [], ...chapter }] } 
            : s
        )
      })),

      updateChapter: (subjectId, chapterId, updatedChapter) => set((state) => ({
        subjects: state.subjects.map((s) => 
          s.id === subjectId 
            ? { ...s, chapters: s.chapters.map(c => c.id === chapterId ? { ...c, ...updatedChapter } : c) } 
            : s
        )
      })),

      toggleChapterStatus: (subjectId, chapterId) => {
        const state = get();
        const subject = state.subjects.find(s => s.id === subjectId);
        const chapter = subject?.chapters.find(c => c.id === chapterId);
        
        if (!chapter) return;

        const newStatus = chapter.status === 'Completed' ? 'Not Started' : 'Completed';
        const xpReward = newStatus === 'Completed' ? 100 : -100;

        set((state) => ({
          subjects: state.subjects.map((s) => {
            if (s.id === subjectId) {
              const updatedChapters = s.chapters.map(c => 
                c.id === chapterId ? { ...c, status: newStatus } : c
              );
              const completedCount = updatedChapters.filter(c => c.status === 'Completed').length;
              const progress = updatedChapters.length > 0 ? Math.round((completedCount / updatedChapters.length) * 100) : 0;
              
              return { ...s, chapters: updatedChapters, progress, xpEarned: s.xpEarned + xpReward };
            }
            return s;
          })
        }));

        get().addXP(xpReward);
      },

      addHabit: (habit) => set((state) => ({ 
        habits: [...state.habits, { ...habit, difficulty: habit.difficulty || 'Medium' }] 
      })),

      addMatrixTask: (task) => set((state) => ({
        matrixTasks: [...state.matrixTasks, { 
          id: crypto.randomUUID(), 
          completed: false, 
          ...task 
        }]
      })),

      updateMatrixTask: (id, updatedTask) => set((state) => ({
        matrixTasks: state.matrixTasks.map((t) => (t.id === id ? { ...t, ...updatedTask } : t)),
      })),

      deleteMatrixTask: (id) => set((state) => ({
        matrixTasks: state.matrixTasks.filter((t) => t.id !== id),
      })),

      toggleMatrixTask: (id) => {
        const task = get().matrixTasks.find(t => t.id === id);
        if (!task) return;

        const xpAmount = 50; // Flat XP for matrix tasks

        set((state) => ({
          matrixTasks: state.matrixTasks.map((t) => 
            t.id === id ? { ...t, completed: !t.completed } : t
          )
        }));

        if (!task.completed) {
          get().addXP(xpAmount);
        } else {
          get().addXP(-xpAmount);
        }
      },

      addMission: (mission) => set((state) => ({
        missions: [...state.missions, { 
          id: crypto.randomUUID(), 
          createdAt: new Date().toISOString(),
          linkedHabitIds: [],
          ...mission 
        }]
      })),

      updateMission: (id, updatedMission) => set((state) => ({
        missions: state.missions.map((m) => (m.id === id ? { ...m, ...updatedMission } : m)),
      })),

      deleteMission: (id) => set((state) => ({
        missions: state.missions.filter((m) => m.id !== id),
      })),

      addFocusSession: (session) => set((state) => {
        const newSession = {
          id: crypto.randomUUID(),
          date: new Date().toISOString(),
          ...session
        };
        const updatedTotal = state.totalFocusMinutes + session.duration;
        get().addXP(session.xpEarned);
        
        return {
          focusSessions: [newSession, ...state.focusSessions],
          totalFocusMinutes: updatedTotal
        };
      }),

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
