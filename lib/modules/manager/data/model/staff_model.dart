class StaffModel {
  final int id;
  final String staffFullname;
  final String staffPhone;
  final String staffDob;
  final String staffImg;
  final String staffGender;
  final bool isClaimed;

  StaffModel({
    required this.id,
    required this.staffFullname,
    required this.staffPhone,
    required this.staffDob,
    required this.staffImg,
    required this.staffGender,
    required this.isClaimed,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'],
      staffFullname: json['staff_fullname'] ?? '',
      staffPhone: json['staff_phone'] ?? '',
      staffDob: json['staff_dob'] ?? '',
      staffImg: json['staff_img'] ?? '',
      staffGender: json['staff_gender'] ?? '',
      isClaimed: json['claimed_staff'] != null && json['claimed_staff']['claimedStaff_id'] != null,
    );
  }
}
