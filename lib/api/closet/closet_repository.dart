import 'dart:convert';
import 'package:client/api/auth/auth_storage.dart';
import 'package:client/model/cloth_item.dart';
import 'package:http/http.dart' as http;

class ClosetRepository {
  final String _baseUrl = 'http://13.124.150.125:8080/api/closet';

  Future<List<CategoryCloth>> getAllClothes() async {
    final accessToken = await AuthStorage.getAccessToken();

    final url = Uri.parse('$_baseUrl');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print(data);
      return data.map((json) => CategoryCloth.fromJson(json)).toList();
    } else {
      throw Exception('옷장을 불러오는데 실패했습니다: ${response.statusCode}');
    }
  }
}
