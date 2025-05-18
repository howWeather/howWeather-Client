import 'package:client/model/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/api/mypage/mypage_repository.dart';

final mypageRepositoryProvider = Provider((ref) => MypageRepository());

final mypageViewModelProvider =
    StateNotifierProvider<MypageViewModel, AsyncValue<UserProfile?>>(
        (ref) => MypageViewModel(ref));

class MypageViewModel extends StateNotifier<AsyncValue<UserProfile?>> {
  final Ref ref;

  MypageViewModel(this.ref) : super(const AsyncLoading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final repo = ref.read(mypageRepositoryProvider);
      final profile = await repo.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 닉네임 수정
  Future<void> updateNickname(String newNickname) async {
    try {
      state = const AsyncLoading(); // 로딩 표시
      final repo = ref.read(mypageRepositoryProvider);
      await repo.updateNickname(newNickname);
      await loadProfile(); // 수정 후 다시 프로필 갱신
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
