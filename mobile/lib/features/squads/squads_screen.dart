import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../services/squad_service.dart';
import '../../services/user_service.dart';
import '../../models/squad_model.dart';
import 'create_squad_dialog.dart';

/// Squads nexus using web's glass-card design.
class SquadsScreen extends ConsumerWidget {
  const SquadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final squadsAsync = ref.watch(squadsProvider);
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
                  Text('NEXUS', style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 2)),
                  SizedBox(height: 4.h),
                  Text('Squad Challenges', style: GoogleFonts.outfit(fontSize: 24.sp, fontWeight: FontWeight.w800, color: AppTheme.textMain, letterSpacing: -0.5)),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: squadsAsync.when(
                data: (squads) {
                  if (squads.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.groups_rounded, size: 48.sp, color: AppTheme.primary.withValues(alpha: 0.4)),
                          SizedBox(height: 16.h),
                          Text('NO ACTIVE SQUADS', style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1.5)),
                          SizedBox(height: 8.h),
                          Text('Create or join from the web app', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white24)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 120.h),
                    itemCount: squads.length,
                    itemBuilder: (context, index) {
                      final currentUserId = userAsync.valueOrNull?.id;
                      return _buildSquadCard(context, ref, squads[index], index, currentUserId);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2)),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sync failed', style: GoogleFonts.inter(color: AppTheme.textMain)),
                      TextButton(onPressed: () => ref.invalidate(squadsProvider), child: Text('RETRY', style: GoogleFonts.outfit(color: AppTheme.primary, fontWeight: FontWeight.w700))),
                    ],
                  ),
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
              builder: (ctx) => const CreateSquadDialog(),
            );
          },
          backgroundColor: AppTheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSquadCard(BuildContext context, WidgetRef ref, SquadModel squad, int index, String? currentUserId) {
    final requestList = squad.requests;
    final pendingRequest = requestList?.where((r) => r['status'] == 'pending').firstOrNull;
    final isPendingReceiver = pendingRequest != null;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(20.w),
      decoration: AppTheme.glassCard(borderRadius: AppTheme.radiusXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(squad.name.toUpperCase(), style: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppTheme.textMain), overflow: TextOverflow.ellipsis),
              ),
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                ),
                child: Icon(Icons.groups_rounded, color: AppTheme.primary, size: 18.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text('${squad.members.length} Members • ${squad.status.toUpperCase()}', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11.sp)),
          SizedBox(height: 14.h),
          if (isPendingReceiver) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _respondToSquad(ref, context, pendingRequest['id'], false),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger.withValues(alpha: 0.2), foregroundColor: AppTheme.danger),
                    child: Text('DECLINE', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _respondToSquad(ref, context, pendingRequest['id'], true),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success.withValues(alpha: 0.2), foregroundColor: AppTheme.success),
                    child: Text('JOIN SQUAD', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ] else
            Row(
            children: [
              ...squad.members.take(4).map((_) => Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: CircleAvatar(radius: 12.r, backgroundColor: Colors.white.withValues(alpha: 0.05), child: Icon(Icons.person, size: 12.sp, color: Colors.white24)),
              )),
              if (squad.members.length > 4)
                Text('+${squad.members.length - 4}', style: GoogleFonts.inter(color: Colors.white24, fontSize: 11.sp)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 80 * index), duration: 400.ms).slideY(begin: 0.05);
  }

  Future<void> _respondToSquad(WidgetRef ref, BuildContext context, String requestId, bool accept) async {
    try {
      await ref.read(squadServiceProvider).respondToRequest(requestId, accept);
      ref.invalidate(squadsProvider);
      ref.invalidate(userProfileProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e', style: const TextStyle(color: Colors.white)), backgroundColor: AppTheme.danger));
    }
  }
}
