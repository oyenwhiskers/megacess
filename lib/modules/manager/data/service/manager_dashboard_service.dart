import 'package:dio/dio.dart';
import '../model/task_analytics.dart';
import '../model/task_model.dart';
import '../model/task_preview_model.dart';
import '../model/task_log_model.dart';
import '../../../utility/dio_client.dart';
import '../../../utility/secure_storage_service.dart';

class ManagerDashboardService {
  Future<Map<String, dynamic>?> assignWorkersToTask({
    required int taskId,
    required List<Map<String, dynamic>> workers,
  }) async {
    final response = await _dioClient.post(
      'v1/tasks/$taskId/assign-workers',
      data: {
        'workers': workers,
      },
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data;
    }
    return null;
  }
  
  Future<Map<String, dynamic>> updateTask(int taskId, {
    String? taskName,
    String? taskType,
    String? taskDate,
  }) async {
    try {
      Map<String, dynamic> data = {};
      if (taskName != null) data['task_name'] = taskName;
      if (taskType != null) data['task_type'] = taskType;
      if (taskDate != null) data['task_date'] = taskDate;
      
      final response = await _dioClient.put('v1/tasks/$taskId', data: data);
      return {
        'statusCode': response.statusCode,
        'data': response.data,
      };
    } on DioException catch (e) {
      return {
        'statusCode': e.response?.statusCode ?? 500,
        'data': e.response?.data ?? {'success': false, 'message': e.message},
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'data': {'success': false, 'message': 'Failed to update task.', 'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> deleteTask(int taskId) async {
    try {
      final response = await _dioClient.delete('v1/tasks/$taskId');
      return {
        'statusCode': response.statusCode,
        'data': response.data,
      };
    } on DioException catch (e) {
      return {
        'statusCode': e.response?.statusCode ?? 500,
        'data': e.response?.data ?? {'success': false, 'message': e.message},
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'data': {'success': false, 'message': 'Failed to delete task.', 'error': e.toString()},
      };
    }
  }
  
  Future<Map<String, dynamic>> submitTaskToChecker(int taskId) async {
    try {
      final response = await _dioClient.post('v1/tasks/$taskId/submit');
      return {
        'statusCode': response.statusCode,
        'data': response.data,
      };
    } on DioException catch (e) {
      return {
        'statusCode': e.response?.statusCode ?? 500,
        'data': e.response?.data ?? {'success': false, 'message': e.message},
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'data': {'success': false, 'message': 'Failed to submit task.', 'error': e.toString()},
      };
    }
  }
  Future<List<TaskLogModel>> fetchTaskLogs(int taskId) async {
    final response = await _dioClient.get('v1/tasks/$taskId/logs');
    print('API LOGS RESPONSE: ${response.data}');
    if (response.statusCode == 200 && response.data['success'] == true && response.data['data'] != null) {
      final logsRaw = response.data['data'];
      if (logsRaw is List) {
        return logsRaw.map((e) => TaskLogModel.fromJson(e)).toList();
      } else {
        print('API LOGS: data is not a List');
      }
    } else {
      print('API LOGS: statusCode=${response.statusCode}, success=${response.data['success']}');
    }
    return [];
  }
  Future<TaskPreviewModel?> fetchTaskPreview(int taskId) async {
    final response = await _dioClient.get('v1/tasks/$taskId');
    if (response.statusCode == 200 && response.data['success'] == true && response.data['data'] != null) {
      return TaskPreviewModel.fromJson(response.data['data']);
    }
    return null;
  }

  Future<Map<String, dynamic>?> createTask({
    required int locationId,
    required String taskName,
    required String taskType,
    required String taskDate,
  }) async {
    final response = await _dioClient.post('v1/tasks', data: {
      'location_id': locationId,
      'task_name': taskName,
      'task_type': taskType,
      'task_date': taskDate,
      'task_status': 'in_progress',
    });
    // Return both statusCode and body for better success detection
    return {
      'statusCode': response.statusCode,
      ...?response.data as Map<String, dynamic>?
    };
  }

  Future<LocationTasksDetailResponse?> fetchLocationTasksDetail(int locationId) async {
    final response = await _dioClient.get('v1/locations/$locationId/tasks');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return LocationTasksDetailResponse.fromJson(response.data);
    }
    return null;
  }
  Future<LocationListResponse?> fetchLocations() async {
    final response = await _dioClient.get('v1/locations');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return LocationListResponse.fromJson(response.data);
    }
    return null;
  }
  Future<TaskListResponse?> fetchTasks() async {
    final response = await _dioClient.get('v1/tasks');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return TaskListResponse.fromJson(response.data);
    }
    return null;
  }
  final DioClient _dioClient = DioClient(
    baseUrl: 'https://mwms.megacess.com/api/',
    storageService: SecureStorageService(),
  );

  Future<AnalyticsResponse?> fetchAnalytics() async {
    final response = await _dioClient.get('v1/analytics/manager');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      return AnalyticsResponse.fromJson(data);
    }
    return null;
  }

  // Tetap pertahankan method lama jika masih dipakai di tempat lain
  Future<TaskAnalytics?> fetchTaskAnalytics() async {
    final response = await _dioClient.get('v1/analytics/manager');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data']['task_analytics'];
      return TaskAnalytics.fromJson(data);
    }
    return null;
  }
}
