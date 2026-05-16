import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
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
    const userLevel = 1;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 24.h, bottom: 120.h),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('All Features', style: GoogleFonts.outfit(color: Colors.white, fontSize: 36.sp, fontWeight: FontWeight.w900, letterSpacing: -1)),
                SizedBox(height: 4.h),
                Text('Explore your productivity ecosystem', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 14.sp)),
              ]),
              Container(width: 56.w, height: 56.w, decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppTheme.primary, Color(0xFFFF9800)]),
                boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 16, spreadRadius: 2)]),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('LVL', style: GoogleFonts.outfit(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                  Text('$userLevel', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900, height: 1.1)),
                ])),
            ]).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),

            SizedBox(height: 40.h),

            _sectionHeader('CORE'),
            SizedBox(height: 16.h),
            _grid(context, [
              _F(Icons.calendar_today_outlined, 'Planner', () => _push(context, const PlannerScreen())),
              _F(Icons.calendar_month_outlined, 'Calendar', () => _push(context, const CalendarScreen())),
              _F(Icons.description_outlined, 'Reports', () => _push(context, const ReportsScreen())),
            ]),

            SizedBox(height: 32.h),
            _sectionHeader('FOCUS & OS'),
            SizedBox(height: 16.h),
            _grid(context, [
              _F(Icons.auto_awesome_outlined, 'Matrix', () => _push(context, const MatrixScreen())),
              _F(Icons.rocket_launch_outlined, 'Missions', () => _push(context, const MissionsScreen())),
              _F(Icons.favorite_border_rounded, 'Wishlist', () => _push(context, const WishlistScreen())),
              _F(Icons.menu_book_rounded, 'Learning Hub', () => _push(context, const LearningScreen())),
              _F(Icons.note_outlined, 'Memo', () => _push(context, const MemoScreen())),
              _F(Icons.image_outlined, 'Vision Board', () => _push(context, const VisionBoardScreen())),
            ]),

            SizedBox(height: 32.h),
            _sectionHeader('SOCIAL'),
            SizedBox(height: 16.h),
            _grid(context, [
              _F(Icons.emoji_events_outlined, 'Leaderboard', () => _push(context, const LeaderboardScreen())),
              _F(Icons.military_tech_outlined, 'Duels', () => _push(context, const DuelsScreen())),
              _F(Icons.groups_outlined, 'Squads', () => _push(context, const SquadsScreen())),
              _F(Icons.workspace_premium_outlined, 'Achievements', () => _push(context, const AchievementsScreen())),
            ]),

            SizedBox(height: 32.h),
            _sectionHeader('SYSTEM'),
            SizedBox(height: 16.h),
            _grid(context, [
              _F(Icons.settings_outlined, 'Settings', () => _push(context, const SettingsScreen())),
              _F(Icons.palette_outlined, 'Themes', () => _push(context, const ThemesScreen())),
              _F(Icons.person_outline_rounded, 'Account', () => _push(context, const ProfileScreen())),
            ]),
            SizedBox(height: 20.h),
          ]),
        ),
      ),
    );
  }

  Widget _sectionHeader(String t) => Text(t, style: GoogleFonts.outfit(
    color: AppTheme.textMuted, fontSize: 11.sp, fontWeight: FontWeight.w800, letterSpacing: 3.0,
  )).animate().fadeIn(duration: 300.ms);

  Widget _grid(BuildContext context, List<_F> items) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      childAspectRatio: 1.15,
      children: items.asMap().entries.map((e) {
        return _card(e.value)
            .animate().fadeIn(delay: Duration(milliseconds: 50 * e.key), duration: 300.ms)
            .slideY(begin: 0.05, duration: 300.ms);
      }).toList(),
    );
  }

  Widget _card(_F item) => GestureDetector(onTap: item.onTap, child: Container(
    padding: EdgeInsets.all(20.w), 
    decoration: BoxDecoration(color: const Color(0xFF111111),
      borderRadius: BorderRadius.circular(24.r), 
      border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, color: AppTheme.primary, size: 24.sp),
        ),
        const Spacer(),
        Text(item.label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700)),
      ]
    )));

  void _push(BuildContext c, Widget s) => Navigator.push(c, MaterialPageRoute(builder: (_) => s));
}

class _F {
  final IconData icon; final String label; final VoidCallback onTap;
  const _F(this.icon, this.label, this.onTap);
}

