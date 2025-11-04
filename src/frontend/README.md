# 📁 Frontend Folder Structure

이 문서는 `webOS 첫 화면 재구성 프로젝트`의 **Flutter 프론트엔드 폴더 구조**를 설명합니다.
세부적인 파일명 및 구성은 개발 진행 상황에 따라 변경될 수 있습니다.

---

## 🏗️ Project Structure

```
frontend/
 ├─ lib/
 │   ├─ main.dart
 │   ├─ app.dart
 │   │
 │   ├─ features/
 │   │   ├─ app_manager/                 # [김경우] webOS 앱 실행 및 리스트 관리
 │   │   │   ├─ presentation/
 │   │   │   │   ├─ app_list_screen.dart
 │   │   │   │   ├─ app_tile.dart
 │   │   │   │   └─ app_launcher_button.dart
 │   │   │   ├─ data/
 │   │   │   │   ├─ app_model.dart
 │   │   │   │   └─ app_repository.dart
 │   │   │   └─ logic/
 │   │   │       ├─ app_manager_controller.dart
 │   │   │       └─ app_service.dart
 │   │   │
 │   │   ├─ media_control/               # [조효원] 미디어 재생 / 볼륨 조절
 │   │   │   ├─ presentation/
 │   │   │   │   ├─ media_screen.dart
 │   │   │   │   ├─ video_player_widget.dart
 │   │   │   │   └─ volume_slider.dart
 │   │   │   ├─ data/
 │   │   │   │   ├─ media_item.dart
 │   │   │   │   └─ media_repository.dart
 │   │   │   └─ logic/
 │   │   │       ├─ media_controller.dart
 │   │   │       └─ volume_service.dart
 │   │   │
 │   │   ├─ user_login/                  # [정인영] 사용자 로그인
 │   │   │   ├─ presentation/
 │   │   │   │   ├─ login_screen.dart
 │   │   │   │   └─ face_login_widget.dart
 │   │   │   ├─ data/
 │   │   │   │   ├─ user_model.dart
 │   │   │   │   └─ auth_repository.dart
 │   │   │   └─ logic/
 │   │   │       ├─ auth_controller.dart
 │   │   │       └─ login_service.dart
 │   │   │
 │   │   ├─ weather_clock_display/       # [주현수] 시계 / 날씨 표시
 │   │   │   ├─ presentation/
 │   │   │   │   ├─ clock_widget.dart
 │   │   │   │   ├─ weather_widget.dart
 │   │   │   │   └─ info_section.dart
 │   │   │   ├─ data/
 │   │   │   │   ├─ weather_model.dart
 │   │   │   │   └─ weather_repository.dart
 │   │   │   └─ logic/
 │   │   │       ├─ weather_controller.dart
 │   │   │       └─ weather_service.dart
 │   │   │
 │   │   ├─ extras/                      # 선택 기능 (메모장, 빈버드, 앱 즐겨찾기)
 │   │   │   ├─ memo/
 │   │   │   ├─ favorites/
 │   │   │   └─ binbird/
 │   │   │
 │   │   └─ shared/                      # 공용 자원 (모든 feature가 공유)
 │   │       ├─ widgets/
 │   │       │   ├─ focus_highlight.dart
 │   │       │   ├─ app_button.dart
 │   │       │   ├─ app_card.dart
 │   │       │   └─ loading_indicator.dart
 │   │       ├─ controllers/
 │   │       │   ├─ key_event_handler.dart
 │   │       │   └─ focus_controller.dart
 │   │       ├─ utils/
 │   │       │   ├─ app_colors.dart
 │   │       │   ├─ app_strings.dart
 │   │       │   └─ layout_helper.dart
 │   │       └─ theme/
 │   │           ├─ app_theme.dart
 │   │           └─ typography.dart
 │   │
 │   └─ routes/
 │       └─ app_router.dart
 │
 ├─ assets/
 │   ├─ images/
 │   ├─ icons/
 │   └─ fonts/
 │
 ├─ webos/
 │   ├─ appinfo.json
 │   ├─ icon.png
 │   └─ dist/
 │
 ├─ pubspec.yaml
 ├─ build.sh
 └─ test/
```

---

## 📘 Folder Description

| 폴더                | 설명                                                    |
| ----------------- | ----------------------------------------------------- |
| **lib/main.dart** | Flutter 앱의 진입점. `runApp()`으로 `app.dart` 실행.           |
| **lib/app.dart**  | 전역 `MaterialApp` 설정, 라우팅 및 테마 등록.                     |
| **features/**     | 기능 단위 구조. 각 기능은 `presentation / data / logic` 으로 분리됨. |
| **shared/**       | 공용 UI, 포커스 제어, 유틸리티, 테마 등 모든 기능이 공유하는 모듈.             |
| **routes/**       | 라우트 관리 파일. 각 기능의 `Screen` 간 네비게이션 정의.                 |
| **assets/**       | 정적 리소스 (이미지, 아이콘, 폰트 등).                              |
| **webos/**        | webOS 실행 관련 파일 (`appinfo.json`, 앱 아이콘, 빌드 결과물 등).     |
| **test/**         | 위젯 및 서비스 테스트 코드.                                      |

---

## 👥 Feature Ownership

| 기능                  | 담당자 | 주요 책임                                                                   |
| ------------------- | --- | ----------------------------------------------------------------------- |
| **App Manager**     | 김경우 | webOS 앱 리스트 및 실행 로직 (`app_manager_controller.dart`, `app_service.dart`) |
| **Media Control**   | 조효원 | 영상 재생 / 볼륨 제어 (`media_controller.dart`, `video_player_widget.dart`)     |
| **User Login**      | 정인영 | 로그인 및 얼굴인식 (`auth_controller.dart`, `login_service.dart`)               |
| **Weather & Clock** | 주현수 | 시계 / 날씨 위젯 (`weather_controller.dart`, `weather_service.dart`)          |
| **Extras**          | 공동  | 메모장, 즐겨찾기, 빈버드 인터랙션 등 선택 기능                                             |

---

## ⚙️ Branch & Collaboration Rules

* 브랜치 전략:

  ```
  main         → 최종 배포용 (.ipk)
  dev          → 통합 테스트
  feature/*    → 개별 기능 개발 (예: feature/media-control)
  ```
* 커밋 컨벤션: [Udacity Git Style Guide](https://udacity.github.io/git-styleguide/) 준수
* 모든 Pull Request에는 **`lessons learned`** 항목 작성
* Figma 및 디자인 파일은 `/features` 단위 컴포넌트명과 동일하게 네이밍
* 주요 산출물 및 코드 관리는
  [LGE-Univ-Sogang/2025_sogang_6](https://github.com/LGE-Univ-Sogang/2025_sogang_6) 레포지토리에서 진행

---

## 🧠 개발 시 유의사항

* **webOS 특화 이벤트**
  `shared/controllers/key_event_handler.dart`를 통해 리모컨 입력(Focus 이동) 처리
* **UI 일관성 유지**
  색상, 여백, 폰트는 `shared/theme/`에서 정의된 스타일 사용
* **데이터 연동**
  백엔드 Express API와 통신 시 `services` / `repository` 계층에서만 호출
* **테스트**
  각 feature 별 `logic` 계층 함수에 대한 단위 테스트 작성 (`test/` 폴더)

---

## 📦 빌드 & 배포

```bash
# webOS 패키징 (.ipk 빌드)
flutter-webos clean
flutter-webos build webos --ipk --release
mv build/webos/*.ipk webos/dist/

# 디바이스 설치
ares-install webos/dist/<파일명>.ipk
ares-launch com.teamname.projectid
```

---

> ✅ 이 구조는 **기능 중심 팀 협업**과 **webOS 환경 대응**을 모두 고려한 기본 템플릿입니다.
> 프로젝트 진행 중 변경이 필요할 경우, 각 담당자는 관련 feature 하위 폴더를 직접 관리합니다.
