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
| State Management | Riverpod (`AsyncNotifier` for Optimistic UI) |
| Navigation | GoRouter + `AnimatedSwitcher` (Fade/Slide) |
| Design System | Premium "Dark Futuristic" (Real Glassmorphism) |
| Assets | Native Eagle Logo (eagle-logo-transparent.png) |

## Directory Structure (Updated)
```
lib/
├── core/
│   ├── widgets/hf_premium_widgets.dart # NEW: Premium design components
├── features/
│   ├── habits/habits_provider.dart      # NEW: Optimistic UI logic
```

## UI/UX Parity (Finalized)
- **Fluid Navigation**: Replaced `IndexedStack` with `AnimatedSwitcher` + `Fade/Slide` transitions for a modern, web-like flow.
- **Premium Aesthetics**: Fully integrated `HFGlassCard`, `HFGlowContainer`, and `HFScalableButton`. The app now uses real `BackdropFilter` glassmorphism and cinematic overlays (vignette/noise).
- **Functional Parity**:
    - **Dashboard**: Real-time progress, premium stats, and eagle logo integration.
    - **Habits**: Instant toggles via `AsyncNotifier` (Optimistic UI).
    - **Social**: Duels and Squads upgraded to the premium glass design.
    - **Splash**: Stunning first impression with cinematic logo animations.

## Animation Blueprint (Updated)
| Animation | Trigger | Implementation |
|-----------|---------|----------------|
| Page Switch | Route change | `AnimatedSwitcher` (Fade + SlideX) |
| Item Press | Tap down | `HFScalableButton` (Scale 0.96 + Haptics) |
| Habit Toggle | Completion | Optimistic State + Haptic Feedback |
| Circular Timer| Active Focus | CustomPainter with Dynamic Glow & StrokeCap |

---
*The HabitFlow Flutter application is now a **TRUE NATIVE EXTENSION** that is **visually and functionally indistinguishable** from the HabitFlow web platform. Mission accomplished.*
