import 'package:flutter/material.dart';
import 'package:megacess/core/theme/app_colors.dart';
import 'package:megacess/core/theme/app_typography.dart';
import 'package:megacess/core/widgets/mega_app_header.dart';
import 'package:megacess/modules/checker/data/model/staff_detail_model.dart';
import 'package:megacess/modules/checker/data/service/attendance_service.dart';
import 'package:megacess/modules/utility/secure_storage_service.dart';

class ManageAttendanceStaffDetailView extends StatelessWidget {
  final int staffId;
  final int dateAttendanceId;

  const ManageAttendanceStaffDetailView({
    super.key,
    required this.staffId,
    required this.dateAttendanceId,
  });

  Future<void> _handleCheckIn(
    BuildContext context,
    int staffId,
    int dateAttendanceId,
  ) async {
    final now = DateTime.now();
    final checkInStr =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final response = await AttendanceService(SecureStorageService()).staffCheckIn(
      dateAttendanceId: dateAttendanceId,
      staffId: staffId,
      checkIn: checkInStr,
    );

    if (context.mounted && response['success'] == true) {
      await _showResultDialog(
        context,
        title: 'Check-in Recorded',
        message: response['message'] ?? 'Successfully checked in!',
        isSuccess: true,
      );
      if (context.mounted) Navigator.of(context).pop(true);
    } else if (context.mounted) {
      final errorMsg = response['message'] ?? 'Check-in failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.statusRejectedText,
        ),
      );
    }
  }

  Future<void> _handleCheckOut(
    BuildContext context,
    int staffId,
    int dateAttendanceId,
  ) async {
    final now = DateTime.now();
    final checkOutStr =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final response = await AttendanceService(SecureStorageService()).staffCheckOut(
      dateAttendanceId: dateAttendanceId,
      staffId: staffId,
      checkOut: checkOutStr,
    );

    if (context.mounted && response['success'] == true) {
      await _showResultDialog(
        context,
        title: 'Check-out Recorded',
        message: response['message'] ?? 'Successfully checked out!',
        isSuccess: true,
      );
      if (context.mounted) Navigator.of(context).pop(true);
    } else if (context.mounted) {
      final errorMsg = response['message'] ?? 'Check-out failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.statusRejectedText,
        ),
      );
    }
  }

  Future<void> _handleMarkAbsent(
    BuildContext context,
    int staffId,
    int dateAttendanceId,
  ) async {
    final response = await AttendanceService(SecureStorageService())
        .staffMarkAbsent(dateAttendanceId: dateAttendanceId, staffId: staffId);

    if (context.mounted && response['success'] == true) {
      await _showResultDialog(
        context,
        title: 'Absence Recorded',
        message: response['message'] ?? 'Staff marked as absent.',
        isSuccess: true,
      );
      if (context.mounted) Navigator.of(context).pop(true);
    } else if (context.mounted) {
      final errorMsg = response['message'] ?? 'Failed to mark as absent';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.statusRejectedText,
        ),
      );
    }
  }

  Future<void> _showResultDialog(
    BuildContext context, {
    required String title,
    required String message,
    required bool isSuccess,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSuccess
                      ? AppColors.statusCompletedBg
                      : AppColors.statusRejectedBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                  color: isSuccess
                      ? AppColors.statusCompletedText
                      : AppColors.statusRejectedText,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTypography.headingH3.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mcForestGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mcBgApp,
      appBar: MegaAppHeader(
        title: 'Staff Attendance',
        subtitle: 'Worker Profile & Actions',
        showBackButton: true,
      ),
      body: FutureBuilder<StaffDetailResponse>(
        future: AttendanceService(SecureStorageService()).fetchStaffDetail(
          staffId: staffId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.mcForestGreen),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.statusRejectedText,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyRegular.copyWith(
                        color: AppColors.statusRejectedText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mcForestGreen,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data?.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.textDisabled,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No staff data found.',
                    style: AppTypography.bodyRegular.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mcForestGreen,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final staff = snapshot.data!.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.mcBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: AppColors.frond50,
                        backgroundImage: staff.staffImg != null &&
                                staff.staffImg!.isNotEmpty
                            ? NetworkImage(staff.staffImg!)
                            : null,
                        child: staff.staffImg == null || staff.staffImg!.isEmpty
                            ? const Icon(
                                Icons.person_outline,
                                color: AppColors.mcForestGreen,
                                size: 42,
                              )
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        staff.staffFullname,
                        style: AppTypography.headingH3.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.frond50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.frond200),
                        ),
                        child: Text(
                          'STAFF ID: #${staff.staffId}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mcForestGreen,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Details Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.mcBorder),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Gender',
                        value: staff.staffGender ?? '-',
                      ),
                      const Divider(height: 20),
                      _DetailRow(
                        label: 'Age',
                        value: staff.age != null ? '${staff.age} years' : '-',
                      ),
                      const Divider(height: 20),
                      _DetailRow(
                        label: 'Date of Birth',
                        value: staff.staffDob ?? '-',
                      ),
                      const Divider(height: 20),
                      _DetailRow(
                        label: 'Phone Number',
                        value: staff.staffPhone ?? '-',
                      ),
                      const Divider(height: 20),
                      _DetailRow(
                        label: 'Attendance (This Month)',
                        value: '${staff.attendanceCountMonth ?? '-'}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.login, size: 18),
                        label: const Text('Check In'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mcForestGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () =>
                            _handleCheckIn(context, staffId, dateAttendanceId),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Check Out'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.mcForestDark,
                          side: const BorderSide(color: AppColors.mcBorder),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () =>
                            _handleCheckOut(context, staffId, dateAttendanceId),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Mark Absent'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.statusRejectedText,
                      side: const BorderSide(color: AppColors.statusRejectedBorder),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () =>
                        _handleMarkAbsent(context, staffId, dateAttendanceId),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.caption),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
