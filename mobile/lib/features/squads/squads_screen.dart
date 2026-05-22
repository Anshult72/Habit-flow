import 'package:flutter/material.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart'; // Required for ScrollDirection listening

import '../../core/theme/app_theme.dart';
import '../../services/squad_service.dart';
import '../../models/squad_model.dart';
import 'create_squad_dialog.dart';
import 'join_squad_dialog.dart';

/// Global provider to track if any modal is open and hide the FAB to avoid overlaps
final squadModalOpenProvider = StateProvider<bool>((ref) => false);

class SquadsScreen extends ConsumerStatefulWidget {
  const SquadsScreen({super.key});

  @override
  ConsumerState<SquadsScreen> createState() => _SquadsScreenState();
}

class _SquadsScreenState extends ConsumerState<SquadsScreen> {
  late final ScrollController _scrollController;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Auto-hide FAB on downward scroll, auto-show on upward scroll
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isFabVisible) {
        setState(() => _isFabVisible = false);
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isFabVisible) {
        setState(() => _isFabVisible = true);
      }
    }
  }

  Future<void> _openCreateModal(BuildContext context, WidgetRef ref) async {
    ref.read(squadModalOpenProvider.notifier).state = true;
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => const CreateSquadDialog(),
    );
    ref.read(squadModalOpenProvider.notifier).state = false;
  }

  Future<void> _openJoinModal(BuildContext context, WidgetRef ref) async {
    ref.read(squadModalOpenProvider.notifier).state = true;
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => const JoinSquadDialog(),
    );
    ref.read(squadModalOpenProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final squadsAsync = ref.watch(squadsProvider);
    final isModalOpen = ref.watch(squadModalOpenProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEXUS', 
                        style: GoogleFonts.outfit(
                          fontSize: 11.sp, 
                          fontWeight: FontWeight.w900, 
                          color: const Color(0xFFE25B20), 
                          letterSpacing: 2.8.sp,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Squad Challenges', 
                        style: GoogleFonts.outfit(
                          fontSize: 22.sp, 
                          fontWeight: FontWeight.w800, 
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  
                  // Prominent and visually balanced contextual Header badge
                  squadsAsync.maybeWhen(
                    data: (squads) {
                      final hasSquad = squads.isNotEmpty;
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h), // Increased padding for visual prominence
                        decoration: BoxDecoration(
                          color: const Color(0xFFE25B20).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFE25B20).withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasSquad ? Icons.leaderboard_rounded : Icons.explore_rounded, 
                              size: 11.5.sp, 
                              color: const Color(0xFFFF7E47),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              hasSquad ? 'LEADERBOARD' : 'DISCOVER', 
                              style: GoogleFonts.outfit(
                                fontSize: 10.sp, 
                                fontWeight: FontWeight.w900, 
                                color: const Color(0xFFFF7E47),
                                letterSpacing: 1.5.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    orElse: () => Container(),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            SizedBox(height: 16.h),

            Expanded(
              child: squadsAsync.when(
                data: (squads) {
                  final hasSquad = squads.isNotEmpty;
                  final activeSquad = hasSquad ? squads.first : null;

                  return ListView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: [
                      // 1. Dynamic Hero: Onboarding Empty State Hero vs Direct Squad Info
                      _buildTribeHeroCard(context, ref, activeSquad)
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 400.ms)
                          .slideY(begin: 0.05),

                      SizedBox(height: 28.h), // Increased breathing gap by 8% (Hero -> Rankings)

                      // 2. Weekly Squad Leaderboard Section
                      Text(
                        'WEEKLY SQUAD RANKINGS', 
                        style: GoogleFonts.outfit(
                          fontSize: 9.sp, 
                          fontWeight: FontWeight.w900, 
                          color: Colors.white.withValues(alpha: 0.38),
                          letterSpacing: 1.6.sp,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _buildTribeLeaderboard(hasSquad, activeSquad),

                      SizedBox(height: 30.h), // Increased breathing gap by 7% (Rankings -> Active Challenges)

                      // 3. Active Group Challenges
                      Text(
                        'ACTIVE GROUP CHALLENGES', 
                        style: GoogleFonts.outfit(
                          fontSize: 9.sp, 
                          fontWeight: FontWeight.w900, 
                          color: Colors.white.withValues(alpha: 0.38),
                          letterSpacing: 1.6.sp,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _buildActiveGroupChallenges(hasSquad),

                      SizedBox(height: 30.h), // Increased breathing gap by 7% (Active Challenges -> Activity Feed)

                      // 4. Live Social Activity Feed
                      Text(
                        'RECENT ACTIVITY FEED', 
                        style: GoogleFonts.outfit(
                          fontSize: 9.sp, 
                          fontWeight: FontWeight.w900, 
                          color: Colors.white.withValues(alpha: 0.38),
                          letterSpacing: 1.6.sp,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _buildSocialActivityFeed(hasSquad),

                      SizedBox(height: 140.h), // Safe bottom clearance scroll cushion
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: HFShimmerList(height: 120, count: 3),
                ),
                error: (e, _) => HFErrorState(
                  onRetry: () => ref.invalidate(squadsProvider),
                ),
              ),
            ),
          ],
        ),
      ),
      // Auto-hide FAB using standard Slide & Opacity transition triggers
      floatingActionButton: isModalOpen 
          ? null 
          : AnimatedSlide(
              duration: const Duration(milliseconds: 260),
              curve: Curves.fastOutSlowIn,
              offset: _isFabVisible ? Offset.zero : const Offset(0, 2), // Slides down out of screen safe space
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isFabVisible ? 1.0 : 0.0,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 94.h),
                  child: GestureDetector(
                    onTap: () => _openCreateModal(context, ref),
                    child: Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF7E47), Color(0xFFE25B20)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE25B20).withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // Hero Card Spacing Rebalancing
  Widget _buildTribeHeroCard(BuildContext context, WidgetRef ref, SquadModel? squad) {
    final hasSquad = squad != null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: hasSquad ? 18.h : 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        gradient: const LinearGradient(
          colors: [Color(0xFF1C110C), Color(0xFF0F0F0F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFE25B20).withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE25B20).withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE25B20).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.diversity_3_rounded, size: 14.sp, color: const Color(0xFFFF7E47)),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    hasSquad ? squad.name.toUpperCase() : 'NO SQUAD YET', 
                    style: GoogleFonts.outfit(
                      fontSize: 13.5.sp, 
                      fontWeight: FontWeight.w900, 
                      color: Colors.white,
                      letterSpacing: 0.6.sp,
                    ),
                  ),
                ],
              ),
              if (hasSquad)
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: squad.inviteCode));
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invite Code copied to Clipboard!'), backgroundColor: AppTheme.success),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.copy_rounded, size: 8.sp, color: Colors.white60),
                        SizedBox(width: 2.w),
                        Text(
                          squad.inviteCode, 
                          style: GoogleFonts.outfit(
                            fontSize: 8.sp, 
                            fontWeight: FontWeight.w900, 
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            hasSquad ? 'Active Accountability Tribe' : 'Build your accountability tribe and grow together',
            style: GoogleFonts.inter(
              fontSize: 11.sp, 
              color: Colors.white.withValues(alpha: 0.45),
              height: 1.35,
            ),
          ),
          SizedBox(height: hasSquad ? 14.h : 10.h),
          Divider(color: Colors.white.withValues(alpha: 0.04), height: 1),
          SizedBox(height: hasSquad ? 12.h : 10.h),

          // Option A: Hide placeholder metrics row completely when user has no squad
          if (hasSquad) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeroStat('MEMBERS', '${squad.members.length}'),
                _buildHeroStat('ACTIVE RUNS', '4 Sprints'),
                _buildHeroStat('TRIBE XP', '${squad.entryXP} XP'),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Text(
                  'TRIBE MEMBERS:', 
                  style: GoogleFonts.outfit(fontSize: 8.sp, fontWeight: FontWeight.w900, color: Colors.white38),
                ),
                SizedBox(width: 8.w),
                // Overlapping Mini Avatars Stack
                Row(
                  children: [
                    ...squad.members.take(3).map((m) => Align(
                      widthFactor: 0.6,
                      child: CircleAvatar(
                        radius: 10.r,
                        backgroundColor: const Color(0xFF111111),
                        child: CircleAvatar(
                          radius: 9.r,
                          backgroundColor: const Color(0xFFFF7E47),
                          child: Text(
                            m.userId.substring(0, 1).toUpperCase(),
                            style: GoogleFonts.outfit(fontSize: 8.sp, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ),
                      ),
                    )),
                    if (squad.members.length > 3)
                      Padding(
                        padding: EdgeInsets.only(left: 10.w),
                        child: Text(
                          '+${squad.members.length - 3} others',
                          style: GoogleFonts.inter(fontSize: 9.sp, color: Colors.white60),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 14.h),
          ],

          if (!hasSquad)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openJoinModal(context, ref),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.5.h),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                      ),
                      child: Text(
                        'JOIN SQUAD',
                        style: GoogleFonts.outfit(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openCreateModal(context, ref),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.5.h),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF7E47), Color(0xFFE25B20)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE25B20).withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        'CREATE SQUAD',
                        style: GoogleFonts.outfit(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      try {
                        await ref.read(squadServiceProvider).deleteSquad(squad.id);
                        ref.invalidate(squadsProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Left Squad successfully.'), backgroundColor: AppTheme.danger),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.danger),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppTheme.danger.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        'LEAVE TRIBE',
                        style: GoogleFonts.outfit(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.danger,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: squad.inviteCode));
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invite Code copied! Share with friends.'), backgroundColor: AppTheme.success),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppTheme.success.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        'SHARE TRIBE CODE',
                        style: GoogleFonts.outfit(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.success,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value) {
    return Column(
      children: [
        Text(
          label, 
          style: GoogleFonts.outfit(
            fontSize: 8.5.sp, 
            fontWeight: FontWeight.w800, 
            color: Colors.white38,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value, 
          style: GoogleFonts.outfit(
            fontSize: 18.sp, 
            fontWeight: FontWeight.w900, 
            color: const Color(0xFFFF7E47),
          ),
        ),
      ],
    );
  }

  // Weekly Leaderboard Section with locked mock preview
  Widget _buildTribeLeaderboard(bool hasSquad, SquadModel? squad) {
    if (!hasSquad) {
      final mockRankings = [
        {'name': 'Alpha Tribe', 'rank': 1},
        {'name': 'Focus Elites', 'rank': 2},
        {'name': 'Discipline Masters', 'rank': 3},
      ];

      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.15,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Column(
                  children: mockRankings.map((member) {
                    final rank = member['rank'] as int;
                    return Container(
                      margin: EdgeInsets.only(bottom: 6.h),
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0A0A),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '🏆 #$rank',
                            style: GoogleFonts.outfit(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white30,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member['name'] as String,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '?? habits • ??? focus mins • ??? XP',
                                  style: GoogleFonts.inter(
                                    fontSize: 9.sp,
                                    color: Colors.white30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline_rounded, size: 22.sp, color: const Color(0xFFFF7E47).withValues(alpha: 0.8)),
                SizedBox(height: 6.h),
                Text(
                  'Join or create a squad to unlock rankings',
                  style: GoogleFonts.outfit(
                    fontSize: 10.sp, 
                    fontWeight: FontWeight.w800, 
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 0.4.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      );
    }

    final mockRankings = [
      {'name': 'Anshul T. (You)', 'habits': 12, 'focus': 420, 'xp': 220, 'rank': 1},
      {'name': 'Rohan K.', 'habits': 8, 'focus': 300, 'xp': 150, 'rank': 2},
      {'name': 'Deepak S.', 'habits': 6, 'focus': 180, 'xp': 90, 'rank': 3},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockRankings.length,
      itemBuilder: (context, idx) {
        final member = mockRankings[idx];
        final rank = member['rank'] as int;
        return Container(
          margin: EdgeInsets.only(bottom: 6.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
          ),
          child: Row(
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: rank == 1 ? const Color(0xFFFFD700).withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.02),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '#$rank',
                  style: GoogleFonts.outfit(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                    color: rank == 1 ? const Color(0xFFFFD700) : Colors.white30,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member['name'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${member['habits']} habits • ${member['focus']} focus mins • ${member['xp']} XP',
                      style: GoogleFonts.inter(
                        fontSize: 9.5.sp,
                        color: Colors.white.withValues(alpha: 0.38),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.analytics_rounded, size: 14.sp, color: Colors.white12),
            ],
          ),
        );
      },
    );
  }

  // Active Group Challenges Section (Subtle differentiation per challenge type)
  Widget _buildActiveGroupChallenges(bool hasSquad) {
    return Column(
      children: [
        // CARD 1: HABIT DOMINANCE (Vibrant green accent + Team contribution focus)
        Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.08)), // Subtle green contrast
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '🔥 Habit Dominance Sprint',
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'STREAK ACTIVE',
                          style: GoogleFonts.outfit(fontSize: 6.5.sp, fontWeight: FontWeight.w900, color: const Color(0xFF22C55E)),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '4 days left',
                    style: GoogleFonts.inter(
                      fontSize: 8.5.sp,
                      color: const Color(0xFF22C55E),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(3.r),
                child: LinearProgressIndicator(
                  value: 0.72,
                  backgroundColor: Colors.white.withValues(alpha: 0.02),
                  color: const Color(0xFF22C55E), // Distinct green for habit progress
                  minHeight: 5.h,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ...['A', 'R', 'D'].map((initial) => Align(
                        widthFactor: 0.6,
                        child: CircleAvatar(
                          radius: 8.r,
                          backgroundColor: const Color(0xFF111111),
                          child: CircleAvatar(
                            radius: 7.r,
                            backgroundColor: const Color(0xFF22C55E).withValues(alpha: 0.8),
                            child: Text(
                              initial,
                              style: GoogleFonts.outfit(fontSize: 7.sp, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      )),
                      SizedBox(width: 8.w),
                      Text(
                        '+3 contributing members',
                        style: GoogleFonts.inter(
                          fontSize: 8.5.sp, 
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF22C55E).withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '38/50 Completed',
                    style: GoogleFonts.inter(fontSize: 8.5.sp, color: Colors.white60),
                  ),
                ],
              ),
            ],
          ),
        ),

        // CARD 2: FOCUS MARATHON (Blue stopwatch accent + Time-centric emphasis)
        Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.08)), // Subtle blue contrast
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '🎯 Focus Marathon',
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(Icons.timer_outlined, size: 11.sp, color: const Color(0xFF3B82F6)),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.military_tech_rounded, size: 10.sp, color: const Color(0xFFFFD700)),
                        SizedBox(width: 2.w),
                        Text(
                          '16 XP',
                          style: GoogleFonts.outfit(fontSize: 8.sp, fontWeight: FontWeight.w900, color: const Color(0xFFFFD700)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(3.r),
                child: LinearProgressIndicator(
                  value: 0.45,
                  backgroundColor: Colors.white.withValues(alpha: 0.02),
                  color: const Color(0xFF3B82F6), // Blue for Focus tracking
                  minHeight: 5.h,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '⏳ 840 mins focused of 1200 mins goal', // Time-centric text
                    style: GoogleFonts.inter(
                      fontSize: 8.5.sp, 
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Group: 45%',
                    style: GoogleFonts.inter(fontSize: 8.5.sp, color: Colors.white60),
                  ),
                ],
              ),
            ],
          ),
        ),

        // CARD 3: LEARNING LEAGUE (Gold accent + XP/progress ring emphasis)
        Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFFFB347).withValues(alpha: 0.08)), // Subtle gold contrast
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '📚 Learning League',
                              style: GoogleFonts.outfit(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                            ),
                            SizedBox(width: 5.w),
                            Icon(Icons.bookmark_added_rounded, size: 10.sp, color: const Color(0xFFFFB347)),
                          ],
                        ),
                        Text(
                          '2 days left',
                          style: GoogleFonts.inter(
                            fontSize: 8.5.sp,
                            color: const Color(0xFFFFB347),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    // Highlighting XP visually
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB347).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: const Color(0xFFFFB347).withValues(alpha: 0.15)),
                      ),
                      child: Text(
                        '🎯 Tribe Target: 1820 / 2000 XP',
                        style: GoogleFonts.outfit(
                          fontSize: 9.sp, 
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFB347),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              // Compact circular progress ring
              SizedBox(
                width: 40.w,
                height: 40.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: 0.85,
                      backgroundColor: Colors.white.withValues(alpha: 0.03),
                      color: const Color(0xFFFFB347), // Gold for Learning progress
                      strokeWidth: 3.5.w,
                    ),
                    Text(
                      '85%',
                      style: GoogleFonts.outfit(fontSize: 8.5.sp, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // CARD 4: MIXED DISCIPLINE (Premium Orange gradient Special Event styling)
        Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(14.r),
            // Premium event highlight border using elegant orange gradient outline
            border: Border.all(color: const Color(0xFFFF7E47).withValues(alpha: 0.3), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF7E47).withValues(alpha: 0.03),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '⚡ Mixed Discipline Challenge',
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900, // Extra bold
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(Icons.bolt, size: 12.sp, color: const Color(0xFFFF7E47))
                          .animate(onPlay: (controller) => controller.repeat(reverse: true))
                          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.2, 1.2), duration: 800.ms),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF7E47), Color(0xFFE25B20)],
                      ),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'SPECIAL RUN',
                      style: GoogleFonts.outfit(fontSize: 7.sp, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(3.r),
                child: LinearProgressIndicator(
                  value: 0.60,
                  backgroundColor: Colors.white.withValues(alpha: 0.02),
                  color: const Color(0xFFFF7E47), // Pulse Orange
                  minHeight: 5.h,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🏆 All active metrics contributing',
                    style: GoogleFonts.inter(
                      fontSize: 8.5.sp, 
                      color: const Color(0xFFFF7E47),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '5 days remaining',
                    style: GoogleFonts.inter(fontSize: 8.5.sp, color: Colors.white60),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Recent Activity Feed (Micro polished for premium visual presence)
  Widget _buildSocialActivityFeed(bool hasSquad) {
    final activities = [
      {'user': 'Rohan K.', 'act': 'completed 3 habits', 'time': '2 hrs ago', 'icon': Icons.fact_check_rounded, 'color': const Color(0xFF22C55E)},
      {'user': 'Deepak S.', 'act': 'added 90 focus minutes', 'time': '4 hrs ago', 'icon': Icons.psychology_rounded, 'color': const Color(0xFF3B82F6)},
      {'user': 'Aman R.', 'act': 'reached 5-day streak', 'time': '5 hrs ago', 'icon': Icons.local_fire_department_rounded, 'color': const Color(0xFFFF7E47)},
      {'user': 'Rahul P.', 'act': 'earned 120 learning XP', 'time': '8 hrs ago', 'icon': Icons.school_rounded, 'color': const Color(0xFFFFB347)},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, idx) {
        final act = activities[idx];
        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.5.h), // Row height scaled by 12%
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(7.w), // Icon container size upscaled by ~15%
                decoration: BoxDecoration(
                  color: (act['color'] as Color).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(act['icon'] as IconData, size: 13.sp, color: act['color'] as Color), // Icon upscaled to 13.sp
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      act['user'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 11.5.sp, // Prominent username
                        fontWeight: FontWeight.w900, // Stronger weight
                        color: Colors.white.withValues(alpha: 0.9), // Higher contrast
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        act['act'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 10.5.sp, // Refined height
                          fontWeight: FontWeight.w500, // Cleaner weight
                          color: Colors.white.withValues(alpha: 0.54), // Upgraded description contrast
                          height: 1.35,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                act['time'] as String,
                style: GoogleFonts.inter(
                  fontSize: 9.sp, // Enhanced timestamp
                  fontWeight: FontWeight.w600, // Readable weight
                  color: Colors.white.withValues(alpha: 0.45), // Premium subtle contrast
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
