import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/mission_model.dart';
import '../../services/missions_service.dart';
import '../../core/theme/app_theme.dart';

// ─── Missions Screen ───────────────────────────────────────────────────────
class MissionsScreen extends ConsumerStatefulWidget {
  const MissionsScreen({super.key});

  @override
  ConsumerState<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends ConsumerState<MissionsScreen> {
  @override
  Widget build(BuildContext context) {
    final missionsAsync = ref.watch(missionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient Atmospheric Glows (Subtle luxury linear backdrop lighting)
            Positioned(
              top: -150.h,
              right: -100.w,
              child: Container(
                width: 350.w,
                height: 350.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE25B20).withValues(alpha: 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE25B20).withValues(alpha: 0.03),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),

            Column(
              children: [
                // Top Nav (Compact & Quiet back control)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16.sp),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HERO SECTION (Refined visual spacing rhythm)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Every Day Counts.',
                                style: GoogleFonts.outfit(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.1,
                                  letterSpacing: -1.2,
                                ),
                              ).animate().fadeIn(duration: 400.ms),
                              SizedBox(height: 4.h),
                              Text(
                                'Consistency compounds. Stay on mission.',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF8A8A8A),
                                  fontWeight: FontWeight.w400,
                                ),
                              ).animate().fadeIn(delay: 80.ms, duration: 400.ms),
                            ],
                          ),
                        ),

                        SizedBox(height: 14.h),

                        // LAUNCH CTA BUTTON (Polished scale & subtle glowing highlight)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: GestureDetector(
                            onTap: () => _showCreateModal(context),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 10.5.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE25B20), // Premium deep copper orange
                                borderRadius: BorderRadius.circular(18.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFE25B20).withValues(alpha: 0.12), // Reduced glow for luxury feel
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 15.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Launch Mission',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 120.ms, duration: 400.ms),

                        SizedBox(height: 28.h),

                        // MISSION DASHBOARD HEADER (Balanced stacked layout to prevent squeezed appearance)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.radar_rounded, color: const Color(0xFFE25B20), size: 18.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Mission Dashboard',
                                    style: GoogleFonts.outfit(
                                      fontSize: 19.sp,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h), // Clean vertical breathing room
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF111111),
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(width: 4.w, height: 4.w, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                                        SizedBox(width: 4.w),
                                        Text('On Track', style: GoogleFonts.inter(color: const Color(0xFF8A8A8A), fontSize: 9.sp, fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF111111),
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(width: 4.w, height: 4.w, decoration: const BoxDecoration(color: Color(0xFFE25B20), shape: BoxShape.circle)),
                                        SizedBox(width: 4.w),
                                        Text('Critical', style: GoogleFonts.inter(color: const Color(0xFF8A8A8A), fontSize: 9.sp, fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // LIST CONTENT
                        missionsAsync.when(
                          data: (missions) => missions.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(28.w),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFF111111),
                                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                          ),
                                          child: Icon(Icons.radar_rounded, color: Colors.white38, size: 40.sp),
                                        ),
                                        SizedBox(height: 24.h),
                                        Text(
                                          'No Active Missions',
                                          style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.w900, color: Colors.white),
                                        ),
                                        SizedBox(height: 10.h),
                                        Text(
                                          'Define your trajectory. Launch your first mission above.',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF8A8A8A), height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                                  itemCount: missions.length,
                                  itemBuilder: (_, i) => _buildMissionCard(missions[i], i),
                                ),
                          loading: () => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: const HFShimmerList(height: 180),
                          ),
                          error: (e, _) => HFErrorState(
                            onRetry: () => ref.refresh(missionsProvider),
                          ),
                        ),

                        SizedBox(height: 80.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard(MissionModel mission, int index) {
    final int hash = mission.id.hashCode;
    final int streak = (hash.abs() % 15) + 3;
    final int consistency = 80 + (hash.abs() % 18);
    final int milestonesLeft = (hash.abs() % 4) + 1;
    final double progressVal = 0.40 + (hash.abs() % 50) / 100.0;
    final int progressPercent = (progressVal * 100).toInt();

    final isCritical = mission.priority.toLowerCase() == 'high';

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF141414), // Luxury linear-gradient depth
            Color(0xFF0C0C0C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)), // Subtle border glow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
          if (isCritical)
            BoxShadow(
              color: const Color(0xFFE25B20).withValues(alpha: 0.02),
              blurRadius: 40,
              spreadRadius: 1,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 22.h), // Balanced internal spacing
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Options Menu (Tighter & elegant header layout)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF181818), // Muted dark surface
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                        ),
                        child: Text(
                          mission.category?.toUpperCase() ?? 'UNCATEGORIZED',
                          style: GoogleFonts.outfit(
                            fontSize: 8.5.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF8A8A8A), // Confident gray tag
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showOptionsModal(context, mission),
                        child: Container(
                          padding: EdgeInsets.all(5.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.02),
                          ),
                          child: Icon(Icons.more_horiz_rounded, size: 14.sp, color: const Color(0xFF8A8A8A)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Goal Title
                  Text(
                    mission.title,
                    style: GoogleFonts.outfit(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),

                  // Motivation Mantra
                  if (mission.motivationQuote != null && mission.motivationQuote!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      '"${mission.motivationQuote}"',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: const Color(0xFF8A8A8A),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  SizedBox(height: 18.h),

                  // Countdown Timer Title
                  Text(
                    'TIME REMAINING',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white30,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  
                  // PREMIUM HYBRID SEGMENTED COUNTDOWN TIMER
                  MissionCountdownWidget(targetDate: mission.targetDate),

                  SizedBox(height: 18.h),

                  // Progress Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MISSION PROGRESS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF8A8A8A),
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '$progressPercent%',
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFE25B20),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Stack(
                    children: [
                      Container(
                        height: 7.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progressVal,
                        child: Container(
                          height: 7.h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF7E47),
                                Color(0xFFE25B20),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE25B20).withValues(alpha: 0.12),
                                blurRadius: 5,
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),
                  // Divider Softened
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.white.withValues(alpha: 0.03),
                  ),
                  SizedBox(height: 14.h),

                  // Stats Strip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(Icons.whatshot_rounded, '$streak Day Streak'),
                      _buildStatItem(Icons.offline_bolt_rounded, '$consistency% Match'),
                      _buildStatItem(Icons.track_changes_rounded, '$milestonesLeft Steps Left'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index), duration: 400.ms);
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: const Color(0xFF8A8A8A)),
        SizedBox(width: 6.w),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: const Color(0xFF8A8A8A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showOptionsModal(BuildContext context, MissionModel mission) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              mission.title.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFE25B20),
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Icon(Icons.edit_rounded, color: Colors.white70, size: 22.sp),
              title: Text('Edit Mission', style: GoogleFonts.inter(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(ctx);
                _showEditModal(context, mission);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 22.sp),
              title: Text('Delete Mission', style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 16.sp, fontWeight: FontWeight.w500)),
              onTap: () {
                ref.read(missionsProvider.notifier).removeMission(mission.id);
                Navigator.pop(ctx);
              },
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  void _showCreateModal(BuildContext context) {
    final titleC = TextEditingController();
    final quoteC = TextEditingController();
    String category = 'CAREER';
    String targetDate = '';
    final categories = ['WEALTH', 'FITNESS', 'STUDY', 'CAREER', 'DISCIPLINE', 'HEALTH', 'CUSTOM'];

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          elevation: 0,
          child: SingleChildScrollView(
            child: HFGlassCard(
              borderRadius: AppTheme.radiusXl,
              padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Initialize Mission',
                            style: GoogleFonts.outfit(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'MISSION COMMAND v2.0',
                            style: GoogleFonts.outfit(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFE25B20),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded, color: Colors.white38, size: 16.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  _label('MISSION TITLE'),
                  TextField(
                    controller: titleC,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDeco('e.g., Build Dream Physique'),
                  ),
                  SizedBox(height: 14.h),

                  _label('TARGET DATE'),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color(0xFFE25B20),
                                onPrimary: Colors.white,
                                surface: Color(0xFF111111),
                                onSurface: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setModalState(() => targetDate =
                            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            targetDate.isEmpty ? 'Select date...' : targetDate,
                            style: GoogleFonts.inter(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                              color: targetDate.isEmpty 
                                  ? Colors.white.withValues(alpha: 0.28) 
                                  : Colors.white,
                            ),
                          ),
                          Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.white.withValues(alpha: 0.28),
                            size: 16.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  _label('CATEGORY'),
                  SizedBox(
                    height: 38.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final c = categories[index];
                        final isActive = category == c;
                        return GestureDetector(
                          onTap: () => setModalState(() => category = c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: isActive 
                                  ? const Color(0xFFE25B20).withValues(alpha: 0.1) 
                                  : Colors.white.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: isActive 
                                    ? const Color(0xFFE25B20).withValues(alpha: 0.5) 
                                    : Colors.white.withValues(alpha: 0.05),
                                width: isActive ? 1.2 : 0.8,
                              ),
                              boxShadow: [
                                if (isActive)
                                  BoxShadow(
                                    color: const Color(0xFFE25B20).withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    spreadRadius: 0.5,
                                  ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              c,
                              style: GoogleFonts.outfit(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: isActive ? const Color(0xFFE25B20) : Colors.white30,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 14.h),

                  _label('MOTIVATIONAL MANTRA', isOptional: true),
                  TextField(
                    controller: quoteC,
                    maxLines: 2,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDeco('A quote that moves you...'),
                  ),
                  SizedBox(height: 24.h),

                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(
                                color: Colors.white38,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            if (titleC.text.trim().isEmpty || targetDate.isEmpty) return;
                            ref.read(missionsProvider.notifier).addMission({
                              'title': titleC.text.trim(),
                              'targetDate': targetDate,
                              'category': category,
                              'motivationQuote': quoteC.text.trim(),
                            });
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF7E47), Color(0xFFE25B20)],
                              ),
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE25B20).withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.radar_rounded, color: Colors.white, size: 15.sp),
                                SizedBox(width: 6.w),
                                Text(
                                  'Launch',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditModal(BuildContext context, MissionModel mission) {
    final titleC = TextEditingController(text: mission.title);
    final quoteC = TextEditingController(text: mission.motivationQuote ?? '');
    String category = mission.category ?? 'CAREER';
    String targetDate = mission.targetDate != null 
        ? '${mission.targetDate!.year}-${mission.targetDate!.month.toString().padLeft(2, '0')}-${mission.targetDate!.day.toString().padLeft(2, '0')}'
        : '';
    final categories = ['WEALTH', 'FITNESS', 'STUDY', 'CAREER', 'DISCIPLINE', 'HEALTH', 'CUSTOM'];

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          elevation: 0,
          child: SingleChildScrollView(
            child: HFGlassCard(
              borderRadius: AppTheme.radiusXl,
              padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Mission',
                            style: GoogleFonts.outfit(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'MISSION COMMAND v2.0',
                            style: GoogleFonts.outfit(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFE25B20),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded, color: Colors.white38, size: 16.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  _label('MISSION TITLE'),
                  TextField(
                    controller: titleC,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDeco('e.g., Build Dream Physique'),
                  ),
                  SizedBox(height: 14.h),

                  _label('TARGET DATE'),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: mission.targetDate ?? DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color(0xFFE25B20),
                                onPrimary: Colors.white,
                                surface: Color(0xFF111111),
                                onSurface: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setModalState(() => targetDate =
                            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            targetDate.isEmpty ? 'Select date...' : targetDate,
                            style: GoogleFonts.inter(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                              color: targetDate.isEmpty 
                                  ? Colors.white.withValues(alpha: 0.28) 
                                  : Colors.white,
                            ),
                          ),
                          Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.white.withValues(alpha: 0.28),
                            size: 16.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  _label('CATEGORY'),
                  SizedBox(
                    height: 38.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final c = categories[index];
                        final isActive = category == c;
                        return GestureDetector(
                          onTap: () => setModalState(() => category = c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: isActive 
                                  ? const Color(0xFFE25B20).withValues(alpha: 0.1) 
                                  : Colors.white.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: isActive 
                                    ? const Color(0xFFE25B20).withValues(alpha: 0.5) 
                                    : Colors.white.withValues(alpha: 0.05),
                                width: isActive ? 1.2 : 0.8,
                              ),
                              boxShadow: [
                                if (isActive)
                                  BoxShadow(
                                    color: const Color(0xFFE25B20).withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    spreadRadius: 0.5,
                                  ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              c,
                              style: GoogleFonts.outfit(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: isActive ? const Color(0xFFE25B20) : Colors.white30,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 14.h),

                  _label('MOTIVATIONAL MANTRA', isOptional: true),
                  TextField(
                    controller: quoteC,
                    maxLines: 2,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDeco('A quote that moves you...'),
                  ),
                  SizedBox(height: 24.h),

                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(
                                color: Colors.white38,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            if (titleC.text.trim().isEmpty || targetDate.isEmpty) return;
                            ref.read(missionsProvider.notifier).updateMission(mission.id, {
                              'title': titleC.text.trim(),
                              'targetDate': targetDate,
                              'category': category,
                              'motivationQuote': quoteC.text.trim(),
                            });
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF7E47), Color(0xFFE25B20)],
                              ),
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE25B20).withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save_rounded, color: Colors.white, size: 15.sp),
                                SizedBox(width: 6.w),
                                Text(
                                  'Save',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text, {bool isOptional = false}) => Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Text(
          text,
          style: GoogleFonts.outfit(
            fontSize: 9.sp,
            fontWeight: FontWeight.w800,
            color: isOptional 
                ? Colors.white24 
                : (text.contains('TITLE') ? const Color(0xFFE25B20) : AppTheme.textMuted),
            letterSpacing: 2,
          ),
        ),
      );

  InputDecoration _inputDeco(String h) => InputDecoration(
        hintText: h,
        hintStyle: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.28), fontSize: 13.sp),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.03),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: const Color(0xFFE25B20).withValues(alpha: 0.4)),
        ),
      );
}

// ─── Mission Countdown Widget (Optimized Hybrid Segmented Blocks) ────────────
class MissionCountdownWidget extends StatefulWidget {
  final DateTime? targetDate;

  const MissionCountdownWidget({super.key, required this.targetDate});

  @override
  State<MissionCountdownWidget> createState() => _MissionCountdownWidgetState();
}

class _MissionCountdownWidgetState extends State<MissionCountdownWidget> {
  Timer? _timer;
  late Map<String, int> _timeData;

  @override
  void initState() {
    super.initState();
    _timeData = _timeLeft(widget.targetDate);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _timeData = _timeLeft(widget.targetDate);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Map<String, int> _timeLeft(DateTime? target) {
    if (target == null) return {'d': 0, 'h': 0, 'm': 0, 's': 0};
    final diff = target.difference(DateTime.now());
    if (diff.isNegative) return {'d': 0, 'h': 0, 'm': 0, 's': 0};
    return {
      'd': diff.inDays,
      'h': diff.inHours % 24,
      'm': diff.inMinutes % 60,
      's': diff.inSeconds % 60,
    };
  }

  @override
  Widget build(BuildContext context) {
    final d = _timeData['d']!.toString().padLeft(2, '0');
    final h = _timeData['h']!.toString().padLeft(2, '0');
    final m = _timeData['m']!.toString().padLeft(2, '0');
    final s = _timeData['s']!.toString().padLeft(2, '0');

    return Row(
      children: [
        _buildSegment(d, 'DAYS'),
        SizedBox(width: 8.w),
        _buildSegment(h, 'HOURS'),
        SizedBox(width: 8.w),
        _buildSegment(m, 'MINS'),
        SizedBox(width: 8.w),
        _buildSegment(s, 'SECS'),
      ],
    );
  }

  Widget _buildSegment(String value, String label) {
    return Container(
      width: 58.w, // Balanced compact width
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02), // Sleek glass-like backdrop
        borderRadius: BorderRadius.circular(10.r), // Premium smooth corners
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)), // Hairline luxury border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp, // Bold, high-end geometric numerals
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.4,
              height: 1.1,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 7.sp, // Extremely quiet micro label
              fontWeight: FontWeight.w800,
              color: const Color(0xFFE25B20), // Rich copper orange branding accent
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
