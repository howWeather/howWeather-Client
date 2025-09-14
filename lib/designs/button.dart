import 'package:flutter/material.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';

class HWButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool enabled;
  final Color? enabledColor;
  final Color? disabledColor;
  final Color? enabledTextColor;
  final Color? disabledTextColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool hasBorder;

  const HWButton({
    super.key,
    required this.text,
    this.onTap,
    this.enabled = true,
    this.enabledColor,
    this.disabledColor,
    this.enabledTextColor,
    this.disabledTextColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(12),
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = enabled
        ? (enabledColor ?? HowWeatherColor.primary[900])
        : (disabledColor ?? HowWeatherColor.neutral[50]);
    final txtColor = enabled
        ? (enabledTextColor ?? HowWeatherColor.white)
        : (disabledTextColor ?? HowWeatherColor.neutral[500]);
    final borderSide = hasBorder
        ? Border.all(
            color: enabled
                ? (enabledColor ?? HowWeatherColor.primary[900])!
                : (disabledColor ?? HowWeatherColor.neutral[200])!,
            width: 2,
          )
        : null;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: borderSide,
        ),
        child: Center(
          child: Medium_14px(
            text: text,
            color: txtColor,
          ),
        ),
      ),
    );
  }
}
