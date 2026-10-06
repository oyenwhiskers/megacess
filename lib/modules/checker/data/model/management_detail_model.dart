import 'package:megacess/core/config/flavor_config.dart';

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
    print('UserAttendanceDetailResponse.fromJson called with: $json');
    return UserAttendanceDetailResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? UserAttendanceDetailData.fromJson(json['data'])
          : null,
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
  final String? userDob;
  final String? userEmploymentStartDate;
  final String? userBankName;
  final String? userBankNumber;
  final String? userKwspNumber;
  final int? staffCount;
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
    this.userDob,
    this.userEmploymentStartDate,
    this.userBankName,
    this.userBankNumber,
    this.userKwspNumber,
    this.staffCount,
    this.createdAt,
    this.updatedAt,
    this.attendanceCountMonth,
  });

  factory UserAttendanceDetailData.fromJson(Map<String, dynamic> json) {
    print('UserAttendanceDetailData.fromJson called with: $json');
    
    String? imageUrl = json['user_img'];
    // Add base URL if the image path is relative (starts with /storage/)
    if (imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('/storage/')) {
      imageUrl = '${FlavorConfig.instance.baseDomain}$imageUrl';
      print('Converted relative user detail image path to: $imageUrl');
    }
    
    return UserAttendanceDetailData(
      id: json['id'] ?? 0,
      userNickname: json['user_nickname'],
      userFullname: json['user_fullname'],
      userRole: json['user_role'],
      userPhone: json['user_phone'],
      userIc: json['user_ic'],
      userGender: json['user_gender'],
      userImg: imageUrl,
      userDob: json['user_dob'],
      userEmploymentStartDate: json['user_employment_start_date'],
      userBankName: json['user_bank_name'],
      userBankNumber: json['user_bank_number'],
      userKwspNumber: json['user_kwsp_number'],
      staffCount: json['staff_count'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      attendanceCountMonth: json['attendance_count_month'],
    );
  }
}
