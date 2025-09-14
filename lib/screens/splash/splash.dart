import 'dart:convert';
import 'dart:io'; // Platform 체크용
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

    _startApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startApp() async {
    // iOS에서는 알림 권한 요청 건너뛰기
    if (!Platform.isIOS) {
      await requestNotificationPermission();
    } else {
      print('iOS에서는 알림 권한 요청 건너뜀2');
    }

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final accessToken = await AuthStorage.getAccessToken();
    final refreshToken = await AuthStorage.getRefreshToken();

    if (!mounted) return;

    if (accessToken != null && refreshToken != null) {
      try {
        if (!isTokenExpired(accessToken)) {
          if (mounted) context.pushReplacement('/home');
        } else {
          await AuthRepository().reissueToken();
          if (mounted) context.pushReplacement('/home');
        }
      } catch (e) {
        await AuthStorage.clear();
        if (mounted) context.pushReplacement('/signIn');
      }
    } else {
      if (mounted) context.pushReplacement('/signIn');
    }
  }

  // 알림 권한 요청 (Android 전용)
  Future<void> requestNotificationPermission() async {
    print('Android에서만 알림 권한 요청 수행');
    // 여기에 기존 알림 권한 요청 코드 삽입
  }

  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      String normalizedPayload = parts[1];
      while (normalizedPayload.length % 4 != 0) {
        normalizedPayload += '=';
      }

      final decodedToken =
          jsonDecode(utf8.decode(base64Url.decode(normalizedPayload)));
      final exp = decodedToken['exp'];
      final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;

      return currentTime > exp;
    } catch (e) {
      return true;
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
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Image.asset("assets/images/logo.png"),
                ),
                const SizedBox(height: 16),
                Text(
                  "날씨어때",
                  style: TextStyle(
                    color: HowWeatherColor.white,
                    fontFamily: "BagelFatOne",
                    fontSize: 42,
                  ),
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
      ),
    );
  }
}
