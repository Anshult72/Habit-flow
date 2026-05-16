import 'package:flutter/foundation.dart';

/// Central configuration for the HabitFlow mobile application.
///
/// These values mirror the web frontend's .env.local configuration
/// to ensure both platforms use the exact same backend ecosystem.
class AppConstants {
  AppConstants._();

  // ─── Supabase Auth (same project as web) ─────────────────────────────
  static const String supabaseUrl =
      'https://luqjcofranlrehitnujn.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx1cWpjb2ZyYW5scmVoaXRudWpuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc4MTkyODUsImV4cCI6MjA5MzM5NTI4NX0.Vx2sg6YbDRmLr_ZXY3i_D06CnF133ZE50svApUykodE';

  // ─── NestJS Backend API ──────────────────────────────────────────────
  // We use a getter to dynamically detect the environment:
  // - Android Emulator: 10.0.2.2
  static String get apiBaseUrl {
    // Production Railway Backend:
    return 'https://stunning-encouragement-production-68e8.up.railway.app/api';
  }

  // ─── App Info ────────────────────────────────────────────────────────
  static const String appName = 'HabitFlow';
  static const String appVersion = '1.0.0';

  // ─── XP System Constants (must match backend) ────────────────────────
  static const int xpPerLevel = 1000;
}
