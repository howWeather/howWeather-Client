import 'dart:convert';
import 'package:client/api/auth/auth_storage.dart';
import 'package:client/api/howweather_api.dart';
import 'package:client/api/interceptor.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AlarmRepository {
  final String _baseUrl = '${API.hostConnect}/api/alarm';
  final HttpInterceptor _http = HttpInterceptor();

  /// 알림 설정 조회
  Future<Map<String, bool>> getAlarmSettings() async {
    final response = await _http.get(_baseUrl);

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
    final url = '$_baseUrl/update';

    final response = await _http.patch(
      url,
      body: updatedFields,
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
    final url = '$_baseUrl/token-save';
    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken == null) {
      print('FCM 토큰을 가져올 수 없음');
      return;
    }
    print(fcmToken);

    final response = await _http.post(
      url,
      body: {"token": fcmToken},
    );

    final decoded = utf8.decode(response.bodyBytes);
    final json = jsonDecode(decoded);
    print('응답 상태 코드: ${response.statusCode}');
    print('응답 바디: $json');

    if (response.statusCode == 200) {
      print('FCM 토큰 등록 완료');
    } else {
      print('FCM 토큰 등록 실패: $json');
    }
  }

  /// FCM token 제거
  Future<void> deleteFCMToken() async {
    try {
      final url = '$_baseUrl/token-delete';
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null) {
        print('FCM 토큰을 가져올 수 없음');
        return;
      }
      print('삭제 요청할 FCM 토큰: $fcmToken');

      final response = await _http.delete(
        url,
        body: {"token": fcmToken},
        useAuth: true,
      );

      print('FCM 토큰 삭제 응답 상태: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ FCM 토큰 제거 성공');
      } else {
        if (response.body.isNotEmpty) {
          try {
            final decoded = utf8.decode(response.bodyBytes);
            final json = jsonDecode(decoded);
            print('❌ FCM 토큰 제거 실패: ${response.statusCode} $json');
          } catch (e) {
            print('❌ FCM 토큰 제거 실패: ${response.statusCode} (응답 본문 파싱 실패)');
          }
        } else {
          print('❌ FCM 토큰 제거 실패: ${response.statusCode} (응답 본문 없음)');
        }
      }
    } catch (e) {
      print('FCM 토큰 제거 중 오류 발생: $e');
    }
  }
}
