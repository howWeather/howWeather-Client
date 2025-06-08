import 'dart:convert';
import 'package:client/api/auth/auth_storage.dart';
import 'package:client/api/howweather_api.dart';
import 'package:http/http.dart' as http;

class ClothRepository {
  final String _baseUrl = '${API.hostConnect}/api/cloth';

  /// 상의 이미지 URL 반환
  Future<String> getUpperClothImage(int clothType) async {
    final accessToken = await AuthStorage.getAccessToken();

    final url = Uri.parse('$_baseUrl/upper-image/$clothType');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    final decodedResponse = utf8.decode(response.bodyBytes);
    final jsonBody = jsonDecode(decodedResponse);
    if (response.statusCode == 200) {
      return jsonBody['result'];
    } else {
      throw Exception('상의 이미지 URL 반환 실패: ${response.statusCode}');
    }
  }

  /// 아우터 이미지 URL 반환
  Future<String> getOuterClothImage(int clothType) async {
    final accessToken = await AuthStorage.getAccessToken();

    final url = Uri.parse('$_baseUrl/outer-image/$clothType');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    final decodedResponse = utf8.decode(response.bodyBytes);
    final jsonBody = jsonDecode(decodedResponse);
    if (response.statusCode == 200) {
      return jsonBody['result'];
    } else {
      throw Exception('아우터 이미지 URL 반환 실패: ${response.statusCode}');
    }
  }
}
