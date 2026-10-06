class CheckerProfile {
  final int id;
  final String userNickname;
  final String userFullname;
  final String userRole;
  final String? userImg;
  final String userPhone;
  final String userIc;
  final String userGender;
  final String userDob;
  final String userBankName;
  final String userBankNumber;
  final String userKwspNumber;
  final int attendanceCountMonth;

  CheckerProfile({
    required this.id,
    required this.userNickname,
    required this.userFullname,
    required this.userRole,
    this.userImg,
    required this.userPhone,
    required this.userIc,
    required this.userGender,
    required this.userDob,
    required this.userBankName,
    required this.userBankNumber,
    required this.userKwspNumber,
    required this.attendanceCountMonth,
  });

  factory CheckerProfile.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return CheckerProfile(
      id: data['id'] ?? 0,
      userNickname: data['user_nickname'] ?? '',
      userFullname: data['user_fullname'] ?? '',
      userRole: data['user_role'] ?? '',
      userImg: data['user_img'],
      userPhone: data['user_phone'] ?? '',
      userIc: data['user_ic'] ?? '',
      userGender: data['user_gender'] ?? '',
      userDob: data['user_dob'] ?? '',
      userBankName: data['user_bank_name'] ?? '',
      userBankNumber: data['user_bank_number'] ?? '',
      userKwspNumber: data['user_kwsp_number'] ?? '',
      attendanceCountMonth: data['attendance_count_month'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_nickname': userNickname,
      'user_fullname': userFullname,
      'user_role': userRole,
      'user_img': userImg,
      'user_phone': userPhone,
      'user_ic': userIc,
      'user_gender': userGender,
      'user_dob': userDob,
      'user_bank_name': userBankName,
      'user_bank_number': userBankNumber,
      'user_kwsp_number': userKwspNumber,
      'attendance_count_month': attendanceCountMonth,
    };
  }
}
