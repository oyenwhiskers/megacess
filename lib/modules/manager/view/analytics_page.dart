import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/service/manager_dashboard_service.dart';
import '../data/model/task_analytics.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

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
      setState(() {
        _analytics = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildTaskSummary(TaskAnalytics t) {
    return Column(
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Total Tasks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(width: 6),
                    Icon(Icons.calendar_today, size: 18, color: Colors.grey[700]),
                  ],
                ),
                const SizedBox(height: 6),
                Text('${t.totalTasks}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatusCard('In-Progress', t.inProgress, Icons.play_arrow, Colors.green),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusCard('Pending', t.pending, Icons.pause_circle_filled, Colors.amber),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatusCard('Reject', t.rejected, Icons.cancel, Colors.red),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusCard('Completed', t.completed, Icons.check_circle, Colors.green),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(String label, int value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 2),
            Text('$value', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageLineChart({
    required String title,
    required List<double> monthlyData,
    required String unit,
    required Color color,
  }) {
    final months = ['Jan', 'Feb', 'Mar', 'April', 'May', 'June'];
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: (monthlyData.reduce((a, b) => a > b ? a : b) * 1.2).ceilToDouble(),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12)),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int idx = value.toInt();
                          if (idx >= 0 && idx < months.length) {
                            return Text(months[idx], style: const TextStyle(fontSize: 12));
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 28,
                        interval: 1,
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (int i = 0; i < monthlyData.length; i++)
                          FlSpot(i.toDouble(), monthlyData[i])
                      ],
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('Month of the year', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Text('Usage ($unit)', textAlign: TextAlign.left, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dummy monthly data for chart (replace with real if available)
    final fertilizerMonthly = [300.0, 200.0, 400.0, 220.0, 600.0, 500.0];
    final herbicideMonthly = [250.0, 180.0, 350.0, 210.0, 550.0, 430.0];
    final fuelMonthly = [320.0, 210.0, 410.0, 230.0, 620.0, 480.0];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7ED957),
        elevation: 0,
        title: const Text('Analytics', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _analytics == null
                  ? const Center(child: Text('No data'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTaskSummary(_analytics!.taskAnalytics),
                          const SizedBox(height: 16),
                          _buildUsageLineChart(
                            title: 'Fertilizer Usage',
                            monthlyData: fertilizerMonthly,
                            unit: _analytics!.usageAnalytics.fertilizerUsage.unit,
                            color: Colors.green,
                          ),
                          _buildUsageLineChart(
                            title: 'Herbicide Usage',
                            monthlyData: herbicideMonthly,
                            unit: _analytics!.usageAnalytics.herbicideUsage.unit,
                            color: Colors.blue,
                          ),
                          _buildUsageLineChart(
                            title: 'Fuel Usage',
                            monthlyData: fuelMonthly,
                            unit: _analytics!.usageAnalytics.fuelUsage.unit,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
    );
  }
}
