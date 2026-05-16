import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/main_layout.dart';
import '../features/onboarding/onboarding_screen.dart';

/// Notifies GoRouter whenever the auth state changes, triggering a redirect check.
/// This prevents rebuilding the entire GoRouter instance, which causes stuck loaders
/// and broken navigation stacks.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AppAuthState>(
      authNotifierProvider,
      (_, __) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authNotifierProvider);
    final currentPath = state.matchedLocation;

    // While auth is loading, stay on splash
    if (authState.status == AuthStatus.loading) {
      return currentPath == '/' ? null : '/';
    }

    final isLoggedIn = authState.status == AuthStatus.authenticated;
    final isOnAuthPage = currentPath == '/login' || currentPath == '/signup' || currentPath == '/' || currentPath == '/onboarding';

    // Not logged in → force to onboarding or login/signup
    if (!isLoggedIn) {
      if (currentPath == '/onboarding' || currentPath == '/login' || currentPath == '/signup') {
        return null;
      }
      return '/onboarding';
    }

    // Logged in but on auth page → go to dashboard
    if (isLoggedIn && isOnAuthPage) {
      return '/dashboard';
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) => RouterNotifier(ref));

/// App router with proper auth-aware redirect logic.
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const MainLayout(),
      ),
    ],
  );
});
