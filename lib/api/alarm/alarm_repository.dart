import 'dart:convert';
import 'package:client/api/auth/auth_storage.dart';
import 'package:http/http.dart' as http;

class AlarmRepository {
  final String _baseUrl = 'http://13.124.150.125:8080/api/alarm';

  /// 알림 설정 조회
  Future<Map<String, bool>> getAlarmSettings() async {
    final accessToken = await AuthStorage.getAccessToken();
    final url = Uri.parse(_baseUrl);

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final json = jsonDecode(decoded);
      return {
        'morning': json['morning'] ?? true,
        'afternoon': json['afternoon'] ?? true,
        'evening': json['evening'] ?? true,
      };
    } else {
      throw Exception('알림 정보를 불러오지 못했습니다. 상태 코드: ${response.statusCode}');
    }
  }

  /// 알림 설정 수정
  Future<void> updateAlarmSettings(Map<String, bool> updatedFields) async {
    final accessToken = await AuthStorage.getAccessToken();
    final url = Uri.parse('$_baseUrl/update');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedFields),
    );

    if (response.statusCode != 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final json = jsonDecode(decoded);
      final message = json['error']?['message'] ?? '알림 설정 변경 실패';
      throw Exception(message);
    }
  }
}
