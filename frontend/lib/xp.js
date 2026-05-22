/**
 * XP Complexity System — Single Source of Truth (Frontend)
 * Mirrors backend XP_PER_COMPLEXITY from habits.service.ts
 *
 * Basic    → 2 XP
 * Standard → 4 XP
 * Advanced → 6 XP
 * Elite    → 8 XP
 */

// Canonical XP per complexity tier
export const XP_PER_COMPLEXITY = {
  Basic: 2,
  Standard: 4,
  Advanced: 6,
  Elite: 8,
};

// Legacy label → canonical label migration (self-healing for stale cache/DB data)
const LABEL_MIGRATION = {
  easy: 'Basic',
  Easy: 'Basic',
  medium: 'Standard',
  Medium: 'Standard',
  hard: 'Advanced',
  Hard: 'Advanced',
  elite: 'Elite',
  Elite: 'Elite',
};

/**
 * Normalise any stored difficulty label to the canonical new label.
 * Falls back to 'Standard' for unknown values.
 */
export function normaliseComplexity(raw) {
  if (!raw) return 'Standard';
  return LABEL_MIGRATION[raw] ?? raw;
}

/**
 * Get XP value for a given difficulty string.
 * Handles both new (Basic/Standard/Advanced/Elite) and legacy (Easy/Medium/Hard) labels.
 */
export function getXpForDifficulty(difficulty) {
  const canonical = normaliseComplexity(difficulty);
  return XP_PER_COMPLEXITY[canonical] ?? 4; // default to Standard (4 XP)
}

/**
 * Difficulty tiers for UI rendering (dropdowns, badges, etc.)
 */
export const DIFFICULTY_TIERS = [
  { label: 'Basic', xp: 2, color: 'text-textMuted' },
  { label: 'Standard', xp: 4, color: 'text-blue-400' },
  { label: 'Advanced', xp: 6, color: 'text-[#FF8C42]' },
  { label: 'Elite', xp: 8, color: 'text-purple-400' },
];

// Per-tier XP-eligible habit limits
export const TIER_LIMITS = {
  Basic: 9,
  Standard: 7,
  Advanced: 5,
  Elite: 3,
};

// Global cap: max active habits that can earn XP simultaneously
export const GLOBAL_XP_CAP = 10;
