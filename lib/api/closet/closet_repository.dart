import 'dart:convert';
import 'package:client/api/howweather_api.dart';
import 'package:client/api/interceptor.dart';
import 'package:client/model/cloth_item.dart';

class ClosetRepository {
  final String _baseUrl = '${API.hostConnect}/api/closet';
  final HttpInterceptor _http = HttpInterceptor();

  /// 옷장 전체 조회
  Future<List<CategoryCloth>> getAllClothes() async {
    final response = await _http.get(_baseUrl);

    final decodedResponse = utf8.decode(response.bodyBytes);
    final List<dynamic> data = jsonDecode(decodedResponse);

    if (response.statusCode == 200) {
      print('옷장 $data');
      return data.map((json) => CategoryCloth.fromJson(json)).toList();
    } else {
      throw Exception('옷장을 불러오는데 실패했습니다: ${response.statusCode}');
    }
  }

  /// 의류 등록
  Future<String> registerClothes({
    required List<Map<String, dynamic>> uppers,
    required List<Map<String, dynamic>> outers,
  }) async {
    final url = '$_baseUrl/register';
    final body = {
      "uppers": uppers,
      "outers": outers,
    };

    final response = await _http.post(url, body: body);

    final decodedResponse = utf8.decode(response.bodyBytes);
    final data = jsonDecode(decodedResponse);

    if (response.statusCode == 200) {
      if (data["success"] == true) {
        print(data);
        return data["result"];
      } else {
        throw Exception("등록 실패: ${data["error"] ?? '알 수 없는 오류'}");
      }
    } else {
      throw Exception('서버 오류: ${response.statusCode}');
    }
  }

  /// 상의 수정
  Future<String> updateUpperCloth({
    required int clothId,
    int? color,
    int? thickness,
  }) async {
    final url = '$_baseUrl/update-upper/$clothId';

    final Map<String, dynamic> body = {};
    if (color != null) body["color"] = color;
    if (thickness != null) body["thickness"] = thickness;

    final response = await _http.patch(url, body: body);

    final decodedResponse = utf8.decode(response.bodyBytes);
    final data = jsonDecode(decodedResponse);

    if (response.statusCode == 200) {
      if (data["success"] == true) {
        print(data);
        return data["result"];
      } else {
        throw Exception("수정 실패: ${data["error"] ?? '알 수 없는 오류'}");
      }
    } else {
      throw Exception('서버 오류: ${response.statusCode}');
    }
  }

  /// 아우터 수정
  Future<String> updateOuterCloth({
    required int clothId,
    int? color,
    int? thickness,
  }) async {
    final url = '$_baseUrl/update-outer/$clothId';

    final Map<String, dynamic> body = {};
    if (color != null) body["color"] = color;
    if (thickness != null) body["thickness"] = thickness;

    final response = await _http.patch(url, body: body);

    final decodedResponse = utf8.decode(response.bodyBytes);
    final data = jsonDecode(decodedResponse);

    if (response.statusCode == 200) {
      if (data["success"] == true) {
        print(data);
        return data["result"];
      } else {
        throw Exception("수정 실패: ${data["error"] ?? '알 수 없는 오류'}");
      }
    } else {
      throw Exception('서버 오류: ${response.statusCode}');
    }
  }

  /// 상의 삭제
  Future<void> deleteUpperCloth({required int clothId}) async {
    final url = '$_baseUrl/delete-upper/$clothId';

    final response = await _http.delete(url);

    if (response.statusCode == 204) {
      return;
    } else {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);
      final message = data['error']?['message'] ?? '상의 삭제 실패';
      throw Exception(message);
    }
  }

  /// 아우터 삭제
  Future<void> deleteOuterCloth({required int clothId}) async {
    final url = '$_baseUrl/delete-outer/$clothId';

    final response = await _http.delete(url);

    if (response.statusCode == 204) {
      return;
    } else {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);
      final message = data['error']?['message'] ?? '아우터 삭제 실패';
      throw Exception(message);
    }
  }
}
