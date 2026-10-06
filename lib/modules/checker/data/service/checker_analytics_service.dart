import '../model/checker_analytics.dart';
import '../../../utility/secure_storage_service.dart';
import '../../../utility/dio_client.dart';
import '../../../../core/config/flavor_config.dart';

class CheckerAnalyticsService {
  final DioClient _dioClient;

  CheckerAnalyticsService({DioClient? dioClient})
    : _dioClient =
          dioClient ??
          DioClient(
            baseUrl: FlavorConfig.instance.baseUrl,
            storageService: SecureStorageService(),
          );

  Future<CheckerAnalytics> fetchCheckerAnalytics() async {
    final response = await _dioClient.get('analytics/checker');
    if (response.statusCode == 200 &&
        response.data['success'] == true &&
        response.data['data'] != null) {
      return CheckerAnalytics.fromJson(response.data['data']);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthenticated: Please login again.');
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load analytics');
    }
  }

  Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      final response = await _dioClient.get('profile');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
    return null;
  }
}

