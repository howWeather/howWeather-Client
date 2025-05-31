import 'dart:convert';

import 'package:client/api/auth/auth_storage.dart';
import 'package:http/http.dart' as http;

class Oauth2Repository {
  final String _baseUrl = 'http://13.124.150.125:8080/oauth2/authorization';

  /// 소셜로그인-카카오
  Future<Map<String, bool>> socialLoginKaKao() async {
    final url = Uri.parse('$_baseUrl/kakao');

    final response = await http.get(url);

    final decodedResponse = utf8.decode(response.bodyBytes);
    final jsonBody = jsonDecode(decodedResponse);
    if (response.statusCode == 200) {
      final result = jsonBody['result'];

      final accessToken = result['accessToken'];
      final refreshToken = result['refreshToken'];

      print('실패');
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
      throw ('${jsonBody['error']['message']}');
    }
  }
}
