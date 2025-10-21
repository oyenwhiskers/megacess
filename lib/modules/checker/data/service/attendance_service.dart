import 'package:megacess/modules/checker/data/model/audit_task_preview_model.dart';
import 'package:megacess/modules/checker/data/model/audit_task_model.dart';
import 'package:megacess/modules/checker/data/model/location_model.dart';
import 'package:megacess/modules/checker/data/model/pending_task_model.dart';
import 'package:megacess/modules/checker/data/model/checker_analytics.dart';
import 'package:megacess/modules/checker/data/model/staff_attendance_model.dart';
import 'package:megacess/modules/checker/data/model/user_attendance_model.dart';
import 'package:megacess/modules/checker/data/model/management_detail_model.dart';
import 'package:megacess/modules/checker/data/model/attendance_model.dart';
import 'package:megacess/modules/checker/data/model/staff_detail_model.dart';
import 'package:megacess/modules/utility/dio_client.dart';
import 'package:megacess/modules/utility/secure_storage_service.dart';
import 'package:dio/dio.dart';

class AttendanceService {
  Future<Map<String, dynamic>> userCheckOut({
    required int dateAttendanceId,
    required int userId,
    required String checkOut,
    String? remarkOt,
  }) async {
    try {
      final response = await dioClient.post(
        'api/v1/user-attendance/check-out',
        data: {
          'date_attendance_id': dateAttendanceId,
          'user_id': userId,
          'check_out': checkOut,
          if (remarkOt != null) 'remark_ot': remarkOt,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }
      return {
        'success': false,
        'message': 'Network error',
      };
    }
  }
  Future<Map<String, dynamic>> userCheckIn({
    required int dateAttendanceId,
    required int userId,
    required String checkIn,
    String? remarkLate,
  }) async {
    try {
      final response = await dioClient.post(
        'api/v1/user-attendance/check-in',
        data: {
          'date_attendance_id': dateAttendanceId,
          'user_id': userId,
          'check_in': checkIn,
          if (remarkLate != null) 'remark_late': remarkLate,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }
      return {
        'success': false,
        'message': 'Network error',
      };
    }
  }
    Future<Map<String, dynamic>> userMarkAbsent({
      required int dateAttendanceId,
      required int userId,
    }) async {
      try {
        final response = await dioClient.post(
          'api/v1/user-attendance/mark-absent',
          data: {
            'date_attendance_id': dateAttendanceId,
            'user_id': userId,
          },
        );
        return response.data as Map<String, dynamic>;
      } on DioError catch (e) {
        if (e.response != null && e.response?.data != null) {
          return e.response?.data as Map<String, dynamic>;
        }
        return {
          'success': false,
          'message': 'Network error',
        };
      }
    }
  Future<UserAttendanceDetailResponse> fetchUserAttendanceDetail({required int userId}) async {
    try {
      final response = await dioClient.get('api/v1/user-attendance/$userId');
      if (response.data is Map && response.data['success'] == true) {
        return UserAttendanceDetailResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch user attendance detail');
      }
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch user attendance detail');
      }
      throw Exception('Failed to fetch user attendance detail');
    }
  }
  Future<Map<String, dynamic>> staffMarkAbsent({
    required int dateAttendanceId,
    required int staffId,
  }) async {
    try {
      final response = await dioClient.post(
        'api/v1/staff-attendance/mark-absent',
        data: {
          'date_attendance_id': dateAttendanceId,
          'staff_id': staffId,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }
      return {
        'success': false,
        'message': 'Network error',
      };
    }
  }
  Future<Map<String, dynamic>> staffCheckOut({
    required int dateAttendanceId,
    required int staffId,
    required String checkOut,
    String? remarkOt,
  }) async {
    try {
      final response = await dioClient.post(
        'api/v1/staff-attendance/check-out',
        data: {
          'date_attendance_id': dateAttendanceId,
          'staff_id': staffId,
          'check_out': checkOut,
          if (remarkOt != null) 'remark_ot': remarkOt,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }
      return {
        'success': false,
        'message': 'Network error',
      };
    }
  }
  Future<Map<String, dynamic>> staffCheckIn({
    required int dateAttendanceId,
    required int staffId,
    required String checkIn,
    String? remarkLate,
  }) async {
    try {
      final response = await dioClient.post(
        'api/v1/staff-attendance/check-in',
        data: {
          'date_attendance_id': dateAttendanceId,
          'staff_id': staffId,
          'check_in': checkIn,
          if (remarkLate != null) 'remark_late': remarkLate,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }
      return {
        'success': false,
        'message': 'Network error',
      };
    }
  }
  Future<StaffDetailResponse> fetchStaffDetail({required int staffId}) async {
    try {
      final response = await dioClient.get('api/v1/staff/$staffId');
      if (response.data is Map && response.data['success'] == true) {
        return StaffDetailResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch staff detail');
      }
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch staff detail');
      }
      throw Exception('Failed to fetch staff detail');
    }
  }
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

  Future<Map<String, dynamic>> deleteAttendance(int id) async {
    try {
      final response = await dioClient.delete('api/v1/attendance/$id');
      if (response.data is Map) {
        return response.data as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': 'Unexpected response format',
        };
      }
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }
      return {
        'success': false,
        'message': 'Network error',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete attendance.',
      };
    }
  }
// ...existing code...
}
