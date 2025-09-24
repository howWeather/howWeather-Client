import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:client/designs/throttle_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HowWeatherDialog extends ConsumerWidget {
  final String titleText;
  final String contentText;
  final VoidCallback done;
  final bool hasTextField;

  HowWeatherDialog({
    required this.titleText,
    required this.contentText,
    required this.done,
    this.hasTextField = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: HowWeatherColor.white,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 34, horizontal: 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Bold_20px(
              text: titleText,
              color: HowWeatherColor.black,
            ),
            SizedBox(
              height: 8,
            ),
            Medium_16px(
              text: contentText,
              color: HowWeatherColor.neutral[500],
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 16,
            ),
            if (hasTextField) ...[
              SizedBox(
                height: 20,
              ),
              TextField(
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: HowWeatherColor.black),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: HowWeatherColor.neutral[100],
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  labelText: "비밀번호를 입력해주세요",
                  labelStyle: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: HowWeatherColor.neutral[400],
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                obscureText: true,
                onChanged: (value) {
                  // ref.read(withdrawalPasswordProvider.notifier).state = value;
                },
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: done,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.redAccent,
                      ),
                      child: Center(
                        child: Semibold_16px(
                          text: "네",
                          color: HowWeatherColor.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      context.pop();
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: HowWeatherColor.neutral[200],
                      ),
                      child: Center(
                        child: Semibold_16px(
                          text: "아니요",
                          color: HowWeatherColor.neutral[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
