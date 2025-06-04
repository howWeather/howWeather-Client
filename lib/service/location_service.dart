import 'package:geolocator/geolocator.dart';

class LocationService {
  // 진행 중인 권한 요청을 추적하기 위한 변수
  static Future<LocationPermission>? _permissionFuture;

  // 한 번 가져온 위치 정보를 캐시
  static Future<Position>? _positionFuture;

  Future<Position> getCurrentLocation() async {
    print('📍 LocationService.getCurrentLocation() 시작');

    try {
      // 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('📡 위치 서비스 활성화: $serviceEnabled');
      if (!serviceEnabled) {
        throw '위치 서비스가 비활성화되어 있습니다.';
      }

      // 현재 권한 상태 확인
      LocationPermission permission = await Geolocator.checkPermission();
      print('🔐 LocationService에서 확인한 권한: $permission');

      // 권한이 이미 허용된 경우 바로 위치 정보 가져오기
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        print('✅ 권한이 이미 허용됨 - 위치 정보 가져오기 시작');
        return await _getPosition();
      }

      // 권한이 거부된 경우에만 요청
      if (permission == LocationPermission.denied) {
        print('❌ 권한이 거부됨 - 권한 요청 시작');

        // 권한 요청이 이미 진행 중인지 확인
        if (_permissionFuture == null) {
          _permissionFuture = _requestPermissionWithRetry().then((value) {
            _permissionFuture = null; // 완료 후 초기화
            print('🔐 권한 요청 결과: $value');
            return value;
          });
        }

        // 진행 중인 권한 요청의 결과를 기다림
        permission = await _permissionFuture!;

        if (permission == LocationPermission.denied) {
          throw '위치 권한이 거부되었습니다.';
        }
      }

      // 영구 거부 상태 확인
      if (permission == LocationPermission.deniedForever) {
        throw '위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.';
      }

      // 권한이 허용된 경우 위치 정보 가져오기
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        print('✅ 권한 요청 후 허용됨 - 위치 정보 가져오기');
        return await _getPosition();
      }

      throw '위치 권한을 얻을 수 없습니다.';
    } catch (e) {
      print('💥 LocationService.getCurrentLocation() 최종 에러: $e');
      print('💥 에러 타입: ${e.runtimeType}');

      // 스택 트레이스도 출력
      if (e is Error) {
        print('💥 스택 트레이스: ${e.stackTrace}');
      }

      // 에러 발생 시 캐시 초기화
      clearCache();
      rethrow;
    }
  }

  // 권한 요청을 재시도하는 메서드
  Future<LocationPermission> _requestPermissionWithRetry() async {
    try {
      // 첫 번째 시도
      LocationPermission permission = await Geolocator.requestPermission();
      print('첫 번째 권한 요청 결과: $permission');

      // 권한이 여전히 denied이고, deniedForever가 아닌 경우 한 번 더 시도
      if (permission == LocationPermission.denied) {
        print('권한이 거부됨 - 잠시 후 재시도');
        await Future.delayed(Duration(milliseconds: 500));

        // 현재 상태 다시 확인
        permission = await Geolocator.checkPermission();
        print('재확인된 권한 상태: $permission');

        // 여전히 denied인 경우 한 번 더 요청
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          print('두 번째 권한 요청 결과: $permission');
        }
      }

      return permission;
    } catch (e) {
      print('권한 요청 중 에러: $e');
      throw e;
    }
  }

  Future<Position> _getPosition() async {
    print('🎯 _getPosition() 시작');

    // 캐시된 위치 정보가 있고 여전히 유효한 경우 재사용
    if (_positionFuture != null) {
      try {
        print('📦 캐시된 위치 정보 확인 중...');
        Position position = await _positionFuture!;

        // 위치 정보가 너무 오래된 경우 새로 요청 (5분 이상)
        final now = DateTime.now();
        final positionTime = DateTime.fromMillisecondsSinceEpoch(
            position.timestamp.millisecondsSinceEpoch);
        final timeDifference = now.difference(positionTime);

        print('⏰ 캐시된 위치 정보 시간 차이: ${timeDifference.inMinutes}분');

        if (timeDifference.inMinutes > 5) {
          print('⏰ 캐시된 위치 정보가 오래됨 - 새로 요청');
          _positionFuture = null;
        } else {
          print('✅ 캐시된 위치 정보 사용: ${position.latitude}, ${position.longitude}');
          return position;
        }
      } catch (e) {
        print('💥 캐시된 위치 정보 사용 실패: $e');
        print('💥 캐시 에러 타입: ${e.runtimeType}');
        // 캐시된 요청이 실패했으면 새로 시도
        _positionFuture = null;
      }
    }

    print('🆕 새로운 위치 정보 요청 시작');
    // 새로운 위치 정보 요청
    _positionFuture = _getCurrentPositionWithFallback().then((position) {
      print('✅ 위치 정보 가져오기 최종 성공: ${position.latitude}, ${position.longitude}');
      print('📊 정확도: ${position.accuracy}m, 시간: ${position.timestamp}');
      return position;
    }).catchError((error) {
      print('💥 위치 정보 가져오기 최종 실패: $error');
      print('💥 위치 에러 타입: ${error.runtimeType}');
      _positionFuture = null; // 실패 시 캐시 초기화
      throw error;
    });

    return await _positionFuture!;
  }

  // 위치 정보 가져오기 (fallback 포함)
  Future<Position> _getCurrentPositionWithFallback() async {
    print('🎯 _getCurrentPositionWithFallback() 시작');

    try {
      print('🎯 1단계: 높은 정확도 위치 요청 (10초 타임아웃)');
      // 높은 정확도로 시도
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      print('✅ 높은 정확도 위치 요청 성공: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('💥 높은 정확도 위치 요청 실패: $e (타입: ${e.runtimeType})');

      try {
        print('🎯 2단계: 중간 정확도 위치 요청 (15초 타임아웃)');
        // 중간 정확도로 재시도
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        );
        print('✅ 중간 정확도 위치 요청 성공: ${position.latitude}, ${position.longitude}');
        return position;
      } catch (e2) {
        print('💥 중간 정확도 위치 요청 실패: $e2 (타입: ${e2.runtimeType})');

        try {
          print('🎯 3단계: 낮은 정확도 위치 요청 (20초 타임아웃)');
          // 낮은 정확도로 최종 시도
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 20),
          );
          print(
              '✅ 낮은 정확도 위치 요청 성공: ${position.latitude}, ${position.longitude}');
          return position;
        } catch (e3) {
          print('💥 낮은 정확도 위치 요청 실패: $e3 (타입: ${e3.runtimeType})');

          try {
            print('🎯 4단계: 마지막 알려진 위치 시도');
            // 마지막 수단으로 getLastKnownPosition 시도
            Position? lastPosition = await Geolocator.getLastKnownPosition();
            if (lastPosition != null) {
              print(
                  '✅ 마지막 알려진 위치 사용: ${lastPosition.latitude}, ${lastPosition.longitude}');
              return lastPosition;
            } else {
              print('💥 마지막 알려진 위치도 없음');
            }
          } catch (e4) {
            print('💥 마지막 알려진 위치 요청 실패: $e4 (타입: ${e4.runtimeType})');
          }

          // 모든 시도가 실패한 경우 상세한 에러 메시지
          String detailedError = '''
위치 정보를 가져올 수 없습니다.
- 높은 정확도 실패: $e
- 중간 정확도 실패: $e2  
- 낮은 정확도 실패: $e3
네트워크 연결과 GPS 설정을 확인해주세요.''';

          print('💥 모든 위치 요청 방법 실패');
          throw detailedError;
        }
      }
    }
  }

  // 캐시된 정보 초기화
  void clearCache() {
    print('LocationService 캐시 초기화');
    _positionFuture = null;
    _permissionFuture = null;
  }

  // 권한 상태만 확인하는 메서드
  Future<bool> hasLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      final hasPermission = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
      print('권한 상태 확인: $permission, 권한 있음: $hasPermission');
      return hasPermission;
    } catch (e) {
      print('권한 상태 확인 중 에러: $e');
      return false;
    }
  }

  // 위치 서비스와 권한이 모두 정상인지 확인
  Future<bool> isLocationAvailable() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      bool hasPermission = await hasLocationPermission();

      print('위치 서비스 사용 가능: $serviceEnabled, 권한 있음: $hasPermission');
      return serviceEnabled && hasPermission;
    } catch (e) {
      print('위치 사용 가능성 확인 중 에러: $e');
      return false;
    }
  }
}
