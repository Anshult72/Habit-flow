import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  final UserModel user;

  const EditProfileDialog({super.key, required this.user});

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  String? _selectedAvatarUrl;
  bool _isSaving = false;

  // Preserving preset selection configuration in local state variables for modular future reactivation
  // ignore: unused_field
  final bool _showAvatarSelector = false;

  // Preset stylized profile avatars preserved in codebase for future avatar marketplace
  // ignore: unused_field
  final List<String> _presetAvatars = [
    'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=150&fit=crop', // Cyber Operator
    'https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?w=150&fit=crop', // Neon Valkyrie
    'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=150&fit=crop', // Solar Phoenix
    'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=150&fit=crop', // Shadow Ninja
    'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=150&fit=crop', // Cosmic Voyager
    'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?w=150&fit=crop', // Alpha Wolf
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name ?? '');
    _cityController = TextEditingController(text: widget.user.city ?? '');
    _stateController = TextEditingController(text: widget.user.state ?? '');
    _selectedAvatarUrl = widget.user.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  // Requests camera permissions and opens device camera
  Future<void> _handleTakePhoto() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      try {
        final picker = ImagePicker();
        final image = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 85,
        );
        if (image != null) {
          setState(() {
            _selectedAvatarUrl = image.path;
          });
          _showSuccessToast('Photo captured successfully');
        }
      } catch (e) {
        _showErrorSnackBar('Failed to access camera: $e');
      }
    } else {
      await _showPermissionDeniedDialog(
        title: 'Camera Access Required',
        message: 'Camera access is required to capture a profile photo.',
      );
    }
  }

  // Requests photo permissions and opens image gallery picker
  Future<void> _handleChooseFromGallery() async {
    // Determine the photo permission based on platform version
    PermissionStatus status;
    if (Platform.isAndroid) {
      status = await Permission.photos.request();
      if (status.isDenied) {
        // Fallback for older Android SDKs
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.photos.request();
    }

    if (status.isGranted || status.isLimited) {
      try {
        final picker = ImagePicker();
        final image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 85,
        );
        if (image != null) {
          setState(() {
            _selectedAvatarUrl = image.path;
          });
          _showSuccessToast('Photo selected successfully');
        }
      } catch (e) {
        _showErrorSnackBar('Failed to open gallery: $e');
      }
    } else {
      await _showPermissionDeniedDialog(
        title: 'Gallery Access Required',
        message: 'Gallery access is required to choose a profile photo.',
      );
    }
  }

  // Renders a premium dialog explaining how to enable permissions if denied
  Future<void> _showPermissionDeniedDialog({
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: const Color(0xFF0F0F0F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1.w),
          ),
          title: Row(
            children: [
              Icon(Icons.shield_outlined, color: const Color(0xFFFF7E47), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE25B20),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              ),
              child: Text(
                'Grant Permission',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Displays Image Selection source modal (Take Photo / Choose from Gallery / Remove)
  void _showImageSourceSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UPDATE PROFILE PHOTO',
              style: GoogleFonts.outfit(
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white38,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 16.h),
            _buildSourceOption(
              icon: Icons.camera_alt_rounded,
              label: 'Take Photo',
              onTap: () {
                Navigator.pop(context);
                _handleTakePhoto();
              },
            ),
            SizedBox(height: 6.h),
            _buildSourceOption(
              icon: Icons.photo_library_rounded,
              label: 'Choose from Gallery',
              onTap: () {
                Navigator.pop(context);
                _handleChooseFromGallery();
              },
            ),
            if (_selectedAvatarUrl != null) ...[
              SizedBox(height: 6.h),
              _buildSourceOption(
                icon: Icons.delete_outline_rounded,
                label: 'Remove Current Photo',
                isDanger: true,
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedAvatarUrl = null;
                  });
                  _showSuccessToast('Profile photo removed');
                },
              ),
            ],
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white38,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final activeColor = isDanger ? AppTheme.danger : const Color(0xFFE25B20);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.04),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: activeColor),
            SizedBox(width: 12.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isDanger ? Colors.redAccent : Colors.white,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, size: 16.sp, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  void _showSuccessToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 16.sp),
            SizedBox(width: 8.w),
            Text(msg, style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
        backgroundColor: const Color(0xFFE25B20),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.white)),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(userServiceProvider).updateProfile({
        'name': _nameController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'avatarUrl': _selectedAvatarUrl,
      });
      ref.invalidate(userProfileProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Update failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Modal Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'EDIT PROFILE',
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Premium Photo Editing and Circular Avatar Preview
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showImageSourceSelector, // Trigger real native camera/gallery options
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFE25B20).withValues(alpha: 0.4),
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFE25B20).withValues(alpha: 0.08),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 46.r,
                                backgroundColor: Colors.white.withValues(alpha: 0.04),
                                backgroundImage: _selectedAvatarUrl != null
                                    ? (_selectedAvatarUrl!.startsWith('http')
                                        ? NetworkImage(_selectedAvatarUrl!)
                                        : FileImage(File(_selectedAvatarUrl!)) as ImageProvider)
                                    : null,
                                child: _selectedAvatarUrl == null
                                    ? Icon(Icons.person_rounded, size: 40.sp, color: Colors.white30)
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE25B20),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  size: 13.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: _showImageSourceSelector, // Trigger real native camera/gallery options
                        child: Text(
                          'Change Photo',
                          style: GoogleFonts.outfit(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFFF7E47),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18.h),

                // Form Fields
                _buildField('DISPLAY NAME', _nameController),
                SizedBox(height: 14.h),

                Row(
                  children: [
                    Expanded(child: _buildField('CITY', _cityController)),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildField('STATE', _stateController)),
                  ],
                ),
                SizedBox(height: 24.h),

                // Save Changes Premium CTA
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE25B20),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: 18.w,
                            height: 18.h,
                            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'SAVE CHANGES',
                            style: GoogleFonts.outfit(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 9.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white38,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.02),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Color(0xFFE25B20), width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
