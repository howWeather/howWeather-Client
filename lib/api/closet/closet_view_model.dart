import 'package:client/api/closet/closet_repository.dart';
import 'package:client/model/cloth_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final closetProvider =
    StateNotifierProvider<ClosetNotifier, AsyncValue<List<CategoryCloth>>>(
        (ref) => ClosetNotifier());

class ClosetNotifier extends StateNotifier<AsyncValue<List<CategoryCloth>>> {
  ClosetNotifier() : super(const AsyncLoading()) {
    loadClothes();
  }

  /// 의류 조회
  Future<void> loadClothes() async {
    try {
      final repo = ClosetRepository();
      final clothes = await repo.getAllClothes();
      state = AsyncValue.data(clothes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 의류 등록
  Future<void> registerClothes({
    required List<Map<String, dynamic>> uppers,
    required List<Map<String, dynamic>> outers,
  }) async {
    try {
      final repo = ClosetRepository();
      final result = await repo.registerClothes(uppers: uppers, outers: outers);

      await loadClothes();

      print(result);
    } catch (e) {
      print('의상 등록 실패: $e');
      rethrow;
    }
  }

  /// 상의 수정
  Future<void> updateUpperCloth({
    required int clothId,
    int? color,
    int? thickness,
  }) async {
    try {
      final repo = ClosetRepository();
      final result = await repo.updateUpperCloth(
        clothId: clothId,
        color: color,
        thickness: thickness,
      );

      await loadClothes();

      print(result);
    } catch (e) {
      print('상의 수정 실패: $e');
      rethrow;
    }
  }

  /// 아우터 수정
  Future<void> updateOuterCloth({
    required int clothId,
    int? color,
    int? thickness,
  }) async {
    try {
      final repo = ClosetRepository();
      final result = await repo.updateOuterCloth(
        clothId: clothId,
        color: color,
        thickness: thickness,
      );

      await loadClothes();

      print(result);
    } catch (e) {
      print('상의 수정 실패: $e');
      rethrow;
    }
  }

  /// 상의 삭제
  Future<void> deleteUpperCloth({
    required int clothId,
  }) async {
    try {
      final repo = ClosetRepository();
      await repo.deleteUpperCloth(clothId: clothId);

      await loadClothes(); // 삭제 후 의류 목록 갱신
    } catch (e) {
      print('상의 삭제 실패: $e');
      rethrow;
    }
  }
}
