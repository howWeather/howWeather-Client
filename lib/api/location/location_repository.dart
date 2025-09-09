import 'dart:convert';
import 'package:client/api/auth/auth_storage.dart';
import 'package:client/api/howweather_api.dart';
import 'package:http/http.dart' as http;

class LocationRepository {
  final String _baseUrl = '${API.hostConnect}/api/location';

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
}
