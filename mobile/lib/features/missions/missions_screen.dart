import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../models/mission_model.dart';
import '../../services/missions_service.dart';

// ─── Missions Screen ───────────────────────────────────────────────────────
class MissionsScreen extends ConsumerStatefulWidget {
  const MissionsScreen({super.key});

  @override
  ConsumerState<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends ConsumerState<MissionsScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
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
    final missionsAsync = ref.watch(missionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav (Optional / Kept simple for flow)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: 12.h),
                    // Hero Text
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        'Every habit you complete brings\nyour mission closer.\nThe clock never stops for those who\nchase greatness.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          color: Colors.white54,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                    
                    SizedBox(height: 32.h),
                    
                    // Initiate Button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: GestureDetector(
                        onTap: () => _showCreateModal(context),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 4)),
                            ]
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded, color: Colors.white, size: 20.sp),
                              SizedBox(width: 8.w),
                              Text('Initiate New Mission', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 500.ms),

                    SizedBox(height: 48.h),

                    // Active Operations Header
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.rocket_launch_outlined, color: AppTheme.primary, size: 24.sp),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Active\nOperations',
                              style: GoogleFonts.outfit(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(width: 6.w, height: 6.w, decoration: BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.circular(2.r))),
                              SizedBox(width: 6.w),
                              Text('On\nTrack', style: GoogleFonts.inter(color: Colors.white54, fontSize: 11.sp, height: 1.2)),
                              SizedBox(width: 16.w),
                              Container(width: 6.w, height: 6.w, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
                              SizedBox(width: 6.w),
                              Text('Critical', style: GoogleFonts.inter(color: Colors.white54, fontSize: 11.sp)),
                            ],
                          )
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 32.h),

                    // Content
                    missionsAsync.when(
                      data: (missions) => missions.isEmpty
                          ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(28.w),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                    ),
                                    child: Icon(Icons.rocket_launch_outlined, color: Colors.white38, size: 40.sp),
                                  ),
                                  SizedBox(height: 32.h),
                                  Text(
                                    'No Missions Detected.',
                                    style: GoogleFonts.outfit(fontSize: 24.sp, fontWeight: FontWeight.w900, color: Colors.white),
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'The future belongs to those who define it.\nCreate your first mission.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white54, height: 1.5),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              itemCount: missions.length,
                              itemBuilder: (_, i) => _buildMissionCard(missions[i], i),
                            ),
                      loading: () => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: const HFShimmerList(height: 120),
                      ),
                      error: (e, _) => HFErrorState(
                        onRetry: () => ref.refresh(missionsProvider),
                      ),
                    ),
                    
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard(MissionModel mission, int index) {
    final tl = _timeLeft(mission.targetDate);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top gradient
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primary.withValues(alpha: 0.5), Colors.transparent]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Delete
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Text(mission.category?.toUpperCase() ?? 'UNCATEGORIZED',
                          style: GoogleFonts.outfit(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                            letterSpacing: 1.5,
                          )),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(missionsProvider.notifier).removeMission(mission.id),
                      child: Icon(Icons.close_rounded, size: 16.sp, color: Colors.white24),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(mission.title,
                    style: GoogleFonts.outfit(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    )),
                if (mission.motivationQuote != null && mission.motivationQuote!.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text('"${mission.motivationQuote}"',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: Colors.white54,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],

                SizedBox(height: 24.h),

                // Countdown
                Row(
                  children: [
                    _buildTimeUnit('${tl['d']}', 'Days'),
                    SizedBox(width: 8.w),
                    _buildTimeUnit('${tl['h']}', 'Hrs'),
                    SizedBox(width: 8.w),
                    _buildTimeUnit('${tl['m']}', 'Min'),
                    SizedBox(width: 8.w),
                    _buildTimeUnit('${tl['s']}', 'Sec'),
                  ],
                ),

                SizedBox(height: 24.h),

                // Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('MISSION MOMENTUM',
                        style: GoogleFonts.outfit(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white54,
                          letterSpacing: 1.5,
                        )),
                    Text('65%',
                        style: GoogleFonts.outfit(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        )),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: 0.65,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                    minHeight: 6.h,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index), duration: 400.ms);
  }

  Widget _buildTimeUnit(String value, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Text(value.padLeft(2, '0'),
                style: GoogleFonts.outfit(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                )),
            Text(label,
                style: GoogleFonts.outfit(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white54,
                  letterSpacing: 1,
                )),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              Center(
                  child: Container(
                      width: 48.w,
                      height: 4.h,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2.r)))),
              SizedBox(height: 16.h),
              Text('TRAJECTORY',
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white54,
                    letterSpacing: 3,
                  )),
              SizedBox(height: 24.h),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('MISSION TITLE'),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: titleC,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
                        decoration: _inputDeco('e.g., Build Dream Physique'),
                      ),
                      SizedBox(height: 24.h),

                      _label('TARGET DATE'),
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setModalState(() => targetDate =
                                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                targetDate.isEmpty ? 'Select date...' : targetDate,
                                style: GoogleFonts.inter(fontSize: 14.sp, color: targetDate.isEmpty ? Colors.white38 : Colors.white),
                              ),
                              Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white38, size: 20.sp),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      _label('CATEGORY'),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: categories.map((c) {
                          final isActive = category == c;
                          return GestureDetector(
                            onTap: () => setModalState(() => category = c),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: isActive ? AppTheme.primary : Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: isActive ? AppTheme.primary : Colors.white.withValues(alpha: 0.05)),
                              ),
                              child: Text(c,
                                  style: GoogleFonts.outfit(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w800,
                                    color: isActive ? Colors.white : Colors.white54,
                                  )),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 24.h),

                      _label('MOTIVATIONAL MANTRA'),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: quoteC,
                        maxLines: 4,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
                        decoration: _inputDeco('A quote that moves you...'),
                      ),
                      SizedBox(height: 24.h),

                      _label('CONNECT HABITS'),
                      SizedBox(height: 8.h),
                      ...List.generate(3, (index) => Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: '',
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.02),
                            contentPadding: EdgeInsets.all(16.w),
                            suffixIcon: Icon(Icons.link_rounded, color: Colors.white24, size: 20.sp),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                          ),
                        ),
                      )),
                      
                      SizedBox(height: 32.h),

                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(ctx),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                alignment: Alignment.center,
                                child: Text('Cancel\nInitialization',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16.sp, height: 1.2)),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
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
                                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.radar_rounded, color: Colors.white, size: 20.sp),
                                    SizedBox(width: 8.w),
                                    Text('Launch\nMission',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16.sp,
                                          height: 1.2,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 1.5));

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 14.sp),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.02),
        contentPadding: EdgeInsets.all(16.w),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5))),
      );
}
