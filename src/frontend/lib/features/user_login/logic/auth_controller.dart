import '../data/auth_repository.dart';
import '../data/user_model.dart';

class AuthController {
  final AuthRepository _repository = AuthRepository();

  Future<List<UserModel>> getStoredUsers() async {
    return await _repository.getStoredUsers();
  }

  // 비밀번호 기반 회원가입
  Future<UserModel> signup({
    required String name,
    required String password,
    bool isChild = false,
  }) async {
    return await _repository.signup(
      name: name,
      password: password,
      isChild: isChild,
    );
  }

  // 비밀번호 기반 로그인
  Future<UserModel> login({
    required String name,
    required String password,
  }) async {
    return await _repository.login(
      name: name,
      password: password,
    );
  }

  // 사용자 데이터를 로컬 스토리지에 저장
  Future<void> saveUserToLocalStorage(UserModel user) async {
    await _repository.saveUserToLocalStorage(user);
  }

  // TODO: 얼굴 인식 기능은 나중에 구현 예정
  Future<UserModel> registerUser(String username, bool isChild, String? characterImagePath) async {
    return await _repository.registerFace(
      username: username,
      isChild: isChild,
      characterImagePath: characterImagePath,
    );
  }

  Future<UserModel> loginWithFace({required String username}) async {
    return await _repository.loginWithFace(username: username);
  }
}
