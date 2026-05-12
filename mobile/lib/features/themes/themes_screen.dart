import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class _ThemeOption { final String name, desc; final Color primary, bg, surface; final bool active, locked;
  const _ThemeOption(this.name, this.desc, this.primary, this.bg, this.surface, {this.active = false, this.locked = false});
}

const _themes = [
  _ThemeOption('Obsidian', 'Default dark theme', Color(0xFFFF6B2C), Color(0xFF050505), Color(0xFF0A0A0A), active: true),
  _ThemeOption('Midnight Blue', 'Deep ocean vibes', Color(0xFF3B82F6), Color(0xFF0A0F1A), Color(0xFF101828)),
  _ThemeOption('Emerald', 'Forest green energy', Color(0xFF10B981), Color(0xFF051210), Color(0xFF0A1F1A)),
  _ThemeOption('Amethyst', 'Royal purple focus', Color(0xFFA855F7), Color(0xFF0F0520), Color(0xFF1A0A30)),
  _ThemeOption('Crimson', 'Bold red intensity', Color(0xFFEF4444), Color(0xFF0F0505), Color(0xFF1A0A0A)),
  _ThemeOption('Sunset', 'Warm golden glow', Color(0xFFF59E0B), Color(0xFF0F0A05), Color(0xFF1A140A)),
  _ThemeOption('Sakura', 'Soft pink aesthetic', Color(0xFFEC4899), Color(0xFF0F050A), Color(0xFF1A0A14), locked: true),
  _ThemeOption('Arctic', 'Cool ice white', Color(0xFF06B6D4), Color(0xFF050A0F), Color(0xFF0A141A), locked: true),
  _ThemeOption('Gold', 'Premium golden class', Color(0xFFFFD700), Color(0xFF0F0D05), Color(0xFF1A180A), locked: true),
];

class ThemesScreen extends StatefulWidget {
  const ThemesScreen({super.key});
  @override
  State<ThemesScreen> createState() => _ThemesScreenState();
}

class _ThemesScreenState extends State<ThemesScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppTheme.background, body: SafeArea(child: Column(children: [
      // Header
      Padding(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h), child: Row(children: [
        GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppTheme.surfaceBorder)),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp))),
        SizedBox(width: 16.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('APPEARANCE', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2.5)),
          Text('Themes', style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white)),
        ])),
      ])).animate().fadeIn(duration: 400.ms),

      // Preview
      Padding(padding: EdgeInsets.symmetric(horizontal: 20.w), child: Container(
        padding: EdgeInsets.all(16.w), height: 120.h,
        decoration: BoxDecoration(color: _themes[_selected].bg, borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: _themes[_selected].primary.withValues(alpha: 0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(width: 8.w, height: 8.w, decoration: BoxDecoration(shape: BoxShape.circle, color: _themes[_selected].primary)),
            SizedBox(width: 8.w),
            Text(_themes[_selected].name, style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
          ]),
          Row(children: List.generate(5, (i) => Container(
            width: 28.w, height: 28.w, margin: EdgeInsets.only(right: 6.w),
            decoration: BoxDecoration(color: _themes[_selected].surface, borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: _themes[_selected].primary.withValues(alpha: 0.2))),
            child: i == 0 ? Icon(Icons.bolt_rounded, size: 14.sp, color: _themes[_selected].primary) : null))),
          ClipRRect(borderRadius: BorderRadius.circular(4.r), child: LinearProgressIndicator(
            value: 0.72, minHeight: 4.h, backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: AlwaysStoppedAnimation(_themes[_selected].primary))),
        ]))).animate().fadeIn(delay: 100.ms, duration: 400.ms),

      SizedBox(height: 16.h),

      // Themes Grid
      Expanded(child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12.h, crossAxisSpacing: 12.w, childAspectRatio: 0.8),
        itemCount: _themes.length,
        itemBuilder: (_, i) => _themeCard(_themes[i], i),
      )),
    ])));
  }

  Widget _themeCard(_ThemeOption t, int index) {
    final sel = _selected == index;
    return GestureDetector(
      onTap: t.locked ? null : () => setState(() => _selected = index),
      child: Container(decoration: BoxDecoration(
        color: t.bg, borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: sel ? t.primary : Colors.white.withValues(alpha: 0.05), width: sel ? 2 : 1)),
        child: Stack(children: [
          Padding(padding: EdgeInsets.all(12.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              // Color dot
              Row(children: [
                Container(width: 16.w, height: 16.w, decoration: BoxDecoration(shape: BoxShape.circle, color: t.primary,
                  boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.4), blurRadius: 6)])),
                if (sel) ...[SizedBox(width: 4.w), Icon(Icons.check_rounded, size: 12.sp, color: t.primary)],
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.name, style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.white),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(t.desc, style: GoogleFonts.inter(fontSize: 8.sp, color: Colors.white38),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ])),
          if (t.locked) Positioned.fill(child: Container(
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(16.r)),
            child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.lock_rounded, size: 18.sp, color: Colors.white24),
              SizedBox(height: 2.h),
              Text('LVL 25+', style: GoogleFonts.outfit(fontSize: 8.sp, fontWeight: FontWeight.w700, color: Colors.white24, letterSpacing: 1)),
            ])))),
        ])),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms);
  }
}
