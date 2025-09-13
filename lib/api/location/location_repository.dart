import 'dart:convert';
import 'package:client/api/auth/auth_storage.dart';
import 'package:client/api/howweather_api.dart';
import 'package:http/http.dart' as http;

class LocationRepository {
  final String _baseUrl = '${API.hostConnect}/api/location';
  final String _mypageBaseUrl = '${API.hostConnect}/api/mypage';

  Future<Map<String, dynamic>> getLocationTemperature({
    required double latitude,
    required double longitude,
    required int timeSlot,
    required String date,
  }) async {
    final accessToken = await AuthStorage.getAccessToken();

    final url = Uri.parse('$_baseUrl/temperature');

    final request = http.Request('GET', url)
      ..headers.addAll({
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'timeSlot': timeSlot,
        'date': date,
      });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);
      print(data);

      if (data['success'] == true) {
        return {
          'regionName': data['result']['regionName'],
          'temperature': data['result']['temperature'],
        };
      } else {
        throw Exception('API 오류: ${data['error']}');
      }
    } else {
      throw Exception('위치 기반 온도 조회 실패: ${response.statusCode}');
    }
  }

  /// 사용자 위치 조회
  Future<String> getUserLocation() async {
    final accessToken = await AuthStorage.getAccessToken();

    final url = Uri.parse('$_mypageBaseUrl/location');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);
      print('사용자 위치 조회: $data');

      if (data['success'] == true) {
        return data['result'] as String;
      } else {
        throw Exception('API 오류: ${data['error']}');
      }
    } else {
      throw Exception('사용자 위치 조회 실패: ${response.statusCode}');
    }
  }

  /// 사용자 위치 등록/수정
  Future<String> updateUserLocation(String regionName) async {
    final accessToken = await AuthStorage.getAccessToken();

    final url = Uri.parse('$_mypageBaseUrl/update-location');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'regionName': regionName,
      }),
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);
      print('사용자 위치 수정: $data');

      if (data['success'] == true) {
        return data['result'] as String;
      } else {
        throw Exception('API 오류: ${data['error']}');
      }
    } else if (response.statusCode == 404) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);

      if (data['error']?['code'] == 'REGION_NOT_FOUND') {
        throw Exception('해당 지역에 대해서는 서비스를 제공하지 않습니다.');
      } else {
        throw Exception('지역을 찾을 수 없습니다.');
      }
    } else {
      throw Exception('사용자 위치 수정 실패: ${response.statusCode}');
    }
  }
}
