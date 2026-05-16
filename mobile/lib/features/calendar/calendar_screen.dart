import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';


// ─── Models ──────────────────────────────────────────────────────────────────
enum ViewMode { grid, table }

class MockHabit {
  final String title;
  final Color color;
  MockHabit(this.title, this.color);
}

// ─── Calendar Screen ───────────────────────────────────────────────────────
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _current = DateTime.now();
  ViewMode _viewMode = ViewMode.grid;

  final List<MockHabit> _mockHabits = [
    MockHabit("Morning Workout", AppTheme.primary),
    MockHabit("Read 20 Pages", AppTheme.primary),
    MockHabit("Meditation", const Color(0xFF10B981)), // Emerald green
  ];

  String _monthName(int m) => ['January','February','March','April','May','June','July','August','September','October','November','December'][m - 1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text('Chronology', style: GoogleFonts.outfit(fontSize: 32.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                  SizedBox(width: 10.w),
                  Icon(Icons.calendar_today_outlined, color: AppTheme.primary, size: 24.sp),
                ],
              ),
              SizedBox(height: 12.h),
              Text('Comprehensive habit tracking across\ntime.', style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white54, height: 1.4)),
              SizedBox(height: 24.h),

              // Toggle Grid / Table
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleBtn(ViewMode.grid, Icons.grid_view_rounded, 'Grid'),
                    _buildToggleBtn(ViewMode.table, Icons.view_list_rounded, 'Table'),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Date Navigator
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _current = DateTime(_current.year, _current.month - 1)),
                            child: Icon(Icons.chevron_left_rounded, color: Colors.white54, size: 20.sp),
                          ),
                          Text('${_monthName(_current.month)} ${_current.year}', style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w800, color: Colors.white)),
                          GestureDetector(
                            onTap: () => setState(() => _current = DateTime(_current.year, _current.month + 1)),
                            child: Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 20.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () => setState(() => _current = DateTime.now()),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Text('Today', style: GoogleFonts.outfit(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Stats Cards
              Row(
                children: [
                  Expanded(child: _buildStatCard('ACTIVE\nDAYS', '0', '/31', AppTheme.primary)),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildStatCard('PERFECT\nDAYS', '0', ' days', const Color(0xFF10B981))),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildStatCard('COMPLETION', '0', '%', const Color(0xFFEAB308))),
                ],
              ),
              SizedBox(height: 24.h),

              // Main View
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _viewMode == ViewMode.grid ? _buildGridView() : _buildTableView(),
              ),
              
              SizedBox(height: 120.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleBtn(ViewMode mode, IconData icon, String label) {
    final isActive = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: isActive ? Colors.white : Colors.white54),
            SizedBox(width: 8.w),
            Text(label, style: GoogleFonts.outfit(fontSize: 13.sp, fontWeight: FontWeight.w700, color: isActive ? Colors.white : Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String val, String suffix, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w700, color: Colors.white54, letterSpacing: 1.5, height: 1.4)),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(val, style: GoogleFonts.outfit(fontSize: 28.sp, fontWeight: FontWeight.w800, color: color, height: 1)),
              Padding(
                padding: EdgeInsets.only(bottom: 4.h, left: 2.w),
                child: Text(suffix, style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white54)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    final first = DateTime(_current.year, _current.month, 1);
    final daysInMonth = DateTime(_current.year, _current.month + 1, 0).day;
    int startWeekday = first.weekday; // Mon=1
    if (startWeekday == 7) startWeekday = 0; // Adjust so Sunday is 0 if your week starts on Sun
    
    final days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    final now = DateTime.now();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // Days Header
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Row(
              children: days.map((d) => Expanded(
                child: Center(child: Text(d, style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.white54, letterSpacing: 1.5))),
              )).toList(),
            ),
          ),
          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.8),
            itemCount: 42, // 6 rows * 7 cols
            itemBuilder: (context, index) {
              final isPadding = index < startWeekday || index >= startWeekday + daysInMonth;
              if (isPadding) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
                  ),
                );
              }

              final day = index - startWeekday + 1;
              final date = DateTime(_current.year, _current.month, day);
              final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

              return GestureDetector(
                onTap: () => _showDailyLog(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday ? AppTheme.primary.withValues(alpha: 0.15) : Colors.transparent,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday ? AppTheme.primary : Colors.transparent,
                      boxShadow: isToday ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 12)] : null,
                    ),
                    alignment: Alignment.center,
                    child: Text('$day', style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                      color: isToday ? Colors.white : Colors.white,
                    )),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms);
  }

  Widget _buildTableView() {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    // For simplicity, just rendering a mock 7-day view of the current week or a scrolling list.
    // The screenshot shows 7 columns of days.
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: Row(
              children: [
                SizedBox(width: 16.w),
                Expanded(flex: 3, child: Text('PROTOCOL', style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.white54, letterSpacing: 1.5))),
                ...List.generate(7, (i) => Expanded(
                  child: Center(
                    child: Column(
                      children: [
                        Text(days[i], style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w800, color: i == 4 ? AppTheme.primary : Colors.white24)),
                        SizedBox(height: 4.h),
                        Text('${10 + i}', style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w800, color: i == 4 ? Colors.white : Colors.white24)),
                      ],
                    )
                  )
                )),
                SizedBox(width: 8.w),
              ],
            ),
          ),
          // Rows
          ..._mockHabits.map((h) => Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.02))),
            ),
            child: Row(
              children: [
                SizedBox(width: 16.w),
                Expanded(flex: 3, child: Row(
                  children: [
                    Container(width: 8.w, height: 8.w, decoration: BoxDecoration(color: h.color, shape: BoxShape.circle)),
                    // Instead of long text, we just show the dot and space if it's too cramped, 
                    // but in screenshot protocol name isn't visible, just dots? Wait, the screenshot only shows dots in the protocol column!
                    // Let's just show the dot for visual parity.
                  ],
                )),
                ...List.generate(7, (i) => Expanded(
                  child: Center(
                    child: Container(
                      width: 24.w, height: 24.w,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                    ),
                  )
                )),
                SizedBox(width: 8.w),
              ],
            ),
          )),
        ],
      ),
    ).animate().fade(duration: 300.ms);
  }

  void _showDailyLog(DateTime date) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => _DailyLogDialog(date: date, habits: _mockHabits),
    );
  }
}

// ─── Daily Log Dialog (Screen 3) ───────────────────────────────────────────
class _DailyLogDialog extends StatefulWidget {
  final DateTime date;
  final List<MockHabit> habits;
  const _DailyLogDialog({required this.date, required this.habits});

  @override
  State<_DailyLogDialog> createState() => _DailyLogDialogState();
}

class _DailyLogDialogState extends State<_DailyLogDialog> {
  final _screenTimeCtrl = TextEditingController(text: '0');
  
  String _formatDateTitle(DateTime d) {
    const days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final suffix = _getDaySuffix(d.day);
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}$suffix';
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF111111),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      insetPadding: EdgeInsets.all(20.w),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
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
                    Text('Daily Log', style: GoogleFonts.outfit(fontSize: 24.sp, fontWeight: FontWeight.w900, color: Colors.white)),
                    SizedBox(height: 4.h),
                    Text(_formatDateTitle(widget.date), style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close_rounded, color: Colors.white54, size: 24.sp),
                ),
              ],
            ),
            SizedBox(height: 32.h),

            Text('HABITS', style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.white54, letterSpacing: 1.5)),
            SizedBox(height: 12.h),
            ...widget.habits.map((h) => Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20.w, height: 20.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: Colors.white38),
                    ),
                  ),
                  const Spacer(),
                  Container(width: 8.w, height: 8.w, decoration: BoxDecoration(color: h.color, shape: BoxShape.circle)),
                ],
              ),
            )),

            SizedBox(height: 24.h),
            Row(
              children: [
                Icon(Icons.description_outlined, color: Colors.white54, size: 14.sp),
                SizedBox(width: 8.w),
                Text('DAILY REFLECTION', style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.white54, letterSpacing: 1.5)),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: TextField(
                maxLines: 3,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp),
                decoration: InputDecoration.collapsed(
                  hintText: 'What went well? What challenged you today...',
                  hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 13.sp),
                ),
              ),
            ),

            SizedBox(height: 24.h),
            Row(
              children: [
                Icon(Icons.desktop_windows_outlined, color: Colors.white54, size: 14.sp),
                SizedBox(width: 8.w),
                Text('SCREEN TIME (HOURS)', style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.white54, letterSpacing: 1.5)),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: TextField(
                controller: _screenTimeCtrl,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
                decoration: const InputDecoration.collapsed(hintText: ''),
              ),
            ),

            SizedBox(height: 32.h),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: Text('Save Entry', style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w800, color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

