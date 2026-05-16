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

/// Duels arena using web's glass-card design.
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
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ARENA', style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 2)),
                  SizedBox(height: 4.h),
                  Text('1v1 Challenges', style: GoogleFonts.outfit(fontSize: 24.sp, fontWeight: FontWeight.w800, color: AppTheme.textMain, letterSpacing: -0.5)),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: duelsAsync.when(
                data: (duels) {
                  if (duels.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.military_tech_rounded, size: 48.sp, color: AppTheme.primary.withValues(alpha: 0.4)),
                          SizedBox(height: 16.h),
                          Text('NO ACTIVE DUELS', style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1.5)),
                          SizedBox(height: 8.h),
                          Text('Challenge someone from the web app', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white24)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 120.h),
                    itemCount: duels.length,
                    itemBuilder: (context, index) {
                      final currentUserId = userAsync.valueOrNull?.id;
                      return _buildDuelCard(context, ref, duels[index], index, currentUserId);
                    },
                  );
                },
                loading: () => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: const HFShimmerList(height: 100, count: 4),
                ),
                error: (e, _) => HFErrorState(
                  onRetry: () => ref.invalidate(duelsProvider),
                ),
                ),
              ),
            ],
          ),
        ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 80.h),
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const CreateDuelDialog(),
            );
          },
          backgroundColor: AppTheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDuelCard(BuildContext context, WidgetRef ref, DuelModel duel, int index, String? currentUserId) {
    final isOpponent = currentUserId != null && duel.opponentId == currentUserId;
    final isCreator = currentUserId != null && duel.createdBy == currentUserId;
    final isPendingReceiver = duel.status == 'pending' && isOpponent;

    return HFGlassCard(
      borderRadius: AppTheme.radiusXl,
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1V1 CHALLENGE',
                  style: GoogleFonts.outfit(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                      letterSpacing: 1)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(duel.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(duel.status.toUpperCase(),
                    style: GoogleFonts.outfit(
                        fontSize: 8.sp,
                        color: _getStatusColor(duel.status),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1)),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildAvatar(
                  isCreator
                      ? 'YOU'
                      : (duel.creator?['name']?.toString().toUpperCase() ??
                          'CREATOR'),
                  duel.creator?['avatarUrl']),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text('VS',
                    style: GoogleFonts.outfit(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white24)),
              ),
              _buildAvatar(
                  isOpponent
                      ? 'YOU'
                      : (duel.opponent?['name']?.toString().toUpperCase() ??
                          'OPPONENT'),
                  duel.opponent?['avatarUrl']),
            ],
          ),
          SizedBox(height: 14.h),
          Text('Stakes: ${duel.entryXP} XP  •  ${duel.durationDays} Days',
              style: GoogleFonts.inter(
                  color: AppTheme.textMuted, fontSize: 12.sp)),
          if (isPendingReceiver) ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: HFScalableButton(
                    onTap: () => _respondToDuel(ref, context, duel, false),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                          color: AppTheme.danger.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd)),
                      child: Center(
                          child: Text('DECLINE',
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.danger))),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: HFScalableButton(
                    onTap: () => _respondToDuel(ref, context, duel, true),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd)),
                      child: Center(
                          child: Text('ACCEPT',
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.success))),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 80 * index), duration: 400.ms).slideY(begin: 0.05);
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e', style: const TextStyle(color: Colors.white)), backgroundColor: AppTheme.danger));
    }
  }

  Widget _buildAvatar(String label, [String? avatarUrl]) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22.r,
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null ? Icon(Icons.person, color: Colors.white38, size: 22.sp) : null,
        ),
        SizedBox(height: 4.h),
        Text(label, style: GoogleFonts.outfit(fontSize: 8.sp, color: AppTheme.textMuted, fontWeight: FontWeight.w700, letterSpacing: 1)),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active': return AppTheme.success;
      case 'completed': return const Color(0xFF3B82F6);
      case 'declined': return AppTheme.danger;
      default: return AppTheme.accent;
    }
  }
}
