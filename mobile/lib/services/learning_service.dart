import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning_model.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage_service.dart';
import '../core/sync/sync_manager.dart';
import '../core/learning/learning_xp_engine.dart';
import 'user_service.dart';

class LearningService {
  final Dio _dio;
  final LocalStorageService _localStorage;
  final SyncManager _syncManager;

  static const String _subjectsCacheKey = 'learning_subjects_cache';
  String _subjectDetailsCacheKey(String id) => 'learning_subject_details_$id';

  LearningService(this._dio, this._localStorage, this._syncManager);

  // --- Helpers ---
  List<SubjectModel> _getCachedSubjects() {
    final data = _localStorage.readData(_subjectsCacheKey);
    if (data != null && data is List) {
      final List<SubjectModel> result = [];
      for (final e in data) {
        try {
          result.add(SubjectModel.fromJson(Map<String, dynamic>.from(e as Map)));
        } catch (_) {
          // Skip corrupt/stale cache entries
        }
      }
      return result;
    }
    return [];
  }

  Future<void> _saveSubjectsToCache(List<SubjectModel> subjects) async {
    await _localStorage.saveData(_subjectsCacheKey, subjects.map((e) => e.toJson()).toList());
  }

  SubjectModel? _getCachedSubjectDetails(String id) {
    final data = _localStorage.readData(_subjectDetailsCacheKey(id));
    if (data != null && data is Map) {
      try {
        return SubjectModel.fromJson(Map<String, dynamic>.from(data));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> saveSubjectDetailsToCache(String id, SubjectModel subject) async {
    await _localStorage.saveData(_subjectDetailsCacheKey(id), subject.toJson());
  }

  // --- API ---

  Future<List<SubjectModel>> getSubjects() async {
    List<SubjectModel> subjects = _getCachedSubjects();

    try {
      final response = await _dio.get('/learning/subjects');
      subjects = (response.data as List).map((e) => SubjectModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      await _saveSubjectsToCache(subjects);
    } catch (e) {
      if (subjects.isEmpty) rethrow;
    }

    return subjects;
  }

  Future<SubjectModel> getSubjectDetails(String id) async {
    SubjectModel? subject = _getCachedSubjectDetails(id);

    try {
      final response = await _dio.get('/learning/subjects/$id');
      subject = SubjectModel.fromJson(Map<String, dynamic>.from(response.data as Map));
      await saveSubjectDetailsToCache(id, subject);
    } catch (e) {
      if (subject == null) rethrow;
    }

    return subject;
  }

  Future<SubjectModel> createSubject(String title, String? category) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempSubject = SubjectModel(
      id: tempId,
      title: title,
      category: category,
      progress: 0,
      count: SubjectCount(chapters: 0),
    );

    final subjects = _getCachedSubjects();
    subjects.add(tempSubject);
    await _saveSubjectsToCache(subjects);

    await _syncManager.enqueueAction('POST', '/learning/subjects', data: {'title': title, 'category': category});
    return tempSubject;
  }

  Future<ChapterModel> addChapter(String subjectId, String title) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempChapter = ChapterModel(
      id: tempId,
      title: title,
      status: 'Not Started',
      progress: 0,
      topics: [],
    );

    final subject = _getCachedSubjectDetails(subjectId);
    if (subject != null) {
      final chapters = List<ChapterModel>.from(subject.chapters ?? []);
      chapters.add(tempChapter);
      final updatedSubject = SubjectModel(
        id: subject.id,
        title: subject.title,
        category: subject.category,
        progress: subject.progress,
        chapters: chapters,
        count: subject.count,
      );
      await saveSubjectDetailsToCache(subjectId, updatedSubject);
    }

    await _syncManager.enqueueAction('POST', '/learning/chapters', data: {'subjectId': subjectId, 'title': title});
    return tempChapter;
  }

  Future<TopicModel> addTopic(String subjectId, String chapterId, String title) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempTopic = TopicModel(id: tempId, title: title, status: 'Not Started');

    final subject = _getCachedSubjectDetails(subjectId);
    if (subject != null) {
      final chapters = subject.chapters?.map((ch) {
        if (ch.id == chapterId) {
          return ChapterModel(
            id: ch.id,
            title: ch.title,
            status: ch.status,
            progress: ch.progress,
            notes: ch.notes,
            topics: [...(ch.topics ?? []), tempTopic],
          );
        }
        return ch;
      }).toList();

      await saveSubjectDetailsToCache(subjectId, SubjectModel(
        id: subject.id,
        title: subject.title,
        category: subject.category,
        progress: subject.progress,
        chapters: chapters,
        count: subject.count,
      ));
    }

    await _syncManager.enqueueAction('POST', '/learning/topics', data: {'chapterId': chapterId, 'title': title});
    return tempTopic;
  }

  Future<TopicModel> updateTopic(String subjectId, String chapterId, String topicId, String status) async {
    final subject = _getCachedSubjectDetails(subjectId);
    TopicModel? updatedTopic;

    if (subject != null) {
      final chapters = subject.chapters?.map((ch) {
        if (ch.id == chapterId) {
          final topics = ch.topics?.map((t) {
            if (t.id == topicId) {
              updatedTopic = TopicModel(id: t.id, title: t.title, status: status);
              return updatedTopic!;
            }
            return t;
          }).toList();

          return ChapterModel(
            id: ch.id,
            title: ch.title,
            status: ch.status,
            progress: ch.progress,
            notes: ch.notes,
            topics: topics,
          );
        }
        return ch;
      }).toList();

      await saveSubjectDetailsToCache(subjectId, SubjectModel(
        id: subject.id,
        title: subject.title,
        category: subject.category,
        progress: subject.progress,
        chapters: chapters,
        count: subject.count,
      ));
    }

    await _syncManager.enqueueAction('PATCH', '/learning/topics/$topicId', data: {'status': status});
    return updatedTopic ?? TopicModel(id: topicId, title: 'Syncing', status: status);
  }

  Future<void> deleteSubject(String id) async {
    final subjects = _getCachedSubjects();
    subjects.removeWhere((s) => s.id == id);
    await _saveSubjectsToCache(subjects);

    await _syncManager.enqueueAction('DELETE', '/learning/subjects/$id');
  }
}

final learningServiceProvider = Provider((ref) {
  return LearningService(
    ref.watch(dioProvider),
    ref.watch(localStorageProvider),
    ref.watch(syncManagerProvider),
  );
});

final subjectsProvider = AsyncNotifierProvider<SubjectsNotifier, List<SubjectModel>>(() {
  return SubjectsNotifier();
});

class SubjectsNotifier extends AsyncNotifier<List<SubjectModel>> {
  @override
  Future<List<SubjectModel>> build() async {
    return ref.watch(learningServiceProvider).getSubjects();
  }

  Future<void> addSubject(String title, String? category) async {
    await ref.read(learningServiceProvider).createSubject(title, category);
    ref.invalidateSelf();
  }

  Future<void> removeSubject(String id) async {
    await ref.read(learningServiceProvider).deleteSubject(id);
    ref.invalidateSelf();
  }
}

final subjectDetailsProvider = AsyncNotifierProviderFamily<SubjectDetailsNotifier, SubjectModel, String>(() {
  return SubjectDetailsNotifier();
});

class SubjectDetailsNotifier extends FamilyAsyncNotifier<SubjectModel, String> {
  @override
  Future<SubjectModel> build(String arg) async {
    return ref.watch(learningServiceProvider).getSubjectDetails(arg);
  }

  Future<void> addChapter(String title) async {
    final currentSubject = state.value;
    if (currentSubject != null) {
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final tempChapter = ChapterModel(
        id: tempId,
        title: title,
        status: 'Ready to Begin',
        progress: 0,
        topics: [],
      );

      final List<ChapterModel> updatedChapters = [...(currentSubject.chapters ?? []), tempChapter];
      
      final updatedSubject = SubjectModel(
        id: currentSubject.id,
        title: currentSubject.title,
        category: currentSubject.category,
        progress: currentSubject.progress,
        chapters: updatedChapters,
        count: currentSubject.count,
        streakCount: currentSubject.streakCount,
        lastStreakDate: currentSubject.lastStreakDate,
        completedTopicsLog: currentSubject.completedTopicsLog,
        xpAwardedTopics: currentSubject.xpAwardedTopics,
        moduleCompletionBonusAwarded: currentSubject.moduleCompletionBonusAwarded,
        chapterCompletionBonusAwarded: currentSubject.chapterCompletionBonusAwarded,
        xpEarned: currentSubject.xpEarned,
        totalHours: currentSubject.totalHours,
        unlockedModules: currentSubject.unlockedModules,
      );

      state = AsyncData(updatedSubject);
    }

    ref.read(learningServiceProvider).addChapter(arg, title).then((_) {
      ref.invalidate(subjectsProvider);
    });
  }

  Future<void> addTopic(String chapterId, String title) async {
    final currentSubject = state.value;
    if (currentSubject != null) {
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final tempTopic = TopicModel(id: tempId, title: title, status: 'Ready to Begin');
      
      final updatedChapters = currentSubject.chapters?.map((ch) {
        if (ch.id == chapterId) {
          final List<TopicModel> updatedTopics = [...(ch.topics ?? []), tempTopic];
          final completed = updatedTopics.where((t) => t.status == 'Completed').length;
          final progress = updatedTopics.isEmpty ? 0 : ((completed / updatedTopics.length) * 100).round();
          
          return ChapterModel(
            id: ch.id,
            title: ch.title,
            status: progress == 100 ? 'Completed' : (progress > 0 ? 'In Progress' : 'Not Started'),
            progress: progress,
            notes: ch.notes,
            topics: updatedTopics,
          );
        }
        return ch;
      }).toList();

      final updatedSubject = SubjectModel(
        id: currentSubject.id,
        title: currentSubject.title,
        category: currentSubject.category,
        progress: currentSubject.progress,
        chapters: updatedChapters,
        count: currentSubject.count,
        streakCount: currentSubject.streakCount,
        lastStreakDate: currentSubject.lastStreakDate,
        completedTopicsLog: currentSubject.completedTopicsLog,
        xpAwardedTopics: currentSubject.xpAwardedTopics,
        moduleCompletionBonusAwarded: currentSubject.moduleCompletionBonusAwarded,
        chapterCompletionBonusAwarded: currentSubject.chapterCompletionBonusAwarded,
        xpEarned: currentSubject.xpEarned,
        totalHours: currentSubject.totalHours,
        unlockedModules: currentSubject.unlockedModules,
      );

      state = AsyncData(updatedSubject);
    }

    ref.read(learningServiceProvider).addTopic(arg, chapterId, title).then((_) {
      ref.invalidate(subjectsProvider);
    });
  }

  Future<void> toggleTopic(String chapterId, String topicId, bool completed) async {
    if (completed) {
      await completeTopicWithXp(chapterId, topicId);
    } else {
      await updateTopicStatus(chapterId, topicId, 'Ready to Begin');
    }
  }

  Future<Map<String, dynamic>?> completeTopicWithXp(String chapterId, String topicId) async {
    final currentSubject = state.value;
    if (currentSubject == null) return null;

    final currentStreak = currentSubject.streakCount;
    final lastStreakDate = currentSubject.lastStreakDate;
    final streakResult = LearningXpEngine.calculateUpdatedStreak(currentStreak, lastStreakDate);
    final nextStreak = streakResult.newStreak;
    final todayStr = LearningXpEngine.formatDate(DateTime.now());

    final completedTopicsLog = Map<String, int>.from(currentSubject.completedTopicsLog);
    final xpAwardedTopics = Map<String, bool>.from(currentSubject.xpAwardedTopics);

    final topicXpResult = LearningXpEngine.calculateTopicXp(
      nextStreak,
      topicId,
      chapterId,
      completedTopicsLog,
      xpAwardedTopics,
    );

    final isTopicXpEligible = topicXpResult.eligible;
    final topicXpEarned = topicXpResult.xp;
    int totalEarnedXp = topicXpEarned;

    final updatedXpAwardedTopics = Map<String, bool>.from(xpAwardedTopics);
    final updatedCompletedTopicsLog = Map<String, int>.from(completedTopicsLog);

    if (isTopicXpEligible && topicXpEarned > 0) {
      updatedXpAwardedTopics[topicId] = true;
      updatedCompletedTopicsLog[chapterId] = (updatedCompletedTopicsLog[chapterId] ?? 0) + 1;
    }

    ChapterModel? targetChapter;
    final updatedChapters = currentSubject.chapters?.map((ch) {
      if (ch.id == chapterId) {
        final updatedTopics = ch.topics?.map((t) {
          if (t.id == topicId) {
            return TopicModel(id: t.id, title: t.title, status: 'Completed');
          }
          return t;
        }).toList() ?? [];

        final completed = updatedTopics.where((t) => t.status == 'Completed').length;
        final total = updatedTopics.length;
        final progress = total == 0 ? 0 : ((completed / total) * 100).round();

        targetChapter = ChapterModel(
          id: ch.id,
          title: ch.title,
          status: progress == 100 ? 'Completed' : (progress > 0 ? 'In Progress' : 'Not Started'),
          progress: progress,
          notes: ch.notes,
          topics: updatedTopics,
        );
        return targetChapter!;
      }
      return ch;
    }).toList();

    int moduleBonusXp = 0;
    final moduleCompletionBonusAwarded = Map<String, bool>.from(currentSubject.moduleCompletionBonusAwarded);

    if (targetChapter != null && targetChapter!.status == 'Completed') {
      final hasBonus = moduleCompletionBonusAwarded[chapterId] == true;
      if (!hasBonus) {
        moduleBonusXp = LearningXpEngine.calculateModuleBonus(nextStreak);
        totalEarnedXp += moduleBonusXp;
        moduleCompletionBonusAwarded[chapterId] = true;
      }
    }

    int chapterBonusXp = 0;
    final chapterCompletionBonusAwarded = Map<String, bool>.from(currentSubject.chapterCompletionBonusAwarded);

    if (updatedChapters != null && LearningXpEngine.isChapterComplete(updatedChapters)) {
      final hasBonus = chapterCompletionBonusAwarded['__subject__'] == true;
      if (!hasBonus) {
        chapterBonusXp = LearningXpEngine.calculateChapterBonus(nextStreak);
        totalEarnedXp += chapterBonusXp;
        chapterCompletionBonusAwarded['__subject__'] = true;
      }
    }

    final totalChapters = updatedChapters?.length ?? 1;
    final sumChapterProgress = updatedChapters?.fold<int>(0, (sum, ch) => sum + ch.progress) ?? 0;
    final subjectProgress = totalChapters == 0 ? 0 : (sumChapterProgress / totalChapters).round();

    final updatedSubject = SubjectModel(
      id: currentSubject.id,
      title: currentSubject.title,
      category: currentSubject.category,
      progress: subjectProgress,
      chapters: updatedChapters,
      count: currentSubject.count,
      streakCount: nextStreak,
      lastStreakDate: todayStr,
      completedTopicsLog: updatedCompletedTopicsLog,
      xpAwardedTopics: updatedXpAwardedTopics,
      moduleCompletionBonusAwarded: moduleCompletionBonusAwarded,
      chapterCompletionBonusAwarded: chapterCompletionBonusAwarded,
      xpEarned: currentSubject.xpEarned + totalEarnedXp,
      totalHours: currentSubject.totalHours,
      unlockedModules: currentSubject.unlockedModules,
    );

    state = AsyncData(updatedSubject);

    if (totalEarnedXp > 0) {
      await ref.read(userServiceProvider).addLocalXp(totalEarnedXp);
      ref.invalidate(userProfileProvider);
    }

    ref.read(learningServiceProvider).updateTopic(arg, chapterId, topicId, 'Completed').then((_) {
      ref.invalidate(subjectsProvider);
    });

    return {
      'xpEarned': topicXpEarned,
      'moduleBonus': moduleBonusXp,
      'chapterBonus': chapterBonusXp,
      'totalXp': totalEarnedXp,
      'streak': nextStreak,
      'isStreakMilestone': streakResult.isStreakMilestone,
    };
  }

  Future<void> updateTopicStatus(String chapterId, String topicId, String status) async {
    final currentSubject = state.value;
    if (currentSubject != null) {
      final updatedChapters = currentSubject.chapters?.map((ch) {
        if (ch.id == chapterId) {
          final updatedTopics = ch.topics?.map((t) {
            if (t.id == topicId) {
              return TopicModel(id: t.id, title: t.title, status: status);
            }
            return t;
          }).toList();

          final completed = updatedTopics?.where((t) => t.status == 'Completed').length ?? 0;
          final total = updatedTopics?.length ?? 1;
          final progress = ((completed / total) * 100).round();

          return ChapterModel(
            id: ch.id,
            title: ch.title,
            status: progress == 100 ? 'Completed' : (progress > 0 ? 'In Progress' : 'Not Started'),
            progress: progress,
            notes: ch.notes,
            topics: updatedTopics,
          );
        }
        return ch;
      }).toList();

      final totalChapters = updatedChapters?.length ?? 1;
      final sumChapterProgress = updatedChapters?.fold<int>(0, (sum, ch) => sum + ch.progress) ?? 0;
      final subjectProgress = totalChapters == 0 ? 0 : (sumChapterProgress / totalChapters).round();

      final updatedSubject = SubjectModel(
        id: currentSubject.id,
        title: currentSubject.title,
        category: currentSubject.category,
        progress: subjectProgress,
        chapters: updatedChapters,
        count: currentSubject.count,
        streakCount: currentSubject.streakCount,
        lastStreakDate: currentSubject.lastStreakDate,
        completedTopicsLog: currentSubject.completedTopicsLog,
        xpAwardedTopics: currentSubject.xpAwardedTopics,
        moduleCompletionBonusAwarded: currentSubject.moduleCompletionBonusAwarded,
        chapterCompletionBonusAwarded: currentSubject.chapterCompletionBonusAwarded,
        xpEarned: currentSubject.xpEarned,
        totalHours: currentSubject.totalHours,
        unlockedModules: currentSubject.unlockedModules,
      );

      state = AsyncData(updatedSubject);
    }

    ref.read(learningServiceProvider).updateTopic(arg, chapterId, topicId, status).then((_) {
      ref.invalidate(subjectsProvider);
    });
  }

  /// Persist a soft-unlock decision so the module stays unlocked across sessions.
  void unlockModule(String chapterId) {
    final currentSubject = state.value;
    if (currentSubject == null) return;

    final updated = Map<String, bool>.from(currentSubject.unlockedModules);
    updated[chapterId] = true;

    final updatedSubject = SubjectModel(
      id: currentSubject.id,
      title: currentSubject.title,
      category: currentSubject.category,
      progress: currentSubject.progress,
      chapters: currentSubject.chapters,
      count: currentSubject.count,
      streakCount: currentSubject.streakCount,
      lastStreakDate: currentSubject.lastStreakDate,
      completedTopicsLog: currentSubject.completedTopicsLog,
      xpAwardedTopics: currentSubject.xpAwardedTopics,
      moduleCompletionBonusAwarded: currentSubject.moduleCompletionBonusAwarded,
      chapterCompletionBonusAwarded: currentSubject.chapterCompletionBonusAwarded,
      xpEarned: currentSubject.xpEarned,
      totalHours: currentSubject.totalHours,
      unlockedModules: updated,
    );

    state = AsyncData(updatedSubject);

    // Persist to cache
    ref.read(learningServiceProvider).saveSubjectDetailsToCache(arg, updatedSubject);
  }
}
