import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/habit_model.dart';
import '../../services/habit_service.dart';
import '../network/api_client.dart';
import '../widgets/confetti_provider.dart';
import '../storage/local_storage_service.dart';
import '../sync/sync_manager.dart';

class HabitsNotifier extends AsyncNotifier<List<HabitModel>> {
  @override
  Future<List<HabitModel>> build() async {
    return ref.watch(habitServiceProvider).getHabits();
  }

  Future<void> toggleHabit(String habitId, String date) async {
    try {
      // 1. Service handles local cache update and sync queue
      final updatedHabit = await ref.read(habitServiceProvider).toggleHabit(habitId, date);
      
      // 2. Trigger Confetti if completed
      final completion = updatedHabit.completions.where((c) => c.date == date).firstOrNull;
      if (completion != null && completion.completed) {
        ref.triggerEvent(GlobalEvent.confetti);
      }

      // 3. Re-sync state with local cache
      ref.invalidateSelf();
    } catch (e) {
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
