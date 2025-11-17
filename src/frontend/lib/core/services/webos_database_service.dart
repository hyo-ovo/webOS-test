import 'package:flutter/foundation.dart';
import 'webos_luna_service.dart';

/// webOS Database (DB8) 서비스
/// 
/// webOS의 DB8 데이터베이스를 사용하여 사용자 데이터를 저장/조회하는 서비스입니다.
/// 참고: https://webostv.developer.lge.com/develop/references/database
class WebOSDatabaseService {
  // DB8 Service URI
  static const String _dbServiceUri = 'luna://com.palm.db';
  
  // 사용자 데이터 Kind ID
  static const String _userKindId = 'com.webos.homescreen.user:1';
  
  // 앱 ID (appinfo.json에서 가져와야 함)
  static const String _appId = 'com.webos.app.homescreen';

  /// 데이터베이스 초기화 (Kind 등록)
  /// 앱 최초 실행 시 한 번만 호출하면 됩니다.
  static Future<bool> initialize() async {
    try {
      final result = await WebOSLunaService.callOneReply(
        uri: _dbServiceUri,
        method: 'putKind',
        parameters: {
          'id': _userKindId,
          'owner': _appId,
          'indexes': [
            {
              'name': 'userId',
              'props': [
                {'name': 'id'}
              ]
            },
            {
              'name': 'username',
              'props': [
                {'name': 'username'}
              ]
            }
          ]
        },
      );

      if (result == null) {
        return false;
      }

      return result['returnValue'] == true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize database: $e');
      }
      return false;
    }
  }

  /// 사용자 데이터 저장
  /// 
  /// [userData] 저장할 사용자 데이터 (Map<String, dynamic>)
  /// Returns: 저장된 객체의 ID 또는 null
  static Future<String?> saveUser(Map<String, dynamic> userData) async {
    try {
      // 기존 사용자가 있는지 확인
      final existingUser = await findUserById(userData['id'] as int);
      
      if (existingUser != null) {
        // 기존 사용자가 있으면 merge로 업데이트
        return await updateUser(userData['id'] as int, userData);
      }

      // 새 사용자 저장
      final result = await WebOSLunaService.callOneReply(
        uri: _dbServiceUri,
        method: 'put',
        parameters: {
          'objects': [
            {
              '_kind': _userKindId,
              ...userData,
            }
          ]
        },
      );

      if (result == null || result['returnValue'] != true) {
        return null;
      }

      final results = result['results'] as List?;
      if (results != null && results.isNotEmpty) {
        return results[0]['id'] as String?;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save user: $e');
      }
      return null;
    }
  }

  /// 사용자 데이터 업데이트
  /// 
  /// [userId] 업데이트할 사용자 ID
  /// [userData] 업데이트할 사용자 데이터
  /// Returns: 업데이트된 객체의 ID 또는 null
  static Future<String?> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      final result = await WebOSLunaService.callOneReply(
        uri: _dbServiceUri,
        method: 'merge',
        parameters: {
          'query': {
            'from': _userKindId,
            'where': [
              {
                'prop': 'id',
                'op': '=',
                'val': userId,
              }
            ]
          },
          'props': userData,
        },
      );

      if (result == null || result['returnValue'] != true) {
        return null;
      }

      // merge는 count를 반환하므로, 기존 ID를 반환
      return await findUserById(userId)?.then((user) => user?['_id'] as String?);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update user: $e');
      }
      return null;
    }
  }

  /// ID로 사용자 조회
  /// 
  /// [userId] 조회할 사용자 ID
  /// Returns: 사용자 데이터 또는 null
  static Future<Map<String, dynamic>?> findUserById(int userId) async {
    try {
      final result = await WebOSLunaService.callOneReply(
        uri: _dbServiceUri,
        method: 'find',
        parameters: {
          'query': {
            'from': _userKindId,
            'where': [
              {
                'prop': 'id',
                'op': '=',
                'val': userId,
              }
            ]
          }
        },
      );

      if (result == null || result['returnValue'] != true) {
        return null;
      }

      final results = result['results'] as List?;
      if (results != null && results.isNotEmpty) {
        return Map<String, dynamic>.from(results[0] as Map);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to find user by ID: $e');
      }
      return null;
    }
  }

  /// 모든 사용자 조회
  /// 
  /// Returns: 사용자 데이터 리스트
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final result = await WebOSLunaService.callOneReply(
        uri: _dbServiceUri,
        method: 'find',
        parameters: {
          'query': {
            'from': _userKindId,
          }
        },
      );

      if (result == null || result['returnValue'] != true) {
        return [];
      }

      final results = result['results'] as List?;
      if (results == null) {
        return [];
      }

      return results
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get all users: $e');
      }
      return [];
    }
  }

  /// 사용자 삭제
  /// 
  /// [userId] 삭제할 사용자 ID
  /// Returns: 삭제 성공 여부
  static Future<bool> deleteUser(int userId) async {
    try {
      final result = await WebOSLunaService.callOneReply(
        uri: _dbServiceUri,
        method: 'del',
        parameters: {
          'query': {
            'from': _userKindId,
            'where': [
              {
                'prop': 'id',
                'op': '=',
                'val': userId,
              }
            ]
          }
        },
      );

      if (result == null || result['returnValue'] != true) {
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete user: $e');
      }
      return false;
    }
  }
}

