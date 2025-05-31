import 'dart:convert';
import 'package:client/api/auth/auth_storage.dart';
import 'package:http/http.dart' as http;

class Oauth2Repository {
  final String _baseUrl = 'http://13.124.150.125:8080/api/oauth';

  /// 소셜로그인-카카오
  Future<Map<String, String>> socialLoginKaKao(
      {required String kakaoAccessToken}) async {
    final url = Uri.parse('$_baseUrl/kakao');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'accessToken': kakaoAccessToken,
      }),
    );

    final decodedResponse = utf8.decode(response.bodyBytes);
    final jsonBody = jsonDecode(decodedResponse);
    print('서버 응답 상태코드: ${response.statusCode}');
    print('서버 응답 바디: ${decodedResponse}');

    if (response.statusCode == 200) {
      final result = jsonBody['result'];

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
      throw ('${jsonBody['error']?['message'] ?? 'Unknown error occurred'}');
    }
  }
}
