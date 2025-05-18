class UserProfile {
  final String nickname;
  final String loginId;
  final String email;
  final int ageGroup;
  final int bodyType;
  final int constitution;
  final int gender;

  UserProfile({
    required this.nickname,
    required this.loginId,
    required this.email,
    required this.ageGroup,
    required this.bodyType,
    required this.constitution,
    required this.gender,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nickname: json['nickname'],
      loginId: json['loginId'],
      email: json['email'],
      ageGroup: json['ageGroup'],
      bodyType: json['bodyType'],
      constitution: json['constitution'],
      gender: json['gender'],
    );
  }
}
