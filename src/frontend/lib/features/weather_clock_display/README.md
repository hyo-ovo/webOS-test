# 🕐☀️ Weather & Clock Display Feature

webOS 홈 화면용 시계 및 날씨 위젯

담당자: **주현수** ([주현수] 시계 / 날씨 표시)

---

## 📁 폴더 구조

```
weather_clock_display/
├─ data/                           # 데이터 계층
│  ├─ weather_model.dart            # 날씨 데이터 모델
│  ├─ weather_repository.dart       # 날씨 API 저장소 (개발용 HTTP)
│  ├─ weather_repository_webos.dart # 날씨 API 저장소 (webOS용 Luna+HTTP)
│  └─ repository_factory.dart       # 환경 자동 감지 및 Repository 선택
├─ logic/                          # 비즈니스 로직 계층
│  ├─ weather_service.dart          # 날씨 서비스 (캐싱, 비즈니스 로직)
│  ├─ weather_controller.dart       # WeatherController + ClockController
│  └─ clock_controller_webos.dart   # webOS Luna Service 시계 (배포용)
└─ presentation/                   # UI 계층 (디자인 명세 기반)
   ├─ clock_widget.dart             # 시계 위젯 (Inter 72px, AM/PM)
   ├─ weather_widget.dart           # 날씨 위젯 (그라디언트 아이콘, °C)
   └─ info_section.dart             # 통합 위젯 (시간|구분선|날씨)
```

### 파일 역할 정리

**현재 사용 중** ✅:
- 모든 `presentation/` 파일
- 모든 `data/` 파일
- `logic/weather_controller.dart` (ClockController + WeatherController 포함)
- `logic/weather_service.dart`

**webOS 배포 시 사용** ⚠️:
- `logic/clock_controller_webos.dart` (Luna Service 기반 시계)
- `data/weather_repository_webos.dart` (Connection Manager 체크)

---

## 📄 파일별 역할

### **Data Layer (데이터 계층)**

#### 1. `weather_model.dart`
**역할**: 날씨 데이터 모델
- API JSON → Dart 객체 변환
- 영어 날씨 상태 → 한글 번역
- 날씨 아이콘 URL 생성

#### 2. `weather_repository.dart`
**역할**: 일반 환경용 날씨 API 저장소
- OpenWeatherMap API 호출 (HTTP)
- Chrome, macOS 등 개발 환경에서 사용

#### 3. `weather_repository_webos.dart`
**역할**: webOS 환경용 날씨 API 저장소
- **Connection Manager로 인터넷 연결 확인**
- 연결 확인 후 OpenWeatherMap API 호출
- webOS Luna Service 사용

**Luna Service 호출**:
```dart
luna://com.webos.service.connectionmanager/getStatus
```

#### 4. `repository_factory.dart`
**역할**: 환경별 Repository 자동 선택
- 개발 환경: `WeatherRepository` (HTTP)
- webOS 환경: `WeatherRepositoryWebOS` (Luna + HTTP)
- 릴리즈 모드 자동 감지

---

### **Logic Layer (비즈니스 로직 계층)**

#### 1. `weather_service.dart`
**역할**: 날씨 비즈니스 로직
- 10분 캐싱으로 불필요한 API 호출 방지
- 에러 시 캐시된 데이터 반환
- Repository Factory 사용

#### 2. `weather_controller.dart`
**역할**: 날씨 & 시계 상태 관리 (일반 환경)
- **WeatherController**: 날씨 데이터 관리, 10분 자동 새로고침
- **ClockController**: Dart Timer로 1초마다 시간 업데이트

#### 3. `clock_controller_webos.dart`
**역할**: webOS Luna Service 기반 시계 컨트롤러
- System Service로 시스템 시간 가져오기
- 시간대 변경 시 자동 업데이트
- 구독(subscribe) 방식으로 이벤트 수신

**Luna Service 호출**:
```dart
luna://com.webos.service.systemservice/time/getSystemTime
```

**응답 예시**:
```json
{
  "returnValue": true,
  "utc": 1418745990,
  "localtime": {
    "year": 2025,
    "month": 11,
    "day": 13,
    "hour": 14,
    "minute": 30,
    "second": 45
  },
  "offset": -300,
  "timezone": "Asia/Seoul"
}
```

---

### **Presentation Layer (UI 계층)**

#### 1. `clock_widget.dart`
**역할**: 시계 표시 위젯
- **ClockWidget**: 시간 + 날짜 표시
- **SimpleClockWidget**: 시간만 표시

#### 2. `weather_widget.dart`
**역할**: 날씨 표시 위젯
- **WeatherWidget**: 온도, 날씨 상태, 습도, 풍속
- **SimpleWeatherWidget**: 온도 + 아이콘만

#### 3. `info_section.dart`
**역할**: 시계 + 날씨 통합 섹션
- **InfoSection**: 가로/세로 레이아웃
- **CompactInfoSection**: 작은 크기 버전
- **ClockCard / WeatherCard**: 독립 카드

---

## 🚀 사용 방법

### 기본 사용 (개발 환경)

```dart
import 'features/weather_clock_display/presentation/info_section.dart';

// 통합 섹션
InfoSection(
  cityName: 'Seoul',
  layout: InfoSectionLayout.horizontal,
)

// 컴팩트 버전
CompactInfoSection(cityName: 'Seoul')

// 개별 위젯
ClockCard()
WeatherCard(cityName: 'Seoul')
```

### webOS 배포

webOS 환경에서는 **자동으로** Luna Service 기반 구현 사용:

1. **시계**: `luna://com.webos.service.systemservice` 사용
2. **날씨**: Connection Manager로 연결 확인 후 HTTP 사용

**추가 설정 불필요** - `RepositoryFactory`가 자동 감지

---

## ⚙️ 환경별 동작 방식

### 개발 환경 (Chrome, macOS)

```
ClockWidget
  └─ ClockController (Dart Timer)
       └─ 1초마다 DateTime.now() 호출

WeatherWidget
  └─ WeatherController
       └─ WeatherService
            └─ WeatherRepository (HTTP)
                 └─ OpenWeatherMap API
```

### webOS 환경 (LG StandByME)

```
ClockWidget
  └─ ClockControllerWebOS
       └─ Luna Service (System Service)
            └─ luna://com.webos.service.systemservice/time/getSystemTime

WeatherWidget
  └─ WeatherController
       └─ WeatherService
            └─ WeatherRepositoryWebOS
                 ├─ Luna Service (Connection Manager) - 연결 확인
                 └─ HTTP (OpenWeatherMap API) - 날씨 데이터
```

---

## 🔧 설정

### 1. OpenWeatherMap API 키 설정

**개발 환경**:
- 파일: `weather_repository.dart:13`
- 변수: `_apiKey = 'YOUR_API_KEY_HERE'`

**webOS 환경**:
- 파일: `weather_repository_webos.dart:13`
- 변수: `_apiKey = 'YOUR_API_KEY_HERE'`

### 2. 환경 강제 설정 (테스트용)

```dart
import 'features/weather_clock_display/data/repository_factory.dart';

void main() {
  // webOS 모드 강제 활성화 (테스트용)
  EnvironmentConfig.setWebOSMode(true);

  // 환경 정보 출력
  EnvironmentConfig.printEnvironmentInfo();

  runApp(MyApp());
}
```

---

## 📊 아키텍처 설계 (Feature-Sliced Design)

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (ClockWidget, WeatherWidget, etc.)     │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│          Logic Layer                    │
│  (Controllers, Services)                │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│          Data Layer                     │
│  (Models, Repositories)                 │
└─────────────────┬───────────────────────┘
                  │
    ┌─────────────┴─────────────┐
    │                           │
┌───▼────┐              ┌───────▼──────┐
│  HTTP  │              │ Luna Service │
│  API   │              │   (webOS)    │
└────────┘              └──────────────┘
```

---

## 🔌 webOS Luna Service 연동

### Method Channel 설정 (Native 측)

webOS 배포 시 Flutter에서 Luna Service를 호출하려면 **MethodChannel** 설정 필요:

```dart
// Dart 측 (이미 구현됨)
static const platform = MethodChannel('com.lg.homescreen/luna');

final result = await platform.invokeMethod('callLunaService', {
  'service': 'luna://com.webos.service.systemservice',
  'method': 'time/getSystemTime',
  'parameters': {'subscribe': true},
});
```

**Native 측 구현 필요** (C++, webOS Runner):
- `com.lg.homescreen/luna` 채널 등록
- Luna Service 호출 로직 구현
- 응답을 Dart로 전달

---

## 🧪 테스트

### 개발 환경 테스트
```bash
cd src/frontend
flutter run -d chrome
```

### webOS 빌드
```bash
flutter-webos clean
flutter-webos build webos --ipk --release
```

### webOS 설치
```bash
ares-install build/webos/*.ipk
ares-launch com.lg.homescreen
```

---

## 📝 TODO

- [ ] OpenWeatherMap API 키 발급 및 설정
- [ ] webOS Native 측 MethodChannel 구현
- [ ] Luna Service 호출 테스트 (실제 webOS 기기)
- [ ] 에러 처리 개선 (네트워크 끊김 시나리오)
- [ ] 다국어 지원 (영어, 한국어)

---

## 🐛 알려진 제한사항

1. **날씨 API**: webOS에서도 외부 HTTP API 사용 (Luna Service에 날씨 API 없음)
2. **네트워크 필수**: 날씨 위젯은 인터넷 연결 필요
3. **시간대**: webOS System Service의 시간대 정보에 의존

---

## 📚 참고 문서

- [OpenWeatherMap API](https://openweathermap.org/api)
- [webOS Luna Service API](https://webostv.developer.lge.com/develop/references/luna-service-introduction)
- [System Service (시간)](document/luna-api-instructions/system-service.mdc)
- [Connection Manager](https://webostv.developer.lge.com/develop/references/connectionmanager-service)

---

**작성일**: 2025-11-13
**버전**: 1.0.0
**담당자**: 주현수
