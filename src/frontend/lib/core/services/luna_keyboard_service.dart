import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// webOS Luna 키보드 서비스 헬퍼
///
/// - webOS 환경이 아닐 경우 실제 Luna 호출은 생략됩니다.
/// - 텍스트 입력이 필요한 위젯에서 `showKeyboard`를 호출해
///   리모컨 또는 소프트 키보드가 노출되도록 요청합니다.
class LunaKeyboardService {
  static const MethodChannel _channel = MethodChannel('com.lg.homescreen/luna');
  static const String _defaultAppId = 'com.lg.homescreen.memo-board';

  /// webOS Luna API를 통해 키보드를 노출합니다.
  Future<void> showKeyboard({
    required String runPatasdh,
    String? initialText,
    int maxLength = 400,
  }) async {
    try {
      await _channel.invokeMethod('callLunaService', {
        'service': 'luna://com.webos.service.ime',
        'method': 'registerRemoteKeyboard',
        'parameters': {
          'appId': runPatasdh.isEmpty ? _defaultAppId : runPatasdh,
          'inputType': 'text',
          'focus': true,
          'currentText': initialText ?? '',
          'maxTextLength': maxLength,
        },
      });
    } catch (error, stackTrace) {
      debugPrint('[LunaKeyboardService] showKeyboard error: $error');
      debugPrint('$stackTrace');
    }
  }

  /// webOS Luna API에 키보드 숨김을 요청합니다.
  Future<void> hideKeyboard({String? runPatasdh}) async {
    try {
      await _channel.invokeMethod('callLunaService', {
        'service': 'luna://com.webos.service.ime',
        'method': 'unregisterRemoteKeyboard',
        'parameters': {
          'appId': (runPatasdh == null || runPatasdh.isEmpty)
              ? _defaultAppId
              : runPatasdh,
        },
      });
    } catch (error, stackTrace) {
      debugPrint('[LunaKeyboardService] hideKeyboard error: $error');
      debugPrint('$stackTrace');
    }
  }
}
