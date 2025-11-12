import 'package:flutter/material.dart';
import '../logic/auth_controller.dart';
import 'account_selection_screen.dart';
import 'register_screen.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({Key? key}) : super(key: key);

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _checkStoredUsers();
  }

  Future<void> _checkStoredUsers() async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final users = await _authController.getStoredUsers();
    
    if (!mounted) return;
    
    if (users.isEmpty) {
      // TV에 저장된 계정 없음 → 회원가입 화면으로
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
    } else {
      // 저장된 계정 있음 → 계정 선택 화면으로
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AccountSelectionScreen(users: users),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFBBBBBB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 24),
            Text(
              '사용자 정보 확인 중...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
