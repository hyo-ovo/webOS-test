import 'package:flutter/material.dart';
import '../data/user_model.dart';
import 'face_login_widget.dart';
import 'register_screen.dart';

class AccountSelectionScreen extends StatelessWidget {
  final List<UserModel> users;

  const AccountSelectionScreen({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.face, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 60),
            
            // 사용자 프로필 목록
            Wrap(
              spacing: 40,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                // 기존 사용자들
                ...users.map((user) => _buildUserProfile(
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
                )),
                
                // 새 계정 추가 버튼
                _buildAddUserButton(context),
              ],
            ),
            
            const SizedBox(height: 50),
            const Text(
              '계정을 선택해주세요',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
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
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(70),
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.person, size: 70, color: Colors.black45),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          username,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAddUserButton(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          ),
          borderRadius: BorderRadius.circular(70),
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey[400]!,
                width: 3,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: const Icon(Icons.add, size: 70, color: Colors.black45),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '새 계정',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
