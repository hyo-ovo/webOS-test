import 'package:flutter/foundation.dart';
import 'package:frontend/webos_service_helper/utils.dart' as webos_utils;

import 'volume_service_interface.dart';

/// VolumeService - webOS Luna Service 사용
///
/// luna://com.webos.audio API를 통한 볼륨 제어
VolumeService getVolumeService() {
  debugPrint('[VolumeService] webOS Luna Service 사용');
  return const _WebOSVolumeService();
}

class _WebOSVolumeService implements VolumeService {
  const _WebOSVolumeService();

  @override
  Future<bool> volumeUp() async {
    debugPrint('[volume] volumeUp() called');
    return await _invoke(method: 'volumeUp');
  }

  @override
  Future<bool> volumeDown() async {
    debugPrint('[volume] volumeDown() called');
    return await _invoke(method: 'volumeDown');
  }

  @override
  Future<bool> setMuted(bool muted) async {
    debugPrint('[volume] setMuted($muted) called');
    return await _invoke(
      method: 'setMuted',
      parameters: {'muted': muted},
    );
  }

  Future<bool> _invoke({
    required String method,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final result = await webos_utils.callOneReply(
        uri: 'luna://com.webos.audio',
        method: method,
        payload: parameters ?? {},
      );

      if (result == null) {
        debugPrint('[volume] $method: No response');
        return false;
      }

      final returnValue = result['returnValue'] as bool? ?? false;
      if (returnValue) {
        debugPrint('[volume] $method: SUCCESS');
      } else {
        final errorCode = result['errorCode'] ?? 'unknown';
        final errorText = result['errorText'] ?? 'unknown';
        debugPrint('[volume] $method: ERROR [$errorCode] $errorText');
      }

      return returnValue;
    } catch (e) {
      debugPrint('[volume] $method: Exception: $e');
      return false;
    }
  }
}
