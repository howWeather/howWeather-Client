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

  Future<void> loadClothes() async {
    try {
      final repo = ClosetRepository();
      final clothes = await repo.getAllClothes();
      state = AsyncValue.data(clothes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
