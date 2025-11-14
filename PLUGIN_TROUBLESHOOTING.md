# WebOSServiceBridge 플러그인 문제 해결 가이드

## 현재 문제
- `WebOSServiceBridge` 플러그인이 webOS 디바이스에서 응답을 받지 못함
- `subscribe()` 스트림이 생성되지만 데이터가 방출되지 않음
- 30초 타임아웃 발생

## 해결 방법

### 1. 플러그인 소스 코드 확인
플러그인 소스 코드를 직접 확인하여 올바른 사용 방법을 파악:
```bash
# 플러그인 소스 코드 위치
https://github.com/LGE-Univ-Sogang/flutter-webos-sdk.git
경로: plugins/packages/webos_service_bridge
```

### 2. 플러그인 사용 방법 재확인
현재 코드에서 `WebOSServiceBridge` 생성자:
```dart
WebOSServiceBridge(uri, payload)
```

가능한 문제:
- 생성자 파라미터 순서나 형식이 잘못되었을 수 있음
- 플러그인이 다른 방식으로 초기화되어야 할 수 있음

### 3. 네이티브 코드 통신 확인
플러그인이 네이티브 코드와 통신하는지 확인:
- MethodChannel이 제대로 설정되었는지
- 네이티브 코드가 응답을 보내는지
- 권한 문제는 없는지

### 4. 대안 방법

#### 방법 A: 플러그인 개발자에게 문의
- GitHub Issues에 문제 보고
- 플러그인 사용 예제 요청

#### 방법 B: 직접 네이티브 코드 호출
Flutter의 MethodChannel을 사용하여 직접 Luna Service 호출:
```dart
static const platform = MethodChannel('com.webos.service');
final result = await platform.invokeMethod('call', {
  'uri': 'luna://com.webos.media',
  'method': 'open',
  'parameters': {...}
});
```

#### 방법 C: JavaScript 인터페이스 사용 (웹 기반)
`media_service_web.dart`의 방식을 webOS 디바이스에서도 사용

### 5. 디버깅 단계
1. 플러그인 초기화 확인
2. 네이티브 코드 로그 확인
3. MethodChannel 통신 확인
4. 권한 확인

## 권장 사항
1. 먼저 플러그인 GitHub 저장소의 Issues를 확인
2. 플러그인 사용 예제 코드 확인
3. 플러그인 개발자에게 문의
4. 필요시 직접 네이티브 코드 호출 방식으로 전환

