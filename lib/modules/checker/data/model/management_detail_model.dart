class UserAttendanceDetailResponse {
  final bool success;
  final String? message;
  final UserAttendanceDetailData? data;

  UserAttendanceDetailResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory UserAttendanceDetailResponse.fromJson(Map<String, dynamic> json) {
    return UserAttendanceDetailResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? UserAttendanceDetailData.fromJson(json['data']) : null,
    );
  }
}

class UserAttendanceDetailData {
  final int id;
  final String? userNickname;
  final String? userFullname;
  final String? userRole;
  final String? userPhone;
  final String? userIc;
  final String? userGender;
  final String? userImg;
  final String? createdAt;
  final String? updatedAt;
  final int? attendanceCountMonth;

  UserAttendanceDetailData({
    required this.id,
    this.userNickname,
    this.userFullname,
    this.userRole,
    this.userPhone,
    this.userIc,
    this.userGender,
    this.userImg,
    this.createdAt,
    this.updatedAt,
    this.attendanceCountMonth,
  });

  factory UserAttendanceDetailData.fromJson(Map<String, dynamic> json) {
    return UserAttendanceDetailData(
      id: json['id'],
      userNickname: json['user_nickname'],
      userFullname: json['user_fullname'],
      userRole: json['user_role'],
      userPhone: json['user_phone'],
      userIc: json['user_ic'],
      userGender: json['user_gender'],
      userImg: json['user_img'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      attendanceCountMonth: json['attendance_count_month'],
    );
  }
}
