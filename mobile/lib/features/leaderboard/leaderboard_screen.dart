import 'package:flutter/material.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../models/leaderboard_model.dart';
import '../../services/analytics_service.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Area (Comfortable status-bar offset & outline ghost back navigation)
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h, bottom: 12.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 9.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.02), // Sleek outline ghost button
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded, 
                        color: Colors.white, 
                        size: 12.sp, // Elegant micro weight
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GLOBAL RANKINGS',
                          style: GoogleFonts.outfit(
                            fontSize: 9.sp, 
                            fontWeight: FontWeight.w900, 
                            color: const Color(0xFFE25B20), 
                            letterSpacing: 2.5,
                          ),
                        ),
                        SizedBox(height: 3.h), // Clean typographic spacing rhythm
                        Text(
                          'Leaderboard', 
                          style: GoogleFonts.outfit(
                            fontSize: 22.sp, 
                            fontWeight: FontWeight.w900, 
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            
            // Faint tactical glass separator below header
            Container(height: 0.5.h, color: Colors.white.withValues(alpha: 0.04)),

            Expanded(
              child: leaderboardAsync.when(
                data: (users) {
                  if (users.isEmpty) {
                    return Center(
                      child: Text(
                        'No rankings available yet.',
                        style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 14.sp),
                      ),
                    );
                  }

                  final top3 = users.take(3).toList();
                  final rest = users.skip(3).toList();

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h), 
                    children: [
                      // Podium Section
                      if (top3.isNotEmpty) ...[
                        _podium(top3),
                        SizedBox(height: 28.h), // Generous breathing room below the podium
                      ],

                      // Full Rankings Header
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up_rounded, 
                            size: 15.sp, 
                            color: const Color(0xFFE25B20).withValues(alpha: 0.8),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'FULL RANKINGS',
                            style: GoogleFonts.outfit(
                              fontSize: 10.5.sp, 
                              fontWeight: FontWeight.w900, 
                              color: Colors.white54, 
                              letterSpacing: 1.5,
                            ),
                          ),
                          const Spacer(),
                          
                          // Synced Live indicator (Subtle Orange Live Indicator for HabitFlow Brand Consistency)
                          Row(
                            children: [
                              Container(
                                width: 5.w,
                                height: 5.w,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE25B20),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE25B20).withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'LIVE SYNCED',
                                style: GoogleFonts.outfit(
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFE25B20).withValues(alpha: 0.8),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),

                      // List Rows
                      ...rest.asMap().entries.map((e) => _row(e.value, e.key)),
                      SizedBox(height: 16.h), // Perfectly balanced bottom vertical rhythm
                    ],
                  );
                },
                loading: () => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: const HFShimmerList(height: 70, count: 6),
                ),
                error: (e, _) => HFErrorState(
                  onRetry: () => ref.refresh(leaderboardProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _podium(List<LeaderboardUserModel> top3) {
    // Expected order: #2, #1, #3
    LeaderboardUserModel? p1, p2, p3;
    if (top3.isNotEmpty) p1 = top3[0];
    if (top3.length > 1) p2 = top3[1];
    if (top3.length > 2) p3 = top3[2];

    return SizedBox(
      height: 295.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, 
        children: [
          // Enhanced Flex weights ( Champ: 12, Sides: 10 ) to completely resolve squeezed/narrow side cards
          if (p2 != null) Expanded(flex: 10, child: _podiumCard(p2, 226.h)) else const Spacer(),
          SizedBox(width: 10.w), // Better spacing rhythm between cards
          if (p1 != null) Expanded(flex: 12, child: _podiumCard(p1, 285.h)) else const Spacer(),
          SizedBox(width: 10.w),
          if (p3 != null) Expanded(flex: 10, child: _podiumCard(p3, 206.h)) else const Spacer(),
        ],
      ),
    );
  }

  Widget _podiumCard(LeaderboardUserModel u, double h) {
    final isChamp = u.rank == 1;
    final rankColors = {
      1: const Color(0xFFFFE259), // Gold glow
      2: const Color(0xFFC0C0C0), // Platinum/Silver
      3: const Color(0xFFCD7F32), // Bronze
    };
    final c = rankColors[u.rank] ?? Colors.white54;

    return Container(
      height: h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isChamp 
              ? [const Color(0xFF1E140F), const Color(0xFF120D0A)] // Premium copper/gold luxury theme
              : [const Color(0xFF131316), const Color(0xFF0F0F11)], // Elegant carbon black theme
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          if (isChamp)
            BoxShadow(
              color: const Color(0xFFE25B20).withValues(alpha: 0.12), // Subtle elegant glow opacity
              blurRadius: 16,
              spreadRadius: 0, // Soft atmospheric centering glow
              offset: const Offset(0, 6),
            )
          else
            BoxShadow(
              color: c.withValues(alpha: 0.05), // Added subtle ambient glow for #2 and #3 for premium depth
              blurRadius: 12,
              spreadRadius: 0.5,
              offset: const Offset(0, 4),
            ),
        ],
        border: Border.all(
          color: isChamp 
              ? const Color(0xFFE25B20).withValues(alpha: 0.35) 
              : c.withValues(alpha: 0.2), // Increased border contrast on side cards
          width: isChamp ? 1.5 : 1.2, // Visual stroke weight premium hierarchy
        ),
      ),
      child: Stack(
        children: [
          // Radial overlay ambient winner card glow
          if (isChamp)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 48.h,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFE25B20).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Rank Badge / Crown Element
                isChamp
                    ? Icon(
                        Icons.emoji_events_rounded, 
                        size: 20.sp, 
                        color: const Color(0xFFE25B20),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                       .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1500.ms, curve: Curves.easeInOut)
                    : Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: c.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: c.withValues(alpha: 0.25), width: 0.8),
                        ),
                        child: Text(
                          '#${u.rank}',
                          style: GoogleFonts.outfit(
                            fontSize: 9.sp, 
                            fontWeight: FontWeight.w900, 
                            color: c,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                SizedBox(height: 10.h),
                
                // Safe Avatar Element (Absolute zero question marks fallback)
                _buildPremiumAvatar(
                  name: u.name,
                  avatarUrl: u.avatarUrl,
                  size: isChamp ? 54.w : 44.w,
                  isChamp: isChamp,
                  accentColor: c,
                ),
                SizedBox(height: 10.h),
                
                // Truncation-safe Name
                Text(
                  _formatName(u.name),
                  style: GoogleFonts.outfit(
                    fontSize: 12.5.sp, 
                    fontWeight: FontWeight.w800, 
                    color: Colors.white,
                    letterSpacing: 0.1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                
                // Level Chip
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Text(
                    'LVL ${u.level}',
                    style: GoogleFonts.inter(
                      fontSize: 8.sp, 
                      fontWeight: FontWeight.w700,
                      color: isChamp ? const Color(0xFFE25B20) : Colors.white38,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10.h),
                
                // XP Score Value
                Text(
                  '${u.xp}',
                  style: GoogleFonts.outfit(
                    fontSize: isChamp ? 20.sp : 16.sp, 
                    fontWeight: FontWeight.w900, 
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  'XP',
                  style: GoogleFonts.outfit(
                    fontSize: 7.5.sp, 
                    fontWeight: FontWeight.w900, 
                    color: isChamp ? const Color(0xFFE25B20).withValues(alpha: 0.8) : AppTheme.textMuted, 
                    letterSpacing: 1.5,
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                // Fire/Streak count row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    Icon(Icons.local_fire_department_rounded, size: 11.sp, color: const Color(0xFFE25B20)),
                    SizedBox(width: 2.w),
                    Text(
                      '${u.level}', 
                      style: GoogleFonts.outfit(
                        fontSize: 10.5.sp, 
                        fontWeight: FontWeight.w800, 
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08);
  }

  Widget _row(LeaderboardUserModel u, int index) {
    final isTop5 = u.rank <= 5;
    final rankColors = {
      1: const Color(0xFFFFE259),
      2: const Color(0xFFC0C0C0),
      3: const Color(0xFFCD7F32),
      4: const Color(0xFFE25B20), // Orange accent for #4
      5: const Color(0xFFE25B20).withValues(alpha: 0.7), // Orange accent for #5
    };
    final rankColor = rankColors[u.rank] ?? Colors.white24;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isTop5 
              ? rankColor.withValues(alpha: 0.15) 
              : AppTheme.surfaceBorder,
          width: isTop5 ? 1.2 : 1,
        ),
        boxShadow: [
          if (isTop5)
            BoxShadow(
              color: rankColor.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Centered all elements vertically for pixel-perfect balance
        children: [
          // Rank Badge/Number
          SizedBox(
            width: 36.w, // Slightly increased for comfortable spacing alignment
            child: Align(
              alignment: Alignment.centerLeft,
              child: isTop5
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: rankColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: rankColor.withValues(alpha: 0.15), width: 0.8),
                      ),
                      child: Text(
                        '#${u.rank}',
                        style: GoogleFonts.outfit(
                          fontSize: 9.sp, 
                          fontWeight: FontWeight.w900, 
                          color: rankColor,
                        ),
                      ),
                    )
                  : Text(
                      '#${u.rank}',
                      style: GoogleFonts.outfit(
                        fontSize: 11.sp, 
                        fontWeight: FontWeight.w700, 
                        color: Colors.white24,
                      ),
                    ),
            ),
          ),
          
          // Premium Avatar (Safe Fallback)
          _buildPremiumAvatar(
            name: u.name,
            avatarUrl: u.avatarUrl,
            size: 34.w,
            isChamp: false,
            accentColor: rankColor,
          ),
          SizedBox(width: 12.w),
          
          // Username and Level details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatName(u.name),
                  style: GoogleFonts.outfit(
                    fontSize: 13.5.sp, 
                    fontWeight: FontWeight.w700, 
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                SizedBox(height: 3.h), // Refined typography vertical gap
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'LVL ${u.level}',
                      style: GoogleFonts.inter(
                        fontSize: 9.sp, 
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMuted,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '•',
                      style: TextStyle(
                        color: Colors.white10,
                        fontSize: 8.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.local_fire_department_rounded, size: 9.sp, color: const Color(0xFFE25B20)),
                    SizedBox(width: 2.w),
                    Text(
                      '${u.level}',
                      style: GoogleFonts.outfit(
                        fontSize: 9.5.sp, 
                        fontWeight: FontWeight.w700, 
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // XP badge pill chip
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE25B20).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: const Color(0xFFE25B20).withValues(alpha: 0.15),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${u.xp}',
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp, 
                    fontWeight: FontWeight.w900, 
                    color: Colors.white,
                    letterSpacing: -0.1,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  'XP',
                  style: GoogleFonts.outfit(
                    fontSize: 8.sp, 
                    fontWeight: FontWeight.w900, 
                    color: const Color(0xFFE25B20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 40 * index), duration: 300.ms);
  }

  // ----------------------------------------------------
  // Sleek Private Layout Helpers
  // ----------------------------------------------------

  Widget _buildPremiumAvatar({
    required String? name,
    required String? avatarUrl,
    required double size,
    required bool isChamp,
    required Color accentColor,
  }) {
    final cleanName = name?.trim() ?? '';
    final isAnonymous = cleanName.isEmpty || cleanName.toLowerCase() == 'anonymous';
    
    // Get initials safely (only if not anonymous and contains letters)
    final initials = !isAnonymous && RegExp(r'[a-zA-Z]').hasMatch(cleanName)
        ? cleanName.split(' ').where((s) => s.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase()
        : '';

    final hasInitials = initials.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        gradient: LinearGradient(
          colors: isChamp 
              ? [const Color(0xFFFF8A50), const Color(0xFFE25B20)] 
              : [accentColor.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isChamp ? const Color(0xFFE25B20) : accentColor).withValues(alpha: isChamp ? 0.12 : 0.05), // Refined elegant glow opacity
            blurRadius: isChamp ? 8 : 6, // Softer elegant blur
            spreadRadius: isChamp ? 0 : 1, // Compact glowing outline
          ),
        ],
        border: Border.all(
          color: isChamp 
              ? const Color(0xFFFF9E70).withValues(alpha: 0.3) // Clean refined border color opacity
              : accentColor.withValues(alpha: 0.3),
          width: isChamp ? 1.5 : 1.2, // Balanced border weight
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.32),
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          alignment: Alignment.center,
          child: hasInitials
              ? Text(
                  initials,
                  style: GoogleFonts.outfit(
                    fontSize: (size * 0.34).sp,
                    fontWeight: FontWeight.w900,
                    color: isChamp ? Colors.white : Colors.white70,
                    letterSpacing: 0.5,
                  ),
                )
              : Icon(
                  Icons.fingerprint_rounded, // Premium neutral anonymous design (Hacker-vibe finger key lock)
                  size: (size * 0.48).sp,
                  color: isChamp ? Colors.white : Colors.white54,
                ),
        ),
      ),
    );
  }

  String _formatName(String? name) {
    if (name == null || name.trim().isEmpty) return 'Anonymous';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      final firstName = parts[0];
      final lastInitial = parts[1][0];
      return '$firstName $lastInitial.';
    }
    return name;
  }
}
