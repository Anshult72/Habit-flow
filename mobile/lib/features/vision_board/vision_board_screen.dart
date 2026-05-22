import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';

class VisionItem {
  final String id;
  String title;
  String category;
  bool completed;
  String imageUrl;
  String? targetDate;
  String? affirmation;

  VisionItem({
    required this.id,
    required this.title,
    this.category = 'Life',
    this.completed = false,
    required this.imageUrl,
    this.targetDate,
    this.affirmation,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'completed': completed,
        'imageUrl': imageUrl,
        'targetDate': targetDate,
        'affirmation': affirmation,
      };

  factory VisionItem.fromJson(Map<String, dynamic> j) => VisionItem(
        id: j['id'],
        title: j['title'],
        category: j['category'] ?? 'Life',
        completed: j['completed'] ?? false,
        imageUrl: j['imageUrl'] ?? '',
        targetDate: j['targetDate'],
        affirmation: j['affirmation'],
      );
}

class VisionBoardScreen extends StatefulWidget {
  const VisionBoardScreen({super.key});

  @override
  State<VisionBoardScreen> createState() => _VisionBoardScreenState();
}

class _VisionBoardScreenState extends State<VisionBoardScreen> {
  List<VisionItem> _items = [];
  final _cats = ['Life', 'Career', 'Health', 'Travel', 'Finance', 'Relationships'];

  // Predefined templates
  final List<Map<String, String>> _templates = [
    {
      'name': 'Tokyo Penthouse',
      'url': 'https://images.unsplash.com/photo-1504917595217-d4dc5ebe6122?q=80&w=600&auto=format&fit=crop'
    },
    {
      'name': 'Porsche GT3',
      'url': 'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?q=80&w=600&auto=format&fit=crop'
    },
    {
      'name': 'Amalfi Sanctuary',
      'url': 'https://images.unsplash.com/photo-1533105079780-92b9be482077?q=80&w=600&auto=format&fit=crop'
    },
    {
      'name': 'Peak Physique',
      'url': 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=600&auto=format&fit=crop'
    },
    {
      'name': 'Alpine Cabin',
      'url': 'https://images.unsplash.com/photo-1510312305653-8ed496efae75?q=80&w=600&auto=format&fit=crop'
    },
    {
      'name': 'Luxury Watch',
      'url': 'https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3?q=80&w=600&auto=format&fit=crop'
    },
    {
      'name': 'High-Tech Setup',
      'url': 'https://images.unsplash.com/photo-1547082299-de196ea013d6?q=80&w=600&auto=format&fit=crop'
    },
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final r = p.getString('habitflow-vision');
    if (r != null) {
      setState(() {
        _items = (jsonDecode(r) as List).map((e) => VisionItem.fromJson(e)).toList();
      });
    } else {
      // First-time load: pre-populate with premium aspirational dreams
      setState(() {
        _items = [
          VisionItem(
            id: 'd1',
            title: 'Minimalist Tokyo Penthouse Office',
            category: 'Career',
            imageUrl: 'https://images.unsplash.com/photo-1504917595217-d4dc5ebe6122?q=80&w=600&auto=format&fit=crop',
            targetDate: 'Oct 2027',
            affirmation: 'My workspace is a temple of absolute focus and high intellect.',
          ),
          VisionItem(
            id: 'd2',
            title: 'Porsche 911 GT3 RS (Chalk Gray)',
            category: 'Finance',
            imageUrl: 'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?q=80&w=600&auto=format&fit=crop',
            targetDate: 'May 2028',
            affirmation: 'I drive toward absolute precision, freedom, and excellence.',
          ),
          VisionItem(
            id: 'd3',
            title: 'Serene Amalfi Coast Sanctuary',
            category: 'Travel',
            imageUrl: 'https://images.unsplash.com/photo-1533105079780-92b9be482077?q=80&w=600&auto=format&fit=crop',
            targetDate: 'Aug 2026',
            affirmation: 'I design a life of profound peace, beauty, and quiet luxury.',
          ),
          VisionItem(
            id: 'd4',
            title: 'Peak Aesthetic Hybrid Physique',
            category: 'Health',
            imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=600&auto=format&fit=crop',
            targetDate: 'Dec 2026',
            affirmation: 'My body is a high-performance vessel of strength and daily stamina.',
          ),
        ];
      });
      _save();
    }
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('habitflow-vision', jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark luxury theme
      body: SafeArea(
        child: Stack(
          children: [
            // Volumetric ambient top blur for luxury depth
            Positioned(
              top: -150.h,
              right: -100.w,
              child: Container(
                width: 350.w,
                height: 350.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.04),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.04),
                      blurRadius: 120,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),

            Column(
              children: [
                // Header Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 16.sp),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VISUALIZATION',
                              style: GoogleFonts.outfit(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primary,
                                letterSpacing: 2.5,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Text(
                              'Vision Board',
                              style: GoogleFonts.outfit(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _addItem,
                        child: Container(
                          padding: EdgeInsets.all(8.w), // 10% lighter footprint
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, Color(0xFFE25B20)],
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(Icons.add_rounded, color: Colors.white, size: 16.sp), // Smaller premium scale
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),

                // Top Premium Stats Row
                if (_items.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.02), // Premium subtle glass look
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(Icons.whatshot_rounded, '27 Day Streak', isHighlighted: true),
                          _buildStatDivider(),
                          _buildStatItem(Icons.track_changes_rounded, '${_items.where((i) => !i.completed).length} Active Focus'),
                          _buildStatDivider(),
                          _buildStatItem(Icons.auto_awesome_rounded, '${_items.length} Dreams Locked'),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                SizedBox(height: 12.h),

                // Staggered Grid Content
                Expanded(
                  child: _items.isEmpty
                      ? _buildEmptyState()
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: _buildStaggeredGrid(),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, {bool isHighlighted = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 11.sp,
          color: isHighlighted ? AppTheme.primary : Colors.white38,
        ),
        SizedBox(width: 4.w),
        Text(
          text,
          style: GoogleFonts.outfit(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w700,
            color: isHighlighted ? Colors.white : Colors.white60,
            letterSpacing: 0.2,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 4.w,
      height: 4.w,
      decoration: const BoxDecoration(
        color: Colors.white24,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.02),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Icon(Icons.blur_on_rounded, size: 40.sp, color: AppTheme.primary.withValues(alpha: 0.8)),
            ),
            SizedBox(height: 20.h),
            Text(
              'Your future deserves a visual form.',
              style: GoogleFonts.outfit(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              'Build the life you want to see daily. Lock down your visual goals and let priority motivate your planning.',
              style: GoogleFonts.inter(
                fontSize: 12.5.sp,
                color: AppTheme.textMuted,
                height: 1.45,
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: _addItem,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, Color(0xFFE25B20)],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Add First Vision',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildStaggeredGrid() {
    final leftList = <Widget>[];
    final rightList = <Widget>[];

    for (int i = 0; i < _items.length; i++) {
      final double cardHeight = i % 2 == 0 ? 190.h : 230.h;
      final cardWidget = _buildVisionCard(_items[i], i, cardHeight);

      if (i % 2 == 0) {
        leftList.add(cardWidget);
      } else {
        rightList.add(cardWidget);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftList,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            children: rightList,
          ),
        ),
      ],
    );
  }

  Widget _buildVisionCardImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFF111111),
          alignment: Alignment.center,
          child: Icon(Icons.image_not_supported_rounded, color: Colors.white24, size: 28.sp),
        ),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFF111111),
          alignment: Alignment.center,
          child: Icon(Icons.image_not_supported_rounded, color: Colors.white24, size: 28.sp),
        ),
      );
    }
  }

  Widget _buildVisionCard(VisionItem item, int index, double height) {
    final catColors = {
      'Life': const Color(0xFFFF6B2C),
      'Career': const Color(0xFF3B82F6),
      'Health': const Color(0xFF10B981),
      'Travel': const Color(0xFFA855F7),
      'Finance': const Color(0xFFFFD700),
      'Relationships': const Color(0xFFEC4899)
    };
    final color = catColors[item.category] ?? AppTheme.primary;

    return GestureDetector(
      onTap: () => _openFullscreenViewer(index),
      onLongPress: () => _showOptions(item),
      child: Container(
        height: height,
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: item.completed ? color.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Immersive visual image background (Unified dynamic Web / Local File render)
              _buildVisionCardImage(item.imageUrl),

              // Cinematic Dark Overlay Layer with Stronger Bottom Density
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.95), // Extra-dense dark baseline for maximum contrast
                    ],
                    stops: const [0.0, 0.45, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Completed Glowing Tint Overlay
              if (item.completed)
                Container(
                  color: color.withValues(alpha: 0.15),
                ),

              // Completed indicator Badge
              if (item.completed)
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'MANIFESTED',
                      style: GoogleFonts.outfit(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.0,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),

              // Card Textual Parameters
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        item.category.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 7.5.sp,
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: 1.0,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      item.title,
                      style: GoogleFonts.outfit(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.25,
                        decoration: TextDecoration.none,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.targetDate != null && item.targetDate!.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 9.sp, color: Colors.white38),
                          SizedBox(width: 4.w),
                          Text(
                            item.targetDate!,
                            style: GoogleFonts.inter(
                              fontSize: 9.sp,
                              color: Colors.white38,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms);
  }

  void _showOptions(VisionItem item) {
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
              item.title.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: AppTheme.primary,
                letterSpacing: 2,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Icon(
                item.completed ? Icons.radio_button_unchecked_rounded : Icons.check_circle_rounded,
                color: Colors.white70,
                size: 22.sp,
              ),
              title: Text(
                item.completed ? 'Mark Active' : 'Mark as Manifested',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                setState(() {
                  item.completed = !item.completed;
                });
                _save();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 22.sp),
              title: Text(
                'Purge Dream',
                style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                setState(() {
                  _items.removeWhere((x) => x.id == item.id);
                });
                _save();
                Navigator.pop(ctx);
              },
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  void _openFullscreenViewer(int initialIndex) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.95),
        pageBuilder: (context, _, __) {
          final pageController = PageController(initialPage: initialIndex);
          // Wrapped inside Scaffold to eradicate any possibilities of yellow platform underlines
          return Scaffold(
            backgroundColor: Colors.black,
            body: StatefulBuilder(
              builder: (context, setViewerState) => Stack(
                fit: StackFit.expand,
                children: [
                  // Horizontal Swiper
                  PageView.builder(
                    controller: pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _items.length,
                    itemBuilder: (ctx, idx) {
                      final item = _items[idx];
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          // Dynamic rendering: Network vs File Image
                          item.imageUrl.startsWith('http')
                              ? Image.network(
                                  item.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: Colors.black),
                                )
                              : Image.file(
                                  File(item.imageUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: Colors.black),
                                ),

                          // Cinematic overall dark tint + strong bottom gradient vignette
                          Container(
                            color: Colors.black.withValues(alpha: 0.25),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black54,
                                  Colors.black, // Fully black bottom for absolute readability
                                ],
                                stops: [0.0, 0.45, 1.0],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),

                          // Affirmations & Metadata (Bottom Position)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6.r),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                                    ),
                                    child: Text(
                                      item.category.toUpperCase(),
                                      style: GoogleFonts.outfit(
                                        fontSize: 8.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 1.5,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 14.h),
                                  Text(
                                    item.title,
                                    style: GoogleFonts.outfit(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w800, // Cinematic strong bold title
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                      decoration: TextDecoration.none,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (item.affirmation != null && item.affirmation!.isNotEmpty) ...[
                                    SizedBox(height: 12.h),
                                    Text(
                                      '"${item.affirmation!}"',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5.sp,
                                        fontStyle: FontStyle.italic, // Refined soft affirmation
                                        color: Colors.white60,
                                        height: 1.45,
                                        decoration: TextDecoration.none,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                  if (item.targetDate != null && item.targetDate!.isNotEmpty) ...[
                                    SizedBox(height: 14.h),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.calendar_today_rounded, size: 9.sp, color: Colors.white38),
                                        SizedBox(width: 4.w),
                                        Text(
                                          'TARGET TIME: ${item.targetDate!.toUpperCase()}', // Minimalist metadata
                                          style: GoogleFonts.outfit(
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white38,
                                            letterSpacing: 1.5,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],

                                  // Subtly integrated premium visual Action Bar
                                  SizedBox(height: 24.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildViewerAction(Icons.bolt_rounded, 'Motivation Hit'),
                                      SizedBox(width: 12.w),
                                      _buildViewerAction(Icons.link_rounded, 'Link to Goal'),
                                      SizedBox(width: 12.w),
                                      _buildViewerAction(Icons.explore_rounded, 'View Mission'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Floating Close Button (Top Left)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16.h,
                    left: 20.w,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded, color: Colors.white, size: 20.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildViewerAction(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.sp, color: AppTheme.primary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
              letterSpacing: 0.2,
              decoration: TextDecoration.none, // Explicitly no underlines
            ),
          ),
        ],
      ),
    );
  }

  void _addItem() {
    final tc = TextEditingController();
    final ac = TextEditingController();
    final dc = TextEditingController();
    String cat = 'Life';
    String selectedUrl = _templates.first['url']!;
    String? customImagePath;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: SingleChildScrollView(
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D0D),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lock New Vision',
                          style: GoogleFonts.outfit(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                            decoration: TextDecoration.none,
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

                    // Image Selection Title
                    Text(
                      'Visual Template',
                      style: GoogleFonts.outfit(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white24,
                        letterSpacing: 1.0,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    SizedBox(
                      height: 52.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _templates.length + 1, // Prepend custom picker
                        separatorBuilder: (_, __) => SizedBox(width: 8.w),
                        itemBuilder: (_, i) {
                          if (i == 0) {
                            // Upload Own Option Item
                            final isCustomSelected = customImagePath != null && selectedUrl == customImagePath;
                            return GestureDetector(
                              onTap: () async {
                                final picker = ImagePicker();
                                final image = await picker.pickImage(source: ImageSource.gallery);
                                if (image != null) {
                                  ss(() {
                                    customImagePath = image.path;
                                    selectedUrl = image.path;
                                  });
                                }
                              },
                              child: Container(
                                width: 80.w,
                                decoration: BoxDecoration(
                                  color: isCustomSelected ? AppTheme.primary.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.02),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: isCustomSelected ? AppTheme.primary : Colors.white10,
                                    width: isCustomSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_rounded, size: 16.sp, color: isCustomSelected ? AppTheme.primary : Colors.white54),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'Upload Own',
                                      style: GoogleFonts.outfit(
                                        fontSize: 8.sp,
                                        fontWeight: FontWeight.w800,
                                        color: isCustomSelected ? Colors.white : Colors.white54,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Predefined templates
                          final temp = _templates[i - 1];
                          final isSelected = selectedUrl == temp['url'] && customImagePath == null;
                          return GestureDetector(
                            onTap: () => ss(() {
                              selectedUrl = temp['url']!;
                              customImagePath = null;
                            }),
                            child: Container(
                              width: 80.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: isSelected ? AppTheme.primary : Colors.white10,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(temp['url']!, fit: BoxFit.cover),
                                    Container(color: Colors.black26),
                                    Center(
                                      child: Text(
                                        temp['name']!,
                                        style: GoogleFonts.outfit(
                                          fontSize: 8.5.sp,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          decoration: TextDecoration.none,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Selected Custom Image Thumbnail preview
                    if (customImagePath != null) ...[
                      SizedBox(height: 12.h),
                      Center(
                        child: Container(
                          height: 100.h,
                          width: 160.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5), width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14.r),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(File(customImagePath!), fit: BoxFit.cover),
                                Positioned(
                                  top: 6.h,
                                  right: 6.w,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle_rounded, size: 8.sp, color: AppTheme.primary),
                                        SizedBox(width: 3.w),
                                        Text(
                                          'SELECTED',
                                          style: GoogleFonts.outfit(
                                            fontSize: 7.sp,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 12.h),

                    // Title Label & Input
                    Text(
                      'Vision Title',
                      style: GoogleFonts.outfit(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                        letterSpacing: 1.0,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: tc,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13.5.sp, fontWeight: FontWeight.w600),
                      decoration: _inputDecoration('e.g., Porsche 911 GT3 RS...'),
                    ),
                    SizedBox(height: 12.h),

                    // Affirmation
                    Text(
                      'Daily Affirmation',
                      style: GoogleFonts.outfit(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                        letterSpacing: 1.0,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: ac,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp),
                      decoration: _inputDecoration('e.g., I drive toward my absolute potential...'),
                    ),
                    SizedBox(height: 12.h),

                    // Category Selector Trigger (Inline anchored Dropdown)
                    Text(
                      'Category',
                      style: GoogleFonts.outfit(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white24,
                        letterSpacing: 1.0,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    PopupMenuButton<String>(
                      tooltip: 'Select Category',
                      color: const Color(0xFF141414),
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      offset: Offset(0, -250.h),
                      onSelected: (selected) {
                        ss(() {
                          cat = selected;
                        });
                      },
                      itemBuilder: (ctx) {
                        return _cats.map((c) {
                          final isCurrent = c == cat;
                          return PopupMenuItem<String>(
                            value: c,
                            height: 38.h,
                            child: Text(
                              c,
                              style: GoogleFonts.outfit(
                                color: isCurrent ? Colors.white : Colors.white60,
                                fontSize: 12.5.sp,
                                fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                                decoration: TextDecoration.none,
                              ),
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
                            Text(
                              cat,
                              style: GoogleFonts.outfit(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white38, size: 18.sp),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Target Date
                    Text(
                      'Target Timeline',
                      style: GoogleFonts.outfit(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white24,
                        letterSpacing: 1.0,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: dc,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp),
                      decoration: _inputDecoration('e.g., Dec 2027...'),
                    ),
                    SizedBox(height: 20.h),

                    // Actions (Cancel / Lock This Vision)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
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
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: isSaving
                                ? null
                                : () async {
                                    if (tc.text.trim().isEmpty) return;
                                    ss(() {
                                      isSaving = true;
                                    });

                                    final newItem = VisionItem(
                                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                                      title: tc.text.trim(),
                                      category: cat,
                                      imageUrl: selectedUrl,
                                      targetDate: dc.text.trim(),
                                      affirmation: ac.text.trim(),
                                    );

                                    // Capture scaffold messenger before any asynchronous wait calls to satisfy safety rules
                                    final messenger = ScaffoldMessenger.of(context);

                                    // Instantly update parent screen state (Optimistic save UI)
                                    setState(() {
                                      _items.add(newItem);
                                    });

                                    Navigator.pop(ctx); // Close Dialog immediately

                                    try {
                                      await _save(); // Reliable background SharedPreferences write
                                      messenger.showSnackBar(
                                        SnackBar(
                                          backgroundColor: const Color(0xFF161616),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12.r),
                                            side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                                          ),
                                          content: Row(
                                            children: [
                                              Icon(Icons.auto_awesome_rounded, color: AppTheme.primary, size: 16.sp),
                                              SizedBox(width: 8.w),
                                              Text(
                                                'Vision Locked to Future Timeline',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      // On save error: rollback locally and show error message
                                      setState(() {
                                        _items.removeWhere((item) => item.id == newItem.id);
                                      });
                                      messenger.showSnackBar(
                                        SnackBar(
                                          backgroundColor: const Color(0xFF2C1111),
                                          content: Text('Failed to lock vision: $e', style: const TextStyle(color: Colors.redAccent)),
                                        ),
                                      );
                                    }
                                  },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppTheme.primary, Color(0xFFE25B20)],
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
                              child: isSaving
                                  ? SizedBox(
                                      height: 16.w,
                                      width: 16.w,
                                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      'Lock This Vision',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.5.sp,
                                        decoration: TextDecoration.none,
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
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.white12, fontSize: 13.sp),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.02),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
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
