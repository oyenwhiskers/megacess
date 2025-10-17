import 'package:dio/dio.dart';
import '../model/staff_model.dart';
import '../../../utility/dio_client.dart';
import '../../../utility/secure_storage_service.dart';

class StaffService {
  final DioClient _dioClient;

  StaffService({
    DioClient? dioClient,
  }) : _dioClient = dioClient ?? DioClient(
      baseUrl: 'https://mwms.megacess.com/api/', // <-- Replace with your actual base URL
      storageService: SecureStorageService(),
    );

  Future<PaginatedStaffResult> fetchUnclaimedStaff({int page = 1, String? search}) async {
    final response = await _dioClient.get(
      'v1/staff',
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
