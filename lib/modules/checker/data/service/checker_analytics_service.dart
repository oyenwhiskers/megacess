import '../model/checker_analytics.dart';
import '../../../utility/dio_client.dart';
import '../../../utility/secure_storage_service.dart';

class CheckerAnalyticsService {
  final DioClient _dioClient;

  CheckerAnalyticsService({DioClient? dioClient})
    : _dioClient =
          dioClient ??
          DioClient(
            baseUrl: 'https://mwms.megacess.com/api/',
            storageService: SecureStorageService(),
          );

  Future<CheckerAnalytics> fetchCheckerAnalytics() async {
    final response = await _dioClient.get('v1/analytics/checker');
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
      final response = await _dioClient.get('v1/profile');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
    return null;
  }
}
