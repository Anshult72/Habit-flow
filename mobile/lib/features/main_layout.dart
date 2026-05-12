import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import 'dashboard/dashboard_screen.dart';
import 'habits/habits_screen.dart';
import 'focus/focus_screen.dart';
import 'analytics/analytics_screen.dart';
import 'more/more_screen.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Main layout that mirrors the web app's structure:
///   - Sidebar (desktop) → Bottom dock (mobile)
///   - Same navigation hierarchy
///   - Same floating glass dock design from MobileDock.jsx
///
/// Web dock items: Home, Habits, Focus, Analytics + More
/// Flutter dock: Dashboard, Habits, Focus, Analytics, More
class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);

    final List<Widget> screens = [
      const DashboardScreen(),
      const HabitsScreen(),
      const FocusScreen(),
      const AnalyticsScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // ─── Ambient Glow Background (from web layout.jsx) ─────────
          // Web: bg-[#FF6B2C]/5 rounded-full blur-[160px]
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.secondary.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ─── Content ───────────────────────────────────────────────
          IndexedStack(
            index: selectedIndex,
            children: screens,
          ),

          // ─── Floating Dock (mirrors MobileDock.jsx) ────────────────
          // Web: fixed bottom-6 left-1/2 -translate-x-1/2 w-[95%] max-w-[420px]
          Positioned(
            left: 0,
            right: 0,
            bottom: 20.h,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.92,
                constraints: BoxConstraints(maxWidth: 420.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        // Web: glass-card bg-surface/90 backdrop-blur-2xl
                        color: AppTheme.background.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: AppTheme.surfaceBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDockItem(ref, 0, Icons.dashboard_rounded, 'HOME', selectedIndex),
                          _buildDockItem(ref, 1, Icons.bolt_rounded, 'HABITS', selectedIndex),
                          _buildDockItem(ref, 2, Icons.flash_on_rounded, 'FOCUS', selectedIndex),
                          _buildDockItem(ref, 3, Icons.bar_chart_rounded, 'ANALYTICS', selectedIndex),
                          _buildDockItem(ref, 4, selectedIndex == 4 ? Icons.close_rounded : Icons.menu_rounded, 'MORE', selectedIndex),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dock item matching web's MobileDock button:
  /// - Active: orange glow pill background + primary color icon
  /// - Inactive: muted icon
  /// - Label: text-[9px] uppercase tracking-widest
  Widget _buildDockItem(WidgetRef ref, int index, IconData icon, String label, int currentIndex) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => ref.read(bottomNavIndexProvider.notifier).state = index,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: isActive
            ? BoxDecoration(
                // Web: bg-primary/10 rounded-2xl border border-primary/20
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGlow.withValues(alpha: 0.15),
                    blurRadius: 15,
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22.sp,
              color: isActive ? AppTheme.primary : AppTheme.textMuted,
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 8.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: isActive ? AppTheme.primary : AppTheme.textMuted.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
