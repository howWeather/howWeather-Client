import 'dart:convert';
import 'package:client/api/auth/auth_storage.dart';
import 'package:client/api/howweather_api.dart';
import 'package:client/api/interceptor.dart';
import 'package:client/model/sign_up.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  final String _baseUrl = '${API.hostConnect}/api/auth';
  final HttpInterceptor _httpClient = HttpInterceptor();

  /// 이메일 중복 검증
  Future<bool> verifyEmail(String email) async {
    final endpoint = '$_baseUrl/email-exist-check';

    final response = await _httpClient.get(
      endpoint,
      queryParams: {'email': email},
      headers: {'Content-Type': 'application/json'},
      useAuth: false, // 로그인 전 요청
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      return responseBody['success'];
    } else if (response.statusCode == 409) {
      throw '중복된 이메일입니다.';
    } else {
      throw Exception('이메일 중복 검증 실패: ${response.statusCode}');
    }
  }

  /// 이메일 인증 코드 요청
  Future<String> requestEmailVerificationCode(String email) async {
    final endpoint = '$_baseUrl/email/code';

    final response = await _httpClient.post(
      endpoint,
      headers: {'Content-Type': 'application/json'},
      body: {'email': email},
      useAuth: false, // 로그인 전 요청
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200 && responseBody['success'] == true) {
      return responseBody['result'];
    } else {
      final errorMessage = responseBody['error']?['message'] ??
          responseBody['message'] ??
          '인증 코드 요청에 실패했습니다.';
      throw Exception(errorMessage);
    }
  }

  /// 이메일 인증 코드 검증
  Future<String> verifyEmailCode(String email, String code) async {
    final endpoint = '$_baseUrl/email/verify';

    final response = await _httpClient.post(
      endpoint,
      headers: {'Content-Type': 'application/json'},
      body: {'email': email, 'code': code},
      useAuth: false, // 로그인 전 요청
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200 && responseBody['success'] == true) {
      return responseBody['result'];
    } else {
      final errorMessage = responseBody['error']?['message'] ??
          responseBody['message'] ??
          '이메일 인증에 실패했습니다.';
      throw Exception(errorMessage);
    }
  }

  /// 아이디 중복 검증
  Future<bool> verifyLoginId(String loginId) async {
    final endpoint = '$_baseUrl/loginid-exist-check';

    final response = await _httpClient.get(
      endpoint,
      queryParams: {'loginId': loginId},
      headers: {'Content-Type': 'application/json'},
      useAuth: false, // 로그인 전 요청
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      return responseBody['success'];
    } else {
      throw Exception('아이디 중복 검증 실패: ${response.statusCode}');
    }
  }

  /// 회원가입
  Future<bool> signUp(SignupData signUp) async {
    final endpoint = '$_baseUrl/signup';

    final response = await _httpClient.post(
      endpoint,
      headers: {'Content-Type': 'application/json'},
      body: signUp.toJson(),
      useAuth: false, // 로그인 전 요청
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200 && responseBody['success'] == true) {
      return true;
    } else {
      final errorMessage = responseBody['error']?['message'] ??
          responseBody['message'] ??
          '회원가입에 실패했습니다.';
      throw Exception(errorMessage);
    }
  }

  /// 로그인 (토큰이 없는 상태이므로 인터셉터 사용 안함)
  Future<Map<String, String>> login(String loginId, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "loginId": loginId,
        "password": password,
      }),
    );

    final jsonBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200 && jsonBody['success'] == true) {
      final result = jsonBody['result'];
      final accessToken = result['accessToken'];
      final refreshToken = result['refreshToken'];

      await AuthStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await AuthStorage.setLoginType('email');

      return {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
    } else {
      final errorMessage = jsonBody['error']?['message'] ??
          jsonBody['message'] ??
          '로그인에 실패했습니다.';
      throw Exception(errorMessage);
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    // 먼저 로컬 토큰을 클리어하여 다른 요청들이 토큰 재발급을 시도하지 않도록 함
    await AuthStorage.clear();

    final endpoint = '$_baseUrl/logout';

    try {
      final response = await _httpClient.post(endpoint);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        // 로그아웃 성공 시 즉시 로그인 화면으로 이동
        final context = HttpInterceptor.navigatorKey?.currentContext;
        if (context != null && context.mounted) {
          context.pushReplacement('/signIn');
        }
        return responseBody['success'];
      }
    } catch (e) {
      print('로그아웃 API 호출 실패: $e');
    }

    // API 호출 실패해도 로컬 토큰은 이미 클리어했으므로 로그인 화면으로 이동
    final context = HttpInterceptor.navigatorKey?.currentContext;
    if (context != null && context.mounted) {
      context.pushReplacement('/signIn');
    }
  }

  /// 회원탈퇴
  Future<void> withdraw() async {
    // 먼저 로컬 토큰을 클리어하여 다른 요청들이 토큰 재발급을 시도하지 않도록 함
    final loginType = await AuthStorage.getLoginType();
    final socialToken = await AuthStorage.getSocialToken();

    // 토큰 정보를 미리 저장한 후 클리어
    await AuthStorage.clear();

    final headers = <String, String>{};
    if (loginType == 'social' && socialToken != null) {
      headers["Social-Access-Token"] = socialToken;
    }

    final endpoint = '$_baseUrl/delete';

    try {
      final response = await _httpClient.delete(
        endpoint,
        headers: headers,
      );

      if (response.statusCode == 204) {
        final context = HttpInterceptor.navigatorKey?.currentContext;
        if (context != null && context.mounted) {
          context.pushReplacement('/signIn');
        }
      }
    } catch (e) {
      print('탈퇴 API 호출 실패: $e');
    }

    // API 호출 실패해도 로컬 토큰은 이미 클리어했으므로 로그인 화면으로 이동
    final context = HttpInterceptor.navigatorKey?.currentContext;
    if (context != null && context.mounted) {
      context.pushReplacement('/signIn');
    }
  }

  /// 비밀번호 초기화 (토큰 없는 상태)
  Future<String?> resetPassword(String identifier) async {
    final url = Uri.parse('$_baseUrl/reset-password');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"identifier": identifier}),
    );

    final jsonBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      return jsonBody['result'];
    } else {
      return jsonBody['result'];
    }
  }

  /// 비밀번호 변경
  Future<void> updatePassword(
      String oldPassword, String newPassword, String confirmPassword) async {
    final endpoint = '$_baseUrl/update-password';

    final response = await _httpClient.post(
      endpoint,
      headers: {'Content-Type': 'application/json'},
      body: {
        "oldPassword": oldPassword,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      },
    );

    final jsonBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      await AuthStorage.clear();
      return;
    } else {
      throw Exception('비밀번호 변경 실패: ${jsonBody['error']['message']}');
    }
  }
}
