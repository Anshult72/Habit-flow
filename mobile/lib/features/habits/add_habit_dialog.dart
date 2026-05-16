import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/hf_premium_widgets.dart';
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
  String _selectedCategory = 'Health';
  String _selectedDifficulty = 'Medium';
  bool _isSaving = false;

  final List<String> _categories = [
    'Health', 'Mindfulness', 'Learning', 'Fitness', 
    'Productivity', 'Finance', 'Deep Work', 'Detox'
  ];
  
  final List<String> _complexities = ['Easy', 'Medium', 'Hard', 'Elite'];

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24.h,
        left: 24.w,
        right: 24.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Initialize\nProtocol',
                style: GoogleFonts.outfit(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textMain,
                  height: 1.1,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: Colors.white38, size: 24.sp),
              ),
            ],
          ),
          SizedBox(height: 32.h),

          // Designation Input
          _buildInputLabel('DESIGNATION'),
          TextField(
            controller: _titleController,
            style: GoogleFonts.inter(color: AppTheme.textMain, fontSize: 16.sp),
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'e.g. Morning Run',
              hintStyle: const TextStyle(color: Colors.white10),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              fillColor: Colors.white.withValues(alpha: 0.03),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
            ),
          ),
          SizedBox(height: 24.h),

          // Selection Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('CLASSIFICATION'),
                    _buildSelectorButton(_selectedCategory, () => _showSelectionSheet('Classification', _categories, _selectedCategory, (v) => setState(() => _selectedCategory = v))),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('COMPLEXITY'),
                    _buildSelectorButton(_selectedDifficulty, () => _showSelectionSheet('Complexity', _complexities, _selectedDifficulty, (v) => setState(() => _selectedDifficulty = v))),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Target Input
          _buildInputLabel('MONTHLY TARGET (DAYS)'),
          TextField(
            controller: _targetController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(color: AppTheme.textMain, fontSize: 16.sp),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              fillColor: Colors.white.withValues(alpha: 0.03),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
            ),
          ),
          SizedBox(height: 32.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text('Abort', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 16.sp)),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveHabit,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: _isSaving
                      ? SizedBox(width: 20.w, height: 20.h, child: const CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : Text('Deploy', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16.sp)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
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

  Widget _buildSelectorButton(String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Text(
          value,
          style: GoogleFonts.inter(color: AppTheme.textMain, fontWeight: FontWeight.w600, fontSize: 15.sp),
        ),
      ),
    );
  }

  void _showSelectionSheet(String title, List<String> options, String currentValue, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HFGlassCard(
        borderRadius: AppTheme.radiusXl,
        padding: EdgeInsets.zero,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title.toUpperCase(), style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 2)),
              SizedBox(height: 20.h),
              ...options.map((opt) => ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
                title: Text(opt, style: GoogleFonts.inter(color: opt == currentValue ? AppTheme.primary : AppTheme.textMain, fontWeight: FontWeight.w500)),
                trailing: opt == currentValue ? Icon(Icons.check_circle, color: AppTheme.primary, size: 20.sp) : Icon(Icons.circle_outlined, color: Colors.white10, size: 20.sp),
                onTap: () {
                  onSelect(opt);
                  Navigator.pop(ctx);
                },
              )),
              SizedBox(height: 20.h),
            ],
          ),
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
