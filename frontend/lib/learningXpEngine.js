/**
 * Learning Hub XP Engine
 * 
 * Pure utility functions for XP calculation, streak logic,
 * anti-farming protection, and unlock progression.
 * 
 * All progression is SUBJECT-SPECIFIC — no global inheritance.
 */

import { format, differenceInCalendarDays } from 'date-fns';

// ============================
// Constants
// ============================
export const BASE_XP_PER_TOPIC = 7;
export const MAX_XP_ELIGIBLE_TOPICS_PER_MODULE = 10;
export const MODULE_COMPLETION_MULTIPLIER = 5;
export const CHAPTER_COMPLETION_MULTIPLIER = 10;

const STREAK_TIERS = [
  { days: 90, bonus: 7 },
  { days: 21, bonus: 3 },
  { days: 7,  bonus: 1 },
];

// ============================
// Streak Calculations
// ============================

/**
 * Get the streak bonus XP based on current subject streak count.
 * @param {number} streakCount - current subject streak days
 * @returns {number} bonus XP per topic
 */
export function getStreakBonus(streakCount) {
  for (const tier of STREAK_TIERS) {
    if (streakCount >= tier.days) return tier.bonus;
  }
  return 0;
}

/**
 * Get the effective XP per topic for a subject's current streak.
 * @param {number} streakCount
 * @returns {number}
 */
export function getXpPerTopic(streakCount) {
  return BASE_XP_PER_TOPIC + getStreakBonus(streakCount);
}

/**
 * Get the current streak tier label.
 * @param {number} streakCount
 * @returns {{ label: string, color: string, nextTier: number|null }}
 */
export function getStreakTier(streakCount) {
  if (streakCount >= 90) return { label: 'Legendary', color: '#FF6B2C', nextTier: null };
  if (streakCount >= 21) return { label: 'Dedicated', color: '#FFD700', nextTier: 90 };
  if (streakCount >= 7)  return { label: 'Committed', color: '#3B82F6', nextTier: 21 };
  if (streakCount >= 1)  return { label: 'Active', color: '#10B981', nextTier: 7 };
  return { label: 'New', color: '#94A3B8', nextTier: 1 };
}

/**
 * Calculate updated streak for a subject when a topic is completed today.
 * @param {number} currentStreak - existing streak
 * @param {string|null} lastStreakDate - ISO date string of last streak activity
 * @returns {{ newStreak: number, isStreakMilestone: number|null }}
 */
export function calculateUpdatedStreak(currentStreak, lastStreakDate) {
  const today = format(new Date(), 'yyyy-MM-dd');
  
  // Already maintained today
  if (lastStreakDate === today) {
    return { newStreak: currentStreak, isStreakMilestone: null };
  }

  let newStreak;
  
  if (!lastStreakDate) {
    // First ever activity
    newStreak = 1;
  } else {
    const daysDiff = differenceInCalendarDays(new Date(today), new Date(lastStreakDate));
    if (daysDiff === 1) {
      // Consecutive day
      newStreak = currentStreak + 1;
    } else if (daysDiff === 0) {
      // Same day (shouldn't reach here but safety)
      newStreak = currentStreak;
    } else {
      // Streak broken — restart at 1
      newStreak = 1;
    }
  }

  // Check if this hits a milestone
  const milestones = [7, 21, 90];
  const isStreakMilestone = milestones.includes(newStreak) ? newStreak : null;

  return { newStreak, isStreakMilestone };
}

// ============================
// Anti-Farming Protection
// ============================

/**
 * Check if a topic completion should award XP.
 * @param {string} topicId - ID of the topic being completed
 * @param {string} moduleId - ID of the parent module (chapter)
 * @param {Object} completedTopicsLog - { [moduleId]: number } map of XP-awarded topic counts per module
 * @param {Object} xpAwardedTopics - { [topicId]: true } map of already-awarded topics
 * @returns {{ eligible: boolean, reason: string }}
 */
export function checkXpEligibility(topicId, moduleId, completedTopicsLog, xpAwardedTopics) {
  // Already awarded XP for this specific topic
  if (xpAwardedTopics[topicId]) {
    return { eligible: false, reason: 'XP already awarded for this topic' };
  }

  // Check per-module cap
  const moduleCount = completedTopicsLog[moduleId] || 0;
  if (moduleCount >= MAX_XP_ELIGIBLE_TOPICS_PER_MODULE) {
    return { eligible: false, reason: `Module XP cap reached (${MAX_XP_ELIGIBLE_TOPICS_PER_MODULE} topics)` };
  }

  return { eligible: true, reason: 'Eligible' };
}

// ============================
// XP Award Calculations
// ============================

/**
 * Calculate XP to award for a topic completion.
 * @param {number} streakCount - current subject streak
 * @param {string} topicId
 * @param {string} moduleId
 * @param {Object} completedTopicsLog
 * @param {Object} xpAwardedTopics
 * @returns {{ xp: number, eligible: boolean, reason: string, xpPerTopic: number }}
 */
export function calculateTopicXp(streakCount, topicId, moduleId, completedTopicsLog, xpAwardedTopics) {
  const xpPerTopic = getXpPerTopic(streakCount);
  const { eligible, reason } = checkXpEligibility(topicId, moduleId, completedTopicsLog, xpAwardedTopics);
  
  return {
    xp: eligible ? xpPerTopic : 0,
    eligible,
    reason,
    xpPerTopic
  };
}

/**
 * Calculate module completion bonus.
 * @param {number} streakCount
 * @returns {number}
 */
export function calculateModuleBonus(streakCount) {
  return getXpPerTopic(streakCount) * MODULE_COMPLETION_MULTIPLIER;
}

/**
 * Calculate chapter completion bonus.
 * @param {number} streakCount
 * @returns {number}
 */
export function calculateChapterBonus(streakCount) {
  return getXpPerTopic(streakCount) * CHAPTER_COMPLETION_MULTIPLIER;
}

// ============================
// Completion Checks
// ============================

/**
 * Check if a module (chapter) is fully completed.
 * @param {Array} topics - array of topic objects
 * @returns {boolean}
 */
export function isModuleComplete(topics) {
  if (!topics || topics.length === 0) return false;
  return topics.every(t => t.status === 'Completed');
}

/**
 * Check if a chapter (collection of modules) is fully completed.
 * All child modules must be complete.
 * @param {Array} chapters - array of chapter objects with topics
 * @returns {boolean}
 */
export function isChapterComplete(chapters) {
  if (!chapters || chapters.length === 0) return false;
  return chapters.every(ch => isModuleComplete(ch.topics));
}

/**
 * Check if the previous module in sequence is complete for soft unlock.
 * @param {Array} chapters - ordered array of chapters
 * @param {number} targetIndex - index of the module being opened
 * @returns {{ locked: boolean, previousTitle: string|null }}
 */
export function checkModuleSoftLock(chapters, targetIndex) {
  if (targetIndex === 0) return { locked: false, previousTitle: null };
  
  const previousChapter = chapters[targetIndex - 1];
  if (!previousChapter) return { locked: false, previousTitle: null };
  
  const isComplete = isModuleComplete(previousChapter.topics);
  return {
    locked: !isComplete,
    previousTitle: previousChapter.title
  };
}

// ============================
// Subject Stats Calculator
// ============================

/**
 * Compute aggregate stats for the Learning Hub.
 * @param {Array} subjects - all subjects from store
 * @returns {Object}
 */
export function computeLearningStats(subjects) {
  let totalXp = 0;
  let totalCompletedTopics = 0;
  let totalTopics = 0;
  let totalCompletedModules = 0;
  let totalModules = 0;
  let maxStreak = 0;
  let totalStudyHours = 0;

  for (const subject of subjects) {
    totalXp += subject.xpEarned || 0;
    totalStudyHours += subject.totalHours || 0;
    if ((subject.streakCount || 0) > maxStreak) maxStreak = subject.streakCount || 0;

    for (const chapter of (subject.chapters || [])) {
      totalModules++;
      const topics = chapter.topics || [];
      totalTopics += topics.length;
      const completed = topics.filter(t => t.status === 'Completed').length;
      totalCompletedTopics += completed;
      if (topics.length > 0 && completed === topics.length) totalCompletedModules++;
    }
  }

  return {
    totalXp,
    totalCompletedTopics,
    totalTopics,
    totalCompletedModules,
    totalModules,
    maxStreak,
    totalStudyHours
  };
}

export default {
  getStreakBonus,
  getXpPerTopic,
  getStreakTier,
  calculateUpdatedStreak,
  checkXpEligibility,
  calculateTopicXp,
  calculateModuleBonus,
  calculateChapterBonus,
  isModuleComplete,
  isChapterComplete,
  checkModuleSoftLock,
  computeLearningStats,
  BASE_XP_PER_TOPIC,
  MAX_XP_ELIGIBLE_TOPICS_PER_MODULE,
};
