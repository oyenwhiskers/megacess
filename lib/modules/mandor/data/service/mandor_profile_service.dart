import '../model/mandor_profile_model.dart';
import '../../../utility/dio_client.dart';
import '../../../utility/secure_storage_service.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class MandorProfileService {
  final DioClient _dioClient;

  MandorProfileService({DioClient? dioClient})
    : _dioClient =
          dioClient ??
          DioClient(
            baseUrl: 'https://mwms.megacess.com/api/',
            storageService: SecureStorageService(),
          );

  /// GET v1/profile
  Future<MandorProfile> fetchProfile() async {
    try {
      final response = await _dioClient.get('v1/profile');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['success'] == true) {
          return MandorProfile.fromJson(data);
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

  /// POST v1/profile (for updating profile)
  Future<MandorProfile> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _dioClient.post(
        'v1/profile',
        data: profileData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['success'] == true) {
          return MandorProfile.fromJson(data);
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

  /// Upload image and update profile
  /// First uploads the image to storage, then updates profile with the image URL
  Future<MandorProfile> uploadProfileImage(String imageFilePath) async {
    try {
      // Step 1: Upload image to files endpoint
      String fileName = imageFilePath.split('/').last;
      if (imageFilePath.contains('\\')) {
        fileName = imageFilePath.split('\\').last;
      }

      // For web blob URLs, generate proper filename
      if (fileName.startsWith('blob:') || !fileName.contains('.')) {
        fileName = 'profile_image.jpg'; // Default name with extension for web
      }

      // Read file as bytes for cross-platform compatibility
      final xFile = XFile(imageFilePath);
      final imageBytes = await xFile.readAsBytes();

      // Create multipart form data
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(imageBytes, filename: fileName),
      });

      // Upload to correct endpoint: v1/files/upload
      final uploadResponse = await _dioClient.post(
        'v1/files/upload',
        data: formData,
      );

      if (uploadResponse.statusCode != 201 &&
          uploadResponse.statusCode != 200) {
        throw Exception('Failed to upload image');
      }

      final uploadData = uploadResponse.data;
      print('Upload API Response: $uploadData'); // Debug log

      if (uploadData == null || uploadData['success'] != true) {
        final errorMsg = uploadData?['message'] ?? 'Image upload failed';
        throw Exception(errorMsg);
      }

      // Get the uploaded image path from response
      final uploadedPath = uploadData['data']?['path'];
      print('Uploaded path from API: $uploadedPath'); // Debug log

      if (uploadedPath == null || uploadedPath.isEmpty) {
        throw Exception('No image path returned from upload');
      }

      // Transform the path to correct format: /storage/user-images/xxx.jpg
      // API might return: uploads/2025/11/26/uuid. (note: no leading slash, ends with dot)
      // We need: /storage/user-images/uuid.jpg
      String finalPath;
      if (uploadedPath.toString().contains('uploads/')) {
        // Extract UUID from path like uploads/2025/11/26/af7a0aba-42c6-4f5b-ad45-844297ef2927.
        final pathParts = uploadedPath.toString().split('/');
        String uuid = pathParts.last;

        // Remove trailing dot if present
        if (uuid.endsWith('.')) {
          uuid = uuid.substring(0, uuid.length - 1);
        }

        // Get original file extension from API response or fallback
        String fileExtension = 'jpg'; // default fallback

        if (uploadData['data']?['extension'] != null &&
            uploadData['data']['extension'].toString().isNotEmpty) {
          fileExtension = uploadData['data']['extension'];
        } else if (uploadData['data']?['mime_type'] != null) {
          // Extract extension from mime type
          final mimeType = uploadData['data']['mime_type'].toString();
          if (mimeType.contains('image/png')) {
            fileExtension = 'png';
          } else if (mimeType.contains('image/jpeg') ||
              mimeType.contains('image/jpg')) {
            fileExtension = 'jpg';
          } else if (mimeType.contains('image/gif')) {
            fileExtension = 'gif';
          } else if (mimeType.contains('image/webp')) {
            fileExtension = 'webp';
          }
        } else if (fileName.contains('.')) {
          // Fallback to original filename extension
          fileExtension = fileName.split('.').last.toLowerCase();
        }

        finalPath = '/storage/user-images/$uuid.$fileExtension';
      } else {
        // Fallback: add leading slash if not present
        finalPath = uploadedPath.startsWith('/')
            ? uploadedPath
            : '/$uploadedPath';
      }

      print('Final path for database: $finalPath'); // Debug log

      // Step 2: Update profile with the corrected image path using POST
      final profileData = {'user_img': finalPath};
      final profileResponse = await _dioClient.post(
        'v1/profile',
        data: profileData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (profileResponse.statusCode == 200) {
        final data = profileResponse.data;
        if (data != null && data['success'] == true) {
          return MandorProfile.fromJson(data);
        }
      }
      throw Exception('Failed to update profile with image');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized');
      } else if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data?['message'] ?? 'Upload failed';
        throw Exception(errorMsg);
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
      final errorMsg =
          e.response?.data?['message'] ?? 'Network error: ${e.message}';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('$e');
    }
  }
}
