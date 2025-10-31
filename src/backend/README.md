# 🚀 Express TypeScript Boilerplate 2025

[![CI](https://github.com/edwinhern/express-typescript/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/edwinhern/express-typescript-2024/actions/workflows/ci.yml)

```code
Hey There! 🙌
🤾 that ⭐️ button if you like this boilerplate.
```

## 🌟 Introduction

Welcome to Express TypeScript Boilerplate 2025 – a simple and ready-to-use starting point for building backend web services with Express.js and TypeScript.

## 💡 Why We Made This

This starter kit helps you:

- ✨ Start new projects faster
- 📊 Write clean, consistent code
- ⚡ Build things quickly
- 🛡️ Follow best practices for security and testing

## 🚀 What's Included

- 📁 Well-organized folders: Files grouped by feature so you can find things easily
- 💨 Fast development: Quick code running with `tsx` and error checking with `tsc`
- 🌐 Latest Node.js: Uses the newest stable Node.js version from `.tool-versions`
- 🔧 Safe settings: Environment settings checked with Zod to prevent errors
- 🔗 Short import paths: Clean code with easy imports using path shortcuts
- 🔄 Auto-updates: Keeps dependencies up-to-date with Renovate
- 🔒 Better security: Built-in protection with Helmet and CORS settings
- 📊 Easy tracking: Built-in logging with `pino-http`
- 🧪 Ready-to-test: Testing tools with Vitest and Supertest already set up
- ✅ Clean code: Consistent coding style with `Biomejs`
- 📃 Standard responses: Unified API responses using `ServiceResponse`
- 🐳 Easy deployment: Ready for Docker containers
- 📝 Input checking: Request validation using Zod
- 🧩 API browser: Interactive API docs with Swagger UI

## 🛠️ Getting Started

### Video Demo

For a visual guide, watch the [video demo](https://github.com/user-attachments/assets/b1698dac-d582-45a0-8d61-31131732b74e) to see the setup and running of the project.

### Step-by-Step Guide

#### Step 1: 🚀 Initial Setup

- Clone the repository: `git clone https://github.com/edwinhern/express-typescript.git`
- Navigate: `cd express-typescript`
- Install dependencies: `pnpm install`

#### Step 2: ⚙️ Environment Configuration

- Create `.env`: Copy `.env.template` to `.env`
- Update `.env`: Fill in necessary environment variables

#### Step 3: 🏃‍♂️ Running the Project

- Development Mode: `pnpm start:dev`
- Building: `pnpm build`
- Production Mode: Set `NODE_ENV="production"` in `.env` then `pnpm build && pnpm start:prod`
- Linting: `pnpm check` (add `--write` to auto-fix issues)

## 🤝 Feedback and Contributions

We'd love to hear your feedback and suggestions for further improvements. Feel free to contribute and join us in making backend development cleaner and faster!

🎉 Happy coding!

## 📁 Folder Structure

```code
├── biome.json                          # Biome 코드 포매터/린터 설정
├── docker-compose.yml                  # PostgreSQL 로컬 개발 환경 설정
├── Dockerfile                          # 컨테이너 배포용 도커 이미지
├── download-models.sh                  # (미사용) 얼굴 인식 모델 다운로드 스크립트
├── FACE_RECOGNITION.md                 # (미사용) 얼굴 인식 API 가이드
├── LICENSE
├── package.json
├── pnpm-lock.yaml
├── README.md
├── service.md                          # 백엔드 서비스 API 문서
├── tsconfig.json
├── vite.config.mts
│
├── .env                                # 환경 변수 설정 (DB, JWT 등)
├── .env.template                       # 환경 변수 템플릿
│
├── .github/
│   ├── renovate.json
│   ├── actions/
│   │   └── setup-pnpm/
│   │       └── action.yml
│   └── workflows/
│       └── ci.yml
│
├── .vscode/
│   ├── extensions.json
│   ├── launch.json
│   ├── settings.json                   # 커밋 메시지 컨벤션 설정
│   └── tasks.json
│
├── models/                             # (미사용) 얼굴 인식 모델 파일
│   ├── face_landmark_68_model-*
│   ├── face_recognition_model-*
│   └── ssd_mobilenetv1_model-*
│
└── src/
    ├── index.ts                        # 애플리케이션 진입점
    ├── server.ts                       # Express 서버 설정 및 라우터 등록
    │
    ├── api/                            # API 엔드포인트 (Feature-Sliced Design)
    │   ├── apps/                       # 앱 관리 API
    │   │   ├── appsController.ts       # 요청/응답 처리
    │   │   ├── appsRepository.ts       # DB 쿼리
    │   │   ├── appsRouter.ts           # 라우팅 및 OpenAPI 정의
    │   │   └── appsService.ts          # 비즈니스 로직
    │   │
    │   ├── auth/                       # 인증 API (얼굴 인식 비활성화)
    │   │   ├── authController.ts
    │   │   ├── authRepository.ts
    │   │   ├── authRouter.ts
    │   │   └── authService.ts
    │   │
    │   ├── favorites/                  # 즐겨찾기 API
    │   │   ├── favoritesController.ts
    │   │   ├── favoritesRepository.ts
    │   │   ├── favoritesRouter.ts
    │   │   └── favoritesService.ts
    │   │
    │   └── memo/                       # 메모 CRUD API
    │       ├── memoController.ts
    │       ├── memoRepository.ts
    │       ├── memoRouter.ts
    │       └── memoService.ts
    │
    ├── api-docs/                       # Swagger OpenAPI 문서
    │   ├── __tests__/
    │   │   └── openAPIRouter.test.ts
    │   ├── openAPIDocumentGenerator.ts # OpenAPI 스펙 생성
    │   ├── openAPIResponseBuilders.ts  # 공통 응답 스키마
    │   └── openAPIRouter.ts            # Swagger UI 라우터
    │
    └── common/                         # 공통 유틸리티
        ├── __tests__/
        │   ├── errorHandler.test.ts
        │   └── requestLogger.test.ts
        │
        ├── middleware/
        │   ├── auth.ts                 # JWT 인증 미들웨어
        │   ├── errorHandler.ts         # 에러 핸들러
        │   ├── rateLimiter.ts          # Rate Limiting (IPv6 호환)
        │   └── requestLogger.ts        # Pino 로거
        │
        ├── models/
        │   └── serviceResponse.ts      # 통일된 API 응답 포맷
        │
        └── utils/
            ├── commonValidation.ts     # Zod 검증 스키마
            ├── database.ts             # PostgreSQL 연결 및 초기화
            ├── envConfig.ts            # 환경 변수 검증
            ├── faceRecognition.ts      # (비활성화) 얼굴 인식 유틸리티
            └── httpHandlers.ts         # HTTP 헬퍼
```

### 📂 주요 디렉토리 설명

#### `src/api/` - Feature-Sliced Design

각 도메인(apps, auth, favorites, memo)별로 독립적인 폴더 구조:

- **Controller**: HTTP 요청/응답 처리, 파일 업로드 등
- **Service**: 비즈니스 로직 및 데이터 검증
- **Repository**: PostgreSQL 쿼리 실행
- **Router**: 라우트 정의 및 OpenAPI 스키마 등록

#### `src/common/` - 공통 모듈

- **middleware**: 인증, 에러 처리, 로깅, Rate Limiting
- **models**: `ServiceResponse` - 모든 API가 사용하는 통일된 응답 포맷
- **utils**: DB 연결, 환경 변수 검증, HTTP 헬퍼

#### `src/api-docs/` - API 문서화

- OpenAPI 3.1 스펙 자동 생성
- Swagger UI를 통한 대화형 API 테스트 (`/swagger` 경로)

### 🗄️ 데이터베이스 스키마

PostgreSQL 테이블 구조 (`src/common/utils/database.ts`):

- **users**: 사용자 정보 (id, username, face_encoding)
- **apps**: 앱 메타데이터 (app_id, name, icon_url)
- **user_app_orders**: 사용자별 앱 정렬 순서 (JSONB)
- **memos**: 메모 (user_id, title, content)
- **favorites**: 즐겨찾기 (user_id, app_id)
