import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/habit_model.dart';
import '../../services/habit_service.dart';
import '../network/api_client.dart';
import '../storage/local_storage_service.dart';
import '../sync/sync_manager.dart';
import '../../services/user_service.dart';
import '../utils/xp_level_engine.dart';

class HabitsNotifier extends AsyncNotifier<List<HabitModel>> {
  @override
  Future<List<HabitModel>> build() async {
    return ref.watch(habitServiceProvider).getHabits();
  }

  Future<void> toggleHabit(String habitId, String date) async {
    // Optimistic UI Update: Instantly toggle the state in memory before saving to cache/disk
    final previousState = state;
    if (state.hasValue) {
      state = AsyncData(state.value!.map((h) {
        if (h.id == habitId) {
          final isCompleted = h.completions.any((c) => c.date == date && c.completed);
          final newCompletions = List<HabitCompletionModel>.from(h.completions);
          if (isCompleted) {
            newCompletions.removeWhere((c) => c.date == date);
            
            // Revert XP optimistically
            if (h.isXpEligible != false) {
              final xp = h.xpValue ?? XpLevelEngine.getXpForDifficulty(h.difficulty);
              ref.read(userProfileProvider.notifier).addOptimisticXp(-xp);
            }
          } else {
            newCompletions.add(HabitCompletionModel(id: 'temp_$date', date: date, completed: true));
            
            // Add XP optimistically
            if (h.isXpEligible != false) {
              final xp = h.xpValue ?? XpLevelEngine.getXpForDifficulty(h.difficulty);
              ref.read(userProfileProvider.notifier).addOptimisticXp(xp);
            }
          }
          return h.copyWith(completions: newCompletions);
        }
        return h;
      }).toList());
    }

    try {
      // 1. Service handles local cache update and sync queue asynchronously
      final updatedHabit = await ref.read(habitServiceProvider).toggleHabit(habitId, date);
      
      // 2. Re-sync state with local cache seamlessly (no invalidateSelf to prevent lag/flicker)
      if (state.hasValue) {
        state = AsyncData(state.value!.map((h) => h.id == habitId ? updatedHabit : h).toList());
      }
    } catch (e) {
      // Revert optimistic update on failure
      state = previousState;
      rethrow;
    }
  }

  Future<void> addHabit(Map<String, dynamic> data) async {
    try {
      await ref.read(habitServiceProvider).createHabit(data);
      // Service updated cache, just reload from cache
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHabit(String habitId, Map<String, dynamic> data) async {
    try {
      await ref.read(habitServiceProvider).updateHabit(habitId, data);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await ref.read(habitServiceProvider).deleteHabit(habitId);
      // Service updated cache, just reload from cache
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }
}

final habitServiceProvider = Provider((ref) {
  return HabitService(
    ref.watch(dioProvider),
    ref.watch(localStorageProvider),
    ref.watch(syncManagerProvider),
  );
});

final habitsProvider = AsyncNotifierProvider<HabitsNotifier, List<HabitModel>>(() {
  return HabitsNotifier();
});
