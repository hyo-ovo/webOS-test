import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'memo_model.dart';

/// 백엔드 메모 API 클라이언트
class MemoApiService {
  MemoApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? _defaultBaseUrl;

  static const String _defaultBaseUrl = 'http://43.201.30.91';

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  /// 메모 목록 조회 (최대 4개)
  Future<List<Memo>> fetchMemos() async {
    final response = await _client.get(_uri('/memo'));
    _validateResponse(response, 200);

    final decoded = _decode(response.body);
    final list = _extractList(decoded);
    return list.whereType<Map<String, dynamic>>().map(Memo.fromJson).toList();
  }

  /// 메모 생성
  Future<Memo> createMemo({
    required MemoSlotType memoType,
    required String text,
    required String runPatasdh,
  }) async {
    final payload = {
      'text': text,
      'memoType': memoType.apiValue,
      'runPatasdh': runPatasdh,
    };

    final response = await _client.post(
      _uri('/memos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    _validateResponse(response, 201, fallback: 200);

    final decoded = _decode(response.body);
    final map = _extractObject(decoded);
    return Memo.fromJson(map);
  }

  /// 메모 수정
  Future<Memo> updateMemo(Memo memo) async {
    final response = await _client.put(
      _uri('/memo/${memo.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(memo.toPayload()),
    );
    _validateResponse(response, 200);

    final decoded = _decode(response.body);
    final map = _extractObject(decoded);
    return Memo.fromJson(map);
  }

  /// 메모 삭제
  Future<void> deleteMemo(String id) async {
    final response = await _client.delete(
      _uri('/memo/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    _validateResponse(response, 200, fallback: 204);
  }

  void dispose() {
    _client.close();
  }

  dynamic _decode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (e) {
      debugPrint('[MemoApiService] JSON decode failed: $e');
      return null;
    }
  }

  List<dynamic> _extractList(dynamic decoded) {
    if (decoded == null) return [];
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      final candidates = [
        decoded['data'],
        decoded['response'],
        decoded['responseObject'],
        decoded['items'],
      ];
      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate;
        }
      }
    }
    return [];
  }

  Map<String, dynamic> _extractObject(dynamic decoded) {
    if (decoded == null) return {};
    if (decoded is Map<String, dynamic>) {
      if (decoded.containsKey('data') &&
          decoded['data'] is Map<String, dynamic>) {
        return decoded['data'] as Map<String, dynamic>;
      }
      if (decoded.containsKey('responseObject') &&
          decoded['responseObject'] is Map<String, dynamic>) {
        return decoded['responseObject'] as Map<String, dynamic>;
      }
      return decoded;
    }

    if (decoded is List && decoded.isNotEmpty) {
      final first = decoded.first;
      if (first is Map<String, dynamic>) {
        return first;
      }
    }

    return {};
  }

  void _validateResponse(
    http.Response response,
    int expectedStatus, {
    int? fallback,
  }) {
    if (response.statusCode == expectedStatus ||
        (fallback != null && response.statusCode == fallback)) {
      return;
    }

    throw Exception(
      'Memo API error (${response.statusCode}): ${response.body}',
    );
  }
}
