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
import 'package:path/path.dart' as path;
import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_parser/http_parser.dart';

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
        
  /// Upload a file to the server
  /// 
  /// [filePath] - The path to the file to upload
  /// [directory] - Optional target directory
  /// [metadata] - Optional metadata (description, category, etc.)
  /// Returns a Map containing the upload response with file details
  Future<Map<String, dynamic>> uploadFile({
    required String filePath,
    String? directory,
    Map<String, String>? metadata,
    List<int>? bytes,
    String? mimeType,
  }) async {
    try {
      // Create FormData for multipart request
      final formData = FormData();
      
      // Add the file
      final fileName = path.basename(filePath);
      
      // Handle file upload based on platform
      if (kIsWeb) {
        // Web platform - require bytes and mimeType parameters
        if (bytes == null) {
          return {
            'success': false,
            'message': 'File bytes are required for web uploads',
          };
        }
        
        formData.files.add(
          MapEntry(
            'file',
            MultipartFile.fromBytes(
              bytes,
              filename: fileName,
              contentType: mimeType != null ? MediaType.parse(mimeType) : null,
            ),
          ),
        );
      } else {
        // Mobile/Desktop platforms - can use File API
        formData.files.add(
          MapEntry(
            'file',
            await MultipartFile.fromFile(
              filePath,
              filename: fileName,
            ),
          ),
        );
      }
      
      // Add directory if provided
      if (directory != null && directory.isNotEmpty) {
        formData.fields.add(MapEntry('directory', directory));
      }
      
      // Add metadata if provided
      if (metadata != null && metadata.isNotEmpty) {
        metadata.forEach((key, value) {
          formData.fields.add(MapEntry('metadata[$key]', value));
        });
      }
      
      // Make the request
      final response = await dioClient.post(
        'api/v1/files/upload',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      
      // Return the response data
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Upload failed: ${e.toString()}',
      };
    }
  }
  
  /// Upload a file as evidence for an audit task
  /// 
  /// [taskId] - The ID of the audit task
  /// [filePath] - The path to the file to upload
  /// [description] - Optional description for the file
  /// [bytes] - Optional file bytes (required for web)
  /// [mimeType] - Optional mime type of the file (used for web)
  /// [isVideo] - Whether the file is a video
  /// Returns a Map containing the upload response with file details
  Future<Map<String, dynamic>> uploadAuditTaskEvidence({
    required int taskId,
    required String filePath,
    String? description,
    List<int>? bytes,
    String? mimeType,
    bool isVideo = false,
  }) async {
    try {
      // Create metadata with task information
      final metadata = <String, String>{
        'related_to': 'audit_task',
        'related_id': taskId.toString(),
        'media_type': isVideo ? 'video' : 'image',
      };
      
      // Add description if provided
      if (description != null && description.isNotEmpty) {
        metadata['description'] = description;
      }
      
      // Use the general upload file method with appropriate directory and metadata
      return await uploadFile(
        filePath: filePath,
        directory: 'audit_tasks/$taskId/evidence',
        metadata: metadata,
        bytes: bytes,
        mimeType: mimeType,
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to upload audit task evidence: ${e.toString()}',
      };
    }
  }
  
  /// Gets the file URL from path
  /// [path] - The path of the file
  /// Returns a Map containing the file URL details
  Future<Map<String, dynamic>> getFileUrl(String path) async {
    try {
      final response = await dioClient.get(
        'api/v1/files/url',
        queryParameters: {'path': path},
      );
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get file URL: ${e.toString()}',
      };
    }
  }
  
  /// Deletes a file using the API
  /// [path] - The path of the file to delete (required)
  /// Returns a Map containing the response with deletion status
  Future<Map<String, dynamic>> deleteFile(String path) async {
    try {
      final response = await dioClient.delete(
        'api/v1/files/delete',
        data: {'path': path},
      );
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete file: ${e.toString()}',
      };
    }
  }

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

  // Method to approve audit task
  Future<Map<String, dynamic>> approveAuditTask({
    required int taskId,
    String? taskVideo,
    List<String>? taskImages,
    String? remarks,
    List<Map<String, dynamic>>? workerAuditMeta,
  }) async {
    try {
      // Prepare request body
      Map<String, dynamic> requestBody = {};
      
      // Add task_video if provided
      if (taskVideo != null && taskVideo.isNotEmpty) {
        requestBody['task_video'] = taskVideo;
      }
      
      // Add task_img if provided
      if (taskImages != null && taskImages.isNotEmpty) {
        requestBody['task_img'] = taskImages;
      }
      
      // Add remarks if provided
      if (remarks != null && remarks.isNotEmpty) {
        requestBody['remarks'] = remarks;
      }
      
      // Add worker_audit_meta if provided, with special handling for manuring tasks
      if (workerAuditMeta != null && workerAuditMeta.isNotEmpty) {
        // Make sure all entries have the correct format
        for (var meta in workerAuditMeta) {
          // Ensure staff_id is an integer, not a string
          if (meta.containsKey('staff_id') && meta['staff_id'] is String) {
            meta['staff_id'] = int.tryParse(meta['staff_id'].toString()) ?? 13;
          }
          
          // Ensure meta_key and meta_value are strings
          if (meta.containsKey('meta_key') && meta['meta_key'] is! String) {
            meta['meta_key'] = meta['meta_key'].toString();
          }
          
          if (meta.containsKey('meta_value') && meta['meta_value'] is! String) {
            meta['meta_value'] = meta['meta_value'].toString();
          }
        }
        requestBody['worker_audit_meta'] = workerAuditMeta;
        
        print('Formatted worker_audit_meta for API:');
        for (var entry in workerAuditMeta) {
          print('  ${entry['staff_id']} (${entry['staff_id'].runtimeType}): ${entry['meta_key']}=${entry['meta_value']}');
        }
      }
      
      print('=== APPROVE TASK API REQUEST ===');
      print('Task ID: $taskId');
      print('task_video type: ${requestBody['task_video']?.runtimeType}');
      print('task_video value: ${requestBody['task_video']}');
      print('task_img type: ${requestBody['task_img']?.runtimeType}');
      print('task_img value: ${requestBody['task_img']}');
      
      // Detailed logging for worker_audit_meta
      if (requestBody.containsKey('worker_audit_meta')) {
        print('worker_audit_meta type: ${requestBody['worker_audit_meta']?.runtimeType}');
        print('worker_audit_meta count: ${requestBody['worker_audit_meta']?.length ?? 0}');
        
        if (requestBody['worker_audit_meta'] != null) {
          final metaList = requestBody['worker_audit_meta'] as List;
          for (int i = 0; i < metaList.length; i++) {
            final entry = metaList[i];
            print('Entry $i:');
            print('  staff_id: ${entry['staff_id']} (${entry['staff_id'].runtimeType})');
            print('  meta_key: ${entry['meta_key']} (${entry['meta_key'].runtimeType})');
            print('  meta_value: ${entry['meta_value']} (${entry['meta_value'].runtimeType})');
          }
        }
      } else {
        print('WARNING: worker_audit_meta is missing from request!');
      }
      
      final response = await dioClient.post(
        'api/v1/tasks/audits/$taskId/approve',
        data: requestBody,
      );
      
      print('=== APPROVE TASK API RESPONSE ===');
      print('Response: ${response.data}');
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('Error approving task: ${e.response?.data}');
      if (e.response != null && e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      print('Unexpected error approving task: $e');
      return {
        'success': false,
        'message': 'Failed to approve task: ${e.toString()}',
      };
    }
  }
// ...existing code...
}
