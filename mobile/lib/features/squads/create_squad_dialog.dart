import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../services/squad_service.dart';

class CreateSquadDialog extends ConsumerStatefulWidget {
  const CreateSquadDialog({super.key});

  @override
  ConsumerState<CreateSquadDialog> createState() => _CreateSquadDialogState();
}

class _CreateSquadDialogState extends ConsumerState<CreateSquadDialog> {
  final _nameController = TextEditingController();
  final _entryXpController = TextEditingController(text: '100');
  final _durationController = TextEditingController(text: '7');
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _entryXpController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final entryXp = int.tryParse(_entryXpController.text) ?? 100;
    final duration = int.tryParse(_durationController.text) ?? 7;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a squad name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(squadServiceProvider).createSquad(name, entryXp, duration);
      ref.invalidate(squadsProvider);
      if (mounted) Navigator.pop(context);
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
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
        border: const Border(top: BorderSide(color: AppTheme.surfaceBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          
          Text('FORM SQUAD', style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppTheme.textMain, letterSpacing: 1.5)),
          SizedBox(height: 24.h),

          _buildInput('SQUAD NAME', _nameController, TextInputType.text),
          SizedBox(height: 16.h),
          
          Row(
            children: [
              Expanded(child: _buildInput('ENTRY XP', _entryXpController, TextInputType.number)),
              SizedBox(width: 16.w),
              Expanded(child: _buildInput('DURATION (DAYS)', _durationController, TextInputType.number)),
            ],
          ),
          
          SizedBox(height: 32.h),

          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
              ),
              child: _isLoading
                  ? SizedBox(width: 20.w, height: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('CREATE SQUAD', style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w700, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.labelStyle()),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: type,
          style: GoogleFonts.inter(color: AppTheme.textMain, fontSize: 16.sp),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            fillColor: Colors.white.withValues(alpha: 0.03),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }
}
