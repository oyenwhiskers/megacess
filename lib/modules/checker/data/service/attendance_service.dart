import 'package:megacess/modules/checker/data/model/audit_task_preview_model.dart';
import 'package:megacess/modules/checker/data/model/audit_task_model.dart';
import 'package:megacess/modules/checker/data/model/location_model.dart';
import 'package:megacess/modules/checker/data/model/pending_task_model.dart';
import 'package:megacess/modules/checker/data/model/checker_analytics.dart';
import 'package:megacess/modules/checker/data/model/staff_attendance_model.dart';
import 'package:megacess/modules/checker/data/model/user_attendance_model.dart';
import 'package:megacess/modules/checker/data/model/attendance_model.dart';
import 'package:megacess/modules/utility/dio_client.dart';
import 'package:megacess/modules/utility/secure_storage_service.dart';
import 'package:dio/dio.dart';

class AttendanceService {
  Future<AuditTaskPreviewModel?> fetchAuditTaskPreview(int taskId) async {
    try {
      final response = await dioClient.get('api/v1/tasks/$taskId');
      if (response.data is Map && response.data['success'] == true) {
        return AuditTaskPreviewModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch audit task preview');
      }
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch audit task preview');
      }
      throw Exception('Failed to fetch audit task preview');
    }
  }
  Future<AuditTaskLocationTasksResponse> fetchAuditLocationTasks(int locationId) async {
    try {
      final response = await dioClient.get('api/v1/locations/$locationId/tasks');
      if (response.data is Map && response.data['success'] == true) {
        return AuditTaskLocationTasksResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch audit tasks');
      }
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch audit tasks');
      }
      throw Exception('Failed to fetch audit tasks');
    }
  }
  Future<LocationListResponse> fetchLocationList() async {
    try {
      final response = await dioClient.get('api/v1/locations');
      if (response.data is Map && response.data['success'] == true) {
        return LocationListResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch locations');
      }
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch locations');
      }
      throw Exception('Failed to fetch locations');
    }
  }
  Future<PendingTaskListResponse> fetchPendingTasks() async {
    try {
      final response = await dioClient.get('api/v1/analytics/checker/pending-tasks');
      if (response.data is Map && response.data['success'] == true) {
        return PendingTaskListResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch pending tasks');
      }
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch pending tasks');
      }
      throw Exception('Failed to fetch pending tasks');
    }
  }
  Future<CheckerAnalytics> fetchCheckerAnalytics() async {
    try {
      final response = await dioClient.get('api/v1/analytics/checker');
      if (response.data is Map && response.data['success'] == true) {
        return CheckerAnalytics.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch analytics');
      }
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch analytics');
      }
      throw Exception('Failed to fetch analytics');
    }
  }
  Future<StaffAttendanceListResponse> fetchStaffAttendanceList({required int dateAttendanceId, int page = 1, int perPage = 15}) async {
    try {
      final response = await dioClient.get(
        'api/v1/staff-attendance',
        queryParameters: {
          'date_attendance_id': dateAttendanceId,
          'page': page,
          'per_page': perPage,
        },
      );
      if (response.data is Map && response.data['success'] == true) {
        return StaffAttendanceListResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch staff attendance');
      }
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch staff attendance');
      }
      throw Exception('Failed to fetch staff attendance');
    }
  }
  Future<UserAttendanceListResponse> fetchUserAttendanceList({required int dateAttendanceId, int page = 1, int perPage = 15}) async {
    try {
      final response = await dioClient.get(
        'api/v1/user-attendance',
        queryParameters: {
          'date_attendance_id': dateAttendanceId,
          'page': page,
          'per_page': perPage,
        },
      );
      if (response.data is Map && response.data['success'] == true) {
        return UserAttendanceListResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch user attendance');
      }
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch user attendance');
      }
      throw Exception('Failed to fetch user attendance');
    }
  }
  Future<Map<String, dynamic>> createAttendance({required String date}) async {
    try {
      final response = await dioClient.post(
        '/api/v1/attendance',
        data: {'date': date},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
  final DioClient dioClient;

  AttendanceService(SecureStorageService storageService)
      : dioClient = DioClient(
          baseUrl: 'https://mwms.megacess.com/',
          storageService: storageService,
        );

  Future<AttendanceListResponse> fetchAttendanceList({int page = 1, int perPage = 15, String? search}) async {
    try {
  final response = await this.dioClient.get(
        'api/v1/attendance',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      return AttendanceListResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> deleteAttendance(int id) async {
    try {
      final response = await dioClient.delete('api/v1/attendance/$id');
      if (response.data is Map) {
        final data = response.data as Map;
        if (data['success'] == false && data['message'] != null) {
          return data['message'].toString();
        }
        if (data['message'] != null) {
          return data['message'].toString();
        }
      }
      return 'Attendance deleted.';
    } catch (e) {
      // If Dio throws, try to extract message from error response
      if (e is DioError && e.response != null && e.response!.data is Map && e.response!.data['message'] != null) {
        return e.response!.data['message'].toString();
      }
      return 'Failed to delete attendance.';
    }
  }
}
