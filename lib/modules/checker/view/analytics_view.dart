import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/mega_app_header.dart';
import '../../../core/widgets/mega_status_badge.dart';
import '../../utility/secure_storage_service.dart';
import '../data/model/checker_analytics.dart';
import '../data/model/pending_task_model.dart';
import '../data/service/attendance_service.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final attendanceService = AttendanceService(SecureStorageService());

    return Scaffold(
      backgroundColor: AppColors.mcBgApp,
      body: SafeArea(
        child: Column(
          children: [
            MegaAppHeader(
              title: 'Analytics',
              subtitle: 'Verification & audit overview',
              showBackButton: true,
            ),
            Expanded(
              child: FutureBuilder<CheckerAnalytics>(
                future: attendanceService.fetchCheckerAnalytics(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.mcForestGreen,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Failed to load analytics: ${snapshot.error}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.mcStatusRed,
                          ),
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData) {
                    return Center(
                      child: Text(
                        'No analytics data found.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.mcTextMuted,
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final pending = data.pendingTaskCount;
                  final completed = data.completeTaskCount;
                  final absent = data.absentPeopleCount;
                  final totalTasks = pending + completed;
                  final pendingRatio = totalTasks > 0
                      ? (pending / totalTasks * 100)
                      : 0.0;
                  final completedRatio = totalTasks > 0
                      ? (completed / totalTasks * 100)
                      : 0.0;

                  return FutureBuilder<PendingTaskListResponse>(
                    future: attendanceService.fetchPendingTasks(),
                    builder: (context, pendingSnapshot) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top KPI Hero: Pending Approval
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.mcBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.mcStatusOrange
                                          .withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.hourglass_top_rounded,
                                      color: AppColors.mcStatusOrange,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'PENDING VERIFICATION',
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.mcTextMuted,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.6,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '$pending Tasks',
                                          style: AppTypography.headingLarge
                                              .copyWith(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.mcStatusOrange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // KPI Row: Completed & Absent
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMetricCard(
                                    title: 'Completed',
                                    value: '$completed',
                                    icon: Icons.check_circle_rounded,
                                    color: AppColors.mcForestGreen,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildMetricCard(
                                    title: 'Absent Staff',
                                    value: '$absent',
                                    icon: Icons.person_off_rounded,
                                    color: AppColors.mcStatusRed,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Ratio Chart Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.mcBorder),
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
                                    'Task Completion Ratio',
                                    style: AppTypography.labelLarge.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.mcTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  if (totalTasks == 0)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Text(
                                          'No task data available for ratio calculation',
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.mcTextMuted,
                                          ),
                                        ),
                                      ),
                                    )
                                  else ...[
                                    Center(
                                      child: SizedBox(
                                        height: 180,
                                        width: 180,
                                        child: PieChart(
                                          PieChartData(
                                            sections: [
                                              PieChartSectionData(
                                                value: pending.toDouble(),
                                                color: AppColors.mcStatusOrange,
                                                title: pendingRatio > 5
                                                    ? '${pendingRatio.toStringAsFixed(0)}%'
                                                    : '',
                                                titleStyle: AppTypography
                                                    .caption
                                                    .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                                radius: 46,
                                              ),
                                              PieChartSectionData(
                                                value: completed.toDouble(),
                                                color: AppColors.mcForestGreen,
                                                title: completedRatio > 5
                                                    ? '${completedRatio.toStringAsFixed(0)}%'
                                                    : '',
                                                titleStyle: AppTypography
                                                    .caption
                                                    .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                                radius: 46,
                                              ),
                                            ],
                                            sectionsSpace: 2,
                                            centerSpaceRadius: 36,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildLegendItem(
                                          color: AppColors.mcForestGreen,
                                          label: 'Completed ($completed)',
                                        ),
                                        _buildLegendItem(
                                          color: AppColors.mcStatusOrange,
                                          label: 'Pending ($pending)',
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Tasks to be verified section
                            Text(
                              'TASKS TO BE VERIFIED',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.mcTextMuted,
                                fontSize: 12,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (pendingSnapshot.connectionState ==
                                ConnectionState.waiting)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: CircularProgressIndicator(
                                    color: AppColors.mcForestGreen,
                                  ),
                                ),
                              )
                            else if (pendingSnapshot.hasError)
                              Center(
                                child: Text(
                                  'Failed to load pending tasks.',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.mcStatusRed,
                                  ),
                                ),
                              )
                            else if (pendingSnapshot.hasData &&
                                pendingSnapshot.data!.tasks.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.mcBorder),
                                ),
                                child: Center(
                                  child: Text(
                                    'No pending tasks to verify.',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.mcTextMuted,
                                    ),
                                  ),
                                ),
                              )
                            else if (pendingSnapshot.hasData)
                              ...pendingSnapshot.data!.tasks.map(
                                (task) => Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.mcBorder,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.mcForestGreen
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          task.taskName.split(' ').first,
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.mcForestGreen,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task.taskName,
                                              style: AppTypography.labelLarge
                                                  .copyWith(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.mcTextPrimary,
                                              ),
                                            ),
                                            if (task.taskDescription
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                task.taskDescription,
                                                style: AppTypography.caption
                                                    .copyWith(
                                                  color: AppColors.mcTextMuted,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      MegaStatusBadge(
                                        status: 'Pending',
                                        color: AppColors.mcStatusOrange,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mcBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.mcTextMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.headingLarge.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mcTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.mcTextPrimary,
          ),
        ),
      ],
    );
  }
}
