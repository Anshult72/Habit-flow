import 'package:flutter/material.dart';
import '../../models/learning_model.dart';

class StreakTier {
  final String label;
  final Color color;
  final int? nextTier;

  const StreakTier({
    required this.label,
    required this.color,
    this.nextTier,
  });
}

class StreakUpdateResult {
  final int newStreak;
  final int? isStreakMilestone;

  StreakUpdateResult({
    required this.newStreak,
    this.isStreakMilestone,
  });
}

class XpEligibilityResult {
  final bool eligible;
  final String reason;

  XpEligibilityResult({
    required this.eligible,
    required this.reason,
  });
}

class TopicXpResult {
  final int xp;
  final bool eligible;
  final String reason;
  final int xpPerTopic;

  TopicXpResult({
    required this.xp,
    required this.eligible,
    required this.reason,
    required this.xpPerTopic,
  });
}

class SoftLockResult {
  final bool locked;
  final String? previousTitle;

  SoftLockResult({
    required this.locked,
    this.previousTitle,
  });
}

class LearningStats {
  final int totalXp;
  final int totalCompletedTopics;
  final int totalTopics;
  final int totalCompletedModules;
  final int totalModules;
  final int maxStreak;
  final int totalStudyHours;

  LearningStats({
    required this.totalXp,
    required this.totalCompletedTopics,
    required this.totalTopics,
    required this.totalCompletedModules,
    required this.totalModules,
    required this.maxStreak,
    required this.totalStudyHours,
  });
}

class LearningXpEngine {
  static const int baseXpPerTopic = 7;
  static const int maxXpEligibleTopicsPerModule = 10;
  static const int moduleCompletionMultiplier = 5;
  static const int chapterCompletionMultiplier = 10;

  static const List<Map<String, dynamic>> streakTiersConfig = [
    {'days': 90, 'bonus': 7},
    {'days': 21, 'bonus': 3},
    {'days': 7,  'bonus': 1},
  ];

  static int getStreakBonus(int streakCount) {
    for (final tier in streakTiersConfig) {
      if (streakCount >= (tier['days'] as int)) {
        return tier['bonus'] as int;
      }
    }
    return 0;
  }

  static int getXpPerTopic(int streakCount) {
    return baseXpPerTopic + getStreakBonus(streakCount);
  }

  static StreakTier getStreakTier(int streakCount) {
    if (streakCount >= 90) {
      return const StreakTier(label: 'Legendary', color: Color(0xFFE25B20), nextTier: null);
    }
    if (streakCount >= 21) {
      return const StreakTier(label: 'Dedicated', color: Color(0xFFFFD700), nextTier: 90);
    }
    if (streakCount >= 7) {
      return const StreakTier(label: 'Committed', color: Color(0xFF3B82F6), nextTier: 21);
    }
    if (streakCount >= 1) {
      return const StreakTier(label: 'Active', color: Color(0xFF10B981), nextTier: 7);
    }
    return const StreakTier(label: 'New', color: Color(0xFF94A3B8), nextTier: 1);
  }

  static String formatDate(DateTime dt) {
    return "${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  static int differenceInCalendarDays(DateTime a, DateTime b) {
    final aLocal = DateTime(a.year, a.month, a.day);
    final bLocal = DateTime(b.year, b.month, b.day);
    return aLocal.difference(bLocal).inDays;
  }

  static StreakUpdateResult calculateUpdatedStreak(int currentStreak, String? lastStreakDateStr) {
    final todayStr = formatDate(DateTime.now());
    
    if (lastStreakDateStr == todayStr) {
      return StreakUpdateResult(newStreak: currentStreak, isStreakMilestone: null);
    }

    int newStreak;

    if (lastStreakDateStr == null || lastStreakDateStr.isEmpty) {
      newStreak = 1;
    } else {
      try {
        final lastDate = DateTime.parse(lastStreakDateStr);
        final today = DateTime.parse(todayStr);
        final daysDiff = differenceInCalendarDays(today, lastDate);

        if (daysDiff == 1) {
          newStreak = currentStreak + 1;
        } else if (daysDiff == 0) {
          newStreak = currentStreak;
        } else {
          newStreak = 1;
        }
      } catch (e) {
        newStreak = 1;
      }
    }

    final milestones = [7, 21, 90];
    final isStreakMilestone = milestones.contains(newStreak) ? newStreak : null;

    return StreakUpdateResult(newStreak: newStreak, isStreakMilestone: isStreakMilestone);
  }

  static XpEligibilityResult checkXpEligibility(
    String topicId,
    String moduleId,
    Map<String, int> completedTopicsLog,
    Map<String, bool> xpAwardedTopics,
  ) {
    if (xpAwardedTopics[topicId] == true) {
      return XpEligibilityResult(eligible: false, reason: 'XP already awarded for this topic');
    }

    final moduleCount = completedTopicsLog[moduleId] ?? 0;
    if (moduleCount >= maxXpEligibleTopicsPerModule) {
      return XpEligibilityResult(
        eligible: false, 
        reason: 'Module XP cap reached ($maxXpEligibleTopicsPerModule topics)',
      );
    }

    return XpEligibilityResult(eligible: true, reason: 'Eligible');
  }

  static TopicXpResult calculateTopicXp(
    int streakCount,
    String topicId,
    String moduleId,
    Map<String, int> completedTopicsLog,
    Map<String, bool> xpAwardedTopics,
  ) {
    final xpPerTopic = getXpPerTopic(streakCount);
    final eligibility = checkXpEligibility(topicId, moduleId, completedTopicsLog, xpAwardedTopics);

    return TopicXpResult(
      xp: eligibility.eligible ? xpPerTopic : 0,
      eligible: eligibility.eligible,
      reason: eligibility.reason,
      xpPerTopic: xpPerTopic,
    );
  }

  static int calculateModuleBonus(int streakCount) {
    return getXpPerTopic(streakCount) * moduleCompletionMultiplier;
  }

  static int calculateChapterBonus(int streakCount) {
    return getXpPerTopic(streakCount) * chapterCompletionMultiplier;
  }

  static bool isModuleComplete(List<TopicModel>? topics) {
    if (topics == null || topics.isEmpty) return false;
    return topics.every((t) => t.status == 'Completed');
  }

  static bool isChapterComplete(List<ChapterModel>? chapters) {
    if (chapters == null || chapters.isEmpty) return false;
    return chapters.every((ch) => isModuleComplete(ch.topics));
  }

  static SoftLockResult checkModuleSoftLock(List<ChapterModel> chapters, int targetIndex) {
    if (targetIndex <= 0) return SoftLockResult(locked: false);
    
    final previousChapter = chapters[targetIndex - 1];
    final isComplete = isModuleComplete(previousChapter.topics);
    
    return SoftLockResult(
      locked: !isComplete,
      previousTitle: previousChapter.title,
    );
  }

  static LearningStats computeLearningStats(List<SubjectModel> subjects) {
    int totalXp = 0;
    int totalCompletedTopics = 0;
    int totalTopics = 0;
    int totalCompletedModules = 0;
    int totalModules = 0;
    int maxStreak = 0;
    int totalStudyHours = 0;

    for (final subject in subjects) {
      totalXp += subject.xpEarned;
      totalStudyHours += subject.totalHours ?? 0;
      if (subject.streakCount > maxStreak) {
        maxStreak = subject.streakCount;
      }

      final chapters = subject.chapters ?? [];
      for (final chapter in chapters) {
        totalModules++;
        final topics = chapter.topics ?? [];
        totalTopics += topics.length;
        
        final completed = topics.where((t) => t.status == 'Completed').length;
        totalCompletedTopics += completed;

        if (topics.isNotEmpty && completed == topics.length) {
          totalCompletedModules++;
        }
      }
    }

    return LearningStats(
      totalXp: totalXp,
      totalCompletedTopics: totalCompletedTopics,
      totalTopics: totalTopics,
      totalCompletedModules: totalCompletedModules,
      totalModules: totalModules,
      maxStreak: maxStreak,
      totalStudyHours: totalStudyHours,
    );
  }
}
