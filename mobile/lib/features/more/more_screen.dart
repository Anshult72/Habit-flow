import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../profile/profile_screen.dart';
import '../duels/duels_screen.dart';
import '../squads/squads_screen.dart';
import '../planner/planner_screen.dart';
import '../memo/memo_screen.dart';
import '../missions/missions_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../matrix/matrix_screen.dart';
import '../learning/learning_screen.dart';
import '../vision_board/vision_board_screen.dart';
import '../calendar/calendar_screen.dart';
import '../reports/reports_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../achievements/achievements_screen.dart';
import '../settings/settings_screen.dart';
import '../themes/themes_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLevel = 1;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h, bottom: 100.h),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('All Features', style: GoogleFonts.outfit(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                SizedBox(height: 4.h),
                Text('Explore your productivity ecosystem', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 14.sp)),
              ]),
              Container(width: 48.w, height: 48.w, decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.7)]),
                boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 12, spreadRadius: 2)]),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('LVL', style: GoogleFonts.outfit(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  Text('$userLevel', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900, height: 1)),
                ])),
            ]).animate().fadeIn(duration: 400.ms),

            SizedBox(height: 28.h),

            _sectionHeader('CORE'),
            SizedBox(height: 12.h),
            _grid(context, [
              _F(Icons.calendar_view_day_rounded, 'Planner', () => _push(context, const PlannerScreen())),
              _F(Icons.calendar_month_rounded, 'Calendar', () => _push(context, const CalendarScreen())),
              _F(Icons.assessment_rounded, 'Reports', () => _push(context, const ReportsScreen())),
            ]),

            SizedBox(height: 28.h),
            _sectionHeader('FOCUS & OS'),
            SizedBox(height: 12.h),
            _grid(context, [
              _F(Icons.grid_view_rounded, 'Matrix', () => _push(context, const MatrixScreen())),
              _F(Icons.flag_rounded, 'Missions', () => _push(context, const MissionsScreen())),
              _F(Icons.favorite_rounded, 'Wishlist', () => _push(context, const WishlistScreen())),
              _F(Icons.auto_stories_rounded, 'Learning Hub', () => _push(context, const LearningScreen())),
              _F(Icons.sticky_note_2_rounded, 'Memo', () => _push(context, const MemoScreen())),
              _F(Icons.dashboard_customize_rounded, 'Vision Board', () => _push(context, const VisionBoardScreen())),
            ]),

            SizedBox(height: 28.h),
            _sectionHeader('SOCIAL'),
            SizedBox(height: 12.h),
            _grid(context, [
              _F(Icons.leaderboard_rounded, 'Leaderboard', () => _push(context, const LeaderboardScreen())),
              _F(Icons.military_tech_rounded, 'Duels', () => _push(context, const DuelsScreen())),
              _F(Icons.groups_rounded, 'Squads', () => _push(context, const SquadsScreen())),
              _F(Icons.emoji_events_rounded, 'Achievements', () => _push(context, const AchievementsScreen())),
            ]),

            SizedBox(height: 28.h),
            _sectionHeader('SYSTEM'),
            SizedBox(height: 12.h),
            _grid(context, [
              _F(Icons.settings_rounded, 'Settings', () => _push(context, const SettingsScreen())),
              _F(Icons.palette_rounded, 'Themes', () => _push(context, const ThemesScreen())),
              _F(Icons.person_rounded, 'Account', () => _push(context, const ProfileScreen())),
            ]),
            SizedBox(height: 20.h),
          ]),
        ),
      ),
    );
  }

  Widget _sectionHeader(String t) => Text(t, style: GoogleFonts.outfit(
    color: AppTheme.textMuted, fontSize: 11.sp, fontWeight: FontWeight.w700, letterSpacing: 2.0,
  )).animate().fadeIn(duration: 300.ms);

  Widget _grid(BuildContext context, List<_F> items) {
    return Wrap(spacing: 12.w, runSpacing: 12.h, children: items.asMap().entries.map((e) {
      final w = (MediaQuery.of(context).size.width - 40.w - 12.w) / 2;
      return SizedBox(width: w, child: _card(e.value)
          .animate().fadeIn(delay: Duration(milliseconds: 50 * e.key), duration: 300.ms)
          .slideY(begin: 0.05, duration: 300.ms));
    }).toList());
  }

  Widget _card(_F item) => GestureDetector(onTap: item.onTap, child: Container(
    padding: EdgeInsets.all(16.w), decoration: BoxDecoration(color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16.r), border: Border.all(color: AppTheme.surfaceBorder)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(item.icon, color: AppTheme.primary, size: 28.sp),
      SizedBox(height: 16.h),
      Text(item.label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
    ])));

  void _push(BuildContext c, Widget s) => Navigator.push(c, MaterialPageRoute(builder: (_) => s));
  void _soon(BuildContext c, String f) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(
    content: Text('$f — Coming Soon', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
    backgroundColor: AppTheme.surface, behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    duration: const Duration(seconds: 2)));
}

class _F {
  final IconData icon; final String label; final VoidCallback onTap;
  const _F(this.icon, this.label, this.onTap);
}
