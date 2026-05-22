import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/theme/app_theme.dart';
import '../../services/squad_service.dart';

class JoinSquadDialog extends ConsumerStatefulWidget {
  const JoinSquadDialog({super.key});

  @override
  ConsumerState<JoinSquadDialog> createState() => _JoinSquadDialogState();
}

class _JoinSquadDialogState extends ConsumerState<JoinSquadDialog> {
  final _searchController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _mockPendingInvites = [
    {
      'squadName': 'ALPHA TRIBE', 
      'host': 'Anshul T.', 
      'code': 'SQUADX99', 
      'xp': '8 XP',
      'members': 4,
      'challengeType': 'Focus Marathon',
    },
    {
      'squadName': 'FOCUS ELITES', 
      'host': 'Deepak S.', 
      'code': 'FOCUS888', 
      'xp': '4 XP',
      'members': 5,
      'challengeType': 'Habit Dominance',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submitJoin(String code) async {
    if (code.isEmpty) return;
    
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      await ref.read(squadServiceProvider).joinSquad(code);
      ref.invalidate(squadsProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome to the Tribe! Squad joined.'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join squad: $e'), backgroundColor: AppTheme.danger),
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
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              constraints: BoxConstraints(maxHeight: 0.8.sh),
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
                    // Title Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.group_add_rounded, color: const Color(0xFFFF7E47), size: 18.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'JOIN SQUAD', 
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
                    SizedBox(height: 20.h),

                    // Search input block
                    Text(
                      'ENTER SQUAD INVITE CODE OR RIVAL USERNAME', 
                      style: GoogleFonts.outfit(
                        fontSize: 8.5.sp, 
                        fontWeight: FontWeight.w900, 
                        color: Colors.white.withValues(alpha: 0.45), // Typography polish (slight brightness increase)
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _searchController,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.white30, size: 16.sp),
                        hintText: 'Search friend username or enter invite code',
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
                    SizedBox(height: 16.h),

                    // Join Button
                    SizedBox(
                      width: double.infinity,
                      height: 44.h,
                      child: GestureDetector(
                        onTap: _isLoading ? null : () => _submitJoin(_searchController.text.trim()),
                        child: Container(
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
                                    'SUBMIT CODE', 
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

                    SizedBox(height: 24.h),

                    // Pending Invites Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PENDING INVITES', 
                          style: GoogleFonts.outfit(
                            fontSize: 8.5.sp, 
                            fontWeight: FontWeight.w900, 
                            color: Colors.white.withValues(alpha: 0.45), // Typography polish
                            letterSpacing: 1.2,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE25B20).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '${_mockPendingInvites.length} NEW', 
                            style: GoogleFonts.outfit(
                              fontSize: 7.5.sp, 
                              fontWeight: FontWeight.w900, 
                              color: const Color(0xFFFF7E47),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _mockPendingInvites.length,
                      itemBuilder: (context, idx) {
                        final invite = _mockPendingInvites[idx];
                        return Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141414),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
                          ),
                          child: Row(
                            children: [
                              // Squad Icon/Avatar
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE25B20).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFE25B20).withValues(alpha: 0.2)),
                                ),
                                child: Icon(Icons.shield_rounded, size: 14.sp, color: const Color(0xFFFF7E47)),
                              ),
                              SizedBox(width: 12.w),
                              
                              // Squad details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      invite['squadName']!, 
                                      style: GoogleFonts.outfit(
                                        fontSize: 12.sp, 
                                        fontWeight: FontWeight.w800, 
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      '${invite['members']} Members • ${invite['challengeType']} • ${invite['xp']}', 
                                      style: GoogleFonts.inter(
                                        fontSize: 9.sp, 
                                        color: Colors.white38, // Typography polish
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Action Buttons
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        _mockPendingInvites.removeAt(idx);
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(6.w),
                                      decoration: BoxDecoration(
                                        color: AppTheme.danger.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.close_rounded, size: 14.sp, color: AppTheme.danger),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  GestureDetector(
                                    onTap: () => _submitJoin(invite['code']!),
                                    child: Container(
                                      padding: EdgeInsets.all(6.w),
                                      decoration: BoxDecoration(
                                        color: AppTheme.success.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.check_rounded, size: 14.sp, color: AppTheme.success),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
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
}
