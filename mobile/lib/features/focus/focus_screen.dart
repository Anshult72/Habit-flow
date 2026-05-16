import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../../core/theme/app_theme.dart';

import '../../services/analytics_service.dart';
import 'stopwatch_service.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});
  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  String _mode = 'pomodoro'; // pomodoro, timer, stopwatch

  void _onSessionComplete(String type, int durationSeconds) {
    // Basic XP formula: 1 XP per minute
    final xp = (durationSeconds / 60).round();
    ref.read(analyticsServiceProvider).logFocusSession(type, durationSeconds, xp);
    ref.invalidate(focusStatsProvider);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Focus Session Logged! +$xp XP', style: GoogleFonts.outfit()),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(focusStatsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(children: [
              // Header
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
                  child: Column(children: [
                    Text('Enter Deep\nFocus.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                            fontSize: 48.sp, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, letterSpacing: -2)),
                    SizedBox(height: 16.h),
                    Text('Time is your greatest weapon.\nUse it intentionally.', 
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 16.sp, color: AppTheme.textMuted, height: 1.4)),
                  ])).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),

              SizedBox(height: 16.h),

              // Mode Switcher
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03), 
                    borderRadius: BorderRadius.circular(16.r), 
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
                child: Row(children: [
                  _modeBtn('pomodoro', 'Pomodoro', null),
                  _modeBtn('timer', 'Timer', Icons.bolt_rounded),
                  _modeBtn('stopwatch', 'Stopwatch', Icons.history_rounded),
                ]),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              SizedBox(height: 24.h),

              // Active Timer Card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _mode == 'pomodoro'
                      ? _PomodoroView(key: const ValueKey('pomo'), onComplete: (d) => _onSessionComplete('pomodoro', d))
                      : _mode == 'timer'
                          ? _TimerView(key: const ValueKey('timer'), onComplete: (d) => _onSessionComplete('timer', d))
                          : _StopwatchView(key: const ValueKey('sw'), onComplete: (d) => _onSessionComplete('stopwatch', d)),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),

              SizedBox(height: 24.h),

              // Stats Grid
              Builder(
                builder: (context) {
                  final history = ref.watch(focusHistoryProvider);
                  final today = DateTime.now();
                  final todaySessions = history.where((h) => h.completedAt.day == today.day && h.completedAt.month == today.month && h.completedAt.year == today.year).toList();
                  final todayMins = todaySessions.fold(0, (sum, h) => sum + h.durationMs) ~/ 60000;
                  final todayCount = todaySessions.length;
                  final totalXp = history.fold(0, (sum, h) => sum + (h.durationMs ~/ 60000));
                  
                  // Category Breakdown
                  final Map<String, int> categoryMins = {};
                  for (final h in history) {
                    final cat = h.category ?? 'Other';
                    categoryMins[cat] = (categoryMins[cat] ?? 0) + (h.durationMs ~/ 60000);
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16.h,
                          crossAxisSpacing: 16.w,
                          childAspectRatio: 1.2,
                          children: [
                            _statCard(Icons.access_time_rounded, '${todayMins}m', 'FOCUS TODAY', const Color(0xFFF97316)),
                            _statCard(Icons.track_changes_rounded, '$todayCount', 'SESSIONS', const Color(0xFF3B82F6)),
                            statsAsync.when(
                              data: (stats) => _statCard(Icons.local_fire_department_rounded, '${stats['streak'] ?? 0} Days', 'CURRENT STREAK', const Color(0xFFFFD700)),
                              loading: () => _statCard(Icons.local_fire_department_rounded, '...', 'CURRENT STREAK', const Color(0xFFFFD700)),
                              error: (_, __) => _statCard(Icons.local_fire_department_rounded, '0 Days', 'CURRENT STREAK', const Color(0xFFFFD700)),
                            ),
                            _statCard(Icons.bolt_rounded, '$totalXp', 'TOTAL XP EARNED', const Color(0xFF10B981)),
                          ]
                        ),
                      ),
                      
                      if (categoryMins.isNotEmpty) ...[
                        SizedBox(height: 32.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Text('Category Breakdown', style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 1.5)),
                        ),
                        SizedBox(height: 16.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: categoryMins.entries.where((e) => e.value > 0).map((e) => Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(e.key, style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.white70)),
                                  SizedBox(width: 8.w),
                                  Text('${e.value}m', style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w800, color: Colors.white)),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                      ],
                    ],
                  );
                }
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              SizedBox(height: 120.h),
            ]),
          )),
    );
  }

  Widget _modeBtn(String id, String label, IconData? icon) {
    final active = _mode == id;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _mode = id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: active ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16.sp, color: active ? Colors.white : Colors.white54),
                SizedBox(width: 6.w),
              ],
              Text(label,
                  style: GoogleFonts.outfit(
                      fontSize: 14.sp, fontWeight: FontWeight.w700, color: active ? Colors.white : Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24.sp, color: color),
          const Spacer(),
          Text(value, style: GoogleFonts.outfit(fontSize: 28.sp, fontWeight: FontWeight.w800, color: Colors.white)),
          SizedBox(height: 4.h),
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 11.sp, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 1.5, height: 1.2)),
        ],
      ),
    );
  }
}

// ─── Pomodoro ──────────────────────────────────────────────────────────────
class _PomodoroView extends StatefulWidget {
  final Function(int) onComplete;
  const _PomodoroView({super.key, required this.onComplete});
  @override
  State<_PomodoroView> createState() => _PomodoroViewState();
}

class _PomodoroViewState extends State<_PomodoroView> with SingleTickerProviderStateMixin {
  int _timeLeft = 25 * 60;
  bool _active = false, _isBreak = false;
  Timer? _timer;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_active) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_timeLeft > 0) { setState(() => _timeLeft--); }
        else { 
          _timer?.cancel(); 
          if (!_isBreak) widget.onComplete(25 * 60);
          setState(() { _active = false; _isBreak = !_isBreak; _timeLeft = _isBreak ? 5 * 60 : 25 * 60; }); 
        }
      });
    }
    setState(() => _active = !_active);
  }

  void _reset() { _timer?.cancel(); setState(() { _active = false; _timeLeft = _isBreak ? 5 * 60 : 25 * 60; }); }

  double get _progress {
    final total = _isBreak ? 5 * 60 : 25 * 60;
    return (total - _timeLeft) / total;
  }

  @override
  Widget build(BuildContext context) {
    final m = _timeLeft ~/ 60;
    final s = _timeLeft % 60;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(40.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Circular Timer
        SizedBox(
          width: 280.w,
          height: 280.w,
          child: AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return CustomPaint(
                painter: _CirclePainter(
                  _progress,
                  _isBreak ? const Color(0xFF22C55E) : AppTheme.primary,
                  _glowController.value,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_isBreak ? 'REGENERATING' : 'OPERATIONAL FOCUS',
                          style: GoogleFonts.outfit(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textMuted,
                              letterSpacing: 4)),
                      SizedBox(height: 4.h),
                      Text(
                          '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
                          style: GoogleFonts.outfit(
                              fontSize: 76.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -2)),
                      SizedBox(height: 8.h),
                      Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                              4,
                              (i) => Container(
                                  width: 8.w,
                                  height: 8.w,
                                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.primary,
                                      boxShadow: [
                                        BoxShadow(
                                            color: AppTheme.primary
                                                .withValues(alpha: 0.5),
                                            blurRadius: 6)
                                      ])))),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 48.h),
        // Controls
        Stack(
          alignment: Alignment.center,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _ctrlBtn(Icons.refresh_rounded, _reset),
              SizedBox(width: 32.w),
              GestureDetector(onTap: _toggle, child: Container(width: 96.w, height: 96.w,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary,
                  boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))]),
                child: Icon(_active ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 48.sp, color: Colors.white))),
              SizedBox(width: 32.w),
              _ctrlBtn(Icons.settings_rounded, () {}),
            ]),
            // Decorative expand button below play button
            Positioned(
              bottom: 0,
              right: 60.w,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1C),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Icon(Icons.open_in_full_rounded, color: Colors.white38, size: 16.sp),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _ctrlBtn(IconData icon, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(
    padding: EdgeInsets.all(18.w), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(20.r), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
    child: Icon(icon, size: 28.sp, color: Colors.white54)));
}

// ─── Stopwatch ─────────────────────────────────────────────────────────────
class _StopwatchView extends ConsumerStatefulWidget {
  final Function(int) onComplete;
  const _StopwatchView({super.key, required this.onComplete});
  @override
  ConsumerState<_StopwatchView> createState() => _StopwatchViewState();
}

class _StopwatchViewState extends ConsumerState<_StopwatchView> {
  Timer? _uiRefreshTimer;
  final TextEditingController _titleController = TextEditingController();
  String _selectedCategory = 'Work';
  final List<String> _categories = ['Work', 'Study', 'Fitness', 'Reading', 'Meditation', 'Other'];

  @override
  void initState() {
    super.initState();
    // A 500ms tick for smooth UI updates when timers are running without milliseconds
    _uiRefreshTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      final sessions = ref.read(stopwatchProvider);
      if (sessions.any((s) => s.isRunning)) {
        setState(() {}); // refresh elapsed time in UI
      }
    });
  }

  @override
  void dispose() {
    _uiRefreshTimer?.cancel();
    _titleController.dispose();
    super.dispose();
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF111111),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r), side: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Session', style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                SizedBox(height: 16.h),
                TextField(
                  controller: _titleController,
                  autofocus: true,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Task or Focus Goal...',
                    hintStyle: GoogleFonts.inter(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: StatefulBuilder(
                    builder: (context, setDialogState) => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        dropdownColor: const Color(0xFF1A1A1C),
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54, size: 20.sp),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => _selectedCategory = v);
                            setState(() => _selectedCategory = v);
                          }
                        },
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54)),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                      onPressed: () {
                        final title = _titleController.text.trim().isEmpty ? 'Untitled Focus' : _titleController.text.trim();
                        ref.read(stopwatchProvider.notifier).createSession(title, category: _selectedCategory);
                        _titleController.clear();
                        Navigator.pop(context);
                      },
                      child: Text('Create', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatMs(int totalMs) {
    int totalSeconds = totalMs ~/ 1000;
    int h = totalSeconds ~/ 3600;
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(stopwatchProvider);
    final history = ref.watch(focusHistoryProvider);

    return Column(
      children: [
        // Create New Button
        GestureDetector(
          onTap: _showCreateDialog,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: AppTheme.primary, size: 24.sp),
                SizedBox(width: 8.w),
                Text('New Session', style: GoogleFonts.outfit(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 16.sp)),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms),
        
        SizedBox(height: 16.h),

        // Sessions List
        if (sessions.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 32.h),
            child: Text('No active sessions.\nStart one to track your focus.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 14.sp)),
          )
        else
          ...sessions.map((s) {
            final ms = s.currentElapsedMs;
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: s.isRunning ? AppTheme.primary.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05)),
                boxShadow: s.isRunning ? [
                  BoxShadow(color: AppTheme.primary.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 2)
                ] : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r)),
                              child: Text(s.category ?? 'Uncategorized', style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.white70)),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(child: Text(s.title, style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(_formatMs(ms), style: GoogleFonts.outfit(fontSize: 32.sp, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
                      ],
                    ),
                  ),
                  
                  // Controls
                  Row(
                    children: [
                      // Play/Pause
                      GestureDetector(
                        onTap: () {
                          if (s.isRunning) {
                            ref.read(stopwatchProvider.notifier).pauseSession(s.id);
                          } else {
                            ref.read(stopwatchProvider.notifier).startSession(s.id);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: s.isRunning ? AppTheme.primary.withValues(alpha: 0.2) : AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(s.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, 
                            color: s.isRunning ? AppTheme.primary : Colors.white, size: 24.sp),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Stop / Save
                      GestureDetector(
                        onTap: () {
                          if (s.isRunning) ref.read(stopwatchProvider.notifier).pauseSession(s.id);
                          
                          // Get final elapsed time before deleting
                          final finalMs = ref.read(stopwatchProvider).firstWhere((session) => session.id == s.id).currentElapsedMs;
                          
                          if (finalMs > 0) {
                            widget.onComplete(finalMs ~/ 1000);
                            ref.read(focusHistoryProvider.notifier).addCompletedSession(s.copyWith(accumulatedMs: finalMs));
                          }
                          ref.read(stopwatchProvider.notifier).deleteSession(s.id);
                        },
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.stop_rounded, color: Colors.white54, size: 24.sp),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05);
          }),
          
        if (history.isNotEmpty) ...[
          SizedBox(height: 32.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Recent History', style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 1.5)),
          ),
          SizedBox(height: 16.h),
          ...history.take(5).map((h) => Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Icon(Icons.history_rounded, color: Colors.white38, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(4.r)),
                            child: Text(h.category ?? 'Uncategorized', style: GoogleFonts.inter(fontSize: 9.sp, fontWeight: FontWeight.w600, color: Colors.white54)),
                          ),
                          SizedBox(width: 6.w),
                          Expanded(child: Text(h.title, style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text('${h.completedAt.day}/${h.completedAt.month}/${h.completedAt.year} • ${_formatMs(h.durationMs)}', style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.white38)),
                    ],
                  ),
                ),
                Text('+${(h.durationMs ~/ 60000)} XP', style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              ],
            ),
          )),
        ]
      ],
    );
  }
}

// ─── Timer ──────────────────────────────────────────────────────────────────
class _TimerView extends StatefulWidget {
  final Function(int) onComplete;
  const _TimerView({super.key, required this.onComplete});
  @override
  State<_TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<_TimerView> {
  final int _inputMin = 10;
  int _timeLeft = 10 * 60;
  bool _active = false;
  Timer? _timer;

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _toggle() {
    if (_active) { _timer?.cancel(); }
    else {
      if (_timeLeft == 0) _timeLeft = _inputMin * 60;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_timeLeft > 0) { setState(() => _timeLeft--); }
        else { 
          _timer?.cancel(); 
          widget.onComplete(_inputMin * 60);
          setState(() => _active = false); 
        }
      });
    }
    setState(() => _active = !_active);
  }

  void _reset() { _timer?.cancel(); setState(() { _active = false; _timeLeft = _inputMin * 60; }); }

  @override
  Widget build(BuildContext context) {
    final m = _timeLeft ~/ 60; final s = _timeLeft % 60;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(40.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Input Fields (Design from screenshot 3)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text('MINUTES', style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 2)),
                SizedBox(height: 8.h),
                _adjustBox(m.toString().padLeft(2, '0')),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Text(':', style: GoogleFonts.outfit(fontSize: 32.sp, fontWeight: FontWeight.w800, color: Colors.white54)),
            ),
            Column(
              children: [
                Text('SECONDS', style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 2)),
                SizedBox(height: 8.h),
                _adjustBox(s.toString().padLeft(2, '0')),
              ],
            ),
          ],
        ),
        SizedBox(height: 48.h),
        
        Text('${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
          style: GoogleFonts.outfit(fontSize: 84.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -4, height: 1.0)),
        SizedBox(height: 48.h),
        
        // Controls
        Stack(
          alignment: Alignment.center,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(onTap: _reset, child: Container(padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
                child: Text('RESET', style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white54, letterSpacing: 1)))),
              SizedBox(width: 24.w),
              GestureDetector(onTap: _toggle, child: Container(width: 104.w, height: 104.w,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary,
                  boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))]),
                child: Icon(_active ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 48.sp, color: Colors.white))),
            ]),
            // Decorative expand button
            Positioned(
              bottom: 0,
              right: 50.w,
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1C),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Icon(Icons.open_in_full_rounded, color: Colors.white38, size: 18.sp),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _adjustBox(String value) {
    return GestureDetector(
      onTap: () {
        // Implement adjust logic later if needed
      },
      child: Container(
        width: 80.w,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        alignment: Alignment.center,
        child: Text(value, style: GoogleFonts.outfit(fontSize: 24.sp, fontWeight: FontWeight.w800, color: Colors.white)),
      ),
    );
  }
}

// ─── Circle Painter ────────────────────────────────────────────────────────
class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double glowValue;

  _CirclePainter(this.progress, this.color, this.glowValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Background circle (glass-morphic track)
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6);

    // Dynamic Breathing Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.2 + (0.2 * glowValue))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10 + (6 * glowValue)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + (8 * glowValue));

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        2 * pi * progress, false, glowPaint);

    // Main Progress Arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        2 * pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _CirclePainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.glowValue != glowValue;
}
