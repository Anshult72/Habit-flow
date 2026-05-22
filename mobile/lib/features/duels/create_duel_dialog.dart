import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/theme/app_theme.dart';
import '../../services/duel_service.dart';

class CreateDuelDialog extends ConsumerStatefulWidget {
  const CreateDuelDialog({super.key});

  @override
  ConsumerState<CreateDuelDialog> createState() => _CreateDuelDialogState();
}

class _CreateDuelDialogState extends ConsumerState<CreateDuelDialog> {
  final _targetIdController = TextEditingController();
  int _selectedXP = 8;
  int _selectedDuration = 7;
  String _selectedDuelType = 'Habit Completion';
  bool _isLoading = false;

  final List<Map<String, String>> _rivalSuggestions = [
    {'name': 'Saurabh Tripathi', 'id': '81920381'},
    {'name': 'Rohan Kapoor', 'id': '12093821'},
    {'name': 'Deepak Sharma', 'id': '47281039'},
  ];

  @override
  void dispose() {
    _targetIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final targetId = _targetIdController.text.trim();

    if (targetId.isEmpty || targetId.length != 8) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 8-digit Opponent ID'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      await ref.read(duelServiceProvider).createChallenge(targetId, _selectedXP, _selectedDuration);
      ref.invalidate(duelsProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Duel Challenge issued! Entering Arena...'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send challenge: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Backdrop blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              constraints: BoxConstraints(maxHeight: 0.85.sh),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: const Color(0xFFE25B20).withValues(alpha: 0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title Block
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shield_rounded, color: const Color(0xFFE25B20), size: 18.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'CHALLENGE RIVAL', 
                              style: GoogleFonts.outfit(
                                fontSize: 13.sp, 
                                fontWeight: FontWeight.w900, 
                                color: Colors.white,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close_rounded, color: Colors.white30, size: 16.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),

                    // Step 1: Choose Opponent
                    _buildSectionTitle('STEP 1: SELECT OPPONENT'),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _targetIdController,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp),
                      decoration: InputDecoration(
                        counterText: '',
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.white30, size: 16.sp),
                        hintText: 'Search username, friend, or 8-digit ID',
                        hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 12.5.sp),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                        fillColor: Colors.white.withValues(alpha: 0.02),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: const Color(0xFFE25B20).withValues(alpha: 0.4)),
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Primary: username/friend search  •  Secondary: enter rival ID', 
                          style: GoogleFonts.inter(fontSize: 8.5.sp, color: Colors.white38),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    
                    // Rivals quick-select suggestions
                    SizedBox(
                      height: 28.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _rivalSuggestions.length,
                        itemBuilder: (context, idx) {
                          final sug = _rivalSuggestions[idx];
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _targetIdController.text = sug['id']!;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 6.w),
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.02),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.person_add_alt_1_rounded, size: 10.sp, color: const Color(0xFFFF7E47)),
                                  SizedBox(width: 4.w),
                                  Text(
                                    sug['name']!,
                                    style: GoogleFonts.outfit(
                                      fontSize: 9.sp, 
                                      fontWeight: FontWeight.w700, 
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 18.h),

                    // Step 2: Choose XP Stake
                    _buildSectionTitle('STEP 2: CHOOSE XP STAKE'),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [4, 8, 16, 32].map((xp) {
                        final isSel = _selectedXP == xp;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() => _selectedXP = xp);
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 2.w),
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSel 
                                    ? const Color(0xFFE25B20).withValues(alpha: 0.12) 
                                    : Colors.white.withValues(alpha: 0.02),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: isSel 
                                      ? const Color(0xFFE25B20).withValues(alpha: 0.4) 
                                      : Colors.white.withValues(alpha: 0.04),
                                  width: isSel ? 1.2 : 0.8,
                                ),
                              ),
                              child: Text(
                                '$xp XP',
                                style: GoogleFonts.outfit(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w900,
                                  color: isSel ? const Color(0xFFFF7E47) : Colors.white60,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 18.h),

                    // Step 3: Choose Duration
                    _buildSectionTitle('STEP 3: CHOOSE DUEL DURATION'),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [3, 7, 14, 30].map((days) {
                        final isSel = _selectedDuration == days;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() => _selectedDuration = days);
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 2.w),
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSel 
                                    ? const Color(0xFFE25B20).withValues(alpha: 0.12) 
                                    : Colors.white.withValues(alpha: 0.02),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: isSel 
                                      ? const Color(0xFFE25B20).withValues(alpha: 0.4) 
                                      : Colors.white.withValues(alpha: 0.04),
                                  width: isSel ? 1.2 : 0.8,
                                ),
                              ),
                              child: Text(
                                '$days Days',
                                style: GoogleFonts.outfit(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w900,
                                  color: isSel ? const Color(0xFFFF7E47) : Colors.white60,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 18.h),

                    // Step 4: Choose Duel Type (Scoped ONLY to Habit, Focus, and Learning)
                    _buildSectionTitle('STEP 4: CHOOSE BATTLE TYPE'),
                    SizedBox(height: 8.h),
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        {
                          'type': 'Habit Completion',
                          'helper': 'Most habits completed wins',
                          'icon': Icons.fact_check_rounded,
                        },
                        {
                          'type': 'Focus Session',
                          'helper': 'Highest focus time wins',
                          'icon': Icons.psychology_rounded,
                        },
                        {
                          'type': 'Learning XP',
                          'helper': 'Most learning XP wins',
                          'icon': Icons.school_rounded,
                        },
                      ].map((item) {
                        final type = item['type'] as String;
                        final helper = item['helper'] as String;
                        final icon = item['icon'] as IconData;
                        final isSel = _selectedDuelType == type;

                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => _selectedDuelType = type);
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 6.h),
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: isSel 
                                  ? const Color(0xFFE25B20).withValues(alpha: 0.08) 
                                  : const Color(0xFF141414),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: isSel 
                                    ? const Color(0xFFE25B20).withValues(alpha: 0.4) 
                                    : Colors.white.withValues(alpha: 0.02),
                                width: isSel ? 1.2 : 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6.w),
                                  decoration: BoxDecoration(
                                    color: isSel 
                                        ? const Color(0xFFE25B20).withValues(alpha: 0.1) 
                                        : Colors.white.withValues(alpha: 0.02),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    icon, 
                                    size: 14.sp, 
                                    color: isSel ? const Color(0xFFFF7E47) : Colors.white24,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        type,
                                        style: GoogleFonts.outfit(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w800,
                                          color: isSel ? Colors.white : Colors.white54,
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        helper,
                                        style: GoogleFonts.inter(
                                          fontSize: 8.5.sp,
                                          color: isSel ? const Color(0xFFFF7E47).withValues(alpha: 0.8) : Colors.white24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 24.h),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 46.h,
                      child: GestureDetector(
                        onTap: _isLoading ? null : _submit,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF7E47), Color(0xFFE25B20)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE25B20).withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? SizedBox(
                                    width: 18.w, 
                                    height: 18.h, 
                                    child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    'ENTER ARENA', 
                                    style: GoogleFonts.outfit(
                                      fontSize: 12.5.sp, 
                                      fontWeight: FontWeight.w900, 
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String label) {
    return Text(
      label, 
      style: GoogleFonts.outfit(
        fontSize: 8.5.sp, 
        fontWeight: FontWeight.w900, 
        color: Colors.white30,
        letterSpacing: 1.2,
      ),
    );
  }
}
