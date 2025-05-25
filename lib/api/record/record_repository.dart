import 'dart:convert';
import 'package:client/api/auth/auth_storage.dart';
import 'package:http/http.dart' as http;

class RecordRepository {
  final String _baseUrl = 'http://13.124.150.125:8080/api/record';

  /// 일일 기록 작성
  Future<Map<String, dynamic>> writeRecord({
    required int timeSlot,
    required int feeling,
    required String date,
    required List<int> uppers,
    required List<int> outers,
    required String city,
  }) async {
    final accessToken = await AuthStorage.getAccessToken();

    final url = Uri.parse('$_baseUrl/write');
    final body = jsonEncode({
      "timeSlot": timeSlot,
      "feeling": feeling,
      "date": date,
      "uppers": uppers,
      "outers": outers,
      "city": city,
    });

    print('request body: $body');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    final decoded = utf8.decode(response.bodyBytes);
    final jsonBody = jsonDecode(decoded);

    if (response.statusCode == 200 && jsonBody['success'] == true) {
      return jsonBody;
    } else {
      final error = jsonBody['error']?['message'] ?? '알 수 없는 오류';
      throw Exception('$error');
    }
  }

  /// 일일 기록 조회
  Future<List<Map<String, dynamic>>> fetchRecordByDate(String date) async {
    final accessToken = await AuthStorage.getAccessToken();
    final url = Uri.parse('$_baseUrl/date/$date');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    final decoded = utf8.decode(response.bodyBytes);
    final jsonBody = jsonDecode(decoded);

    if (response.statusCode == 200) {
      if (jsonBody is List) {
        return List<Map<String, dynamic>>.from(jsonBody);
      } else {
        throw Exception('예상치 못한 응답 형식입니다.');
      }
    } else {
      final error = jsonBody['error']?['message'] ?? '알 수 없는 오류';
      throw Exception('$error');
    }
  }

  /// 기록한 날 달별 조회
  Future<List<int>> fetchRecordedDaysByMonth(String month) async {
    final accessToken = await AuthStorage.getAccessToken();
    final url = Uri.parse('$_baseUrl/month/$month');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    final decoded = utf8.decode(response.bodyBytes);
    final jsonBody = jsonDecode(decoded);

    if (response.statusCode == 200) {
      return List<int>.from(jsonBody);
    } else {
      throw Exception('기록된 날짜 조회 실패');
    }
  }

  /// 유사날씨 날짜 달별 조회
  Future<List<int>> fetchSimilarDaysByMonth({
    required String month,
    required double temperature,
    double? upperGap,
    double? lowerGap,
  }) async {
    final accessToken = await AuthStorage.getAccessToken();
    final uri = Uri.parse('$_baseUrl/similar/$month').replace(queryParameters: {
      'temperature': temperature.toString(),
      if (upperGap != null) 'upperGap': upperGap.toString(),
      if (lowerGap != null) 'lowerGap': lowerGap.toString(),
    });

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    final decoded = utf8.decode(response.bodyBytes);
    final jsonBody = jsonDecode(decoded);

    if (response.statusCode == 200) {
      return List<int>.from(jsonBody);
    } else {
      throw Exception('유사 기록 날짜 조회 실패');
    }
  }
}
