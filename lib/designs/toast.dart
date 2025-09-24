import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 사용법:
// HowWeatherToast.show(context, "message", true);
// 이렇게 호출

class HowWeatherToast {
  static void show(
    BuildContext context,
    String message,
    bool isError, {
    int duration = 2, // 기본값 2초
  }) {
    final overlay = Overlay.of(context);
    final maxWidth = MediaQuery.of(context).size.width * 0.9;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.1,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isError
                      ? HowWeatherColor.systemRed
                      : HowWeatherColor.systemGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      isError
                          ? "assets/icons/alert.svg"
                          : "assets/icons/complete.svg",
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Semibold_14px(
                        text: message,
                        color: HowWeatherColor.neutral[900],
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(
      Duration(seconds: duration),
    ).then((_) => overlayEntry.remove());
  }
}
