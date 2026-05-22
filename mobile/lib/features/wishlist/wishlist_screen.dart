import 'package:flutter/material.dart';
import '../../core/widgets/hf_premium_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../models/wishlist_model.dart';
import '../../services/wishlist_service.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  @override
  Widget build(BuildContext context) {
    final wishlistAsync = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient Luxury Atmospheric Glows
            Positioned(
              top: -150.h,
              right: -100.w,
              child: Container(
                width: 350.w,
                height: 350.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE25B20).withValues(alpha: 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE25B20).withValues(alpha: 0.03),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),

            Column(
              children: [
                // Top Nav Header (Premium DREAM PROTOCOL branding)
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
                          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16.sp),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DREAM PROTOCOL',
                              style: GoogleFonts.outfit(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFE25B20),
                                letterSpacing: 2.5,
                              ),
                            ),
                            Text(
                              'Wish Vault',
                              style: GoogleFonts.outfit(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Plus Button Polish (Refined by an additional 5-8% for premium subtlety)
                      GestureDetector(
                        onTap: () => _showAddModal(),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE25B20).withValues(alpha: 0.12), width: 0.6),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE25B20).withValues(alpha: 0.04),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: Icon(Icons.add_rounded, color: const Color(0xFFE25B20), size: 16.sp),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),

                // Overall Vault Balance & Funding banner (Emotional Refinements)
                wishlistAsync.when(
                  data: (items) {
                    final total = items.fold<double>(0, (s, i) => s + i.targetPrice);
                    final saved = items.fold<double>(0, (s, i) => s + i.currentSavings);
                    final pct = total > 0 ? (saved / total * 100).round() : 0;

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF141414), Color(0xFF0C0C0C)],
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TOTAL SAVED',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white30,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '₹${saved.toStringAsFixed(0)}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 24.w),
                            Container(width: 1, height: 32.h, color: Colors.white.withValues(alpha: 0.05)),
                            SizedBox(width: 24.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'WISH PROGRESS',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 8.sp,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white30,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      Text(
                                        '$pct%',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFFE25B20),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  Stack(
                                    children: [
                                      Container(
                                        height: 6.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.03),
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: (pct / 100).clamp(0.0, 1.0),
                                        child: Container(
                                          height: 6.h,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFFFF7E47), Color(0xFFE25B20)],
                                            ),
                                            borderRadius: BorderRadius.circular(4.r),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFE25B20).withValues(alpha: 0.12),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
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
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                SizedBox(height: 16.h),

                // Stacked Scrollable List of Dream Vault Collectibles
                Expanded(
                  child: wishlistAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(28.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF111111),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                  ),
                                  child: Icon(Icons.card_giftcard_rounded, size: 40.sp, color: Colors.white38),
                                ),
                                SizedBox(height: 24.h),
                                Text(
                                  'Your Wish Vault is Empty',
                                  style: GoogleFonts.outfit(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  'Build your future rewards, one contribution at a time. Deploy your first target now.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF8A8A8A),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                        itemCount: items.length,
                        itemBuilder: (_, i) => _buildCard(items[i], i),
                      );
                    },
                    loading: () => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: const HFShimmerList(height: 160, count: 3),
                    ),
                    error: (e, _) => HFErrorState(
                      onRetry: () => ref.refresh(wishlistProvider),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Premium framed visual squircle thumbnail matching luxury target items
  Widget _getProductIcon(String title) {
    final t = title.toLowerCase();
    IconData iconData = Icons.card_giftcard_rounded;
    if (t.contains('macbook') || t.contains('laptop') || t.contains('pc') || t.contains('computer')) {
      iconData = Icons.laptop_mac_rounded;
    } else if (t.contains('shoe') || t.contains('shoes') || t.contains('nike') || t.contains('sneaker') || t.contains('run')) {
      iconData = Icons.sports_gymnastics_rounded;
    } else if (t.contains('watch') || t.contains('rolex') || t.contains('apple watch')) {
      iconData = Icons.watch_rounded;
    } else if (t.contains('course') || t.contains('learn') || t.contains('design') || t.contains('class') || t.contains('study')) {
      iconData = Icons.school_rounded;
    } else if (t.contains('headphone') || t.contains('headphones') || t.contains('sony') || t.contains('earbuds') || t.contains('sound')) {
      iconData = Icons.headset_rounded;
    } else if (t.contains('phone') || t.contains('iphone') || t.contains('mobile') || t.contains('gadget')) {
      iconData = Icons.phone_iphone_rounded;
    } else if (t.contains('bike') || t.contains('cycle') || t.contains('car') || t.contains('accessory')) {
      iconData = Icons.directions_bike_rounded;
    } else {
      iconData = Icons.card_giftcard_rounded; // Cohesive monoline card visual rather than sparkle placeholder
    }

    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE25B20).withValues(alpha: 0.04),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        iconData,
        color: const Color(0xFFE25B20),
        size: 19.sp,
      ),
    );
  }

  // Premium Monoline Icon layout replacing prototype-feel emojis
  Widget _buildDopamineMessage(WishlistModel item) {
    final progress = item.progress;
    final acquired = item.status == 'Acquired';

    IconData icon;
    String text;
    Color color;

    if (acquired) {
      icon = Icons.stars_rounded;
      text = 'Reward Unlocked';
      color = Colors.green;
    } else if (progress >= 85) {
      icon = Icons.offline_bolt_outlined;
      text = 'Almost there, final push';
      color = const Color(0xFFFF7E47);
    } else if (progress >= 60) {
      icon = Icons.trending_up_rounded;
      text = '15% ahead of your pace';
      color = const Color(0xFFFF7E47);
    } else if (progress >= 35) {
      icon = Icons.whatshot_rounded;
      text = 'Fueling the dream';
      color = const Color(0xFFFF7E47);
    } else if (progress > 0) {
      final hash = item.id.hashCode;
      if (hash % 2 == 0) {
        icon = Icons.rocket_launch_outlined;
        text = 'Momentum activated';
      } else {
        icon = Icons.explore_outlined;
        text = 'Journey initiated';
      }
      color = const Color(0xFFFF7E47);
    } else {
      icon = Icons.gps_fixed_rounded;
      text = 'Ready to contribute';
      color = const Color(0xFFFF7E47);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 14.sp),
        SizedBox(width: 6.w),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneDot(bool passed, bool acquired) {
    return Container(
      width: 4.w,
      height: 4.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: passed ? Colors.white : Colors.white.withValues(alpha: 0.15),
        boxShadow: [
          if (passed)
            BoxShadow(
              color: (acquired ? Colors.greenAccent : const Color(0xFFFF7E47)).withValues(alpha: 0.8),
              blurRadius: 4,
              spreadRadius: 1,
            ),
        ],
      ),
    );
  }

  Widget _buildCard(WishlistModel item, int index) {
    final acquired = item.status == 'Acquired';
    final progressVal = (item.progress / 100).clamp(0.0, 1.0);
    final remaining = (item.targetPrice - item.currentSavings).clamp(0.0, double.infinity);

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF141414),
            Color(0xFF0C0C0C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: acquired
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
          if (acquired)
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.02),
              blurRadius: 40,
              spreadRadius: 1,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Thumbnail + Title Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _getProductIcon(item.title),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.outfit(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'Target: ₹${item.targetPrice.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: const Color(0xFF8A8A8A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Three-dot overflow menu for clean destructive operations
                      GestureDetector(
                        onTap: () => _showOptionsModal(context, item),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.02),
                          ),
                          child: Icon(
                            Icons.more_horiz_rounded,
                            size: 16.sp,
                            color: const Color(0xFF8A8A8A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Progress Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'UNLOCK PROGRESS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white30,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '${item.progress.round()}%',
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: acquired ? Colors.green : const Color(0xFFE25B20),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Thicker Progress Bar with Milestone Dots embedded on the track
                  Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 8.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progressVal,
                        child: Container(
                          height: 8.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: acquired
                                  ? [Colors.greenAccent, Colors.green]
                                  : [const Color(0xFFFF7E47), const Color(0xFFE25B20)],
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                color: (acquired ? Colors.green : const Color(0xFFE25B20))
                                    .withValues(alpha: 0.25),
                                blurRadius: 8,
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Milestone marker dots at 25/50/75
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox.shrink(),
                              _buildMilestoneDot(progressVal >= 0.25, acquired),
                              _buildMilestoneDot(progressVal >= 0.50, acquired),
                              _buildMilestoneDot(progressVal >= 0.75, acquired),
                              const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // Milestone Labels with High Intentional Visibility
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0%', style: GoogleFonts.plusJakartaSans(fontSize: 8.sp, color: Colors.white38, fontWeight: FontWeight.w700)),
                      Text('25%', style: GoogleFonts.plusJakartaSans(fontSize: 8.sp, color: progressVal >= 0.25 ? const Color(0xFFE25B20) : Colors.white30, fontWeight: progressVal >= 0.25 ? FontWeight.w800 : FontWeight.w700)),
                      Text('50%', style: GoogleFonts.plusJakartaSans(fontSize: 8.sp, color: progressVal >= 0.50 ? const Color(0xFFE25B20) : Colors.white30, fontWeight: progressVal >= 0.50 ? FontWeight.w800 : FontWeight.w700)),
                      Text('75%', style: GoogleFonts.plusJakartaSans(fontSize: 8.sp, color: progressVal >= 0.75 ? const Color(0xFFE25B20) : Colors.white30, fontWeight: progressVal >= 0.75 ? FontWeight.w800 : FontWeight.w700)),
                      Text('100%', style: GoogleFonts.plusJakartaSans(fontSize: 8.sp, color: progressVal >= 1.0 ? Colors.green : Colors.white38, fontWeight: progressVal >= 1.0 ? FontWeight.w800 : FontWeight.w700)),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Dopamine Motivational Signals Strip with monoline icons (No raw emojis)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDopamineMessage(item),
                      if (!acquired)
                        Text(
                          '₹${remaining.toStringAsFixed(0)} left',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: const Color(0xFF8A8A8A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Container(height: 1, width: double.infinity, color: Colors.white.withValues(alpha: 0.03)),
                  SizedBox(height: 14.h),

                  // Elegant Action Footer Strip (Surgical CTA balance & SAVED SO FAR label)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SAVED SO FAR', // Human Premium Label Refinement
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 7.5.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFE25B20).withValues(alpha: 0.8),
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '₹${item.currentSavings.toStringAsFixed(0)}',
                            style: GoogleFonts.outfit(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      // Surgical CTA balance: slightly smaller, soft glow, high confidence
                      GestureDetector(
                        onTap: acquired ? null : () => _showSavingsModal(item),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                          decoration: BoxDecoration(
                            color: acquired
                                ? Colors.green.withValues(alpha: 0.05)
                                : const Color(0xFFE25B20),
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: [
                              if (!acquired)
                                BoxShadow(
                                  color: const Color(0xFFE25B20).withValues(alpha: 0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                acquired ? Icons.done_all_rounded : Icons.add_circle_outline_rounded,
                                size: 12.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                acquired ? 'Unlocked' : 'Add Contribution',
                                style: GoogleFonts.outfit(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
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
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms);
  }

  void _showOptionsModal(BuildContext context, WishlistModel item) {
    final acquired = item.status == 'Acquired';
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
                color: const Color(0xFFE25B20),
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 16.h),
            if (!acquired)
              ListTile(
                leading: Icon(Icons.add_circle_outline_rounded, color: Colors.white70, size: 22.sp),
                title: Text('Add Contribution', style: GoogleFonts.inter(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSavingsModal(item);
                },
              ),
            ListTile(
              leading: Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 22.sp),
              title: Text('Delete Goal', style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 16.sp, fontWeight: FontWeight.w500)),
              onTap: () {
                ref.read(wishlistProvider.notifier).removeItem(item.id);
                Navigator.pop(ctx);
              },
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  void _showSavingsModal(WishlistModel item) {
    final c = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        elevation: 0,
        child: SingleChildScrollView(
          child: HFGlassCard(
            borderRadius: AppTheme.radiusXl,
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Contribution',
                      style: GoogleFonts.outfit(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Icon(Icons.close_rounded, color: Colors.white70, size: 16.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.title,
                    style: GoogleFonts.inter(fontSize: 13.sp, color: AppTheme.textMuted),
                  ),
                ),
                SizedBox(height: 24.h),
                TextField(
                  controller: c,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 26.sp, fontWeight: FontWeight.w800),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: GoogleFonts.outfit(color: const Color(0xFFE25B20), fontSize: 26.sp, fontWeight: FontWeight.w800),
                    hintText: '0',
                    hintStyle: GoogleFonts.outfit(color: Colors.white10, fontSize: 26.sp),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.03),
                    contentPadding: EdgeInsets.all(16.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(color: const Color(0xFFE25B20).withValues(alpha: 0.5)),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          final amt = double.tryParse(c.text) ?? 0;
                          if (amt <= 0) return;

                          final newSavings = item.currentSavings + amt;
                          final status = newSavings >= item.targetPrice ? 'Acquired' : 'Active';

                          ref.read(wishlistProvider.notifier).updateItem(item.id, {
                            'currentSavings': newSavings,
                            'status': status,
                          });
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF7E47), Color(0xFFE25B20)],
                            ),
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE25B20).withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Contribute',
                            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700),
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

  void _showAddModal() {
    final titleC = TextEditingController();
    final priceC = TextEditingController();
    final urlC = TextEditingController();
    bool isSyncing = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          elevation: 0,
          child: SingleChildScrollView(
            child: HFGlassCard(
              borderRadius: AppTheme.radiusXl,
              padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Initialize Target',
                        style: GoogleFonts.outfit(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded, color: Colors.white38, size: 16.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // Auto Sync Field
                  Text(
                    'AUTO-SYNC (OPTIONAL)',
                    style: GoogleFonts.outfit(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE25B20),
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: urlC,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: _inputDeco('Paste product URL'),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: isSyncing
                            ? null
                            : () async {
                                if (urlC.text.isEmpty) return;
                                ss(() => isSyncing = true);
                                try {
                                  final data = await ref
                                      .read(wishlistServiceProvider)
                                      .autoSync(urlC.text);
                                  ss(() {
                                    titleC.text = data['title'] ?? '';
                                    priceC.text = (data['price'] ?? 0).toString();
                                    isSyncing = false;
                                  });
                                } catch (e) {
                                  ss(() => isSyncing = false);
                                }
                              },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: isSyncing
                              ? SizedBox(
                                  width: 16.w,
                                  height: 16.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFE25B20),
                                  ),
                                )
                              : Icon(
                                  Icons.sync_rounded,
                                  color: const Color(0xFFE25B20).withValues(alpha: 0.7),
                                  size: 16.sp,
                                ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  // Elegant Visual Separator
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 0.5.h,
                          color: Colors.white.withValues(alpha: 0.025),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          'OR',
                          style: GoogleFonts.outfit(
                            fontSize: 7.5.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withValues(alpha: 0.2),
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 0.5.h,
                          color: Colors.white.withValues(alpha: 0.025),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  Text(
                    'MANUAL ENTRY',
                    style: GoogleFonts.outfit(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: titleC,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDeco('e.g., MacBook Pro M3 Max'),
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: priceC,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDeco('Target Price (₹)'),
                  ),
                  SizedBox(height: 24.h),

                  GestureDetector(
                    onTap: () {
                      if (titleC.text.trim().isEmpty) return;
                      ref.read(wishlistProvider.notifier).addItem({
                        'title': titleC.text.trim(),
                        'targetPrice': double.tryParse(priceC.text) ?? 0,
                        'category': 'Wishlist',
                        'link': urlC.text.trim(),
                      });
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF7E47), Color(0xFFE25B20)],
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE25B20).withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Deploy Target',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String h) => InputDecoration(
        hintText: h,
        hintStyle: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.28), fontSize: 13.sp),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.03),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: const Color(0xFFE25B20).withValues(alpha: 0.4)),
        ),
      );
}
