import 'dart:convert';
import 'package:client/api/howweather_api.dart';
import 'package:client/api/interceptor.dart';
import 'package:client/model/user_profile.dart';

class MypageRepository {
  final String _baseUrl = '${API.hostConnect}/api/mypage';
  final HttpInterceptor _http = HttpInterceptor();

  /// 프로필 조회
  Future<UserProfile> getProfile() async {
    final url = '$_baseUrl/profile';
    final response = await _http.get(url);

    final decodedResponse = utf8.decode(response.bodyBytes);
    final jsonBody = jsonDecode(decodedResponse);

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonBody);
    } else {
      throw Exception('프로필을 불러오는데 실패했습니다: ${response.statusCode}');
    }
  }

  /// 닉네임 수정
  Future<void> updateNickname(String newNickname) async {
    final url = '$_baseUrl/update-nickname';
    final response = await _http.patch(
      url,
      body: {'data': newNickname},
    );

    final decodedResponse = utf8.decode(response.bodyBytes);
    final data = jsonDecode(decodedResponse);

    if (response.statusCode == 200) {
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
  Future<void> updateConstitution(int newConstitution) async {
    final url = '$_baseUrl/update-constitution';
    final response = await _http.patch(
      url,
      body: {"data": newConstitution},
    );

    if (response.statusCode != 200) {
      throw Exception('체질 수정 실패: ${response.statusCode}');
    }
  }

  /// 성별 수정
  Future<void> updateGender(int newGender) async {
    final url = '$_baseUrl/update-gender';
    final response = await _http.patch(
      url,
      body: {"data": newGender},
    );

    if (response.statusCode != 200) {
      throw Exception('성별 수정 실패: ${response.statusCode}');
    }
  }

  /// 연령대 수정
  Future<void> updateAge(int newAgeGroup) async {
    final url = '$_baseUrl/update-age';
    final response = await _http.patch(
      url,
      body: {"data": newAgeGroup},
    );

    if (response.statusCode != 200) {
      throw Exception('연령대 수정 실패: ${response.statusCode}');
    }
  }
}
