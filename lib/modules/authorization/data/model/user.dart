class User {
  final int id;
  final String userNickname;
  final String userFullname;
  final String userRole;
  final String? userImg;
  final String userGender;

  User({
    required this.id,
    required this.userNickname,
    required this.userFullname,
    required this.userRole,
    this.userImg,
    required this.userGender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      userNickname: json['user_nickname'],
      userFullname: json['user_fullname'],
      userRole: json['user_role'],
      userImg: json['user_img'],
      userGender: json['user_gender'],
    );
  }
}
