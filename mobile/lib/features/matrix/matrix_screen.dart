import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

class MatrixTask {
  final String id;
  String title, desc;
  int quadrant;
  bool completed;
  MatrixTask({required this.id, required this.title, this.desc = '', this.quadrant = 1, this.completed = false});
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'desc': desc, 'quadrant': quadrant, 'completed': completed};
  factory MatrixTask.fromJson(Map<String, dynamic> j) => MatrixTask(id: j['id'], title: j['title'], desc: j['desc'] ?? '', quadrant: j['quadrant'] ?? 1, completed: j['completed'] ?? false);
}

class _Quad { final int id; final String title, subtitle; final Color color; final IconData icon;
  const _Quad(this.id, this.title, this.subtitle, this.color, this.icon);
}

const _quads = [
  _Quad(1, 'Do First', 'Urgent & Important', Color(0xFFFF4D4D), Icons.bolt_rounded),
  _Quad(2, 'Schedule', 'Not Urgent & Important', Color(0xFFFFD700), Icons.calendar_today_rounded),
  _Quad(3, 'Delegate', 'Urgent & Unimportant', Color(0xFF3B82F6), Icons.flag_rounded),
  _Quad(4, 'Eliminate', 'Not Urgent & Unimportant', Color(0xFF10B981), Icons.coffee_rounded),
];

class MatrixScreen extends ConsumerStatefulWidget {
  const MatrixScreen({super.key});
  @override
  ConsumerState<MatrixScreen> createState() => _MatrixScreenState();
}

class _MatrixScreenState extends ConsumerState<MatrixScreen> {
  List<MatrixTask> _tasks = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final r = p.getString('habitflow-matrix');
    if (r != null) setState(() => _tasks = (jsonDecode(r) as List).map((e) => MatrixTask.fromJson(e)).toList());
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('habitflow-matrix', jsonEncode(_tasks.map((e) => e.toJson()).toList()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppTheme.background, body: SafeArea(child: Column(children: [
      // Header
      Padding(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h), child: Row(children: [
        _backBtn(context),
        SizedBox(width: 16.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('STRATEGIC PRIORITY', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2.5)),
          Text('Eisenhower Matrix', style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white)),
        ])),
        _addBtn(() => _showAdd(context)),
      ])).animate().fadeIn(duration: 400.ms),

      Expanded(child: ListView(padding: EdgeInsets.symmetric(horizontal: 20.w), children: [
        ..._quads.map((q) {
          final qTasks = _tasks.where((t) => t.quadrant == q.id).toList();
          return Container(margin: EdgeInsets.only(bottom: 16.h), decoration: BoxDecoration(
            color: q.color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: q.color.withValues(alpha: 0.2))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Quadrant Header
              Container(padding: EdgeInsets.all(16.w), decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2), borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
                child: Row(children: [
                  Container(padding: EdgeInsets.all(10.w), decoration: BoxDecoration(
                    color: q.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12.r)),
                    child: Icon(q.icon, size: 20.sp, color: q.color)),
                  SizedBox(width: 12.w),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(q.title, style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text(q.subtitle, style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w600, color: q.color.withValues(alpha: 0.6), letterSpacing: 1)),
                  ])),
                  Text('${qTasks.where((t) => !t.completed).length}', style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white38)),
                ])),
              // Tasks
              if (qTasks.isEmpty) Padding(padding: EdgeInsets.all(20.w), child: Center(child: Column(children: [
                Icon(Icons.add_circle_outline_rounded, size: 28.sp, color: Colors.white10),
                SizedBox(height: 4.h),
                Text('No tasks', style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.white10)),
              ])))
              else ...qTasks.map((t) => _taskTile(t, q.color)),
            ]));
        }),
        SizedBox(height: 80.h),
      ])),
    ])));
  }

  Widget _taskTile(MatrixTask t, Color c) => Container(
    margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: AppTheme.surfaceBorder)),
    child: Row(children: [
      GestureDetector(onTap: () { setState(() => t.completed = !t.completed); _save(); },
        child: Icon(t.completed ? Icons.check_circle_rounded : Icons.circle_outlined, size: 20.sp,
          color: t.completed ? c : Colors.white24)),
      SizedBox(width: 10.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t.title, style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w600,
          color: t.completed ? Colors.white24 : Colors.white,
          decoration: t.completed ? TextDecoration.lineThrough : null)),
        if (t.desc.isNotEmpty) Text(t.desc, style: GoogleFonts.inter(fontSize: 11.sp, color: AppTheme.textMuted),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      ])),
      GestureDetector(onTap: () { setState(() => _tasks.removeWhere((x) => x.id == t.id)); _save(); },
        child: Icon(Icons.close_rounded, size: 16.sp, color: Colors.white10)),
    ]));

  void _showAdd(BuildContext context) {
    final tc = TextEditingController(); final dc = TextEditingController();
    String urg = 'urgent', imp = 'important';
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
        padding: EdgeInsets.all(24.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2.r)))),
          SizedBox(height: 20.h),
          Text('Strategic Init', style: GoogleFonts.outfit(fontSize: 24.sp, fontWeight: FontWeight.w800, color: Colors.white)),
          SizedBox(height: 20.h),
          TextField(controller: tc, style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp), decoration: _dec('Task title...')),
          SizedBox(height: 12.h),
          TextField(controller: dc, maxLines: 2, style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp), decoration: _dec('Details...')),
          SizedBox(height: 16.h),
          Text('URGENCY', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2)),
          SizedBox(height: 6.h),
          Row(children: ['urgent', 'not-urgent'].map((o) => Expanded(child: GestureDetector(
            onTap: () => ss(() => urg = o),
            child: Container(margin: EdgeInsets.only(right: o == 'urgent' ? 6.w : 0),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(color: urg == o ? AppTheme.primary.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12.r), border: Border.all(color: urg == o ? AppTheme.primary : Colors.white.withValues(alpha: 0.1))),
              alignment: Alignment.center,
              child: Text(o.replaceAll('-', ' ').toUpperCase(), style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w700, color: urg == o ? Colors.white : Colors.white38)))))).toList()),
          SizedBox(height: 12.h),
          Text('IMPORTANCE', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2)),
          SizedBox(height: 6.h),
          Row(children: ['important', 'not-important'].map((o) => Expanded(child: GestureDetector(
            onTap: () => ss(() => imp = o),
            child: Container(margin: EdgeInsets.only(right: o == 'important' ? 6.w : 0),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(color: imp == o ? AppTheme.primary.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12.r), border: Border.all(color: imp == o ? AppTheme.primary : Colors.white.withValues(alpha: 0.1))),
              alignment: Alignment.center,
              child: Text(o.replaceAll('-', ' ').toUpperCase(), style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w700, color: imp == o ? Colors.white : Colors.white38)))))).toList()),
          const Spacer(),
          GestureDetector(onTap: () {
            if (tc.text.trim().isEmpty) return;
            int q = 4;
            if (urg == 'urgent' && imp == 'important') q = 1;
            else if (urg == 'not-urgent' && imp == 'important') q = 2;
            else if (urg == 'urgent' && imp == 'not-important') q = 3;
            setState(() => _tasks.add(MatrixTask(id: DateTime.now().millisecondsSinceEpoch.toString(), title: tc.text.trim(), desc: dc.text.trim(), quadrant: q)));
            _save(); Navigator.pop(ctx);
          }, child: Container(width: double.infinity, padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFFE85D04)]), borderRadius: BorderRadius.circular(16.r)),
            alignment: Alignment.center, child: Text('Commit to Matrix', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.sp)))),
        ]))));
  }

  InputDecoration _dec(String h) => InputDecoration(hintText: h, hintStyle: GoogleFonts.inter(color: Colors.white12, fontSize: 13.sp),
    filled: true, fillColor: Colors.white.withValues(alpha: 0.03), contentPadding: EdgeInsets.all(14.w),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5))));

  Widget _backBtn(BuildContext c) => GestureDetector(onTap: () => Navigator.pop(c), child: Container(padding: EdgeInsets.all(8.w),
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppTheme.surfaceBorder)),
    child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp)));

  Widget _addBtn(VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(padding: EdgeInsets.all(10.w),
    decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFFE85D04)]), borderRadius: BorderRadius.circular(12.r)),
    child: Icon(Icons.add_rounded, color: Colors.white, size: 22.sp)));
}
