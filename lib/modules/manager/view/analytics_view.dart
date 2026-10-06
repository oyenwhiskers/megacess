import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/mega_app_header.dart';
import '../data/model/manager_models.dart';
import '../data/service/manager_service.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  late Future<Map<String, dynamic>> _analyticsFuture;
  late Future<Map<String, dynamic>> _usageBreakdownFuture;
  final ManagerService _managerService = ManagerService();

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _managerService.fetchManagerAnalytics();
    _usageBreakdownFuture = _managerService.fetchUsageBreakdown();
  }

  void _refreshAnalytics() {
    setState(() {
      _analyticsFuture = _managerService.fetchManagerAnalytics();
      _usageBreakdownFuture = _managerService.fetchUsageBreakdown();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mcBgApp,
      body: SafeArea(
        child: Column(
          children: [
            MegaAppHeader(
              title: 'Analytics',
              subtitle: 'Operations & resource breakdown',
              showBackButton: true,
            ),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _analyticsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.mcForestGreen,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 54,
                            color: AppColors.mcStatusRed.withOpacity(0.8),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load analytics',
                            style: AppTypography.headingLarge.copyWith(
                              fontSize: 18,
                              color: AppColors.mcStatusRed,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.mcTextMuted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshAnalytics,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mcForestGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
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

                  final rawData = snapshot.data!;
                  final dataSection = rawData['data'] ?? {};
                  final taskAnalyticsData = dataSection['task_analytics'] ?? {};

                  final taskAnalytics = TaskAnalytics(
                    totalTasks: taskAnalyticsData['total_tasks'] ?? 0,
                    pending: taskAnalyticsData['pending'] ?? 0,
                    inProgress: taskAnalyticsData['in_progress'] ?? 0,
                    completed: taskAnalyticsData['completed'] ?? 0,
                    rejected: taskAnalyticsData['rejected'] ?? 0,
                  );

                  final pending = taskAnalytics.pending;
                  final completed = taskAnalytics.completed;
                  final totalTasks = pending + completed;

                  return RefreshIndicator(
                    onRefresh: () async {
                      _refreshAnalytics();
                    },
                    color: AppColors.mcForestGreen,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Total Tasks Top Hero Card
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
                                    color: AppColors.mcForestGreen
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.analytics_outlined,
                                    color: AppColors.mcForestGreen,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TOTAL ASSIGNED TASKS',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.mcTextMuted,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${taskAnalytics.totalTasks}',
                                      style:
                                          AppTypography.headingLarge.copyWith(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.mcTextPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 2x2 Grid of Statuses
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  title: 'In-Progress',
                                  value: '${taskAnalytics.inProgress}',
                                  icon: Icons.trending_up_rounded,
                                  color: AppColors.mcStatusBlue,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Pending',
                                  value: '${taskAnalytics.pending}',
                                  icon: Icons.hourglass_top_rounded,
                                  color: AppColors.mcStatusOrange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Completed',
                                  value: '${taskAnalytics.completed}',
                                  icon: Icons.check_circle_rounded,
                                  color: AppColors.mcForestGreen,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Rejected',
                                  value: '${taskAnalytics.rejected}',
                                  icon: Icons.cancel_rounded,
                                  color: AppColors.mcStatusRed,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Pie Chart Section
                          if (totalTasks > 0) ...[
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
                                    'Pending vs Completed Tasks',
                                    style: AppTypography.labelLarge.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.mcTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Center(
                                    child: SizedBox(
                                      height: 180,
                                      width: 180,
                                      child: PieChart(
                                        PieChartData(
                                          sections: _buildPieChartSections(
                                            pending,
                                            completed,
                                          ),
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
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Usage Breakdown Analytics
                          FutureBuilder<Map<String, dynamic>>(
                            future: _usageBreakdownFuture,
                            builder: (context, usageSnapshot) {
                              if (usageSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: CircularProgressIndicator(
                                      color: AppColors.mcForestGreen,
                                    ),
                                  ),
                                );
                              } else if (usageSnapshot.hasError) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.mcStatusRed.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.mcStatusRed
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    'Failed to load usage breakdown: ${usageSnapshot.error}',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.mcStatusRed,
                                    ),
                                  ),
                                );
                              } else if (!usageSnapshot.hasData) {
                                return const SizedBox.shrink();
                              }

                              final usageData =
                                  usageSnapshot.data!['data'] ?? {};
                              final fertilizerBreakdown =
                                  usageData['fertilizer_breakdown']
                                          as List<dynamic>? ??
                                      [];
                              final herbicideBreakdown =
                                  usageData['herbicide_breakdown']
                                          as List<dynamic>? ??
                                      [];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'RESOURCE USAGE BY LOCATION',
                                    style: AppTypography.labelLarge.copyWith(
                                      color: AppColors.mcTextMuted,
                                      fontSize: 12,
                                      letterSpacing: 0.8,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Fertilizer Breakdown
                                  if (fertilizerBreakdown.isNotEmpty) ...[
                                    _buildUsageBreakdownCard(
                                      title: 'Fertilizer Usage',
                                      data: fertilizerBreakdown,
                                      unit: 'kg',
                                      color: AppColors.mcForestGreen,
                                      icon: Icons.grass_rounded,
                                      showTypeBreakdown: true,
                                    ),
                                    const SizedBox(height: 14),
                                  ],

                                  // Herbicide Breakdown
                                  if (herbicideBreakdown.isNotEmpty) ...[
                                    _buildUsageBreakdownCard(
                                      title: 'Herbicide Usage',
                                      data: herbicideBreakdown,
                                      unit: 'L',
                                      color: AppColors.mcStatusBlue,
                                      icon: Icons.water_drop_rounded,
                                      showTypeBreakdown: false,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mcBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
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
                Text(
                  value,
                  style: AppTypography.headingLarge.copyWith(
                    fontSize: 18,
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

  List<PieChartSectionData> _buildPieChartSections(int pending, int completed) {
    final total = pending + completed;
    if (total == 0) return [];

    final pendingRatio = (pending / total * 100);
    final completedRatio = (completed / total * 100);

    return [
      PieChartSectionData(
        value: pendingRatio,
        color: AppColors.mcStatusOrange,
        title: pendingRatio > 5 ? '${pendingRatio.toStringAsFixed(0)}%' : '',
        titleStyle: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontSize: 12,
        ),
        radius: 46,
      ),
      PieChartSectionData(
        value: completedRatio,
        color: AppColors.mcForestGreen,
        title:
            completedRatio > 5 ? '${completedRatio.toStringAsFixed(0)}%' : '',
        titleStyle: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontSize: 12,
        ),
        radius: 46,
      ),
    ];
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

  Widget _buildUsageBreakdownCard({
    required String title,
    required List<dynamic> data,
    required String unit,
    required Color color,
    required IconData icon,
    required bool showTypeBreakdown,
  }) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mcTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...data.map(
            (item) => _buildLocationUsageItem(
              locationName: item['location_name'] ?? 'Unknown',
              totalAmount: item['total_amount'] ?? 0,
              taskCount: item['task_count'] ?? 0,
              unit: unit,
              color: color,
              typeBreakdown: showTypeBreakdown ? item['by_type'] : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationUsageItem({
    required String locationName,
    required num totalAmount,
    required int taskCount,
    required String unit,
    required Color color,
    Map<String, dynamic>? typeBreakdown,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.mcBgApp,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.mcBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locationName,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.mcTextPrimary,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$totalAmount $unit',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    '$taskCount task${taskCount != 1 ? 's' : ''}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.mcTextMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (typeBreakdown != null) ...[
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.mcBorder),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: typeBreakdown.entries
                  .where((entry) => entry.value['amount'] > 0)
                  .map(
                    (entry) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: color.withOpacity(0.2)),
                      ),
                      child: Text(
                        '${entry.key}: ${entry.value['amount']} $unit',
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
