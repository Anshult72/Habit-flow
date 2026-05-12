import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

// ─── Data Model ────────────────────────────────────────────────────────────
class Mission {
  final String id;
  String title;
  String category;
  String targetDate; // yyyy-MM-dd
  String motivationQuote;
  String priority;

  Mission({
    required this.id,
    required this.title,
    this.category = 'Career',
    required this.targetDate,
    this.motivationQuote = '',
    this.priority = 'High',
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'category': category,
    'targetDate': targetDate, 'motivationQuote': motivationQuote,
    'priority': priority,
  };

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
    id: json['id'], title: json['title'], category: json['category'] ?? 'Career',
    targetDate: json['targetDate'], motivationQuote: json['motivationQuote'] ?? '',
    priority: json['priority'] ?? 'High',
  );
}

// ─── Missions Screen ───────────────────────────────────────────────────────
class MissionsScreen extends ConsumerStatefulWidget {
  const MissionsScreen({super.key});

  @override
  ConsumerState<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends ConsumerState<MissionsScreen> {
  List<Mission> _missions = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadMissions();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('habitflow-missions');
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      setState(() => _missions = decoded.map((m) => Mission.fromJson(m)).toList());
    }
  }

  Future<void> _saveMissions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('habitflow-missions', jsonEncode(_missions.map((m) => m.toJson()).toList()));
  }

  Map<String, int> _timeLeft(String dateStr) {
    try {
      final target = DateTime.parse(dateStr);
      final diff = target.difference(DateTime.now());
      if (diff.isNegative) return {'d': 0, 'h': 0, 'm': 0, 's': 0};
      return {
        'd': diff.inDays,
        'h': diff.inHours % 24,
        'm': diff.inMinutes % 60,
        's': diff.inSeconds % 60,
      };
    } catch (_) {
      return {'d': 0, 'h': 0, 'm': 0, 's': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppTheme.surface, borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MISSION CONTROL', style: GoogleFonts.outfit(
                          fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2.5,
                        )),
                        Text('Countdown Hub', style: GoogleFonts.outfit(
                          fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white,
                        )),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showCreateModal(context),
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFFE85D04)]),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            // ─── Hero Text ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Text('Your Future Is Already\nCounting Down.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.white,
                      height: 1.2, letterSpacing: -1,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text('Every habit you complete brings your mission closer.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 13.sp, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 500.ms),

            SizedBox(height: 16.h),

            // ─── Stats Row ──────────────────────────────────────────
            if (_missions.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    _buildStatCard(Icons.flag_rounded, '${_missions.length}', 'Active', AppTheme.primary),
                    SizedBox(width: 8.w),
                    _buildStatCard(Icons.bolt_rounded, '84%', 'Momentum', Colors.blue),
                    SizedBox(width: 8.w),
                    _buildStatCard(Icons.psychology_rounded, 'Optimal', 'Readiness', Colors.green),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            SizedBox(height: 16.h),

            // ─── Mission Cards ──────────────────────────────────────
            Expanded(
              child: _missions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.rocket_launch_rounded, size: 48.sp, color: Colors.white10),
                          SizedBox(height: 12.h),
                          Text('No Missions Detected.', style: GoogleFonts.outfit(
                            fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white,
                          )),
                          SizedBox(height: 4.h),
                          Text('Create your first mission.', style: GoogleFonts.inter(
                            fontSize: 13.sp, color: AppTheme.textMuted,
                          )),
                          SizedBox(height: 16.h),
                          GestureDetector(
                            onTap: () => _showCreateModal(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFFE85D04)]),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_rounded, color: Colors.white, size: 18.sp),
                                  SizedBox(width: 8.w),
                                  Text('Initiate Mission', style: GoogleFonts.inter(
                                    color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w700,
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: _missions.length,
                      itemBuilder: (_, i) => _buildMissionCard(_missions[i], i),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppTheme.surface, borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 18.sp, color: color),
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.outfit(fontSize: 8.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1)),
                  Text(value, style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard(Mission mission, int index) {
    final tl = _timeLeft(mission.targetDate);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top gradient
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primary.withOpacity(0.5), Colors.transparent]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
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
                        color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(mission.category, style: GoogleFonts.outfit(
                        fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 1.5,
                      )),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _missions.removeWhere((m) => m.id == mission.id));
                        _saveMissions();
                      },
                      child: Icon(Icons.close_rounded, size: 16.sp, color: Colors.white10),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(mission.title, style: GoogleFonts.outfit(
                  fontSize: 20.sp, fontWeight: FontWeight.w800, color: Colors.white,
                )),
                if (mission.motivationQuote.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text('"${mission.motivationQuote}"', style: GoogleFonts.inter(
                    fontSize: 12.sp, color: AppTheme.textMuted, fontStyle: FontStyle.italic,
                  ), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],

                SizedBox(height: 16.h),

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

                SizedBox(height: 16.h),

                // Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('MISSION MOMENTUM', style: GoogleFonts.outfit(
                      fontSize: 8.sp, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 1.5,
                    )),
                    Text('65%', style: GoogleFonts.outfit(
                      fontSize: 12.sp, fontWeight: FontWeight.w800, color: AppTheme.primary,
                    )),
                  ],
                ),
                SizedBox(height: 6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: 0.65,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: AlwaysStoppedAnimation(AppTheme.primary),
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
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(value.padLeft(2, '0'), style: GoogleFonts.outfit(
              fontSize: 20.sp, fontWeight: FontWeight.w900, color: Colors.white,
            )),
            Text(label, style: GoogleFonts.outfit(
              fontSize: 7.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1,
            )),
          ],
        ),
      ),
    );
  }

  void _showCreateModal(BuildContext context) {
    final titleC = TextEditingController();
    final quoteC = TextEditingController();
    String category = 'Career';
    String targetDate = '';
    final categories = ['Wealth', 'Fitness', 'Study', 'Career', 'Discipline', 'Health', 'Custom'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40.w, height: 4.h,
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2.r)))),
              SizedBox(height: 20.h),
              Text('Initiate Mission', style: GoogleFonts.outfit(
                fontSize: 24.sp, fontWeight: FontWeight.w800, color: Colors.white,
              )),
              SizedBox(height: 20.h),

              Text('MISSION TITLE', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2)),
              SizedBox(height: 6.h),
              TextField(
                controller: titleC,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
                decoration: _inputDeco('e.g., Build Dream Physique'),
              ),
              SizedBox(height: 16.h),

              Text('TARGET DATE', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2)),
              SizedBox(height: 6.h),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setModalState(() => targetDate = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                    targetDate.isEmpty ? 'Select target date...' : targetDate,
                    style: GoogleFonts.inter(fontSize: 13.sp, color: targetDate.isEmpty ? Colors.white12 : Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              Text('CATEGORY', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2)),
              SizedBox(height: 6.h),
              Wrap(
                spacing: 6.w, runSpacing: 6.h,
                children: categories.map((c) {
                  final isActive = category == c;
                  return GestureDetector(
                    onTap: () => setModalState(() => category = c),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.primary : Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(c, style: GoogleFonts.outfit(
                        fontSize: 10.sp, fontWeight: FontWeight.w700,
                        color: isActive ? Colors.white : Colors.white38,
                      )),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),

              Text('MOTIVATIONAL MANTRA', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2)),
              SizedBox(height: 6.h),
              TextField(
                controller: quoteC,
                maxLines: 3,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp),
                decoration: _inputDeco('A quote that moves you...'),
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        alignment: Alignment.center,
                        child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14.sp)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        if (titleC.text.trim().isEmpty || targetDate.isEmpty) return;
                        setState(() {
                          _missions.add(Mission(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: titleC.text.trim(),
                            targetDate: targetDate,
                            category: category,
                            motivationQuote: quoteC.text.trim(),
                          ));
                        });
                        _saveMissions();
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFFE85D04)]),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flag_rounded, color: Colors.white, size: 18.sp),
                            SizedBox(width: 8.w),
                            Text('Launch Mission', style: GoogleFonts.inter(
                              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.sp,
                            )),
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
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(color: Colors.white12, fontSize: 13.sp),
    filled: true, fillColor: Colors.white.withOpacity(0.03),
    contentPadding: EdgeInsets.all(14.w),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.5))),
  );
}
