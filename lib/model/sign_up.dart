class SignupData {
  final String? loginId;
  final String? password;
  final String email;
  final String? nickname;
  final int? constitution;
  final int? ageGroup;
  final int? bodyType;
  final int? gender;

  SignupData({
    this.loginId,
    this.password,
    required this.email,
    this.nickname,
    this.constitution,
    this.ageGroup,
    this.bodyType,
    this.gender,
  });

  SignupData copyWith({
    String? loginId,
    String? password,
    String? email,
    String? nickname,
    int? constitution,
    int? ageGroup,
    int? bodyType,
    int? gender,
  }) {
    return SignupData(
      loginId: loginId ?? this.loginId,
      password: password ?? this.password,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      constitution: constitution ?? this.constitution,
      ageGroup: ageGroup ?? this.ageGroup,
      bodyType: bodyType ?? this.bodyType,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loginId': loginId,
      'password': password,
      'email': email,
      'nickname': nickname,
      'constitution': constitution,
      'ageGroup': ageGroup,
      'bodyType': bodyType,
      'gender': gender,
    };
  }
}
