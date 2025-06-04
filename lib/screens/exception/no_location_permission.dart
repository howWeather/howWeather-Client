import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';

class NoLocationPermission extends StatefulWidget {
  final String e;
  const NoLocationPermission({required this.e, super.key});

  @override
  State<NoLocationPermission> createState() => _NoLocationPermissionState();
}

class _NoLocationPermissionState extends State<NoLocationPermission> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Center(
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
                    onTap: () async {
                      await Geolocator.openAppSettings();
                      if (await Geolocator.checkPermission() ==
                          LocationPermission.whileInUse) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: HowWeatherColor.primary[700],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Semibold_24px(
                        text: "설정으로 이동",
                        color: HowWeatherColor.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
