import 'dart:convert';
import 'package:client/api/auth/auth_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  /// FCM token 등록
  Future<void> saveFCMToken() async {
    final accessToken = await AuthStorage.getAccessToken();
    final url = Uri.parse('$_baseUrl/token-save');
    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken == null) {
      print('FCM 토큰을 가져올 수 없음');
      return;
    }
    print(fcmToken);

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"token": fcmToken}),
    );

    final decoded = utf8.decode(response.bodyBytes);
    final json = jsonDecode(decoded);
    print('응답 상태 코드: ${response.statusCode}');
    print('응답 바디: ${json}');

    if (response.statusCode == 200) {
      print('FCM 토큰 등록 완료');
    } else {
      print('FCM 토큰 등록 실패: ${json}');
    }
  }

  /// FCM token 제거
  Future<void> deleteFCMToken() async {
    final accessToken = await AuthStorage.getAccessToken();
    final url = Uri.parse('$_baseUrl/token-delete');
    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken == null) {
      print('FCM 토큰을 가져올 수 없음');
      return;
    }
    print(fcmToken);

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"token": fcmToken}),
    );

    if (response.statusCode == 204) {
      print('FCM 토큰 제거 성공');
    } else {
      print('FCM 토큰 등록 실패: ${response.body}');
    }
  }
}
