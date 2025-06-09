import 'package:client/api/record/record_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recordRepositoryProvider = Provider((ref) => RecordRepository());

final recordViewModelProvider = StateNotifierProvider<RecordViewModel,
    AsyncValue<List<Map<String, dynamic>>>>((ref) => RecordViewModel(ref));

final recordedDaysProvider =
    FutureProvider.family<List<int>, String>((ref, month) async {
  final viewModel = ref.read(recordViewModelProvider.notifier);
  return await viewModel.fetchRecordedDaysByMonth(month);
});

final similarDaysProvider = FutureProvider.family
    .autoDispose<List<int>, ({String month, double temperature})>(
  (ref, args) async {
    final viewModel = ref.read(recordViewModelProvider.notifier);
    return await viewModel.fetchSimilarDaysByMonth(
      month: args.month,
      temperature: args.temperature,
    );
  },
);

class RecordViewModel
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final Ref ref;

  RecordViewModel(this.ref) : super(const AsyncValue.data([]));

  /// 일일 기록 작성
  Future<void> writeRecord({
    required int timeSlot,
    required int feeling,
    required String date,
    required List<int?> uppers,
    required List<int?> outers,
    required String city,
  }) async {
    try {
      print('뷰모델 체크1');
      final repo = ref.read(recordRepositoryProvider);
      final result = await repo.writeRecord(
        timeSlot: timeSlot,
        feeling: feeling,
        date: date,
        uppers: uppers,
        outers: outers,
        city: city,
      );

      print('기록 성공: $result');
    } catch (e) {
      rethrow;
    }
  }

  /// 일일 기록 조회
  Future<void> fetchRecordByDate(String date) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(recordRepositoryProvider);
      final result = await repo.fetchRecordByDate(date);

      // null 체크 추가
      if (result == null) {
        state = const AsyncValue.data([]);
      } else {
        state = AsyncValue.data(result);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 기록한 날 달별 조회
  Future<List<int>> fetchRecordedDaysByMonth(String month) async {
    try {
      final repo = ref.read(recordRepositoryProvider);
      final result = await repo.fetchRecordedDaysByMonth(month);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// 유사날씨 날짜 달별 조회
  Future<List<int>> fetchSimilarDaysByMonth({
    required String month,
    required double temperature,
    double? upperGap,
    double? lowerGap,
  }) async {
    try {
      final repo = ref.read(recordRepositoryProvider);
      final result = await repo.fetchSimilarDaysByMonth(
        month: month,
        temperature: temperature,
        upperGap: upperGap,
        lowerGap: lowerGap,
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
