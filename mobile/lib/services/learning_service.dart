import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning_model.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage_service.dart';
import '../core/sync/sync_manager.dart';

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
    if (data != null) {
      return (data as List).map((e) => SubjectModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> _saveSubjectsToCache(List<SubjectModel> subjects) async {
    await _localStorage.saveData(_subjectsCacheKey, subjects.map((e) => e.toJson()).toList());
  }

  SubjectModel? _getCachedSubjectDetails(String id) {
    final data = _localStorage.readData(_subjectDetailsCacheKey(id));
    if (data != null) {
      return SubjectModel.fromJson(data);
    }
    return null;
  }

  Future<void> _saveSubjectDetailsToCache(String id, SubjectModel subject) async {
    await _localStorage.saveData(_subjectDetailsCacheKey(id), subject.toJson());
  }

  // --- API ---

  Future<List<SubjectModel>> getSubjects() async {
    List<SubjectModel> subjects = _getCachedSubjects();

    try {
      final response = await _dio.get('/learning/subjects');
      subjects = (response.data as List).map((e) => SubjectModel.fromJson(e)).toList();
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
      subject = SubjectModel.fromJson(response.data);
      await _saveSubjectDetailsToCache(id, subject);
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
      await _saveSubjectDetailsToCache(subjectId, updatedSubject);
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

      await _saveSubjectDetailsToCache(subjectId, SubjectModel(
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

      await _saveSubjectDetailsToCache(subjectId, SubjectModel(
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
    await ref.read(learningServiceProvider).addChapter(arg, title);
    ref.invalidateSelf();
    ref.invalidate(subjectsProvider);
  }

  Future<void> addTopic(String chapterId, String title) async {
    await ref.read(learningServiceProvider).addTopic(arg, chapterId, title);
    ref.invalidateSelf();
    ref.invalidate(subjectsProvider);
  }

  Future<void> toggleTopic(String chapterId, String topicId, bool completed) async {
    final status = completed ? 'Completed' : 'Not Started';
    await ref.read(learningServiceProvider).updateTopic(arg, chapterId, topicId, status);
    ref.invalidateSelf();
    ref.invalidate(subjectsProvider);
  }
}
