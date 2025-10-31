# 얼굴 인증 API 사용 가이드

## 🚀 시작하기

### 1. Face Recognition 모델 다운로드

```bash
chmod +x download-models.sh
./download-models.sh
```

모델 파일들이 `models/` 폴더에 다운로드됩니다 (~40MB).

### 2. 서버 실행

```bash
pnpm start:dev
```

## 📡 API 엔드포인트

### 1. 얼굴 등록 (POST /auth/register-face)

**Request:**

```bash
curl -X POST http://localhost:8080/auth/register-face \
  -F "image=@face_photo.jpg" \
  -F "username=홍길동"
```

**Response (성공):**

```json
{
  "success": true,
  "message": "얼굴 등록 성공",
  "responseObject": {
    "userId": 1,
    "username": "홍길동"
  },
  "statusCode": 200
}
```

**Response (실패 - 얼굴 감지 안됨):**

```json
{
  "success": false,
  "message": "얼굴을 감지할 수 없습니다",
  "responseObject": null,
  "statusCode": 400
}
```

---

### 2. 얼굴 로그인 (POST /auth/face-login)

**Request:**

```bash
curl -X POST http://localhost:8080/auth/face-login \
  -F "image=@face_photo.jpg"
```

**Response (성공):**

```json
{
  "success": true,
  "message": "로그인 성공",
  "responseObject": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user_info": {
      "id": 1,
      "username": "홍길동"
    }
  },
  "statusCode": 200
}
```

**Response (실패 - 사용자 없음):**

```json
{
  "success": false,
  "message": "등록된 사용자를 찾을 수 없습니다",
  "responseObject": null,
  "statusCode": 401
}
```

---

## 🧪 테스트 방법

### 1. Postman으로 테스트

1. **POST** `http://localhost:8080/auth/register-face`
2. Body → form-data 선택
3. Key: `image` (Type: File), Value: 얼굴 사진 업로드
4. Key: `username` (Type: Text), Value: "테스트사용자"
5. Send

### 2. curl로 테스트

```bash
# 1. 얼굴 등록
curl -X POST http://localhost:8080/auth/register-face \
  -F "image=@test_face.jpg" \
  -F "username=테스트"

# 2. 얼굴 로그인
curl -X POST http://localhost:8080/auth/face-login \
  -F "image=@test_face.jpg"
```

---

## 🎯 작동 원리

### 1. 얼굴 등록 플로우

```
이미지 업로드
  ↓
face-api.js로 얼굴 감지
  ↓
128차원 얼굴 특징 벡터 추출
  ↓
JSON으로 직렬화
  ↓
PostgreSQL에 저장
```

### 2. 얼굴 로그인 플로우

```
이미지 업로드
  ↓
얼굴 특징 벡터 추출
  ↓
DB의 모든 사용자와 비교
  ↓
유사도 0.6 이상이면 매칭 성공
  ↓
JWT 토큰 발급
```

---

## ⚙️ 설정

### 얼굴 유사도 임계값 조정

`src/common/utils/faceRecognition.ts`:

```typescript
export function isSamePerson(
  descriptor1: Float32Array,
  descriptor2: Float32Array,
  threshold: number = 0.6 // 0.5 ~ 0.7 권장
): boolean {
  // ...
}
```

- **0.5**: 관대한 매칭 (오인식 증가)
- **0.6**: 기본값 (균형)
- **0.7**: 엄격한 매칭 (거부율 증가)

---

## 🔒 보안

1. **JWT 토큰**: 24시간 유효 (.env의 `JWT_EXPIRES_IN`)
2. **Rate Limiting**: IP당 1초에 20회 제한
3. **파일 크기**: 최대 10MB
4. **MIME Type**: 이미지 파일만 허용

---

## 🐛 문제 해결

### "Face recognition models not found" 오류

→ 모델 다운로드:

```bash
./download-models.sh
```

### "얼굴을 감지할 수 없습니다" 오류

→ 체크리스트:

- ✅ 정면 얼굴이 명확히 보이는가?
- ✅ 조명이 충분한가?
- ✅ 이미지 해상도가 너무 낮지 않은가?
- ✅ 여러 사람이 함께 찍힌 사진이 아닌가?

### "등록된 사용자를 찾을 수 없습니다" 오류

→ 가능한 원인:

- 등록 시와 다른 각도/조명으로 촬영
- 안경/모자 착용 여부 변경
- 유사도 임계값이 너무 높음

---

## 📊 성능

- **얼굴 감지**: ~200ms
- **특징 추출**: ~300ms
- **DB 비교 (100명 기준)**: ~50ms
- **총 응답 시간**: ~600ms

---

## 🔗 참고 자료

- [face-api.js GitHub](https://github.com/justadudewhohacks/face-api.js)
- [TensorFlow.js](https://www.tensorflow.org/js)
- [JWT 인증](https://jwt.io/)
