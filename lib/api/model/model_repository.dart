import 'dart:convert';
import 'package:client/api/howweather_api.dart';
import 'package:client/api/interceptor.dart';
import 'package:client/model/model_recommendation.dart';

class ModelRepository {
  final String _baseUrl = '${API.hostConnect}/api/model/recommendation';
  final HttpInterceptor _http = HttpInterceptor();

  Future<List<ModelRecommendation>> fetchModelRecommendation() async {
    final response = await _http.get(_baseUrl);

    final decodedBody = utf8.decode(response.bodyBytes);
    final jsonBody = jsonDecode(decodedBody);
    print(jsonBody);

    if (response.statusCode == 200 && jsonBody['success'] == true) {
      final resultList = jsonBody['result'] as List;

      return resultList
          .map((item) => ModelRecommendation.fromJson(item))
          .toList();
    } else {
      final message = jsonBody['error']?['message'] ?? '모델 추천 결과 불러오기 실패';
      throw Exception(message);
    }
  }
}
