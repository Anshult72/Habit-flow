# HabitFlow Mobile App

This directory contains the scalable Flutter mobile application architecture for HabitFlow. 

Since the `flutter` CLI is not currently available in this terminal environment, the foundational structure and key architectural files have been established manually. 

## Features & Integration
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod (`flutter_riverpod`)
- **Routing**: GoRouter (`go_router`)
- **Auth**: Supabase Auth (Seamless sharing of user accounts with the web frontend)
- **API**: NestJS Backend (Accessed via Dio with injected Supabase JWTs)
- **UI**: Dark Futuristic UI matching the web app.

## How to Initialize

To continue development, you will need to install the [Flutter SDK](https://docs.flutter.dev/get-started/install) on your machine. Once installed, run the following commands inside this `mobile` directory:

```bash
# 1. Generate the platform-specific folders (android, ios, web, macos, windows, linux)
# This will not overwrite the custom lib/ files and pubspec.yaml we've created.
flutter create .

# 2. Get dependencies
flutter pub get

# 3. Generate Riverpod / Freezed code (if needed)
dart run build_runner build -d

# 4. Run the app on an emulator or physical device
flutter run
```

## Directory Highlights
- `lib/core/network/dio_client.dart`: Configured to automatically attach the Supabase JWT token to every request made to the NestJS backend.
- `lib/core/theme/app_theme.dart`: Contains the `AppTheme` with the primary `orange glow` and dark backgrounds matching the HabitFlow aesthetic.
- `lib/routes/app_router.dart`: Pre-configured for GoRouter implementation.
- `lib/services/auth_service.dart`: Supabase wrapper for authentication handling.
