import 'dart:convert';
import 'package:client/api/auth/auth_repository.dart';
import 'package:client/api/auth/auth_storage.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Splash extends ConsumerStatefulWidget {
  const Splash({super.key});

  @override
  ConsumerState<Splash> createState() => _SplashState();
}

class _SplashState extends ConsumerState<Splash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // initState에서 비동기 작업 시작
    _startApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startApp() async {
    await Future.delayed(const Duration(seconds: 2));

    // mounted 체크를 통해 위젯이 여전히 활성 상태인지 확인
    if (!mounted) return;

    final accessToken = await AuthStorage.getAccessToken();
    final refreshToken = await AuthStorage.getRefreshToken();

    print('accessToken: $accessToken');
    print('refreshToken: $refreshToken');

    // 각 비동기 작업 후마다 mounted 체크
    if (!mounted) return;

    if (accessToken != null && refreshToken != null) {
      try {
        if (!isTokenExpired(accessToken)) {
          print('토큰이 만료되지 않았다면 바로 홈으로 이동');
          if (mounted) {
            context.pushReplacement('/home');
          }
        } else {
          print('토큰 만료 시 재발급 시도');
          await AuthRepository().reissueToken();
          if (mounted) {
            context.pushReplacement('/home');
          }
        }
      } catch (e) {
        print('토큰 재발급 실패 시 로그인 화면으로 이동');
        await AuthStorage.clear();
        if (mounted) {
          context.pushReplacement('/signIn');
        }
      }
    } else {
      print('토큰이 없으면 로그인 화면으로 이동');
      if (mounted) {
        context.pushReplacement('/signIn');
      }
    }
  }

  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return true; // 올바른 JWT 형식이 아님
      }

      // 패딩 처리
      String normalizedPayload = parts[1];
      while (normalizedPayload.length % 4 != 0) {
        normalizedPayload += '=';
      }

      final decodedToken =
          jsonDecode(utf8.decode(base64Url.decode(normalizedPayload)));
      final exp = decodedToken['exp']; // 만료 시간 (Unix timestamp)
      final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;

      print('Token exp: $exp, Current time: $currentTime');
      return currentTime > exp; // 현재 시간이 만료 시간보다 크면 만료된 토큰
    } catch (e) {
      print('Token validation error: $e');
      return true; // 토큰 파싱에 실패하면 만료된 것으로 간주
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      color: HowWeatherColor.primary[700],
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Image.asset("assets/images/logo.png"),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                style: TextStyle(
                  color: HowWeatherColor.white,
                  fontFamily: "BagelFatOne",
                  fontSize: 42,
                ),
                "날씨어때",
              ),
              Medium_16px(
                text: "체감 온도 학습 기반 개인화 의상 추천 서비스",
                color: HowWeatherColor.white,
              ),
              const SizedBox(height: 36),
              AnimatedBuilder(
                animation: _progress,
                builder: (context, child) {
                  return Container(
                    width: 108,
                    height: 7,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                      color: HowWeatherColor.secondary[500]!.withOpacity(0.7),
                    ),
                    child: LinearProgressIndicator(
                      value: _progress.value,
                      color: HowWeatherColor.white,
                      backgroundColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
