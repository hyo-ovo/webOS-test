import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'volume_service_interface.dart';

VolumeService getVolumeService() => _WebOSVolumeService();

class _WebOSVolumeService implements VolumeService {
  static const MethodChannel _channel = MethodChannel('com.lg.homescreen/luna');
  static const String _audioServiceUri = 'luna://com.webos.audio';

  @override
  Future<bool> volumeUp() => _invoke(method: 'volumeUp');

  @override
  Future<bool> volumeDown() => _invoke(method: 'volumeDown');

  @override
  Future<bool> setMuted(bool muted) {
    return _invoke(
      method: 'setMuted',
      parameters: {'muted': muted},
    );
  }

  Future<bool> _invoke({
    required String method,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final result = await _channel.invokeMethod<dynamic>('callLunaService', {
        'service': _audioServiceUri,
        'method': method,
        'parameters': parameters ?? const <String, dynamic>{},
      });

      if (result is Map) {
        final map = result.cast<String, dynamic>();
        if (map['returnValue'] == true) {
          return true;
        }
        final code =
            map['errorCode'] ?? map['errorCodeValue'] ?? 'unknown';
        final text = map['errorText'] ?? 'unknown';
        debugPrint('[volume] $method failed: [$code] $text');
        return false;
      }

      debugPrint('[volume] $method unexpected response: $result');
      return false;
    } on MissingPluginException catch (error) {
      debugPrint('[volume] luna channel missing: $error');
      return false;
    } catch (error, stackTrace) {
      debugPrint('[volume] $method error: $error');
      debugPrint('$stackTrace');
      return false;
    }
  }
}
