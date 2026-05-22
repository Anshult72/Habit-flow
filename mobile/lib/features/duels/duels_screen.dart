import 'package:flutter/material.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../services/duel_service.dart';
import '../../services/user_service.dart';
import '../../models/duel_model.dart';
import 'create_duel_dialog.dart';

class DuelsScreen extends ConsumerWidget {
  const DuelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duelsAsync = ref.watch(duelsProvider);
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header Row
            Padding(
              padding: EdgeInsets.fromLTRB(21.w, 17.h, 21.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ARENA', 
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp, 
                          fontWeight: FontWeight.w800, 
                          color: const Color(0xFFE25B20), 
                          letterSpacing: 2.5,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '1v1 Challenges', 
                        style: GoogleFonts.outfit(
                          fontSize: 23.5.sp, 
                          fontWeight: FontWeight.w800, 
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE25B20).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: const Color(0xFFE25B20).withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.shield_rounded, size: 13.sp, color: const Color(0xFFFF7E47)),
                        SizedBox(width: 4.w),
                        Text(
                          'LIVE', 
                          style: GoogleFonts.outfit(
                            fontSize: 9.6.sp, 
                            fontWeight: FontWeight.w900, 
                            color: const Color(0xFFFF7E47),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            SizedBox(height: 16.5.h),

            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFFE25B20),
                backgroundColor: const Color(0xFF111113),
                onRefresh: () async {
                  ref.invalidate(duelsProvider);
                  ref.invalidate(userProfileProvider);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: [
                    // 1. Premium Arena Stats Hero Card (Optimized by 15% height reduction)
                  _buildArenaHeroCard().animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.05),

                  SizedBox(height: 16.h),

                  // 2. Active Battles Section Title
                  Text(
                    'ACTIVE BATTLES', 
                    style: GoogleFonts.outfit(
                      fontSize: 9.6.sp, 
                      fontWeight: FontWeight.w900, 
                      color: Colors.white30,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Active battles list
                  duelsAsync.when(
                    data: (duels) {
                      if (duels.isEmpty) {
                        return _buildEmptyState().animate().fadeIn(duration: 350.ms);
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: duels.length,
                        itemBuilder: (context, index) {
                          final currentUserId = userAsync.valueOrNull?.id;
                          return _buildActiveDuelCard(context, ref, duels[index], index, currentUserId);
                        },
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: HFShimmerList(height: 110, count: 2),
                    ),
                    error: (e, _) => HFErrorState(
                      onRetry: () => ref.invalidate(duelsProvider),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // 3. Battle History Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BATTLE HISTORY', 
                        style: GoogleFonts.outfit(
                          fontSize: 9.6.sp, 
                          fontWeight: FontWeight.w900, 
                          color: Colors.white30,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'PAST 30 DAYS', 
                        style: GoogleFonts.outfit(
                          fontSize: 8.5.sp, 
                          fontWeight: FontWeight.w800, 
                          color: const Color(0xFFFF7E47),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  _buildBattleHistoryList(),

                  SizedBox(height: 90.h), // Safe spacer at bottom
                ],
              ),
            ),
          ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (ctx) => const CreateDuelDialog(),
            );
          },
          child: Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7E47), Color(0xFFE25B20)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE25B20).withValues(alpha: 0.15), // Reduced glow intensity by ~20%
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.5,
              ),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  // Redesigned Arena Stats Hero Card (Optimized premium vertical spacing scaled)
  Widget _buildArenaHeroCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 17.h), 
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        gradient: const LinearGradient(
          colors: [Color(0xFF1C110C), Color(0xFF0F0F0F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFE25B20).withValues(alpha: 0.3),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE25B20).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w), 
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9900).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFF9900).withValues(alpha: 0.25)),
                    ),
                    child: Icon(Icons.emoji_events_rounded, size: 15.sp, color: const Color(0xFFFFB347)),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GOLD LEAGUE IV', 
                        style: GoogleFonts.outfit(
                          fontSize: 13.sp, 
                          fontWeight: FontWeight.w900, 
                          color: const Color(0xFFFFB347),
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Top 8% Active Duels', 
                        style: GoogleFonts.inter(
                          fontSize: 10.sp, 
                          color: Colors.white30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                ),
                child: Text(
                  'Rank #242', 
                  style: GoogleFonts.outfit(
                    fontSize: 9.sp, 
                    fontWeight: FontWeight.w900, 
                    color: Colors.white60,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h), 
          Divider(color: Colors.white.withValues(alpha: 0.04), height: 1),
          SizedBox(height: 12.h), 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeroStat('WINS', '32', const Color(0xFF22C55E)),
              _buildHeroStat('LOSSES', '14', const Color(0xFFEF4444)),
              _buildHeroStat('WIN RATE', '70%', const Color(0xFF3B82F6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label, 
          style: GoogleFonts.outfit(
            fontSize: 9.sp, 
            fontWeight: FontWeight.w800, 
            color: Colors.white38,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value, 
          style: GoogleFonts.outfit(
            fontSize: 21.5.sp, 
            fontWeight: FontWeight.w900, 
            color: color,
          ),
        ),
      ],
    );
  }

  // Premium Empty State Redesign (Compact CTA Invitation Row Scaled Tighter)
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 11.h), 
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9.w), 
            decoration: BoxDecoration(
              color: const Color(0xFFE25B20).withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE25B20).withValues(alpha: 0.15),
                width: 1.0,
              ),
            ),
            child: Icon(
              Icons.military_tech_rounded, 
              size: 21.5.sp, 
              color: const Color(0xFFFF7E47),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(0.94, 0.94), end: const Offset(1.06, 1.06), duration: 2000.ms),
          ),
          SizedBox(width: 12.w), 
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter the Arena', 
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp, 
                    fontWeight: FontWeight.w800, 
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2.h), 
                Text(
                  'Challenge a rival, stake XP, and prove your discipline.', 
                  style: GoogleFonts.inter(
                    fontSize: 10.5.sp, 
                    color: Colors.white38,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Redesigned Active Duel Card
  Widget _buildActiveDuelCard(BuildContext context, WidgetRef ref, DuelModel duel, int index, String? currentUserId) {
    final isOpponent = currentUserId != null && duel.opponentId == currentUserId;
    final isCreator = currentUserId != null && duel.createdBy == currentUserId;
    final isPendingReceiver = duel.status == 'pending' && isOpponent;

    // High fidelity active stats
    final creatorName = duel.creator?['name']?.toString() ?? 'Creator';
    final opponentName = duel.opponent?['name']?.toString() ?? 'Rival';
    
    final creatorProgress = duel.participants.firstWhere((p) => p.userId == duel.createdBy, orElse: () => DuelParticipantModel(id: '', progress: 0, userId: '')).progress;
    final opponentProgress = duel.participants.firstWhere((p) => p.userId == duel.opponentId, orElse: () => DuelParticipantModel(id: '', progress: 0, userId: '')).progress;

    // Leader Logic
    final creatorLeading = creatorProgress > opponentProgress;
    final opponentLeading = opponentProgress > creatorProgress;

    return Container(
      margin: EdgeInsets.only(bottom: 11.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: duel.status == 'active' 
              ? const Color(0xFFE25B20).withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.05),
          width: duel.status == 'active' ? 1.0 : 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Header Status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.flash_on_rounded, 
                    size: 12.sp, 
                    color: duel.status == 'active' ? const Color(0xFFFF7E47) : Colors.white24,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    duel.status == 'active' ? 'LIVE DUEL' : 'PENDING CHALLENGE',
                    style: GoogleFonts.outfit(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w900,
                      color: duel.status == 'active' ? const Color(0xFFFF7E47) : Colors.white30,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                ),
                child: Text(
                  '${duel.entryXP} XP AT STAKE',
                  style: GoogleFonts.outfit(
                    fontSize: 8.5.sp,
                    color: const Color(0xFFFFB347),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Competitors layout
          Row(
            children: [
              // Competitor 1
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildBattleAvatar(
                          isCreator ? 'YOU' : creatorName.toUpperCase(), 
                          duel.creator?['avatarUrl'], 
                          creatorLeading,
                        ),
                        if (creatorLeading)
                          Positioned(
                            top: -6.h,
                            left: 0,
                            right: 0,
                            child: Icon(Icons.emoji_events_rounded, size: 12.sp, color: const Color(0xFFFFD700)),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '$creatorProgress pts',
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  children: [
                    Text(
                      'VS', 
                      style: GoogleFonts.outfit(
                        fontSize: 15.sp, 
                        fontWeight: FontWeight.w900, 
                        color: Colors.white12,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '${duel.durationDays}D',
                        style: GoogleFonts.outfit(
                          fontSize: 7.sp,
                          color: const Color(0xFFEF4444),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Competitor 2
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildBattleAvatar(
                          isOpponent ? 'YOU' : opponentName.toUpperCase(), 
                          duel.opponent?['avatarUrl'], 
                          opponentLeading,
                        ),
                        if (opponentLeading)
                          Positioned(
                            top: -6.h,
                            left: 0,
                            right: 0,
                            child: Icon(Icons.emoji_events_rounded, size: 12.sp, color: const Color(0xFFFFD700)),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '$opponentProgress pts',
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),

          // Double progress bars comparison (High gamification)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: Container(
                  height: 5.5.h,
                  width: double.infinity,
                  color: Colors.white.withValues(alpha: 0.03),
                  child: Row(
                    children: [
                      Expanded(
                        flex: creatorProgress == 0 && opponentProgress == 0 ? 5 : (creatorProgress == 0 ? 1 : creatorProgress),
                        child: Container(
                          color: creatorLeading ? const Color(0xFFFF7E47) : Colors.white24,
                        ),
                      ),
                      Container(width: 2.w, color: const Color(0xFF000000)),
                      Expanded(
                        flex: creatorProgress == 0 && opponentProgress == 0 ? 5 : (opponentProgress == 0 ? 1 : opponentProgress),
                        child: Container(
                          color: opponentLeading ? const Color(0xFFFF7E47) : Colors.white24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    creatorLeading ? '👑 $creatorName leading' : (opponentLeading ? '👑 $opponentName leading' : 'Tied'),
                    style: GoogleFonts.inter(
                      fontSize: 9.6.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF7E47),
                    ),
                  ),
                  Text(
                    'Time remaining: Active',
                    style: GoogleFonts.inter(
                      fontSize: 9.6.sp,
                      color: Colors.white30,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (isPendingReceiver) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: HFScalableButton(
                    onTap: () => _respondToDuel(ref, context, duel, false),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
                      ),
                      child: Center(
                        child: Text(
                          'DECLINE',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 10.sp,
                            color: AppTheme.danger,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: HFScalableButton(
                    onTap: () => _respondToDuel(ref, context, duel, true),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
                      ),
                      child: Center(
                        child: Text(
                          'ACCEPT',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 10.sp,
                            color: AppTheme.success,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 60 * index), duration: 250.ms);
  }

  Future<void> _respondToDuel(WidgetRef ref, BuildContext context, DuelModel duel, bool accept) async {
    try {
      HapticFeedback.mediumImpact();
      final requestList = duel.requests;
      if (requestList == null || requestList.isEmpty) {
        throw Exception('No pending request found for this duel');
      }
      final requestId = requestList.first['id'];
      
      await ref.read(duelServiceProvider).respondToRequest(requestId, accept);
      ref.invalidate(duelsProvider);
      ref.invalidate(userProfileProvider); // XP might have changed
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e', style: const TextStyle(color: Colors.white)), 
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  Widget _buildBattleAvatar(String label, String? avatarUrl, bool isLeading) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isLeading ? const Color(0xFFFFB347) : Colors.white.withValues(alpha: 0.05),
              width: 1.5,
            ),
          ),
          child: CircleAvatar(
            radius: 19.r, 
            backgroundColor: Colors.white.withValues(alpha: 0.04),
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null ? Icon(Icons.person, color: Colors.white24, size: 19.sp) : null,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label, 
          style: GoogleFonts.outfit(
            fontSize: 8.sp, 
            color: Colors.white54, 
            fontWeight: FontWeight.w800, 
            letterSpacing: 0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // Duel History Redesign (Scores matching specific Duel Types with premium spacing)
  Widget _buildBattleHistoryList() {
    final mockHistory = [
      {'opponent': 'Saurabh T.', 'type': 'Habit Completion', 'result': 'WON', 'score': '12 vs 8', 'xp': '+16 XP', 'date': 'May 16, 2026'},
      {'opponent': 'Rohan K.', 'type': 'Learning XP', 'result': 'LOST', 'score': '42 XP vs 56 XP', 'xp': '-8 XP', 'date': 'May 12, 2026'},
      {'opponent': 'Deepak S.', 'type': 'Focus Session', 'result': 'WON', 'score': '420m vs 310m', 'xp': '+32 XP', 'date': 'May 08, 2026'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockHistory.length,
      itemBuilder: (context, index) {
        final item = mockHistory[index];
        final isWon = item['result'] == 'WON';
        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 14.h), 
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.5.h),
                decoration: BoxDecoration(
                  color: isWon 
                      ? const Color(0xFF22C55E).withValues(alpha: 0.1) 
                      : const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: isWon 
                        ? const Color(0xFF22C55E).withValues(alpha: 0.2) 
                        : const Color(0xFFEF4444).withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  item['result']!,
                  style: GoogleFonts.outfit(
                    fontSize: 9.sp,
                    color: isWon ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'vs ${item['opponent']}',
                      style: GoogleFonts.outfit(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${item['type']} • ${item['date']}',
                      style: GoogleFonts.inter(
                        fontSize: 9.6.sp,
                        color: Colors.white30,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item['score']!,
                    style: GoogleFonts.outfit(
                      fontSize: 12.3.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item['xp']!,
                    style: GoogleFonts.outfit(
                      fontSize: 10.7.sp,
                      fontWeight: FontWeight.w800,
                      color: isWon ? const Color(0xFFFF9900) : Colors.white24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 40 * index), duration: 200.ms);
      },
    );
  }
}
