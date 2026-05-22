import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Production-grade auth service wrapping Supabase Auth.
///
/// This mirrors the web frontend's `supabaseAuth.ts` exactly:
/// - Same signIn / signUp / signOut methods
/// - Same session handling
/// - Same JWT extraction for the NestJS backend
class AuthService {
  final supa.SupabaseClient _client = supa.Supabase.instance.client;

  // ─── Session & User ──────────────────────────────────────────────────

  supa.Session? get currentSession => _client.auth.currentSession;
  supa.User? get currentUser => _client.auth.currentUser;
  String? get accessToken => currentSession?.accessToken;
  bool get isAuthenticated => currentSession != null;

  /// Stream of Supabase auth state changes.
  Stream<supa.AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  // ─── Sign In ─────────────────────────────────────────────────────────

  Future<supa.AuthResponse> signInWithEmail(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.session == null) {
      throw const supa.AuthException('Sign in failed: No session returned');
    }
    debugPrint('[AuthService] Signed in: ${response.user?.email}');
    return response;
  }

  // ─── Sign Up ─────────────────────────────────────────────────────────

  Future<supa.AuthResponse> signUpWithEmail(String email, String password) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    debugPrint('[AuthService] Signed up: ${response.user?.email}');
    return response;
  }

  // ─── Google Auth ─────────────────────────────────────────────────────

  /// Native Google Sign-In flow (Lightroom style).
  /// No webview redirects, uses native account picker.
  Future<supa.AuthResponse> signInWithGoogle() async {
    try {
      debugPrint('[AuthService] Initiating Native Google Sign-In...');

      /// 1. Configure Google Sign-In
      /// On Android, this uses the server client ID from the Google Cloud Console.
      /// On iOS, the reverse client ID should be in Info.plist.
      final googleSignIn = GoogleSignIn(
        // On Android, provide the Web Client ID (from Google Console)
        // On iOS, this is usually not required as it uses the URL Scheme.
        // clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com', 
        scopes: ['email', 'openid', 'profile'],
      );

      /// 2. Trigger Native Account Picker
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const supa.AuthException('Google sign-in cancelled by user');
      }

      /// 3. Obtain ID Token & Access Token
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw const supa.AuthException('Could not retrieve Google ID Token');
      }

      /// 4. Sign in to Supabase with the ID Token
      final response = await _client.auth.signInWithIdToken(
        provider: supa.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      debugPrint('[AuthService] Google Sign-In successful for: ${response.user?.email}');
      return response;
    } catch (e) {
      debugPrint('[AuthService] Google Sign-In Error: $e');
      rethrow;
    }
  }

  // ─── Sign Out ────────────────────────────────────────────────────────

  Future<void> signOut() async {
    // 1. Sign out from Supabase
    await _client.auth.signOut();
    
    // 2. Clear local caches
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      final settingsBox = Hive.box('settings');
      await settingsBox.clear();
    } catch (e) {
      debugPrint('[AuthService] Error clearing local caches: $e');
    }
    
    debugPrint('[AuthService] Signed out & Caches cleared');
  }

  // ─── Session Recovery ────────────────────────────────────────────────

  Future<supa.Session?> recoverSession() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) return null;

      if (session.isExpired) {
        debugPrint('[AuthService] Token expired, refreshing...');
        final response = await _client.auth.refreshSession();
        return response.session;
      }

      debugPrint('[AuthService] Session recovered for: ${_client.auth.currentUser?.email}');
      return session;
    } catch (e) {
      debugPrint('[AuthService] Session recovery failed: $e');
      return null;
    }
  }
}

// ─── Riverpod Providers ────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Auth status — deterministic 3-state model to avoid the infinite
/// loading bug caused by StreamProvider's initial AsyncLoading state.
enum AuthStatus { loading, authenticated, unauthenticated }

class AppAuthState {
  final AuthStatus status;
  final supa.Session? session;
  final supa.User? user;

  const AppAuthState({required this.status, this.session, this.user});
  const AppAuthState.loading() : this(status: AuthStatus.loading);
  const AppAuthState.authenticated(supa.Session session, supa.User user)
      : this(status: AuthStatus.authenticated, session: session, user: user);
  const AppAuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);
}

class AuthNotifier extends StateNotifier<AppAuthState> {
  final AuthService _authService;
  StreamSubscription<supa.AuthState>? _sub;

  AuthNotifier(this._authService) : super(const AppAuthState.loading()) {
    _init();
  }

  Future<void> _init() async {
    // 1. Try to recover existing session
    final session = await _authService.recoverSession();
    if (session != null && _authService.currentUser != null) {
      state = AppAuthState.authenticated(session, _authService.currentUser!);
    } else {
      state = const AppAuthState.unauthenticated();
    }

    // 2. Listen for future auth changes
    _sub = _authService.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session != null && _authService.currentUser != null) {
        state = AppAuthState.authenticated(session, _authService.currentUser!);
      } else {
        state = const AppAuthState.unauthenticated();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
