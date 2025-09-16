import 'dart:convert';
import 'package:client/api/howweather_api.dart';
import 'package:client/api/interceptor.dart';

class ClothRepository {
  final String _baseUrl = '${API.hostConnect}/api/cloth';
  final HttpInterceptor _http = HttpInterceptor();

  /// 상의 이미지 URL 반환
  Future<String> getUpperClothImage(int clothType) async {
    final url = '$_baseUrl/upper-image/$clothType';
    final response = await _http.get(url);

    final decodedResponse = utf8.decode(response.bodyBytes);
    final jsonBody = jsonDecode(decodedResponse);

    if (response.statusCode == 200) {
      return jsonBody['result'];
    } else {
      final message = jsonBody['error']?['message'] ?? '상의 이미지 URL 반환 실패';
      throw Exception(message);
    }
  }

  /// 아우터 이미지 URL 반환
  Future<String> getOuterClothImage(int clothType) async {
    final url = '$_baseUrl/outer-image/$clothType';
    final response = await _http.get(url);

    final decodedResponse = utf8.decode(response.bodyBytes);
    final jsonBody = jsonDecode(decodedResponse);

    if (response.statusCode == 200) {
      return jsonBody['result'];
    } else {
      final message = jsonBody['error']?['message'] ?? '아우터 이미지 URL 반환 실패';
      throw Exception(message);
    }
  }
}
