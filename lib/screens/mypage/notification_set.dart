import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherTypo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class NotificationSet extends ConsumerWidget {
  NotificationSet({super.key});

  final morningNotificationProvider = StateProvider<bool>((ref) => true);
  final afternoonNotificationProvider = StateProvider<bool>((ref) => true);
  final eveningNotificationProvider = StateProvider<bool>((ref) => true);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: HowWeatherColor.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Medium_18px(text: "알림 설정"),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            context.pop(); // ← () 빠졌던 거 고침
          },
          child: SvgPicture.asset(
            "assets/icons/chevron-left.svg",
            fit: BoxFit.scaleDown,
            height: 20,
            width: 20,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Medium_18px(text: "전체 알림"),
            Container(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(
                color: HowWeatherColor.primary[900],
                height: 1,
              ),
            ),
            TimeNotification(
                "오전 알림", "오전 9시에 알림이 와요", morningNotificationProvider, ref),
            TimeNotification(
                "오후 알림", "오후 2시에 알림이 와요", afternoonNotificationProvider, ref),
            TimeNotification(
                "저녁 알림", "오후 8시에 알림이 와요", eveningNotificationProvider, ref),
          ],
        ),
      ),
    );
  }

  Widget TimeNotification(String title, String content,
      StateProvider<bool> provider, WidgetRef ref) {
    final isOn = ref.watch(provider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Medium_18px(text: title),
              SizedBox(height: 4),
              Medium_16px(text: content, color: HowWeatherColor.neutral[400]),
            ],
          ),
          Spacer(),
          CupertinoSwitch(
            value: isOn,
            onChanged: (value) {
              ref.read(provider.notifier).state = value;
            },
            activeColor: HowWeatherColor.primary[900],
          ),
        ],
      ),
    );
  }
}
