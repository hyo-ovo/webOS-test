import '../data/auth_repository.dart';
import '../data/user_model.dart';

class AuthController {
  final AuthRepository _repository = AuthRepository();

  Future<List<UserModel>> getStoredUsers() async {
    return await _repository.getStoredUsers();
  }

  Future<UserModel> registerFace({required String username}) async {
    if (username.trim().isEmpty) {
      throw Exception('사용자 이름을 입력해주세요');
    }
    return await _repository.registerFace(username: username);
  }

  Future<UserModel> loginWithFace({required String username}) async {
    return await _repository.loginWithFace(username: username);
  }
}
