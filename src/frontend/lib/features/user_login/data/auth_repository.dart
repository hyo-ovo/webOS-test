import 'user_model.dart';

class AuthRepository {
  // Mock: TV에 저장된 사용자 목록 (실제로는 SharedPreferences나 로컬 DB 사용)
  final List<UserModel> _mockUsers = [
    UserModel(id: 1, username: '김경우'),
    UserModel(id: 2, username: '정인영'),
  ];

  Future<List<UserModel>> getStoredUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockUsers;
  }

  Future<UserModel> registerFace({required String username}) async {
    await Future.delayed(const Duration(seconds: 1));
    final newUser = UserModel(
      id: _mockUsers.length + 1,
      username: username,
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    );
    _mockUsers.add(newUser);
    return newUser;
  }

  Future<UserModel> loginWithFace({required String username}) async {
    await Future.delayed(const Duration(seconds: 1));
    final user = _mockUsers.firstWhere(
      (u) => u.username == username,
      orElse: () => throw Exception('사용자를 찾을 수 없습니다'),
    );
    return UserModel(
      id: user.id,
      username: user.username,
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
