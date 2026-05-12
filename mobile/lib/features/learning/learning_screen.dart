import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

class Subject { final String id; String name; List<Chapter> chapters;
  Subject({required this.id, required this.name, List<Chapter>? chapters}) : chapters = chapters ?? [];
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'chapters': chapters.map((c) => c.toJson()).toList()};
  factory Subject.fromJson(Map<String, dynamic> j) => Subject(id: j['id'], name: j['name'],
    chapters: (j['chapters'] as List?)?.map((c) => Chapter.fromJson(c)).toList());
  double get progress { if (chapters.isEmpty) return 0; return chapters.fold<double>(0, (s, c) => s + c.progress) / chapters.length; }
}

class Chapter { final String id; String name; List<Topic> topics;
  Chapter({required this.id, required this.name, List<Topic>? topics}) : topics = topics ?? [];
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'topics': topics.map((t) => t.toJson()).toList()};
  factory Chapter.fromJson(Map<String, dynamic> j) => Chapter(id: j['id'], name: j['name'],
    topics: (j['topics'] as List?)?.map((t) => Topic.fromJson(t)).toList());
  double get progress { if (topics.isEmpty) return 0; return topics.where((t) => t.completed).length / topics.length * 100; }
}

class Topic { final String id; String name; bool completed;
  Topic({required this.id, required this.name, this.completed = false});
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'completed': completed};
  factory Topic.fromJson(Map<String, dynamic> j) => Topic(id: j['id'], name: j['name'], completed: j['completed'] ?? false);
}

class LearningScreen extends ConsumerStatefulWidget {
  const LearningScreen({super.key});
  @override
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen> {
  List<Subject> _subjects = [];
  String? _expandedSubject, _expandedChapter;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final r = p.getString('habitflow-learning');
    if (r != null) setState(() => _subjects = (jsonDecode(r) as List).map((e) => Subject.fromJson(e)).toList());
  }
  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('habitflow-learning', jsonEncode(_subjects.map((e) => e.toJson()).toList()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppTheme.background, body: SafeArea(child: Column(children: [
      Padding(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h), child: Row(children: [
        _back(context), SizedBox(width: 16.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('KNOWLEDGE BASE', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2.5)),
          Text('Learning Hub', style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white)),
        ])),
        GestureDetector(onTap: () => _addSubject(), child: Container(padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFFE85D04)]), borderRadius: BorderRadius.circular(12.r)),
          child: Icon(Icons.add_rounded, color: Colors.white, size: 22.sp))),
      ])).animate().fadeIn(duration: 400.ms),

      // Stats
      if (_subjects.isNotEmpty) Padding(padding: EdgeInsets.symmetric(horizontal: 20.w), child: Container(
        padding: EdgeInsets.all(14.w), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: AppTheme.surfaceBorder)),
        child: Row(children: [
          _stat('${_subjects.length}', 'Subjects'), SizedBox(width: 16.w),
          _stat('${_subjects.fold<int>(0, (s, sub) => s + sub.chapters.length)}', 'Chapters'), SizedBox(width: 16.w),
          _stat('${_subjects.fold<int>(0, (s, sub) => s + sub.chapters.fold<int>(0, (s2, ch) => s2 + ch.topics.length))}', 'Topics'),
        ]))),

      SizedBox(height: 12.h),

      Expanded(child: _subjects.isEmpty
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.auto_stories_rounded, size: 48.sp, color: Colors.white10), SizedBox(height: 12.h),
            Text('No Subjects Yet', style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(height: 4.h),
            Text('Start building your knowledge base.', style: GoogleFonts.inter(fontSize: 13.sp, color: AppTheme.textMuted)),
          ]))
        : ListView.builder(padding: EdgeInsets.symmetric(horizontal: 20.w), itemCount: _subjects.length,
            itemBuilder: (_, i) => _subjectCard(_subjects[i]))),
    ])));
  }

  Widget _subjectCard(Subject s) {
    final expanded = _expandedSubject == s.id;
    return Container(margin: EdgeInsets.only(bottom: 12.h), decoration: BoxDecoration(color: AppTheme.surface,
      borderRadius: BorderRadius.circular(20.r), border: Border.all(color: AppTheme.surfaceBorder)),
      child: Column(children: [
        GestureDetector(onTap: () => setState(() => _expandedSubject = expanded ? null : s.id),
          child: Padding(padding: EdgeInsets.all(16.w), child: Row(children: [
            Container(padding: EdgeInsets.all(10.w), decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
              child: Icon(Icons.book_rounded, size: 20.sp, color: AppTheme.primary)),
            SizedBox(width: 12.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.name, style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white)),
              SizedBox(height: 4.h),
              Row(children: [
                Text('${s.chapters.length} chapters', style: GoogleFonts.inter(fontSize: 11.sp, color: AppTheme.textMuted)),
                SizedBox(width: 8.w),
                Text('${s.progress.round()}%', style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              ]),
              SizedBox(height: 4.h),
              ClipRRect(borderRadius: BorderRadius.circular(4.r), child: LinearProgressIndicator(value: s.progress / 100, minHeight: 4.h,
                backgroundColor: Colors.white.withValues(alpha: 0.05), valueColor: AlwaysStoppedAnimation(AppTheme.primary))),
            ])),
            Row(children: [
              GestureDetector(onTap: () { setState(() => _subjects.removeWhere((x) => x.id == s.id)); _save(); },
                child: Icon(Icons.delete_rounded, size: 16.sp, color: Colors.white10)),
              SizedBox(width: 8.w),
              Icon(expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 20.sp, color: Colors.white38),
            ]),
          ]))),
        if (expanded) ...[
          Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
          Padding(padding: EdgeInsets.all(12.w), child: Column(children: [
            ...s.chapters.map((ch) => _chapterTile(s, ch)),
            SizedBox(height: 8.h),
            GestureDetector(onTap: () => _addChapter(s), child: Container(padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_rounded, size: 16.sp, color: Colors.white24), SizedBox(width: 6.w),
                Text('Add Chapter', style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.white24, fontWeight: FontWeight.w600)),
              ]))),
          ])),
        ],
      ])).animate().fadeIn(duration: 300.ms);
  }

  Widget _chapterTile(Subject s, Chapter ch) {
    final expanded = _expandedChapter == ch.id;
    return Container(margin: EdgeInsets.only(bottom: 8.h), padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Column(children: [
        GestureDetector(onTap: () => setState(() => _expandedChapter = expanded ? null : ch.id),
          child: Row(children: [
            Expanded(child: Text(ch.name, style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white))),
            Text('${ch.progress.round()}%', style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppTheme.primary)),
            SizedBox(width: 6.w),
            Icon(expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 18.sp, color: Colors.white24),
          ])),
        if (expanded) ...[
          SizedBox(height: 8.h),
          ...ch.topics.map((t) => GestureDetector(onTap: () { setState(() => t.completed = !t.completed); _save(); },
            child: Container(margin: EdgeInsets.only(bottom: 4.h), padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(10.r)),
              child: Row(children: [
                Icon(t.completed ? Icons.check_circle_rounded : Icons.circle_outlined, size: 18.sp,
                  color: t.completed ? AppTheme.primary : Colors.white24),
                SizedBox(width: 8.w),
                Expanded(child: Text(t.name, style: GoogleFonts.inter(fontSize: 13.sp, color: t.completed ? Colors.white24 : Colors.white70,
                  decoration: t.completed ? TextDecoration.lineThrough : null))),
              ])))),
          SizedBox(height: 6.h),
          GestureDetector(onTap: () => _addTopic(s, ch), child: Row(children: [
            Icon(Icons.add_rounded, size: 14.sp, color: Colors.white12), SizedBox(width: 4.w),
            Text('Add Topic', style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.white12)),
          ])),
        ],
      ]));
  }

  void _addSubject() => _showInput('Subject Name', (v) {
    setState(() => _subjects.add(Subject(id: DateTime.now().millisecondsSinceEpoch.toString(), name: v)));
    _save();
  });

  void _addChapter(Subject s) => _showInput('Chapter Name', (v) {
    setState(() => s.chapters.add(Chapter(id: DateTime.now().millisecondsSinceEpoch.toString(), name: v)));
    _save();
  });

  void _addTopic(Subject s, Chapter ch) => _showInput('Topic Name', (v) {
    setState(() => ch.topics.add(Topic(id: DateTime.now().millisecondsSinceEpoch.toString(), name: v)));
    _save();
  });

  void _showInput(String label, Function(String) onSave) {
    final c = TextEditingController();
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (ctx) => Container(
      padding: EdgeInsets.all(24.w), decoration: BoxDecoration(color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white)),
        SizedBox(height: 16.h),
        TextField(controller: c, autofocus: true, style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
          decoration: InputDecoration(hintText: 'Enter name...', hintStyle: GoogleFonts.inter(color: Colors.white12),
            filled: true, fillColor: Colors.white.withValues(alpha: 0.03), contentPadding: EdgeInsets.all(14.w),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5))))),
        SizedBox(height: 16.h),
        GestureDetector(onTap: () { if (c.text.trim().isNotEmpty) { onSave(c.text.trim()); Navigator.pop(ctx); } },
          child: Container(width: double.infinity, padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFFE85D04)]), borderRadius: BorderRadius.circular(14.r)),
            alignment: Alignment.center, child: Text('Add', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)))),
        SizedBox(height: 16.h),
      ])));
  }

  Widget _stat(String v, String l) => Expanded(child: Column(children: [
    Text(v, style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.w800, color: Colors.white)),
    Text(l, style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 1)),
  ]));

  Widget _back(BuildContext c) => GestureDetector(onTap: () => Navigator.pop(c), child: Container(padding: EdgeInsets.all(8.w),
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppTheme.surfaceBorder)),
    child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp)));
}
