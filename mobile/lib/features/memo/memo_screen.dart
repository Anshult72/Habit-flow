import 'package:flutter/material.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../services/memo_service.dart';
import '../../models/memo_model.dart';

// ─── Memo Screen (Second Brain / Cognitive Cache) ───────────────────────────
class MemoScreen extends ConsumerStatefulWidget {
  const MemoScreen({super.key});

  @override
  ConsumerState<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends ConsumerState<MemoScreen> {
  String _searchQuery = '';
  String _activeCategory = 'All';
  final _quickController = TextEditingController();

  static const _categories = ['All', 'Ideas', 'Study', 'Vision', 'Routine', 'Research', 'Business', 'Coding', 'Personal'];

  @override
  void dispose() {
    _quickController.dispose();
    super.dispose();
  }

  void _quickAdd() {
    if (_quickController.text.trim().isEmpty) return;
    ref.read(memosProvider.notifier).addMemo({
      'title': 'Quick Thought',
      'content': _quickController.text.trim(),
      'category': 'Ideas',
      'priority': 'Low',
    });
    _quickController.clear();
  }

  Color _getCategoryColor(String? cat) {
    switch (cat?.toLowerCase()) {
      case 'ideas': return const Color(0xFFE25B20);
      case 'study': return Colors.blueAccent;
      case 'vision': return Colors.purpleAccent;
      case 'routine': return Colors.greenAccent;
      case 'business': return Colors.amberAccent;
      case 'coding': return Colors.cyanAccent;
      case 'research': return Colors.tealAccent;
      case 'personal': return Colors.pinkAccent;
      default: return const Color(0xFF8A8A8A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final memosAsync = ref.watch(memosProvider);

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
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16.sp),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('COGNITIVE CACHE', style: GoogleFonts.outfit(
                          fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2.0,
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
                        gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFFE85D04)]),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            // ─── Hero Quick Capture (Primary Premium Interaction) ───
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF141414),
                      Color(0xFF0C0C0C),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _quickController,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp),
                        decoration: InputDecoration(
                          hintText: 'Quick capture your next idea...',
                          hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 13.sp),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => _quickAdd(),
                      ),
                    ),
                    GestureDetector(
                      onTap: _quickAdd,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h), // Slightly reduced scale
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(8.r), // Reduced corner weight
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Icon(Icons.bolt_rounded, color: Colors.white, size: 14.sp), // Slightly smaller icon
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 50.ms, duration: 400.ms),

            SizedBox(height: 16.h),

            // ─── Search Field (Utility - Full Width) ────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                height: 36.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                ),
                child: TextField(
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12.sp),
                  decoration: InputDecoration(
                    hintText: 'Search thoughts...',
                    hintStyle: GoogleFonts.inter(color: Colors.white12, fontSize: 12.sp),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.white24, size: 14.sp),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            ),

            SizedBox(height: 12.h), // Balanced breathing room

            // ─── Category Filter Chips (Navigation - Full Width Scroll) ──
            SizedBox(
              height: 32.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => SizedBox(width: 6.w),
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final isActive = _activeCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _activeCategory = cat),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.primary : Colors.white.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isActive ? AppTheme.primary : Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(cat, style: GoogleFonts.outfit(
                        fontSize: 10.5.sp, fontWeight: FontWeight.w700,
                        color: isActive ? Colors.white : Colors.white38,
                      )),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20.h),

            // ─── Memos List ─────────────────────────────────────────
            Expanded(
              child: memosAsync.when(
                data: (memos) {
                  final filtered = memos.where((m) {
                    final matchSearch = m.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        m.content.toLowerCase().contains(_searchQuery.toLowerCase());
                    final matchCat = _activeCategory == 'All' || m.category == _activeCategory;
                    return matchSearch && matchCat;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
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
                    );
                  }

                  final pinned = filtered.where((m) => m.isPinned).toList();
                  final others = filtered.where((m) => !m.isPinned).toList();

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    children: [
                      if (pinned.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.push_pin_rounded, size: 12.sp, color: AppTheme.primary),
                            SizedBox(width: 6.w),
                            Text('PRIORITY CACHE', style: GoogleFonts.outfit(
                              fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.white54,
                              letterSpacing: 1.5,
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
                          Text('COGNITIVE CACHE', style: GoogleFonts.outfit(
                            fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.white54,
                            letterSpacing: 1.5,
                          )),
                          Text('${filtered.length} Units', style: GoogleFonts.outfit(
                            fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted,
                            letterSpacing: 1.0,
                          )),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      ...others.map((m) => _buildMemoCard(m)),
                      SizedBox(height: 80.h),
                    ],
                  );
                },
                loading: () => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: const HFShimmerList(height: 100, count: 5),
                ),
                error: (e, _) => HFErrorState(
                  onRetry: () => ref.refresh(memosProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoCard(MemoModel memo) {
    final catColor = _getCategoryColor(memo.category);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF141414), // Premium dark luxury depth
            Color(0xFF0C0C0C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: memo.isPinned ? AppTheme.primary.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            // Subtle left vertical accent strip exclusively for pinned/important notes
            if (memo.isPinned)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3.w,
                  color: AppTheme.primary,
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h), // Optimized card height by ~20%
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Category tag & options menu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: catColor.withValues(alpha: 0.1)),
                        ),
                        child: Text(
                          memo.category?.toUpperCase() ?? 'UNCATEGORIZED',
                          style: GoogleFonts.outfit(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w800,
                            color: catColor,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          if (memo.isPinned) ...[
                            Icon(Icons.push_pin_rounded, size: 11.sp, color: AppTheme.primary),
                            SizedBox(width: 8.w),
                          ],
                          GestureDetector(
                            onTap: () => _showOptionsModal(context, memo),
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.02),
                              ),
                              child: Icon(
                                Icons.more_horiz_rounded,
                                size: 14.sp,
                                color: Colors.white54, // Improved visibility from faint white30
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h), // Tightened top spacing harmony

                  // Title
                  Text(
                    memo.title,
                    style: GoogleFonts.outfit(
                      fontSize: 15.sp, // Tighter and more elegant font size
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 4.h), // Tightened top spacing harmony

                  // Content Body
                  Text(
                    memo.content,
                    style: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      color: const Color(0xFF8A8A8A),
                      height: 1.45,
                    ),
                    maxLines: 3, // Tightened card height for rapid scanning
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 10.h), // Tightened

                  // Date metadata (Clean, micro-sized date)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 10.sp, color: Colors.white12),
                          SizedBox(width: 4.w),
                          Text(
                            '${memo.createdAt.day}/${memo.createdAt.month}/${memo.createdAt.year}',
                            style: GoogleFonts.outfit(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      if (memo.priority?.toLowerCase() == 'high')
                        Container(
                          width: 4.w,
                          height: 4.w,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
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
    ).animate().fadeIn(duration: 300.ms);
  }

  void _showOptionsModal(BuildContext context, MemoModel memo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              memo.title.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: AppTheme.primary,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Icon(Icons.edit_rounded, color: Colors.white70, size: 22.sp),
              title: Text('Refine Insight', style: GoogleFonts.inter(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(ctx);
                _showCreateModal(context, existing: memo);
              },
            ),
            ListTile(
              leading: Icon(Icons.push_pin_rounded, color: memo.isPinned ? AppTheme.primary : Colors.white70, size: 22.sp),
              title: Text(memo.isPinned ? 'Unpin from Memory' : 'Pin Insight', style: GoogleFonts.inter(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500)),
              onTap: () {
                ref.read(memosProvider.notifier).togglePin(memo.id, memo.isPinned);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 22.sp),
              title: Text('Purge from Brain', style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 16.sp, fontWeight: FontWeight.w500)),
              onTap: () {
                ref.read(memosProvider.notifier).removeMemo(memo.id);
                Navigator.pop(ctx);
              },
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  void _showCreateModal(BuildContext context, {MemoModel? existing}) {
    final titleC = TextEditingController(text: existing?.title ?? '');
    final contentC = TextEditingController(text: existing?.content ?? '');
    String category = existing?.category ?? 'Ideas';
    String priority = existing?.priority ?? 'Low';

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85), // Dark luxurious backdrop depth
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          elevation: 0,
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D), // Premium high-density solid-glass dark surface
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 40,
                    spreadRadius: 2,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Header & Minimal Close Trigger
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        existing != null ? 'Refine Memo' : 'Cache Thought',
                        style: GoogleFonts.outfit(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.02),
                          ),
                          child: Icon(Icons.close_rounded, color: Colors.white38, size: 14.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Title Label & Input
                  Text(
                    'Title',
                    style: GoogleFonts.outfit(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  TextField(
                    controller: titleC,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13.5.sp, fontWeight: FontWeight.w600),
                    decoration: _inputDecoration('Title your insight...'),
                  ),
                  SizedBox(height: 12.h), // Spacing tightened

                  // Content Label & Input (Optimized multi-line limit)
                  Text(
                    'Thought',
                    style: GoogleFonts.outfit(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  TextField(
                    controller: contentC,
                    maxLines: 3, // Reduced from 5 to optimize height footprint
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp),
                    decoration: _inputDecoration('Capture your next breakthrough...'),
                  ),
                  SizedBox(height: 12.h),

                  // Category Label & Compact Inline Dropdown Selector
                  Text(
                    'Category',
                    style: GoogleFonts.outfit(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white24,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  PopupMenuButton<String>(
                    tooltip: 'Select Category',
                    color: const Color(0xFF141414), // Matches premium dark luxury depth surface
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    offset: Offset(0, -312.h), // Smart upward offset to avoid controls overlap
                    onSelected: (selected) {
                      setModalState(() {
                        category = selected;
                      });
                    },
                    itemBuilder: (ctx) {
                      return _categories.skip(1).map((cat) { // Skip 'All'
                        final isCurrent = cat == category;
                        return PopupMenuItem<String>(
                          value: cat,
                          height: 38.h,
                          child: Row(
                            children: [
                              Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(cat),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                cat,
                                style: GoogleFonts.outfit(
                                  color: isCurrent ? Colors.white : Colors.white60,
                                  fontSize: 12.5.sp,
                                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(category),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                category,
                                style: GoogleFonts.outfit(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white38, size: 18.sp),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Priority Segmented Selector Upgraded Track
                  Text(
                    'Priority',
                    style: GoogleFonts.outfit(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white24,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                    ),
                    child: Row(
                      children: ['Low', 'Medium', 'High'].map((p) {
                        final isActive = priority == p;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => priority = p),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: isActive ? Colors.white.withValues(alpha: 0.06) : Colors.transparent,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                p,
                                style: GoogleFonts.outfit(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: isActive ? Colors.white : Colors.white24,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Actions Group (Cancel / Commit to Memory)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h), // Height optimized
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            if (titleC.text.trim().isEmpty) return;
                            final data = {
                              'title': titleC.text.trim(),
                              'content': contentC.text.trim(),
                              'category': category,
                              'priority': priority,
                            };
                            if (existing != null) {
                              ref.read(memosProvider.notifier).updateMemo(existing.id, data);
                            } else {
                              ref.read(memosProvider.notifier).addMemo(data);
                            }
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h), // Height optimized
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primary, Color(0xFFE25B20)], // Premium warm tones
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              existing != null ? 'Sync Insight' : 'Commit to Memory',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5.sp,
                              ),
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
      ),
    );
  }



  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(color: Colors.white12, fontSize: 13.sp),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.02),
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h), // Height optimized
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.4)),
    ),
  );
}
