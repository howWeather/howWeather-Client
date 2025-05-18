import 'package:client/model/user_profile.dart';
import 'package:client/screens/mypage/profile.dart';
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

  /// 체질 수정
  Future<void> updateConstitution(int newConstitution) async {
    try {
      state = const AsyncLoading(); // 로딩 상태로 변경
      final repo = ref.read(mypageRepositoryProvider);
      await repo.updateConstitution(newConstitution);
      await loadProfile(); // 수정 후 프로필 다시 불러오기
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 성별 수정
  Future<void> updateGender(int newGender) async {
    try {
      state = const AsyncLoading(); // 로딩 상태
      final repo = ref.read(mypageRepositoryProvider);
      await repo.updateGender(newGender);
      await loadProfile(); // 수정 후 최신 프로필 다시 불러오기
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 연령대 수정
  Future<void> updateAge(int newAgeGroup) async {
    try {
      state = const AsyncLoading();
      final repo = ref.read(mypageRepositoryProvider);
      await repo.updateAge(newAgeGroup);
      await loadProfile(); // 변경 후 프로필 갱신
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
