class AttendanceItem {
  final int id;
  final String date;
  final String status;
  final String createdAt;
  final String updatedAt;

  AttendanceItem({
    required this.id,
    required this.date,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceItem.fromJson(Map<String, dynamic> json) {
    return AttendanceItem(
      id: json['id'],
      date: json['date'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class AttendanceListResponse {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final int from;
  final int to;
  final List<AttendanceItem> data;

  AttendanceListResponse({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.from,
    required this.to,
    required this.data,
  });

  factory AttendanceListResponse.fromJson(Map<String, dynamic> json) {
    final d = json['data'] ?? {};
    return AttendanceListResponse(
      currentPage: d['current_page'] ?? 1,
      perPage: d['per_page'] ?? 15,
      total: d['total'] ?? 0,
      lastPage: d['last_page'] ?? 1,
      from: d['from'] ?? 1,
      to: d['to'] ?? 1,
      data: (d['data'] as List<dynamic>? ?? [])
          .map((e) => AttendanceItem.fromJson(e))
          .toList(),
    );
  }
}
