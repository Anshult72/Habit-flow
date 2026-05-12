import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import 'dart:math';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});
  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  String _mode = 'pomodoro'; // pomodoro, timer, stopwatch

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(child: Column(children: [
        // Header
        Padding(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h), child: Column(children: [
          Text('Enter Deep Focus.', textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2, letterSpacing: -1)),
          SizedBox(height: 4.h),
          Text('Time is your greatest weapon.', style: GoogleFonts.inter(fontSize: 13.sp, color: AppTheme.textMuted)),
        ])).animate().fadeIn(duration: 400.ms),

        SizedBox(height: 12.h),

        // Mode Switcher
        Container(
          margin: EdgeInsets.symmetric(horizontal: 40.w),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppTheme.surfaceBorder)),
          child: Row(children: [
            _modeBtn('pomodoro', 'Pomodoro', Icons.access_time_rounded),
            _modeBtn('timer', 'Timer', Icons.bolt_rounded),
            _modeBtn('stopwatch', 'Stopwatch', Icons.history_rounded),
          ]),
        ),

        SizedBox(height: 24.h),

        // Active Timer
        Expanded(child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _mode == 'pomodoro'
              ? _PomodoroView(key: const ValueKey('pomo'))
              : _mode == 'timer'
                  ? _TimerView(key: const ValueKey('timer'))
                  : _StopwatchView(key: const ValueKey('sw')),
        )),

        // Stats Row
        Padding(padding: EdgeInsets.symmetric(horizontal: 20.w), child: Row(children: [
          _statCard(Icons.access_time_rounded, '124m', 'Focus Today', AppTheme.primary),
          SizedBox(width: 8.w),
          _statCard(Icons.flag_rounded, '5', 'Sessions', const Color(0xFF3B82F6)),
          SizedBox(width: 8.w),
          _statCard(Icons.local_fire_department_rounded, '4 Days', 'Streak', const Color(0xFFFFD700)),
        ])).animate().fadeIn(delay: 300.ms, duration: 400.ms),

        SizedBox(height: 100.h),
      ])),
    );
  }

  Widget _modeBtn(String id, String label, IconData icon) {
    final active = _mode == id;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _mode = id),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 14.sp, color: active ? Colors.white : Colors.white30),
          SizedBox(width: 4.w),
          Text(label, style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w700,
            color: active ? Colors.white : Colors.white30)),
        ])),
    ));
  }

  Widget _statCard(IconData icon, String value, String label, Color color) {
    return Expanded(child: Container(padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.surfaceBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16.sp, color: color),
        SizedBox(height: 6.h),
        Text(value, style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(label, style: GoogleFonts.outfit(fontSize: 8.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1)),
      ])));
  }
}

// ─── Pomodoro ──────────────────────────────────────────────────────────────
class _PomodoroView extends StatefulWidget {
  const _PomodoroView({super.key});
  @override
  State<_PomodoroView> createState() => _PomodoroViewState();
}

class _PomodoroViewState extends State<_PomodoroView> {
  int _timeLeft = 25 * 60;
  bool _active = false, _isBreak = false;
  Timer? _timer;

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _toggle() {
    if (_active) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_timeLeft > 0) { setState(() => _timeLeft--); }
        else { _timer?.cancel(); setState(() { _active = false; _isBreak = !_isBreak; _timeLeft = _isBreak ? 5 * 60 : 25 * 60; }); }
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

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      // Circular Timer
      SizedBox(width: 240.w, height: 240.w, child: CustomPaint(
        painter: _CirclePainter(_progress, _isBreak ? const Color(0xFF22C55E) : AppTheme.primary),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_isBreak ? 'REGENERATING' : 'OPERATIONAL', style: GoogleFonts.outfit(
            fontSize: 8.sp, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 3)),
          SizedBox(height: 4.h),
          Text('${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
            style: GoogleFonts.outfit(fontSize: 52.sp, fontWeight: FontWeight.w900, color: Colors.white)),
          SizedBox(height: 4.h),
          Row(mainAxisSize: MainAxisSize.min, children: List.generate(4, (i) => Container(
            width: 5.w, height: 5.w, margin: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary,
              boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.5), blurRadius: 4)])))),
        ])),
      )),
      SizedBox(height: 32.h),
      // Controls
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _ctrlBtn(Icons.refresh_rounded, _reset),
        SizedBox(width: 20.w),
        GestureDetector(onTap: _toggle, child: Container(width: 72.w, height: 72.w,
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary,
            boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))]),
          child: Icon(_active ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 36.sp, color: Colors.white))),
        SizedBox(width: 20.w),
        _ctrlBtn(Icons.settings_rounded, () {}),
      ]),
    ]);
  }

  Widget _ctrlBtn(IconData icon, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(
    padding: EdgeInsets.all(14.w), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
    child: Icon(icon, size: 22.sp, color: Colors.white38)));
}

// ─── Stopwatch ─────────────────────────────────────────────────────────────
class _StopwatchView extends StatefulWidget {
  const _StopwatchView({super.key});
  @override
  State<_StopwatchView> createState() => _StopwatchViewState();
}

class _StopwatchViewState extends State<_StopwatchView> {
  int _seconds = 0;
  bool _active = false;
  Timer? _timer;

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _toggle() {
    if (_active) { _timer?.cancel(); }
    else { _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _seconds++)); }
    setState(() => _active = !_active);
  }

  void _reset() { _timer?.cancel(); setState(() { _active = false; _seconds = 0; }); }

  @override
  Widget build(BuildContext context) {
    final h = _seconds ~/ 3600; final m = (_seconds % 3600) ~/ 60; final s = _seconds % 60;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('TACTICAL DURATION', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 3)),
      SizedBox(height: 8.h),
      Text('${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
        style: GoogleFonts.outfit(fontSize: 56.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -2)),
      SizedBox(height: 32.h),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        GestureDetector(onTap: _reset, child: Container(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
          child: Text('Reset', style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.white38)))),
        SizedBox(width: 16.w),
        GestureDetector(onTap: _toggle, child: Container(width: 72.w, height: 72.w,
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary,
            boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 20)]),
          child: Icon(_active ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 36.sp, color: Colors.white))),
        SizedBox(width: 16.w),
        GestureDetector(onTap: () { _timer?.cancel(); setState(() => _active = false); },
          child: Container(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
          child: Text('Save', style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.white38)))),
      ]),
    ]);
  }
}

// ─── Timer ──────────────────────────────────────────────────────────────────
class _TimerView extends StatefulWidget {
  const _TimerView({super.key});
  @override
  State<_TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<_TimerView> {
  int _inputMin = 10, _timeLeft = 10 * 60;
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
        else { _timer?.cancel(); setState(() => _active = false); }
      });
    }
    setState(() => _active = !_active);
  }

  void _reset() { _timer?.cancel(); setState(() { _active = false; _timeLeft = _inputMin * 60; }); }

  @override
  Widget build(BuildContext context) {
    final m = _timeLeft ~/ 60; final s = _timeLeft % 60;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      // Input
      if (!_active) ...[
        Text('SET DURATION', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 3)),
        SizedBox(height: 12.h),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _adjustBtn(Icons.remove_rounded, () { if (_inputMin > 1) setState(() { _inputMin--; _timeLeft = _inputMin * 60; }); }),
          SizedBox(width: 16.w),
          Text('$_inputMin min', style: GoogleFonts.outfit(fontSize: 28.sp, fontWeight: FontWeight.w800, color: Colors.white)),
          SizedBox(width: 16.w),
          _adjustBtn(Icons.add_rounded, () => setState(() { _inputMin++; _timeLeft = _inputMin * 60; })),
        ]),
        SizedBox(height: 20.h),
      ],
      Text('${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
        style: GoogleFonts.outfit(fontSize: 56.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -2)),
      SizedBox(height: 32.h),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        GestureDetector(onTap: _reset, child: Container(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
          child: Text('Reset', style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.white38)))),
        SizedBox(width: 16.w),
        GestureDetector(onTap: _toggle, child: Container(width: 72.w, height: 72.w,
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary,
            boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 20)]),
          child: Icon(_active ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 36.sp, color: Colors.white))),
      ]),
    ]);
  }

  Widget _adjustBtn(IconData icon, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(
    padding: EdgeInsets.all(10.w), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
    child: Icon(icon, size: 20.sp, color: Colors.white54)));
}

// ─── Circle Painter ────────────────────────────────────────────────────────
class _CirclePainter extends CustomPainter {
  final double progress; final Color color;
  _CirclePainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background circle
    canvas.drawCircle(center, radius, Paint()
      ..color = Colors.white.withValues(alpha: 0.05)..style = PaintingStyle.stroke..strokeWidth = 4);

    // Progress arc
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, 2 * pi * progress, false,
      Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant _CirclePainter old) => old.progress != progress || old.color != color;
}
