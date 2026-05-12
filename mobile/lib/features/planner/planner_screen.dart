import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

// ─── Data Models ───────────────────────────────────────────────────────────
class PlannerTask {
  final String id;
  final String title;
  bool completed;

  PlannerTask({required this.id, required this.title, this.completed = false});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'completed': completed};
  factory PlannerTask.fromJson(Map<String, dynamic> json) =>
      PlannerTask(id: json['id'], title: json['title'], completed: json['completed'] ?? false);
}

class TimeSlot {
  final String timeRange;
  final List<PlannerTask> tasks;

  TimeSlot({required this.timeRange, List<PlannerTask>? tasks}) : tasks = tasks ?? [];

  Map<String, dynamic> toJson() => {
    'timeRange': timeRange,
    'tasks': tasks.map((t) => t.toJson()).toList(),
  };

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
    timeRange: json['timeRange'],
    tasks: (json['tasks'] as List).map((t) => PlannerTask.fromJson(t)).toList(),
  );
}

// ─── Constants ─────────────────────────────────────────────────────────────
const List<String> _defaultSlots = [
  '6 AM – 9 AM',
  '9 AM – 12 PM',
  '12 PM – 3 PM',
  '3 PM – 6 PM',
  '6 PM – 9 PM',
  '9 PM – 12 AM',
];

// ─── Planner Screen ────────────────────────────────────────────────────────
class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  DateTime _currentDate = DateTime.now();
  Map<String, List<TimeSlot>> _plannerData = {};
  String? _activeSlot;
  final _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _activeSlot = _defaultSlots[0];
    _loadData();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  String get _dateKey {
    return '${_currentDate.year}-${_currentDate.month.toString().padLeft(2, '0')}-${_currentDate.day.toString().padLeft(2, '0')}';
  }

  List<TimeSlot> get _currentDaySlots {
    return _plannerData[_dateKey] ?? _defaultSlots.map((r) => TimeSlot(timeRange: r)).toList();
  }

  int get _totalTasks => _currentDaySlots.fold(0, (sum, s) => sum + s.tasks.length);
  int get _completedTasks => _currentDaySlots.fold(0, (sum, s) => sum + s.tasks.where((t) => t.completed).length);
  int get _progress => _totalTasks > 0 ? ((_completedTasks / _totalTasks) * 100).round() : 0;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('habitflow-planner-data');
    if (raw != null) {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      setState(() {
        _plannerData = decoded.map((key, value) => MapEntry(
          key,
          (value as List).map((s) => TimeSlot.fromJson(s)).toList(),
        ));
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_plannerData.map((key, value) =>
        MapEntry(key, value.map((s) => s.toJson()).toList())));
    await prefs.setString('habitflow-planner-data', encoded);
  }

  void _addTask(String slotRange) {
    if (_taskController.text.trim().isEmpty) return;
    final slots = List<TimeSlot>.from(_currentDaySlots.map((s) {
      if (s.timeRange == slotRange) {
        return TimeSlot(
          timeRange: s.timeRange,
          tasks: [
            ...s.tasks,
            PlannerTask(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _taskController.text.trim(),
            ),
          ],
        );
      }
      return s;
    }));
    setState(() {
      _plannerData[_dateKey] = slots;
      _taskController.clear();
    });
    _saveData();
  }

  void _toggleTask(String slotRange, String taskId) {
    final slots = _currentDaySlots.map((s) {
      if (s.timeRange == slotRange) {
        return TimeSlot(
          timeRange: s.timeRange,
          tasks: s.tasks.map((t) {
            if (t.id == taskId) t.completed = !t.completed;
            return t;
          }).toList(),
        );
      }
      return s;
    }).toList();
    setState(() => _plannerData[_dateKey] = slots);
    _saveData();
  }

  void _deleteTask(String slotRange, String taskId) {
    final slots = _currentDaySlots.map((s) {
      if (s.timeRange == slotRange) {
        return TimeSlot(
          timeRange: s.timeRange,
          tasks: s.tasks.where((t) => t.id != taskId).toList(),
        );
      }
      return s;
    }).toList();
    setState(() => _plannerData[_dateKey] = slots);
    _saveData();
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _dayName(DateTime d) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return _isToday(d) ? 'Today' : days[d.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── App Bar ────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12.r),
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
                        Text('STRATEGIC PLANNING', style: GoogleFonts.outfit(
                          fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary,
                          letterSpacing: 2.5,
                        )),
                        Text('Daily Protocol', style: GoogleFonts.outfit(
                          fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white,
                        )),
                      ],
                    ),
                  ),
                  // Progress Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: Text('$_progress%', style: GoogleFonts.outfit(
                      fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppTheme.primary,
                    )),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            // ─── Date Navigation ────────────────────────────────────
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => setState(() => _currentDate = _currentDate.subtract(const Duration(days: 1))),
                    icon: Icon(Icons.chevron_left_rounded, color: Colors.white54, size: 24.sp),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _currentDate = DateTime.now()),
                    child: Column(
                      children: [
                        Text(_dayName(_currentDate), style: GoogleFonts.outfit(
                          fontSize: 14.sp, fontWeight: FontWeight.w800, color: Colors.white,
                          letterSpacing: 1.5,
                        )),
                        Text(_formatDate(_currentDate), style: GoogleFonts.outfit(
                          fontSize: 9.sp, fontWeight: FontWeight.w600, color: AppTheme.textMuted,
                          letterSpacing: 1.5,
                        )),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _currentDate = _currentDate.add(const Duration(days: 1))),
                    icon: Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 24.sp),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            SizedBox(height: 12.h),

            // ─── Stats Row ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  _buildStatChip(Icons.check_circle_outline, '$_completedTasks / $_totalTasks', 'Completed'),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: LinearProgressIndicator(
                        value: _progress / 100,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        valueColor: AlwaysStoppedAnimation(AppTheme.primary),
                        minHeight: 6.h,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            SizedBox(height: 12.h),

            // ─── Time Slots ─────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
                itemCount: _currentDaySlots.length,
                itemBuilder: (context, index) {
                  final slot = _currentDaySlots[index];
                  final isActive = _activeSlot == slot.timeRange;
                  final slotCompleted = slot.tasks.where((t) => t.completed).length;

                  return GestureDetector(
                    onTap: () => setState(() => _activeSlot = slot.timeRange),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isActive ? AppTheme.primary.withOpacity(0.5) : AppTheme.surfaceBorder,
                        ),
                        boxShadow: isActive ? [
                          BoxShadow(color: AppTheme.primary.withOpacity(0.05), blurRadius: 20),
                        ] : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Slot Header
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: isActive ? AppTheme.primary : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: isActive ? AppTheme.primary : Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Icon(Icons.access_time_rounded,
                                  size: 14.sp,
                                  color: isActive ? Colors.white : Colors.white38,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(slot.timeRange, style: GoogleFonts.outfit(
                                  fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white,
                                )),
                              ),
                              Text('$slotCompleted/${slot.tasks.length}', style: GoogleFonts.outfit(
                                fontSize: 11.sp, fontWeight: FontWeight.w800, color: AppTheme.primary,
                                letterSpacing: 1,
                              )),
                            ],
                          ),

                          SizedBox(height: 12.h),

                          // Tasks
                          if (slot.tasks.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                child: Column(
                                  children: [
                                    Icon(Icons.checklist_rounded, size: 28.sp, color: Colors.white10),
                                    SizedBox(height: 4.h),
                                    Text('ZONE UNALLOCATED', style: GoogleFonts.outfit(
                                      fontSize: 8.sp, fontWeight: FontWeight.w700, color: Colors.white10,
                                      letterSpacing: 2,
                                    )),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...slot.tasks.map((task) => Padding(
                              padding: EdgeInsets.only(bottom: 6.h),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _toggleTask(slot.timeRange, task.id),
                                      child: Icon(
                                        task.completed ? Icons.check_circle_rounded : Icons.circle_outlined,
                                        size: 20.sp,
                                        color: task.completed ? AppTheme.primary : Colors.white24,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(task.title, style: GoogleFonts.inter(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                        color: task.completed ? Colors.white24 : Colors.white70,
                                        decoration: task.completed ? TextDecoration.lineThrough : null,
                                      )),
                                    ),
                                    GestureDetector(
                                      onTap: () => _deleteTask(slot.timeRange, task.id),
                                      child: Icon(Icons.close_rounded, size: 16.sp, color: Colors.white10),
                                    ),
                                  ],
                                ),
                              ),
                            )),

                          // Add Task Input
                          if (isActive) ...[
                            SizedBox(height: 8.h),
                            Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.05),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _taskController,
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp),
                                    decoration: InputDecoration(
                                      hintText: 'Allocate task...',
                                      hintStyle: GoogleFonts.inter(color: Colors.white12, fontSize: 13.sp),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.03),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                        borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
                                      ),
                                    ),
                                    onSubmitted: (_) => _addTask(slot.timeRange),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                GestureDetector(
                                  onTap: () => _addTask(slot.timeRange),
                                  child: Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    child: Icon(Icons.add_rounded, size: 18.sp, color: Colors.white54),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: AppTheme.primary),
          SizedBox(width: 6.w),
          Text(value, style: GoogleFonts.outfit(
            fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white,
          )),
        ],
      ),
    );
  }
}
