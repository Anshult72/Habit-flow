import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

class WishItem {
  final String id;
  String title, category, link;
  double targetPrice, currentSavings;
  String status;

  WishItem({required this.id, required this.title, this.category = 'Tech',
    this.targetPrice = 0, this.currentSavings = 0, this.link = '', this.status = 'Active'});

  double get progress => targetPrice > 0 ? (currentSavings / targetPrice * 100).clamp(0, 100) : 0;

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'category': category,
    'targetPrice': targetPrice, 'currentSavings': currentSavings, 'link': link, 'status': status};

  factory WishItem.fromJson(Map<String, dynamic> j) => WishItem(id: j['id'], title: j['title'],
    category: j['category'] ?? 'Tech', targetPrice: (j['targetPrice'] ?? 0).toDouble(),
    currentSavings: (j['currentSavings'] ?? 0).toDouble(), link: j['link'] ?? '', status: j['status'] ?? 'Active');
}

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});
  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  List<WishItem> _items = [];
  String _activeCategory = 'All';
  final _cats = ['All', 'Tech', 'Gaming', 'Fitness', 'Vehicle', 'Education', 'Lifestyle'];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final r = p.getString('habitflow-wishlist');
    if (r != null) { setState(() => _items = (jsonDecode(r) as List).map((e) => WishItem.fromJson(e)).toList()); }
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('habitflow-wishlist', jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  List<WishItem> get _filtered => _items.where((i) => _activeCategory == 'All' || i.category == _activeCategory).toList();

  @override
  Widget build(BuildContext context) {
    final total = _items.fold<double>(0, (s, i) => s + i.targetPrice);
    final saved = _items.fold<double>(0, (s, i) => s + i.currentSavings);
    final pct = total > 0 ? (saved / total * 100).round() : 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(child: Column(children: [
        // Header
        Padding(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h), child: Row(children: [
          GestureDetector(onTap: () => Navigator.pop(context), child: Container(
            padding: EdgeInsets.all(8.w), decoration: BoxDecoration(color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppTheme.surfaceBorder)),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp))),
          SizedBox(width: 16.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ACQUISITION PROTOCOL', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2.5)),
            Text('Life Vault', style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white)),
          ])),
          GestureDetector(onTap: () => _showAddModal(), child: Container(
            padding: EdgeInsets.all(10.w), decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFFE85D04)]),
              borderRadius: BorderRadius.circular(12.r)),
            child: Icon(Icons.add_rounded, color: Colors.white, size: 22.sp))),
        ])).animate().fadeIn(duration: 400.ms),

        // Stats
        Padding(padding: EdgeInsets.symmetric(horizontal: 20.w), child: Container(
          padding: EdgeInsets.all(12.w), decoration: BoxDecoration(color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16.r), border: Border.all(color: AppTheme.surfaceBorder)),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('TOTAL', style: GoogleFonts.outfit(fontSize: 8.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1.5)),
              Text('₹${total.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.w800, color: Colors.white)),
            ]),
            SizedBox(width: 16.w),
            Container(width: 1, height: 30.h, color: Colors.white10),
            SizedBox(width: 16.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PROGRESS', style: GoogleFonts.outfit(fontSize: 8.sp, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1.5)),
              Row(children: [
                Text('$pct%', style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                SizedBox(width: 8.w),
                Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(value: pct / 100, backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: AlwaysStoppedAnimation(AppTheme.primary), minHeight: 4.h))),
              ]),
            ])),
          ]))),

        SizedBox(height: 12.h),

        // Categories
        SizedBox(height: 36.h, child: ListView.separated(scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20.w), itemCount: _cats.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (_, i) {
            final c = _cats[i]; final a = _activeCategory == c;
            return GestureDetector(onTap: () => setState(() => _activeCategory = c),
              child: Container(padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(color: a ? AppTheme.primary : Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(10.r), border: Border.all(color: a ? AppTheme.primary : Colors.white.withOpacity(0.1))),
                alignment: Alignment.center,
                child: Text(c, style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.w700, color: a ? Colors.white : Colors.white38))));
          })),

        SizedBox(height: 12.h),

        // Items
        Expanded(child: _filtered.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.rocket_launch_rounded, size: 48.sp, color: Colors.white10),
              SizedBox(height: 12.h),
              Text('No Life Goals Initialized.', style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white)),
            ]))
          : ListView.builder(padding: EdgeInsets.symmetric(horizontal: 20.w), itemCount: _filtered.length,
              itemBuilder: (_, i) => _buildCard(_filtered[i], i))),
      ])),
    );
  }

  Widget _buildCard(WishItem item, int index) {
    final acquired = item.status == 'Acquired';
    return Container(margin: EdgeInsets.only(bottom: 16.h), decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: acquired ? Colors.green.withOpacity(0.3) : AppTheme.surfaceBorder)),
      child: Padding(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(6.r)),
            child: Text(item.category, style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w700, color: AppTheme.primary, letterSpacing: 1))),
          if (acquired) Icon(Icons.check_circle_rounded, size: 18.sp, color: Colors.green),
        ]),
        SizedBox(height: 10.h),
        Text(item.title, style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.w800, color: Colors.white)),
        SizedBox(height: 4.h),
        Text('₹${item.targetPrice.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.primary)),
        SizedBox(height: 12.h),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('VAULT STATUS', style: GoogleFonts.outfit(fontSize: 8.sp, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 1.5)),
          Text('${item.progress.round()}%', style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w800, color: acquired ? Colors.green : AppTheme.primary)),
        ]),
        SizedBox(height: 6.h),
        ClipRRect(borderRadius: BorderRadius.circular(6.r),
          child: LinearProgressIndicator(value: item.progress / 100, minHeight: 8.h,
            backgroundColor: Colors.white.withOpacity(0.05),
            valueColor: AlwaysStoppedAnimation(acquired ? Colors.green : AppTheme.primary))),
        SizedBox(height: 6.h),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Saved: ₹${item.currentSavings.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
          Text('Rem: ₹${(item.targetPrice - item.currentSavings).toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
        ]),
        SizedBox(height: 12.h),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            GestureDetector(onTap: () { setState(() => _items.removeWhere((x) => x.id == item.id)); _save(); },
              child: Container(padding: EdgeInsets.all(8.w), decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(10.r)),
                child: Icon(Icons.delete_rounded, size: 16.sp, color: Colors.white24))),
          ]),
          GestureDetector(onTap: acquired ? null : () => _showSavingsModal(item),
            child: Container(padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(color: acquired ? Colors.green.withOpacity(0.1) : AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r), border: Border.all(color: acquired ? Colors.green.withOpacity(0.3) : AppTheme.primary.withOpacity(0.3))),
              child: Text(acquired ? 'Acquired' : 'Sync Savings', style: GoogleFonts.outfit(
                fontSize: 10.sp, fontWeight: FontWeight.w800, color: acquired ? Colors.green : AppTheme.primary, letterSpacing: 1)))),
        ]),
      ])),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms);
  }

  void _showSavingsModal(WishItem item) {
    final c = TextEditingController();
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (ctx) => Container(
      padding: EdgeInsets.all(24.w), decoration: BoxDecoration(color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Sync Savings', style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white)),
        SizedBox(height: 4.h),
        Text(item.title, style: GoogleFonts.inter(fontSize: 13.sp, color: AppTheme.textMuted)),
        SizedBox(height: 20.h),
        TextField(controller: c, keyboardType: TextInputType.number, autofocus: true,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.w800),
          decoration: InputDecoration(prefixText: '₹ ', prefixStyle: GoogleFonts.outfit(color: AppTheme.primary, fontSize: 28.sp, fontWeight: FontWeight.w800),
            hintText: '0', hintStyle: GoogleFonts.outfit(color: Colors.white10, fontSize: 28.sp),
            filled: true, fillColor: Colors.white.withOpacity(0.03), contentPadding: EdgeInsets.all(16.w),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.5))))),
        SizedBox(height: 16.h),
        Row(children: [
          Expanded(child: GestureDetector(onTap: () => Navigator.pop(ctx), child: Container(
            padding: EdgeInsets.symmetric(vertical: 14.h), decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.1)), borderRadius: BorderRadius.circular(14.r)),
            alignment: Alignment.center, child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600))))),
          SizedBox(width: 12.w),
          Expanded(flex: 2, child: GestureDetector(onTap: () {
            final amt = double.tryParse(c.text) ?? 0;
            if (amt <= 0) return;
            setState(() {
              item.currentSavings += amt;
              if (item.currentSavings >= item.targetPrice) item.status = 'Acquired';
            });
            _save(); Navigator.pop(ctx);
          }, child: Container(padding: EdgeInsets.symmetric(vertical: 14.h), decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFFE85D04)]),
            borderRadius: BorderRadius.circular(14.r)),
            alignment: Alignment.center, child: Text('Sync', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700))))),
        ]),
        SizedBox(height: 16.h),
      ])));
  }

  void _showAddModal() {
    final titleC = TextEditingController();
    final priceC = TextEditingController();
    String cat = 'Tech';

    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          border: Border.all(color: Colors.white.withOpacity(0.1))),
        padding: EdgeInsets.all(24.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2.r)))),
          SizedBox(height: 20.h),
          Text('Initialize Target', style: GoogleFonts.outfit(fontSize: 24.sp, fontWeight: FontWeight.w800, color: Colors.white)),
          SizedBox(height: 20.h),
          TextField(controller: titleC, style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
            decoration: _inputDeco('e.g., MacBook Pro M3 Max')),
          SizedBox(height: 12.h),
          TextField(controller: priceC, keyboardType: TextInputType.number,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
            decoration: _inputDeco('Target Price (₹)')),
          SizedBox(height: 12.h),
          Wrap(spacing: 6.w, runSpacing: 6.h, children: ['Tech', 'Gaming', 'Fitness', 'Vehicle', 'Education', 'Lifestyle'].map((c2) {
            final a = cat == c2;
            return GestureDetector(onTap: () => ss(() => cat = c2), child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(color: a ? AppTheme.primary : Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(10.r)),
              child: Text(c2, style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w700, color: a ? Colors.white : Colors.white38))));
          }).toList()),
          const Spacer(),
          GestureDetector(onTap: () {
            if (titleC.text.trim().isEmpty) return;
            setState(() => _items.add(WishItem(id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: titleC.text.trim(), targetPrice: double.tryParse(priceC.text) ?? 0, category: cat)));
            _save(); Navigator.pop(ctx);
          }, child: Container(width: double.infinity, padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFFE85D04)]),
              borderRadius: BorderRadius.circular(16.r)),
            alignment: Alignment.center, child: Text('Deploy Target', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.sp)))),
        ]))));
  }

  InputDecoration _inputDeco(String h) => InputDecoration(hintText: h, hintStyle: GoogleFonts.inter(color: Colors.white12, fontSize: 13.sp),
    filled: true, fillColor: Colors.white.withOpacity(0.03), contentPadding: EdgeInsets.all(14.w),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.5))));
}
