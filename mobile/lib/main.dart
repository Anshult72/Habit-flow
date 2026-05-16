import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'routes/app_router.dart';

import 'core/storage/local_storage_service.dart';
import 'core/sync/sync_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('settings');

  // Initialize LocalStorageService
  final localStorageService = LocalStorageService();
  await localStorageService.init();

  // Initialize Supabase Auth (same project as web frontend)
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(localStorageService),
      ],
      child: const HabitFlowApp(),
    ),
  );
}

class HabitFlowApp extends ConsumerStatefulWidget {
  const HabitFlowApp({super.key});

  @override
  ConsumerState<HabitFlowApp> createState() => _HabitFlowAppState();
}

class _HabitFlowAppState extends ConsumerState<HabitFlowApp> {
  @override
  void initState() {
    super.initState();
    // Initialize sync manager on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncManagerProvider).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 14 Pro reference
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          routerConfig: router,
          builder: (context, child) {
            return ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
