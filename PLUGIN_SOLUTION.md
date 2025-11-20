# WebOSServiceBridge 플러그인 문제 해결 방법

## 현재 상황
- `WebOSServiceBridge` 플러그인이 webOS 디바이스에서 응답하지 않음
- `subscribe()` 스트림이 생성되지만 데이터가 방출되지 않음
- 30초 타임아웃 발생

## 즉시 시도할 수 있는 해결 방법

### 방법 1: 플러그인 소스 코드 직접 확인 (가장 빠름)

```bash
# 플러그인 소스 코드 클론
git clone https://github.com/LGE-Univ-Sogang/flutter-webos-sdk.git
cd flutter-webos-sdk/plugins/packages/webos_service_bridge

# 소스 코드 확인
# - lib/ 폴더에서 Dart 코드 확인
# - android/, ios/, linux/ 폴더에서 네이티브 코드 확인
# - README.md에서 사용 방법 확인
```

**확인할 사항:**
1. `WebOSServiceBridge` 생성자가 올바른 파라미터를 받는지
2. `subscribe()` 메서드가 어떻게 구현되어 있는지
3. 네이티브 코드에서 어떤 MethodChannel을 사용하는지
4. 사용 예제 코드가 있는지

### 방법 2: 플러그인 개발자에게 문의

**GitHub Issues에 문제 보고:**
- URL: https://github.com/LGE-Univ-Sogang/flutter-webos-sdk/issues
- 제목: "WebOSServiceBridge plugin not responding on webOS device"
- 내용:
  ```
  플러그인이 webOS 디바이스에서 응답하지 않습니다.
  
  증상:
  - subscribe() 스트림이 생성되지만 데이터가 방출되지 않음
  - 30초 타임아웃 발생
  
  환경:
  - Flutter webOS SDK
  - webOS 디바이스
  
  로그:
  [CustomWebOSServiceBridge] subscribe() 스트림 획득
  [CustomWebOSServiceBridge] subscribe listen 완료, 응답 대기 중...
  [CustomWebOSServiceBridge] callOneReply 타임아웃 (30초)
  
  사용 예제 코드를 요청합니다.
  ```

### 방법 3: 네이티브 코드 직접 구현 (최후의 수단)

webOS 네이티브 코드(C++)에서 Luna Service를 직접 호출하는 MethodChannel 구현:

**필요한 작업:**
1. `src/frontend/webos/runner/` 폴더에 MethodChannel 핸들러 추가
2. Luna Service 호출 코드 작성
3. Flutter에서 호출할 수 있도록 설정

**참고:**
- webOS Luna Service API 문서 확인
- 기존 네이티브 코드 구조 확인

### 방법 4: 임시 해결책 - Mock 모드 사용

개발 중에는 Mock 모드를 사용하여 기능 테스트:

```dart
// 환경 변수 설정
USE_MOCK=true flutter-webos run --debug -d ttest
```

Mock 응답 파일을 생성하여 테스트 가능

## 권장 순서

1. **즉시**: 플러그인 소스 코드 확인 (방법 1)
2. **단기**: 플러그인 개발자에게 문의 (방법 2)
3. **중기**: 플러그인 개발자와 협의하여 해결
4. **장기**: 필요시 네이티브 코드 직접 구현 (방법 3)

## 추가 정보

- 플러그인 GitHub: https://github.com/LGE-Univ-Sogang/flutter-webos-sdk
- 플러그인 경로: `plugins/packages/webos_service_bridge`
- 현재 사용 중인 플러그인 버전: `main` 브랜치

