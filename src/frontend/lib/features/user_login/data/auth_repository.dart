import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/services/webos_database_service.dart';
import 'user_model.dart';

class AuthRepository {
  // Backend API base URL
  static const String baseUrl = 'https://webos-backend.fly.dev';
  
  // 데이터베이스 초기화 플래그
  static bool _databaseInitialized = false;

  // 회원가입
  Future<UserModel> signup({
    required String name,
    required String password,
    bool isChild = false,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'password': password,
        'isChild': isChild,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['responseObject'] != null) {
        final userData = data['responseObject'];
        final user = UserModel(
          id: userData['id'] as int,
          username: userData['name'] as String,
          isChild: userData['isChild'] as bool? ?? false,
        );
        
        // 로컬 스토리지에 사용자 저장
        await saveUserToLocalStorage(user);
        
        return user;
      }
      throw Exception(data['message'] ?? '회원가입에 실패했습니다');
    }
    final errorData = json.decode(response.body);
    throw Exception(errorData['message'] ?? '회원가입에 실패했습니다');
  }

  // 로그인
  Future<UserModel> login({
    required String name,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['responseObject'] != null) {
        final responseData = data['responseObject'];
        final userData = responseData['user'];
        final user = UserModel(
          id: userData['id'] as int,
          username: userData['name'] as String,
          token: responseData['token'] as String?,
          isChild: userData['isChild'] as bool? ?? false,
        );
        
        // 로그인 성공 시 기존 저장된 사용자 정보를 업데이트 (캐릭터 이미지 등 유지)
        await _updateUserInLocalStorage(user);
        
        return user;
      }
      throw Exception(data['message'] ?? '로그인에 실패했습니다');
    }
    final errorData = json.decode(response.body);
    throw Exception(errorData['message'] ?? '로그인에 실패했습니다');
  }

  // 얼굴 인식 기반 회원가입 (기존 API 호환성 유지)
  Future<UserModel> registerFace({
    required String username,
    required bool isChild,
    String? characterImagePath,
  }) async {
    // 얼굴 인식 기반 회원가입의 경우 임시 비밀번호 사용
    // 실제 구현에서는 얼굴 인식 데이터를 서버에 전송해야 할 수 있습니다
    final user = await signup(
      name: username,
      password: 'face_auth_temp_password', // 임시 비밀번호
      isChild: isChild,
    );
    
    // 캐릭터 이미지 경로가 있으면 추가하여 저장
    if (characterImagePath != null) {
      final userWithCharacter = UserModel(
        id: user.id,
        username: user.username,
        token: user.token,
        isChild: user.isChild,
        characterImagePath: characterImagePath,
      );
      await saveUserToLocalStorage(userWithCharacter);
      return userWithCharacter;
    }
    
    return user;
  }

  // 얼굴 인식 기반 로그인 (기존 API 호환성 유지)
  Future<UserModel> loginWithFace({required String username}) async {
    // 얼굴 인식 기반 로그인의 경우 임시 비밀번호 사용
    // 실제 구현에서는 얼굴 인식 데이터를 서버에 전송해야 할 수 있습니다
    return login(
      name: username,
      password: 'face_auth_temp_password', // 임시 비밀번호
    );
  }

  // 데이터베이스 초기화 (필요시 자동 호출)
  Future<void> _ensureDatabaseInitialized() async {
    if (_databaseInitialized || kIsWeb) {
      return;
    }
    
    try {
      final initialized = await WebOSDatabaseService.initialize();
      if (initialized) {
        _databaseInitialized = true;
        if (kDebugMode) {
          print('Database initialized successfully');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize database: $e');
      }
    }
  }

  // webOS Database에 사용자 업데이트 (기존 정보 유지)
  Future<void> _updateUserInLocalStorage(UserModel user) async {
    // 웹 환경에서는 데이터베이스를 사용할 수 없으므로 무시
    if (kIsWeb) {
      if (kDebugMode) {
        print('Web environment: skipping database update');
      }
      return;
    }
    
    try {
      // 데이터베이스 초기화 확인
      await _ensureDatabaseInitialized();
      
      // 기존 사용자 정보 조회
      final existingUser = await WebOSDatabaseService.findUserById(user.id);
      
      // 기존 정보가 있으면 캐릭터 이미지 경로 유지
      UserModel userToSave = user;
      if (existingUser != null && existingUser['characterImagePath'] != null) {
        userToSave = UserModel(
          id: user.id,
          username: user.username,
          token: user.token,
          isChild: user.isChild,
          characterImagePath: existingUser['characterImagePath'] as String?,
        );
      }
      
      // UserModel을 Map으로 변환하여 저장
      final userData = userToSave.toJson();
      await WebOSDatabaseService.saveUser(userData);
      
      if (kDebugMode) {
        print('User updated in database: ${user.username}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update user in database: $e');
      }
    }
  }

  // webOS Database에 사용자 저장 (public 메서드)
  Future<void> saveUserToLocalStorage(UserModel user) async {
    // 웹 환경에서는 데이터베이스를 사용할 수 없으므로 무시
    if (kIsWeb) {
      if (kDebugMode) {
        print('Web environment: skipping database save');
      }
      return;
    }
    
    try {
      // 데이터베이스 초기화 확인
      await _ensureDatabaseInitialized();
      
      // UserModel을 Map으로 변환하여 저장
      final userData = user.toJson();
      await WebOSDatabaseService.saveUser(userData);
      
      if (kDebugMode) {
        print('User saved to database: ${user.username}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save user to database: $e');
      }
    }
  }

  // 저장된 사용자 목록 가져오기
  Future<List<UserModel>> getStoredUsers() async {
    // 웹 환경에서는 데이터베이스를 사용할 수 없으므로 빈 리스트 반환
    if (kIsWeb) {
      if (kDebugMode) {
        print('Web environment: returning empty user list');
      }
      return [];
    }
    
    try {
      // 데이터베이스 초기화 확인
      await _ensureDatabaseInitialized();
      
      // 데이터베이스에서 모든 사용자 조회
      final usersData = await WebOSDatabaseService.getAllUsers();
      
      // Map을 UserModel로 변환
      return usersData
          .map((userData) {
            try {
              // DB8에서 반환된 데이터는 _kind, _id, _rev 등의 필드가 포함될 수 있음
              // UserModel에 필요한 필드만 추출
              return UserModel.fromJson({
                'id': userData['id'],
                'username': userData['username'],
                'token': userData['token'],
                'isChild': userData['isChild'] ?? false,
                'characterImagePath': userData['characterImagePath'],
              });
            } catch (e) {
              if (kDebugMode) {
                print('Failed to parse user data: $e');
              }
              return null;
            }
          })
          .whereType<UserModel>()
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load users from database: $e');
      }
      return [];
    }
  }
}