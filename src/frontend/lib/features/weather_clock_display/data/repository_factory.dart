import 'package:flutter/foundation.dart';
import 'weather_repository.dart';
import 'weather_repository_webos.dart';

/// Repository Factory
///
/// 역할: 실행 환경에 따라 적절한 Repository 인스턴스 생성
/// - Web/Mobile: 일반 HTTP Repository
/// - webOS: Luna Service 기반 Repository
class RepositoryFactory {
  /// 현재 실행 환경 확인
  static bool get isWebOS {
    // webOS 환경 감지 로직
    // TODO: 실제 webOS 감지 로직으로 교체 필요
    // 예: 환경변수, 플랫폼 채널 확인 등

    // 방법 1: kIsWeb을 사용하지 않고 플랫폼 체크
    // 방법 2: 환경변수 체크
    // 방법 3: MethodChannel 사용 가능 여부 체크

    // 임시: 디버그 모드에서는 false (일반 HTTP)
    // 릴리즈 빌드(.ipk)에서는 true (webOS)
    return kReleaseMode && !kIsWeb;
  }

  /// 날씨 Repository 생성
  ///
  /// 환경에 따라 자동으로 올바른 Repository 반환
  /// EnvironmentConfig의 강제 설정도 고려함
  static dynamic createWeatherRepository() {
    // EnvironmentConfig의 강제 설정 먼저 확인
    final useWebOS = EnvironmentConfig.isWebOSMode;

    if (useWebOS) {
      debugPrint('🌐 webOS 환경 - WeatherRepositoryWebOS 사용');
      return WeatherRepositoryWebOS();
    } else {
      debugPrint('💻 로컬 환경 - WeatherRepository 사용');
      return WeatherRepository();
    }
  }

  /// 수동으로 webOS Repository 생성
  static WeatherRepositoryWebOS createWebOSRepository() {
    return WeatherRepositoryWebOS();
  }

  /// 수동으로 일반 Repository 생성
  static WeatherRepository createStandardRepository() {
    return WeatherRepository();
  }
}

/// 환경 설정 클래스
///
/// 앱 전체에서 사용할 환경 설정 관리
/// 손쉽게 환경을 전환할 수 있는 유틸리티 제공
class EnvironmentConfig {
  static bool _forceWebOS = false;
  static bool _forceLocal = false;

  /// webOS 환경 강제 설정 (개발/테스트용)
  ///
  /// [enabled]: true면 webOS 모드로 강제 전환
  /// 사용 예: main.dart에서 EnvironmentConfig.forceWebOS(true) 호출
  static void forceWebOS(bool enabled) {
    _forceWebOS = enabled;
    _forceLocal = false;
    debugPrint('🌐 환경 강제 설정: ${enabled ? "webOS" : "자동 감지"}');
  }

  /// 로컬 환경 강제 설정 (개발/테스트용)
  ///
  /// [enabled]: true면 로컬 모드로 강제 전환
  /// 사용 예: main.dart에서 EnvironmentConfig.forceLocal(true) 호출
  static void forceLocal(bool enabled) {
    _forceLocal = enabled;
    _forceWebOS = false;
    debugPrint('💻 환경 강제 설정: ${enabled ? "로컬" : "자동 감지"}');
  }

  /// 환경 설정 초기화 (자동 감지로 복원)
  static void resetEnvironment() {
    _forceWebOS = false;
    _forceLocal = false;
    debugPrint('🔄 환경 설정 초기화: 자동 감지 모드');
  }

  /// 현재 webOS 모드 여부
  static bool get isWebOSMode {
    if (_forceLocal) return false;
    if (_forceWebOS) return true;
    return RepositoryFactory.isWebOS;
  }

  /// 현재 로컬 모드 여부
  static bool get isLocalMode {
    return !isWebOSMode;
  }

  /// 환경 정보 출력
  static void printEnvironmentInfo() {
    debugPrint('╔═══════════════════════════════╗');
    debugPrint('║      환경 정보              ║');
    debugPrint('╠═══════════════════════════════╣');
    debugPrint('║ 플랫폼: ${_getPlatformName().padRight(20)}║');
    debugPrint('║ 릴리즈 모드: ${kReleaseMode.toString().padRight(15)}║');
    debugPrint('║ 웹 환경: ${kIsWeb.toString().padRight(19)}║');
    debugPrint('║ webOS 모드: ${isWebOSMode.toString().padRight(16)}║');
    if (_forceWebOS) {
      debugPrint('║ 상태: webOS 강제 활성화     ║');
    } else if (_forceLocal) {
      debugPrint('║ 상태: 로컬 강제 활성화      ║');
    } else {
      debugPrint('║ 상태: 자동 감지             ║');
    }
    debugPrint('╚═══════════════════════════════╝');
  }

  static String _getPlatformName() {
    if (kIsWeb) return 'Web';
    if (defaultTargetPlatform == TargetPlatform.android) return 'Android';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'iOS';
    if (defaultTargetPlatform == TargetPlatform.macOS) return 'macOS';
    if (defaultTargetPlatform == TargetPlatform.windows) return 'Windows';
    if (defaultTargetPlatform == TargetPlatform.linux) return 'Linux';
    return 'Unknown';
  }
}
