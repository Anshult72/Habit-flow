import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

// ─── Data Model ────────────────────────────────────────────────────────────
class Memo {
  final String id;
  String title;
  String content;
  String category;
  String priority;
  String color;
  bool isPinned;
  final DateTime createdAt;

  Memo({
    required this.id,
    required this.title,
    required this.content,
    this.category = 'Ideas',
    this.priority = 'Low',
    this.color = '#FF6B2C',
    this.isPinned = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'content': content,
    'category': category, 'priority': priority, 'color': color,
    'isPinned': isPinned, 'createdAt': createdAt.toIso8601String(),
  };

  factory Memo.fromJson(Map<String, dynamic> json) => Memo(
    id: json['id'], title: json['title'], content: json['content'],
    category: json['category'] ?? 'Ideas', priority: json['priority'] ?? 'Low',
    color: json['color'] ?? '#FF6B2C', isPinned: json['isPinned'] ?? false,
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
  );
}

// ─── Memo Screen ───────────────────────────────────────────────────────────
class MemoScreen extends ConsumerStatefulWidget {
  const MemoScreen({super.key});

  @override
  ConsumerState<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends ConsumerState<MemoScreen> {
  List<Memo> _memos = [];
  String _searchQuery = '';
  String _activeCategory = 'All';
  final _quickController = TextEditingController();

  static const _categories = ['All', 'Ideas', 'Study', 'Vision', 'Routine', 'Research', 'Business', 'Coding', 'Personal'];

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  @override
  void dispose() {
    _quickController.dispose();
    super.dispose();
  }

  Future<void> _loadMemos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('habitflow-memos');
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      setState(() => _memos = decoded.map((m) => Memo.fromJson(m)).toList());
    }
  }

  Future<void> _saveMemos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('habitflow-memos', jsonEncode(_memos.map((m) => m.toJson()).toList()));
  }

  List<Memo> get _filtered {
    return _memos.where((m) {
      final matchSearch = m.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.content.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCat = _activeCategory == 'All' || m.category == _activeCategory;
      return matchSearch && matchCat;
    }).toList();
  }

  void _quickAdd() {
    if (_quickController.text.trim().isEmpty) return;
    setState(() {
      _memos.insert(0, Memo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Quick Thought',
        content: _quickController.text.trim(),
        category: 'Ideas',
      ));
      _quickController.clear();
    });
    _saveMemos();
  }

  void _deleteMemo(String id) {
    setState(() => _memos.removeWhere((m) => m.id == id));
    _saveMemos();
  }

  void _togglePin(String id) {
    setState(() {
      final memo = _memos.firstWhere((m) => m.id == id);
      memo.isPinned = !memo.isPinned;
    });
    _saveMemos();
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'High': return Colors.redAccent;
      case 'Medium': return Colors.amber;
      default: return Colors.blue;
    }
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinned = _filtered.where((m) => m.isPinned).toList();
    final others = _filtered.where((m) => !m.isPinned).toList();

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
                        Text('COGNITIVE CACHE', style: GoogleFonts.outfit(
                          fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2.5,
                        )),
                        Text('Second Brain', style: GoogleFonts.outfit(
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

            // ─── Quick Capture ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TextField(
                controller: _quickController,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp),
                decoration: InputDecoration(
                  hintText: 'Quick Capture thought... (Enter to save)',
                  hintStyle: GoogleFonts.inter(color: Colors.white12, fontSize: 13.sp),
                  prefixIcon: Icon(Icons.bolt_rounded, color: AppTheme.primary.withOpacity(0.4), size: 18.sp),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.03),
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.5)),
                  ),
                ),
                onSubmitted: (_) => _quickAdd(),
              ),
            ),

            SizedBox(height: 12.h),

            // ─── Category Chips ─────────────────────────────────────
            SizedBox(
              height: 36.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final isActive = _activeCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _activeCategory = cat),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.primary : Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isActive ? AppTheme.primary : Colors.white.withOpacity(0.1),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(cat, style: GoogleFonts.outfit(
                        fontSize: 11.sp, fontWeight: FontWeight.w700,
                        color: isActive ? Colors.white : Colors.white38,
                      )),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 12.h),

            // ─── Search ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TextField(
                style: GoogleFonts.inter(color: Colors.white, fontSize: 12.sp),
                decoration: InputDecoration(
                  hintText: 'Search brain...',
                  hintStyle: GoogleFonts.inter(color: Colors.white12, fontSize: 12.sp),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.white12, size: 18.sp),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.03),
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
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
                    borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.5)),
                  ),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),

            SizedBox(height: 12.h),

            // ─── Memos List ─────────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sticky_note_2_outlined, size: 48.sp, color: Colors.white10),
                          SizedBox(height: 12.h),
                          Text('Synaptic Void Detected.', style: GoogleFonts.outfit(
                            fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white,
                          )),
                          SizedBox(height: 4.h),
                          Text('No thoughts currently cached.', style: GoogleFonts.inter(
                            fontSize: 13.sp, color: AppTheme.textMuted,
                          )),
                        ],
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      children: [
                        if (pinned.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(Icons.push_pin_rounded, size: 14.sp, color: AppTheme.primary),
                              SizedBox(width: 6.w),
                              Text('PRIORITY SYNC', style: GoogleFonts.outfit(
                                fontSize: 11.sp, fontWeight: FontWeight.w800, color: Colors.white,
                                letterSpacing: 2,
                              )),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          ...pinned.map((m) => _buildMemoCard(m)),
                          SizedBox(height: 16.h),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('THOUGHT RESERVOIR', style: GoogleFonts.outfit(
                              fontSize: 11.sp, fontWeight: FontWeight.w800, color: Colors.white,
                              letterSpacing: 2,
                            )),
                            Text('${_filtered.length} Units', style: GoogleFonts.outfit(
                              fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted,
                              letterSpacing: 1.5,
                            )),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        ...others.map((m) => _buildMemoCard(m)),
                        SizedBox(height: 80.h),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoCard(Memo memo) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: memo.isPinned ? AppTheme.primary.withOpacity(0.3) : AppTheme.surfaceBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color indicator
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: _parseColor(memo.color),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(memo.title, style: GoogleFonts.outfit(
                            fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white,
                          ), maxLines: 1, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(memo.category, style: GoogleFonts.outfit(
                              fontSize: 8.sp, fontWeight: FontWeight.w800, color: AppTheme.primary,
                              letterSpacing: 1.5,
                            )),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _togglePin(memo.id),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: memo.isPinned ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.push_pin_rounded,
                          size: 14.sp,
                          color: memo.isPinned ? AppTheme.primary : Colors.white10,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(memo.content, style: GoogleFonts.inter(
                  fontSize: 13.sp, color: AppTheme.textMuted, height: 1.5,
                ), maxLines: 4, overflow: TextOverflow.ellipsis),
                SizedBox(height: 12.h),
                Container(height: 1, color: Colors.white.withOpacity(0.05)),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 10.sp, color: Colors.white12),
                        SizedBox(width: 4.w),
                        Text(
                          '${memo.createdAt.day}/${memo.createdAt.month}/${memo.createdAt.year}',
                          style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w600, color: Colors.white12, letterSpacing: 1),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showCreateModal(context, existing: memo),
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(Icons.edit_rounded, size: 14.sp, color: Colors.white24),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        GestureDetector(
                          onTap: () => _deleteMemo(memo.id),
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(Icons.delete_rounded, size: 14.sp, color: Colors.white24),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  void _showCreateModal(BuildContext context, {Memo? existing}) {
    final titleC = TextEditingController(text: existing?.title ?? '');
    final contentC = TextEditingController(text: existing?.content ?? '');
    String category = existing?.category ?? 'Ideas';
    String priority = existing?.priority ?? 'Low';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(width: 40.w, height: 4.h,
                    decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2.r)),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(existing != null ? 'Refine Memo' : 'Cache Thought', style: GoogleFonts.outfit(
                  fontSize: 24.sp, fontWeight: FontWeight.w800, color: Colors.white,
                )),
                SizedBox(height: 20.h),

                // Title
                Text('HEADER', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2)),
                SizedBox(height: 6.h),
                TextField(
                  controller: titleC,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
                  decoration: _inputDecoration('Title your insight...'),
                ),
                SizedBox(height: 16.h),

                // Content
                Text('SUBSTANCE', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2)),
                SizedBox(height: 6.h),
                Expanded(
                  child: TextField(
                    controller: contentC,
                    maxLines: null,
                    expands: true,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp),
                    decoration: _inputDecoration('Expand your consciousness here...'),
                  ),
                ),
                SizedBox(height: 16.h),

                // Category chips
                Text('CLASSIFICATION', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: Colors.white24, letterSpacing: 2)),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: ['Ideas', 'Study', 'Vision', 'Routine', 'Research', 'Business', 'Coding', 'Personal'].map((c) {
                    final isActive = category == c;
                    return GestureDetector(
                      onTap: () => setModalState(() => category = c),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.primary : Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: isActive ? AppTheme.primary : Colors.white.withOpacity(0.1)),
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

                // Priority
                Text('PRIORITY', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: Colors.white24, letterSpacing: 2)),
                SizedBox(height: 6.h),
                Row(
                  children: ['Low', 'Medium', 'High'].map((p) {
                    final isActive = priority == p;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => priority = p),
                        child: Container(
                          margin: EdgeInsets.only(right: p != 'High' ? 6.w : 0),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: isActive ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1)),
                          ),
                          alignment: Alignment.center,
                          child: Text(p, style: GoogleFonts.outfit(
                            fontSize: 10.sp, fontWeight: FontWeight.w700,
                            color: isActive ? Colors.white : Colors.white24,
                          )),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20.h),

                // Save Button
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
                          if (titleC.text.trim().isEmpty) return;
                          if (existing != null) {
                            setState(() {
                              existing.title = titleC.text.trim();
                              existing.content = contentC.text.trim();
                              existing.category = category;
                              existing.priority = priority;
                            });
                          } else {
                            setState(() {
                              _memos.insert(0, Memo(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                title: titleC.text.trim(),
                                content: contentC.text.trim(),
                                category: category,
                                priority: priority,
                              ));
                            });
                          }
                          _saveMemos();
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFFE85D04)]),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(existing != null ? 'Sync Insight' : 'Commit to Memory',
                            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.sp),
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
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(color: Colors.white12, fontSize: 13.sp),
    filled: true,
    fillColor: Colors.white.withOpacity(0.03),
    contentPadding: EdgeInsets.all(14.w),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.5)),
    ),
  );
}
