# WebOSServiceBridge 플러그인 문제 해결 가이드

## 현재 문제 상황

### 확인된 문제
1. **`WebOSServiceBridge` 플러그인이 webOS 디바이스에서 응답하지 않음**
   - `subscribe()` 스트림이 생성되지만 데이터가 방출되지 않음
   - 30초 타임아웃 발생
   - 로그: `[CustomWebOSServiceBridge] subscribe() 스트림 획득` 이후 응답 없음

2. **직접 MethodChannel도 작동하지 않음**
   - `MissingPluginException: No implementation found for method call on channel com.webos.service`
   - 네이티브 코드에서 해당 MethodChannel이 구현되지 않음

### 테스트 결과
- ✅ 플러그인 인스턴스 생성: 성공
- ✅ `subscribe()` 스트림 생성: 성공
- ❌ 스트림에서 데이터 수신: 실패 (30초 타임아웃)
- ❌ 직접 MethodChannel: 실패 (MissingPluginException)

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

## 즉시 조치 사항

### 1. 플러그인 개발자에게 문의 (최우선)
- GitHub Issues: https://github.com/LGE-Univ-Sogang/flutter-webos-sdk/issues
- 문제 설명:
  - `WebOSServiceBridge` 플러그인이 webOS 디바이스에서 응답하지 않음
  - `subscribe()` 스트림이 생성되지만 데이터가 방출되지 않음
  - 30초 타임아웃 발생
  - 사용 예제 코드 요청

### 2. 플러그인 소스 코드 확인
```bash
git clone https://github.com/LGE-Univ-Sogang/flutter-webos-sdk.git
cd flutter-webos-sdk/plugins/packages/webos_service_bridge
# 소스 코드 확인하여 올바른 사용 방법 파악
```

### 3. 네이티브 코드 구현 (최후의 수단)
webOS 네이티브 코드에서 Luna Service를 직접 호출하는 MethodChannel 구현 필요

## 권장 사항
1. **즉시**: 플러그인 GitHub 저장소의 Issues 확인 및 문제 보고
2. **단기**: 플러그인 사용 예제 코드 확인
3. **중기**: 플러그인 개발자와 협의하여 해결
4. **장기**: 필요시 네이티브 코드 직접 구현

## 현재 상태
- 플러그인 문제로 인해 동영상 재생 기능이 작동하지 않음
- 모든 디버깅 로그가 추가되어 있으므로 문제 원인 파악 가능
- 플러그인 개발자의 지원이 필요함

