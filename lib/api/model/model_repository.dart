import 'dart:convert';
import 'package:client/api/auth/auth_storage.dart';
import 'package:client/api/howweather_api.dart';
import 'package:client/model/model_recommendation.dart';
import 'package:http/http.dart' as http;

class ModelRepository {
  final String _baseUrl = '${API.hostConnect}/api/model/recommendation';

  Future<List<ModelRecommendation>> fetchModelRecommendation() async {
    final accessToken = await AuthStorage.getAccessToken();

    final url = Uri.parse(_baseUrl);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    final decodedBody = utf8.decode(response.bodyBytes);
    final jsonBody = jsonDecode(decodedBody);

    if (response.statusCode == 200 && jsonBody['success'] == true) {
      final resultList = jsonBody['result'] as List;

      return resultList
          .map((item) => ModelRecommendation.fromJson(item))
          .toList();
    } else {
      throw Exception('모델 추천 결과 불러오기 실패: ${response.statusCode}');
    }
  }
}
