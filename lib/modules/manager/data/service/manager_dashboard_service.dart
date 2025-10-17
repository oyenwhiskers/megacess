import 'package:dio/dio.dart';
import '../model/task_analytics.dart';
import '../../../utility/dio_client.dart';
import '../../../utility/secure_storage_service.dart';

class ManagerDashboardService {
  final DioClient _dioClient = DioClient(
    baseUrl: 'https://mwms.megacess.com/api/',
    storageService: SecureStorageService(),
  );

  Future<TaskAnalytics?> fetchTaskAnalytics() async {
    final response = await _dioClient.get('v1/analytics/manager');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data']['task_analytics'];
      return TaskAnalytics.fromJson(data);
    }
    return null;
  }
}
