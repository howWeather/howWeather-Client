import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/api/alarm/alarm_repository.dart';

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  return AlarmRepository();
});

class AlarmState {
  final bool morning;
  final bool afternoon;
  final bool evening;

  AlarmState({
    required this.morning,
    required this.afternoon,
    required this.evening,
  });

  AlarmState copyWith({bool? morning, bool? afternoon, bool? evening}) {
    return AlarmState(
      morning: morning ?? this.morning,
      afternoon: afternoon ?? this.afternoon,
      evening: evening ?? this.evening,
    );
  }
}

class AlarmViewModel extends StateNotifier<AlarmState> {
  final AlarmRepository repository;
  AlarmViewModel(this.repository)
      : super(AlarmState(morning: true, afternoon: true, evening: true));

  /// 알림 설정 조회
  Future<void> fetchAlarmSettings() async {
    final data = await repository.getAlarmSettings();
    state = AlarmState(
      morning: data['morning']!,
      afternoon: data['afternoon']!,
      evening: data['evening']!,
    );
  }

  void toggleMorning() async {
    final newValue = !state.morning;
    state = state.copyWith(morning: newValue);
    try {
      await repository.updateAlarmSettings({'morning': newValue});
    } catch (e) {
      // 실패 시 원래 값으로 롤백
      state = state.copyWith(morning: !newValue);
    }
  }

  void toggleAfternoon() async {
    final newValue = !state.afternoon;
    state = state.copyWith(afternoon: newValue);
    try {
      await repository.updateAlarmSettings({'afternoon': newValue});
    } catch (e) {
      state = state.copyWith(afternoon: !newValue);
    }
  }

  void toggleEvening() async {
    final newValue = !state.evening;
    state = state.copyWith(evening: newValue);
    try {
      await repository.updateAlarmSettings({'evening': newValue});
    } catch (e) {
      state = state.copyWith(evening: !newValue);
    }
  }
}

final alarmViewModelProvider =
    StateNotifierProvider<AlarmViewModel, AlarmState>((ref) {
  final repo = ref.watch(alarmRepositoryProvider);
  return AlarmViewModel(repo);
});
