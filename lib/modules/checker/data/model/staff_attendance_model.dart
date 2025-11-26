class StaffAttendanceItem {
  final int staffId;
  final String staffImg;
  final String staffName;
  final String status;
  final String? checkIn;
  final String? checkOut;
  final String? checkedinBy;
  final String? checkedoutBy;

  StaffAttendanceItem({
    required this.staffId,
    required this.staffImg,
    required this.staffName,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.checkedinBy,
    this.checkedoutBy,
  });

  factory StaffAttendanceItem.fromJson(Map<String, dynamic> json) {
    return StaffAttendanceItem(
      staffId: json['id'] ?? json['staff_id'] ?? 0,
      staffImg: json['staff_img'] ?? '',
      staffName: json['staff_fullname'] ?? json['staff_name'] ?? '',
      status: json['status'] ?? 'Absent',
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      checkedinBy: json['checkedin_by'],
      checkedoutBy: json['checkedout_by'],
    );
  }
}

class StaffAttendanceListResponse {
  final List<StaffAttendanceItem> data;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final int from;
  final int to;

  StaffAttendanceListResponse({
    required this.data,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.from,
    required this.to,
  });

  factory StaffAttendanceListResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Check if data is nested or direct
      List<dynamic> dataList;
      Map<String, dynamic> paginationData;

      if (json['data'] is Map) {
        // Nested structure: data.data and pagination info directly in data
        final dataMap = json['data'] as Map<String, dynamic>;
        dataList = (dataMap['data'] as List?) ?? [];
        paginationData = dataMap; // Pagination fields are directly in dataMap
      } else {
        // Direct structure: data as list, meta separate
        dataList = (json['data'] as List?) ?? [];
        paginationData = json['meta'] ?? json;
      }

      print('Parsing pagination data: $paginationData'); // Debug

      return StaffAttendanceListResponse(
        data: dataList
            .map((e) => StaffAttendanceItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        currentPage: paginationData['current_page'] ?? 1,
        perPage: paginationData['per_page'] ?? 15,
        total: paginationData['total'] ?? 0,
        lastPage: paginationData['last_page'] ?? 1,
        from: paginationData['from'] ?? 0,
        to: paginationData['to'] ?? 0,
      );
    } catch (e) {
      print('Error parsing StaffAttendanceListResponse: $e');
      print('JSON: $json');
      rethrow;
    }
  }
}
