import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF43C463),
        elevation: 0,
        title: const Text('Analytics', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF43C463)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load analytics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshAnalytics,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43C463),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No analytics data found.'));
          }

          final rawData = snapshot.data!;
          // Extract data from the API response structure
          final dataSection = rawData['data'] ?? {};
          final taskAnalyticsData = dataSection['task_analytics'] ?? {};

          // Convert the raw data to expected structure
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

          print('DEBUG: Manager Analytics loaded successfully!');
          print('DEBUG: Total Tasks: ${taskAnalytics.totalTasks}');
          print('DEBUG: Pending Tasks: $pending');
          print('DEBUG: Completed Tasks: $completed');

          return RefreshIndicator(
            onRefresh: () async {
              _refreshAnalytics();
            },
            color: const Color(0xFF43C463),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Task Analytics Cards
                  _buildStatCard(
                    title: 'Total Tasks',
                    value: '${taskAnalytics.totalTasks}',
                    icon: Icons.assignment,
                    color: Colors.black87,
                  ),
                  _buildStatCard(
                    title: 'Total In-Progress',
                    value: '${taskAnalytics.inProgress}',
                    icon: Icons.arrow_forward,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    title: 'Total Pending',
                    value: '${taskAnalytics.pending}',
                    icon: Icons.pause_circle,
                    color: Colors.orange,
                  ),
                  _buildStatCard(
                    title: 'Total Reject',
                    value: '${taskAnalytics.rejected}',
                    icon: Icons.cancel,
                    color: Colors.red,
                  ),
                  _buildStatCard(
                    title: 'Total Completed',
                    value: '${taskAnalytics.completed}',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),

                  const SizedBox(height: 20),

                  // Pending Tasks vs Completed Tasks Ratio
                  if (totalTasks > 0) ...[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Pending Tasks vs Completed Tasks Ratio',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF222B45),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 18),

                          SizedBox(
                            height: 260,
                            width: 260,
                            child: PieChart(
                              PieChartData(
                                sections: _buildPieChartSections(
                                  pending,
                                  completed,
                                ),
                                sectionsSpace: 0,
                                centerSpaceRadius: 0,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Legend
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 28,
                            runSpacing: 10,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7C948),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Total Pending Tasks',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF43C463),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Total Completed Tasks',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],

                  // Simple completion rate card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Task Completion Rate',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '$pending',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const Text('Pending'),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '$completed',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const Text('Completed'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Usage Breakdown Analytics
                  FutureBuilder<Map<String, dynamic>>(
                    future: _usageBreakdownFuture,
                    builder: (context, usageSnapshot) {
                      if (usageSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF43C463),
                          ),
                        );
                      } else if (usageSnapshot.hasError) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[300]!),
                          ),
                          child: Text(
                            'Failed to load usage breakdown: ${usageSnapshot.error}',
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        );
                      } else if (!usageSnapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      final usageData = usageSnapshot.data!['data'] ?? {};
                      final fertilizerBreakdown =
                          usageData['fertilizer_breakdown'] as List<dynamic>? ??
                          [];
                      final herbicideBreakdown =
                          usageData['herbicide_breakdown'] as List<dynamic>? ??
                          [];

                      return Column(
                        children: [
                          // Fertilizer Breakdown
                          if (fertilizerBreakdown.isNotEmpty) ...[
                            _buildUsageBreakdownCard(
                              title: 'Fertilizer Usage by Location',
                              data: fertilizerBreakdown,
                              unit: 'kg',
                              color: Colors.green,
                              icon: Icons.eco,
                              showTypeBreakdown: true,
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Herbicide Breakdown
                          if (herbicideBreakdown.isNotEmpty) ...[
                            _buildUsageBreakdownCard(
                              title: 'Herbicide Usage by Location',
                              data: herbicideBreakdown,
                              unit: 'L',
                              color: Colors.orange,
                              icon: Icons.local_florist,
                              showTypeBreakdown: false,
                            ),
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
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(int pending, int completed) {
    final total = pending + completed;

    // Debug output for pie chart data
    print('DEBUG: PIE CHART - Pending Tasks: $pending');
    print('DEBUG: PIE CHART - Completed Tasks: $completed');
    print('DEBUG: PIE CHART - Total Tasks: $total');

    if (total == 0) return [];

    final pendingRatio = (pending / total * 100);
    final completedRatio = (completed / total * 100);

    print(
      'DEBUG: PIE CHART - Pending Percentage: ${pendingRatio.toStringAsFixed(2)}%',
    );
    print(
      'DEBUG: PIE CHART - Completed Percentage: ${completedRatio.toStringAsFixed(2)}%',
    );

    return [
      PieChartSectionData(
        value: pendingRatio,
        color: const Color(0xFFF7C948),
        title: pendingRatio > 0 ? '${pendingRatio.toStringAsFixed(2)}%' : '',
        titleStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Color(0xFF222B45),
        ),
        radius: 110,
      ),
      PieChartSectionData(
        value: completedRatio,
        color: const Color(0xFF43C463),
        title: completedRatio > 0
            ? '${completedRatio.toStringAsFixed(2)}%'
            : '',
        titleStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.white,
        ),
        radius: 110,
      ),
    ];
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locationName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$totalAmount $unit',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '$taskCount task${taskCount != 1 ? 's' : ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          if (typeBreakdown != null) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: typeBreakdown.entries
                  .where((entry) => entry.value['amount'] > 0)
                  .map(
                    (entry) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${entry.key}: ${entry.value['amount']} $unit',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
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
