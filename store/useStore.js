import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { format, subDays, startOfWeek, startOfMonth } from 'date-fns';

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
      user: null,
      setUser: (user) => set({ user }),

      selectedMonth: new Date().getMonth(),
      selectedYear: new Date().getFullYear(),
      setSelectedMonth: (selectedMonth) => set({ selectedMonth }),
      setSelectedYear: (selectedYear) => set({ selectedYear }),

      isHydrated: false,
      setHydrated: (val) => set({ isHydrated: val }),

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
            ? { ...s, chapters: [...(s.chapters || []), { 
                id: crypto.randomUUID(), 
                status: 'Not Started', 
                topics: [],
                progress: 0,
                notes: '', 
                ...chapter 
              }] } 
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

      deleteChapter: (subjectId, chapterId) => set((state) => ({
        subjects: state.subjects.map((s) => 
          s.id === subjectId 
            ? { ...s, chapters: s.chapters.filter(c => c.id !== chapterId) } 
            : s
        )
      })),

      addTopic: (subjectId, chapterId, topic) => set((state) => ({
        subjects: state.subjects.map((s) => {
          if (s.id === subjectId) {
            const updatedChapters = s.chapters.map(c => 
              c.id === chapterId 
                ? { ...c, topics: [...(c.topics || []), { id: crypto.randomUUID(), title: topic.title, status: 'Not Started' }] } 
                : c
            );
            return { ...s, chapters: updatedChapters };
          }
          return s;
        })
      })),

      updateTopic: (subjectId, chapterId, topicId, updatedTopic) => set((state) => ({
        subjects: state.subjects.map((s) => {
          if (s.id === subjectId) {
            const updatedChapters = s.chapters.map(c => 
              c.id === chapterId 
                ? { ...c, topics: c.topics.map(t => t.id === topicId ? { ...t, ...updatedTopic } : t) } 
                : c
            );
            return { ...s, chapters: updatedChapters };
          }
          return s;
        })
      })),

      deleteTopic: (subjectId, chapterId, topicId) => set((state) => ({
        subjects: state.subjects.map((s) => {
          if (s.id === subjectId) {
            const updatedChapters = s.chapters.map(c => 
              c.id === chapterId 
                ? { ...c, topics: c.topics.filter(t => t.id !== topicId) } 
                : c
            );
            return { ...s, chapters: updatedChapters };
          }
          return s;
        })
      })),

      toggleTopicStatus: (subjectId, chapterId, topicId) => {
        set((state) => {
          const newSubjects = state.subjects.map((s) => {
            if (s.id === subjectId) {
              const updatedChapters = s.chapters.map((c) => {
                if (c.id === chapterId) {
                  const updatedTopics = c.topics.map((t) => {
                    if (t.id === topicId) {
                      const statusMap = { 'Not Started': 'In Progress', 'In Progress': 'Completed', 'Completed': 'Not Started' };
                      return { ...t, status: statusMap[t.status] || 'Not Started' };
                    }
                    return t;
                  });

                  // Recalculate Chapter Status & Progress
                  const completedTopics = updatedTopics.filter(t => t.status === 'Completed').length;
                  const chapterProgress = updatedTopics.length > 0 ? Math.round((completedTopics / updatedTopics.length) * 100) : 0;
                  
                  let chapterStatus = 'Not Started';
                  if (chapterProgress === 100) chapterStatus = 'Completed';
                  else if (chapterProgress > 0 || updatedTopics.some(t => t.status === 'In Progress')) chapterStatus = 'In Progress';

                  return { ...c, topics: updatedTopics, progress: chapterProgress, status: chapterStatus };
                }
                return c;
              });

              // Recalculate Subject Progress
              const totalChapters = updatedChapters.length;
              const sumProgress = updatedChapters.reduce((acc, curr) => acc + (curr.progress || 0), 0);
              const subjectProgress = totalChapters > 0 ? Math.round(sumProgress / totalChapters) : 0;

              return { ...s, chapters: updatedChapters, progress: subjectProgress };
            }
            return s;
          });
          return { subjects: newSubjects };
        });
      },

      addHabit: (habit) => set((state) => ({ 
        habits: [...state.habits, { id: crypto.randomUUID(), ...habit, difficulty: habit.difficulty || 'Medium' }] 
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
        
        const existingDayIndex = state.xpHistory.findIndex(h => h.date === date);
        let newHistory = [...state.xpHistory];
        
        if (existingDayIndex >= 0) {
          newHistory[existingDayIndex] = { 
            ...newHistory[existingDayIndex], 
            amount: newHistory[existingDayIndex].amount + amount 
          };
        } else {
          newHistory.push({ date, amount });
        }
        
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
      },
      getStreak: () => {
        const { habits, completions } = get();
        if (habits.length === 0) return 0;
        
        let streak = 0;
        let d = new Date();
        const todayStr = format(d, 'yyyy-MM-dd');

        while (true) {
          const dStr = format(d, 'yyyy-MM-dd');
          const completedOnDay = habits.some(h => completions[`${h.id}-${dStr}`]);
          
          if (completedOnDay) {
            streak++;
            d = subDays(d, 1);
          } else {
            if (dStr === todayStr) {
              d = subDays(d, 1);
            } else {
              break;
            }
          }
        }
        return streak;
      }
    }),
    {
      name: 'habitflow-v2-storage',
      onRehydrateStorage: (state) => {
        return (rehydratedState) => {
          if (rehydratedState) {
            rehydratedState.setHydrated(true);
          }
        };
      },
    }
  )
);

export default useStore;
