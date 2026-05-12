import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

class VisionItem { final String id; String title, category; bool completed;
  VisionItem({required this.id, required this.title, this.category = 'Life', this.completed = false});
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'category': category, 'completed': completed};
  factory VisionItem.fromJson(Map<String, dynamic> j) => VisionItem(id: j['id'], title: j['title'], category: j['category'] ?? 'Life', completed: j['completed'] ?? false);
}

class VisionBoardScreen extends StatefulWidget {
  const VisionBoardScreen({super.key});
  @override
  State<VisionBoardScreen> createState() => _VisionBoardScreenState();
}

class _VisionBoardScreenState extends State<VisionBoardScreen> {
  List<VisionItem> _items = [];
  final _cats = ['Life', 'Career', 'Health', 'Travel', 'Finance', 'Relationships'];

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { final p = await SharedPreferences.getInstance(); final r = p.getString('habitflow-vision');
    if (r != null) setState(() => _items = (jsonDecode(r) as List).map((e) => VisionItem.fromJson(e)).toList()); }
  Future<void> _save() async { final p = await SharedPreferences.getInstance();
    await p.setString('habitflow-vision', jsonEncode(_items.map((e) => e.toJson()).toList())); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppTheme.background, body: SafeArea(child: Column(children: [
      Padding(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h), child: Row(children: [
        GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppTheme.surfaceBorder)),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp))),
        SizedBox(width: 16.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('VISUALIZATION', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2.5)),
          Text('Vision Board', style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white)),
        ])),
        GestureDetector(onTap: _addItem, child: Container(padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFFE85D04)]), borderRadius: BorderRadius.circular(12.r)),
          child: Icon(Icons.add_rounded, color: Colors.white, size: 22.sp))),
      ])).animate().fadeIn(duration: 400.ms),

      // Progress
      if (_items.isNotEmpty) Padding(padding: EdgeInsets.symmetric(horizontal: 20.w), child: Container(
        padding: EdgeInsets.all(14.w), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: AppTheme.surfaceBorder)),
        child: Row(children: [
          Text('${_items.where((i) => i.completed).length}/${_items.length} achieved', style: GoogleFonts.outfit(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white)),
          SizedBox(width: 12.w),
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4.r), child: LinearProgressIndicator(
            value: _items.isEmpty ? 0 : _items.where((i) => i.completed).length / _items.length,
            minHeight: 6.h, backgroundColor: Colors.white.withValues(alpha: 0.05), valueColor: AlwaysStoppedAnimation(AppTheme.primary)))),
        ]))),
      SizedBox(height: 12.h),

      Expanded(child: _items.isEmpty
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.dashboard_customize_rounded, size: 48.sp, color: Colors.white10), SizedBox(height: 12.h),
            Text('Manifest Your Future', style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(height: 4.h),
            Text('Add your dreams and goals.', style: GoogleFonts.inter(fontSize: 13.sp, color: AppTheme.textMuted)),
          ]))
        : GridView.builder(padding: EdgeInsets.symmetric(horizontal: 20.w), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 12.h, crossAxisSpacing: 12.w, childAspectRatio: 0.85),
          itemCount: _items.length, itemBuilder: (_, i) => _card(_items[i], i))),
    ])));
  }

  Widget _card(VisionItem item, int index) {
    final catColors = {'Life': const Color(0xFFFF6B2C), 'Career': const Color(0xFF3B82F6), 'Health': const Color(0xFF10B981),
      'Travel': const Color(0xFFA855F7), 'Finance': const Color(0xFFFFD700), 'Relationships': const Color(0xFFEC4899)};
    final c = catColors[item.category] ?? AppTheme.primary;

    return GestureDetector(onTap: () { setState(() => item.completed = !item.completed); _save(); },
      onLongPress: () { setState(() => _items.removeWhere((x) => x.id == item.id)); _save(); },
      child: Container(decoration: BoxDecoration(
        color: item.completed ? c.withValues(alpha: 0.1) : AppTheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: item.completed ? c.withValues(alpha: 0.4) : AppTheme.surfaceBorder)),
        child: Padding(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6.r)),
              child: Text(item.category, style: GoogleFonts.outfit(fontSize: 8.sp, fontWeight: FontWeight.w700, color: c, letterSpacing: 1))),
            SizedBox(height: 12.h),
            Text(item.title, style: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white, height: 1.3),
              maxLines: 3, overflow: TextOverflow.ellipsis),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(item.completed ? 'ACHIEVED' : 'IN PROGRESS', style: GoogleFonts.outfit(fontSize: 8.sp,
              fontWeight: FontWeight.w800, color: item.completed ? c : Colors.white24, letterSpacing: 1.5)),
            Icon(item.completed ? Icons.check_circle_rounded : Icons.circle_outlined, size: 22.sp,
              color: item.completed ? c : Colors.white12),
          ]),
        ])))
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms);
  }

  void _addItem() {
    final tc = TextEditingController(); String cat = 'Life';
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Container(
        height: MediaQuery.of(context).size.height * 0.55, padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2.r)))),
          SizedBox(height: 20.h),
          Text('Add Vision', style: GoogleFonts.outfit(fontSize: 24.sp, fontWeight: FontWeight.w800, color: Colors.white)),
          SizedBox(height: 16.h),
          TextField(controller: tc, autofocus: true, style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
            decoration: InputDecoration(hintText: 'Your dream or goal...', hintStyle: GoogleFonts.inter(color: Colors.white12),
              filled: true, fillColor: Colors.white.withValues(alpha: 0.03), contentPadding: EdgeInsets.all(14.w),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5))))),
          SizedBox(height: 12.h),
          Wrap(spacing: 6.w, runSpacing: 6.h, children: _cats.map((c) {
            final a = cat == c;
            return GestureDetector(onTap: () => ss(() => cat = c), child: Container(padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(color: a ? AppTheme.primary : Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(10.r)),
              child: Text(c, style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w700, color: a ? Colors.white : Colors.white38))));
          }).toList()),
          const Spacer(),
          GestureDetector(onTap: () { if (tc.text.trim().isEmpty) return;
            setState(() => _items.add(VisionItem(id: DateTime.now().millisecondsSinceEpoch.toString(), title: tc.text.trim(), category: cat)));
            _save(); Navigator.pop(ctx); },
            child: Container(width: double.infinity, padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFFE85D04)]), borderRadius: BorderRadius.circular(16.r)),
              alignment: Alignment.center, child: Text('Manifest', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.sp)))),
        ]))));
  }
}
