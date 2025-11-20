# System Volume Control Widget

Luna API를 사용하여 시스템 볼륨을 조절하는 위젯입니다.

## 구조

```
system_volume/
├── logic/
│   └── controllers/
│       └── volume_controller.dart    # 볼륨 상태 관리 및 제어
└── presentation/
    └── widgets/
        └── volume_control_widget.dart # 볼륨 조절 UI 위젯
```

## 사용 방법

### 기본 사용

```dart
import 'package:frontend/features/system_volume/presentation/widgets/volume_control_widget.dart';

// 기본 사용
VolumeControlWidget()

// 커스터마이징
VolumeControlWidget(
  height: 100,
  backgroundColor: Colors.black.withOpacity(0.8),
  textColor: Colors.white,
  iconColor: Colors.blue,
)
```

### HomeScreen에 추가 예시

```dart
import 'package:frontend/features/system_volume/presentation/widgets/volume_control_widget.dart';

// HomeScreen의 _TopHeader에 추가
Row(
  children: [
    // ... 기존 위젯들
    const SizedBox(width: 32),
    const VolumeControlWidget(),
  ],
)
```

## 기능

- **볼륨 증가**: `volumeUp()` - 볼륨을 1만큼 증가
- **볼륨 감소**: `volumeDown()` - 볼륨을 1만큼 감소
- **음소거 토글**: `toggleMute()` - 음소거 켜기/끄기
- **음소거 설정**: `setMuted(bool)` - 음소거 상태 직접 설정

## API

### VolumeController

- `volumeUp()`: 볼륨 증가
- `volumeDown()`: 볼륨 감소
- `toggleMute()`: 음소거 토글
- `setMuted(bool muted)`: 음소거 설정
- `isMuted`: 현재 음소거 상태
- `isLoading`: 로딩 상태
- `errorMessage`: 에러 메시지

### VolumeControlWidget

- `height`: 위젯 높이 (기본값: 80)
- `backgroundColor`: 배경색
- `textColor`: 텍스트 색상
- `iconColor`: 아이콘 색상

## Luna API

이 위젯은 `luna://com.webos.audio` 서비스를 사용합니다:

- `volumeUp`: 볼륨 증가
- `volumeDown`: 볼륨 감소
- `setMuted`: 음소거 설정

자세한 내용은 `document/luna-api-instructions/volume.mdc`를 참고하세요.

