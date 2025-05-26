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

  void toggleMorning() {
    state = state.copyWith(morning: !state.morning);
  }

  void toggleAfternoon() {
    state = state.copyWith(afternoon: !state.afternoon);
  }

  void toggleEvening() {
    state = state.copyWith(evening: !state.evening);
  }
}

final alarmViewModelProvider =
    StateNotifierProvider<AlarmViewModel, AlarmState>((ref) {
  final repo = ref.watch(alarmRepositoryProvider);
  return AlarmViewModel(repo);
});
