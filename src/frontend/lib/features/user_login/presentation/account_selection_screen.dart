import 'package:flutter/material.dart';
import '../data/user_model.dart';
import 'face_login_widget.dart';
import 'register_screen.dart';

/// 계정 선택 화면 - 등록된 사용자 목록 표시
class AccountSelectionScreen extends StatelessWidget {
  final List<UserModel> users;

  const AccountSelectionScreen({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // 수직 정렬 추가
          children: [
            // 기존 사용자들
            ...users.map((user) => Padding(
              padding: const EdgeInsets.only(right: 40),
              child: _buildUserProfile(
                context,
                username: user.username,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FaceLoginWidget(
                      isRegistration: false,
                      username: user.username,
                    ),
                  ),
                ),
              ),
            )),
            
            // 새 계정 추가 버튼
            _buildAddUserButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(
    BuildContext context, {
    required String username,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          username,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAddUserButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // 추가
      children: [
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          ),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              size: 50,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 16), // 텍스트 공간 확보
      ],
    );
  }
}
