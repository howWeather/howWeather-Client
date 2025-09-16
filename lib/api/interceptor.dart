import 'dart:async';
import 'dart:convert';
import 'package:client/api/auth/auth_storage.dart';
import 'package:client/api/howweather_api.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class HttpInterceptor {
  static final HttpInterceptor _instance = HttpInterceptor._internal();
  factory HttpInterceptor() => _instance;
  HttpInterceptor._internal();

  /// 전역 Navigator 키
  static GlobalKey<NavigatorState>? navigatorKey;

  /// 토큰 재발급 상태
  bool _isRefreshing = false;

  /// 재발급 대기 요청들
  final List<_PendingRequest> _pendingRequests = [];

  /// GET 요청
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool useAuth = true,
  }) async {
    String url = endpoint;
    if (queryParams != null && queryParams.isNotEmpty) {
      final query = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      url += '?$query';
    }
    final uri = Uri.parse(url);

    final requestHeaders = await _buildHeaders(headers, useAuth: useAuth);

    // GET + request body 요청 생성
    final request = http.Request('GET', uri);
    request.headers.addAll(requestHeaders);

    if (body != null) {
      request.body = jsonEncode(body);
    }

    // 요청 전송
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return await _handleResponse(
      response,
      () => get(endpoint,
          headers: headers,
          body: body,
          queryParams: queryParams,
          useAuth: useAuth),
    );
  }

  /// POST 요청
  Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    bool useAuth = true,
  }) async {
    final uri = Uri.parse(endpoint);
    final requestHeaders = await _buildHeaders(headers, useAuth: useAuth);
    String? requestBody =
        body != null ? (body is String ? body : jsonEncode(body)) : null;

    final response =
        await http.post(uri, headers: requestHeaders, body: requestBody);
    return await _handleResponse(
      response,
      () => post(endpoint, headers: headers, body: body, useAuth: useAuth),
    );
  }

  /// PUT 요청
  Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    bool useAuth = true,
  }) async {
    final uri = Uri.parse(endpoint);
    final requestHeaders = await _buildHeaders(headers, useAuth: useAuth);
    String? requestBody =
        body != null ? (body is String ? body : jsonEncode(body)) : null;

    final response =
        await http.put(uri, headers: requestHeaders, body: requestBody);
    return await _handleResponse(
      response,
      () => put(endpoint, headers: headers, body: body, useAuth: useAuth),
    );
  }

  /// PATCH 요청
  Future<http.Response> patch(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    bool useAuth = true,
  }) async {
    final uri = Uri.parse(endpoint);
    final requestHeaders = await _buildHeaders(headers, useAuth: useAuth);
    String? requestBody =
        body != null ? (body is String ? body : jsonEncode(body)) : null;

    final response =
        await http.patch(uri, headers: requestHeaders, body: requestBody);
    return await _handleResponse(
      response,
      () => patch(endpoint, headers: headers, body: body, useAuth: useAuth),
    );
  }

  /// DELETE 요청
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    bool useAuth = true,
  }) async {
    final uri = Uri.parse(endpoint);
    final requestHeaders = await _buildHeaders(headers, useAuth: useAuth);

    final response = await http.delete(uri, headers: requestHeaders);
    return await _handleResponse(
      response,
      () => delete(endpoint, headers: headers, useAuth: useAuth),
    );
  }

  /// 헤더 구성
  Future<Map<String, String>> _buildHeaders(
    Map<String, String>? customHeaders, {
    bool useAuth = true,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (customHeaders != null) headers.addAll(customHeaders);

    if (useAuth) {
      final accessToken = await AuthStorage.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
        final refreshToken = await AuthStorage.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          headers['Refresh-Token'] = 'Bearer $refreshToken';
        }
      }
    }

    return headers;
  }

  /// 응답 처리 및 토큰 만료 체크
  Future<http.Response> _handleResponse(
    http.Response response,
    Future<http.Response> Function() retry,
  ) async {
    if (response.statusCode == 401 || response.statusCode == 403) {
      if (_isRefreshing) return await _waitForTokenRefresh(retry);

      final success = await _attemptTokenRefresh();
      if (success) return await retry();
      await _handleTokenFailure();
      return response;
    }
    return response;
  }

  /// 토큰 재발급 시도
  Future<bool> _attemptTokenRefresh() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    try {
      final refreshToken = await AuthStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final url = Uri.parse('${API.hostConnect}/api/auth/reissue');
      final response = await http.post(url, headers: {
        'Authorization': 'Bearer $refreshToken',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final newAccessToken = body['result']['accessToken'];
          await AuthStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: refreshToken,
          );
          _processPendingRequests();
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// 토큰 재발급 대기 요청 처리
  Future<http.Response> _waitForTokenRefresh(
      Future<http.Response> Function() retry) {
    final completer = Completer<http.Response>();
    _pendingRequests.add(_PendingRequest(retry, completer));
    return completer.future;
  }

  void _processPendingRequests() {
    for (final req in _pendingRequests) {
      req
          .retry()
          .then((res) => req.completer.complete(res))
          .catchError((e) => req.completer.completeError(e));
    }
    _pendingRequests.clear();
  }

  Future<void> _handleTokenFailure() async {
    await AuthStorage.clear();
    _navigateToLogin();
  }

  void _navigateToLogin() {
    final context = navigatorKey?.currentContext;
    if (context != null && context.mounted) {
      // Flutter Toast로 메시지 표시
      Fluttertoast.showToast(
        msg: "세션 만료: 로그인이 만료되었습니다.\n다시 로그인해 주세요.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );

      // 로그인 화면으로 이동
      context.pushReplacement('/signIn');
    } else {
      print('세션 만료: context 없음, 로그인 화면으로 이동 필요');
    }
  }

  /// 토큰 만료 여부 확인
  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      String normalizedPayload = parts[1];
      while (normalizedPayload.length % 4 != 0) normalizedPayload += '=';

      final decodedToken =
          jsonDecode(utf8.decode(base64Url.decode(normalizedPayload)));
      final exp = decodedToken['exp'];
      final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
      return currentTime > exp;
    } catch (_) {
      return true;
    }
  }
}

class _PendingRequest {
  final Future<http.Response> Function() retry;
  final Completer<http.Response> completer;

  _PendingRequest(this.retry, this.completer);
}
