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
      staffId: json['staff_id'] ?? 0,
      staffImg: json['staff_img'] ?? '',
      staffName: json['staff_name'] ?? '',
      status: json['status'] ?? '',
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
    final dataList = (json['data']['data'] as List?) ?? [];
    return StaffAttendanceListResponse(
      data: dataList.map((e) => StaffAttendanceItem.fromJson(e)).toList(),
      currentPage: json['data']['current_page'] ?? 1,
      perPage: json['data']['per_page'] ?? 15,
      total: json['data']['total'] ?? 0,
      lastPage: json['data']['last_page'] ?? 1,
      from: json['data']['from'] ?? 0,
      to: json['data']['to'] ?? 0,
    );
  }
}
