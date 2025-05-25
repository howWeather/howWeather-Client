import 'package:client/api/record/record_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recordRepositoryProvider = Provider((ref) => RecordRepository());

final recordViewModelProvider = StateNotifierProvider<RecordViewModel,
    AsyncValue<List<Map<String, dynamic>>>>((ref) => RecordViewModel(ref));

class RecordViewModel
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final Ref ref;

  RecordViewModel(this.ref) : super(const AsyncValue.data([]));

  /// 일일 기록 작성
  Future<void> writeRecord({
    required int timeSlot,
    required int feeling,
    required String date,
    required List<int> uppers,
    required List<int> outers,
    required String city,
  }) async {
    try {
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
}
