class StaffBriefModel {
  final int id;
  final String staffFullname;
  final String staffPhone;
  final String staffDob;
  final String staffImg;
  final String staffGender;

  StaffBriefModel({
    required this.id,
    required this.staffFullname,
    required this.staffPhone,
    required this.staffDob,
    required this.staffImg,
    required this.staffGender,
  });

  factory StaffBriefModel.fromJson(Map<String, dynamic> json) {
    return StaffBriefModel(
      id: json['id'],
      staffFullname: json['staff_fullname'],
      staffPhone: json['staff_phone'],
      staffDob: json['staff_dob'],
      staffImg: json['staff_img'] ?? '',
      staffGender: json['staff_gender'] ?? '',
    );
  }
}
