import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'models/memo.dart';

class MemoApi {
  MemoApi({
    http.Client? client,
    String baseUrl = _defaultHost,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl;

  static const String _defaultHost = 'http://13.124.157.24:8080';

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<List<Memo>> fetchMemos() async {
    final response = await _client.get(_uri('/memo'));
    _ensureSuccess(response);
    final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((dynamic item) =>
            Memo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Memo> createMemo({
    required int memoType,
    required String content,
  }) async {
    final response = await _client.post(
      _uri('/memos'),
      headers: _headers,
      body: jsonEncode(<String, dynamic>{
        'memoType': memoType,
        'content': content,
      }),
    );
    _ensureSuccess(response);
    return Memo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Memo> updateMemo({
    required String id,
    required String content,
  }) async {
    final response = await _client.put(
      _uri('/memo/$id'),
      headers: _headers,
      body: jsonEncode(<String, dynamic>{'content': content}),
    );
    _ensureSuccess(response);
    return Memo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteMemo(String id) async {
    final response = await _client.delete(_uri('/memo/$id'));
    _ensureSuccess(response);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 400) {
      if (kDebugMode) {
        print('[MemoApi] Error ${response.statusCode}: ${response.body}');
      }
      throw Exception('Memo API error ${response.statusCode}');
    }
  }

  Map<String, String> get _headers => <String, String>{
        'Content-Type': 'application/json',
      };
}


