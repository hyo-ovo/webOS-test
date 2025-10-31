# 얼굴 인증 로직 구현 가이드

## 전체 플로우

```
1. webOS Client (Flutter)
   ↓ 카메라로 얼굴 사진 촬영
   ↓ JPEG 이미지를 Base64 또는 Multipart로 인코딩

2. HTTP POST → Express Backend
   ↓ /auth/face-login

3. Backend (Node.js)
   ↓ 이미지 수신 → Face Recognition Library
   ↓ 얼굴 특징 추출 (face encoding)
   ↓ DB의 저장된 얼굴들과 비교

4. 인증 성공 시
   ↓ JWT 토큰 발급
   ↓ 사용자 정보 반환

5. webOS Client
   ↓ 토큰 저장 (SharedPreferences)
   ↓ 홈 화면으로 이동
```

---

## 1. webOS Client (Flutter) 구현

### 1-1. 카메라 서비스 (camera_service.dart)

```dart
import 'package:webos_service_helper/utils.dart';

class CameraService {
  // 1. AI 모델 설치
  static Future<void> installModel() async {
    await callOneReply(
      uri: 'luna://com.webos.service.aiinferencemanager',
      method: 'installModel',
      payload: {'id': 'FACE'},
    );
  }

  // 2. 카메라 목록 조회
  static Future<String?> getCameraId() async {
    final res = await callOneReply(
      uri: 'luna://com.webos.service.camera2',
      method: 'getCameraList',
      payload: {},
    );
    return res?['deviceList']?[0]?['id'];
  }

  // 3. 카메라 권한 설정
  static Future<void> setPermission() async {
    await callOneReply(
      uri: 'luna://com.webos.service.camera2',
      method: 'setPermission',
      payload: {'appId': 'com.webos.app.homescreen'},
    );
  }

  // 4. 카메라 열기
  static Future<int?> openCamera(String cameraId) async {
    final res = await callOneReply(
      uri: 'luna://com.webos.service.camera2',
      method: 'open',
      payload: {
        'appId': 'com.webos.app.homescreen',
        'id': cameraId,
        'mode': 'primary',
      },
    );
    return res?['handle'];
  }

  // 5. 포맷 설정 (1280x720 JPEG)
  static Future<void> setFormat(int handle) async {
    await callOneReply(
      uri: 'luna://com.webos.service.camera2',
      method: 'setFormat',
      payload: {
        'handle': handle,
        'params': {
          'format': 'JPEG',
          'fps': 30,
          'width': 1280,
          'height': 720,
        },
      },
    );
  }

  // 6. 프리뷰 시작
  static Future<void> startPreview(int handle) async {
    await callOneReply(
      uri: 'luna://com.webos.service.camera2',
      method: 'startPreview',
      payload: {'handle': handle},
    );
  }

  // 7. 사진 촬영 (캡처)
  static Future<String?> takePicture(int handle) async {
    final res = await callOneReply(
      uri: 'luna://com.webos.service.camera2',
      method: 'takePicture',
      payload: {
        'handle': handle,
        'params': {
          'width': 640,
          'height': 480,
          'format': 'JPEG',
        },
      },
    );
    // 반환된 이미지 경로 또는 Base64 데이터
    return res?['imagePath'] ?? res?['imageData'];
  }

  // 8. 카메라 닫기
  static Future<void> closeCamera(int handle) async {
    await callOneReply(
      uri: 'luna://com.webos.service.camera2',
      method: 'close',
      payload: {'handle': handle},
    );
  }
}
```

### 1-2. 얼굴 인증 화면 (face_login_page.dart)

```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class FaceLoginPage extends StatefulWidget {
  @override
  _FaceLoginPageState createState() => _FaceLoginPageState();
}

class _FaceLoginPageState extends State<FaceLoginPage> {
  bool _isLoading = false;
  String? _message;
  int? _cameraHandle;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // 카메라 초기화
  Future<void> _initializeCamera() async {
    try {
      await CameraService.installModel();
      final cameraId = await CameraService.getCameraId();
      if (cameraId == null) {
        setState(() => _message = '카메라를 찾을 수 없습니다');
        return;
      }

      await CameraService.setPermission();
      _cameraHandle = await CameraService.openCamera(cameraId);
      if (_cameraHandle != null) {
        await CameraService.setFormat(_cameraHandle!);
        await CameraService.startPreview(_cameraHandle!);
        setState(() => _message = '카메라 준비 완료');
      }
    } catch (e) {
      setState(() => _message = '카메라 초기화 실패: $e');
    }
  }

  // 얼굴 인증 실행
  Future<void> _performFaceLogin() async {
    if (_cameraHandle == null) {
      setState(() => _message = '카메라가 준비되지 않았습니다');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '얼굴 인식 중...';
    });

    try {
      // 1. 사진 촬영
      final imagePath = await CameraService.takePicture(_cameraHandle!);
      if (imagePath == null) {
        throw Exception('사진 촬영 실패');
      }

      // 2. 백엔드로 전송
      final response = await _sendToBackend(imagePath);

      if (response['success']) {
        // 3. 토큰 저장
        final token = response['token'];
        await _saveToken(token);

        // 4. 홈 화면으로 이동
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() => _message = '얼굴 인식 실패: ${response['message']}');
      }
    } catch (e) {
      setState(() => _message = '오류 발생: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 백엔드로 이미지 전송
  Future<Map<String, dynamic>> _sendToBackend(String imagePath) async {
    final uri = Uri.parse('http://localhost:8080/auth/face-login');
    final request = http.MultipartRequest('POST', uri);

    // 이미지 파일 첨부
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(responseBody);
    } else {
      throw Exception('서버 오류: ${response.statusCode}');
    }
  }

  // 토큰 저장 (SharedPreferences)
  Future<void> _saveToken(String token) async {
    // TODO: SharedPreferences에 저장
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('auth_token', token);
  }

  @override
  void dispose() {
    if (_cameraHandle != null) {
      CameraService.closeCamera(_cameraHandle!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('얼굴 인증 로그인')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.face, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(_message ?? '카메라를 초기화 중...'),
            SizedBox(height: 40),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _performFaceLogin,
                    icon: Icon(Icons.camera_alt),
                    label: Text('얼굴 인증 시작'),
                  ),
          ],
        ),
      ),
    );
  }
}
```

---

## 2. Backend (Express + TypeScript) 구현

### 2-1. Face Recognition 라이브러리 설치

```bash
cd /Users/Inyoung/Desktop/26-2/lg-capstone/2025_sogang_6/src/backend
pnpm add face-api.js @tensorflow/tfjs-node canvas
pnpm add -D @types/canvas
```

### 2-2. Face Recognition 유틸리티 (faceRecognition.ts)

```typescript
// src/common/utils/faceRecognition.ts
import * as faceapi from "face-api.js";
import * as canvas from "canvas";
import * as tf from "@tensorflow/tfjs-node";
import path from "path";

// Canvas 설정 (face-api.js가 브라우저 API 대신 사용)
const { Canvas, Image, ImageData } = canvas;
faceapi.env.monkeyPatch({ Canvas, Image, ImageData } as any);

// 모델 로드 여부
let modelsLoaded = false;

// Face Recognition 모델 로드
export async function loadModels() {
  if (modelsLoaded) return;

  const modelPath = path.join(__dirname, "../../../models");

  await Promise.all([
    faceapi.nets.ssdMobilenetv1.loadFromDisk(modelPath),
    faceapi.nets.faceLandmark68Net.loadFromDisk(modelPath),
    faceapi.nets.faceRecognitionNet.loadFromDisk(modelPath),
  ]);

  modelsLoaded = true;
  console.log("✅ Face recognition models loaded");
}

// 이미지에서 얼굴 특징 추출
export async function extractFaceDescriptor(
  imageBuffer: Buffer
): Promise<Float32Array | null> {
  const img = await canvas.loadImage(imageBuffer);
  const detection = await faceapi
    .detectSingleFace(img as any)
    .withFaceLandmarks()
    .withFaceDescriptor();

  if (!detection) {
    return null; // 얼굴 감지 안됨
  }

  return detection.descriptor;
}

// 두 얼굴 특징 비교 (유사도 계산)
export function compareFaces(
  descriptor1: Float32Array,
  descriptor2: Float32Array
): number {
  const distance = faceapi.euclideanDistance(descriptor1, descriptor2);
  const similarity = 1 - distance; // 0~1 (높을수록 유사)
  return similarity;
}

// 얼굴 매칭 (임계값 0.6 이상이면 동일인)
export function isSamePerson(
  descriptor1: Float32Array,
  descriptor2: Float32Array,
  threshold: number = 0.6
): boolean {
  const similarity = compareFaces(descriptor1, descriptor2);
  return similarity >= threshold;
}
```

### 2-3. Auth Service 업데이트

```typescript
// src/api/auth/authService.ts
import { authRepository } from "./authRepository";
import jwt from "jsonwebtoken";
import { env } from "@/common/utils/envConfig";
import {
  extractFaceDescriptor,
  isSamePerson,
  loadModels,
} from "@/common/utils/faceRecognition";

export class AuthService {
  // 얼굴 인식 로그인
  async faceLogin(imageBuffer: Buffer): Promise<{
    token: string;
    userId: number;
    username: string;
  }> {
    // 1. Face Recognition 모델 로드
    await loadModels();

    // 2. 업로드된 이미지에서 얼굴 특징 추출
    const uploadedDescriptor = await extractFaceDescriptor(imageBuffer);
    if (!uploadedDescriptor) {
      throw new Error("얼굴을 감지할 수 없습니다");
    }

    // 3. DB에서 모든 사용자 얼굴 데이터 가져오기
    const users = await authRepository.getAllUsers();

    // 4. 각 사용자와 비교
    for (const user of users) {
      const storedDescriptor = new Float32Array(JSON.parse(user.face_encoding));

      if (isSamePerson(uploadedDescriptor, storedDescriptor)) {
        // 5. 매칭 성공 → JWT 발급
        const token = jwt.sign(
          { userId: user.id, username: user.username },
          env.JWT_SECRET,
          { expiresIn: env.JWT_EXPIRES_IN }
        );

        return {
          token,
          userId: user.id,
          username: user.username,
        };
      }
    }

    throw new Error("등록된 사용자를 찾을 수 없습니다");
  }

  // 얼굴 등록 (개발용)
  async registerFace(
    imageBuffer: Buffer,
    username: string
  ): Promise<{ userId: number }> {
    await loadModels();

    const descriptor = await extractFaceDescriptor(imageBuffer);
    if (!descriptor) {
      throw new Error("얼굴을 감지할 수 없습니다");
    }

    // Float32Array를 JSON으로 직렬화
    const faceEncoding = JSON.stringify(Array.from(descriptor));

    const userId = await authRepository.createUser(username, faceEncoding);

    return { userId };
  }
}

export const authService = new AuthService();
```

### 2-4. Auth Controller 업데이트

```typescript
// src/api/auth/authController.ts
import { Request, Response } from "express";
import { authService } from "./authService";

export class AuthController {
  // 얼굴인식 로그인
  async faceLogin(req: Request, res: Response) {
    try {
      if (!req.file) {
        return res.status(400).json({ error: "이미지 파일이 필요합니다" });
      }

      const result = await authService.faceLogin(req.file.buffer);

      res.status(200).json({
        success: true,
        ...result,
      });
    } catch (error: any) {
      res.status(401).json({
        success: false,
        message: error.message,
      });
    }
  }

  // 얼굴 등록
  async registerFace(req: Request, res: Response) {
    try {
      if (!req.file) {
        return res.status(400).json({ error: "이미지 파일이 필요합니다" });
      }

      const username = req.body.username || `user_${Date.now()}`;
      const result = await authService.registerFace(req.file.buffer, username);

      res.status(201).json({
        success: true,
        ...result,
      });
    } catch (error: any) {
      res.status(400).json({
        success: false,
        message: error.message,
      });
    }
  }
}

export const authController = new AuthController();
```

### 2-5. Auth Repository 업데이트

```typescript
// src/api/auth/authRepository.ts
import { db } from "@/common/utils/database";

export class AuthRepository {
  async getAllUsers(): Promise<
    Array<{ id: number; username: string; face_encoding: string }>
  > {
    const result = await db.query(
      "SELECT id, username, face_encoding FROM users"
    );
    return result.rows;
  }

  async createUser(username: string, faceEncoding: string): Promise<number> {
    const result = await db.query(
      "INSERT INTO users (username, face_encoding) VALUES ($1, $2) RETURNING id",
      [username, faceEncoding]
    );
    return result.rows[0].id;
  }
}

export const authRepository = new AuthRepository();
```

---

## 3. Face Recognition 모델 다운로드

모델 파일들을 `src/backend/models/` 폴더에 다운로드:

```bash
mkdir -p models
cd models

# face-api.js 모델 다운로드
curl -O https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights/ssd_mobilenetv1_model-weights_manifest.json
curl -O https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights/ssd_mobilenetv1_model-shard1
curl -O https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights/face_landmark_68_model-weights_manifest.json
curl -O https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights/face_landmark_68_model-shard1
curl -O https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights/face_recognition_model-weights_manifest.json
curl -O https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights/face_recognition_model-shard1
curl -O https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights/face_recognition_model-shard2
```

---

## 4. 전체 플로우 시퀀스

```mermaid
sequenceDiagram
    participant Client as webOS Client
    participant Camera as Luna Camera API
    participant Backend as Express Backend
    participant FaceAPI as Face Recognition
    participant DB as PostgreSQL

    Client->>Camera: installModel("FACE")
    Client->>Camera: getCameraList()
    Camera-->>Client: cameraId
    Client->>Camera: setPermission()
    Client->>Camera: open(cameraId)
    Camera-->>Client: handle
    Client->>Camera: setFormat(handle)
    Client->>Camera: startPreview(handle)
    Client->>Camera: takePicture(handle)
    Camera-->>Client: imageData

    Client->>Backend: POST /auth/face-login (image)
    Backend->>FaceAPI: extractFaceDescriptor(image)
    FaceAPI-->>Backend: descriptor
    Backend->>DB: SELECT all users
    DB-->>Backend: users[]
    Backend->>FaceAPI: compareFaces(descriptor, stored)
    FaceAPI-->>Backend: similarity
    Backend->>Backend: JWT.sign()
    Backend-->>Client: { token, userId, username }

    Client->>Client: saveToken(token)
    Client->>Client: navigate('/home')
```

---

## 5. 테스트 방법

### 5-1. 얼굴 등록 (개발용)

```bash
curl -X POST http://localhost:8080/auth/register-face \
  -F "image=@test_face.jpg" \
  -F "username=홍길동"
```

### 5-2. 얼굴 로그인

```bash
curl -X POST http://localhost:8080/auth/face-login \
  -F "image=@test_face.jpg"
```

---

## 6. 보안 고려사항

1. **HTTPS 필수**: 프로덕션에서는 반드시 HTTPS 사용
2. **이미지 크기 제한**: 현재 10MB (MAX_FILE_SIZE)
3. **Rate Limiting**: 무차별 대입 공격 방지
4. **얼굴 유사도 임계값**: 0.6 (조정 가능)
5. **JWT 만료 시간**: 24시간 (env.JWT_EXPIRES_IN)

---

## 7. 성능 최적화

1. **캐싱**: 얼굴 디스크립터를 메모리에 캐싱
2. **이미지 리사이징**: webOS에서 640x480으로 전송
3. **비동기 처리**: 얼굴 비교를 병렬 처리
4. **인덱싱**: PostgreSQL에 사용자 ID 인덱스

---

## 8. 에러 처리

| 에러 코드 | 메시지                           | 해결 방법        |
| --------- | -------------------------------- | ---------------- |
| 400       | 이미지 파일이 필요합니다         | 파일 업로드 확인 |
| 401       | 얼굴을 감지할 수 없습니다        | 조명/각도 조정   |
| 401       | 등록된 사용자를 찾을 수 없습니다 | 얼굴 재등록 필요 |
| 500       | 서버 오류                        | 로그 확인        |

---

이제 webOS 클라이언트에서 카메라로 얼굴을 촬영하고, 백엔드에서 Face Recognition으로 인증하는 전체 시스템이 완성됩니다! 🎉
