import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A simple provider to trigger global UI events like confetti.
final globalEventProvider = StateProvider<GlobalEvent?>((ref) => null);

enum GlobalEvent {
  confetti,
  levelUp,
  duelWon,
}

extension GlobalEventTriggerWidget on WidgetRef {
  void triggerEvent(GlobalEvent event) {
    read(globalEventProvider.notifier).state = null; // Reset
    Future.delayed(const Duration(milliseconds: 10), () {
      read(globalEventProvider.notifier).state = event;
    });
  }
}

extension GlobalEventTriggerRef on Ref {
  void triggerEvent(GlobalEvent event) {
    read(globalEventProvider.notifier).state = null; // Reset
    Future.delayed(const Duration(milliseconds: 10), () {
      read(globalEventProvider.notifier).state = event;
    });
  }
}
