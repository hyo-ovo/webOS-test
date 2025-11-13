import 'package:frontend/webos_service_helper/utils.dart';

/// Application Manager Luna Service
/// 앱 실행, 설치된 앱 목록 조회 등의 기능 제공
class AppManagerService {
  /// 설치된 앱의 런치 포인트 목록 조회
  ///
  /// Returns: LaunchPoint 객체 배열
  /// - id: 앱 ID
  /// - launchPointId: 런치 포인트 ID
  /// - title: 앱 이름
  /// - icon: 아이콘 경로
  /// - params: 실행 파라미터
  static Future<Map<String, dynamic>?> listLaunchPoints() async {
    return await callOneReply(
      uri: 'luna://com.webos.service.applicationmanager',
      method: 'listLaunchPoints',
      payload: {},
    );
  }

  /// 앱 실행
  ///
  /// Parameters:
  /// - appId: 실행할 앱의 ID (예: "com.webos.app.browser")
  /// - params: 앱에 전달할 파라미터 (optional)
  ///
  /// Returns:
  /// - returnValue: 성공 여부
  /// - appId: 실행된 앱 ID
  /// - instanceId: 앱 인스턴스 ID
  static Future<Map<String, dynamic>?> launchApp(
    String appId, {
    Map<String, dynamic>? params,
  }) async {
    return await callOneReply(
      uri: 'luna://com.webos.service.applicationmanager',
      method: 'launch',
      payload: {
        'id': appId,
        if (params != null) 'params': params,
      },
    );
  }

  /// 실행 중인 앱 목록 조회
  ///
  /// Returns: 실행 중인 앱 정보 배열
  /// - id: 앱 ID
  /// - processId: 프로세스 ID
  /// - displayId: 디스플레이 ID
  static Future<Map<String, dynamic>?> listApps() async {
    return await callOneReply(
      uri: 'luna://com.webos.service.applicationmanager',
      method: 'listApps',
      payload: {},
    );
  }

  /// 앱 종료
  ///
  /// Parameters:
  /// - appId: 종료할 앱 ID
  /// - instanceId: 특정 인스턴스 ID (optional)
  static Future<Map<String, dynamic>?> closeApp(
    String appId, {
    String? instanceId,
  }) async {
    return await callOneReply(
      uri: 'luna://com.webos.service.applicationmanager',
      method: 'close',
      payload: {
        'id': appId,
        if (instanceId != null) 'instanceId': instanceId,
      },
    );
  }

  /// 포그라운드 앱 정보 조회
  ///
  /// Parameters:
  /// - subscribe: 구독 여부 (기본 false)
  /// - extraInfo: 추가 정보 포함 여부 (기본 false)
  static Future<Map<String, dynamic>?> getForegroundAppInfo({
    bool subscribe = false,
    bool extraInfo = false,
  }) async {
    return await callOneReply(
      uri: 'luna://com.webos.service.applicationmanager',
      method: 'getForegroundAppInfo',
      payload: {
        'subscribe': subscribe,
        'extraInfo': extraInfo,
      },
    );
  }
}
