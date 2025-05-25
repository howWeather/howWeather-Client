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
}
