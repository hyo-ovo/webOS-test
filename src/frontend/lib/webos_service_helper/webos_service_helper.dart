import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'custom_webos_service_bridge.dart';

/// webOS 환경인지 확인
bool _isWebOS() {
  if (kIsWeb) return false;
  if (Platform.isWindows || Platform.isMacOS) return false;
  if (Platform.isLinux) {
    // webOS는 /etc/palm-release 파일이 있음
    final palmRelease = File('/etc/palm-release');
    if (palmRelease.existsSync()) {
      return true;
    }
    // 또는 환경 변수로 확인
    final webosEnv = Platform.environment['WEBOS_NAME'];
    if (webosEnv != null && webosEnv.isNotEmpty) {
      return true;
    }
  }
  return false;
}

final bool useMock = kIsWeb ||
    Platform.isWindows ||
    Platform.isMacOS ||
    !_isWebOS() ||
    bool.parse(Platform.environment['USE_MOCK'] ?? 'false');
final int defaultHashCode = useMock ? 99 : 0;

class BridgeService {
  BridgeService({
    required this.bridge,
    this.onComplete,
    this.onError,
    this.onDone,
    this.cancelOnError,
  });
  final WebOSServiceBridgeBase bridge;
  final void Function(Map<String, dynamic>)? onComplete;
  final Function? onError;
  final void Function()? onDone;
  final bool? cancelOnError;
  late StreamSubscription _scription;

  BridgeService subscribe() {
    _scription = bridge.subscribe().listen(
          onComplete,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );
    return this;
  }

  void cancel() {
    _scription.cancel();
    bridge.cancel();
  }
}

class ServiceManager {
  factory ServiceManager() {
    return instance;
  }
  ServiceManager._();

  static final ServiceManager instance = ServiceManager._();

  final Map<int, BridgeService> _bridgeServices = <int, BridgeService>{};

  void add(int hashCode, BridgeService service) {
    _bridgeServices[hashCode] = service;
  }

  void remove(int hashCode) {
    _bridgeServices[hashCode]?.cancel();
    _bridgeServices.remove(hashCode);
  }

  void removeAll() {
    for (final BridgeService service in _bridgeServices.values) {
      service.cancel();
    }
    _bridgeServices.clear();
  }

  BridgeService? get(int hashCode) {
    return _bridgeServices[hashCode];
  }
}
