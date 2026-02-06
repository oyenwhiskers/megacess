import '../model/staff_model.dart';
import '../../../utility/secure_storage_service.dart';
import '../../../utility/dio_client.dart';
import '../../../../core/config/flavor_config.dart';

class StaffService {
  Future<bool> unclaimStaff(int staffId) async {
    final response = await _dioClient.delete('staff/$staffId/unclaim');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return true;
    }
    return false;
  }

  Future<StaffModel?> getStaffDetail(int staffId) async {
    final response = await _dioClient.get('staff/$staffId');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return StaffModel.fromJson(response.data['data']);
    }
    return null;
  }

  Future<bool> claimStaff(int staffId) async {
    final response = await _dioClient.post('staff/$staffId/claim');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return true;
    }
    return false;
  }

  final DioClient _dioClient;

  StaffService({DioClient? dioClient})
    : _dioClient =
          dioClient ??
          DioClient(
            baseUrl: FlavorConfig.instance.baseUrl,
            storageService: SecureStorageService(),
          );

  Future<PaginatedStaffResult> fetchUnclaimedStaff({
    int page = 1,
    String? search,
  }) async {
    final response = await _dioClient.get(
      'staff',
      queryParameters: {
        'page': page,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'];
      final meta = response.data['meta'];
      final staffList = data
          .map((json) => StaffModel.fromJson(json))
          .where((staff) => !staff.isClaimed)
          .toList();
      return PaginatedStaffResult(
        staff: staffList,
        currentPage: meta['current_page'] ?? 1,
        lastPage: meta['last_page'] ?? 1,
        total: meta['total'] ?? staffList.length,
      );
    }
    throw Exception('Failed to fetch staff');
  }

  Future<List<StaffModel>> fetchClaimedStaff() async {
    final response = await _dioClient.get('staff/my-staff');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'];
      return data.map((json) => StaffModel.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch claimed staff');
  }
}

class PaginatedStaffResult {
  final List<StaffModel> staff;
  final int currentPage;
  final int lastPage;
  final int total;

  PaginatedStaffResult({
    required this.staff,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}


