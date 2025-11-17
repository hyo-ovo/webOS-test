import 'package:flutter/foundation.dart';
import 'package:frontend/webos_service_helper/utils.dart' as webos_utils;

import 'media_service_interface.dart';

/// MediaService - webOS Luna Service 사용
///
/// luna://com.webos.media API를 통한 미디어 재생 제어
MediaService getMediaService() {
  debugPrint('[MediaService] webOS Luna Service 사용');
  return const _WebOSMediaService();
}

class _WebOSMediaService implements MediaService {
  const _WebOSMediaService();

  @override
  Future<String?> open(String uri, {Map<String, dynamic>? options}) async {
    final timestamp = DateTime.now().toString();
    debugPrint('[media] [$timestamp] open() called');
    debugPrint('[media] [$timestamp] uri: $uri');

    try {
      final parameters = <String, dynamic>{
        'uri': uri,
        'type': 'media',
        'mediaFormat': 'video',
        'option': {
          'mediaTransportType': uri.startsWith('http') ? 'STREAMING' : 'FILE',
        },
        ...?options,
      };

      debugPrint('[media] [$timestamp] Calling luna://com.webos.media/open');
      debugPrint('[media] [$timestamp] Parameters: $parameters');

      final result = await webos_utils.callOneReply(
        uri: 'luna://com.webos.media',
        method: 'open',
        payload: parameters,
      );

      if (result == null) {
        debugPrint('[media] [$timestamp] ERROR: No response from Luna Service');
        return null;
      }

      final returnValue = result['returnValue'] as bool? ?? false;
      if (!returnValue) {
        final errorCode = result['errorCode'] ?? 'unknown';
        final errorText = result['errorText'] ?? 'unknown';
        debugPrint('[media] [$timestamp] ERROR: [$errorCode] $errorText');
        return null;
      }

      final sessionId = result['sessionId'] as String?;
      debugPrint('[media] [$timestamp] SUCCESS: sessionId = $sessionId');
      return sessionId;
    } catch (e) {
      debugPrint('[media] [$timestamp] Exception: $e');
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
    final timestamp = DateTime.now().toString();
    debugPrint('[media] [$timestamp] $method() called with sessionId: $sessionId');

    try {
      final result = await webos_utils.callOneReply(
        uri: 'luna://com.webos.media',
        method: method,
        payload: {'sessionId': sessionId},
      );

      if (result == null) {
        debugPrint('[media] [$timestamp] $method: No response');
        return;
      }

      final returnValue = result['returnValue'] as bool? ?? false;
      if (returnValue) {
        debugPrint('[media] [$timestamp] $method: SUCCESS');
      } else {
        final errorCode = result['errorCode'] ?? 'unknown';
        final errorText = result['errorText'] ?? 'unknown';
        debugPrint('[media] [$timestamp] $method: ERROR [$errorCode] $errorText');
      }
    } catch (e) {
      debugPrint('[media] [$timestamp] $method: Exception: $e');
    }
  }
}
