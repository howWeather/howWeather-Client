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

  /// 닉네임 수정
  Future<void> updateNickname(String newNickname) async {
    final accessToken = await AuthStorage.getAccessToken();

    final url = Uri.parse('$_baseUrl/update-nickname');
    final response = await http.post(
      url,
      headers: {
        'Authorization': '$accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'data': newNickname,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return; // 성공
      } else {
        throw Exception('닉네임 수정 실패: ${data['result']}');
      }
    } else {
      throw Exception('닉네임 수정 요청 실패: ${response.statusCode}');
    }
  }

  /// 체질 수정
  Future<void> updateConstitution(String newConstitution) async {
    final accessToken = await AuthStorage.getAccessToken();

    final url = Uri.parse('$_baseUrl/update-constitution');
    final response = await http.post(
      url,
      headers: {
        'Authorization': '$accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({"data": newConstitution}),
    );

    if (response.statusCode != 200) {
      throw Exception('체질 수정 실패: ${response.statusCode}');
    }
  }

  /// 성별 수정
  Future<void> updateGender(int newGender) async {
    final accessToken = await AuthStorage.getAccessToken();

    final url = Uri.parse('$_baseUrl/update-gender');
    final response = await http.post(
      url,
      headers: {
        'Authorization': '$accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({"data": newGender}),
    );

    if (response.statusCode != 200) {
      throw Exception('성별 수정 실패: ${response.statusCode}');
    }
  }

  /// 연령대 수정
  Future<void> updateAge(int newAgeGroup) async {
    final accessToken = await AuthStorage.getAccessToken();

    final url = Uri.parse('$_baseUrl/update-age');
    final response = await http.post(
      url,
      headers: {
        'Authorization': '$accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({"data": newAgeGroup}),
    );

    if (response.statusCode != 200) {
      throw Exception('연령대 수정 실패: ${response.statusCode}');
    }
  }
}
