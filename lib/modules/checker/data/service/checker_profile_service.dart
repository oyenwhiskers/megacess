import '../model/checker_profile_model.dart';
import '../../../utility/dio_client.dart';
import '../../../utility/secure_storage_service.dart';
import 'package:dio/dio.dart';

class CheckerProfileService {
  final DioClient _dioClient;

  CheckerProfileService(SecureStorageService storageService)
    : _dioClient = DioClient(
        baseUrl: 'https://mwms.megacess.com/',
        storageService: storageService,
      );

  /// GET v1/profile
  Future<CheckerProfile> fetchProfile() async {
    try {
      final response = await _dioClient.get('api/v1/profile');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['success'] == true) {
          return CheckerProfile.fromJson(data);
        }
      }
      throw Exception('Failed to fetch profile');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized');
      }
      throw Exception('Network error while fetching profile');
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  /// PUT v1/profile (for updating profile)
  Future<CheckerProfile> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _dioClient.put(
        'api/v1/profile',
        data: profileData,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['success'] == true) {
          return CheckerProfile.fromJson(data);
        }
      }
      throw Exception('Failed to update profile');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized');
      } else if (e.response?.statusCode == 422) {
        final data = e.response?.data;
        if (data != null && data['errors'] is Map) {
          final errors = data['errors'] as Map<String, dynamic>;
          final errorMessages = <String>[];
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessages.add(value.first.toString());
            }
          });
          throw Exception(errorMessages.join(', '));
        }
        throw Exception('Validation error');
      }
      throw Exception('Network error while updating profile');
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
