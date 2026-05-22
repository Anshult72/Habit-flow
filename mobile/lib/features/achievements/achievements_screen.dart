import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

enum TrophyRarity { common, rare, epic, legendary, mythic }

class TrophyModel {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final bool unlocked;
  final TrophyRarity rarity;
  final String category;
  final String reward;
  final int xpReward;
  final int? progressCurrent;
  final int? progressTotal;

  const TrophyModel({
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    this.unlocked = false,
    required this.rarity,
    required this.category,
    required this.reward,
    required this.xpReward,
    this.progressCurrent,
    this.progressTotal,
  });
}

const _trophies = [
  TrophyModel(
    title: 'First Step', 
    desc: 'Complete your first habit', 
    icon: Icons.directions_walk_rounded, 
    color: Color(0xFFE2E2E2), // Silver treatment for Common
    unlocked: true,
    rarity: TrophyRarity.common,
    category: 'Discipline',
    reward: '+4 XP',
    xpReward: 4,
  ),
  TrophyModel(
    title: 'Week Warrior', 
    desc: '7-day habit completion streak', 
    icon: Icons.local_fire_department_rounded, 
    color: Color(0xFF3B82F6), // Rare Blue
    unlocked: true,
    rarity: TrophyRarity.rare,
    category: 'Discipline',
    reward: '+8 XP',
    xpReward: 8,
  ),
  TrophyModel(
    title: 'Habit Machine', 
    desc: 'Complete 50 habit entries', 
    icon: Icons.precision_manufacturing_rounded, 
    color: Color(0xFFFFD700), // Legendary Gold
    unlocked: true,
    rarity: TrophyRarity.legendary,
    category: 'Productivity',
    reward: '+32 XP & Gold Title',
    xpReward: 32,
  ),
  TrophyModel(
    title: 'Early Bird', 
    desc: 'Complete 5 habits before 8 AM', 
    icon: Icons.wb_sunny_rounded, 
    color: Color(0xFFA855F7), // Epic Purple
    unlocked: true,
    rarity: TrophyRarity.epic,
    category: 'Productivity',
    reward: '+16 XP',
    xpReward: 16,
  ),
  TrophyModel(
    title: 'Month Master', 
    desc: '30-day habit completion streak', 
    icon: Icons.calendar_month_rounded, 
    color: Color(0xFFFFD700), // Legendary Gold
    rarity: TrophyRarity.legendary,
    category: 'Discipline',
    reward: '+36 XP & 👑 Title',
    xpReward: 36,
    progressCurrent: 12,
    progressTotal: 30,
  ),
  TrophyModel(
    title: 'Century Club', 
    desc: '100-day habit completion streak', 
    icon: Icons.military_tech_rounded, 
    color: Color(0xFFEF4444), // Mythic Crimson
    rarity: TrophyRarity.mythic,
    category: 'Discipline',
    reward: '+72 XP & Fire Theme',
    xpReward: 72,
    progressCurrent: 15,
    progressTotal: 100,
  ),
  TrophyModel(
    title: 'Scholar', 
    desc: 'Complete 10 Learning Hub topics', 
    icon: Icons.school_rounded, 
    color: Color(0xFF3B82F6), // Rare Blue
    rarity: TrophyRarity.rare,
    category: 'Learning',
    reward: '+12 XP',
    xpReward: 12,
    progressCurrent: 4,
    progressTotal: 10,
  ),
  TrophyModel(
    title: 'Mission Possible', 
    desc: 'Complete your first mission', 
    icon: Icons.rocket_launch_rounded, 
    color: Color(0xFFE2E2E2), // Silver treatment for Common
    unlocked: true,
    rarity: TrophyRarity.common,
    category: 'Missions',
    reward: '+6 XP',
    xpReward: 6,
  ),
  TrophyModel(
    title: 'Brain Dump', 
    desc: 'Create 25 focus memos', 
    icon: Icons.psychology_rounded, 
    color: Color(0xFF3B82F6), // Rare Blue
    rarity: TrophyRarity.rare,
    category: 'Focus',
    reward: '+8 XP',
    xpReward: 8,
    progressCurrent: 18,
    progressTotal: 25,
  ),
  TrophyModel(
    title: 'Saver', 
    desc: 'Save ₹10,000 in wishlist', 
    icon: Icons.savings_rounded, 
    color: Color(0xFF3B82F6), // Rare Blue
    rarity: TrophyRarity.rare,
    category: 'Finance',
    reward: '+14 XP',
    xpReward: 14,
    progressCurrent: 4500,
    progressTotal: 10000,
  ),
  TrophyModel(
    title: 'Planner Pro', 
    desc: 'Complete all 6 planner time slots', 
    icon: Icons.event_available_rounded, 
    color: Color(0xFFA855F7), // Epic Purple
    rarity: TrophyRarity.epic,
    category: 'Productivity',
    reward: '+18 XP',
    xpReward: 18,
    progressCurrent: 2,
    progressTotal: 6,
  ),
  TrophyModel(
    title: 'Matrix Mind', 
    desc: 'Clear all Q1 critical tasks', 
    icon: Icons.grid_view_rounded, 
    color: Color(0xFFA855F7), // Epic Purple
    rarity: TrophyRarity.epic,
    category: 'Focus',
    reward: '+20 XP',
    xpReward: 20,
    progressCurrent: 1,
    progressTotal: 4,
  ),
  TrophyModel(
    title: 'Duel Victor', 
    desc: 'Win 5 productivity duels', 
    icon: Icons.emoji_events_rounded, 
    color: Color(0xFFFFD700), // Legendary Gold
    rarity: TrophyRarity.legendary,
    category: 'Missions',
    reward: '+28 XP',
    xpReward: 28,
    progressCurrent: 3,
    progressTotal: 5,
  ),
  TrophyModel(
    title: 'Absolute Zen', 
    desc: 'Complete 30 focus sessions', 
    icon: Icons.brightness_7_rounded, 
    color: Color(0xFFEF4444), // Mythic Crimson
    rarity: TrophyRarity.mythic,
    category: 'Secret',
    reward: '+64 XP & Zen Title',
    xpReward: 64,
    unlocked: false,
  ),
  TrophyModel(
    title: 'Golden Vault', 
    desc: 'Maintain budget for 90 days', 
    icon: Icons.vpn_key_rounded, 
    color: Color(0xFFFFD700), // Legendary Gold
    rarity: TrophyRarity.legendary,
    category: 'Secret',
    reward: '+36 XP',
    xpReward: 36,
    unlocked: false,
  ),
];

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  String _selectedCategory = 'All';

  Color _getRarityColor(TrophyRarity r) {
    switch (r) {
      case TrophyRarity.common:
        return const Color(0xFFC0C0C0); // Premium Silver
      case TrophyRarity.rare:
        return const Color(0xFF3B82F6);
      case TrophyRarity.epic:
        return const Color(0xFFA855F7);
      case TrophyRarity.legendary:
        return const Color(0xFFFFD700);
      case TrophyRarity.mythic:
        return const Color(0xFFEF4444);
    }
  }

  String _getRarityLabel(TrophyRarity r) {
    switch (r) {
      case TrophyRarity.common:
        return 'COMMON';
      case TrophyRarity.rare:
        return 'RARE';
      case TrophyRarity.epic:
        return 'EPIC';
      case TrophyRarity.legendary:
        return 'LEGENDARY';
      case TrophyRarity.mythic:
        return 'MYTHIC';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _trophies.where((b) => b.unlocked).length;
    final totalCount = _trophies.length;
    final progressRatio = unlockedCount / totalCount;
    final lifetimeXP = _trophies.where((b) => b.unlocked).fold<int>(0, (sum, b) => sum + b.xpReward);

    // Calculate progression rank dynamically
    String rankName = 'NOVICE DISCIPLINARIAN';
    String nextRankName = 'APPRENTICE';
    int threshold = 3;
    if (unlockedCount >= 3 && unlockedCount < 6) {
      rankName = 'DISCIPLINE APPRENTICE';
      nextRankName = 'TROPHY MASTER';
      threshold = 6;
    } else if (unlockedCount >= 6 && unlockedCount < 10) {
      rankName = 'TROPHY MASTER';
      nextRankName = 'ELITE ARCHITECT';
      threshold = 10;
    } else if (unlockedCount >= 10 && unlockedCount < 14) {
      rankName = 'ELITE ARCHITECT';
      nextRankName = 'SUPREME LEGEND';
      threshold = 14;
    } else if (unlockedCount >= 14) {
      rankName = 'SUPREME LEGEND';
      nextRankName = 'MAX LEVEL';
      threshold = 15;
    }

    // Singular/plural grammar checker
    final remaining = threshold - unlockedCount;
    final motivationText = unlockedCount < threshold
        ? '$remaining more achievement${remaining == 1 ? "" : "s"} to reach $nextRankName'
        : 'Ultimate discipline achieved!';

    final categories = [
      'All', 
      'Discipline', 
      'Learning', 
      'Focus', 
      'Finance', 
      'Productivity', 
      'Missions', 
      'Secret'
    ];

    final categoryIcons = {
      'All': Icons.grid_view_rounded,
      'Discipline': Icons.local_fire_department_rounded,
      'Learning': Icons.school_rounded,
      'Focus': Icons.psychology_rounded,
      'Finance': Icons.savings_rounded,
      'Productivity': Icons.speed_rounded,
      'Missions': Icons.rocket_launch_rounded,
      'Secret': Icons.vpn_key_rounded,
    };

    final filteredTrophies = _trophies.where((t) {
      if (_selectedCategory == 'All') return true;
      return t.category.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          children: [
            // Premium Header Row (Micro polished padding)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded, 
                        color: Colors.white, 
                        size: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'COLLECTIBLES', 
                          style: GoogleFonts.outfit(
                            fontSize: 9.sp, 
                            fontWeight: FontWeight.w800, 
                            color: const Color(0xFFE25B20), 
                            letterSpacing: 2.5,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Trophy Vault', 
                          style: GoogleFonts.outfit(
                            fontSize: 22.sp, 
                            fontWeight: FontWeight.w800, 
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: [
                  SizedBox(height: 4.h), // Compressed vertical height

                  // Trophy progression hero card compressed by 15%
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h), // Compressed padding height
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1F120D), Color(0xFF0F0F0F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: const Color(0xFFE25B20).withValues(alpha: 0.25),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE25B20).withValues(alpha: 0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rankName,
                                    style: GoogleFonts.outfit(
                                      fontSize: 10.sp, // Compressed slightly
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFFFF7E47),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    '$unlockedCount / $totalCount UNLOCKED',
                                    style: GoogleFonts.outfit(
                                      fontSize: 17.sp, // Compressed slightly
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(6.w), // Compressed avatar size
                              decoration: BoxDecoration(
                                color: const Color(0xFFE25B20).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFE25B20).withValues(alpha: 0.25),
                                  width: 1.0,
                                ),
                              ),
                              child: Icon(
                                Icons.emoji_events_rounded, 
                                size: 18.sp, // Reduced trophy icon size by 10%
                                color: const Color(0xFFFFB347),
                              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                               .scale(
                                 begin: const Offset(0.94, 0.94), 
                                 end: const Offset(1.06, 1.06), 
                                 duration: 1800.ms, 
                                 curve: Curves.easeInOut,
                               ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h), // Compressed vertical spacing
                        
                        // LifeTime Vault XP Tracker Badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.stars_rounded, size: 11.sp, color: const Color(0xFFFF7E47)),
                              SizedBox(width: 4.w),
                              Text(
                                '${lifetimeXP.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} Vault Value',
                                style: GoogleFonts.outfit(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h), // Compressed vertical spacing

                        // Progress Indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: progressRatio,
                            minHeight: 5.h, // Slightly compressed progress height
                            backgroundColor: Colors.white.withValues(alpha: 0.04),
                            valueColor: const AlwaysStoppedAnimation(Color(0xFFE25B20)),
                          ),
                        ),
                        SizedBox(height: 6.h), // Compressed vertical spacing
                        
                        Text(
                          motivationText,
                          style: GoogleFonts.inter(
                            fontSize: 9.5.sp, // Compressed slightly
                            fontWeight: FontWeight.w600,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

                  SizedBox(height: 14.h), // Tighter vertical layout breathing

                  // Category chips slimmer by ~12%
                  SizedBox(
                    height: 28.h, // Reduced chip row height from 32.h
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final catName = categories[index];
                        final isSelected = _selectedCategory == catName;
                        final vectorIcon = categoryIcons[catName] ?? Icons.grid_view_rounded;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = catName;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 6.w),
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h), // Reduced padding
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? const Color(0xFFE25B20).withValues(alpha: 0.12) 
                                  : Colors.white.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: isSelected 
                                    ? const Color(0xFFE25B20).withValues(alpha: 0.4) 
                                    : Colors.white.withValues(alpha: 0.04),
                                width: isSelected ? 1.0 : 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  vectorIcon, 
                                  size: 10.sp, // Slimmer icon
                                  color: isSelected ? const Color(0xFFFF7E47) : Colors.white38,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  catName,
                                  style: GoogleFonts.outfit(
                                    fontSize: 9.sp, // Slimmer text from 10.sp
                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                    color: isSelected ? const Color(0xFFFF7E47) : Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 16.h), // Standard spacing section rhythm

                  // Trophy Grid list
                  filteredTrophies.isEmpty
                      ? Container(
                          padding: EdgeInsets.symmetric(vertical: 40.h),
                          alignment: Alignment.center,
                          child: Text(
                            'No trophies found in this section.',
                            style: GoogleFonts.inter(
                              color: AppTheme.textMuted,
                              fontSize: 12.5.sp,
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12.h, // Increased spacing for premium breathing
                            crossAxisSpacing: 12.w, // Increased spacing for premium breathing
                            childAspectRatio: 1.12, // Increased ratio to reduce card height by ~12-15%
                          ),
                          itemCount: filteredTrophies.length,
                          itemBuilder: (_, i) => _buildTrophyCard(filteredTrophies[i], i),
                        ),
                  SizedBox(height: 120.h), // Generous clearance spacer
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrophyCard(TrophyModel b, int index) {
    final rarityColor = _getRarityColor(b.rarity);
    final rarityLabel = _getRarityLabel(b.rarity);
    
    final isLockedSecret = b.category == 'Secret' && !b.unlocked;
    final cardTitle = isLockedSecret ? '???' : b.title;
    final cardDesc = isLockedSecret ? 'Hidden Achievement' : b.desc;
    final cardIcon = isLockedSecret ? Icons.vpn_key_rounded : b.icon;
    final cardStatus = isLockedSecret ? 'Unlock to reveal' : (b.unlocked ? 'UNLOCKED' : 'LOCKED');

    final isCommon = b.rarity == TrophyRarity.common;
    final metallicBackground = isCommon && b.unlocked
        ? const LinearGradient(
            colors: [Color(0xFF222222), Color(0xFF131313)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : null;

    // Locked border visibility enhanced subtly to 0.22 alpha for better presence
    final borderThemeColor = isCommon
        ? (b.unlocked ? const Color(0xFFE2E2E2).withValues(alpha: 0.25) : const Color(0xFFE2E2E2).withValues(alpha: 0.22))
        : (b.unlocked ? rarityColor.withValues(alpha: 0.3) : rarityColor.withValues(alpha: 0.22));

    return Container(
      decoration: BoxDecoration(
        color: b.unlocked ? const Color(0xFF111111) : const Color(0xFF141414), // Muted yet active locked card background
        gradient: metallicBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: borderThemeColor,
          width: b.unlocked ? 1.2 : 0.8,
        ),
        boxShadow: [
          if (b.unlocked)
            BoxShadow(
              color: rarityColor.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h), // Tighter card vertical cushion (reduced dead empty space)
        child: Opacity(
          opacity: b.unlocked ? 1.0 : 0.72, // Upgraded opacity from 0.65 for premium unlocked/locked teaser
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.5.w), // Slimmer container spacing
                        decoration: BoxDecoration(
                          color: b.unlocked 
                              ? rarityColor.withValues(alpha: 0.1) 
                              : Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: b.unlocked 
                                ? rarityColor.withValues(alpha: 0.15) 
                                : Colors.white.withValues(alpha: 0.05),
                            width: 0.5,
                          ),
                        ),
                        child: Icon(
                          cardIcon, 
                          size: 13.sp, // Compressed
                          color: b.unlocked ? rarityColor : Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                      
                      // Custom Capsule Rarity Chip
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: rarityColor.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(5.r),
                          border: Border.all(
                            color: rarityColor.withValues(alpha: 0.12), 
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          rarityLabel,
                          style: GoogleFonts.outfit(
                            fontSize: 6.sp, // Tighter rarity text
                            fontWeight: FontWeight.w900,
                            color: rarityColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h), // Compressed vertical spacing (eliminates dead height)

                  // Title Text (Optimized to feel stronger and more premium)
                  Text(
                    cardTitle, 
                    style: GoogleFonts.outfit(
                      fontSize: 12.7.sp, // Micro-increased title size by ~6% for premium presence
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h), // Compressed spacing (eliminates dead height)

                  // Description Text (Upgraded readability)
                  Text(
                    cardDesc, 
                    style: GoogleFonts.inter(
                      fontSize: 9.6.sp, // Micro-increased description text size by ~6.6% for reading comfort
                      color: Colors.white.withValues(alpha: 0.48),
                    ),
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Progress Indicators for locked achievements
                  if (!b.unlocked && b.progressCurrent != null && b.progressTotal != null) ...[
                    SizedBox(height: 3.h), // Tighter progress gap
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3.r),
                            child: LinearProgressIndicator(
                              value: b.progressCurrent! / b.progressTotal!,
                              minHeight: 2.2.h,
                              backgroundColor: Colors.white.withValues(alpha: 0.04),
                              valueColor: AlwaysStoppedAnimation(rarityColor.withValues(alpha: 0.45)),
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${b.progressCurrent}/${b.progressTotal}',
                          style: GoogleFonts.outfit(
                            fontSize: 8.sp, // Slightly increased progress text size
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withValues(alpha: 0.40),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reward Visibility row
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE25B20).withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(5.r),
                      border: Border.all(color: const Color(0xFFE25B20).withValues(alpha: 0.08), width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.stars_rounded, 
                          size: 8.sp, 
                          color: const Color(0xFFFF7E47),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            isLockedSecret ? '???' : b.reward,
                            style: GoogleFonts.outfit(
                              fontSize: 7.9.sp, // Micro-increased reward strip size by ~5%
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFFF7E47),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h), // Compressed vertical spacing

                  // Bottom Unlock Status Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cardStatus, 
                        style: GoogleFonts.outfit(
                          fontSize: 7.5.sp, // Kept status text size unchanged
                          fontWeight: FontWeight.w900, 
                          color: isLockedSecret 
                              ? const Color(0xFFA855F7)
                              : (b.unlocked ? rarityColor : Colors.white30),
                          letterSpacing: 1.0,
                        ),
                      ),
                      Icon(
                        isLockedSecret
                            ? Icons.lock_outline_rounded
                            : (b.unlocked ? Icons.check_circle_rounded : Icons.lock_rounded), 
                        size: 9.sp, // Compressed icon
                        color: isLockedSecret
                            ? const Color(0xFFA855F7).withValues(alpha: 0.6)
                            : (b.unlocked ? rarityColor.withValues(alpha: 0.6) : Colors.white30),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 30 * index), duration: 250.ms);
  }
}
