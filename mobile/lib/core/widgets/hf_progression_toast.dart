import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HFProgressionToast extends StatelessWidget {
  final String title;
  final String subtitle;
  final int xpEarned;
  final int streakCount;
  final bool isMilestone;

  const HFProgressionToast({
    super.key,
    required this.title,
    required this.subtitle,
    required this.xpEarned,
    required this.streakCount,
    this.isMilestone = false,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int xpEarned,
    required int streakCount,
    bool isMilestone = false,
  }) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: HFProgressionToast(
            title: title,
            subtitle: subtitle,
            xpEarned: xpEarned,
            streakCount: streakCount,
            isMilestone: isMilestone,
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    // Auto-remove after animation completes (Entrance + Display + Exit = 4.2 seconds)
    Timer(const Duration(milliseconds: 4300), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = isMilestone ? const Color(0xFFFFD700) : const Color(0xFFE25B20);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.18),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: 0.04),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Glowing Flame icon for study streak
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.12),
                width: 0.8,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              isMilestone ? LucideIcons.trophy : LucideIcons.flame,
              color: accentColor,
              size: 20,
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1000.ms, curve: Curves.easeInOut),
          ),
          const SizedBox(width: 14),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontWeight: FontWeight.w500,
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (streakCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$streakCount-DAY STREAK',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFF9E2C),
                          fontWeight: FontWeight.w900,
                          fontSize: 9.5,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // XP badge with dynamic colors
          if (xpEarned > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isMilestone
                      ? [const Color(0xFFFFDF00), const Color(0xFFD4AF37)]
                      : [const Color(0xFFFF7E47), const Color(0xFFE25B20)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '+$xpEarned XP',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    )
    .animate()
    .slideY(begin: -1.2, end: 0.0, duration: 400.ms, curve: Curves.easeOutCubic)
    .fadeIn(duration: 300.ms)
    .then(delay: 3300.ms) // Display duration
    .slideY(begin: 0.0, end: -1.2, duration: 400.ms, curve: Curves.easeInCubic)
    .fadeOut(duration: 300.ms);
  }
}
