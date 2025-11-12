import '../data/auth_repository.dart';
import '../data/user_model.dart';

class AuthController {
  final AuthRepository _repository = AuthRepository();

  Future<List<UserModel>> getStoredUsers() async {
    return await _repository.getStoredUsers();
  }

  Future<UserModel> registerUser(String username, bool isChild) async {
    return await _repository.registerFace(
      username: username,
      isChild: isChild,
    );
  }

  Future<UserModel> loginWithFace({required String username}) async {
    return await _repository.loginWithFace(username: username);
  }
}
