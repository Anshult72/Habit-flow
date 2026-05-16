import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'habits_provider.dart';

// Simple init provider to trigger habit fetch on first use
final habitsInitProvider = FutureProvider<void>((ref) async {
  await ref.read(habitsProvider.notifier).build(); // build() is enough for AsyncNotifier
});
