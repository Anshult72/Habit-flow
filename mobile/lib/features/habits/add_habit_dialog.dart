import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../services/habit_service.dart';

/// Add habit dialog using web's glass-card aesthetic.
class AddHabitDialog extends ConsumerStatefulWidget {
  const AddHabitDialog({super.key});

  @override
  ConsumerState<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends ConsumerState<AddHabitDialog> {
  final _titleController = TextEditingController();
  String _selectedFrequency = 'Daily';
  String _selectedDifficulty = 'Medium';
  String _selectedIcon = 'Zap';
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20.h,
        left: 20.w,
        right: 20.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
        border: Border(top: BorderSide(color: AppTheme.surfaceBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36.w, height: 4.h,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(2.r)),
            ),
          ),
          SizedBox(height: 20.h),

          Text('DEPLOY NEW PROTOCOL', style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppTheme.textMain, letterSpacing: 1)),
          SizedBox(height: 20.h),

          // Title
          TextField(
            controller: _titleController,
            style: GoogleFonts.inter(color: AppTheme.textMain, fontSize: 15.sp),
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'e.g. Deep Work, Morning Run, Read 30 min',
            ),
          ),
          SizedBox(height: 16.h),

          // Icons
          Text('ICON', style: AppTheme.labelStyle()),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 6.w,
            children: ['Zap', 'Book', 'Gym', 'Water', 'Code', 'Run'].map((icon) {
              final isSelected = _selectedIcon == icon;
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = icon),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: isSelected ? Border.all(color: AppTheme.primary.withValues(alpha: 0.4)) : null,
                  ),
                  child: Icon(_getIcon(icon), color: isSelected ? AppTheme.primary : Colors.white38, size: 20.sp),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),

          // Dropdowns
          Row(
            children: [
              Expanded(child: _buildDropdown('FREQUENCY', ['Daily', 'Weekly'], _selectedFrequency, (v) => setState(() => _selectedFrequency = v!))),
              SizedBox(width: 10.w),
              Expanded(child: _buildDropdown('DIFFICULTY', ['Easy', 'Medium', 'Hard', 'Elite'], _selectedDifficulty, (v) => setState(() => _selectedDifficulty = v!))),
            ],
          ),
          SizedBox(height: 24.h),

          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveHabit,
              child: _isSaving
                  ? SizedBox(width: 20.w, height: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('DEPLOY', style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.labelStyle()),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: AppTheme.surfaceBorder),
          ),
          child: DropdownButton<String>(
            value: value,
            items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.inter(fontSize: 13.sp)))).toList(),
            onChanged: onChanged,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF0A0A0A),
            style: GoogleFonts.inter(color: AppTheme.textMain, fontSize: 13.sp),
            icon: Icon(Icons.expand_more, color: AppTheme.textMuted, size: 18.sp),
          ),
        ),
      ],
    );
  }

  Future<void> _saveHabit() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(habitServiceProvider).createHabit({
        'title': _titleController.text.trim(),
        'frequency': _selectedFrequency,
        'difficulty': _selectedDifficulty,
        'icon': _selectedIcon,
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

  IconData _getIcon(String name) {
    switch (name.toLowerCase()) {
      case 'zap': return Icons.bolt_rounded;
      case 'book': return Icons.menu_book_rounded;
      case 'gym': return Icons.fitness_center_rounded;
      case 'water': return Icons.water_drop_rounded;
      case 'code': return Icons.code_rounded;
      case 'run': return Icons.directions_run_rounded;
      default: return Icons.star_rounded;
    }
  }
}
