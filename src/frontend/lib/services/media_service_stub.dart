import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:frontend/webos_service_helper/utils.dart' as webos_utils;

import 'media_service_interface.dart';

MediaService getMediaService() {
  debugPrint('[MediaService] WebOSServiceBridge 사용');
  return const _NativeWebOSMediaService();
}

class _NativeWebOSMediaService extends MediaService {
  const _NativeWebOSMediaService();

  @override
  Future<String?> open(String uri, {Map<String, dynamic>? options}) async {
    try {
      final parameters = <String, dynamic>{
        'uri': uri,
        'type': 'media',
        'mediaFormat': 'video',
        'option': {
          'mediaTransportType': uri.startsWith('http') ? 'STREAMING' : 'FILE',
        },
      };
      if (options != null) {
        parameters.addAll(options);
      }

      debugPrint('[Luna API] 호출: luna://com.webos.media/open');
      debugPrint('[Luna API] 파라미터: $parameters');

      final result = await webos_utils.callOneReply(
        uri: 'luna://com.webos.media',
        method: 'open',
        payload: parameters,
      );

      debugPrint('[Luna API] 응답: $result');

      if (result != null && result['returnValue'] == true) {
        final sessionId = result['sessionId'] as String?;
        debugPrint('[Luna API] ✅ 성공 - sessionId: $sessionId');
        return sessionId;
      }

      // 에러 정보 상세 로깅
      final errorCode = result?['errorCode'];
      final errorText = result?['errorText'];
      debugPrint('[Luna API] ❌ 실패 - returnValue: ${result?['returnValue']}');
      debugPrint('[Luna API] ❌ errorCode: $errorCode');
      debugPrint('[Luna API] ❌ errorText: $errorText');
      debugPrint('[Luna API] ❌ 전체 응답: $result');
      return null;
    } catch (e) {
      debugPrint('[Luna API] ❌ 에러: $e');
      return null;
    }
  }

  @override
  Future<void> play(String sessionId) => _invokeSimple('play', sessionId);

  @override
  Future<void> pause(String sessionId) => _invokeSimple('pause', sessionId);

  @override
  Future<void> stop(String sessionId) => _invokeSimple('stop', sessionId);

  @override
  Future<void> close(String sessionId) => _invokeSimple('close', sessionId);

  Future<void> _invokeSimple(String method, String sessionId) async {
    try {
      debugPrint('[Luna API] 호출: luna://com.webos.media/$method');
      debugPrint('[Luna API] sessionId: $sessionId');

      final result = await webos_utils.callOneReply(
        uri: 'luna://com.webos.media',
        method: method,
        payload: {'sessionId': sessionId},
      );

      debugPrint('[Luna API] $method 응답: $result');

      if (result != null && result['returnValue'] == true) {
        debugPrint('[Luna API] ✅ $method 성공');
      } else {
        // 에러 정보 상세 로깅
        final errorCode = result?['errorCode'];
        final errorText = result?['errorText'];
        debugPrint('[Luna API] ❌ $method 실패 - returnValue: ${result?['returnValue']}');
        debugPrint('[Luna API] ❌ $method errorCode: $errorCode');
        debugPrint('[Luna API] ❌ $method errorText: $errorText');
        debugPrint('[Luna API] ❌ $method 전체 응답: $result');
      }
    } catch (e) {
      debugPrint('[Luna API] ❌ $method 에러: $e');
      debugPrint('[Luna API] ❌ $method 에러 스택: ${StackTrace.current}');
    }
  }
}
