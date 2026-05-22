import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/state/habits_provider.dart';

/// Add habit dialog using web's glass-card aesthetic.
class AddHabitDialog extends ConsumerStatefulWidget {
  const AddHabitDialog({super.key});

  @override
  ConsumerState<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends ConsumerState<AddHabitDialog> {
  final _titleController = TextEditingController();
  final _targetController = TextEditingController(text: '30');
  final _titleFocusNode = FocusNode();
  final _targetFocusNode = FocusNode();
  String _selectedCategory = 'Health';
  String _selectedDifficulty = 'Standard';
  bool _isSaving = false;

  final List<String> _categories = [
    'Health',
    'Learning',
    'Productivity',
    'Mindfulness',
    'Finance',
    'Other',
    // Extensible/overlapping categories preserved for future use:
    // 'Fitness',      // Merged into Health
    // 'Deep Work',    // Merged into Productivity
    // 'Detox',        // Merged into Mindfulness
  ];
  
  final List<String> _complexities = ['Basic', 'Standard', 'Advanced', 'Elite'];

  @override
  void initState() {
    super.initState();
    _titleFocusNode.addListener(_onFocusChange);
    _targetFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _titleFocusNode.removeListener(_onFocusChange);
    _targetFocusNode.removeListener(_onFocusChange);
    _titleController.dispose();
    _targetController.dispose();
    _titleFocusNode.dispose();
    _targetFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(AppTheme.radiusXxl),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, spreadRadius: 0)
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create Protocol',
                  style: GoogleFonts.outfit(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textMain,
                    letterSpacing: -0.5,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: 0.7), size: 22.sp),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Designation Input
            _buildInputLabel('DESIGNATION'),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: _titleFocusNode.hasFocus
                        ? AppTheme.primary.withValues(alpha: 0.05)
                        : Colors.transparent,
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: TextField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                style: GoogleFonts.inter(
                  color: AppTheme.textMain,
                  fontSize: 16.sp,
                  height: 1.2,
                ),
                textAlignVertical: TextAlignVertical.center,
                autofocus: true,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'e.g. Morning Run',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15.sp),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  fillColor: Colors.white.withValues(alpha: 0.02),
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.25), width: 0.6),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Selection Row
            Row(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final fieldWidth = constraints.maxWidth;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('CLASSIFICATION'),
                          Theme(
                            data: Theme.of(context).copyWith(
                              scrollbarTheme: ScrollbarThemeData(
                                thumbVisibility: WidgetStateProperty.all(false),
                                trackVisibility: WidgetStateProperty.all(false),
                                thickness: WidgetStateProperty.all(0),
                              ),
                            ),
                            child: MenuAnchor(
                              style: MenuStyle(
                                backgroundColor: WidgetStateProperty.all(const Color(0xFF161616)),
                                elevation: WidgetStateProperty.all(12),
                                shadowColor: WidgetStateProperty.all(Colors.black.withValues(alpha: 0.5)),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    side: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1.0),
                                  ),
                                ),
                                maximumSize: WidgetStateProperty.all(Size(fieldWidth, 340.h)),
                                minimumSize: WidgetStateProperty.all(Size(fieldWidth, 0)),
                                padding: WidgetStateProperty.all(EdgeInsets.zero),
                              ),
                              builder: (BuildContext context, MenuController controller, Widget? child) {
                                return _buildSelectorButton(
                                  _selectedCategory,
                                  () {
                                    if (controller.isOpen) {
                                      controller.close();
                                    } else {
                                      controller.open();
                                    }
                                  },
                                  isOpen: controller.isOpen,
                                );
                              },
                              menuChildren: _categories.map((opt) {
                                final isSelected = opt == _selectedCategory;
                                return MenuItemButton(
                                  style: MenuItemButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                                    backgroundColor: isSelected ? AppTheme.primary.withValues(alpha: 0.04) : Colors.transparent,
                                  ),
                                  onPressed: () => setState(() => _selectedCategory = opt),
                                  child: SizedBox(
                                    width: fieldWidth - 32.w,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            opt,
                                            style: GoogleFonts.inter(
                                              color: isSelected ? AppTheme.primary : AppTheme.textMain,
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                              fontSize: 14.sp,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check_rounded,
                                            color: AppTheme.primary,
                                            size: 16.sp,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final fieldWidth = constraints.maxWidth;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('COMPLEXITY'),
                          Theme(
                            data: Theme.of(context).copyWith(
                              scrollbarTheme: ScrollbarThemeData(
                                thumbVisibility: WidgetStateProperty.all(false),
                                trackVisibility: WidgetStateProperty.all(false),
                                thickness: WidgetStateProperty.all(0),
                              ),
                            ),
                            child: MenuAnchor(
                              style: MenuStyle(
                                backgroundColor: WidgetStateProperty.all(const Color(0xFF161616)),
                                elevation: WidgetStateProperty.all(12),
                                shadowColor: WidgetStateProperty.all(Colors.black.withValues(alpha: 0.5)),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    side: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1.0),
                                  ),
                                ),
                                maximumSize: WidgetStateProperty.all(Size(fieldWidth, 340.h)),
                                minimumSize: WidgetStateProperty.all(Size(fieldWidth, 0)),
                                padding: WidgetStateProperty.all(EdgeInsets.zero),
                              ),
                              builder: (BuildContext context, MenuController controller, Widget? child) {
                                return _buildSelectorButton(
                                  _selectedDifficulty,
                                  () {
                                    if (controller.isOpen) {
                                      controller.close();
                                    } else {
                                      controller.open();
                                    }
                                  },
                                  isOpen: controller.isOpen,
                                );
                              },
                              menuChildren: _complexities.map((opt) {
                                final isSelected = opt == _selectedDifficulty;
                                return MenuItemButton(
                                  style: MenuItemButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                                    backgroundColor: isSelected ? AppTheme.primary.withValues(alpha: 0.04) : Colors.transparent,
                                  ),
                                  onPressed: () => setState(() => _selectedDifficulty = opt),
                                  child: SizedBox(
                                    width: fieldWidth - 32.w,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            opt,
                                            style: GoogleFonts.inter(
                                              color: isSelected ? AppTheme.primary : AppTheme.textMain,
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                              fontSize: 14.sp,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check_rounded,
                                            color: AppTheme.primary,
                                            size: 16.sp,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Target Input
            _buildInputLabel('MONTHLY TARGET (DAYS)'),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: _targetFocusNode.hasFocus
                        ? AppTheme.primary.withValues(alpha: 0.05)
                        : Colors.transparent,
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: TextField(
                controller: _targetController,
                focusNode: _targetFocusNode,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(
                  color: AppTheme.textMain,
                  fontSize: 16.sp,
                  height: 1.2,
                ),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  fillColor: Colors.white.withValues(alpha: 0.02),
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.25), width: 0.6),
                  ),
                ),
              ),
            ),
            SizedBox(height: 18.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      backgroundColor: Colors.white.withValues(alpha: 0.03),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1.0),
                      ),
                    ),
                    child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 16.sp)),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveHabit,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? SizedBox(width: 20.w, height: 20.h, child: const CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : Text('Save Protocol', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16.sp, letterSpacing: 0.2)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          color: AppTheme.textMuted,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSelectorButton(String value, VoidCallback onTap, {bool isOpen = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.inter(color: AppTheme.textMain, fontWeight: FontWeight.w600, fontSize: 15.sp),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AnimatedRotation(
              turns: isOpen ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white60,
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveHabit() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(habitServiceProvider).createHabit({
        'title': _titleController.text.trim(),
        'frequency': 'Daily', // Default for now
        'difficulty': _selectedDifficulty,
        'category': _selectedCategory,
        'icon': 'Zap',
        'color': '#FF6B2C',
      });
      ref.invalidate(habitsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
