````markdown
# Media Database (통합형 문서)

serviceUri: luna://com.webos.mediadb

description: |
webOS의 미디어 관련 대용량 데이터셋을 로컬에 영구 저장하는 NoSQL 데이터베이스 서비스입니다.
DB8(Database)와 사용법이 동일하지만 미디어 특화 기능을 제공합니다.

주요 용도:

- 미디어 메타데이터 캐싱 (제목, 썸네일 URL, 장르, 재생 시간)
- 재생 이력 관리 (마지막 재생 위치, 시청 횟수)
- 개인화 데이터 저장 (즐겨찾기, 평점)
- 오프라인 지원 (다운로드된 미디어 정보)

schema:

- title: Media Database
  serviceUri: luna://com.webos.mediadb
  description: 미디어 메타데이터와 개인화 데이터를 로컬에 저장/조회/관리

  ## 기본 워크플로우

  1. putKind: 데이터 스키마(Kind) 등록
  2. putPermissions: 다른 앱 접근 권한 설정 (선택)
  3. put: 데이터 객체 저장
  4. find/search/get: 데이터 조회
  5. merge: 데이터 업데이트
  6. del: 데이터 삭제
  7. watch: 변경사항 구독 (선택)

  methods:

  - name: putKind
    description: 데이터 스키마(Kind)를 등록합니다. 인덱스를 정의하여 빠른 쿼리를 지원합니다.
    parameters:

    - name: id
      type: string
      required: true
      description: Kind ID (예: "com.yourapp.media:1")
    - name: owner
      type: string
      required: true
      description: 앱 ID 또는 서비스 버스 주소
    - name: indexes
      type: object array
      required: false
      description: 인덱스 정의 (쿼리 성능 향상)
    - name: schema
      type: object
      required: false
      description: JSON 스키마 검증용 (선택)
      payloadExample:
      {
      "id": "com.yourapp.media:1",
      "owner": "com.yourapp",
      "indexes": [
      {
      "name": "title",
      "props": [{"name": "title"}]
      },
      {
      "name": "genre",
      "props": [{"name": "genre"}]
      },
      {
      "name": "lastPlayed",
      "props": [{"name": "lastPlayedAt"}]
      }
      ]
      }
      returnExample:
      { "returnValue": true }
      notes: |
    - 앱 최초 실행 시 한 번만 호출하면 됩니다.
    - 인덱스는 find/search 쿼리에서 사용할 필드를 지정해야 합니다.
      usage:
    - flutterExample: |
      static Future<void> initializeMediaKind() async {
      await callOneReply(
      uri: 'luna://com.webos.mediadb',
      method: 'putKind',
      payload: { /_ ... _/ },
      );
      }

  - name: put
    description: 미디어 메타데이터를 저장합니다. 각 객체에 자동으로 \_id와 \_rev가 할당됩니다.
    parameters:

    - name: objects
      type: object array
      required: true
      description: 저장할 JSON 객체 배열 (각 객체는 \_kind 필드 필수)
      payloadExample:
      {
      "objects": [
      {
      "_kind": "com.yourapp.media:1",
      "title": "어벤져스",
      "streamUrl": "https://cdn.example.com/avengers.mp4",
      "thumbnailUrl": "https://cdn.example.com/thumb.jpg",
      "genre": "action",
      "durationSeconds": 7200,
      "lastPlayedPosition": 0,
      "isFavorite": false
      }
      ]
      }
      returnExample:
      {
      "returnValue": true,
      "results": [
      { "id": "J8rTIa65u++", "rev": 27 }
      ]
      }
      notes: \_id는 자동 생성되며, 이후 merge/del에 사용됩니다.
      usage:
    - flutterExample: |
      static Future<String?> addMedia({
      required String title,
      required String streamUrl,
      }) async {
      final res = await callOneReply(
      uri: 'luna://com.webos.mediadb',
      method: 'put',
      payload: { "objects": [{ /* ... */ }] },
      );
      return res?['results']?[0]?['id'];
      }

  - name: find
    description: 쿼리 조건에 맞는 객체들을 조회합니다. 인덱스된 필드로 빠르게 검색 가능합니다.
    parameters:

    - name: query
      type: object
      required: true
      description: DB8 쿼리 (from, where, orderBy 등)
    - name: count
      type: boolean
      required: false
      description: true면 전체 결과 개수를 반환
    - name: watch
      type: boolean
      required: false
      description: true면 결과 변경 시 알림
      payloadExample:
      {
      "query": {
      "from": "com.yourapp.media:1",
      "where": [
      { "prop": "genre", "op": "=", "val": "action" }
      ],
      "orderBy": "lastPlayedAt",
      "desc": true,
      "limit": 20
      }
      }
      returnExample:
      {
      "returnValue": true,
      "results": [
      {
      "_id": "J8rKTaBClIo",
      "_rev": 21,
      "_kind": "com.yourapp.media:1",
      "title": "어벤져스",
      "genre": "action"
      }
      ]
      }
      notes: |
    - where 절에 사용하는 prop은 반드시 putKind에서 인덱스로 등록되어 있어야 합니다.
    - op: =, !=, <, <=, >, >=, %, ? (prefix, full-text)
      usage:
    - flutterExample: |
      static Future<List<MediaItem>> getMediaByGenre(String genre) async {
      final res = await callOneReply(
      uri: 'luna://com.webos.mediadb',
      method: 'find',
      payload: { "query": { /_ ... _/ } },
      );
      return (res?['results'] as List? ?? [])
      .map((e) => MediaItem.fromJson(e))
      .toList();
      }

  - name: search
    description: 전체 텍스트 검색을 지원합니다 (? 연산자). find보다 느리지만 부분 문자열 검색 가능.
    parameters:

    - name: query
      type: object
      required: true
      description: DB8 쿼리 (where에 ? 연산자 사용 가능)
      payloadExample:
      {
      "query": {
      "from": "com.yourapp.media:1",
      "where": [
      { "prop": "title", "op": "?", "val": "어벤" }
      ]
      }
      }
      returnExample:
      {
      "returnValue": true,
      "count": 2,
      "results": [ /* ... */ ]
      }
      notes: |
    - 타이핑 검색에 사용 (예: 제목 검색창)
    - 인덱스 필요, 단어 시작 부분만 매칭
      usage:
    - flutterExample: |
      static Future<List<MediaItem>> searchByTitle(String keyword) async {
      final res = await callOneReply(
      uri: 'luna://com.webos.mediadb',
      method: 'search',
      payload: { "query": { "from": "...", "where": [...] } },
      );
      return parseResults(res);
      }

  - name: get
    description: ID로 객체를 직접 조회합니다. 가장 빠른 조회 방법입니다.
    parameters:

    - name: ids
      type: string array
      required: true
      description: 조회할 객체 ID 배열
      payloadExample:
      { "ids": ["J8rKTaBClIo"] }
      returnExample:
      {
      "returnValue": true,
      "results": [
      { "_id": "J8rKTaBClIo", "title": "어벤져스", /* ... */ }
      ]
      }
      usage:
    - flutterExample: |
      static Future<MediaItem?> getMediaById(String id) async {
      final res = await callOneReply(
      uri: 'luna://com.webos.mediadb',
      method: 'get',
      payload: { "ids": [id] },
      );
      final results = res?['results'] as List?;
      return results?.isNotEmpty == true
      ? MediaItem.fromJson(results![0])
      : null;
      }

  - name: merge
    description: 기존 객체의 특정 필드만 업데이트합니다 (부분 업데이트).
    parameters:

    - name: objects
      type: object array
      required: false
      description: \_id와 업데이트할 필드 포함
    - name: query
      type: object
      required: false
      description: 업데이트할 객체를 쿼리로 선택
    - name: props
      type: object
      required: false
      description: query 사용 시 업데이트할 필드
      payloadExample:
      {
      "objects": [
      {
      "_id": "J8rKTaBClIo",
      "lastPlayedPosition": 1800,
      "lastPlayedAt": 1704067200000
      }
      ]
      }
      returnExample:
      {
      "returnValue": true,
      "results": [
      { "id": "J8rKTaBClIo", "rev": 23 }
      ]
      }
      notes: |
    - 재생 위치 업데이트에 유용 (전체 객체 대체 불필요)
    - query 방식: 여러 객체 일괄 업데이트 가능
      usage:
    - flutterExample: |
      static Future<void> updatePlaybackPosition(String id, int seconds) async {
      await callOneReply(
      uri: 'luna://com.webos.mediadb',
      method: 'merge',
      payload: {
      "objects": [
      { "_id": id, "lastPlayedPosition": seconds }
      ]
      },
      );
      }

  - name: del
    description: 객체를 삭제합니다 (ID 또는 쿼리로 선택 가능).
    parameters:

    - name: ids
      type: string array
      required: false
      description: 삭제할 객체 ID 배열
    - name: query
      type: object
      required: false
      description: 삭제할 객체를 쿼리로 선택
    - name: purge
      type: boolean
      required: false
      description: true면 즉시 영구 삭제, false면 삭제 마크만 (기본값)
      payloadExample:
      { "ids": ["J8rKTaBClIo"] }
      returnExample:
      {
      "returnValue": true,
      "results": [
      { "id": "J8rKTaBClIo" }
      ]
      }
      usage:
    - flutterExample: |
      static Future<void> deleteMedia(String id) async {
      await callOneReply(
      uri: 'luna://com.webos.mediadb',
      method: 'del',
      payload: { "ids": [id] },
      );
      }

  - name: watch
    description: 쿼리 결과에 변경사항이 생기면 알림을 받습니다 (구독).
    parameters:

    - name: query
      type: object
      required: true
      description: 감시할 쿼리
      payloadExample:
      {
      "query": {
      "from": "com.yourapp.media:1",
      "where": [
      { "prop": "isFavorite", "op": "=", "val": true }
      ]
      }
      }
      returnExample:
      {
      "returnValue": true,
      "fired": true
      }
      notes: |
    - 실시간 업데이트가 필요한 UI에 사용
    - 구독 해제: request.cancel()
      usage:
    - flutterExample: |
      var request = await callOneReply(
      uri: 'luna://com.webos.mediadb',
      method: 'watch',
      payload: { "query": { /_ ... _/ } },
      subscribe: true,
      );
      // 구독 해제: request.cancel()

  - name: batch
    description: 여러 DB 작업을 한 번에 실행합니다 (원자성 보장 안 됨).
    parameters:

    - name: operations
      type: object array
      required: true
      description: 실행할 작업 목록 (put, get, del, find, merge)
      payloadExample:
      {
      "operations": [
      {
      "method": "put",
      "params": { "objects": [{ /* ... */ }] }
      },
      {
      "method": "merge",
      "params": { "query": { /_ ... _/ }, "props": { /_ ... _/ } }
      }
      ]
      }
      returnExample:
      {
      "returnValue": true,
      "responses": [
      { "returnValue": true, "results": [...] },
      { "count": 1, "returnValue": true }
      ]
      }
      notes: 트랜잭션이 아니므로 일부 실패 가능

  - name: putPermissions
    description: 다른 앱에 데이터 접근 권한을 부여합니다.
    parameters:

    - name: permissions
      type: object array
      required: true
      description: 권한 설정 배열
      payloadExample:
      {
      "permissions": [
      {
      "type": "db.kind",
      "object": "com.yourapp.media:1",
      "caller": "com.otherapp",
      "operations": {
      "read": "allow",
      "create": "allow",
      "update": "allow",
      "delete": "allow"
      }
      }
      ]
      }
      notes: 다른 앱과 데이터 공유 시에만 필요

  - name: delKind
    description: Kind를 삭제합니다 (모든 데이터도 함께 삭제됨).
    parameters:

    - name: id
      type: string
      required: true
      description: 삭제할 Kind ID
      payloadExample:
      { "id": "com.yourapp.media:1" }
      notes: 주의! 해당 Kind의 모든 데이터가 삭제됩니다.

  - name: reserveIds
    description: 객체 ID를 미리 예약합니다 (일괄 삽입 시 사용).
    parameters:
    - name: count
      type: number
      required: true
      description: 예약할 ID 개수
      payloadExample:
      { "count": 10 }
      returnExample:
      {
      "returnValue": true,
      "ids": ["J9FJ12j0Usk", "J9FJ12j18hJ", /* ... */ ]
      }

## 실전 사용 예시

### 1. 초기 설정 (앱 설치 시 한 번만)

```dart
class MediaDbService {
  static Future<void> initialize() async {
    // Kind 등록
    await callOneReply(
      uri: 'luna://com.webos.mediadb',
      method: 'putKind',
      payload: {
        "id": "com.yourapp.media:1",
        "owner": "com.yourapp",
        "indexes": [
          {"name": "title", "props": [{"name": "title"}]},
          {"name": "genre", "props": [{"name": "genre"}]},
          {"name": "lastPlayed", "props": [{"name": "lastPlayedAt"}]},
        ]
      },
    );
  }
}
```
````

### 2. 미디어 추가

```dart
static Future<String?> addMedia({
  required String title,
  required String streamUrl,
  String? genre,
}) async {
  final res = await callOneReply(
    uri: 'luna://com.webos.mediadb',
    method: 'put',
    payload: {
      "objects": [
        {
          "_kind": "com.yourapp.media:1",
          "title": title,
          "streamUrl": streamUrl,
          "genre": genre ?? "unknown",
          "lastPlayedPosition": 0,
          "isFavorite": false,
        }
      ]
    },
  );
  return res?['results']?[0]?['id'];
}
```

### 3. 목록 조회 (장르별)

```dart
static Future<List<MediaItem>> getMediaByGenre(String genre) async {
  final res = await callOneReply(
    uri: 'luna://com.webos.mediadb',
    method: 'find',
    payload: {
      "query": {
        "from": "com.yourapp.media:1",
        "where": [{"prop": "genre", "op": "=", "val": genre}]
      }
    },
  );
  return (res?['results'] as List? ?? [])
      .map((e) => MediaItem.fromJson(e))
      .toList();
}
```

### 4. 재생 위치 업데이트 (이어보기)

```dart
static Future<void> updatePlaybackPosition(String mediaId, int seconds) async {
  await callOneReply(
    uri: 'luna://com.webos.mediadb',
    method: 'merge',
    payload: {
      "objects": [
        {
          "_id": mediaId,
          "lastPlayedPosition": seconds,
          "lastPlayedAt": DateTime.now().millisecondsSinceEpoch,
        }
      ]
    },
  );
}
```

### 5. 제목 검색

```dart
static Future<List<MediaItem>> searchByTitle(String keyword) async {
  final res = await callOneReply(
    uri: 'luna://com.webos.mediadb',
    method: 'search',
    payload: {
      "query": {
        "from": "com.yourapp.media:1",
        "where": [{"prop": "title", "op": "?", "val": keyword}]
      }
    },
  );
  return parseResults(res);
}
```

### 6. 즐겨찾기 토글

```dart
static Future<void> toggleFavorite(String mediaId, bool isFavorite) async {
  await callOneReply(
    uri: 'luna://com.webos.mediadb',
    method: 'merge',
    payload: {
      "objects": [
        {"_id": mediaId, "isFavorite": isFavorite}
      ]
    },
  );
}
```

## 주요 사용 패턴

### 패턴 1: 하이브리드 캐싱

```
Backend (서버) → Media Database (로컬 캐시) → Flutter UI
- 앱 시작: 로컬에서 즉시 로드
- 백그라운드: 서버 데이터 동기화
```

### 패턴 2: 개인화 데이터 (로컬 우선)

```
사용자 행동 → Media Database (즉시 저장)
- 재생 위치, 즐겨찾기, 평점
- 서버 동기화는 선택적
```

### 패턴 3: 오프라인 지원

```
온라인: 다운로드 + Media Database에 기록
오프라인: Media Database 조회 → 다운로드된 항목만 표시
```

## 주의사항

1. **인덱스 필수**: find/search에서 사용할 필드는 반드시 putKind에서 인덱스로 등록
2. **쿼리 제한**: where 절은 인덱싱된 필드만 사용 가능
3. **원자성 없음**: batch는 트랜잭션이 아니므로 일부 실패 가능
4. **전체 텍스트 검색 느림**: search는 타이핑 검색용으로만 사용 권장
5. **purge 주의**: del에서 purge=true는 복구 불가능한 영구 삭제

## 에러 처리

```dart
final res = await callOneReply(/* ... */);
if (res?['returnValue'] != true) {
  final errorCode = res?['errorCode'];
  final errorText = res?['errorText'];
  print('Error: [$errorCode] $errorText');
  // -3970: kind not registered
  // -3963: permission denied
  // -3962: quota exceeded
}
```

## 참고

- Media Database는 DB8와 동일한 API 사용
- 미디어 재생은 별도 video_player 필요
- 볼륨 제어는 luna://com.webos.audio 사용
- 상세 DB8 문서: https://webostv.developer.lge.com/develop/references/database

```

```
