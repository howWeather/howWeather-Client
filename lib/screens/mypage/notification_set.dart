import 'package:client/api/alarm/alarm_view_model.dart';
import 'package:client/designs/how_weather_color.dart';
import 'package:client/designs/how_weather_typo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class NotificationSet extends ConsumerStatefulWidget {
  const NotificationSet({super.key});

  @override
  ConsumerState<NotificationSet> createState() => _NotificationSetState();
}

class _NotificationSetState extends ConsumerState<NotificationSet> {
  @override
  void initState() {
    super.initState();
    // 최초 1번만 불러오기
    Future.microtask(() {
      ref.read(alarmViewModelProvider.notifier).fetchAlarmSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final alarmState = ref.watch(alarmViewModelProvider);
    final alarmNotifier = ref.read(alarmViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: HowWeatherColor.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Medium_18px(text: "알림 설정"),
        centerTitle: true,
        leading: InkWell(
          onTap: () => context.pop(),
          child: SvgPicture.asset(
            "assets/icons/chevron-left.svg",
            fit: BoxFit.scaleDown,
            height: 20,
            width: 20,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Medium_18px(text: "전체 알림"),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Divider(
                color: HowWeatherColor.primary[900],
                height: 1,
              ),
            ),
            _timeNotification("오전 알림", "오전 9시에 알림이 와요", alarmState.morning,
                alarmNotifier.toggleMorning),
            _timeNotification("오후 알림", "오후 2시에 알림이 와요", alarmState.afternoon,
                alarmNotifier.toggleAfternoon),
            _timeNotification("저녁 알림", "오후 8시에 알림이 와요", alarmState.evening,
                alarmNotifier.toggleEvening),
          ],
        ),
      ),
    );
  }

  Widget _timeNotification(
      String title, String content, bool isOn, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Medium_18px(text: title),
              const SizedBox(height: 4),
              Medium_16px(text: content, color: HowWeatherColor.neutral[400]),
            ],
          ),
          const Spacer(),
          CupertinoSwitch(
            value: isOn,
            onChanged: (_) => onToggle(),
            activeColor: HowWeatherColor.primary[900],
          ),
        ],
      ),
    );
  }
}
