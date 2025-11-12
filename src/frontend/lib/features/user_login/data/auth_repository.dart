import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_model.dart';

class AuthRepository {
  // Windows 호스트 IP 주소 사용 (ipconfig로 확인)
  static const String baseUrl = 'http://192.168.0.100:8080/api/auth';

  // 사용자 목록 가져오기
  Future<List<UserModel>> getStoredUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final users = (data['data'] as List)
          .map((u) => UserModel(
                id: u['id'],
                username: u['username'],
                isChild: u['isChild'],
              ))
          .toList();
      return users;
    }
    throw Exception('사용자 목록을 불러올 수 없습니다');
  }

  // 회원가입
  Future<UserModel> registerFace({
    required String username,
    required bool isChild,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'isChild': isChild}),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return UserModel(
        id: data['data']['userId'],
        username: username,
        isChild: isChild,
      );
    }
    throw Exception('회원가입에 실패했습니다');
  }

  // 로그인
  Future<UserModel> loginWithFace({required String username}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return UserModel(
        id: data['userId'],
        username: data['username'],
        token: data['token'],
        isChild: data['isChild'],
      );
    }
    throw Exception('로그인에 실패했습니다');
  }
}
