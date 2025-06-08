import 'dart:convert';
import 'package:client/api/auth/auth_storage.dart';
import 'package:client/api/howweather_api.dart';
import 'package:http/http.dart' as http;

class Oauth2Repository {
  final String _baseUrl = '${API.hostConnect}/api/oauth';

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

    if (response.statusCode == 200) {
      final result = jsonBody['result'];
      final accessToken = result['accessToken'];
      final refreshToken = result['refreshToken'];

      await AuthStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await AuthStorage.setLoginType('social');
      await AuthStorage.setSocialToken(kakaoAccessToken);

      return {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
    } else {
      throw ('${jsonBody['error']?['message'] ?? 'Unknown error occurred'}');
    }
  }

  /// 소셜로그인-구글
  Future<Map<String, String>> socialLoginGoogle(
      {required String googleAccessToken}) async {
    final url = Uri.parse('$_baseUrl/google');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'accessToken': googleAccessToken,
      }),
    );

    final decodedResponse = utf8.decode(response.bodyBytes);
    final jsonBody = jsonDecode(decodedResponse);

    if (response.statusCode == 200) {
      final result = jsonBody['result'];
      final accessToken = result['accessToken'];
      final refreshToken = result['refreshToken'];

      await AuthStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await AuthStorage.setLoginType('social');
      await AuthStorage.setSocialToken(googleAccessToken);

      return {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
    } else {
      throw ('${jsonBody['error']?['message'] ?? 'Unknown error occurred'}');
    }
  }
}
