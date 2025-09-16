import 'dart:convert';
import 'package:client/api/auth/auth_storage.dart';
import 'package:client/api/howweather_api.dart';
import 'package:client/api/interceptor.dart';
import 'package:http/http.dart' as http;

class Oauth2Repository {
  final String _baseUrl = '${API.hostConnect}/api/oauth';
  final HttpInterceptor _http = HttpInterceptor();

  /// 소셜로그인-카카오
  Future<Map<String, String>> socialLoginKaKao({
    required String kakaoAccessToken,
  }) async {
    final url = '$_baseUrl/kakao';

    final response = await _http.post(
      url,
      body: {'accessToken': kakaoAccessToken},
      useAuth: false, // 로그인 전에는 토큰 X
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
  Future<Map<String, String>> socialLoginGoogle({
    required String googleAccessToken,
  }) async {
    final url = '$_baseUrl/google';

    final response = await _http.post(
      url,
      body: {'accessToken': googleAccessToken},
      useAuth: false,
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
