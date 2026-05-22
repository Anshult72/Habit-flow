/// ─── HabitFlow XP + Leveling Engine ─────────────────────────────────────────
///
/// Single source of math truth on the mobile client.
/// These formulas MIRROR the backend exactly (users.service.ts).
///
/// Dynamic leveling progression:
///   Delta(L) = 25 × (L + 1)
///   Threshold(L) = 12.5 × L × (L + 1) − 25
///
/// XP thresholds:
///   Level 1  →    0 XP
///   Level 2  →   50 XP
///   Level 3  →  125 XP
///   Level 4  →  225 XP
///   Level 5  →  350 XP
///   Level 6  →  500 XP
///   Level 7  →  675 XP
///   Level 8  →  875 XP
///   Level 9  → 1100 XP
///   Level 10 → 1350 XP
///
/// XP per complexity tier (matches backend XP_PER_COMPLEXITY):
///   Basic    = 2 XP
///   Standard = 4 XP
///   Advanced = 6 XP
///   Elite    = 8 XP
class XpLevelEngine {
  XpLevelEngine._(); // non-instantiable utility class

  static const Map<String, String> labelMigration = {
    'easy': 'Basic',
    'Easy': 'Basic',
    'medium': 'Standard',
    'Medium': 'Standard',
    'hard': 'Advanced',
    'Hard': 'Advanced',
    'elite': 'Elite',
    'Elite': 'Elite',
  };

  static String normalizeDifficulty(String raw) {
    return labelMigration[raw] ?? 'Standard';
  }

  // ─── Complexity → XP map ─────────────────────────────────────────────────

  static const Map<String, int> xpPerComplexity = {
    'Basic': 2,
    'Standard': 4,
    'Advanced': 6,
    'Elite': 8,
    // Legacy label fallbacks — self-healing for any stale cached data
    'Easy': 2,
    'Medium': 4,
    'Hard': 6,
  };

  /// Returns XP per completion for the given complexity label.
  /// Falls back to Standard (4) for any unknown value.
  static int getXpForDifficulty(String difficulty) {
    final canonical = normalizeDifficulty(difficulty);
    return xpPerComplexity[canonical] ?? 4;
  }

  // ─── Level Thresholds ────────────────────────────────────────────────────

  /// Returns the cumulative XP required to *reach* the given level.
  /// Level 1 requires 0 XP (starting state).
  static double getXpThresholdForLevel(int level) {
    if (level <= 1) return 0;
    return 12.5 * level * (level + 1) - 25;
  }

  /// Returns the level a user is at given their total XP.
  static int getLevelForXp(int xp) {
    if (xp <= 0) return 1;
    int level = 1;
    while (xp >= getXpThresholdForLevel(level + 1)) {
      level++;
    }
    return level;
  }

  /// Returns the XP progress *within* the current level (0..deltaXp).
  static int getXpWithinLevel(int xp) {
    final level = getLevelForXp(xp);
    final currentThreshold = getXpThresholdForLevel(level);
    return xp - currentThreshold.toInt();
  }

  /// Returns the XP gap between the current and next level.
  static int getDeltaXpForLevel(int level) {
    return (getXpThresholdForLevel(level + 1) - getXpThresholdForLevel(level)).toInt();
  }

  /// Returns 0.0–1.0 progress fraction within the current level.
  static double getLevelProgress(int xp) {
    final level = getLevelForXp(xp);
    final withinLevel = getXpWithinLevel(xp);
    final delta = getDeltaXpForLevel(level);
    if (delta <= 0) return 1.0;
    return (withinLevel / delta).clamp(0.0, 1.0);
  }

  /// Returns XP remaining to reach the next level.
  static int getXpToNextLevel(int xp) {
    final level = getLevelForXp(xp);
    final nextThreshold = getXpThresholdForLevel(level + 1);
    return (nextThreshold - xp).toInt().clamp(0, 999999);
  }
}
