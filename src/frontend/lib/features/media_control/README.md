# Media Control Feature

webOS TV의 미디어 재생 및 볼륨 조절 기능을 담당하는 Feature입니다.

## 📁 폴더 구조

```
media_control/
├── presentation/          # UI 레이어
│   ├── video_player_widget.dart
│   └── widgets/
│
├── data/                  # 데이터 레이어
│   ├── models/
│   │   └── media_item.dart
│   └── repositories/
│       └── media_repository.dart
│
├── logic/                 # 비즈니스 로직 레이어
│   ├── controllers/
│   │   └── media_controller.dart
│   └── services/
│       ├── media_service.dart (플랫폼별 조건부 import)
│       ├── media_service_interface.dart
│       ├── media_service_web.dart (웹 브라우저용)
│       ├── media_service_stub.dart (Linux/webOS용)
│       ├── volume_service.dart (플랫폼별 조건부 import)
│       ├── volume_service_interface.dart
│       ├── volume_service_web.dart (웹 브라우저용)
│       └── volume_service_stub.dart (Linux/webOS용)
│
└── media_control.dart     # Feature export 파일
```

## 🎯 주요 컴포넌트

### 1. Presentation Layer

#### VideoPlayerWidget
비디오 플레이어 UI 위젯
```dart
VideoPlayerWidget(
  videoUrl: 'https://example.com/video.mp4',
  onPlay: () => print('Play clicked'),
  caption: '로딩 중...',
)
```

### 2. Data Layer

#### MediaItem (Model)
미디어 아이템을 표현하는 모델
```dart
final mediaItem = MediaItem(
  id: '1',
  title: 'Sample Video',
  url: 'https://example.com/video.mp4',
  type: MediaType.video,
);
```

#### MediaRepository
MediaService와 VolumeService를 래핑한 Repository
```dart
final repository = MediaRepository(
  mediaService: mediaService,
  volumeService: volumeService,
);

// 미디어 재생
final sessionId = await repository.openMedia(mediaItem);
await repository.playMedia(sessionId);

// 볼륨 조절
await repository.volumeUp();
```

### 3. Logic Layer

#### MediaController
미디어 재생 상태를 관리하는 Controller (ChangeNotifier)
```dart
final controller = MediaController(repository: repository);

// 미디어 열기 및 재생
await controller.openAndPlay(mediaItem);

// 재생 상태 확인
print(controller.playbackState); // MediaPlaybackState.playing

// 볼륨 조절
await controller.volumeUp();
await controller.toggleMute();
```

## 🔧 플랫폼별 구현

### 웹 브라우저 (`*_web.dart`)
- `dart:js_util`을 사용하여 `window.webOS` JavaScript 객체와 통신
- Luna Service API를 JavaScript를 통해 호출

### Linux/webOS 디바이스 (`*_stub.dart`)
- `video_player` 패키지 사용 (MediaService)
- Stub 구현 (VolumeService)
- 실제 webOS 디바이스에서는 `webos_service_bridge` 사용 권장

## 📝 사용 예시

### 기본 사용법

```dart
import 'package:frontend/features/media_control/media_control.dart';
import 'package:provider/provider.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MediaController(
        repository: MediaRepository(
          mediaService: mediaService,
          volumeService: volumeService,
        ),
      ),
      child: Consumer<MediaController>(
        builder: (context, controller, child) {
          return Column(
            children: [
              VideoPlayerWidget(
                videoUrl: 'https://example.com/video.mp4',
              ),
              ElevatedButton(
                onPressed: () => controller.openAndPlay(
                  MediaItem(
                    id: '1',
                    title: 'Sample',
                    url: 'https://example.com/video.mp4',
                  ),
                ),
                child: Text('Play'),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

## 🔄 마이그레이션 가이드

### 기존 코드에서 마이그레이션

**Before:**
```dart
import 'package:frontend/services/media_service.dart';
import 'package:frontend/widgets/custom_video_widget.dart';

final service = mediaService;
await service.open('url');

CustomVideoWidget(videoUrl: 'url');
```

**After:**
```dart
import 'package:frontend/features/media_control/media_control.dart';

final controller = MediaController(repository: repository);
await controller.openAndPlay(mediaItem);

VideoPlayerWidget(videoUrl: 'url');
```

## 🎨 담당자
**조효원** - 미디어 재생 / 볼륨 조절
