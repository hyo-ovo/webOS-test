// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:js' as js;
import 'dart:js_util' as js_util;

import 'package:flutter/foundation.dart';

import 'volume_service_interface.dart';

VolumeService getVolumeService() => _WebOSVolumeService();

class _WebOSVolumeService implements VolumeService {
  @override
  Future<bool> volumeUp() {
    return _invoke(method: 'volumeUp');
  }

  @override
  Future<bool> volumeDown() {
    return _invoke(method: 'volumeDown');
  }

  @override
  Future<bool> setMuted(bool muted) {
    final parameters = js_util.newObject();
    js_util.setProperty(parameters, 'muted', muted);
    return _invoke(method: 'setMuted', parameters: parameters);
  }

  Future<bool> _invoke({required String method, Object? parameters}) {
    if (!_hasWebOS) {
      debugPrint('[volume] webOS object is not available for $method');
      return Future.value(false);
    }

    final completer = Completer<bool>();
    final service = js_util.getProperty(_webOS!, 'service');
    final options = js_util.newObject();
    js_util.setProperty(options, 'method', method);
    if (parameters != null) {
      js_util.setProperty(options, 'parameters', parameters);
    }

    js_util.setProperty(
      options,
      'onSuccess',
      js.allowInterop((dynamic _) {
        completer.complete(true);
      }),
    );
    js_util.setProperty(
      options,
      'onFailure',
      js.allowInterop((dynamic error) {
        final code = js_util.hasProperty(error, 'errorCode')
            ? js_util.getProperty(error, 'errorCode')
            : 'unknown';
        final text = js_util.hasProperty(error, 'errorText')
            ? js_util.getProperty(error, 'errorText')
            : 'unknown';
        debugPrint('[volume] $method failed: [$code] $text');
        completer.complete(false);
      }),
    );

    try {
      js_util.callMethod(service, 'request', [
        'luna://com.webos.audio',
        options,
      ]);
    } catch (error) {
      debugPrint('[volume] $method request threw: $error');
      completer.complete(false);
    }

    return completer.future;
  }
}

Object? get _webOS => js_util.hasProperty(js_util.globalThis, 'webOS')
    ? js_util.getProperty(js_util.globalThis, 'webOS')
    : null;

bool get _hasWebOS => _webOS != null;

