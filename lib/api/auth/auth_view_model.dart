import 'package:client/api/auth/auth_repository.dart';
import 'package:client/model/sign_up.dart';
import 'package:client/screens/sign_up/sign_up_id.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AsyncValue<void>>(
  (ref) => AuthViewModel(ref),
);

class AuthViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  AuthViewModel(this.ref) : super(const AsyncData(null));

  /// 이메일 중복 검증
  Future<void> verifyEmail(String email) async {
    final repo = ref.read(authRepositoryProvider);
    try {
      await repo.verifyEmail(email);
      print('✅ 이메일 중복 검증 확인 완료');
    } catch (e) {
      print('❌ 이메일 중복 검증 확인 실패: $e');
      throw e;
    }
  }

  /// 아이디 중복 검증
  Future<void> verifyloginId(String loginId) async {
    final repo = ref.read(authRepositoryProvider);
    try {
      await repo.verifyLoginId(loginId);
      ref.read(duplicateProvider.notifier).state = '';
      print('✅ 아이디 중복 검증 확인 완료');
    } catch (e) {
      print('❌ 아이디 중복 검증 확인 실패: $e');
      ref.read(duplicateProvider.notifier).state = 'duplicated';
      throw e;
    }
  }

  // 회원가입
  Future<void> signUpWithFullData(SignupData data) async {
    state = const AsyncLoading();

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signUp(data);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // 로그인
  Future<void> login(String loginId, String password) async {
    state = const AsyncLoading();

    try {
      final repo = ref.read(authRepositoryProvider);
      final tokens = await repo.login(loginId, password);

      print('AccessToken: ${tokens['accessToken']}');
      print('RefreshToken: ${tokens['refreshToken']}');

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
