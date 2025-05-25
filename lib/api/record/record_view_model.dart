import 'package:client/api/record/record_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recordRepositoryProvider = Provider((ref) => RecordRepository());

final recordViewModelProvider =
    StateNotifierProvider<RecordViewModel, AsyncValue<void>>(
        (ref) => RecordViewModel(ref));

class RecordViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  RecordViewModel(this.ref) : super(const AsyncData(null));

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
}
