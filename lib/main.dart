import 'package:client/designs/HowWeatherColor.dart';
import 'package:client/designs/HowWeatherNavi.dart';
import 'package:client/model/sign_up.dart';
import 'package:client/screens/calendar/view.dart';
import 'package:client/screens/mypage/change_password.dart';
import 'package:client/screens/mypage/clothes/clothes_delete.dart';
import 'package:client/screens/mypage/clothes/clothes_enroll.dart';
import 'package:client/screens/mypage/clothes/clothes_view.dart';
import 'package:client/screens/mypage/mypage.dart';
import 'package:client/screens/mypage/notification_set.dart';
import 'package:client/screens/mypage/profile.dart';
import 'package:client/screens/calendar/register/search.dart';
import 'package:client/screens/calendar/register/view.dart';
import 'package:client/screens/mypage/version.dart';
import 'package:client/screens/signIn/findPassword/find_password.dart';
import 'package:client/screens/signIn/findPassword/send_email.dart';
import 'package:client/screens/signIn/signIn.dart';
import 'package:client/screens/signUp/signUpCheck.dart';
import 'package:client/screens/signUp/signUpEmail.dart';
import 'package:client/screens/signUp/signUpId.dart';
import 'package:client/screens/signUp/signUpNickname.dart';
import 'package:client/screens/signUp/signUpPassword.dart';
import 'package:client/screens/signUp/signUpPersonal.dart';
import 'package:client/screens/signUp/signup_clothes_enroll.dart';
import 'package:client/screens/splash/splash.dart';
import 'package:client/screens/todayWear/view.dart';
import 'package:client/screens/todayWeather/view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Splash(),
      ),
      GoRoute(
        path: '/signIn',
        builder: (context, state) => SignIn(),
      ),
      GoRoute(
        path: '/signIn/findPassword',
        builder: (context, state) => FindPassword(),
      ),
      GoRoute(
        path: '/signIn/findPassword/sendEmail',
        builder: (context, state) => SendEmail(),
      ),
      GoRoute(
        path: '/signUp/email',
        builder: (context, state) => SignUpEmail(),
      ),
      GoRoute(
        path: '/signUp/id',
        builder: (context, state) {
          final signupData = state.extra as SignupData;
          return SignUpId(signupData: signupData);
        },
      ),
      GoRoute(
        path: '/signUp/password',
        builder: (context, state) {
          final signupData = state.extra as SignupData;
          return SignUpPassword(signupData: signupData);
        },
      ),
      GoRoute(
        path: '/signUp/nickname',
        builder: (context, state) {
          final signupData = state.extra as SignupData;
          return SignUpNickname(signupData: signupData);
        },
      ),
      GoRoute(
        path: '/signUp/personal',
        builder: (context, state) {
          final signupData = state.extra as SignupData;
          return SignUpPersonal(signupData: signupData);
        },
      ),
      GoRoute(
        path: '/signUp/check',
        builder: (context, state) {
          final signupData = state.extra as SignupData;
          return SignUpCheck(signupData: signupData);
        },
      ),
      GoRoute(
        path: '/signUp/enrollClothes',
        builder: (context, state) => SignUpEnrollClothes(),
      ),
      GoRoute(
        path: '/calendar/register',
        builder: (context, state) => Register(),
      ),
      GoRoute(
        path: '/calendar/register/search',
        builder: (context, state) => AddressSearchPage(),
      ),
      GoRoute(
        path: '/mypage/profile',
        builder: (context, state) => Profile(),
      ),
      GoRoute(
        path: '/mypage/clothes/enroll',
        builder: (context, state) => ClothesEnroll(),
      ),
      GoRoute(
        path: '/mypage/clothes/view',
        builder: (context, state) => ClothesView(),
      ),
      GoRoute(
        path: '/mypage/clothes/delete',
        builder: (context, state) => ClothesDelete(),
      ),
      GoRoute(
        path: '/mypage/changePassword',
        builder: (context, state) => ChangePassword(),
      ),
      GoRoute(
        path: '/mypage/notification',
        builder: (context, state) => NotificationSet(),
      ),
      GoRoute(
        path: '/mypage/version',
        builder: (context, state) => Version(),
      ),
      ShellRoute(
        builder: (context, state, child) => HowWeatherNaviShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => WeatherScreen(),
          ),
          GoRoute(
            path: '/todaywear',
            builder: (context, state) => TodayWear(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => Calendar(),
          ),
          GoRoute(
            path: '/mypage',
            builder: (context, state) => MyPage(),
          ),
        ],
      ),
    ],
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  await dotenv.load(fileName: ".env");
  // ✅ 중복 초기화 방지
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // 알림 권한 요청 (iOS 필수)
  await messaging.requestPermission(alert: true, badge: true, sound: true);
  // 포그라운드 메시지 수신
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Foreground 알림 수신: ${message.notification?.title}');
  });
  runApp(const ProviderScope(child: HowWeather()));
}

class HowWeather extends ConsumerWidget {
  const HowWeather({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'HowWeather',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: HowWeatherColor.white),
        appBarTheme: AppBarTheme(
            // systemOverlayStyle: SystemUiOverlayStyle(
            //   statusBarColor: Colors.transparent,
            //   statusBarIconBrightness: Brightness.light,
            // ),
            ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: HowWeatherColor.neutral[700],
          selectionColor: HowWeatherColor.neutral[700],
          selectionHandleColor: HowWeatherColor.neutral[700],
        ),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
