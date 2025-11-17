import 'package:flutter/material.dart';
import '../data/user_model.dart';
import 'face_login_widget.dart';
import 'register_screen.dart';

/// 계정 선택 화면 - 등록된 사용자 목록 표시
class AccountSelectionScreen extends StatelessWidget {
  final List<UserModel> users;

  const AccountSelectionScreen({super.key, required this.users});

  // 피그마 디자인 토큰
  static const Color _bgColor = Color(0xFFC3C3C3); // 배경색
  static const Color _addButtonColor = Color(0xFFE6E6E6); // 새 계정 추가 버튼 배경색
  static const Color _textColor = Color(0xFF6B6B6B); // LGGray
  static const Color _iconColor = Color(0xFF7E838C); // Sub3
  static const Color _white = Color(0xFFFFFFFF); // white

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor, // 피그마 Sub1 색상
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 기존 사용자들
            ...users.map((user) => Padding(
              padding: const EdgeInsets.only(right: 44), // 피그마 간격
              child: _buildUserProfile(
                context,
                user: user,
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
    required UserModel user,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(64.5), // 129/2
          child: Container(
            width: 129, // 피그마 크기
            height: 129,
            decoration: BoxDecoration(
              color: _white,
              shape: BoxShape.circle,
            ),
            child: user.characterImagePath != null
                ? ClipOval(
                    child: Image.asset(
                      user.characterImagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 60,
                          color: _iconColor,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 60,
                    color: _iconColor,
                  ),
          ),
        ),
        const SizedBox(height: 19), // 피그마 간격
        Text(
          user.username,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _textColor,
            letterSpacing: 1.44,
          ),
        ),
      ],
    );
  }

  Widget _buildAddUserButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          ),
          borderRadius: BorderRadius.circular(64.5), // 129/2
          child: Container(
            width: 129, // 피그마 크기
            height: 129,
            decoration: BoxDecoration(
              color: _addButtonColor, // #E6E6E6 색상
              shape: BoxShape.circle,
            ),
            child: Container(
              margin: const EdgeInsets.all(40), // 중앙 정렬을 위한 패딩 (아이콘 크기 증가에 맞춰 조정)
              child: Icon(
                Icons.add,
                size: 48, // 아이콘 크기 증가
                color: _iconColor, // 피그마 Sub3 색상
              ),
            ),
          ),
        ),
        const SizedBox(height: 19), // 피그마 간격 (텍스트 공간 확보)
        const SizedBox(
          height: 29, // 텍스트 높이와 동일하게 설정
        ),
      ],
    );
  }
}
