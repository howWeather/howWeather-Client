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

    final decodedResponse = utf8.decode(response.bodyBytes);
    final jsonBody = jsonDecode(decodedResponse);
    if (response.statusCode == 200) {
      final result = jsonBody['result'];

      final accessToken = result['accessToken'];
      final refreshToken = result['refreshToken'];

      // 토큰 저장
      await AuthStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await AuthStorage.setLoginType('email');

      return {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
    } else {
      throw ('${jsonBody['error']['message']}');
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

  /// 회원탈퇴
  Future<void> withdraw() async {
    final accessToken = await AuthStorage.getAccessToken();
    final refreshToken = await AuthStorage.getRefreshToken();
    final loginType = await AuthStorage.getLoginType();
    final headers = {
      "Authorization": 'Bearer $accessToken',
      "Refresh-Token": 'Bearer $refreshToken',
    };

    // 소셜 로그인일 경우에만 Social-Access-Token 포함
    if (loginType == 'social') {
      final socialToken = await AuthStorage.getSocialToken();
      if (socialToken != null) {
        headers["Social-Access-Token"] = socialToken;
        print('socialToken: $socialToken');
      }
    }

    final url = Uri.parse('$_baseUrl/delete');

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 204) {
        print('✅ 회원탈퇴 성공');
        await AuthStorage.clear();
      } else {
        print('❌ 서버 응답 에러: ${response.statusCode}');
        print('body: ${response.body}');
      }
    } catch (e) {
      print('❌ 회원탈퇴 실패: $e');
      rethrow;
    }
  }

  /// 비밀번호 초기화
  Future<String?> resetPassword(String identifier) async {
    final url = Uri.parse('$_baseUrl/reset-password');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          "identifier": identifier,
        },
      ),
    );

    final decodedResponse = utf8.decode(response.bodyBytes);
    final jsonBody = jsonDecode(decodedResponse);
    print(identifier);
    print(jsonBody);
    if (response.statusCode == 200) {
      return jsonBody['result'];
    } else {
      return jsonBody['result'];
    }
  }

  /// 비밀번호 변경
  Future<void> updatePassword(
      String oldPassword, String newPassword, String confirmPassword) async {
    final accessToken = await AuthStorage.getAccessToken();
    final refreshToken = await AuthStorage.getRefreshToken();
    final url = Uri.parse('$_baseUrl/update-password');

    final response = await http.post(
      url,
      headers: {
        "Authorization": 'Bearer $accessToken',
        "Refresh-Token": 'Bearer $refreshToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          "oldPassword": oldPassword,
          "newPassword": newPassword,
          "confirmPassword": confirmPassword,
        },
      ),
    );

    final decodedResponse = utf8.decode(response.bodyBytes);
    final jsonBody = jsonDecode(decodedResponse);
    if (response.statusCode == 200) {
      await AuthStorage.clear();
      print('비밀번호 변경 성공');
      return jsonBody['success'];
    } else {
      throw ('비밀번호 변경 실패: ${jsonBody['error']['message']}');
    }
  }
}
