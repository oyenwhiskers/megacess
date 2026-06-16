import '../data/model/task_analytics.dart';
import '../data/service/manager_dashboard_service.dart';
import '../../authorization/view-model/login_view_model.dart';
import 'package:megacess/core/config/flavor_config.dart';

class ManagerDashboardViewModel {
  Future<void> logout() async {
    try {
      await LoginViewModel().logout();
    } catch (e) {
      // fallback: do nothing
    }
  }

  final ManagerDashboardService _service = ManagerDashboardService();
  TaskAnalytics? analytics;
  Map<String, dynamic>? profile;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadAnalytics() async {
    isLoading = true;
    errorMessage = null;
    try {
      analytics = await _service.fetchTaskAnalytics();
      profile = await _service.fetchProfile();
      if (analytics == null) {
        errorMessage = 'Failed to load analytics.';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
    }
    isLoading = false;
  }

  String? _getFullImageUrl(String? userImg) {
    if (userImg == null || userImg.isEmpty) {
      return null;
    }
    
    // Check if the URL already starts with http:// or https://
    if (userImg.startsWith('http://') || userImg.startsWith('https://')) {
      return userImg;
    }
    
    // If not, prepend the base URL
    return '${FlavorConfig.instance.baseDomain}/$userImg';
  }

  String? get profileImageUrl {
    return _getFullImageUrl(profile?['user_img']);
  }
}
