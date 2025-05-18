import 'dart:convert';
import 'package:client/api/auth/auth_storage.dart';
import 'package:client/model/user_profile.dart';
import 'package:http/http.dart' as http;

class MypageRepository {
  final String _baseUrl = 'http://13.124.150.125:8080/api/mypage';

  Future<UserProfile> getProfile() async {
    final accessToken = await AuthStorage.getAccessToken();

    final url = Uri.parse('$_baseUrl/profile');
    final response = await http.get(
      url,
      headers: {
        'Authorization': '$accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserProfile.fromJson(data);
    } else {
      throw Exception('프로필을 불러오는데 실패했습니다: ${response.statusCode}');
    }
  }
}
