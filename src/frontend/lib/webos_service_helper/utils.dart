import 'package:flutter/foundation.dart';
import 'package:webos_service_bridge/webos_service_bridge.dart';
import 'custom_webos_service_bridge.dart';
import 'webos_service_helper.dart';

int subscribe({
  required String uri,
  required String method,
  Map<String, dynamic>? payload,
  required void Function(Map<String, dynamic>) onComplete,
  void Function(Object)? onError,
  void Function()? onDone,
  bool cancelOnError = false,
}) {
  // WebOSServiceBridge 플러그인은 URI만 받고, method는 payload에 포함해야 할 수 있음
  final fullPayload = <String, dynamic>{
    'method': method,
    if (payload != null) ...payload,
  };
  
  final WebOSServiceData serviceData = WebOSServiceData(uri,
      payload: fullPayload, optHashCode: defaultHashCode);
  final int hashCode = generateHashCode(serviceData);
  BridgeService? service = ServiceManager.instance.get(hashCode);
  if (service == null) {
    service = BridgeService(
      bridge: useMock
          ? MockWebOSServiceBridge(serviceData)
          : CustomWebOSServiceBridge(serviceData),
      onComplete: onComplete,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    ServiceManager.instance.add(hashCode, service);
    service.subscribe();
  }
  return hashCode;
}

void cancel(int hashCode) {
  ServiceManager.instance.remove(hashCode);
}

void cancelAll() {
  ServiceManager.instance.removeAll();
}

Future<Map<String, dynamic>?> callOneReply({
  required String uri,
  required String method,
  Map<String, dynamic>? payload = const <String, dynamic>{},
}) async {
  // WebOSServiceBridge 플러그인은 URI만 받고, method는 payload에 포함해야 할 수 있음
  // URI와 method를 분리하여 전달
  final fullPayload = <String, dynamic>{
    'method': method,
    if (payload != null) ...payload,
  };
  
  debugPrint('[WebOSServiceHelper] callOneReply 호출');
  debugPrint('[WebOSServiceHelper] URI: $uri');
  debugPrint('[WebOSServiceHelper] Method: $method');
  debugPrint('[WebOSServiceHelper] Full Payload: $fullPayload');
  debugPrint('[WebOSServiceHelper] useMock: $useMock');
  
  final WebOSServiceData serviceData = WebOSServiceData(uri,
      payload: fullPayload, optHashCode: defaultHashCode);
  
  try {
    final result = useMock
        ? await MockWebOSServiceBridge.callOneReply(serviceData)
        : await CustomWebOSServiceBridge.callOneReply(serviceData);
    
    debugPrint('[WebOSServiceHelper] callOneReply 응답: $result');
    return result;
  } catch (e, stackTrace) {
    debugPrint('[WebOSServiceHelper] callOneReply 에러: $e');
    debugPrint('[WebOSServiceHelper] 스택 트레이스: $stackTrace');
    rethrow;
  }
}
