import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'duel_service.dart';
import 'squad_service.dart';
import 'notification_service.dart';

/// A service to handle real-time subscriptions via Supabase.
class RealtimeService {
  final SupabaseClient _supabase;
  final Ref _ref;

  RealtimeService(this._supabase, this._ref);

  void init() {
    // Listen for duel updates
    _supabase
        .channel('public:duels')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'Duel',
          callback: (payload) {
            // Refresh duels when something changes
            _ref.invalidate(duelsProvider);
          },
        )
        .subscribe();

    // Listen for squad updates
    _supabase
        .channel('public:squads')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'Squad',
          callback: (payload) {
            // Refresh squads when something changes
            _ref.invalidate(squadsProvider);
          },
        )
        .subscribe();
    
    // Listen for user profile updates (XP, Level)
    _supabase
        .channel('public:profiles')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'User',
          callback: (payload) {
            // Refresh user data
            // _ref.invalidate(userProfileProvider);
          },
        )
        .subscribe();

    // Listen for notification updates
    _supabase
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'Notification',
          callback: (payload) {
            // Refresh notifications
            _ref.invalidate(notificationsProvider);
          },
        )
        .subscribe();
  }
}

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  return RealtimeService(Supabase.instance.client, ref);
});
