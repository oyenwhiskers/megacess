class UserAttendanceItem {
  final int userId;
  final String userImg;
  final String userName;
  final String status;
  final String? checkIn;
  final String? checkOut;
  final String? checkedinBy;
  final String? checkedoutBy;

  UserAttendanceItem({
    required this.userId,
    required this.userImg,
    required this.userName,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.checkedinBy,
    this.checkedoutBy,
  });

  factory UserAttendanceItem.fromJson(Map<String, dynamic> json) {
    return UserAttendanceItem(
      userId: json['user_id'] ?? 0,
      userImg: json['user_img'] ?? '',
      userName: json['user_name'] ?? '',
      status: json['status'] ?? '',
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      checkedinBy: json['checkedin_by'],
      checkedoutBy: json['checkedout_by'],
    );
  }
}

class UserAttendanceListResponse {
  final List<UserAttendanceItem> data;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final int from;
  final int to;

  UserAttendanceListResponse({
    required this.data,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.from,
    required this.to,
  });

  factory UserAttendanceListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data']['data'] as List?) ?? [];
    return UserAttendanceListResponse(
      data: dataList.map((e) => UserAttendanceItem.fromJson(e)).toList(),
      currentPage: json['data']['current_page'] ?? 1,
      perPage: json['data']['per_page'] ?? 15,
      total: json['data']['total'] ?? 0,
      lastPage: json['data']['last_page'] ?? 1,
      from: json['data']['from'] ?? 0,
      to: json['data']['to'] ?? 0,
    );
  }
}
