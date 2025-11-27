class StaffModel {
  final int id;
  final String staffFullname;
  final String staffPhone;
  final String staffDob;
  final String staffImg;
  final String staffGender;
  final bool isClaimed;
  final int? attendanceCountMonth;

  StaffModel({
    required this.id,
    required this.staffFullname,
    required this.staffPhone,
    required this.staffDob,
    required this.staffImg,
    required this.staffGender,
    required this.isClaimed,
    this.attendanceCountMonth,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['staff_img'] ?? '';
    
    // Add base URL if the image path is relative (starts with /storage/)
    if (imageUrl.isNotEmpty && imageUrl.startsWith('/storage/')) {
      imageUrl = 'https://mwms.megacess.com$imageUrl';
      print('Converted relative staff image path to: $imageUrl');
    }
    
    return StaffModel(
      id: json['id'],
      staffFullname: json['staff_fullname'] ?? '',
      staffPhone: json['staff_phone'] ?? '',
      staffDob: json['staff_dob'] ?? '',
      staffImg: imageUrl,
      staffGender: json['staff_gender'] ?? '',
      isClaimed:
          json['claimed_staff'] != null &&
          json['claimed_staff']['claimedStaff_id'] != null,
      attendanceCountMonth: json['attendance_count_month'],
    );
  }
}
