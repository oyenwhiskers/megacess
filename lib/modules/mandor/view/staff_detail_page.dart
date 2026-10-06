import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/mega_app_header.dart';
import '../../../core/widgets/mega_status_badge.dart';
import '../data/model/staff_model.dart';
import '../data/service/staff_service.dart';

class StaffDetailPage extends StatefulWidget {
  final int staffId;
  const StaffDetailPage({super.key, required this.staffId});

  @override
  State<StaffDetailPage> createState() => _StaffDetailPageState();
}

class _StaffDetailPageState extends State<StaffDetailPage> {
  StaffModel? staff;
  bool isLoading = true;
  final StaffService _staffService = StaffService();

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => isLoading = true);
    staff = await _staffService.getStaffDetail(widget.staffId);
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  int getAge(String dob) {
    try {
      final birthDate = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mcBgApp,
      body: SafeArea(
        child: Column(
          children: [
            MegaAppHeader(
              title: 'Staff Profile',
              subtitle: 'Worker information & history',
              showBackButton: true,
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.mcForestGreen,
                      ),
                    )
                  : staff == null
                  ? Center(
                      child: Text(
                        'Staff not found',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.mcTextMuted,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        children: [
                          // Profile Hero Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.mcBorder,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.mcForestGreen
                                          .withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 46,
                                    backgroundColor: AppColors.mcForestGreen
                                        .withOpacity(0.08),
                                    child: staff!.staffImg.isNotEmpty
                                        ? ClipOval(
                                            child: Image.network(
                                              staff!.staffImg,
                                              width: 92,
                                              height: 92,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.person_rounded,
                                                  size: 48,
                                                  color: AppColors.mcForestGreen,
                                                );
                                              },
                                            ),
                                          )
                                        : const Icon(
                                            Icons.person_rounded,
                                            size: 48,
                                            color: AppColors.mcForestGreen,
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  staff!.staffFullname,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.headingLarge.copyWith(
                                    fontSize: 18,
                                    color: AppColors.mcTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                MegaStatusBadge(
                                  status: 'Active Staff',
                                  color: AppColors.mcForestGreen,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Details Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.mcBorder,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Personal Information',
                                  style: AppTypography.labelLarge.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.mcTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildDetailRow(
                                  icon: Icons.wc_rounded,
                                  label: 'Gender',
                                  value: staff!.staffGender.isNotEmpty
                                      ? staff!.staffGender
                                      : 'Not specified',
                                ),
                                const Divider(
                                  height: 24,
                                  color: AppColors.mcBorder,
                                ),
                                _buildDetailRow(
                                  icon: Icons.cake_outlined,
                                  label: 'Age',
                                  value: staff!.staffDob.isNotEmpty
                                      ? '${getAge(staff!.staffDob)} years old'
                                      : '-',
                                ),
                                const Divider(
                                  height: 24,
                                  color: AppColors.mcBorder,
                                ),
                                _buildDetailRow(
                                  icon: Icons.phone_outlined,
                                  label: 'Phone Number',
                                  value: staff!.staffPhone.isNotEmpty
                                      ? staff!.staffPhone
                                      : 'None',
                                ),
                                const Divider(
                                  height: 24,
                                  color: AppColors.mcBorder,
                                ),
                                _buildDetailRow(
                                  icon: Icons.calendar_month_outlined,
                                  label: 'Attendance (This Month)',
                                  value: staff!.attendanceCountMonth != null
                                      ? '${staff!.attendanceCountMonth} days present'
                                      : '-',
                                  highlight: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: highlight ? AppColors.mcForestGreen : AppColors.mcTextMuted,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.mcTextMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight:
                      highlight ? FontWeight.w700 : FontWeight.w500,
                  color: highlight
                      ? AppColors.mcForestGreen
                      : AppColors.mcTextPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
