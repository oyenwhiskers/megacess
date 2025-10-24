class StaffDetailResponse {
  final bool success;
  final String message;
  final StaffDetailData? data;

  StaffDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StaffDetailResponse.fromJson(Map<String, dynamic> json) {
    return StaffDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? StaffDetailData.fromJson(json['data'])
          : null,
    );
  }
}

class StaffDetailData {
  final int id;
  final int staffId;
  final int? dateAttendanceId;
  final String staffFullname;
  final String? staffPhone;
  final String? staffDob;
  final String? staffImg;
  final String? staffGender;
  final int? attendanceCountMonth;
  final int? age;

  StaffDetailData({
    required this.id,
    required this.staffFullname,
    required this.staffId,
    this.dateAttendanceId,
    this.staffPhone,
    this.staffDob,
    this.staffImg,
    this.staffGender,
    this.attendanceCountMonth,
    this.age,
  });

  factory StaffDetailData.fromJson(Map<String, dynamic> json) {
    int? calculatedAge;
    if (json['staff_dob'] != null && json['staff_dob'] is String) {
      try {
        final dob = DateTime.parse(json['staff_dob']);
        final now = DateTime.now();
        calculatedAge =
            now.year -
            dob.year -
            ((now.month < dob.month ||
                    (now.month == dob.month && now.day < dob.day))
                ? 1
                : 0);
      } catch (_) {}
    }
    return StaffDetailData(
      id: json['id'],
      staffId: json['staff_id'] ?? json['id'],
      dateAttendanceId: json['date_attendance_id'],
      staffFullname: json['staff_fullname'] ?? '',
      staffPhone: json['staff_phone'],
      staffDob: json['staff_dob'],
      staffImg: json['staff_img'],
      staffGender: json['staff_gender'],
      attendanceCountMonth: json['attendance_count_month'],
      age: calculatedAge,
    );
  }
}
