import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/service/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class NoLocationPermission extends StatefulWidget {
  final String e;
  const NoLocationPermission({required this.e, super.key});

  @override
  State<NoLocationPermission> createState() => _NoLocationPermissionState();
}

class _NoLocationPermissionState extends State<NoLocationPermission>
    with WidgetsBindingObserver {
  bool _isCheckingPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && !_isCheckingPermission) {
      await _checkPermissionAndNavigate();
    }
  }

  Future<void> _checkPermissionAndNavigate() async {
    if (_isCheckingPermission) return;

    setState(() {
      _isCheckingPermission = true;
    });

    try {
      // 권한 확인
      final permission = await Geolocator.checkPermission();

      if (!mounted) return;

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        // LocationService 캐시 초기화
        LocationService().clearCache();

        // 홈으로 이동
        context.go('/home');
        return;
      }
    } catch (e) {
      print('권한 확인 중 오류: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingPermission = false;
        });
      }
    }
  }

  Future<void> _requestPermission() async {
    if (_isCheckingPermission) return;

    setState(() {
      _isCheckingPermission = true;
    });

    try {
      // LocationService 캐시 초기화
      LocationService().clearCache();

      // 권한 요청 시도
      await LocationService().getCurrentLocation();

      // 성공하면 홈으로 이동
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;

      // 영구 거부 상태일 경우 설정 열기
      await Geolocator.openAppSettings();

      // 설정에서 돌아온 후 권한 재확인은 didChangeAppLifecycleState에서 처리
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingPermission = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HowWeatherColor.white,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF4093EB), const Color(0xFFABDAEF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Lottie.asset(
                    'assets/lotties/Animation - 1749048637107.json',
                    repeat: true,
                    animate: true,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset("assets/icons/locator-off.svg"),
                        SizedBox(height: 32),
                        Medium_18px(
                          text: widget.e,
                          color: HowWeatherColor.neutral[700],
                        ),
                        SizedBox(height: 12),
                        Medium_16px(
                          text: "위치 권한을 변경하시겠습니까?",
                          color: HowWeatherColor.neutral[700],
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap:
                              _isCheckingPermission ? null : _requestPermission,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: _isCheckingPermission
                                  ? HowWeatherColor.primary[700]
                                      ?.withOpacity(0.6)
                                  : HowWeatherColor.primary[700],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _isCheckingPermission
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: HowWeatherColor.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Semibold_24px(
                                        text: "확인 중...",
                                        color: HowWeatherColor.white,
                                      ),
                                    ],
                                  )
                                : Semibold_24px(
                                    text: "권한 변경하기",
                                    color: HowWeatherColor.white,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
