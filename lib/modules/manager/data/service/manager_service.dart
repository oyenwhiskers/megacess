import '../model/manager_models.dart';
import '../../../utility/dio_client.dart';
import '../../../utility/secure_storage_service.dart';
import '../../../../core/config/flavor_config.dart';
import 'package:dio/dio.dart';

class ManagerService {
  final DioClient _dioClient;

  ManagerService({DioClient? dioClient})
    : _dioClient =
          dioClient ??
          DioClient(
            baseUrl: FlavorConfig.instance.baseUrl,
            storageService: SecureStorageService(),
          );

  // Get manager statistics from real API
  Future<ManagerStats> getManagerStats() async {
    try {
      print('Fetching manager analytics from API...');
      final response = await _dioClient.get('analytics/manager');
      print('Manager analytics API response: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ManagerStats.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Failed to fetch manager analytics: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } on DioException catch (e) {
      print('DioException in getManagerStats: ${e.message}');
      print('DioException response: ${e.response?.data}');
      if (e.response != null && e.response?.data != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch manager analytics',
        );
      }
      throw Exception('Network error: Failed to fetch manager analytics');
    } catch (e) {
      print('Error in getManagerStats: $e');
      throw Exception('Failed to fetch manager analytics: $e');
    }
  }

  // Manager profile methods
  Future<ManagerProfile> fetchProfile() async {
    try {
      final response = await _dioClient.get('profile');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ManagerProfile.fromJson(response.data['data']);
      }
      throw Exception('Failed to fetch manager profile');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch manager profile',
        );
      }
      throw Exception('Network error: Failed to fetch manager profile');
    }
  }

  Future<ManagerProfile> updateProfile(Map<String, dynamic> updateData) async {
    try {
      final response = await _dioClient.post('profile', data: updateData);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ManagerProfile.fromJson(response.data['data']);
      }
      throw Exception('Failed to update manager profile');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to update manager profile',
        );
      }
      throw Exception('Network error: Failed to update manager profile');
    }
  }

  // Analytics methods
  Future<Map<String, dynamic>> fetchManagerAnalytics() async {
    try {
      final response = await _dioClient.get('analytics/manager');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      }
      throw Exception('Failed to fetch manager analytics');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch manager analytics',
        );
      }
      throw Exception('Network error: Failed to fetch manager analytics');
    }
  }

  Future<Map<String, dynamic>> fetchUsageBreakdown() async {
    try {
      final response = await _dioClient.get('analytics/usage-breakdown');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      }
      throw Exception('Failed to fetch usage breakdown');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch usage breakdown',
        );
      }
      throw Exception('Network error: Failed to fetch usage breakdown');
    }
  }

  // Task management methods
  Future<LocationTasksBreakdownResponse> fetchLocationTasksBreakdown(
    int locationId,
  ) async {
    try {
      final response = await _dioClient.get(
        'tasks/location/$locationId/breakdown-by-location',
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return LocationTasksBreakdownResponse.fromJson(response.data);
      }
      throw Exception('Failed to fetch location tasks breakdown');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ??
              'Failed to fetch location tasks breakdown',
        );
      }
      throw Exception(
        'Network error: Failed to fetch location tasks breakdown',
      );
    }
  }

  // Location management methods
  Future<List<LocationItem>> fetchLocations() async {
    try {
      final response = await _dioClient.get('locations');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'];
        return data.map((json) => LocationItem.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch locations');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch locations',
        );
      }
      throw Exception('Network error: Failed to fetch locations');
    }
  }

  Future<LocationItem> createLocation(String name, String description) async {
    try {
      final response = await _dioClient.post(
        'locations',
        data: {'name': name, 'description': description},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return LocationItem.fromJson(response.data['data']);
      }
      throw Exception('Failed to create location');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to create location',
        );
      }
      throw Exception('Network error: Failed to create location');
    }
  }

  Future<bool> deleteLocation(int locationId) async {
    try {
      final response = await _dioClient.delete('locations/$locationId');
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to delete location',
        );
      }
      throw Exception('Network error: Failed to delete location');
    }
  }

  Future<LocationItem> updateLocation(
    int locationId,
    String name,
    String description,
  ) async {
    try {
      final response = await _dioClient.put(
        'locations/$locationId',
        data: {'name': name, 'description': description},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return LocationItem.fromJson(response.data['data']);
      }
      throw Exception('Failed to update location');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to update location',
        );
      }
      throw Exception('Network error: Failed to update location');
    }
  }

  // Demo methods for task management (keeping for compatibility)
  Future<List<TaskItem>> getAllTasks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  Future<List<TaskItem>> getTasksByStatus(String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  Future<bool> addTask(TaskItem task) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<bool> updateTaskStatus(int taskId, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<bool> deleteTask(int taskId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}


