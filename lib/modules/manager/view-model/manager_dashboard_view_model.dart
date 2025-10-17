import '../data/model/task_analytics.dart';
import '../data/service/manager_dashboard_service.dart';

class ManagerDashboardViewModel {
  final ManagerDashboardService _service = ManagerDashboardService();
  TaskAnalytics? analytics;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadAnalytics() async {
    isLoading = true;
    errorMessage = null;
    try {
      analytics = await _service.fetchTaskAnalytics();
      if (analytics == null) {
        errorMessage = 'Failed to load analytics.';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
    }
    isLoading = false;
  }
}
