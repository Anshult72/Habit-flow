import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsModal extends ConsumerWidget {
  const NotificationsModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Container(
      padding: EdgeInsets.only(top: 24.h),
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
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('NOTIFICATIONS', style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppTheme.textMain, letterSpacing: 1.5)),
                GestureDetector(
                  onTap: () => ref.invalidate(notificationsProvider),
                  child: Icon(Icons.refresh_rounded, color: Colors.white54, size: 20.sp),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          Flexible(
            child: notificationsAsync.when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Center(
                      child: Text('No new alerts', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 14.sp)),
                    ),
                  );
                }
                
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                  itemBuilder: (context, index) {
                    final note = notifications[index];
                    return _buildNotificationTile(context, ref, note);
                  },
                );
              },
              loading: () => Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: const Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2)),
              ),
              error: (e, _) => Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Center(child: Text('Failed to load', style: GoogleFonts.inter(color: AppTheme.danger))),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, WidgetRef ref, NotificationModel note) {
    return GestureDetector(
      onTap: () {
        if (!note.isRead) {
          ref.read(notificationServiceProvider).markAsRead(note.id);
          // Invalidate later to refresh state after interaction
        }
      },
      child: Container(
        color: note.isRead ? Colors.transparent : AppTheme.primary.withValues(alpha: 0.05),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 2.h),
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: note.isRead ? Colors.transparent : AppTheme.primary,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(note.title, style: GoogleFonts.inter(color: AppTheme.textMain, fontWeight: note.isRead ? FontWeight.w500 : FontWeight.w700, fontSize: 14.sp)),
                  SizedBox(height: 4.h),
                  Text(note.message, style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13.sp, height: 1.4)),
                  SizedBox(height: 6.h),
                  Text(timeago.format(note.createdAt), style: GoogleFonts.inter(color: Colors.white38, fontSize: 10.sp)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
