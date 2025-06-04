import 'package:geolocator/geolocator.dart';

class LocationService {
  // 진행 중인 권한 요청을 추적하기 위한 변수
  static Future<LocationPermission>? _permissionFuture;

  // 한 번 가져온 위치 정보를 캐시
  static Future<Position>? _positionFuture;

  Future<Position> getCurrentLocation() async {
    // 이미 가져온 위치 정보가 있으면 재사용
    if (_positionFuture != null) {
      return _positionFuture!;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw '위치 서비스가 비활성화되어 있습니다.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 권한 요청이 이미 진행 중인지 확인
      if (_permissionFuture == null) {
        // 없으면 새로운 권한 요청 시작
        _permissionFuture = Geolocator.requestPermission().then((value) {
          _permissionFuture = null; // 완료 후 초기화
          return value;
        });
      }

      // 진행 중인 권한 요청의 결과를 기다림
      permission = await _permissionFuture!;

      if (permission == LocationPermission.denied) {
        throw '위치 권한이 거부되었습니다.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw '위치 권한이 영구적으로 거부되었습니다.';
    }

    // 위치 정보 가져오기
    _positionFuture = Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return await _positionFuture!;
  }

  // 캐시된 위치 정보 초기화 (필요시 사용)
  void clearCache() {
    _positionFuture = null;
  }
}
