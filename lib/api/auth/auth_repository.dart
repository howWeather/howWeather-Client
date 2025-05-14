import 'dart:convert';

import 'package:client/model/sign_up.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  final String _baseUrl = 'http://13.124.150.125:8080/api/auth';

  /// 이메일 중복 검증
  Future<bool> verifyEmail(String email) async {
    final url = Uri.parse('$_baseUrl/email-exist-check?email=$email');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['success'];
    } else {
      print(jsonDecode(response.body)['error']['message']);
      throw Exception('이메일 중복 검증 실패: ${response.statusCode}');
    }
  }

  /// 아이디 중복 검증
  Future<bool> verifyLoginId(String loginId) async {
    final url = Uri.parse('$_baseUrl/loginid-exist-check?loginId=$loginId');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['success'];
    } else {
      print(jsonDecode(response.body)['error']['message']);
      throw Exception('아이디 중복 검증 실패: ${response.statusCode}');
    }
  }

  /// 회원가입
  Future<bool> signUp(SignupData signUp) async {
    final url = Uri.parse('$_baseUrl/signup');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(signUp.toJson()),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['success'];
    } else {
      print(jsonDecode(response.body)['error']['message']);
      throw Exception('회원가입 실패: ${response.statusCode}');
    }
  }
}
