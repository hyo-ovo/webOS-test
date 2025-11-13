import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'media_service_interface.dart';

MediaService getMediaService() => const _WebOSMediaService();

class _WebOSMediaService extends MediaService {
  const _WebOSMediaService();

  static const MethodChannel _channel = MethodChannel('com.lg.homescreen/luna');
  static const String _mediaServiceUri = 'luna://com.webos.media';

  Future<Map<String, dynamic>?> _callLuna(
    String method, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final result = await _channel.invokeMethod<dynamic>('callLunaService', {
        'service': _mediaServiceUri,
        'method': method,
        'parameters': parameters ?? const <String, dynamic>{},
      });

      if (result is Map) {
        return result.cast<String, dynamic>();
      }

      debugPrint('[media] $_mediaServiceUri/$method unexpected response: $result');
      return null;
    } on MissingPluginException catch (error) {
      debugPrint('[media] luna channel missing: $error');
      return null;
    } catch (error, stackTrace) {
      debugPrint('[media] $_mediaServiceUri/$method error: $error');
      debugPrint('$stackTrace');
      return null;
    }
  }

  @override
  Future<String?> open(String uri, {Map<String, dynamic>? options}) async {
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

    final response = await _callLuna('open', parameters: parameters);

    if (response == null) {
      return null;
    }

    final success = response['returnValue'] == true;
    final sessionId = response['sessionId'];

    if (success && sessionId is String && sessionId.isNotEmpty) {
      debugPrint('[media] open success: sessionId=$sessionId');
      return sessionId;
    }

    final errorCode =
        response['errorCode'] ?? response['errorCodeValue'] ?? 'unknown';
    final errorText = response['errorText'] ?? 'unknown';
    debugPrint('[media] open failed: [$errorCode] $errorText');
    return null;
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
    final response = await _callLuna(
      method,
      parameters: {'sessionId': sessionId},
    );

    if (response == null) {
      debugPrint('[media] $method no response');
      return;
    }

    if (response['returnValue'] == true) {
      debugPrint('[media] $method success for sessionId=$sessionId');
      return;
    }

    final errorCode =
        response['errorCode'] ?? response['errorCodeValue'] ?? 'unknown';
    final errorText = response['errorText'] ?? 'unknown';
    debugPrint('[media] $method failed: [$errorCode] $errorText');
  }
}
