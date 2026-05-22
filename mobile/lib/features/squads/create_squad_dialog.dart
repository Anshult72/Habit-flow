import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/theme/app_theme.dart';
import '../../services/squad_service.dart';

class CreateSquadDialog extends ConsumerStatefulWidget {
  const CreateSquadDialog({super.key});

  @override
  ConsumerState<CreateSquadDialog> createState() => _CreateSquadDialogState();
}

class _CreateSquadDialogState extends ConsumerState<CreateSquadDialog> {
  int _currentStep = 0; // Steps 0 to 4
  final _nameController = TextEditingController();
  
  // Selection States
  int _selectedSize = 5; // 2, 5, or 10 Members
  String _selectedType = 'Habit Dominance'; // Habit Dominance, Focus Marathon, Learning League, Mixed Discipline
  int _selectedDuration = 7; // 7, 14, or 30 Days
  int _selectedXP = 8; // 0 (No Stake), 4, 8, 16
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a squad name'), backgroundColor: AppTheme.danger),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      await ref.read(squadServiceProvider).createSquad(name, _selectedXP, _selectedDuration);
      ref.invalidate(squadsProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Squad "$name" formed! Tribe registered.'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create squad: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    if (_currentStep == 0 && _nameController.text.trim().isEmpty) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Squad Name to proceed'), backgroundColor: AppTheme.danger),
      );
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _currentStep++;
    });
  }

  void _prevStep() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentStep--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
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
                    blurRadius: 35,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w), // Increased internal padding from 20.w for a cleaner look
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Step progress header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'STEP ${_currentStep + 1} OF 5', 
                          style: GoogleFonts.outfit(
                            fontSize: 9.sp, 
                            fontWeight: FontWeight.w900, 
                            color: const Color(0xFFFF7E47),
                            letterSpacing: 1.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close_rounded, color: Colors.white30, size: 18.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h), // Increased spacing
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2.r),
                      child: LinearProgressIndicator(
                        value: (_currentStep + 1) / 5,
                        backgroundColor: Colors.white.withValues(alpha: 0.03),
                        color: const Color(0xFFE25B20),
                        minHeight: 3.h,
                      ),
                    ),
                    SizedBox(height: 28.h), // Increased vertical spacing

                    // Multi Step content switcher
                    _buildStepContent(),

                    SizedBox(height: 32.h), // Increased vertical spacing

                    // Bottom Navigation Buttons
                    Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: GestureDetector(
                              onTap: _prevStep,
                              child: Container(
                                height: 44.h, // Slightly larger height
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.02),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                ),
                                child: Center(
                                  child: Text(
                                    'BACK',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white60,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (_currentStep > 0) SizedBox(width: 10.w),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: _currentStep < 4 ? _nextStep : (_isLoading ? null : _submit),
                            child: Container(
                              height: 44.h, // Slightly larger height
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF7E47), Color(0xFFE25B20)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFE25B20).withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isLoading
                                    ? SizedBox(
                                        width: 16.w, 
                                        height: 16.h, 
                                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : Text(
                                        _currentStep < 4 ? 'NEXT STEP' : 'FORM THE TRIBE',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12.5.sp,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 1.0,
                                        ),
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
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1SquadName();
      case 1:
        return _buildStep2SquadSize();
      case 2:
        return _buildStep3ChallengeType();
      case 3:
        return _buildStep4Duration();
      case 4:
        return _buildStep5Stake();
      default:
        return Container();
    }
  }

  // STEP 1: Squad Name
  Widget _buildStep1SquadName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NAME YOUR TRIBE', 
          style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        SizedBox(height: 6.h), // Increased breathing room
        Text(
          'Choose a strong name representing your accountability squad.', 
          style: GoogleFonts.inter(fontSize: 11.5.sp, color: Colors.white.withValues(alpha: 0.45)), // Typography Polish (brighter dim text)
        ),
        SizedBox(height: 20.h), // Increased vertical spacing
        TextField(
          controller: _nameController,
          autofocus: true,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13.5.sp),
          decoration: InputDecoration(
            hintText: 'Enter your squad name',
            hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 13.sp),
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h), // More padded text field
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
      ],
    );
  }

  // STEP 2: Choose Squad Size
  Widget _buildStep2SquadSize() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CHOOSE SQUAD SIZE', 
          style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        SizedBox(height: 6.h),
        Text(
          'Limit the total accountability members for healthy rivalry.', 
          style: GoogleFonts.inter(fontSize: 11.5.sp, color: Colors.white.withValues(alpha: 0.45)), // Typography Polish
        ),
        SizedBox(height: 20.h),
        Column(
          children: [2, 5, 10].map((size) {
            final isSel = _selectedSize == size;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedSize = size);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h), // More padded cards
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFFE25B20).withValues(alpha: 0.08) : const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSel ? const Color(0xFFE25B20).withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.03), // Cleaner opacity border
                    width: isSel ? 1.2 : 0.8,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.groups_rounded, 
                          color: isSel ? const Color(0xFFFF7E47) : Colors.white24,
                          size: 16.sp,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          '$size Members Limit', 
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp, 
                            fontWeight: FontWeight.w800, 
                            color: isSel ? Colors.white : Colors.white60,
                          ),
                        ),
                      ],
                    ),
                    if (isSel)
                      Icon(Icons.check_circle_rounded, color: const Color(0xFFFF7E47), size: 14.sp),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // STEP 3: Choose Primary Challenge Type
  Widget _buildStep3ChallengeType() {
    final types = [
      {
        'title': 'Habit Dominance',
        'desc': 'Most habit completions win',
        'icon': Icons.fact_check_rounded,
      },
      {
        'title': 'Focus Marathon',
        'desc': 'Highest focus minutes win',
        'icon': Icons.psychology_rounded,
      },
      {
        'title': 'Learning League',
        'desc': 'Highest learning XP wins',
        'icon': Icons.school_rounded,
      },
      {
        'title': 'Mixed Discipline',
        'desc': 'Combined productivity scoring',
        'icon': Icons.flash_on_rounded,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT PRIMARY METRIC', 
          style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        SizedBox(height: 6.h),
        Text(
          'Choose the core habit activity to compete in.', 
          style: GoogleFonts.inter(fontSize: 11.5.sp, color: Colors.white.withValues(alpha: 0.45)), // Typography Polish
        ),
        SizedBox(height: 16.h),
        Column(
          children: types.map((item) {
            final title = item['title'] as String;
            final desc = item['desc'] as String;
            final icon = item['icon'] as IconData;
            final isSel = _selectedType == title;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedType = title);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h), // More vertical breathing room
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFFE25B20).withValues(alpha: 0.08) : const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isSel ? const Color(0xFFE25B20).withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.03), // Cleaner opacity border
                    width: isSel ? 1.2 : 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFFE25B20).withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.02),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon, 
                        size: 14.sp, 
                        color: isSel ? const Color(0xFFFF7E47) : Colors.white30, // Typography Polish
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.outfit(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w800,
                              color: isSel ? Colors.white : Colors.white54,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            desc,
                            style: GoogleFonts.inter(
                              fontSize: 9.sp,
                              color: isSel ? const Color(0xFFFF7E47).withValues(alpha: 0.85) : Colors.white30, // Typography Polish
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
      ],
    );
  }

  // STEP 4: Challenge Duration
  Widget _buildStep4Duration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CHALLENGE DURATION', 
          style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        SizedBox(height: 6.h),
        Text(
          'Select the duration for this squad battle sprint.', 
          style: GoogleFonts.inter(fontSize: 11.5.sp, color: Colors.white.withValues(alpha: 0.45)), // Typography Polish
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [7, 14, 30].map((days) {
            final isSel = _selectedDuration == days;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedDuration = days);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w), // More spacing
                  padding: EdgeInsets.symmetric(vertical: 14.h), // More padded cards
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFFE25B20).withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isSel ? const Color(0xFFE25B20).withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.04),
                      width: isSel ? 1.2 : 0.8,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$days',
                        style: GoogleFonts.outfit(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: isSel ? const Color(0xFFFF7E47) : Colors.white60,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Days',
                        style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          color: isSel ? const Color(0xFFFF7E47).withValues(alpha: 0.75) : Colors.white30, // Typography Polish
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // STEP 5: Squad XP Stake
  Widget _buildStep5Stake() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OPTIONAL SQUAD XP STAKE', 
          style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        SizedBox(height: 6.h),
        Text(
          'Higher stakes demand ultimate focus. Winning members earn bonus rewards!', 
          style: GoogleFonts.inter(fontSize: 11.5.sp, color: Colors.white.withValues(alpha: 0.45), height: 1.3), // Typography Polish
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [0, 4, 8, 16].map((xp) {
            final isSel = _selectedXP == xp;
            final label = xp == 0 ? 'No Stake' : '$xp XP';
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedXP = xp);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  padding: EdgeInsets.symmetric(vertical: 12.h), // More padded card
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFFE25B20).withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isSel ? const Color(0xFFE25B20).withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.04),
                      width: isSel ? 1.2 : 0.8,
                    ),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w900,
                      color: isSel ? const Color(0xFFFF7E47) : Colors.white60,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 16.h), // Increased vertical spacing
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline_rounded, size: 10.sp, color: const Color(0xFFFF7E47)),
              SizedBox(width: 4.w),
              Text(
                'Stake will be locked until the challenge duration ends.',
                style: GoogleFonts.inter(fontSize: 9.sp, color: const Color(0xFFFF7E47).withValues(alpha: 0.85)), // Typography Polish
              ),
            ],
          ),
        ),
      ],
    );
  }
}
