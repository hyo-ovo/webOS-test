import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'custom_webos_service_bridge.dart';

/// Mock 모드 사용 여부 결정
/// 
/// webOS 실제 디바이스에서는 항상 실제 Luna API를 사용해야 함
/// 웹/윈도우 환경이나 개발용으로만 Mock 사용
bool get _shouldUseMock {
  // 환경 변수로 강제 제어 가능
  final useMockEnv = Platform.environment['USE_MOCK'];
  if (useMockEnv != null) {
    final result = bool.parse(useMockEnv);
    debugPrint('[WebOSServiceHelper] USE_MOCK 환경 변수: $result');
    return result;
  }
  
  // 웹이나 윈도우에서는 Mock 사용
  if (kIsWeb || Platform.isWindows) {
    debugPrint('[WebOSServiceHelper] 웹/윈도우 환경 - Mock 모드 사용');
    return true;
  }
  
  // webOS 디바이스(Linux 기반)에서는 실제 Luna API 사용
  // Mock을 사용하려면 USE_MOCK=true 환경 변수 설정 필요
  debugPrint('[WebOSServiceHelper] webOS 디바이스 - 실제 Luna API 사용');
  return false;
}

final bool useMock = _shouldUseMock;
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
