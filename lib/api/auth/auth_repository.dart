import 'dart:convert';

import 'package:client/api/auth/auth_storage.dart';
import 'package:client/model/sign_up.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  final String _baseUrl = 'http://13.124.150.125:8080/api/auth';

  /// 이메일 중복 검증
  Future<bool> verifyEmail(String email) async {
    final url = Uri.parse('$_baseUrl/email-exist-check?email=$email');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['success'];
    } else {
      print(jsonDecode(response.body)['error']['message']);
      throw Exception('이메일 중복 검증 실패: ${response.statusCode}');
    }
  }

  /// 아이디 중복 검증
  Future<bool> verifyLoginId(String loginId) async {
    final url = Uri.parse('$_baseUrl/loginid-exist-check?loginId=$loginId');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['success'];
    } else {
      print(jsonDecode(response.body)['error']['message']);
      throw Exception('아이디 중복 검증 실패: ${response.statusCode}');
    }
  }

  /// 회원가입
  Future<bool> signUp(SignupData signUp) async {
    final url = Uri.parse('$_baseUrl/signup');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(signUp.toJson()),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['success'];
    } else {
      print(jsonDecode(response.body)['error']['message']);
      throw Exception('회원가입 실패: ${response.statusCode}');
    }
  }

  /// 로그인
  Future<Map<String, String>> login(String loginId, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        {
          "loginId": loginId,
          "password": password,
        },
      ),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final result = responseBody['result'];

      final accessToken = result['accessToken'];
      final refreshToken = result['refreshToken'];

      // 토큰 저장
      await AuthStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      return {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
    } else {
      throw Exception(
          '로그인 실패: ${jsonDecode(response.body)['error']['message']}');
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    final accessToken = await AuthStorage.getAccessToken();
    final refreshToken = await AuthStorage.getRefreshToken();
    final url = Uri.parse('$_baseUrl/logout');

    final response = await http.post(
      url,
      headers: {
        "Authorization": 'Bearer $accessToken',
        "Refresh-Token": 'Bearer $refreshToken',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      await AuthStorage.clear();
      return responseBody['success'];
    } else {
      throw Exception('로그아웃 실패: ${response.statusCode}');
    }
  }

  /// 토큰 재발급
  Future<void> reissueToken() async {
    final accessToken = await AuthStorage.getAccessToken();
    final refreshToken = await AuthStorage.getRefreshToken();

    final url = Uri.parse('$_baseUrl/reissue');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $refreshToken',
      },
    );

    print('🔁 재발급 응답: ${response.statusCode} / ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final result = responseBody['result'];
      final newAccessToken = result['accessToken'];

      await AuthStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: refreshToken!,
      );
    } else {
      throw Exception('토큰 재발급 실패: ${response.reasonPhrase}');
    }
  }
}
