import 'dart:convert';
import 'package:client/api/auth/auth_storage.dart';
import 'package:client/model/cloth_item.dart';
import 'package:http/http.dart' as http;

class ClosetRepository {
  final String _baseUrl = 'http://13.124.150.125:8080/api/closet';

  Future<List<CategoryCloth>> getAllClothes() async {
    final accessToken = await AuthStorage.getAccessToken();

    final url = Uri.parse('$_baseUrl');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
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
    final accessToken = await AuthStorage.getAccessToken();

    final url = Uri.parse('$_baseUrl/register');
    final body = jsonEncode({
      "uppers": uppers,
      "outers": outers,
    });
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print(accessToken);
    print(body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
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
    final accessToken = await AuthStorage.getAccessToken();

    final url = Uri.parse('$_baseUrl/update-upper/$clothId');

    final Map<String, dynamic> body = {};
    if (color != null) body["color"] = color;
    if (thickness != null) body["thickness"] = thickness;

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
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
    final accessToken = await AuthStorage.getAccessToken();

    final url = Uri.parse('$_baseUrl/update-outer/$clothId');

    final Map<String, dynamic> body = {};
    if (color != null) body["color"] = color;
    if (thickness != null) body["thickness"] = thickness;

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
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
  Future<void> deleteUpperCloth({
    required int clothId,
  }) async {
    final accessToken = await AuthStorage.getAccessToken();

    final url = Uri.parse('$_baseUrl/delete-upper/$clothId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('상의 삭제 실패: ${response.statusCode}');
    }
  }

  /// 아우터 삭제
  Future<void> deleteOuterCloth({
    required int clothId,
  }) async {
    final accessToken = await AuthStorage.getAccessToken();

    final url = Uri.parse('$_baseUrl/delete-outer/$clothId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('상의 삭제 실패: ${response.statusCode}');
    }
  }
}
