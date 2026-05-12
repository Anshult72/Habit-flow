# HabitFlow Mobile — Architecture & Integration Guide

## Overview
The HabitFlow mobile app is the **real mobile extension** of the HabitFlow platform. It connects to the **exact same backend, database, and auth system** as the web app.

- **Same NestJS backend** (`/api/...`)
- **Same Supabase Auth** (shared JWT tokens)
- **Same PostgreSQL database** (Neon)
- **Same XP system, duels, squads, habits**
- **Same user accounts** — login on web, see data on mobile instantly

## Tech Stack
| Layer | Technology |
|-------|-----------|
| Framework | Flutter (stable) |
| Language | Dart |
| State Management | Riverpod (`StateNotifier`) |
| Routing | GoRouter |
| Networking | Dio + JWT interceptor |
| Authentication | Supabase Auth (`supabase_flutter`) |
| Local Storage | Hive |
| Animations | flutter_animate |
| Typography | Google Fonts (Inter, Outfit) |
| Responsive | flutter_screenutil |

## Auth Flow (CRITICAL)

### The Bug We Fixed
The previous implementation used `StreamProvider<AuthState>` for auth. This caused **infinite loading** because:
1. `StreamProvider` starts with `AsyncLoading`
2. Router treated `AsyncLoading` as "not logged in"
3. → Infinite redirect to `/login`

### The Fix
Replaced with `StateNotifier<AppAuthState>` with **3 deterministic states**:
```
loading → splash screen (no redirect)
authenticated → redirect to /dashboard
unauthenticated → redirect to /login
```

### Login Sequence (mirrors web exactly)
```
1. User enters credentials
2. Supabase Auth validates → returns session + JWT
3. We call GET /api/auth/me → syncs user into PostgreSQL
4. AuthNotifier detects session → state = authenticated
5. GoRouter redirect → /dashboard
```

## Directory Structure
```
lib/
├── main.dart                          # Entry point
├── core/
│   ├── constants/app_constants.dart   # Supabase URL, API URL
│   ├── network/api_client.dart        # Dio + JWT interceptor
│   └── theme/app_theme.dart           # Dark futuristic theme
├── services/
│   ├── auth_service.dart              # Supabase Auth + AuthNotifier
│   ├── user_service.dart              # /api/users/profile
│   ├── habit_service.dart             # /api/habits (CRUD)
│   ├── duel_service.dart              # /api/duels
│   └── squad_service.dart             # /api/squads
├── models/
│   ├── user_model.dart                # Matches Prisma User schema
│   ├── habit_model.dart               # Matches Prisma Habit schema
│   ├── duel_model.dart                # Matches Prisma Duel schema
│   └── squad_model.dart               # Matches Prisma Squad schema
├── features/
│   ├── auth/
│   │   ├── login_screen.dart          # Login + backend sync
│   │   └── splash_screen.dart         # Auth loading state
│   ├── dashboard/dashboard_screen.dart # XP, habits, profile
│   ├── habits/
│   │   ├── habits_screen.dart         # CRUD management
│   │   └── add_habit_dialog.dart      # Create habit form
│   ├── duels/duels_screen.dart        # 1v1 challenges
│   ├── squads/squads_screen.dart      # Group challenges
│   ├── profile/profile_screen.dart    # Stats, settings, logout
│   └── main_layout.dart               # Bottom nav + IndexedStack
└── routes/app_router.dart             # Auth-aware GoRouter
```

## Backend API Mapping
| Mobile Action | API Endpoint | Same as Web? |
|--------------|-------------|:---:|
| Login sync | `GET /api/auth/me` | ✅ |
| Get profile | `GET /api/users/profile` | ✅ |
| Get habits | `GET /api/habits` | ✅ |
| Create habit | `POST /api/habits` | ✅ |
| Delete habit | `DELETE /api/habits/:id` | ✅ |
| Toggle habit | `POST /api/habits/:id/toggle` | ✅ |
| Get duels | `GET /api/duels` | ✅ |
| Get squads | `GET /api/squads` | ✅ |

## API URL Configuration
```dart
// Emulator → host machine
static const String apiBaseUrl = 'http://10.0.2.2:3001/api';

// Physical device → your PC's IP
// static const String apiBaseUrl = 'http://192.168.X.X:3001/api';
```

## Status: ✅ ZERO ANALYSIS ERRORS
```
flutter analyze → No issues found!
flutter pub get → Got dependencies!
```

## Completion Status 🚀 (Finalized)
The core architecture is fully mapped and perfectly synchronized with the web platform. 
The following major Phase 6 features have been natively built in Flutter:
- **1v1 Duels & Squads**: Full lifecycle logic (Create, Accept/Decline, Invites, XP Stakes) mapped to Prisma relations.
- **In-App Notifications**: `NotificationsModal` actively listens to the backend to present Duel/Squad invites.
- **Analytics Sync**: The Dashboard natively queries the NestJS `/analytics/productivity` endpoint to chart user productivity.
- **Settings & Theming**: Interactive, glass-morphic UI profile with configurable options.

The Flutter application is now fully prepared for production deployment/beta testing.
