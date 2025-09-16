import 'dart:convert';
import 'package:client/api/howweather_api.dart';
import 'package:client/api/interceptor.dart';

class RecordRepository {
  final String _baseUrl = '${API.hostConnect}/api/record';
  final HttpInterceptor _httpClient = HttpInterceptor();

  /// 일일 기록 작성
  Future<Map<String, dynamic>> writeRecord({
    required int timeSlot,
    required int feeling,
    required String date,
    required List<int?> uppers,
    required List<int?> outers,
    required String city,
  }) async {
    final endpoint = '$_baseUrl/write';
    final body = {
      "timeSlot": timeSlot,
      "feeling": feeling,
      "date": date,
      "uppers": uppers,
      "outers": outers,
      "city": city,
    };

    final response = await _httpClient.post(
      endpoint,
      body: body,
    );

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200 && decoded['success'] == true) {
      return decoded;
    } else {
      final error = decoded['error']?['message'] ?? '알 수 없는 오류';
      throw Exception('$error');
    }
  }

  /// 일일 기록 조회
  Future<List<Map<String, dynamic>>> fetchRecordByDate(String date) async {
    final endpoint = '$_baseUrl/date/$date';

    final response = await _httpClient.get(endpoint);

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      } else {
        throw Exception('예상치 못한 응답 형식입니다.');
      }
    } else {
      final error = decoded['error']?['message'] ?? '알 수 없는 오류';
      throw Exception('$error');
    }
  }

  /// 기록한 날 달별 조회
  Future<List<int>> fetchRecordedDaysByMonth(String month) async {
    final endpoint = '$_baseUrl/month/$month';

    final response = await _httpClient.get(endpoint);

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      return List<int>.from(decoded);
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
    final queryParams = {
      'temperature': temperature.toString(),
      if (upperGap != null) 'upperGap': upperGap.toString(),
      if (lowerGap != null) 'lowerGap': lowerGap.toString(),
    };

    final endpoint = '$_baseUrl/similar/$month';

    final response = await _httpClient.get(
      endpoint,
      queryParams: queryParams,
    );

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      return List<int>.from(decoded);
    } else {
      throw Exception('유사 기록 날짜 조회 실패');
    }
  }
}
