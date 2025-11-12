# 🚀 webOS Home Screen Backend

## 🌟 프로젝트 소개

webOS 디바이스의 홈 화면을 위한 백엔드 API 서버입니다.
사용자별 로그인, 메모 관리, 앱 리스트 관리, 즐겨찾기 기능을 제공합니다.

## 💡 주요 기능

### Phase 1 (현재 구현)
- ✅ 사용자 로그인/회원가입 (username/password 기반)
- ✅ 사용자별 메모 CRUD
- ✅ 사용자별 앱 리스트 순서 관리

### Phase 2 (11/13 이후 구현 예정)
- 🔮 얼굴 인식 로그인 (face-api.js, TensorFlow.js)
- 🔮 어드민 대시보드
- 🔮 128차원 얼굴 벡터 기반 사용자 인식
- 🔮 Multer 기반 이미지 업로드
- 🔮 유클리드 거리 매칭 (임계값 0.6)

> **Note**: 얼굴 인식 기능은 프로젝트 제안서(§ 1.5)에 따라 11/25 이후 구현됩니다.

## 🚀 기술 스택

- **Runtime**: Node.js 20.x
- **Framework**: Express + TypeScript 5.x
- **Database**: PostgreSQL 16.x
- **Validation**: Zod
- **Authentication**: JWT (jsonwebtoken)
- **API Docs**: OpenAPI 3.1 + Swagger UI
- **Logger**: Pino
- **Code Quality**: Biome (Linter & Formatter)
- **Phase 2 예정**: face-api.js, TensorFlow.js, Multer

## 🛠️ 시작하기

### 1️⃣ 환경 설정

```bash
# 저장소 클론
git clone https://github.com/LGE-Univ-Sogang/2025_sogang_6_lghandsome.git
cd 2025_sogang_6_lghandsome/src/backend

# 의존성 설치
pnpm install

# 환경 변수 설정
cp .env.template .env
# .env 파일을 열어 DB 정보, JWT Secret 등을 입력하세요
```

### 2️⃣ 데이터베이스 설정

```bash
# PostgreSQL 실행 (Docker)
docker-compose up -d

# 테이블은 애플리케이션 시작 시 자동 생성됩니다
```

### 3️⃣ 개발 서버 실행

```bash
# 개발 모드
pnpm start:dev

# 프로덕션 빌드
pnpm build
pnpm start:prod

# 코드 검사
pnpm check
pnpm check --write  # 자동 수정
```



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

- **users**: 사용자 정보 (id, username, password)
- **apps**: 앱 메타데이터 (app_id, name, icon_url)
- **user_app_orders**: 사용자별 앱 정렬 순서 (JSONB)
- **memos**: 메모 (user_id, title, content)
- **favorites**: 즐겨찾기 (user_id, app_id)
