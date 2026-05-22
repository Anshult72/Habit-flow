import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

import '../../services/analytics_service.dart';
import 'stopwatch_service.dart';

// ─── Focus Screen (Visual Rhythm & Flagship Mobile Architecture) ───────────
class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  String _mode = 'pomodoro'; // pomodoro, timer, stopwatch

  void _onSessionComplete(String type, int durationSeconds) {
    final xp = (durationSeconds / 60).round();
    ref.read(analyticsServiceProvider).logFocusSession(type, durationSeconds, xp);
    ref.invalidate(focusStatsProvider);
    
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.bolt_rounded, color: const Color(0xFFE25B20), size: 16.sp),
            SizedBox(width: 8.w),
            Text(
              'Session Secured! +$xp XP Added', 
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.sp),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F0F11),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(12.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
          side: BorderSide(color: const Color(0xFFE25B20).withValues(alpha: 0.2)),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(focusStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF08080A), // Immersive premium obsidian black
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 1. High-Tech Premium Cinematic Hero Header
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 40.h, bottom: 18.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Enter Deep Focus.', 
                      style: GoogleFonts.outfit(
                        fontSize: 38.sp, 
                        fontWeight: FontWeight.w900, 
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Time is your greatest weapon.\nUse it intentionally.',
                      style: GoogleFonts.inter(
                        fontSize: 13.5.sp,
                        color: Colors.white.withValues(alpha: 0.5),
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms),

              // 2. Mode Capsule Switcher (Tactile floating bar)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F11), 
                  borderRadius: BorderRadius.circular(12.r), 
                  border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
                ),
                child: Row(
                  children: [
                    _modeBtn('pomodoro', 'Pomodoro', Icons.timer_outlined),
                    _modeBtn('timer', 'Timer', Icons.bolt_rounded),
                    _modeBtn('stopwatch', 'Stopwatch', Icons.history_rounded),
                  ],
                ),
              ).animate().fadeIn(delay: 50.ms, duration: 250.ms),

              SizedBox(height: 10.h),

              // 3. Immersive Focus Hero Card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: _mode == 'pomodoro'
                      ? _PomodoroView(key: const ValueKey('pomo'), onComplete: (d) => _onSessionComplete('pomodoro', d))
                      : _mode == 'timer'
                          ? _TimerView(key: const ValueKey('timer'), onComplete: (d) => _onSessionComplete('timer', d))
                          : _StopwatchView(key: const ValueKey('sw'), onComplete: (d) => _onSessionComplete('stopwatch', d)),
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

              SizedBox(height: 20.h),

              // 4. Asymmetric Stats Grid (Dynamic Visual Hierarchy)
              Builder(
                builder: (context) {
                  final history = ref.watch(focusHistoryProvider);
                  final today = DateTime.now();
                  final todaySessions = history.where((h) => h.completedAt.day == today.day && h.completedAt.month == today.month && h.completedAt.year == today.year).toList();
                  final todayMins = todaySessions.fold(0, (sum, h) => sum + h.durationMs) ~/ 60000;
                  final todayCount = todaySessions.length;
                  final totalXp = history.fold(0, (sum, h) => sum + (h.durationMs ~/ 60000));
                  
                  // Category Breakdown Data
                  final Map<String, int> categoryMins = {};
                  for (final h in history) {
                    final cat = h.category ?? 'Other';
                    categoryMins[cat] = (categoryMins[cat] ?? 0) + (h.durationMs ~/ 60000);
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Asymmetric stats block
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: _buildAsymmetricStats(todayMins, todayCount, totalXp, statsAsync),
                      ),
                      
                      // Upgraded Category breakdown visualizer
                      if (categoryMins.isNotEmpty) ...[
                        SizedBox(height: 20.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Text(
                            'BREAKDOWN BY CATEGORY', 
                            style: GoogleFonts.outfit(
                              fontSize: 9.sp, 
                              fontWeight: FontWeight.w900, 
                              color: Colors.white30, 
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: _buildMobileCategoryBars(categoryMins),
                        ),
                      ],
                    ],
                  );
                }
              ).animate().fadeIn(delay: 150.ms, duration: 350.ms),

              // Generous bottom spacing to clear floating bottom navigation
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeBtn(String id, String label, IconData icon) {
    final active = _mode == id;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _mode = id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 6.5.h),
          decoration: BoxDecoration(
            gradient: active 
                ? const LinearGradient(
                    colors: [Color(0xFFE25B20), Color(0xFFFF7E40)],
                  )
                : null,
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13.sp, color: active ? Colors.white : Colors.white24),
              SizedBox(width: 5.w),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11.sp, 
                  fontWeight: FontWeight.w900, 
                  color: active ? Colors.white : Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAsymmetricStats(int todayMins, int todayCount, int totalXp, AsyncValue<Map<String, dynamic>> statsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FOCUS METRICS',
          style: GoogleFonts.outfit(
            fontSize: 9.sp,
            fontWeight: FontWeight.w900,
            color: Colors.white30,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 12.h),
        
        // Asymmetric Row Layout (Featured featured card left + stacked details card right)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Featured Primary Card (Focus Today)
            Expanded(
              flex: 5,
              child: Container(
                height: 146.h,
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF131316), Color(0xFF0F0F11)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE25B20).withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE25B20).withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(color: const Color(0xFFE25B20).withValues(alpha: 0.08), shape: BoxShape.circle),
                      child: Icon(Icons.access_time_rounded, size: 16.sp, color: const Color(0xFFE25B20)),
                    ),
                    const Spacer(),
                    Text(
                      '${todayMins}m', 
                      style: GoogleFonts.outfit(
                        fontSize: 32.sp, 
                        fontWeight: FontWeight.w900, 
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'FOCUS TODAY', 
                      style: GoogleFonts.outfit(
                        fontSize: 9.sp, 
                        fontWeight: FontWeight.w900, 
                        color: Colors.white38,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Target goal visualizer bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2.r),
                      child: Stack(
                        children: [
                          Container(height: 4.h, color: Colors.white.withValues(alpha: 0.03)),
                          Container(
                            height: 4.h,
                            width: 42.w, // Dynamic visual ratio
                            color: const Color(0xFFE25B20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            
            // Right Stack Column
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Row(
                    children: [
                      // Streak Metric
                      Expanded(
                        child: statsAsync.when(
                          data: (stats) => _buildMiniStatCard(
                            Icons.local_fire_department_rounded, 
                            '${stats['streak'] ?? 0}d', 
                            'STREAK', 
                            const Color(0xFFFFD700),
                          ),
                          loading: () => _buildMiniStatCard(
                            Icons.local_fire_department_rounded, 
                            '...', 
                            'STREAK', 
                            const Color(0xFFFFD700),
                          ),
                          error: (_, __) => _buildMiniStatCard(
                            Icons.local_fire_department_rounded, 
                            '0d', 
                            'STREAK', 
                            const Color(0xFFFFD700),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      // Sessions Completed Metric
                      Expanded(
                        child: _buildMiniStatCard(
                          Icons.track_changes_rounded, 
                          '$todayCount', 
                          'SESSIONS', 
                          const Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  
                  // XP Telemetry Full Width Card
                  Container(
                    height: 68.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F11),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.08), shape: BoxShape.circle),
                          child: Icon(Icons.bolt_rounded, size: 14.sp, color: const Color(0xFF10B981)),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$totalXp XP', 
                              style: GoogleFonts.outfit(
                                fontSize: 16.sp, 
                                fontWeight: FontWeight.w900, 
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'TOTAL SECURED TELEMETRY', 
                              style: GoogleFonts.outfit(
                                fontSize: 8.sp, 
                                fontWeight: FontWeight.w900, 
                                color: Colors.white38,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      height: 66.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F11),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 12.sp, color: color),
              SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  label, 
                  style: GoogleFonts.outfit(
                    fontSize: 8.sp, 
                    fontWeight: FontWeight.w900, 
                    color: Colors.white38,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value, 
            style: GoogleFonts.outfit(
              fontSize: 16.sp, 
              fontWeight: FontWeight.w900, 
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCategoryBars(Map<String, int> categories) {
    final total = categories.values.fold(0, (sum, v) => sum + v);
    if (total == 0) return const SizedBox.shrink();

    final colors = {
      'Work': const Color(0xFFE25B20),
      'Study': const Color(0xFF3B82F6),
      'Fitness': const Color(0xFF10B981),
      'Reading': const Color(0xFFF59E0B),
      'Meditation': const Color(0xFF8B5CF6),
      'Other': Colors.white30,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F11),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        children: categories.entries.where((e) => e.value > 0).map((e) {
          final percentage = e.value / total;
          final Color themeColor = colors[e.key] ?? const Color(0xFFE25B20);

          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key, 
                      style: GoogleFonts.inter(
                        fontSize: 11.sp, 
                        fontWeight: FontWeight.w600, 
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${e.value}m (${(percentage * 100).round()}%)', 
                      style: GoogleFonts.outfit(
                        fontSize: 11.sp, 
                        fontWeight: FontWeight.w900, 
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3.r),
                  child: Stack(
                    children: [
                      Container(height: 4.h, color: Colors.white.withValues(alpha: 0.02)),
                      AnimatedContainer(
                        duration: 400.ms,
                        width: (MediaQuery.of(context).size.width - 68.w) * percentage,
                        height: 4.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [themeColor.withValues(alpha: 0.5), themeColor],
                          ),
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
    );
  }
}

// ─── Pomodoro View Redesign (Immersive Chronometer Style) ──────────────────
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
    HapticFeedback.mediumImpact();
    if (_active) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_timeLeft > 0) { 
          setState(() => _timeLeft--); 
        } else { 
          _timer?.cancel(); 
          if (!_isBreak) widget.onComplete(25 * 60);
          setState(() { 
            _active = false; 
            _isBreak = !_isBreak; 
            _timeLeft = _isBreak ? 5 * 60 : 25 * 60; 
          }); 
        }
      });
    }
    setState(() => _active = !_active);
  }

  void _reset() { 
    HapticFeedback.lightImpact();
    _timer?.cancel(); 
    setState(() { 
      _active = false; 
      _timeLeft = _isBreak ? 5 * 60 : 25 * 60; 
    }); 
  }

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
      padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F11),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        children: [
          // Immersive Circular Chronometer Progress
          SizedBox(
            width: 220.w,
            height: 220.w,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _CirclePainter(
                    _progress,
                    _isBreak ? const Color(0xFF10B981) : const Color(0xFFE25B20),
                    _glowController.value,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isBreak ? 'REGEN BREAK' : 'FOCUS ACTIVE',
                          style: GoogleFonts.outfit(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white30,
                            letterSpacing: 2.0,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
                          style: GoogleFonts.outfit(
                            fontSize: 48.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        // Status Subtag
                        Text(
                          _active ? 'OPERATIONAL' : 'PAUSED',
                          style: GoogleFonts.outfit(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w900,
                            color: _active ? const Color(0xFFE25B20) : Colors.white24,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: 22.h),
          
          // Connected Control Panel Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ctrlBtn(Icons.refresh_rounded, _reset),
              SizedBox(width: 32.w),
              GestureDetector(
                onTap: _toggle, 
                child: Container(
                  width: 64.w, 
                  height: 64.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, 
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE25B20), Color(0xFFFF7E40)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE25B20).withValues(alpha: 0.15), 
                        blurRadius: 10, 
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(_active ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 28.sp, color: Colors.white),
                ),
              ),
              SizedBox(width: 32.w),
              _ctrlBtn(Icons.open_in_full_rounded, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ctrlBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap, 
        child: Container(
          padding: EdgeInsets.all(12.w), 
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.015),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
          ),
          child: Icon(icon, size: 18.sp, color: Colors.white38),
        ),
      );
}

// ─── Timer View Redesign (Drum Dial Style Selector) ─────────────────────────
class _TimerView extends StatefulWidget {
  final Function(int) onComplete;
  const _TimerView({super.key, required this.onComplete});
  @override
  State<_TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<_TimerView> {
  int _selectedMinutes = 10;
  int _selectedSeconds = 0;
  int _timeLeft = 10 * 60;
  bool _active = false;
  Timer? _timer;

  @override
  void dispose() { 
    _timer?.cancel(); 
    super.dispose(); 
  }

  void _toggle() {
    HapticFeedback.mediumImpact();
    if (_active) { 
      _timer?.cancel(); 
    } else {
      if (_timeLeft == 0) {
        _timeLeft = _selectedMinutes * 60 + _selectedSeconds;
      }
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_timeLeft > 0) { 
          setState(() => _timeLeft--); 
        } else { 
          _timer?.cancel(); 
          widget.onComplete(_selectedMinutes * 60 + _selectedSeconds);
          setState(() => _active = false); 
        }
      });
    }
    setState(() => _active = !_active);
  }

  void _reset() { 
    HapticFeedback.lightImpact();
    _timer?.cancel(); 
    setState(() { 
      _active = false; 
      _timeLeft = _selectedMinutes * 60 + _selectedSeconds; 
    }); 
  }

  void _adjustTime(bool isMinutes, bool isIncrement) {
    if (_active) return;
    HapticFeedback.selectionClick();
    setState(() {
      if (isMinutes) {
        if (isIncrement) {
          if (_selectedMinutes < 99) _selectedMinutes++;
        } else {
          if (_selectedMinutes > 1) _selectedMinutes--;
        }
      } else {
        if (isIncrement) {
          if (_selectedSeconds < 59) _selectedSeconds += 5;
        } else {
          if (_selectedSeconds > 0) _selectedSeconds -= 5;
        }
      }
      _timeLeft = _selectedMinutes * 60 + _selectedSeconds;
    });
  }

  void _applyPreset(int mins) {
    if (_active) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedMinutes = mins;
      _selectedSeconds = 0;
      _timeLeft = mins * 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = _timeLeft ~/ 60; 
    final s = _timeLeft % 60;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 26.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F11),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        children: [
          if (!_active) ...[
            // Drum capsule dial adjusters
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAdjusterColumn(true, _selectedMinutes),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Text(':', style: GoogleFonts.outfit(fontSize: 24.sp, fontWeight: FontWeight.w900, color: Colors.white24)),
                ),
                _buildAdjusterColumn(false, _selectedSeconds),
              ],
            ),
            
            SizedBox(height: 18.h),
            
            // Rapid presets dock (horizontal pills)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPresetChip(5, '5 MIN'),
                SizedBox(width: 6.w),
                _buildPresetChip(15, '15 MIN'),
                SizedBox(width: 6.w),
                _buildPresetChip(25, '25 MIN'),
                SizedBox(width: 6.w),
                _buildPresetChip(45, '45 MIN'),
              ],
            ),
          ] else ...[
            // Active countdown large digits
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              alignment: Alignment.center,
              child: Text(
                '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
                style: GoogleFonts.outfit(
                  fontSize: 52.sp, 
                  fontWeight: FontWeight.w900, 
                  color: Colors.white, 
                  letterSpacing: -1.0,
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    end: const Offset(1.02, 1.02), 
                    duration: 1000.ms, 
                    curve: Curves.easeInOut,
                  ),
            ),
          ],
          
          SizedBox(height: 18.h),
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _reset, 
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.015), 
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Text(
                    'RESET', 
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp, 
                      fontWeight: FontWeight.w900, 
                      color: Colors.white38, 
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20.w),
              GestureDetector(
                onTap: _toggle, 
                child: Container(
                  width: 60.w, 
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, 
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE25B20), Color(0xFFFF7E40)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE25B20).withValues(alpha: 0.15), 
                        blurRadius: 8, 
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(_active ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 26.sp, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdjusterColumn(bool isMinutes, int val) {
    return Column(
      children: [
        Text(
          isMinutes ? 'MINUTES' : 'SECONDS', 
          style: GoogleFonts.outfit(
            fontSize: 9.sp, 
            fontWeight: FontWeight.w900, 
            color: Colors.white24, 
            letterSpacing: 1.0,
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            GestureDetector(
              onTap: () => _adjustTime(isMinutes, false),
              child: Icon(Icons.remove_circle_outline_rounded, color: Colors.white38, size: 22.sp),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 58.w,
              padding: EdgeInsets.symmetric(vertical: 7.h),
              decoration: BoxDecoration(
                color: const Color(0xFF060608),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
              ),
              alignment: Alignment.center,
              child: Text(
                val.toString().padLeft(2, '0'), 
                style: GoogleFonts.outfit(
                  fontSize: 20.sp, 
                  fontWeight: FontWeight.w900, 
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => _adjustTime(isMinutes, true),
              child: Icon(Icons.add_circle_outline_rounded, color: Colors.white38, size: 22.sp),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetChip(int mins, String label) {
    final active = _selectedMinutes == mins && _selectedSeconds == 0;
    return GestureDetector(
      onTap: () => _applyPreset(mins),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE25B20).withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.01),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: active ? const Color(0xFFE25B20).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.04),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: active ? const Color(0xFFE25B20) : Colors.white38, 
            fontSize: 9.5.sp, 
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

// ─── Stopwatch View (Standout Timeline Command Dock Redesign) ─────────────
class _StopwatchView extends ConsumerStatefulWidget {
  final Function(int) onComplete;
  const _StopwatchView({super.key, required this.onComplete});
  @override
  ConsumerState<_StopwatchView> createState() => _StopwatchViewState();
}

class _StopwatchViewState extends ConsumerState<_StopwatchView> with SingleTickerProviderStateMixin {
  Timer? _uiRefreshTimer;
  final TextEditingController _titleController = TextEditingController();
  String _selectedCategory = 'Work';
  final List<String> _categories = ['Work', 'Study', 'Fitness', 'Reading', 'Meditation', 'Other'];
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _uiRefreshTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      final sessions = ref.read(stopwatchProvider);
      if (sessions.any((s) => s.isRunning)) {
        setState(() {}); 
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _uiRefreshTimer?.cancel();
    _titleController.dispose();
    super.dispose();
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0F0F11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r), 
            side: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DEPLOY FOCUS TRACKER', 
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp, 
                    fontWeight: FontWeight.w900, 
                    color: const Color(0xFFE25B20),
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: _titleController,
                  autofocus: true,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp),
                  decoration: InputDecoration(
                    hintText: 'Enter task descriptor...',
                    hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 13.sp),
                    filled: true,
                    fillColor: const Color(0xFF060608),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF060608),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: StatefulBuilder(
                    builder: (context, setDialogState) => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        dropdownColor: const Color(0xFF0F0F11),
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white38, size: 18.sp),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp),
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
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white38, fontSize: 12.sp)),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE25B20), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      onPressed: () {
                        final title = _titleController.text.trim().isEmpty ? 'Untitled Focus' : _titleController.text.trim();
                        ref.read(stopwatchProvider.notifier).createSession(title, category: _selectedCategory);
                        _titleController.clear();
                        Navigator.pop(context);
                      },
                      child: Text('Deploy', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp)),
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
        // Deploy Trigger Button (high-end tactical button style)
        GestureDetector(
          onTap: _showCreateDialog,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE25B20).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFE25B20).withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: const Color(0xFFE25B20), size: 18.sp),
                SizedBox(width: 6.w),
                Text(
                  'DEPLOY NEW TRACKER', 
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFE25B20), 
                    fontWeight: FontWeight.w900, 
                    fontSize: 10.5.sp,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 200.ms),
        
        SizedBox(height: 18.h),

        // Stopwatch Command Dock System (Timeline rhythm integration)
        if (sessions.isEmpty)
          Container(
            padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F11),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
            ),
            child: Column(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.04), width: 0.8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.blur_circular_rounded, color: Colors.white24, size: 24.sp),
                ),
                SizedBox(height: 10.h),
                Text(
                  'TRACKER DOCK VACANT', 
                  style: GoogleFonts.outfit(
                    color: Colors.white38, 
                    fontSize: 11.sp, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Initialize focus nodes to record concurrent telemetry.', 
                  style: GoogleFonts.inter(
                    color: Colors.white24, 
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          // Beautiful Timeline stack of active concurrent stopwatch nodes
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sessions.length,
            itemBuilder: (context, idx) {
              final s = sessions[idx];
              final ms = s.currentElapsedMs;
              final isRunning = s.isRunning;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Timeline track lane
                    SizedBox(
                      width: 32.w,
                      child: Column(
                        children: [
                          // Connected timeline node
                          AnimatedContainer(
                            duration: 200.ms,
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isRunning ? const Color(0xFFE25B20) : Colors.white24,
                              boxShadow: isRunning ? [
                                BoxShadow(color: const Color(0xFFE25B20).withValues(alpha: 0.4), blurRadius: 6)
                              ] : null,
                            ),
                          ),
                          // Vertical running line
                          if (idx < sessions.length - 1)
                            Expanded(
                              child: Container(
                                width: 1.5.w,
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10.w),
                    
                    // Main Session Command node card
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0F11),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isRunning 
                                ? const Color(0xFFE25B20).withValues(alpha: 0.2) 
                                : Colors.white.withValues(alpha: 0.03),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: isRunning 
                                        ? const Color(0xFFE25B20).withValues(alpha: 0.08) 
                                        : Colors.white.withValues(alpha: 0.02), 
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    s.category?.toUpperCase() ?? 'OTHER', 
                                    style: GoogleFonts.outfit(
                                      fontSize: 8.5.sp, 
                                      fontWeight: FontWeight.w900, 
                                      color: isRunning ? const Color(0xFFE25B20) : Colors.white38,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    s.title, 
                                    style: GoogleFonts.outfit(
                                      fontSize: 14.sp, 
                                      fontWeight: FontWeight.w800, 
                                      color: Colors.white70,
                                    ), 
                                    maxLines: 1, 
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatMs(ms), 
                                  style: GoogleFonts.outfit(
                                    fontSize: 26.sp, 
                                    fontWeight: FontWeight.w900, 
                                    color: Colors.white, 
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                
                                // Quick action triggers
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        if (isRunning) {
                                          ref.read(stopwatchProvider.notifier).pauseSession(s.id);
                                        } else {
                                          ref.read(stopwatchProvider.notifier).startSession(s.id);
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: isRunning 
                                              ? const Color(0xFFE25B20).withValues(alpha: 0.08) 
                                              : Colors.white.withValues(alpha: 0.015),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isRunning 
                                                ? const Color(0xFFE25B20).withValues(alpha: 0.2) 
                                                : Colors.white.withValues(alpha: 0.04),
                                          ),
                                        ),
                                        child: Icon(
                                          isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, 
                                          color: isRunning ? const Color(0xFFE25B20) : Colors.white70, 
                                          size: 16.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.mediumImpact();
                                        if (s.isRunning) ref.read(stopwatchProvider.notifier).pauseSession(s.id);
                                        
                                        final finalMs = ref.read(stopwatchProvider).firstWhere((session) => session.id == s.id).currentElapsedMs;
                                        
                                        if (finalMs > 0) {
                                          widget.onComplete(finalMs ~/ 1000);
                                          ref.read(focusHistoryProvider.notifier).addCompletedSession(s.copyWith(accumulatedMs: finalMs));
                                        }
                                        ref.read(stopwatchProvider.notifier).deleteSession(s.id);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.015),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                                        ),
                                        child: Icon(Icons.stop_rounded, color: Colors.white38, size: 16.sp),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            // Pulse telemetry lines when running
                            if (isRunning) ...[
                              SizedBox(height: 8.h),
                              Row(
                                children: List.generate(12, (i) {
                                  final double baseHeight = 4.h;
                                  return AnimatedBuilder(
                                    animation: _waveController,
                                    builder: (context, child) {
                                      final double val = sin((_waveController.value * 2 * pi) + i) * 3.h;
                                      return Container(
                                        width: 1.5.w,
                                        height: baseHeight + val.abs(),
                                        margin: EdgeInsets.only(right: 3.w),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE25B20).withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(1.r),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
        if (history.isNotEmpty) ...[
          SizedBox(height: 24.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'RECENT HISTORY', 
              style: GoogleFonts.outfit(
                fontSize: 10.sp, 
                fontWeight: FontWeight.w900, 
                color: Colors.white30, 
                letterSpacing: 1.6,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          ...history.take(3).map((h) => Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F11),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
            ),
            child: Row(
              children: [
                Icon(Icons.history_rounded, color: Colors.white24, size: 16.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(3.r)),
                            child: Text(
                              h.category?.toUpperCase() ?? 'OTHER', 
                              style: GoogleFonts.outfit(fontSize: 8.sp, fontWeight: FontWeight.w900, color: Colors.white38),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              h.title, 
                              style: GoogleFonts.outfit(fontSize: 13.sp, fontWeight: FontWeight.w800, color: Colors.white70), 
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '${h.completedAt.day}/${h.completedAt.month}/${h.completedAt.year} • ${_formatMs(h.durationMs)}', 
                        style: GoogleFonts.inter(fontSize: 10.5.sp, color: Colors.white38),
                      ),
                    ],
                  ),
                ),
                Text(
                  '+${(h.durationMs ~/ 60000)} XP', 
                  style: GoogleFonts.outfit(
                    fontSize: 12.5.sp, 
                    fontWeight: FontWeight.w900, 
                    color: const Color(0xFFE25B20),
                  ),
                ),
              ],
            ),
          )),
        ]
      ],
    );
  }
}

// ─── Circle Painter (Immersive Visual Chronometer Details) ─────────────────
class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double glowValue;

  _CirclePainter(this.progress, this.color, this.glowValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw futuristic chronometer tick indicators on the circumference
    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    for (int i = 0; i < 60; i++) {
      final angle = (i * 6) * pi / 180;
      final outerPoint = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      final tickLength = i % 5 == 0 ? 6.w : 3.w;
      final innerPoint = Offset(
        center.dx + (radius - tickLength) * cos(angle),
        center.dy + (radius - tickLength) * sin(angle),
      );
      canvas.drawLine(innerPoint, outerPoint, tickPaint);
    }

    // Background track (subtle futuristic ring)
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.015)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);

    // Neon Breathing Glow Arc
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.12 + (0.08 * glowValue))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5 + (2.5 * glowValue)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 + (3 * glowValue));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius), 
      -pi / 2,
      2 * pi * progress, 
      false, 
      glowPaint,
    );

    // Sharp Foreground arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius), 
      -pi / 2,
      2 * pi * progress, 
      false, 
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.glowValue != glowValue;
}
