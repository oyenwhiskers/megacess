import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/mega_app_header.dart';
import '../data/service/manager_dashboard_service.dart';
import '../data/model/task_analytics.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final ManagerDashboardService _service = ManagerDashboardService();
  AnalyticsResponse? _analytics;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _service.fetchAnalytics();
      if (mounted) {
        setState(() {
          _analytics = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTaskSummary(TaskAnalytics t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Tasks Hero Card
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.mcForestGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_rounded,
                  color: AppColors.mcForestGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL SCHEDULED TASKS',
                    style: AppTypography.caption.copyWith(
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mcTextMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${t.totalTasks}',
                    style: AppTypography.headingLarge.copyWith(
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

        // Status 2x2 Grid
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                'In-Progress',
                t.inProgress,
                Icons.trending_up_rounded,
                AppColors.mcStatusBlue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatusCard(
                'Pending',
                t.pending,
                Icons.hourglass_top_rounded,
                AppColors.mcStatusOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                'Completed',
                t.completed,
                Icons.check_circle_rounded,
                AppColors.mcForestGreen,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatusCard(
                'Rejected',
                t.rejected,
                Icons.cancel_rounded,
                AppColors.mcStatusRed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
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
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.mcTextMuted,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$value',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
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

  Widget _buildUsageCard({
    required String title,
    required double totalAmount,
    required String unit,
    required int taskCount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mcTextPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      totalAmount.toStringAsFixed(1),
                      style: AppTypography.headingLarge.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.mcTextMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Utilized across $taskCount task${taskCount != 1 ? 's' : ''}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.mcTextMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
              subtitle: 'Operations & resource metrics',
              showBackButton: true,
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.mcForestGreen,
                      ),
                    )
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Error: $_error',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.mcStatusRed,
                          ),
                        ),
                      ),
                    )
                  : _analytics == null
                  ? Center(
                      child: Text(
                        'No analytics data available',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.mcTextMuted,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.mcForestGreen,
                      onRefresh: _fetchAnalytics,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTaskSummary(_analytics!.taskAnalytics),
                            const SizedBox(height: 20),
                            Text(
                              'RESOURCE USAGE SUMMARY',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.mcTextMuted,
                                fontSize: 12,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildUsageCard(
                              title: 'Fertilizer Usage',
                              totalAmount: _analytics!.usageAnalytics
                                  .fertilizerUsage.totalAmount,
                              unit: _analytics!
                                  .usageAnalytics.fertilizerUsage.unit,
                              taskCount: _analytics!
                                  .usageAnalytics.fertilizerUsage.taskCount,
                              color: AppColors.mcForestGreen,
                              icon: Icons.grass_rounded,
                            ),
                            _buildUsageCard(
                              title: 'Herbicide Usage',
                              totalAmount: _analytics!.usageAnalytics
                                  .herbicideUsage.totalAmount,
                              unit: _analytics!
                                  .usageAnalytics.herbicideUsage.unit,
                              taskCount: _analytics!
                                  .usageAnalytics.herbicideUsage.taskCount,
                              color: AppColors.mcStatusBlue,
                              icon: Icons.water_drop_rounded,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
